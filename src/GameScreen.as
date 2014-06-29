package {

import flash.media.Sound;
import flash.media.SoundTransform;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.events.MouseEvent;
import flash.ui.Keyboard;
import flash.utils.getTimer;
import baseui.Screen;
import baseui.ScreenEvent;

//  GameScreen
//
public class GameScreen extends Screen
{
  private const SHORT_FLASH:int = 10;
  private const FLASH_COLOR:uint = 0x0044ff;

  private var _guide:Guide;
  private var _keypad:Keypad;
  private var _status:Status;

  private var _state:int;
  private var _tutorial:int;
  private var _ticks:int;
  private var _t0:int;

  private var _maze:Maze;
  private var _shadow:Shadow;
  private var _player:Player;
  private var _playermoved:Boolean;

  private var stepSound:Sound;
  private var bumpSound:Sound;

  [Embed(source="../assets/sounds/beep.mp3")]
  private static const PickupSoundCls:Class;
  private static const pickupSound:Sound = new PickupSoundCls();

  public function GameScreen(width:int, height:int)
  {
    super(width, height);

    _keypad = new Keypad();
    _keypad.addEventListener(KeypadEvent.PRESSED, onKeypadPressed);
    _keypad.layoutFull(48, 48, 8);
    _keypad.x = (width-_keypad.rect.width)/2;
    _keypad.y = (height-_keypad.rect.height)/2;
    addChild(_keypad);

    _maze = new Maze(_keypad.cols, _keypad.rows, 48+8);
    _maze.addEventListener(ActorEvent.COLLIDED, onActorCollided);
    _maze.x = _keypad.x-4;
    _maze.y = _keypad.y-4;
    addChild(_maze);

    _shadow = new Shadow(48);
    addChild(_shadow);

    _player = new Player(_maze);
    _player.visible = false;
    _maze.addChild(_player);

    _status = new Status();
    _status.x = (width-_status.width)/2;
    _status.y = (height-_status.height-16);
    addChild(_status);

    _guide = new Guide(width*3/4, height/2);
    _guide.x = (width-_guide.width)/2;
    _guide.y = (height-_guide.height)/2;
    addChild(_guide);

    addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);

    stepSound = SoundGenerator.createSine(45, 0.01, 0.03);
    bumpSound = SoundGenerator.createNoise(300, 0.01, 0.1);
  }

  // open()
  public override function open():void
  {
    _state = 0;
    _tutorial = 0;
    _ticks = 0;

    _guide.show("ESCAPE THE CAVE", 
		"PRESS Z KEY.");

    initGame();
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

    var rect:Rectangle = _player.rect;
    _shadow.x = _maze.x+rect.x+(rect.width-_shadow.width)/2;
    _shadow.y = _maze.y+rect.y+(rect.height-_shadow.height)/2;

    if (_state == 2) {
      _maze.update(_ticks);
      _player.update(_ticks);
      
      _maze.detectCollision(_player);
      
      if (_t0 != 0) {
	var t:int = Math.floor((_t0-getTimer()+999)/1000);
	if (_status.time != t) {
	  _status.time = t;
	  _status.update();
	}
      }
    }
    _ticks++;
  }

  // initGame()
  private function initGame():void
  {
    trace("initGame");
    _status.level = 0;
    _status.miss = 0;
    _status.time = 60;
    _status.update();

    _maze.clear();
    _maze.buildFromArray(["+-+-+-+-+-+-+-+-+-+-+",
			  "|         |     |  1|",
			  "+-+-+-+-+-+ +-+-+-+ +",
			  "|      4    |     | |",
			  "+ +-+-+-+-+ +-+ + + +",
			  "| |       |2  |   | |",
			  "+ +-+-+-+-+-+ +-+-+ +",
			  "|           |       |",
			  "+-+-+-+-+-+-+-+-+-+-+"]);
    _maze.findPath(0, _maze.mazeHeight-1, _maze.mazeWidth-1, 0);
    _maze.paint();

    _player.visible = false;
    _player.pos = new Point(0, 3);

    _state = 1;
  }

  // startGame()
  private function startGame():void
  {
    // start the timer.
    _t0 = getTimer()+_status.time*1000;

    _player.visible = true;
    playSound(stepSound);

    _state = 2;
  }

  // gameOver()
  private function gameOver():void
  {
    trace("gameOver");
    _guide.show("GAME OVER", 
		"PRESS KEY TO PLAY AGAIN.");
    _state = 0;
  }

  // keydown(keycode)
  public override function keydown(keycode:int):void
  {
    _guide.hide();
    if (_state == 0) {
      initGame();
      return;
    }
    _keypad.keydown(keycode);

    switch (keycode) {
    case Keyboard.F1:		// Cheat
      _shadow.visible = !_shadow.visible;
      break;

    case Keyboard.LEFT:
      movePlayer(-1, 0);
      break;

    case Keyboard.RIGHT:
      movePlayer(+1, 0);
      break;

    case Keyboard.UP:
      movePlayer(0, -1);
      break;

    case Keyboard.DOWN:
      movePlayer(0, +1);
      break;
    }
  }

  // onMouseDown
  private function onMouseDown(e:MouseEvent):void
  {
    _guide.hide();
    if (_state == 0) {
      initGame();
      return;
    }
    var p:Point = new Point(e.stageX, e.stageY);
    _keypad.mousedown(_keypad.globalToLocal(p));
  }

  // onKeypadPressed
  private function onKeypadPressed(e:KeypadEvent):void
  {
    var keypad:Keypad = Keypad(e.target);
    var key:Keytop = e.key;
    var i:int = key.pos.x;
    key.flash(FLASH_COLOR, SHORT_FLASH);
    //_keypad.makeParticle(key.rect, FLASH_COLOR, SHORT_FLASH);

    var dx:int = key.pos.x - _player.pos.x;
    var dy:int = key.pos.y - _player.pos.y;
    if (_state == 1) {
      if (dx != 0 || dy != 0) return;
    }
    movePlayer(dx, dy);
  }

  private function playSound(sound:Sound):void
  {
    var pan:Number = _keypad.getPan(_player.pos.x);
    sound.play(0, 0, new SoundTransform(1, pan));
  }

  private function movePlayer(dx:int, dy:int):void
  {
    if (_state == 1) {
      startGame();
      return;
    }
    if ((Math.abs(dx) == 1 && dy == 0) ||
	(dx == 0 && Math.abs(dy) == 1)) {
      if (_maze.isOpen(_player.pos.x, _player.pos.y, dx, dy)) {
	_player.move(dx, dy);
	playSound(stepSound);
      } else {
	playSound(bumpSound);
      }
    }
  }
  
  private function onActorCollided(e:ActorEvent):void
  {
    var actor:Actor = e.actor;
    playSound(pickupSound);
    _maze.removeActor(actor);
  }
}

} // package

import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.media.Sound;
import flash.media.SoundChannel;
import baseui.Font;


//  Status
// 
class Status extends Sprite
{
  public var level:int;
  public var miss:int;
  public var time:int;

  private var _text:Bitmap;

  public function Status()
  {
    _text = Font.createText("LEVEL: 00   MISS: 00   TIME: 00", 0xffffff, 0, 2);
    addChild(_text);
  }

  public function update():void
  {
    var text:String = "LEVEL: "+Utils.format(level,2);
    text += "   MISS: "+Utils.format(miss,2);
    text += "   TIME: "+Utils.format(time,2);
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
    graphics.endFill();
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


//  Shadow
//
class Shadow extends Shape
{
  public function Shadow(size:int)
  {
    graphics.beginFill(0, 1.0);
    graphics.drawRect(0, 0, size*24, size*24);
    graphics.drawRect(size*10, size*10, size*4, size*4);
    graphics.endFill();
    graphics.beginFill(0, 0.7);
    graphics.drawRect(size*10, size*10, size*4, size*4);
    graphics.drawRect(size*11, size*11, size*2, size*2);
    graphics.endFill();
  }
}
