package {

import flash.events.Event;
import flash.geom.Point;

//  KeypadEvent
//
public class KeypadEvent extends Event
{
  public static const PRESSED:String = "KeypadEvent.PRESSED";

  public var key:Keytop;
  public var modifiers:uint;

  public function KeypadEvent(type:String, key:Keytop, modifiers:uint=0)
  {
    super(type);
    this.key = key;
    this.modifiers = modifiers;
  }
}

} // package

