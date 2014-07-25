package {

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.media.Sound;
import flash.media.SoundTransform;
import flash.media.SoundChannel;

//  PlayListItem
//
public class PlayListItem extends EventDispatcher
{
  public static const START:String = "START";
  public static const STOP:String = "STOP";

  public var sound:Sound;
  public var startpos:Number;
  public var transform:SoundTransform;

  private var _pos:Number;
  private var _channel:SoundChannel;

  public function PlayListItem(sound:Sound, startpos:Number, transform:SoundTransform)
  {
    this.sound = sound;
    this.startpos = startpos;
    this.transform = transform;
    _pos = startpos;
  }

  public function get pos():Number
  {
    return _pos;
  }

  public function get channel():SoundChannel
  {
    return _channel;
  }

  public function start():void
  {
    _channel = sound.play(_pos, 0, transform);
    dispatchEvent(new Event(START));
  }

  public function stop():void
  {
    _channel.stop();
    dispatchEvent(new Event(STOP));
  }
}

} // package
