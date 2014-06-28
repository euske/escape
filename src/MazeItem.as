package {

import flash.display.Shape;
import flash.geom.Rectangle;
import flash.geom.Point;

//  MazeItem
// 
public class MazeItem extends Shape
{
  private var _maze:Maze;
  
  public function MazeItem(maze:Maze)
  {
    _maze = maze;
  }

  public function get maze():Maze
  {
    return _maze;
  }

  public virtual function get rect():Rectangle
  {
    return new Rectangle(x, y, _maze.cellSize, _maze.cellSize);
  }

  public virtual function update(t:int):void
  {
  }

  public virtual function makeNoise(dx:int, dy:int):void
  {
  }
}

} // package
