package;

import flixel.util.FlxColor;
import flixel.FlxSprite;

class StrumPos extends FlxSprite {
    var elapsedTime:Float = 0;
    var mania:Int = 0;
    var colorMap:Map<Int, Array<FlxColor>> = [
        0 => [FlxColor.GRAY], 1 => [FlxColor.PURPLE, FlxColor.RED], 2 => [FlxColor.PURPLE, FlxColor.GRAY, FlxColor.RED],
        3 => [FlxColor.PURPLE, FlxColor.BLUE, FlxColor.GREEN, FlxColor.RED], 4 => [FlxColor.PURPLE, FlxColor.BLUE, FlxColor.GRAY, FlxColor.GREEN, FlxColor.RED]
    ];

    public function new(mania:Int) {
        super();

        this.mania = mania;

        makeGraphic(40, 5, FlxColor.WHITE);
    }

    public function playAnim(noteData:Int) {
        elapsedTime = 0.1;

        color = colorMap.get(mania)[noteData];
    }

    override function update(e:Float) {
        super.update(e);

        elapsedTime -= e;
        if (elapsedTime < 0) color = FlxColor.WHITE;
    }
}