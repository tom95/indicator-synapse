/*
 * Copyright (C) 2010 Michal Hruby <michal.mhr@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA.
 *
 * Authored by Michal Hruby <michal.mhr@gmail.com>
 *
 */

namespace Sezen
{
  public class ResultSet : Object, Gee.Iterable <Gee.Map.Entry <Match, int>>
  {
    protected Gee.Map<Match, int> matches;
    protected Gee.Set<unowned string> uris;

    public ResultSet ()
    {
      Object ();
    }

    construct
    {
      matches = new Gee.HashMap<Match, int> ();
      // Match.uri is not owned, so we can optimize here
      uris = new Gee.HashSet<unowned string> ();
    }

    public Type element_type
    {
      get { return matches.element_type; }
    }

    public int size
    {
      get { return matches.size; }
    }

    public Gee.Set<Match> keys
    {
      owned get { return matches.keys; }
    }

    public Gee.Set<Gee.Map.Entry <Match, int>> entries
    {
      owned get { return matches.entries; }
    }

    public Gee.Iterator<Gee.Map.Entry <Match, int>?> iterator ()
    {
      return matches.iterator ();
    }

    public void add (Match match, int relevancy)
    {
      matches.set (match, relevancy);

      unowned string uri = match.uri;
      if (uri != null && uri != "")
      {
        uris.add (uri);
      }
    }

    public void add_all (ResultSet? rs)
    {
      if (rs == null) return;
      matches.set_all (rs.matches);
      uris.add_all (rs.uris);
    }

    public bool contains_uri (string uri)
    {
      return uri in uris;
    }

    public Gee.List<Match> get_sorted_list ()
    {
      var l = new Gee.ArrayList<Gee.Map.Entry<Match, int>> ();
      l.add_all (matches.entries);

      l.sort ((a, b) => 
      {
        unowned Gee.Map.Entry<Match, int> e1 = (Gee.Map.Entry<Match, int>) a;
        unowned Gee.Map.Entry<Match, int> e2 = (Gee.Map.Entry<Match, int>) b;
        int relevancy_delta = e2.value - e1.value;
        if (relevancy_delta != 0) return relevancy_delta;
        // FIXME: utf8 compare!
        else return e1.key.title.ascii_casecmp (e2.key.title);
      });

      var sorted_list = new Gee.ArrayList<Match> ();
      foreach (Gee.Map.Entry<Match, int> m in l)
      {
        sorted_list.add (m.key);
      }

      return sorted_list;
    }
  }

  errordomain SearchError
  {
    SEARCH_CANCELLED,
    UNKNOWN_ERROR
  }

  public abstract class DataPlugin : Object
  {
    public unowned DataSink data_sink { get; construct; }

    public abstract async ResultSet? search (Query query) throws SearchError;
  }
  
  public abstract class ActionPlugin : DataPlugin
  {
    // FIXME: should this even be async?
    public abstract ResultSet find_for_match (Query query, Match match);
    public override async ResultSet? search (Query query) throws SearchError
    {
      assert_not_reached ();
      return null;
    }
  }

  public class DataSink : Object
  {
    public DataSink ()
    {
    }

    ~DataSink ()
    {
      debug ("DataSink died...");
    }

    private Gee.Set<DataPlugin> plugins;
    private Gee.Set<ActionPlugin> actions;
    private Gee.List<Cancellable> cancellables;

    construct
    {
      plugins = new Gee.HashSet<DataPlugin> ();
      actions = new Gee.HashSet<ActionPlugin> ();
      cancellables = new Gee.ArrayList<Cancellable> ();

      load_plugins ();
    }

    // FIXME: public? really?
    public void register_plugin (DataPlugin plugin)
    {
      if (plugin is ActionPlugin)
      {
        actions.add (plugin as ActionPlugin);
      }
      else
      {
        plugins.add (plugin);
      }
    }

    private void load_plugins ()
    {
      // FIXME: turn into proper modules
      register_plugin (Object.new (typeof (DesktopFilePlugin),
                       "data-sink", this, null) as DataPlugin);
      register_plugin (Object.new (typeof (ZeitgeistPlugin),
                       "data-sink", this, null) as DataPlugin);
      register_plugin (Object.new (typeof (HybridSearchPlugin),
                       "data-sink", this, null) as DataPlugin);
      register_plugin (Object.new (typeof (GnomeSessionPlugin),
                       "data-sink", this, null) as DataPlugin);
      register_plugin (Object.new (typeof (UPowerPlugin),
                       "data-sink", this, null) as DataPlugin);
#if TEST_PLUGINS
      register_plugin (Object.new (typeof (TestSlowPlugin),
                       "data-sink", this, null) as DataPlugin);
#endif

      register_plugin (Object.new (typeof (CommonActions),
                       "data-sink", this, null) as DataPlugin);
    }

    public signal void plugin_search_done (DataPlugin plugin, ResultSet rs);

    public void cancel_search ()
    {
      foreach (var c in cancellables) c.cancel ();
      cancellables.clear ();
    }
    
    private ResultSet partial_result_set;

    public async Gee.List<Match> search (string query,
                                         QueryFlags flags) throws SearchError
    {
      var q = Query (query, flags);

      // clear current cancellables
      cancellables.clear (); // FIXME: really?

      var current_result_set = new ResultSet ();
      partial_result_set = current_result_set;
      int search_size = plugins.size;
      bool waiting = false;
      var current_cancellable = new Cancellable ();
      cancellables.add (current_cancellable);

      foreach (var data_plugin in plugins)
      {
        // we need to pass separate cancellable to each plugin, because we're
        // running them in parallel
        var c = new Cancellable ();
        cancellables.add (c);
        q.cancellable = c;
        // magic comes here
        data_plugin.search.begin (q, (src_obj, res) =>
        {
          var plugin = src_obj as DataPlugin;
          try
          {
            var results = plugin.search.end (res);
            plugin_search_done (plugin, results);
            current_result_set.add_all (results);
          }
          catch (SearchError err)
          {
            if (!(err is SearchError.SEARCH_CANCELLED))
            {
              warning ("%s returned error: %s",
                       plugin.get_type ().name (), err.message);
            }
          }

          if (--search_size == 0 && waiting) search.callback ();
        });
      }

      waiting = true;
      if (search_size > 0) yield;

      if (current_cancellable.is_cancelled ())
      {
        throw new SearchError.SEARCH_CANCELLED ("Cancelled");
      }

      return current_result_set.get_sorted_list ();
    }
    
    // this will return Matches found so far while search is running
    public Gee.List<Match> get_partial_results ()
    {
      return partial_result_set.get_sorted_list ();
    }

    public Gee.List<Match> find_action_for_match (Match match, string? query)
    {
      var rs = new ResultSet ();
      var q = Query (query ?? "");
      foreach (var action_plugin in actions)
      {
        rs.add_all (action_plugin.find_for_match (q, match));
      }
      
      return rs.get_sorted_list ();
    }
  }
}

