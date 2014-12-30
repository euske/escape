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
    return addItem(new SoundItem(sound, startpos, transform));
  }

  public function addPause(length:int):PlayListItem
  {
    return addItem(new PauseItem(length));
  }

  public function addItem(item:PlayListItem):PlayListItem
  {
    _playlist.push(item);
    update();
    return item;
  }

  public function idle():void
  {
    if (_current != null) {
      _current.idle();
    }
  }

  public function reset():void
  {
    _playlist.length = 0;
    if (_current != null) {
      var item:PlayListItem = _current;
      _current = null;
      item.abort();	 // This might fire an event, so make sure it's run last.
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
      _current.abort();
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
      _current.addEventListener(PlayListItem.FINISH, onPlayItemComplete);
      _current.start();
    }
  }

  private function onPlayItemComplete(e:Event):void
  {
    _current.removeEventListener(PlayListItem.FINISH, onPlayItemComplete);
    _current = null;
    update();
  }
}

} // package
