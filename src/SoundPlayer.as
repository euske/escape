package {

import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;

//  SoundPlayer
//
public class SoundPlayer extends Object
{
  public function SoundPlayer()
  {
    _playlist = new Vector.<PlayListItem>();
  }

  public function addSound(sound:Sound, 
			   start:Number=0.0,
			   transform:SoundTransform=null):void
  {
    _playlist.push(new PlayListItem(sound, start, transform));
    update();
  }

  public function get isPlaying():Boolean
  {
    return _playing;
  }

  public function set isPlaying(v:Boolean):void
  {
    _playing = v;
    if (_playing) {
      update();
    } else {
      if (_channel != null) {
	_lastpos = _channel.position;
	_channel.stop();
	_channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
	_channel = null;
      }
    }
  }

  private var _playing:Boolean;
  private var _lastpos:Number;
  private var _channel:SoundChannel;
  private var _playlist:Vector.<PlayListItem>;

  private function update():void
  {
    if (_channel != null) return;
    if (_playing && 0 < _playlist.length) {
      var item:PlayListItem = _playlist[0];
      var pos:Number = (0 < _lastpos)? _lastpos : item.start;
      _channel = item.sound.play(pos, 0, item.transform);
      _channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
    }
  }

  private function onSoundComplete(e:Event):void
  {
    _lastpos = -1;
    _channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
    _channel = null;
    _playlist.shift();
    update();
  }
}

} // package

import flash.media.Sound;
import flash.media.SoundTransform;

class PlayListItem extends Object
{
  public var sound:Sound;
  public var start:Number;
  public var transform:SoundTransform;

  public function PlayListItem(sound:Sound, start:Number, transform:SoundTransform)
  {
    this.sound = sound;
    this.start = start;
    this.transform = transform;
  }
}
