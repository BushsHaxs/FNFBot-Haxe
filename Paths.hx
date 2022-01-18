package;

import flixel.graphics.frames.FlxAtlasFrames;

class Paths {
    inline static public function charts(chart:String = '') {
        return Main.getDataPath() + 'charts/$chart';
    }

    inline static public function inst(chart:String = '') {
        return Main.getDataPath() + 'charts/$chart-inst.ogg';
    }
    inline static public function voices(chart:String = '') {
        return Main.getDataPath() + 'charts/$chart-voices.ogg';
    }

    inline static public function image(key:String) {return Main.getDataPath() + 'assets/images/$key.png';}
    
    inline static public function file(key:String) {return Main.getDataPath() + 'assets/$key';}

    inline static public function getSparrowAtlas(key:String):FlxAtlasFrames
    {
        return FlxAtlasFrames.fromSparrow(image(key), file('images/$key.xml'));
    }
}