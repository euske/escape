package {

import flash.geom.Point;
import flash.geom.Rectangle;
import flash.media.SoundTransform;

//  Utility Functions
// 
public class Utils
{
  // clamp(v0, v, v1): caps the value between upper/lower bounds.
  public static function clamp(v0:int, v:int, v1:int):int
  {
    return Math.min(Math.max(v, v0), v1);
  }
  
  // rnd(n)
  public static function rnd(a:int, b:int=0):int
  {
    if (b < a) {
      var c:int = a;
      a = b;
      b = c;
    }
    return Math.floor(Math.random()*(b-a))+a;
  }

  // choose(a)
  public static function choose(a:Array):*
  {
    return a[rnd(a.length)];
  }

  // shuffle(a)
  public static function shuffle(a:Array):Array
  {
    for (var n:int = 0; n < a.length; n++) {
      var i:int = rnd(a.length);
      var j:int = rnd(a.length);
      var t:* = a[i];
      a[i] = a[j];
      a[j] = t;
    }
    return a;
  }

  // format
  public static function format(v:int, n:int=3, c:String=" "):String
  {
    var s:String = "";
    while (s.length < n) {
      s = (v % 10)+s;
      v /= 10;
      if (v <= 0) break;
    }
    while (s.length < n) {
      s = c+s;
    }
    return s;
  }

  // soundTransform
  public static function soundTransform(volume:Number, pan:Number):SoundTransform
  {
    volume = Math.min(Math.max(volume, 0.0), 1.0);
    pan = Math.min(Math.max(pan, -1.0), 1.0);
    volume = (1+Math.abs(pan))*0.5;
    return new SoundTransform(volume, pan);
  }
}

} // package
