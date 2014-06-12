package {

import flash.media.Sound;
import flash.media.SoundTransform;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.events.MouseEvent;
import flash.ui.Keyboard;
import baseui.Screen;
import baseui.ScreenEvent;

//  GameScreen
//
public class GameScreen extends Screen
{
  private const SHORT_FLASH:int = 10;
  private const PLAYER_COLOR:uint = 0xff0000;

  private var _status:Status;
  private var _guide:Guide;
  private var _keypad:Keypad;

  private var _initialized:Boolean;
  private var _tutorial:int;

  private var _start:int;
  private var _ticks:int;

  private var _maze:Maze;

  public function GameScreen(width:int, height:int)
  {
    super(width, height);

    _status = new Status();
    _status.x = (width-_status.width)/2;
    _status.y = (height-_status.height-16);
    addChild(_status);

    _keypad = new Keypad();
    _keypad.addEventListener(KeypadEvent.PRESSED, onKeypadPressed);
    _keypad.layoutFull();
    _keypad.x = (width-_keypad.rect.width)/2;
    _keypad.y = (height-_keypad.rect.height)/2;
    addChild(_keypad);

    _guide = new Guide(width*3/4, height/2);
    _guide.x = (width-_guide.width)/2;
    _guide.y = (height-_guide.height)/2;
    addChild(_guide);

    addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
  }

  // open()
  public override function open():void
  {
    _ticks = 0;
    _start = 0;

    _initialized = false;
    _tutorial = 0;
    _guide.show("ESCAPE THE CAVE", 
		"PRESS Z KEY.");

    _maze = new Maze(_keypad.cols, _keypad.rows);
    _maze.x = _keypad.x;
    _maze.y = _keypad.y;
    _maze.paint();
    addChild(_maze);
  }

  // close()
  public override function close():void
  {
  }

  // pause()
  public override function pause():void
  {
  }

  // resume()
  public override function resume():void
  {
  }

  // update()
  public override function update():void
  {
    _guide.update();
    _keypad.update();
    _ticks++;
  }

  // keydown(keycode)
  public override function keydown(keycode:int):void
  {
    _guide.hide();
    if (!_initialized) {
      init();
      return;
    }
    _keypad.keydown(keycode);
  }

  // mouseDown
  private function onMouseDown(e:MouseEvent):void
  {
    _guide.hide();
    if (!_initialized) {
      init();
      return;
    }
    var p:Point = new Point(e.stageX, e.stageY);
    _keypad.mousedown(_keypad.globalToLocal(p));
  }

  private function onKeypadPressed(e:KeypadEvent):void
  {
    var keypad:Keypad = Keypad(e.target);
    var key:Keytop = e.key;
    var i:int = key.pos.x;
    key.flash(PLAYER_COLOR, SHORT_FLASH);
    //_keypad.makeParticle(key.rect, PLAYER_COLOR, SHORT_FLASH);
  }

  private function setDelay(delay:int):void
  {
    _start = Math.max(_start, _ticks+delay);
  }

  private function init():void
  {
    trace("init");
    _status.level = 0;
    _status.score = 0;
    _status.update();
    _initialized = true;
  }

  private function gameOver():void
  {
    trace("gameOver");
    _guide.show("GAME OVER", 
		"PRESS KEY TO PLAY AGAIN.");
    _initialized = false;
  }
}

} // package

import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import baseui.Font;


//  Status
// 
class Status extends Sprite
{
  public var level:int;
  public var score:int;
  public var miss:int;

  private var _text:Bitmap;

  public function Status()
  {
    _text = Font.createText("LEVEL: 00   SCORE: 00   MISS: 00", 0xffffff, 0, 2);
    addChild(_text);
  }

  public function update():void
  {
    var text:String = "LEVEL: "+Utils.format(level,2);
    text += "   SCORE: "+Utils.format(score,2);
    text += "   MISS: "+Utils.format(miss,2);
    Font.renderText(_text.bitmapData, text);
  }
}


//  Guide
// 
class Guide extends Sprite
{
  public const MARGIN:int = 16;

  private var _title:Bitmap;
  private var _text:Bitmap;
  private var _sound:Sound;
  private var _channel:SoundChannel;
  private var _count:int;

  public function Guide(width:int, height:int)
  {
    graphics.beginFill(0, 0.2);
    graphics.drawRect(0, 0, width, height);
  }

  public function set title(v:String):void
  {
    if (_title != null) {
      removeChild(_title);
      _title = null;
    }
    if (v != null) {
      _title = Font.createText(v, 0xffffff, 0, 2);
      _title.x = (width-_title.width)/2;
      _title.y = MARGIN;
      addChild(_title);
    }
  }

  public function set text(v:String):void
  {
    if (_text != null) {
      removeChild(_text);
      _text = null;
    }
    if (v != null) {
      _text = Font.createText(v, 0xffffff, 2, 2);
      _text.x = (width-_text.width)/2;
      _text.y = (height-_text.height-MARGIN);
      addChild(_text);
    }
  }

  public function show(title:String=null, text:String=null, 
		       sound:Sound=null, delay:int=30):void
  {
    this.title = title;
    this.text = text;
    _sound = sound;
    _count = delay;
    visible = true;
  }

  public function hide():void
  {
    if (_channel != null) {
      _channel.stop();
      _channel = null;
    }
    visible = false;
  }

  public function update():void
  {
    if (_count != 0) {
      _count--;
    } else {
      if (_sound != null) {
	_channel = _sound.play();
	_sound = null;
      }
    }
  }
}


//  Maze
class Maze extends Sprite
{
  public const CELL_SIZE:int = 32;
  
  public function Maze(width:int, height:int)
  {
    _width = width;
    _height = height;

    _cells = new Array(_height);
    for (var y:int = 0; y < _height; y++) {
      var row:Array = new Array(_width);
      for (var x:int = 0; x < _width; x++) {
	row[x] = new MazeCell();
      }
      _cells[y] = row;
    }

    _stack = new Array();
    _stack.push(new Point(0, 0));

    build();
  }

  public function paint():void
  {
    graphics.clear();
    graphics.lineStyle(1, 0xffffff);
    for (var y:int = 0; y < _height; y++) {
      var row:Array = _cells[y]
      for (var x:int = 0; x < _width; x++) {
	var c:MazeCell = row[x];
	if ((c.open & MazeCell.LEFT) == 0) {
	  graphics.moveTo(x*CELL_SIZE, y*CELL_SIZE);
	  graphics.lineTo(x*CELL_SIZE, (y+1)*CELL_SIZE);
	}
	if ((c.open & MazeCell.TOP) == 0) {
	  graphics.moveTo(x*CELL_SIZE, y*CELL_SIZE);
	  graphics.lineTo((x+1)*CELL_SIZE, y*CELL_SIZE);
	}
      }
    }
  }

  private var _width:int;
  private var _height:int;
  private var _stack:Array;
  private var _cells:Array;

  private function build():void
  {
    var F:Array = [0,1,2,3];
    while (0 < _stack.length) {
      var p:Point = _stack.pop();
      Utils.shuffle(F);
      for each (var f:int in F) {
	switch (f) {
	case 0:
	  visit(p, p.x-1, p.y, f); // open left.
	  break;
	case 1:
	  visit(p, p.x+1, p.y, f); // open right.
	  break;
	case 2:
	  visit(p, p.x, p.y-1, f); // open top.
	  break;
	case 3:
	  visit(p, p.x, p.y+1, f); // open bottom.
	  break;
	}
      }
    }
  }

  private function visit(p:Point, x:int, y:int, f:int):void
  {
    if (x < 0 || y < 0 || _width <= x || _height <= y) return;
    var c0:MazeCell = _cells[p.y][p.x];
    var c1:MazeCell = _cells[y][x];
    if (c1.visited) return;
    c1.visited = true;
    switch (f) {
    case 0:
      c0.open |= MazeCell.RIGHT;
      c1.open |= MazeCell.LEFT;
      break;
    case 1:
      c0.open |= MazeCell.LEFT;
      c1.open |= MazeCell.RIGHT;
      break;
    case 2:
      c0.open |= MazeCell.BOTTOM;
      c1.open |= MazeCell.TOP;
      break;
    case 3:
      c0.open |= MazeCell.TOP;
      c1.open |= MazeCell.BOTTOM;
      break;
    }
    _stack.push(new Point(x, y));
  }

}

class MazeCell extends Object
{
  public static const LEFT:int = 1;
  public static const RIGHT:int = 2;
  public static const TOP:int = 4;
  public static const BOTTOM:int = 8;

  public var visited:Boolean;
  public var open:int;
}
