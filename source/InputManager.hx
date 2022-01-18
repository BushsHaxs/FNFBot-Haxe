package;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;

class InputManager {
    public static var keys:Map<Int, Array<FlxKey>> = [
        0 => [SPACE],
        1 => [LEFT, RIGHT],
        2 => [LEFT, SPACE, RIGHT],
        3 => [LEFT, DOWN, UP, RIGHT],
        4 => [LEFT, DOWN, SPACE, UP, RIGHT],
        5 => [S, D, F, J, K, L],
        6 => [S, D, F, SPACE, J, K, L],
        7 => [A, S, D, F, H, J, K, L],
        8 => [A, S, D, F, SPACE, H, J, K, L]
    ];

    public function dispatchKey(noteData:Int, mania:Int = -1) 
    {
        var key:FlxKey;
        if (mania == -1) 
        {
            key = keys.get(3)[noteData];
        } else key = keys.get(mania)[noteData];

        var evt:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN, false, false, key, key);
        FlxG.stage.dispatchEvent(evt);
    }
}