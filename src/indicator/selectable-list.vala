/*
 * Copyright (C) 2018 Tom Beckmann <tomjonabc@gmail>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored by Tom Beckmann <tomjonabc@gmail>
 *
 */


public class SelectableList : Gtk.Grid
{
    int _selected_search_result = -1;
    public int selected_search_result {
	get {
	    return _selected_search_result;
	}
	set {
	    var children = get_children ();
	    if (_selected_search_result >= 0) {
		nth_item (_selected_search_result).set_state_flags (Gtk.StateFlags.NORMAL, true);
	    }

	    if (value < 0)
		_selected_search_result = (int) num_entries () - 1;
	    else if (value >= num_entries ())
		_selected_search_result = 0;
	    else
		_selected_search_result = value;

	    if (_selected_search_result >= 0) {
		nth_item (_selected_search_result).set_state_flags (Gtk.StateFlags.SELECTED, true);
	    }

	    if (scroll != null)
		assure_visible ();
	}
    }

    public unowned Gtk.ScrolledWindow? scroll = null;

    construct {
	orientation = Gtk.Orientation.VERTICAL;
    }

    void assure_visible () {
	Gtk.Allocation alloc;
	selected_item ().get_allocation (out alloc);

	var pos_y = int.max (alloc.y, 0);

	if (pos_y < scroll.vadjustment.value) {
	    scroll.vadjustment.value = pos_y;
	} else if (pos_y + alloc.height >= scroll.vadjustment.value + scroll.vadjustment.page_size) {
	    scroll.vadjustment.value = pos_y + alloc.height - scroll.vadjustment.page_size;
	}
    }

    public Gtk.Widget selected_item () {
	return nth_item (selected_search_result);
    }

    public uint num_entries () {
	return get_children ().length ();
    }

    public void clear () {
	foreach (var child in get_children ()) {
	    child.destroy ();
	}
    }

    Gtk.Widget nth_item (int n) {
	return get_children ().nth_data (get_children ().length () - n - 1);
    }
}
