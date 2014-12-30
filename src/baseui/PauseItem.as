package baseui {

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.getTimer;

//  PauseItem
//
public class PauseItem extends PlayListItem
{
  public var length:int;

  private var _t:int;

  public function PauseItem(length:int)
  {
    this.length = length;
  }

  public override function start():void
  {
    _t = getTimer() + length;
    dispatchEvent(new Event(START));
  }

  public override function abort():void
  {
    dispatchEvent(new Event(ABORT));
  }
  
  public override function idle():void
  {
    if (_t <= getTimer()) {
      dispatchEvent(new Event(FINISH));
    }
  }
  
}

} // package
