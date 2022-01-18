package;

import flixel.FlxG;
import flixel.text.FlxText;

class MainMenuItem extends FlxText {
    public var time:Float = -1;
    public var wasDoubleClicked:Bool = false;

    public function new(name:String) {
        super(0, 0, 0, name, 16);

        font = 'assets/data/fonts/arial.ttf';


    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        #if !android if (FlxG.mouse.overlaps(this) && FlxG.mouse.justPressed) { #else if (FlxG.touches.list[0].justPressed) { #end
            if (time < 0) {
                time = 0.5;
            } else if (time > 0) {
                wasDoubleClicked = true;
            }

            this.bold = true;
        }

        #if !android if (!FlxG.mouse.overlaps(this) && FlxG.mouse.justPressed) { #else if (false) { #end
            this.bold = false;
        }

        time -= elapsed;
    }
}