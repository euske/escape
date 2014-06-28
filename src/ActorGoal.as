package {

import flash.display.Shape;
import flash.geom.Rectangle;
import flash.geom.Point;

//  ActorGoal
// 
public class ActorGoal extends Actor
{
  public function ActorGoal(maze:Maze)
  {
    super(maze);
    var size:int = maze.cellSize;
    graphics.lineStyle(6, 0xffffff);
    graphics.drawRect(size/4, size/4, size/2, size/2);
  }
}

} // package
