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

public class Main : Wingpanel.Indicator
{
	// backend synapse initialization
	Type[] plugins = {
        typeof (SynapseIndicator.DesktopFilePlugin),
        typeof (SynapseIndicator.HybridSearchPlugin),
        typeof (SynapseIndicator.GnomeSessionPlugin),
        typeof (SynapseIndicator.GnomeScreenSaverPlugin),
        typeof (SynapseIndicator.SystemManagementPlugin),
        typeof (SynapseIndicator.CommandPlugin),
        typeof (SynapseIndicator.RhythmboxActions),
        typeof (SynapseIndicator.BansheeActions),
        typeof (SynapseIndicator.DirectoryPlugin),
        typeof (SynapseIndicator.LaunchpadPlugin),
        typeof (SynapseIndicator.CalculatorPlugin),
        typeof (SynapseIndicator.SelectionPlugin),
        typeof (SynapseIndicator.SshPlugin),
        typeof (SynapseIndicator.XnoiseActions),
        typeof (SynapseIndicator.ZeitgeistPlugin),
        typeof (SynapseIndicator.ZeitgeistRelated),
        // typeof (SynapseIndicator.ImgUrPlugin), appears disfunctional atm
        // action-only plugins
        typeof (SynapseIndicator.DevhelpPlugin),
        typeof (SynapseIndicator.OpenSearchPlugin),
        typeof (SynapseIndicator.LocatePlugin),
        typeof (SynapseIndicator.PastebinPlugin),
        typeof (SynapseIndicator.DictionaryPlugin),
	typeof (SynapseIndicator.FilezillaPlugin),
	typeof (SynapseIndicator.WolframAlphaPlugin)
	};

	public static SynapseIndicator.DataSink sink;

	private Wingpanel.Widgets.OverlayIcon? indicator_icon = null;
	private Menu? popover_widget = null;

	const string CODE_NAME = "de.tombeckmann.synapse";

	Cancellable? current_search = null;

	public Main (Wingpanel.IndicatorManager.ServerType server_type) {
		Object (code_name: CODE_NAME,
			display_name: _("Synapse"),
			description: _("Synapse Search Indicator"));

		sink = new SynapseIndicator.DataSink ();
		foreach (var plugin in plugins) {
			sink.register_static_plugin (plugin);
		}
	}

	public override Gtk.Widget get_display_widget () {
		if (indicator_icon == null) {
			indicator_icon = new Wingpanel.Widgets.OverlayIcon ("edit-find-symbolic");
		}

		return indicator_icon;
	}

	public override Gtk.Widget? get_widget () {
		if (popover_widget == null) {
			popover_widget = new Menu ();
			popover_widget.close.connect (() => {close (); print("restuqest close\n"); });

			popover_widget.search.connect ((text) => {
			    if (current_search != null) {
				current_search.cancel ();
				current_search = null;
			    }

			    sink.search.begin (text, SynapseIndicator.QueryFlags.ALL, null, current_search, (obj, res) =>  {
				try {
				    var matches = sink.search.end (res);
				    popover_widget.show_matches (matches);
				} catch (Error e) { warning (e.message); }
			    });
			});
		}

		visible = true;

		return popover_widget;
	}

	public override void opened () {
		if (popover_widget != null) {
		    popover_widget.focused ();
		}
	}

	public override void closed () {
	}
}

public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    debug ("Activating Synapse Indicator");

    var indicator = new Main (server_type);
    return indicator;
}

