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

  private var _maze:Maze;
  private var _size:int;
  
  public function MazeItem(maze:Maze, size:int)
  {
    _maze = maze;
    _size = size;
    graphics.beginFill(0, 0);
    graphics.drawRect(0, 0, size, size);
    graphics.endFill();
  }

  public function get maze():Maze
  {
    return _maze;
  }

  public function get size():int
  {
    return _size;
  }

  public virtual function get rect():Rectangle
  {
    return new Rectangle(x, y, _size, _size);
  }

  public virtual function update(t:int):void
  {
  }

  public virtual function get isPickable():Boolean
  {
    return false;
  }

  public static function createItem(type:int, maze:Maze, size:int):MazeItem
  {
    switch (type) {
    case GOAL:
      return new GoalItem(maze, size);
    case KEY:
      return new KeyItem(maze, size);
    case ENEMY:
      return new EnemyItem(maze, size);
    default:
      return null;
    }
  }
}

} // package

class GoalItem extends MazeItem
{
  public function GoalItem(maze:Maze, size:int)
  {
    super(maze, size);
    graphics.lineStyle(6, 0xffffff);
    graphics.drawRect(size/4, size/4, size/2, size/2);
  }
}

class KeyItem extends MazeItem
{
  public function KeyItem(maze:Maze, size:int)
  {
    super(maze, size);
    graphics.lineStyle(0);
    graphics.beginFill(0xffee44);
    graphics.drawRect(size*3/8, size/4, size/4, size/2);
    graphics.endFill();
  }

  public override function get isPickable():Boolean
  {
    return true;
  }
}

class EnemyItem extends MazeItem
{
  private var _speed:int;
  private var _dx:int;
  private var _dy:int;

  public function EnemyItem(maze:Maze, size:int, speed:int=4)
  {
    super(maze, size);
    graphics.lineStyle(0);
    graphics.beginFill(0x880044);
    graphics.drawRect(0, 0, size, size);
    graphics.endFill();
    _speed = speed;
    _dx = 1;
    _dy = 0;
  }

  public override function update(t:int):void
  {
    if ((x % maze.cellSize) == 0 &&
	(y % maze.cellSize) == 0) {
      if (!maze.isOpen(Math.floor(x/maze.cellSize),
		       Math.floor(y/maze.cellSize),
		       _dx, _dy)) {
	_dx = -_dx;
	_dy = -_dy;
      }
    }
    x += _dx*_speed;
    y += _dy*_speed;
  }
}
