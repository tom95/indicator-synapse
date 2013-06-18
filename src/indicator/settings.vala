
public class Settings : Granite.Services.Settings
{
	static Settings? instance;

	public string shortcut { get; set; }

	Settings ()
	{
		base ("net.launchpad.synapse-project.indicator");
	}

	public static Settings get_default ()
	{
		if (instance == null)
			instance = new Settings ();

		return instance;
	}
}

