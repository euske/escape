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
  public var vx:int;
  public var vy:int;

  private var _size:int;

  public function ActorEnemy(maze:Maze, vx:int=1, vy:int=0)
  {
    super(maze);
    this.vx = vx;
    this.vy = vy;

    _size = maze.cellSize/8;
    graphics.lineStyle(0);
    graphics.beginFill(0x880044);
    graphics.drawRect(_size, _size, _size*6, _size*6);
    graphics.endFill();
  }

  public override function get rect():Rectangle
  {
    return new Rectangle(x+_size, y+_size, _size*6, _size*6);
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
    var volume:Number = 0.7-Math.abs(dx)*0.2-Math.abs(dy)*0.2;
    var sound:Sound = (vx < 0)? Sounds.leftSound : Sounds.rightSound;
    playSound(sound, volume, dx*0.5);
  }
}

} // package
