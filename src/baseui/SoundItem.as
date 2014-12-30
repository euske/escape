package baseui {

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.media.Sound;
import flash.media.SoundTransform;
import flash.media.SoundChannel;

//  SoundItem
//
public class SoundItem extends PlayListItem
{
  public var sound:Sound;
  public var startpos:Number;
  public var transform:SoundTransform;

  private var _pos:Number;
  private var _channel:SoundChannel;

  public function SoundItem(sound:Sound, startpos:Number, transform:SoundTransform)
  {
    this.sound = sound;
    this.startpos = startpos;
    this.transform = transform;
  }

  public function get pos():Number
  {
    return _pos;
  }

  public override function start():void
  {
    if (_channel == null) {
      _channel = sound.play(_pos, 0, transform);
      _channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
      dispatchEvent(new Event(START));
    }
  }

  public override function abort():void
  {
    if (_channel != null) {
      _pos = _channel.position;
      _channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
      _channel.stop();
      _channel = null;
      dispatchEvent(new Event(ABORT));
    }
  }

  private function onSoundComplete(e:Event):void
  {
    _channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
    _channel = null;
    dispatchEvent(new Event(FINISH));
  }
}

} // package
