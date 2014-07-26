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

  public var hasKey:Boolean;

  private var _maze:Maze;
  private var _pos:Point;
  private var _goal:Point;

  public function Player(maze:Maze)
  {
    _maze = maze;
    _pos = new Point();
    _goal = new Point();
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
      var size:int = _maze.cellSize/8;
      graphics.clear();
      graphics.beginFill(PLAYER_COLOR);
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
    var p:Point = new Point(_maze.cellSize*_pos.x,
			    _maze.cellSize*_pos.y);
    if (!visible) {
      x = p.x;
      y = p.y;
    } else {
      x = _goal.x;
      y = _goal.y;
    }
    _goal = p;
  }
}

} // package
