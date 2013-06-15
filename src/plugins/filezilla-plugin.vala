/*
 * Copyright (C) 2013 Tom Beckmann <tomjonabc@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
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
 * Authored by Tom Beckmann <tomjonabc@gmail.com>
 *
 */

using Gee;

namespace Synapse
{
  public class FilezillaPlugin: Object, Activatable, ItemProvider
  {
    public  bool      enabled { get; set; default = true; }
    private ArrayList<Site> sites;
    
    protected File config_file;
    protected FileMonitor monitor;

    static construct
    {
      register_plugin ();
    }
    
    construct
    {
      sites = new ArrayList<Site> ();
    }

    public void activate ()
    {
      this.config_file = File.new_for_path (Environment.get_home_dir () + "/.filezilla/sitemanager.xml");

      parse_site_config.begin ();

      try {
        this.monitor = config_file.monitor_file (FileMonitorFlags.NONE);
        this.monitor.changed.connect (this.handle_site_config_update);
      }
      catch (IOError e)
      {
        Utils.Logger.warning (this, "Failed to start monitoring changes of filezilla site config file");
      }
    }

    public void deactivate () {}

    static void register_plugin ()
    {
      DataSink.PluginRegistry.get_default ().register_plugin (
        typeof (FilezillaPlugin),
    		"Filezilla", // Plugin title
        _ ("Connect to Filezilla sites"), // description
        "applications-internet",	// icon name
        register_plugin, // reference to this function
    		// true if user's system has all required components which the plugin needs
        (Environment.find_program_in_path ("filezilla") != null),
        _ ("Filezilla is not installed") // error message
      );
    }

    private async void parse_site_config ()
    {
      sites.clear ();

      try
      {
        var dis = new DataInputStream (config_file.read ());

        string line;
        string? host = null;
        string? name = null;

        while ((line = yield dis.read_line_async (Priority.DEFAULT)) != null)
        {
            var relevant = line.substring (line.index_of ("<") + 1, 4);
            if (relevant == "Host")
                host = line.slice (line.index_of ("<Host>") + 6, line.index_of ("</Host>"));
            else if (relevant == "Name")
                name = line.slice (line.index_of ("<Name>") + 6, line.index_of ("</Name>"));

            if (host != null && name != null) {
                Utils.Logger.debug (this, "site added: %s:%s\n", name, host);
                sites.add (new Site (name, host));
                host = null;
                name = null;
            }
        }
      }
      catch (Error e)
      {
        Utils.Logger.warning (this, "%s: %s", config_file.get_path (), e.message);
      }
    }
    
    public void handle_site_config_update (FileMonitor monitor,
                                          File file,
                                          File? other_file,
                                          FileMonitorEvent event_type)
    {
      if (event_type == FileMonitorEvent.CHANGES_DONE_HINT)
      {
        Utils.Logger.log (this, "filezilla config has changed, reparsing");
        parse_site_config.begin ();
      }
    }

    public bool handles_query (Query query)
    {
      return sites.size > 0 && 
            ( QueryFlags.ACTIONS in query.query_type ||
              QueryFlags.INTERNET in query.query_type);
    }

    public async ResultSet? search (Query q) throws SearchError
    {
      Idle.add (search.callback);
      yield;
      q.check_cancellable ();

      var results = new ResultSet ();
      
      var matchers = Query.get_matchers_for_query (q.query_string, 0,
        RegexCompileFlags.OPTIMIZE | RegexCompileFlags.CASELESS);

      foreach (var site in sites)
      {
        foreach (var matcher in matchers)
        {
          if (matcher.key.match (site.description) || matcher.key.match (site.title))
          {
            results.add (site, matcher.value - Match.Score.INCREMENT_SMALL);
            break;
          }
        }
      }

      q.check_cancellable ();

      return results;
    }

    private class Site : Object, Match
    {
      public string title           { get; construct set; }
      public string description     { get; set; }
      public string icon_name       { get; construct set; }
      public bool   has_thumbnail   { get; construct set; }
      public string thumbnail_path  { get; construct set; }
      public MatchType match_type   { get; construct set; }

      public void execute (Match? match)
      {
        try
        {
          AppInfo ai = AppInfo.create_from_commandline (
            "filezilla --site=\"0%s\"".printf (this.title),
            "filezilla", 0);
          ai.launch (null, new Gdk.AppLaunchContext ());
        }
        catch (Error err)
        {
          warning ("%s", err.message);
        }
      }

      public Site (string name, string host)
      {
        Object (
          match_type: MatchType.ACTION,
          title: name,
          description: _ ("Connect to %s").printf (host),
          has_thumbnail: false,
          icon_name: "applications-internet"
        );
        
      }
    }
  }
}

// vim: expandtab softtabstop tabstop=2

