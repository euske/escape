package {

import flash.display.Shape;
import flash.geom.Rectangle;
import flash.geom.Point;

//  EnemyItem
// 

public class EnemyItem extends MazeItem
{
  public var speed:int = 4;
  public var dx:int = 1;
  public var dy:int = 0;

  public function EnemyItem(maze:Maze)
  {
    super(maze);
    var size:int = maze.cellSize/8;
    graphics.lineStyle(0);
    graphics.beginFill(0x880044);
    graphics.drawRect(size, size, size*6, size*6);
    graphics.endFill();
  }

  public override function update(t:int):void
  {
    if ((x % maze.cellSize) == 0 &&
	(y % maze.cellSize) == 0) {
      if (!maze.isOpen(Math.floor(x/maze.cellSize),
		       Math.floor(y/maze.cellSize),
		       dx, dy)) {
	dx = -dx;
	dy = -dy;
      }
    }
    x += dx*speed;
    y += dy*speed;
  }
}

} // package
