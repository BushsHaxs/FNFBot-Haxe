package;

import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flash.display.BitmapData;

using StringTools;

class Note extends FlxSprite
{
	var gfxLetter:Array<String> = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 
	'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R'];

	public static var keysShit:Map<Int, Map<String, Dynamic>> = [
		0 => ["letters" => ["E"], "anims" => ["UP"], "strumAnims" => ["SPACE"]],
		1 => ["letters" => ["A", "D"], "anims" => ["LEFT", "RIGHT"], "strumAnims" => ["LEFT", "RIGHT"]],
		2 => ["letters" => ["A", "E", "D"], "anims" => ["LEFT", "UP", "RIGHT"], "strumAnims" => ["LEFT", "SPACE", "RIGHT"]],
		3 => ["letters" => ["A", "B", "C", "D"], "anims" => ["LEFT", "DOWN", "UP", "RIGHT"], "strumAnims" => ["LEFT", "DOWN", "UP", "RIGHT"]],
		4 => ["letters" => ["A", "B", "E", "C", "D"], "anims" => ["LEFT", "DOWN", "UP", "UP", "RIGHT"],
			 "strumAnims" => ["LEFT", "DOWN", "SPACE", "UP", "RIGHT"]],
		5 => ["letters" => ["A", "C", "D", "F", "B", "I"], "anims" => ["LEFT", "UP", "RIGHT", "LEFT", "DOWN", "RIGHT"],
			 "strumAnims" => ["LEFT", "UP", "RIGHT", "LEFT", "DOWN", "RIGHT"]],
		6 => ["letters" => ["A", "C", "D", "E", "F", "B", "I"], "anims" => ["LEFT", "UP", "RIGHT", "UP", "LEFT", "DOWN", "RIGHT"],
			 "strumAnims" => ["LEFT", "UP", "RIGHT", "SPACE", "LEFT", "DOWN", "RIGHT"]],
		7 => ["letters" => ["A", "B", "C", "D", "F", "G", "H", "I"], "anims" => ["LEFT", "UP", "DOWN", "RIGHT", "LEFT", "DOWN", "UP", "RIGHT"],
			 "strumAnims" => ["LEFT", "DOWN", "UP", "RIGHT", "LEFT", "DOWN", "UP", "RIGHT"]],
		8 => ["letters" => ["A", "B", "C", "D", "E", "F", "G", "H", "I"], "anims" => ["LEFT", "DOWN", "UP", "RIGHT", "UP", "LEFT", "DOWN", "UP", "RIGHT"],
			 "strumAnims" => ["LEFT", "DOWN", "UP", "RIGHT", "SPACE", "LEFT", "DOWN", "UP", "RIGHT"]],
	];
	public static var scales:Array<Float> = [0.9, 0.85, 0.8, 0.7, 0.66, 0.6, 0.55, 0.50, 0.46];
	public static var ammo:Array<Int> = [
		1, 2, 3, 4, 5, 6, 7, 8, 9
	];

	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var ignoreNote:Bool = false;
	public var hitByOpponent:Bool = false;
	public var noteWasHit:Bool = false;
	public var prevNote:Note;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var noteType(default, set):String = null;

	public var eventName:String = '';
	public var eventLength:Int = 0;
	public var eventVal1:String = '';
	public var eventVal2:String = '';

	public var inEditor:Bool = false;
	public var gfNote:Bool = false;
	private var earlyHitMult:Float = 0.5;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	// Lua shit
	public var noteSplashDisabled:Bool = false;
	public var noteSplashTexture:String = null;
	public var noteSplashHue:Float = 0;
	public var noteSplashSat:Float = 0;
	public var noteSplashBrt:Float = 0;

	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var offsetAngle:Float = 0;
	public var multAlpha:Float = 1;

	public var copyX:Bool = true;
	public var copyY:Bool = true;
	public var copyAngle:Bool = true;
	public var copyAlpha:Bool = true;

	public var hitHealth:Float = 0.023;
	public var missHealth:Float = 0.0475;

	public var texture(default, set):String = null;

	public var noAnimation:Bool = false;
	public var hitCausesMiss:Bool = false;
	public var distance:Float = 2000;//plan on doing scroll directions soon -bb

	public var mania:Int = 1;

	var ogW:Float;
	var ogH:Float;

	var defaultWidth:Float = 0;
	var defaultHeight:Float = 0;

	public var isParent:Bool; //ke input shits
	public var childs:Array<Note> = [];
	public var parent:Note;
	public var susActive:Bool = true;
	public var spotInLine:Int = 0;

	private function set_texture(value:String):String {
		if(texture != value) {
			reloadNote('', value);
		}
		texture = value;
		return value;
	}

	private function set_noteType(value:String):String {
		if(noteData > -1 && noteType != value) {
			switch(value) {
				case 'Hurt Note':
					ignoreNote = mustPress;
					reloadNote('HURT');
					noteSplashTexture = 'HURTnoteSplashes';
					if(isSustainNote) {
						missHealth = 0.1;
					} else {
						missHealth = 0.3;
					}
					hitCausesMiss = true;
				case 'No Animation':
					noAnimation = true;
				case 'GF Sing':
					gfNote = true;
			}
			noteType = value;
		}
		return value;
	}

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inEditor:Bool = false)
	{
		super();

		mania = PlayState.mania;

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		this.inEditor = inEditor;

		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= FlxG.height * 2;
		this.strumTime = strumTime;

		this.noteData = noteData;

		if(noteData > -1) {
			texture = '';

			if(!isSustainNote) { //Doing this 'if' check to fix the warnings on Senpai songs
				var animToPlay:String = '';
				animToPlay = Note.keysShit.get(mania).get('letters')[noteData];
				animation.play(animToPlay);
			}
		}

		// trace(prevNote);

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;
			multAlpha = 0.6;
			flipY = true;
			if(FlxG.save.data.upscroll && FlxG.save.data.upscroll != null) flipY = false;

			offsetX += width / 2;
			copyAngle = false;

			animation.play(Note.keysShit.get(mania).get('letters')[noteData] + ' tail');

			updateHitbox();

			offsetX -= width / 2;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(Note.keysShit.get(mania).get('letters')[prevNote.noteData] + ' hold');

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.05;
				if(PlayState.instance != null)
				{
					prevNote.scale.y *= PlayState.instance.songSpeed;
				}
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		} else if(!isSustainNote) {
			earlyHitMult = 1;
		}
		x += offsetX;
	}

	function reloadNote(?prefix:String = '', ?texture:String = '', ?suffix:String = '') {
		if(prefix == null) prefix = '';
		if(texture == null) texture = '';
		if(suffix == null) suffix = '';
		
		var skin:String = texture;
		if(texture.length < 1) {
			skin = 'NOTE_assets';
		}

		var animName:String = null;
		if(animation.curAnim != null) {
			animName = animation.curAnim.name;
		}

		var arraySkin:Array<String> = skin.split('/');
		arraySkin[arraySkin.length-1] = prefix + arraySkin[arraySkin.length-1] + suffix;

		var lastScaleY:Float = scale.y;
		var blahblah:String = arraySkin.join('/');

		defaultWidth = 40;
		defaultHeight = 40;
		frames = Paths.getSparrowAtlas(blahblah);
		loadNoteAnims();
		antialiasing = true;
		if(isSustainNote) {
			scale.y = lastScaleY;
		}
		updateHitbox();

		if(animName != null)
			animation.play(animName, true);
	}

	function loadNoteAnims() {
		for (i in 0...gfxLetter.length)
			{
				animation.addByPrefix(gfxLetter[i], gfxLetter[i] + '0');
	
				if (isSustainNote)
				{
					animation.addByPrefix(gfxLetter[i] + ' hold', gfxLetter[i] + ' hold');
					animation.addByPrefix(gfxLetter[i] + ' tail', gfxLetter[i] + ' tail');
				}
			}
				
			ogW = width;
			ogH = height;
			if (!isSustainNote)
				setGraphicSize(Std.int(defaultWidth));
			else
				setGraphicSize(Std.int(defaultWidth), Std.int(defaultHeight * scales[0]));
			updateHitbox();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		mania = PlayState.mania;

        if (!mustPress) multAlpha = 0.4;
        
		if (tooLate && !inEditor)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}