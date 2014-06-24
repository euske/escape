package {

import flash.display.Shape;
import flash.geom.Rectangle;
import flash.geom.Point;

//  MazeItem
// 
public class MazeItem extends Shape
{
  public static const GOAL:int = 1;
  public static const KEY:int = 2;
  public static const TRAP:int = 3;
  public static const ENEMY:int = 4;
  
  private var _pos:Point;

  public function MazeItem(x:int, y:int, size:int)
  {
    _pos = new Point(x, y);
    graphics.beginFill(0, 0);
    graphics.drawRect(0, 0, size, size);
    graphics.endFill();
  }

  public function get pos():Point
  {
    return _pos;
  }

  public static function createItem(type:int, x:int, y:int, size:int):MazeItem
  {
    switch (type) {
    case GOAL:
      return new GoalItem(x, y, size);
    case KEY:
      return new KeyItem(x, y, size);
    default:
      return null;
    }
  }
}

} // package

class GoalItem extends MazeItem
{
  public function GoalItem(x:int, y:int, size:int)
  {
    super(x, y, size);
    graphics.lineStyle(6, 0xffffff);
    graphics.drawRect(size/4, size/4, size/2, size/2);
  }
}

class KeyItem extends MazeItem
{
  public function KeyItem(x:int, y:int, size:int)
  {
    super(x, y, size);
    graphics.beginFill(0xffee44);
    graphics.drawRect(size*3/8, size/4, size/4, size/2);
    graphics.endFill();
  }
}
