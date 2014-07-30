package {

import flash.display.Shape;
import flash.geom.Rectangle;
import flash.geom.Point;

//  ActorItem
// 
public class ActorItem extends Actor
{
  public var item:int;

  private var _size:int;

  public function ActorItem(maze:Maze, item:int)
  {
    super(maze);
    this.item = item;

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
    _size = maze.cellSize/8;
    graphics.lineStyle(0);
    graphics.beginFill(color);
    graphics.drawRect(_size*3, _size*2, _size*2, _size*4);
    graphics.endFill();
  }
  
  public override function get rect():Rectangle
  {
    return new Rectangle(x+_size*2, y+_size*2, _size*4, _size*4);
  }
}

} // package
