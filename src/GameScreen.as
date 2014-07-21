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
import baseui.SoundGenerator;

//  GameScreen
//
public class GameScreen extends Screen
{
  private const SHORT_FLASH:int = 10;
  private const FLASH_COLOR:uint = 0x0044ff;

  private const UNINITED:String = "UNINITED";
  private const INITED:String = "INITED";
  private const STARTED:String = "STARTED";
  private const GOALED:String = "GOALED";

  private var _title:Guide;
  private var _guide:Guide;
  private var _keypad:Keypad;
  private var _status:Status;
  private var _soundman:SoundPlayer;

  private var _state:String;
  private var _tutorial:int;
  private var _ticks:int;
  private var _t0:int;

  private var _maze:Maze;
  private var _shadow:Shadow;
  private var _player:Player;
  private var _playermoved:Boolean;

  private var beepSound:SoundGenerator;
  private var stepSound:SoundGenerator;
  private var bumpSound:SoundGenerator;
  private var pickupSound:SoundGenerator;
  private var doomAlarmSound:SoundGenerator;

  public function GameScreen(width:int, height:int, shared:Object)
  {
    super(width, height, shared);

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

    _title = new Guide(width/2, height/8);
    _title.x = (width-_title.width)/2;
    _title.y = _maze.y-_title.height-16;
    addChild(_title);

    _guide = new Guide(width/2, height/6);
    _guide.x = (width-_guide.width)/2;
    _guide.y = _status.y-_guide.height-16;
    addChild(_guide);

    _soundman = new SoundPlayer();

    addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);

    if (beepSound == null) {
      beepSound = new SoundGenerator();
      beepSound.tone = SoundGenerator.ConstSineTone(440);
      beepSound.envelope = SoundGenerator.DecayEnvelope(0.01, 0.1);
    }
    if (stepSound == null) {
      stepSound = new SoundGenerator();
      stepSound.tone = SoundGenerator.ConstSawTone(100);
      stepSound.envelope = SoundGenerator.DecayEnvelope(0.01, 0.1);
    }
    if (bumpSound == null) {
      bumpSound = new SoundGenerator();
      bumpSound.tone = SoundGenerator.ConstNoise(300);
      bumpSound.envelope = SoundGenerator.DecayEnvelope(0.01, 0.1);
    }
    if (pickupSound == null) {
      var func:Function = (function (t:Number):Number { return (t<0.05)? 660 : 800; });
      pickupSound = new SoundGenerator();
      pickupSound.tone = SoundGenerator.RectTone(func);
      pickupSound.envelope = SoundGenerator.DecayEnvelope(0.01, 0.3);
    }
    if (doomAlarmSound == null) {
      doomAlarmSound = new SoundGenerator();
      doomAlarmSound.tone = SoundGenerator.ConstSineTone(880);
      doomAlarmSound.envelope = SoundGenerator.DecayEnvelope(0.0, 0.3, 0.1, 2);
    }
  }

  // open()
  public override function open():void
  {
    _tutorial = 0;
    _ticks = 0;
    _soundman.isPlaying = true;

    _state = UNINITED;
    _title.show("ESCAPE THE CAVE");
    _guide.show("PRESS Z KEY.");

    initGame();
  }

  // close()
  public override function close():void
  {
    _soundman.isPlaying = false;
  }

  // pause()
  public override function pause():void
  {
    _soundman.isPlaying = false;
  }

  // resume()
  public override function resume():void
  {
    _soundman.isPlaying = true;
  }

  // update()
  public override function update():void
  {
    _guide.update();
    _keypad.update();

    var rect:Rectangle = _player.rect;
    _shadow.x = _maze.x+rect.x+(rect.width-_shadow.width)/2;
    _shadow.y = _maze.y+rect.y+(rect.height-_shadow.height)/2;

    if (_state == STARTED) {
      _maze.update(_ticks);
      _player.update(_ticks);
      
      _maze.detectCollision(_player);
      
      if (_t0 != 0) {
	var t:int = Math.floor((_t0-getTimer()+999)/1000);
	if (_status.time != t) {
	  _status.time = t;
	  _status.update();
	  switch (t) {
	  case 30:
	  case 20:
	  case 10:
	    doomAlarmSound.play();
	    break;
	  }
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

    initLevel();
  }

  // initLevel()
  private function initLevel():void
  {
    trace("initLevel");
    _status.miss = 0;
    _status.time = 60;
    _status.update();

    _maze.clear();
    _maze.buildFromArray(Levels.getLevel(_status.level));
    _maze.findPath(0, _maze.mazeHeight-1, _maze.mazeWidth-1, 0);
    _maze.paint();

    _player.visible = false;
    _player.pos = new Point(0, 3);

    _state = INITED;
  }

  // startGame()
  private function startGame():void
  {
    trace("startGame");
    // start the timer.
    _t0 = getTimer()+_status.time*1000;

    _player.visible = true;
    playSound(stepSound, 0);

    _state = STARTED;
  }

  // gameOver()
  private function gameOver():void
  {
    trace("gameOver");
    _title.show("GAME OVER");
    _guide.show("PRESS KEY TO PLAY AGAIN.");

    _state = UNINITED;
  }

  // nextLevel()
  private function nextLevel():void
  {
    trace("nextLevel");
    _status.level++;
    if (_status.level < Levels.LEVELS.length) {
      initLevel();
    } else {
      // Game beaten.
      _state = GOALED;
      _title.show("CONGRATURATIONS!");
      _guide.show("PRESS KEY TO PLAY AGAIN.");
    }
  }

  // keydown(keycode)
  public override function keydown(keycode:int):void
  {
    _title.hide();
    _guide.hide();
    if (_state == UNINITED) {
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

    case Keyboard.SPACE:
      //_soundman.addSound(new SoundGenerator().setSawTone(function (t:Number):Number { return 400-(1000*t)+20*Math.sin(t*100); }).setCutoffEnvelope(0.3));
      break;
    }
  }

  // onMouseDown
  private function onMouseDown(e:MouseEvent):void
  {
    _title.hide();
    _guide.hide();
    if (_state == UNINITED) {
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
    if (_state != STARTED) {
      if (dx != 0 || dy != 0) return;
    }
    movePlayer(dx, dy);
  }

  // movePlayer(dx, dy)
  private function movePlayer(dx:int, dy:int):void
  {
    if (_state != STARTED) {
      startGame();
      return;
    }
    var d:int = Math.abs(dx)+Math.abs(dy);
    if (d == 1) {
      if (_maze.isOpen(_player.pos.x, _player.pos.y, dx, dy)) {
	_player.move(dx, dy);
	playSound(stepSound, dx);
      } else {
	playSound(bumpSound, dx);
      }
    } else if (2 <= d) {
      playSound(beepSound, dx);
    }

    if (_maze.isGoal(_player.pos.x, _player.pos.y)) {
      nextLevel();
    }
  }

  // playSound
  private function playSound(sound:Sound, dx:int):void
  {
    sound.play(0, 0, new SoundTransform(1, dx));
  }

  // onActorCollided
  private function onActorCollided(e:ActorEvent):void
  {
    var actor:Actor = e.actor;
    playSound(pickupSound, 0);
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
  private var _text:Bitmap;
  private var _sound:Sound;
  private var _channel:SoundChannel;
  private var _count:int;

  public function Guide(width:int, height:int, alpha:Number=0.2)
  {
    graphics.beginFill(0, alpha);
    graphics.drawRect(0, 0, width, height);
    graphics.endFill();
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
      _text.y = (height-_text.height)/2;
      addChild(_text);
    }
  }

  public function show(text:String=null, 
		       sound:Sound=null, delay:int=30):void
  {
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
