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

    _size = maze.cellSize/8;
    graphics.lineStyle(0);

    var color:uint;
    switch (item) {
    case MazeCell.ITEM_KEY:
      graphics.beginFill(0xffee44); // yellow
      graphics.drawRect(_size*3, _size*2, _size*2, _size*4);
      graphics.endFill();
      break;
    case MazeCell.ITEM_HEALTH:
      graphics.beginFill(0x88ff44); // green
      graphics.drawRect(_size*3, _size*3, _size*2, _size*2);
      graphics.endFill();
      break;
    case MazeCell.ITEM_BOMB:
      graphics.beginFill(0xff00ff); // magenta
      graphics.drawRect(_size*2, _size*3, _size*4, _size*2);
      graphics.endFill();
      break;
    case MazeCell.ITEM_COMPASS:
      graphics.beginFill(0x00ffff); // cyan
      graphics.drawRect(_size*2, _size*2, _size*4, _size*4);
      graphics.endFill();
      break;
    } 
  }
  
  public override function get rect():Rectangle
  {
    return new Rectangle(x+_size*2, y+_size*2, _size*4, _size*4);
  }
}

} // package
