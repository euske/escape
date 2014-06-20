package {

import flash.display.Sprite;
import flash.geom.Rectangle;
import flash.geom.Point;

//  Maze
//
public class Maze extends Sprite
{
  private const WALL_WIDTH:uint = 4;
  private const WALL_COLOR:uint = 0x888888;

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
    for (var y:int = 0; y < _cells.length; y++) {
      var row:Array = new Array(_width+1);
      for (var x:int = 0; x < row.length; x++) {
	var cell:MazeCell = new MazeCell(x, y);
	if (x == _width) { cell.open_top = true; }
	if (y == _height) { cell.open_left = true; }
	row[x] = cell;
      }
      _cells[y] = row;
    }
  }

  public function get mazeWidth():int
  {
    return _width;
  }

  public function get mazeHeight():int
  {
    return _height;
  }

  public function get cellSize():int
  {
    return _cellsize;
  }

  public function clear():void
  {
    for (var y:int = 0; y < _height; y++) {
      var row:Array = _cells[y];
      for (var x:int = 0; x < _width; x++) {
	var cell:MazeCell = row[x];
	cell.open_top = false;
	cell.open_left = false;
	cell.item = 0;
      }
    }
  }

  // findPath(start, goal)
  public function findPath(x0:int, y0:int, x1:int, y1:int):void
  {
    var INF:int = _height*_width+1;
    for (var y:int = 0; y < _height; y++) {
      var row:Array = _cells[y];
      for (var x:int = 0; x < _width; x++) {
	var cell:MazeCell = row[x];
	cell.distance = INF;
      }
    }

    var queue:Array = [_cells[y1][x1]];
    queue[0].distance = 0;
    while (0 < queue.length) {
      var p:MazeCell = queue.pop();
      if (p.x == x0 && p.y == y0) break;
      var a:Array = new Array();
      if (0 < p.x && p.open_left) {
	a.push(_cells[p.y][p.x-1]);
      }
      if (p.x < _width-1 && _cells[p.y][p.x+1].open_left) {
	a.push(_cells[p.y][p.x+1]);
      }
      if (0 < p.y && p.open_top) {
	a.push(_cells[p.y-1][p.x]);
      }
      if (p.y < _height-1 && _cells[p.y+1][p.x].open_top) {
	a.push(_cells[p.y+1][p.x]);
      }
      var d:int = p.distance+1;
      for each (var q:MazeCell in a) {
	if (d < q.distance) {
	  q.distance = d;
	  q.parent = p;
	  queue.push(q);
	}
      }
      queue.sortOn("distance", Array.NUMERIC);
    }
  }

  public function buildFromArray(a:Array):void
  {
    for (var y:int = 0; y < a.length; y += 2) {
      var row1:String = a[y];
      var row2:String = a[y+1];
      for (var x:int = 0; x < row1.length; x += 2) {
	var cell:MazeCell = getCell(Math.floor(x/2), Math.floor(y/2));
	if (cell != null) {
	  cell.open_top = (row1.charAt(x+1) == " ");
	  cell.open_left = (row2.charAt(x) == " ");
	  cell.item = parseInt(row2.charAt(x+1));
	}
      }
    }
  }

  public function buildAuto():void
  {
    var F:Array = [0,1,2,3];
    var stack:Array = [new Point(0, 0)];

    while (0 < stack.length) {
      var i:int = Utils.rnd(stack.length);
      var p:Point = stack[i];
      stack.splice(i, 1);
      Utils.shuffle(F);
      for each (var f:int in F) {
	switch (f) {
	case 0:
	  visit(stack, p.x-1, p.y, p.x, p.y, false); // open left.
	  break;
	case 1:
	  visit(stack, p.x+1, p.y, p.x+1, p.y, false); // open right.
	  break;
	case 2:
	  visit(stack, p.x, p.y-1, p.x, p.y, true); // open top.
	  break;
	case 3:
	  visit(stack, p.x, p.y+1, p.x, p.y+1, true); // open bottom.
	  break;
	}
      }
    }
  }

  private function visit(stack:Array, x1:int, y1:int, x0:int, y0:int, 
			 vertical:Boolean):void
  {
    var cell:MazeCell = getCell(x1, y1);
    if (cell == null || cell.visited) return;
    cell.visited = true;
    stack.push(new Point(x1, y1));

    var c0:MazeCell = _cells[y0][x0];
    if (vertical) {
      c0.open_top = true;
    } else {
      c0.open_left = true;
    }
  }

  public function getCell(x:int, y:int):MazeCell
  {
    if (x < 0 || y < 0 || _width <= x || _height <= y) return null;
    return _cells[y][x];
  }

  public function isOpen(x:int, y:int, dx:int, dy:int):Boolean
  {
    if (x+dx < 0 || y+dy < 0 ||	_width <= x+dx || _height <= y+dy) return false;
    if (dx < 0 && dy == 0) {
      return _cells[y][x].open_left;
    } else if (0 < dx && dy == 0) {
      return _cells[y][x+1].open_left;
    } else if (dx == 0 && dy < 0) {
      return _cells[y][x].open_top;
    } else if (dx == 0 && 0 < dy) {
      return _cells[y+1][x].open_top;
    }
    return false;
  }

  public function paint():void
  {
    graphics.clear();
    graphics.lineStyle(WALL_WIDTH, WALL_COLOR);

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
}

} // package