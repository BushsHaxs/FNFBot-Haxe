package;

import sys.io.File;
import haxe.Json;

using StringTools;

typedef PsychEngineSong = {
    var song:String;
	var notes:Array<PsychEngineSwagSection>;
	var events:Array<Dynamic>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var player3:String; //deprecated, now replaced by gfVersion
	var gfVersion:String;
	var stage:String;

	var mania:Int;

	var arrowSkin:String;
	var splashSkin:String;
	var validScore:Bool;
}

typedef PsychEngineSwagSection = {
	var sectionNotes:Array<Dynamic>;
	var lengthInSteps:Int;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var gfSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Bool;
}

class Song {
    public static function loadFromJson(song:String):PsychEngineSong
    {
        var rawJson:String = null;
        
        rawJson = File.getContent(song).trim();

        while (!rawJson.endsWith("}"))
        {
            rawJson = rawJson.substr(0, rawJson.length - 1);
        }

        var songJson:PsychEngineSong = parseJSONshit(rawJson);
        return songJson;
    }

    public static function parseJSONshit(rawJson:String):PsychEngineSong
    {
        var swagShit:PsychEngineSong = cast Json.parse(rawJson).song;
        swagShit.validScore = true;
        return swagShit;
    }
}