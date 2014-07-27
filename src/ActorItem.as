package {

import flash.display.Shape;
import flash.geom.Rectangle;
import flash.geom.Point;

//  ActorItem
// 
public class ActorItem extends Actor
{
  public var item:int;

  public function ActorItem(maze:Maze, item:int)
  {
    super(maze);
    this.item = item;

    var size:int = maze.cellSize;
    var color:uint;
    switch (item) {
    case MazeCell.ITEM_KEY:
      color = 0xffee44;		// yellow
      break;
    case MazeCell.ITEM_HEALTH:
      color = 0xccff44;		// green
      break;
    case MazeCell.ITEM_BOMB:
      color = 0x00ffff;		// cyan
      break;
    case MazeCell.ITEM_COMPASS:
      color = 0xff00ff;		// magenta
      break;
    default:
      color = 0xffffff;
      break;
    } 
    graphics.lineStyle(0);
    graphics.beginFill(color);
    graphics.drawRect(size*3/8, size/4, size/4, size/2);
    graphics.endFill();
  }
}

} // package
