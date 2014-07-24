package {

import flash.display.Shape;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.media.Sound;

//  ActorEnemy
// 
public class ActorEnemy extends Actor
{
  public var speed:int = 4;
  public var vx:int = 1;
  public var vy:int = 0;

  public function ActorEnemy(maze:Maze)
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

  public override function makeNoise(dx:Number, dy:Number):void
  {
    var volume:Number = 0.7-Math.abs(dx)*0.1-Math.abs(dy)*0.2;
    if (volume <= 0) return;

    var sound:Sound = (vx < 0)? Sounds.leftSound : Sounds.rightSound;
    if (sound != playingSound) {
      stopSound();
    }
    playSound(sound);
    setSoundTransform(volume, dx*0.5);
  }
}

} // package
