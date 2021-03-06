package {

import flash.events.Event;

//  ActorEvent
//
public class ActorEvent extends Event
{
  public static const COLLIDED:String = "ActorEvent.COLLIDED";
  public static const EXPLODED:String = "ActorEvent.EXPLODED";

  public var actor:Actor;

  public function ActorEvent(type:String, actor:Actor)
  {
    super(type);
    this.actor = actor;
  }
}

} // package

