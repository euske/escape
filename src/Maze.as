package {

import flash.display.Sprite;
import flash.geom.Rectangle;
import flash.geom.Point;

//  Maze
//
public class Maze extends Sprite
{
  private var _cellsize:int;
  private var _width:int;
  private var _height:int;
  private var _cells:Array;

  public function Maze(width:int, height:int, cellsize:int=32)
  {
    _width = width;
    _height = height;
    _cellsize = cellsize;
    _cells = new Array(_height+1);
  }

  public function get cellsize():int
  {
    return _cellsize;
  }

  public function paint():void
  {
    graphics.clear();
    graphics.lineStyle(4, 0xffffff);

    for (var y:int = 0; y < _cells.length; y++) {
      var row:Array = _cells[y]
      for (var x:int = 0; x < row.length; x++) {
	var c:MazeCell = row[x];
	if (!c.open_left) {
	  graphics.moveTo(x*_cellsize, y*_cellsize);
	  graphics.lineTo(x*_cellsize, (y+1)*_cellsize);
	}
	if (!c.open_top) {
	  graphics.moveTo(x*_cellsize, y*_cellsize);
	  graphics.lineTo((x+1)*_cellsize, y*_cellsize);
	}
      }
    }
  }

  private var _stack:Array;

  public function build():void
  {
    var F:Array = [0,1,2,3];

    for (var y:int = 0; y < _cells.length; y++) {
      var row:Array = new Array(_width+1);
      for (var x:int = 0; x < row.length; x++) {
	var c:MazeCell = new MazeCell();
	if (x == _width) { c.open_top = true; }
	if (y == _height) { c.open_left = true; }
	row[x] = c;
      }
      _cells[y] = row;
    }

    _stack = new Array();
    _stack.push(new Point(0, 0));

    while (0 < _stack.length) {
      var i:int = Utils.rnd(_stack.length);
      var p:Point = _stack[i];
      _stack.splice(i, 1);
      Utils.shuffle(F);
      for each (var f:int in F) {
	switch (f) {
	case 0:
	  visit(p.x-1, p.y, p.x, p.y, false); // open left.
	  break;
	case 1:
	  visit(p.x+1, p.y, p.x+1, p.y, false); // open right.
	  break;
	case 2:
	  visit(p.x, p.y-1, p.x, p.y, true); // open top.
	  break;
	case 3:
	  visit(p.x, p.y+1, p.x, p.y+1, true); // open bottom.
	  break;
	}
      }
    }
  }

  private function visit(x1:int, y1:int, x0:int, y0:int, vertical:Boolean):void
  {
    if (x1 < 0 || y1 < 0 || _width <= x1 || _height <= y1) return;
    var c1:MazeCell = _cells[y1][x1];
    if (c1.visited) return;
    c1.visited = true;
    _stack.push(new Point(x1, y1));

    var c0:MazeCell = _cells[y0][x0];
    if (vertical) {
      c0.open_top = true;
    } else {
      c0.open_left = true;
    }
  }
}

} // package

// MazeCell
class MazeCell extends Object
{
  public var visited:Boolean;
  public var open_top:Boolean;
  public var open_left:Boolean;
}
