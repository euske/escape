package {

import flash.display.Shape;
import flash.geom.Rectangle;
import flash.geom.Point;

//  ActorBomb
// 
public class ActorBomb extends Actor
{
  private var _size:int;

  public function ActorBomb(maze:Maze)
  {
    super(maze);

    _size = maze.cellSize/8;
    graphics.lineStyle(0);
    graphics.beginFill(0xff0000); // red
    graphics.drawRect(_size*2, _size*3, _size*4, _size*2);
    graphics.endFill();
  }
  
  public override function get rect():Rectangle
  {
    return new Rectangle(x+_size*2, y+_size*2, _size*4, _size*4);
  }
}

} // package
