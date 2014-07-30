package baseui {

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
    if (_channel == null) {
      _channel = sound.play(_pos, 0, transform);
      _channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
      dispatchEvent(new Event(START));
    }
  }

  public function stop():void
  {
    if (_channel != null) {
      _pos = _channel.position;
      _channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
      _channel.stop();
      _channel = null;
    }
  }

  private function onSoundComplete(e:Event):void
  {
    _channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
    _channel = null;
    dispatchEvent(new Event(STOP));
  }
}

} // package
