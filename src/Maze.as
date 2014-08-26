package {

import flash.display.Sprite;
import flash.geom.Rectangle;
import flash.geom.Point;

//  Maze
//
public class Maze extends Sprite
{
  private const WALL_WIDTH:uint = 4;
  private const WALL_COLOR:uint = 0xcccccc;
  private const START_WIDTH:uint = 6;
  private const START_COLOR:uint = 0x444400;
  private const GOAL_WIDTH:uint = 6;
  private const GOAL_COLOR:uint = 0xcccc00;

  private var _cellsize:int;
  private var _width:int;
  private var _height:int;
  private var _cells:Vector.<Vector.<MazeCell>>;
  private var _actors:Vector.<Actor>;

  public function Maze(width:int, height:int, cellsize:int=32)
  {
    _width = width;
    _height = height;
    _cellsize = cellsize;

    _cells = new Vector.<Vector.<MazeCell>>(_height+1);
    for (var y:int = 0; y < _cells.length; y++) {
      var row:Vector.<MazeCell> = new Vector.<MazeCell>(_width+1);
      for (var x:int = 0; x < row.length; x++) {
	var cell:MazeCell = new MazeCell();
	if (x == _width) { cell.open_top = true; }
	if (y == _height) { cell.open_left = true; }
	row[x] = cell;
      }
      _cells[y] = row;
    }

    _actors = new Vector.<Actor>();
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

  public function stopSound():void
  {
    for each (var actor:Actor in _actors) {
      actor.stopSound();
    }
  }

  public function clear():void
  {
    while (0 < _actors.length) {
      removeActor(_actors[0]);
    }

    for (var y:int = 0; y < _height; y++) {
      var row:Vector.<MazeCell> = _cells[y];
      for (var x:int = 0; x < _width; x++) {
	var cell:MazeCell = row[x];
	cell.open_top = false;
	cell.open_left = false;
	cell.item = 0;
      }
    }
  }

  // findPath(start, goal)
  public function findPath(dist:Vector.<Vector.<int>>,
			   x0:int, y0:int, x1:int, y1:int):Vector.<Point>
  {
    var pt:MeshPoint;
    var INF:int = _height*_width+1;

    var mesh:Vector.<Vector.<MeshPoint>> = new Vector.<Vector.<MeshPoint>>(_height);
    for (var y:int = 0; y < _height; y++) {
      var row:Vector.<MeshPoint> = new Vector.<MeshPoint>(_width);
      for (var x:int = 0; x < _width; x++) {
	pt = new MeshPoint(x, y);
	pt.parent = null;
	pt.distance = INF;
	row[x] = pt;
      }
      mesh[y] = row;
    }

    pt = mesh[y1][x1];
    pt.parent = null;
    pt.distance = 0;
    var queue:Array = [pt];
    while (0 < queue.length) {
      pt = queue.pop();
      if (pt.x == x0 && pt.y == y0) break;
      var a:Array = new Array();
      if (0 < pt.x && _cells[pt.y][pt.x].open_left) {
	a.push(mesh[pt.y][pt.x-1]);
      }
      if (pt.x < _width-1 && _cells[pt.y][pt.x+1].open_left) {
	a.push(mesh[pt.y][pt.x+1]);
      }
      if (0 < pt.y && _cells[pt.y][pt.x].open_top) {
	a.push(mesh[pt.y-1][pt.x]);
      }
      if (pt.y < _height-1 && _cells[pt.y+1][pt.x].open_top) {
	a.push(mesh[pt.y+1][pt.x]);
      }
      var d:int = pt.distance+1;
      for each (var q:MeshPoint in a) {
	if (d < q.distance) {
	  q.distance = d;
	  q.parent = pt;
	  queue.push(q);
	}
      }
      queue.sortOn("distance", Array.NUMERIC);
    }

    if (dist != null) {
      for (y = 0; y < _height; y++) {
	dist[y] = new Vector.<int>(_width);
	for (x = 0; x < _width; x++) {
	  dist[y][x] = mesh[y][x].distance;
	}
      }
    }

    var path:Vector.<Point> = new Vector.<Point>();
    while (pt != null) {
      path.push(new Point(pt.x, pt.y));
      pt = pt.parent;
    }
    return path;
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

    placeActors();
  }

  public function buildAuto():void
  {
    var F:Array = [0,1,2,3];
    var stack:Vector.<Point>;
    var visited:Vector.<Vector.<Boolean>> = new Vector.<Vector.<Boolean>>(_height);
    for (var y:int = 0; y < _height; y++) {
      var row:Vector.<Boolean> = new Vector.<Boolean>(_width);
      for (var x:int = 0; x < _width; x++) {
	row[x] = false;
      }
      visited[y] = row;
    }

    stack.push(new Point(0, 0));
    while (0 < stack.length) {
      var i:int = Utils.rnd(stack.length);
      var p:Point = stack[i];
      stack.splice(i, 1);
      Utils.shuffle(F);
      for each (var f:int in F) {
	switch (f) {
	case 0:
	  visit(visited, stack, p.x-1, p.y, p.x, p.y, false); // open left.
	  break;
	case 1:
	  visit(visited, stack, p.x+1, p.y, p.x+1, p.y, false); // open right.
	  break;
	case 2:
	  visit(visited, stack, p.x, p.y-1, p.x, p.y, true); // open top.
	  break;
	case 3:
	  visit(visited, stack, p.x, p.y+1, p.x, p.y+1, true); // open bottom.
	  break;
	}
      }
    }

    placeActors();
  }

  private function visit(visited:Vector.<Vector.<Boolean>>, 
			 stack:Vector.<Point>, 
			 x1:int, y1:int, x0:int, y0:int, 
			 vertical:Boolean):void
  {
    if (x1 < 0 || y1 < 0 ||
	_width <= x1 || _height <= y1 ||
	visited[y1][x1]) return;
    visited[y1][x1] = true;
    stack.push(new Point(x1, y1));

    var c0:MazeCell = _cells[y0][x0];
    if (vertical) {
      c0.open_top = true;
    } else {
      c0.open_left = true;
    }
  }

  private function placeActors():void
  {
    for (var y:int = 0; y < _cells.length; y++) {
      var row:Vector.<MazeCell> = _cells[y]
      for (var x:int = 0; x < row.length; x++) {
	var cell:MazeCell = row[x];
	var actor:Actor = null;
	switch (cell.item) {
	case MazeCell.ITEM_KEY:
	case MazeCell.ITEM_HEALTH:
	case MazeCell.ITEM_BOMB:
	case MazeCell.ITEM_COMPASS:
	  actor = new ActorItem(this, cell.item);
	  break;
	case MazeCell.TRAP:
	  actor = new ActorTrap(this);
	  break;
	case MazeCell.ENEMY:
	  actor = new ActorEnemy(this);
	  break;
	}
	if (actor != null) {
	  addActor(actor, x, y);
	}
      }
    }
  }

  public function getCell(x:int, y:int):MazeCell
  {
    if (x < 0 || y < 0 || _width <= x || _height <= y) return null;
    return _cells[y][x];
  }

  public function getCellRect(x:int, y:int):Rectangle
  {
    return new Rectangle(x*_cellsize, y*_cellsize, _cellsize, _cellsize);
  }

  public function findCell(f:Function):Point
  {
    for (var y:int = 0; y < _cells.length; y++) {
      var row:Vector.<MazeCell> = _cells[y]
      for (var x:int = 0; x < row.length; x++) {
	var cell:MazeCell = row[x];
	if (f(cell)) return new Point(x, y);
      }
    }
    return null;
  }

  public function isGoal(x:int, y:int):Boolean
  {
    var cell:MazeCell = getCell(x, y);
    return (cell != null && cell.item == MazeCell.GOAL);
  }

  public function isOpen(x:int, y:int, dx:int, dy:int):Boolean
  {
    if (x+dx < 0 || y+dy < 0 ||	_width <= x+dx || _height <= y+dy) return false;
    if (dx == 0 && dy == 0) {
      return true;
    } else if (dx < 0 && dy == 0) {
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

    for (var y:int = 0; y < _cells.length; y++) {
      var row:Vector.<MazeCell> = _cells[y];
      for (var x:int = 0; x < row.length; x++) {
	var cell:MazeCell = row[x];
	if (!cell.open_left) {
	  graphics.lineStyle(WALL_WIDTH, WALL_COLOR);
	  graphics.moveTo(x*_cellsize, y*_cellsize);
	  graphics.lineTo(x*_cellsize, (y+1)*_cellsize);
	}
	if (!cell.open_top) {
	  graphics.lineStyle(WALL_WIDTH, WALL_COLOR);
	  graphics.moveTo(x*_cellsize, y*_cellsize);
	  graphics.lineTo((x+1)*_cellsize, y*_cellsize);
	}
	switch (cell.item) {
	case MazeCell.START:
	  graphics.lineStyle(START_WIDTH, START_COLOR);
	  graphics.drawRect(x*_cellsize+_cellsize/4, 
			    y*_cellsize+_cellsize/4, 
			    _cellsize/2, _cellsize/2);
	  break;
	case MazeCell.GOAL:
	  graphics.lineStyle(GOAL_WIDTH, GOAL_COLOR);
	  graphics.drawRect(x*_cellsize+_cellsize/4, 
			    y*_cellsize+_cellsize/4, 
			    _cellsize/2, _cellsize/2);
	  break;
	}
      }
    }
  }

  public function update(t:int):void
  {
    var bombs:Vector.<ActorBomb> = new Vector.<ActorBomb>();
    var enemies:Vector.<ActorEnemy> = new Vector.<ActorEnemy>();
    for each (var actor:Actor in _actors) {
      actor.update(t);
      if (actor is ActorBomb) {
	bombs.push(actor);
      } else if (actor is ActorEnemy) {
	enemies.push(actor);
      }
    }
    for each (var bomb:ActorBomb in bombs) {
      for each (var enemy:ActorEnemy in enemies) {
	if (bomb.rect.intersects(enemy.rect)) {
	  removeActor(bomb);
	  dispatchEvent(new ActorEvent(ActorEvent.EXPLODED, enemy));
	}
      }
    }
  }

  public function makeNoises(rect:Rectangle):void
  {
    for each (var actor:Actor in _actors) {
      var dx:int = ((actor.rect.x+actor.rect.width/2)-
		    (rect.x+rect.width/2));
      var dy:int = ((actor.rect.y+actor.rect.height/2)-
		    (rect.y+rect.height/2));
      actor.makeNoise(dx/_cellsize, dy/_cellsize);
    }
  }
  
  public function detectCollision(rect:Rectangle):void
  {
    for each (var actor:Actor in _actors) {
      if (actor.rect.intersects(rect)) {
	dispatchEvent(new ActorEvent(ActorEvent.COLLIDED, actor));
      }
    }
  }

  public function placeBomb(x:int, y:int):void
  {
    addActor(new ActorBomb(this), x, y);
  }

  public function addActor(actor:Actor, x:int, y:int):void
  {
    actor.x = x*_cellsize;
    actor.y = y*_cellsize;
    _actors.push(actor);
    addChild(actor);
  }
  
  public function removeActor(actor:Actor):void
  {
    actor.stopSound();
    var i:int = _actors.indexOf(actor);
    _actors.splice(i, 1);
    removeChild(actor);
  }
}

} // package

class MeshPoint extends Object
{
  public var x:int, y:int;
  public var visited:Boolean;
  public var parent:MeshPoint;
  public var distance:int;
  public var shortest:Boolean;

  public function MeshPoint(x:int, y:int)
  {
    this.x = x;
    this.y = y;
  }
}
