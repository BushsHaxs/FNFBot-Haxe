package;

import flixel.graphics.frames.FlxAtlasFrames;

class Paths {
    inline static public function charts(chart:String = '') {
        return 'charts/$chart';
    }

    inline static public function inst(chart:String = '') {
        return 'charts/$chart-inst.ogg';
    }
    inline static public function voices(chart:String = '') {
        return 'charts/$chart-voices.ogg';
    }

    inline static public function image(key:String) {return 'assets/images/$key.png';}
    
    inline static public function file(key:String) {return 'assets/$key';}

    inline static public function getSparrowAtlas(key:String):FlxAtlasFrames
    {
        return FlxAtlasFrames.fromSparrow(image(key), file('images/$key.xml'));
    }
}