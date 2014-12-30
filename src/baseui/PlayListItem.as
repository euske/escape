package baseui {

import flash.events.Event;
import flash.events.EventDispatcher;

//  PlayListItem
//
public class PlayListItem extends EventDispatcher
{
  public static const START:String = "START";
  public static const FINISH:String = "FINISH";
  public static const ABORT:String = "ABORT";

  public virtual function start():void
  {
  }

  public virtual function abort():void
  {
  }

  public virtual function idle():void
  {
  }
}

} // package
