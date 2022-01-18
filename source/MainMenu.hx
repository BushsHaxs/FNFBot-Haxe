package;

import flixel.FlxG;
import sys.FileSystem;
import flixel.FlxState;

using StringTools;

class MainMenu extends FlxState {
    var textGroup:Array<MainMenuItem> = [];

    override function create()
    {

        super.create();

        var iterator:Int = 0;
        for (file in FileSystem.readDirectory(Paths.charts())) {
            if (file.endsWith('.json')) {
                var item:MainMenuItem = new MainMenuItem(file);
                item.y = 16 * iterator;
                textGroup.push(item);
                add(item);

                iterator++;
            }
        }

    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        for (item in textGroup) {
            if (item.wasDoubleClicked) {
                FlxG.switchState(new PlayState(item.text));
            }
        }
    }
}