
public class MatchItem : Wingpanel.Widgets.Container
{
	public SynapseIndicator.Match? match { get; private set; }
	public SynapseIndicator.Match? target { get; private set; }
	public Gtk.Widget inner_box { get; private set; }
	public Gtk.Box outer_box { get; private set; }
	Gtk.Label category;

	bool has_separator = false;

	public unowned Menu? menu = null;

	public signal void do_search (SynapseIndicator.Match match, SynapseIndicator.Match target);

	static Gtk.Widget get_box (string title, string icon, bool large)
	{
		var inner_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
		var label = new Gtk.Label (title);
		label.xalign = 0.0f;
		label.ellipsize = Pango.EllipsizeMode.MIDDLE;
		inner_box.pack_start (new Gtk.Image.from_pixbuf (find_icon (icon, 16)), false);
		inner_box.pack_start (label);

		inner_box.margin_left = 6;

		return inner_box;
	}

	private MatchItem () {
		clicked.connect (() => selected());
		button_release_event.connect (e => {
			if (e.button == 3 && menu != null) {
				menu.show_context_menu (this);
				return true;
			}
			return false;
		});
	}

	public MatchItem.with_match (SynapseIndicator.Match _match, string _category, bool large)
	{
		this.with_widget (_category, get_box (_match.title, _match.icon_name, large));
		match = _match;
		has_separator = true;
	}

	public MatchItem.with_action (SynapseIndicator.Match action, SynapseIndicator.Match _target, bool large)
	{
		this.with_widget (action.title, get_box (action.description, action.icon_name, large));
		match = action;
		target = _target;
		has_separator = true;
	}

	public MatchItem.contextual (SynapseIndicator.Match action, SynapseIndicator.Match _target, bool large)
	{
		this ();

		get_content_widget ().add (get_box (action.description, action.icon_name, large));
		match = action;
		target = _target;
	}

	public MatchItem.with_widget (string _category, Gtk.Widget _inner_box, bool no_hover = false)
	{
		this ();

		outer_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
		category = new Gtk.Label (_category);
		category.width_request = 90;
		category.xalign = 1.0f;
		category.margin_right = 12;

		inner_box = _inner_box;

		outer_box.pack_start (category, false);
		outer_box.pack_start (inner_box);
		outer_box.margin_right = 12;
		get_content_widget ().add (outer_box);

		if (no_hover) {
			leave_notify_event.connect (() => { return true; });
			enter_notify_event.connect (() => { return true; });
		}
	}

	public override bool draw (Cairo.Context cr)
	{
		base.draw (cr);
		if (has_separator)
			draw_separator (cr);
		return true;
	}

	void draw_separator (Cairo.Context cr)
	{
		cr.move_to (category.get_allocated_width () + 18.5, 0);
		cr.rel_line_to (0, get_allocated_height ());
		cr.set_source_rgba (0, 0, 0, Menu.STROKE_ALPHA);
		cr.set_line_width (1);
		cr.stroke ();
	}

	public void selected ()
	{
		if (match == null)
			return;

		if (match.match_type == SynapseIndicator.MatchType.SEARCH) {
			if (menu != null)
				menu.do_search (match, target);
			return;
		}

		if (target != null)
			match.execute_with_target (target);
		else {
			var actions = Main.sink.find_actions_for_match (match, null, SynapseIndicator.QueryFlags.ALL);
			actions.get (0).execute_with_target (match);
		}

		if (menu != null)
			menu.close ();
	}
}

public static Gdk.Pixbuf? find_icon (string name, int size)
{
	try {
		var icon = Icon.new_for_string (name);
		if (icon == null)
			return null;
		var info = Gtk.IconTheme.get_default ().lookup_by_gicon (icon, size, Gtk.IconLookupFlags.FORCE_SIZE);
		if (info == null)
			return null;
		return info.load_icon ();
	} catch (Error e) { warning (e.message); }

	return null;
}
