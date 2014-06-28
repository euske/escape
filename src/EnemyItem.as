package {

import flash.display.Shape;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;

//  EnemyItem
// 
public class EnemyItem extends MazeItem
{
  public var speed:int = 4;
  public var vx:int = 1;
  public var vy:int = 0;

  private static var leftSound:Sound = SoundGenerator.createRect(100);
  private static var rightSound:Sound = SoundGenerator.createRect(300);

  public function EnemyItem(maze:Maze)
  {
    super(maze);
    var size:int = maze.cellSize/8;
    graphics.lineStyle(0);
    graphics.beginFill(0x880044);
    graphics.drawRect(size, size, size*6, size*6);
    graphics.endFill();
  }

  public override function update(t:int):void
  {
    if ((x % maze.cellSize) == 0 &&
	(y % maze.cellSize) == 0) {
      if (!maze.isOpen(Math.floor(x/maze.cellSize),
		       Math.floor(y/maze.cellSize),
		       vx, vy)) {
	vx = -vx;
	vy = -vy;
      }
    }
    x += vx*speed;
    y += vy*speed;
  }

  private var _channel:SoundChannel;
  private function get isPlayingSound():Boolean
  {
    return (_channel != null);
  }
  private function playSound(sound:Sound, volume:Number=1.0, pan:Number=0.0):void
  {
    if (_channel == null) {
      volume = Math.min(Math.max(volume, 0.0), 1.0);
      pan = Math.min(Math.max(pan, -1.0), 1.0);
      _channel = sound.play(0, 0, new SoundTransform(volume, pan));
      _channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
    }
  }
  private function stopSound():void
  {
    if (_channel != null) {
      _channel.stop();
      _channel = null;
    }
  }
  private function onSoundComplete(e:Event):void
  {
    _channel = null;
  }

  public override function makeNoise(dx:int, dy:int):void
  {
    var volume:Number = 1.5-Math.abs(dx)*0.2-Math.abs(dy)*0.4;
    if (0 < volume) {
      var sound:Sound = (vx < 0)? leftSound : rightSound;
      playSound(sound, volume, dx*0.5);
    }
  }
}

} // package
