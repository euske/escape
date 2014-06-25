package {

import flash.display.Sprite;
import flash.geom.Rectangle;
import flash.geom.Point;

//  Player
// 
public class Player extends Sprite
{
  private const PLAYER_COLOR:uint = 0xff8800;
  private const MAX_SPEED:Number = 20;

  private var _maze:Maze;
  private var _pos:Point;
  private var _goal:Point;

  public function Player(maze:Maze)
  {
    _maze = maze;
  }

  public function get pos():Point
  {
    return _pos;
  }
  public function set pos(v:Point):void
  {
    _pos = v;
    updatePos();
  }

  public function get rect():Rectangle
  {
    return new Rectangle(x, y, _maze.cellSize, _maze.cellSize);
  }

  public function move(dx:int, dy:int):void
  {
    _pos.x += dx;
    _pos.y += dy;
    updatePos();
  }

  public function update(t:int):void
  {
    if (visible) {
      var a:Number = Math.cos(t*0.3);
      var size:int = _maze.cellSize/8;
      graphics.beginFill(0);
      graphics.drawRect(size, size, size*6, size*6);
      graphics.endFill();
      graphics.beginFill(PLAYER_COLOR, a);
      graphics.drawRect(size, size, size*6, size*6);
      graphics.endFill();

      var dx:int = _goal.x - x;
      var dy:int = _goal.y - y;

      if (Math.abs(dx) < 2 && Math.abs(dy) < 2) {
	x = _goal.x;
	y = _goal.y;
      } else {
	var r:Number = Math.sqrt(dx*dx+dy*dy);
	r = Math.min(r*.5, MAX_SPEED)/r;
	x += dx*r;
	y += dy*r;
      }
    }
  }

  private function updatePos():void
  {
    _goal = new Point(_maze.cellSize*_pos.x,
		      _maze.cellSize*_pos.y);
    if (!visible) {
      x = _goal.x;
      y = _goal.y;
    }
  }
}

} // package
