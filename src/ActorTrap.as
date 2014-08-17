package {

import flash.display.Shape;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.media.Sound;

//  ActorTrap
// 
public class ActorTrap extends Actor
{
  private var _size:int;

  public function ActorTrap(maze:Maze)
  {
    super(maze);

    _size = maze.cellSize/8;
    graphics.lineStyle(0);
    graphics.beginFill(0x008822);
    graphics.drawCircle(_size*4, _size*4, _size*3);
    graphics.endFill();
  }

  public override function get rect():Rectangle
  {
    return new Rectangle(x+_size, y+_size, _size*6, _size*6);
  }

  public override function makeNoise(dx:Number, dy:Number):void
  {
    var volume:Number = 1.0-Math.abs(dx)*0.2-Math.abs(dy)*0.4;
    playSound(Sounds.trapSound, volume, dx*0.5);
  }
}

} // package
