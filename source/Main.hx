package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public static var dataPath:String = '';

	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, MainMenu));
	}

	static public function getDataPath():String 
	{
		#if mobile
		dataPath = "/storage/emulated/0/Android/data/" + Application.current.meta.get("packageName") + "/files/";         
		return dataPath;
		#else
		return "";//to prevent crashing
		#end
	}
}
