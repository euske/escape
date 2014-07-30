package baseui {

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
    _playlist.length = 0;
    if (_current != null) {
      _current.stop();
      _current = null;
    }
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
      _current.addEventListener(PlayListItem.STOP, onPlayItemComplete);
      _current.start();
    }
  }

  private function onPlayItemComplete(e:Event):void
  {
    _current.removeEventListener(PlayListItem.STOP, onPlayItemComplete);
    _current = null;
    update();
  }
}

} // package
