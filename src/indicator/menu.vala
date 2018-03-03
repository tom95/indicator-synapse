
public class Menu : Gtk.Grid
{
	const string SEARCH_VIEW = "search";
	const string CONTEXT_VIEW = "context";

	public const double STROKE_ALPHA = 0.2;

	Gtk.Entry entry;
	MatchItem entry_item;

	SelectableList results;
	SelectableList context_results;
	Gtk.Stack stack;

	public signal void search (string text);
	public signal void close ();

	public Menu ()
	{
		orientation = Gtk.Orientation.VERTICAL;

		stack = new Gtk.Stack ();
		stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;

		entry = new Gtk.Entry ();
		entry.hexpand = true;

		entry.primary_icon_name = "edit-find-symbolic";
		entry_item = new MatchItem.with_widget (_("Search:"), entry, true);
		add (entry_item);

		// forward any clicks on the item
		entry_item.button_release_event.connect ((e) => { entry.button_release_event (e); return true; });
		entry_item.motion_notify_event.connect ((e) => { entry.motion_notify_event (e); return true; });
		entry_item.button_press_event.connect ((e) => { entry.button_press_event (e); return true; });
		entry_item.draw.connect ((cr) => {
			if (results.num_entries () < 1)
				return false;

			cr.move_to (0, entry_item.get_allocated_height () - 0.5);
			cr.rel_line_to (entry_item.get_allocated_width (), 0);
			cr.set_line_width (1);
			cr.set_source_rgba (0, 0, 0, STROKE_ALPHA);
			cr.stroke ();
			return false;
		});

		entry.key_press_event.connect ((e) => {
			switch (e.keyval) {
				case Gdk.Key.Left:
					stack.visible_child_name = SEARCH_VIEW;
					return true;
				case Gdk.Key.Right:
				case Gdk.Key.Tab:
					if (stack.visible_child_name == CONTEXT_VIEW)
						activate_selected ();
					else
						show_context_menu ();
					return true;
				case Gdk.Key.Down:
					get_active_result_list ().selected_search_result++;
					return true;
				case Gdk.Key.Up:
					get_active_result_list ().selected_search_result--;
					return true;
				case Gdk.Key.Return:
				case Gdk.Key.KP_Enter:
					activate_selected ();
					return true;
				case Gdk.Key.Escape:
					if (stack.visible_child_name != SEARCH_VIEW) {
						stack.visible_child_name = SEARCH_VIEW;
						return true;
					}
					return false;
				default:
					if (stack.visible_child_name != SEARCH_VIEW)
						stack.visible_child_name = SEARCH_VIEW;
					return false;
			}
		});

		entry.changed.connect (() => {
			if (entry.text == "")
				clear ();
			else
				search (entry.text);
		});

		results = new SelectableList ();
		var scroll = new Wingpanel.Widgets.AutomaticScrollBox ();
		results.scroll = scroll;
		scroll.add (results);

		context_results = new SelectableList ();

		stack.add_named (scroll, SEARCH_VIEW);
		stack.add_named (context_results, CONTEXT_VIEW);
		add (stack);

		width_request = 480;
	}

	void activate_selected () {
		(get_active_result_list ().selected_item () as MatchItem).activate ();
	}

	SelectableList get_active_result_list () {
		if (stack.visible_child_name == SEARCH_VIEW)
			return results;
		else
			return context_results;
	}

	public void focused () {
		entry.grab_focus ();
	}

	Gtk.Label? nothing_found_label = null;

	public void show_matches (Gee.List<SynapseIndicator.Match> matches)
	{
		clear ();

		if (nothing_found_label != null)
			nothing_found_label.destroy ();

		if (matches.size < 1) {
			nothing_found_label = new Gtk.Label (_("No results for this query."));
			nothing_found_label.margin_top = nothing_found_label.margin_bottom = 6;
			nothing_found_label.show ();
			add (nothing_found_label);
			return;
		}

		var current_type = -2;
		foreach (var match in matches) {
			var tophit = current_type == -2;
			var title = tophit ? "Top hit" : "";
			if (!tophit) {
				if (current_type != match.match_type) {
					current_type = match.match_type;
					switch (current_type) {
						case SynapseIndicator.MatchType.APPLICATION:
							title = _("Applications");
							break;
						case SynapseIndicator.MatchType.TEXT:
							title = _("Texts");
							break;
						case SynapseIndicator.MatchType.GENERIC_URI:
							title = _("Files");
							break;
						case SynapseIndicator.MatchType.ACTION:
							title = _("Actions");
							break;
						case SynapseIndicator.MatchType.SEARCH:
							title = _("Search");
							break;
						case SynapseIndicator.MatchType.UNKNOWN:
							break;
						default:
							title = _("Other");
							break;
					}
				}
			} else
				current_type = -1;

			if (match.match_type == SynapseIndicator.MatchType.UNKNOWN) {
				var actions = Main.sink.find_actions_for_match (match, null, SynapseIndicator.QueryFlags.ALL);
				foreach (var action in actions) {
					var item = new MatchItem.with_action (action, match, tophit);
					item.menu = this;
					results.add (item);
					// if we are the tophit, only make the first item large
					if (tophit)
						tophit = false;
				}

				continue;
			}

			var item = new MatchItem.with_match (match, title, tophit);
			item.menu = this;
			results.add (item);
		}
		show_all ();
		results.selected_search_result = 0;
	}

	public void clear ()
	{
		context_results.clear ();
		results.clear ();
	}

	public void do_search (SynapseIndicator.Match match, SynapseIndicator.Match target)
	{
		clear ();

		stack.visible_child_name = SEARCH_VIEW;

		var search = match as SynapseIndicator.SearchMatch;
		search.search_source = target;

		var last = new SynapseIndicator.ResultSet ();
		search.search.begin (entry.text, SynapseIndicator.QueryFlags.ALL, last, null, (obj, res) => {
			try {
				var matches = search.search.end (res);
				show_matches (matches);
			} catch (Error e) {
				// FIXME is this likely? do smth more user friendly?
				warning (e.message);
			}
		});
	}

	public void show_context_menu (MatchItem? selected = null)
	{
		if (stack.visible_child_name == CONTEXT_VIEW)
			return;

		context_results.clear ();

		var active = selected ?? results.selected_item () as MatchItem;

		var actions = Main.sink.find_actions_for_match (active.match, null, SynapseIndicator.QueryFlags.ALL);
		foreach (var action in actions) {
			var item = new MatchItem.contextual (action, active.match, false);
			item.menu = this;
			context_results.add (item);
		}

		stack.visible_child_name = CONTEXT_VIEW;
		context_results.selected_search_result = 0;
		context_results.show_all ();
	}
}

