package {

import flash.display.Shape;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;

//  Actor
// 
public class Actor extends Shape
{
  private const EPSILON:Number = 0.05;

  private var _maze:Maze;
  
  public function Actor(maze:Maze)
  {
    _maze = maze;
  }

  public function get maze():Maze
  {
    return _maze;
  }

  private var _sound:Sound;
  private var _channel:SoundChannel;

  private function onSoundComplete(e:Event):void
  {
    _channel = null;
    _sound = null;
  }

  protected function playSound(sound:Sound, volume:Number=1.0, pan:Number=0.0):void
  {
    if (EPSILON <= volume) {
      if (_channel != null && _sound != sound) {
	stopSound();
      }
      if (_channel == null) {
	_sound = sound;
	_channel = sound.play();
	_channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
      }
      _channel.soundTransform = Utils.soundTransform(volume, pan);
    } else {
      stopSound();
    }
  }

  public function stopSound():void
  {
    if (_channel != null) {
      _channel.stop();
      _channel = null;
      _sound = null;
    }
  }

  public virtual function get rect():Rectangle
  {
    return new Rectangle(x, y, _maze.cellSize, _maze.cellSize);
  }

  public virtual function update(t:int):void
  {
  }

  public virtual function makeNoise(dx:Number, dy:Number):void
  {
  }
}

} // package
