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

  private var _size:int;
  
  public function MazeItem(size:int)
  {
    _size = size;
    graphics.beginFill(0, 0);
    graphics.drawRect(0, 0, size, size);
    graphics.endFill();
  }

  public function get size():int
  {
    return _size;
  }

  public virtual function get isPickable():Boolean
  {
    return false;
  }

  public virtual function get rect():Rectangle
  {
    return new Rectangle(x, y, _size, _size);
  }

  public virtual function update():void
  {
  }

  public static function createItem(type:int, size:int):MazeItem
  {
    switch (type) {
    case GOAL:
      return new GoalItem(size);
    case KEY:
      return new KeyItem(size);
    default:
      return null;
    }
  }
}

} // package

class GoalItem extends MazeItem
{
  public function GoalItem(size:int)
  {
    super(size);
    graphics.lineStyle(6, 0xffffff);
    graphics.drawRect(size/4, size/4, size/2, size/2);
  }
}

class KeyItem extends MazeItem
{
  public function KeyItem(size:int)
  {
    super(size);
    graphics.beginFill(0xffee44);
    graphics.drawRect(size*3/8, size/4, size/4, size/2);
    graphics.endFill();
  }

  public override function get isPickable():Boolean
  {
    return true;
  }
}
