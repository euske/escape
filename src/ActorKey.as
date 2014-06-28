package {

import flash.display.Shape;
import flash.geom.Rectangle;
import flash.geom.Point;

//  ActorKey
// 
public class ActorKey extends Actor
{
  public function ActorKey(maze:Maze)
  {
    super(maze);
    var size:int = maze.cellSize;
    graphics.lineStyle(0);
    graphics.beginFill(0xffee44);
    graphics.drawRect(size*3/8, size/4, size/4, size/2);
    graphics.endFill();
  }
}

} // package
