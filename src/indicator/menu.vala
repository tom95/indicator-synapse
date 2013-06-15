
public class Menu : Gtk.Menu
{
	Gtk.Entry entry;
	MatchItem entry_item;

	public signal void search (string text);

	public Menu ()
	{
		entry = new Gtk.Entry ();

		key_press_event.connect ((e) => {
			switch (e.keyval) {
				case Gdk.Key.Escape:
				case Gdk.Key.Up:
				case Gdk.Key.Down:
				case Gdk.Key.Return:
				case Gdk.Key.KP_Enter:
					return false;
				default:
					entry.key_press_event (e);
					if (entry.text == "")
						clear ();
					else
						search (entry.text);
					return true;
			}
		});

		entry.margin_right = entry.margin_bottom = 12;
		entry.margin_top = 6;
		entry.primary_icon_name = "edit-find-symbolic";
		entry_item = new MatchItem ("Search:", entry, true);
		append (entry_item);
		entry_item.button_release_event.connect ((e) => {
			return true;
		});
		entry_item.draw.connect ((cr) => {
			if (get_children ().length () < 2)
				return false;

			cr.move_to (0, entry_item.get_allocated_height () - 0.5);
			cr.rel_line_to (entry_item.get_allocated_width (), 0);
			cr.set_line_width (1);
			cr.set_source_rgba (0, 0, 0, 0.2);
			cr.stroke ();
			return false;
		});
	}

	public void show_matches (Gee.List<Synapse.Match> matches)
	{
		clear ();

		var current_type = -2;
		foreach (var match in matches) {
			var tophit = current_type == -2;
			var title = tophit ? "Top hit" : "";
			if (!tophit) {
				if (current_type != match.match_type) {
					current_type = match.match_type;
					switch (current_type) {
						case Synapse.MatchType.APPLICATION:
							title = _("Applications");
							break;
						case Synapse.MatchType.TEXT:
							title = _("Texts");
							break;
						case Synapse.MatchType.GENERIC_URI:
							title = _("Files");
							break;
						case Synapse.MatchType.ACTION:
							title = _("Actions");
							break;
						case Synapse.MatchType.SEARCH:
							title = _("Search");
							break;
						case Synapse.MatchType.UNKNOWN:
							break;
						default:
							title = _("Other");
							break;
					}
				}
			} else
				current_type = -1;

			if (match.match_type == Synapse.MatchType.UNKNOWN) {
				var actions = Main.sink.find_actions_for_match (match, null, Synapse.QueryFlags.ALL);
				foreach (var action in actions) {
					var item = new MatchItem.with_action (action, match, tophit);
					append (item);
					// if we are the tophit, only make the first item large
					if (tophit)
						tophit = false;
				}

				continue;
			}

			var item = new MatchItem.with_match (match, title, tophit);
			append (item);
		}
		show_all ();
		select_item (get_children ().nth_data (1));
	}

	public void clear ()
	{
		foreach (var child in get_children ()) {
			if (child == entry_item)
				continue;
			child.destroy ();
		}
	}
}

