
public class MatchItem : Gtk.MenuItem
{
	public Synapse.Match? match { get; private set; }
	public Synapse.Match? target { get; private set; }
	Gtk.Box box;
	Gtk.Label category;

	static Gtk.Widget get_box (string title, string icon, bool large)
	{
		var inner_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
		var label = new Gtk.Label (title);
		label.xalign = 0.0f;
		inner_box.pack_start (new Gtk.Image.from_pixbuf (find_icon (icon, 16)), false);
		inner_box.pack_start (label);

		inner_box.margin_left = 6;

		return inner_box;
	}

	public MatchItem.with_match (Synapse.Match _match, string _category, bool large)
	{
		this (_category, get_box (_match.title, _match.icon_name, large));
		match = _match;
		draw.connect (draw_separator);
	}

	public MatchItem.with_action (Synapse.Match action, Synapse.Match _target, bool large)
	{
		this (action.title, get_box (action.description, action.icon_name, large));
		match = action;
		target = _target;
		draw.connect (draw_separator);
	}

	public MatchItem (string _category, Gtk.Widget inner_box, bool no_hover = false)
	{
		box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
		category = new Gtk.Label (_category);
		category.width_request = 90;
		category.xalign = 0.8f;

		box.pack_start (category, false);
		box.pack_start (inner_box);
		box.margin_right = 12;
		add (box);

		if (no_hover) {
			leave_notify_event.connect (() => { return true; });
			enter_notify_event.connect (() => { return true; });
		}
	}

	bool draw_separator (Cairo.Context cr)
	{
		cr.move_to (category.get_allocated_width () + 30.5, 0);
		cr.rel_line_to (0, get_allocated_height ());
		cr.set_source_rgba (0, 0, 0, 0.2);
		cr.set_line_width (1);
		cr.stroke ();
		return false;
	}

	public override void activate ()
	{
		if (match == null)
			return;

		if (target != null)
			match.execute_with_target (target);
		else {
			var actions = Main.sink.find_actions_for_match (match, null, Synapse.QueryFlags.ALL);
			actions.get (0).execute_with_target (match);
		}
	}
}

