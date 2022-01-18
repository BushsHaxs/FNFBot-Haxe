package;

import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.math.FlxMath;
import Song.PsychEngineSong;
import sys.FileSystem;
import flixel.FlxState;

using StringTools;

class PlayState extends FlxState
{
	public static var instance:PlayState;
	public static var mania:Int = 0;
	public static var SONG:PsychEngineSong;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];

	public var songSpeed:Float = 0;

	public var strumGroup:Array<StrumPos> = [];

	var vocals:FlxSound;

	override public function create()
	{
		instance = this;

		generateSong();

		for (i in 0...(Note.ammo[mania] * 2)) {
			var strumLine:StrumPos = new StrumPos(mania);
			strumLine.y = FlxG.height * 0.5;
			strumLine.x += 40 * i;
			strumGroup.push(strumLine);
			add(strumLine);
		}

		super.create();
	}

	public function generateSong(song:String = 'zanta-mania.json') {
		if (FileSystem.exists(Paths.charts(song))) {
			SONG = Song.loadFromJson(Paths.charts(song));

			var songData = SONG;

			Conductor.changeBPM(songData.bpm);
		
			if (SONG.needsVoices)
				vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
			else
				vocals = new FlxSound();

			FlxG.sound.list.add(vocals);
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song));

			notes = new FlxTypedGroup<Note>();
			add(notes);

			vocals.play();

			songSpeed = songData.speed;
			songSpeed *= 0.6;
			mania = songData.mania;

			for (section in songData.notes) {
				for (notes in section.sectionNotes) {

					var daStrumTime:Float = notes[0];
					var daNoteData:Int = Std.int(notes[1] % Note.ammo[mania]);

					var gottaHitNote:Bool = section.mustHitSection;

					if (notes[1] > (Note.ammo[mania] - 1))
					{
						gottaHitNote = !section.mustHitSection;
					}

					var oldNote:Note;
					if (unspawnNotes.length > 0)
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
					else
						oldNote = null;

					var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
					swagNote.mustPress = gottaHitNote;
					swagNote.sustainLength = notes[2];
					swagNote.gfNote = (section.gfSection && (notes[1]<Note.ammo[mania]));
					swagNote.noteType = notes[3];

					swagNote.x = 40 * swagNote.noteData;

					swagNote.scrollFactor.set();

					var susLength:Float = swagNote.sustainLength;

					susLength = susLength / Conductor.stepCrochet;
					unspawnNotes.push(swagNote);

					var floorSus:Int = Math.floor(susLength);

					var type = 0;
					if(floorSus > 0) {
						for (susNote in 0...floorSus+1)
						{
							oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

							var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true);
							sustainNote.mustPress = gottaHitNote;
							sustainNote.gfNote = (section.gfSection && (notes[1]<Note.ammo[mania]));
							sustainNote.noteType = swagNote.noteType;
							sustainNote.scrollFactor.set();
							unspawnNotes.push(sustainNote);

							sustainNote.parent = swagNote;
							swagNote.childs.push(sustainNote);
							sustainNote.spotInLine = type;
							type++;
						}
					}
				}

			}


		}
	}

	override public function update(elapsed:Float)
	{
		Conductor.songPosition = FlxG.sound.music.time;

		var roundedSpeed:Float = FlxMath.roundDecimal(songSpeed, 2);
		if (unspawnNotes[0] != null)
		{
			var time:Float = 3000;//shit be werid on 4:3
			if(roundedSpeed < 1) time /= roundedSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}
	
		var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
		notes.forEachAlive(function(daNote:Note){
			var strumNum:Int = daNote.noteData;
			if (daNote.mustPress) strumNum += Note.ammo[mania];

			if (FlxG.save.data.upscroll != null && FlxG.save.data.upscroll) {
				daNote.y = (strumGroup[strumNum].y - 0.45 * (Conductor.songPosition - daNote.strumTime) * roundedSpeed);
			} else daNote.y = (strumGroup[strumNum].y + 0.45 * (Conductor.songPosition - daNote.strumTime) * roundedSpeed);

			daNote.x = 40 * daNote.noteData;
			if (daNote.mustPress) daNote.x += 40 * Note.ammo[mania];
			if (daNote.isSustainNote) {
				daNote.x += daNote.offsetX;
				if (daNote.animation.curAnim.name.endsWith('tail')) {
					daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * roundedSpeed + (46 * (roundedSpeed - 1));
					daNote.y -= 46 * (1 - (fakeCrochet / 600)) * roundedSpeed;
					daNote.y -= 19;
				}
			}
			if (daNote.isSustainNote && daNote.wasGoodHit){
				daNote.multAlpha = 0.4;
			}

			if (daNote.strumTime < Conductor.songPosition && !daNote.wasGoodHit) {
				daNote.wasGoodHit = true;
				daNote.multAlpha = 0.2;

				strumGroup[strumNum].playAnim(daNote.noteData);
			}

			var doKill = daNote.y > FlxG.height;
			if (FlxG.save.data.upscroll != null && FlxG.save.data.upscroll) doKill = daNote.y < 0;
			if (doKill) {
				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}

			daNote.alpha = daNote.multAlpha;
		}); 

		super.update(elapsed);
	}
}