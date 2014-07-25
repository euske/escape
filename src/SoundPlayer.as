package {

import flash.events.Event;
import flash.media.Sound;
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
			   startpos:Number=0.0,
			   transform:SoundTransform=null):PlayListItem
  {
    var item:PlayListItem = new PlayListItem(sound, startpos, transform)
    _playlist.push(item);
    update();
    return item;
  }

  public function reset():void
  {
    if (_current != null) {
      _current.stop();
      _current = null;
    }
    _playlist.length = 0;
  }

  public function get isActive():Boolean
  {
    return _active;
  }

  public function set isActive(v:Boolean):void
  {
    _active = v;
    if (_active) {
      update();
    } else if (_current != null) {
      _current.stop();
    }
  }

  private var _active:Boolean;
  private var _current:PlayListItem;
  private var _playlist:Vector.<PlayListItem>;

  private function update():void
  {
    if (_current != null) {
      _current.start();
    } else if (_active && 0 < _playlist.length) {
      _current = _playlist.shift();
      _current.start();
      _current.channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
    }
  }

  private function onSoundComplete(e:Event):void
  {
    _current.stop();
    _current.channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
    _current = null;
    update();
  }
}

} // package
