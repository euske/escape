package {

import flash.media.Sound;
import flash.media.SoundTransform;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.ui.Keyboard;
import flash.utils.getTimer;
import baseui.Screen;
import baseui.ScreenEvent;
import baseui.SoundPlayer;
import baseui.PlayListItem;

//  GameScreen
//
public class GameScreen extends Screen
{
  private const CELL_SIZE:int = 48;
  private const CELL_MARGIN:int = 8;
  private const SHORT_FLASH:int = 10;
  private const FLASH_COLOR:uint = 0x0044ff;
  private const PLAYER_HEALTH:int = 3;
  private const M_SHIFT:uint = 1;

  private const UNINITED:String = "UNINITED";
  private const INITED:String = "INITED";
  private const STARTED:String = "STARTED";
  private const GOALED:String = "GOALED";
  private const FINISHED:String = "FINISHED";

  private var _shared:SharedInfo;
  private var _title:Guide;
  private var _guide:SoundGuide;
  private var _keypad:Keypad;
  private var _status:Status;
  private var _soundman:SoundPlayer;

  private var _state:String;
  private var _tutorial:int;
  private var _ticks:int;
  private var _tleft:int;
  private var _t0:int;

  private var _maze:Maze;
  private var _shadow:Shadow;
  private var _player:Player;
  private var _compass:Vector.<Vector.<int>>;

  public function GameScreen(width:int, height:int, shared:Object)
  {
    super(width, height, shared);
    _shared = SharedInfo(shared);

    _soundman = new SoundPlayer();

    _keypad = new Keypad();
    _keypad.addEventListener(KeypadEvent.PRESSED, onKeypadPressed);
    _keypad.layoutFull(CELL_SIZE, CELL_SIZE, CELL_MARGIN);
    _keypad.x = (width-_keypad.rect.width)/2;
    _keypad.y = (height-_keypad.rect.height)/2;
    addChild(_keypad);

    _maze = new Maze(_keypad.cols, _keypad.rows, CELL_SIZE+CELL_MARGIN);
    _maze.addEventListener(ActorEvent.COLLIDED, onActorCollided);
    _maze.addEventListener(ActorEvent.EXPLODED, onActorExploded);
    _maze.x = _keypad.x-4;
    _maze.y = _keypad.y-4;
    addChild(_maze);

    _shadow = new Shadow(CELL_SIZE);
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

    _guide = new SoundGuide(_soundman, width/2, height/6);
    _guide.x = (width-_guide.width)/2;
    _guide.y = _status.y-_guide.height-16;
    addChild(_guide);

    addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
  }

  // open()
  public override function open():void
  {
    _tutorial = 0;
    _ticks = 0;
    _soundman.isActive = true;

    _state = UNINITED;
    _title.show("ESCAPE THE CAVE");
    _guide.show("PRESS Z KEY.");

    initGame();
  }

  // close()
  public override function close():void
  {
    _maze.stopSound();
    _soundman.isActive = false;
  }

  // pause()
  public override function pause():void
  {
    _maze.stopSound();
    _soundman.isActive = false;
    _tleft -= (getTimer()-_t0);
  }

  // resume()
  public override function resume():void
  {
    _soundman.isActive = true;
    _t0 = getTimer();
  }

  // update()
  public override function update():void
  {
    _keypad.update();

    var rect:Rectangle = _player.rect;
    _shadow.x = _maze.x+rect.x+(rect.width-_shadow.width)/2;
    _shadow.y = _maze.y+rect.y+(rect.height-_shadow.height)/2;
    _player.update(_ticks);

    if (_state == STARTED) {
      updateGame();
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
    _maze.clear();
    _maze.buildFromArray(Levels.getLevel(_status.level));
    _maze.paint();

    var p:Point = _maze.findCell(function (cell:MazeCell):Boolean
				 { return (cell.item == MazeCell.START); });
    _player.visible = false;
    _player.init(p.x, p.y, PLAYER_HEALTH);
    _soundman.addSound(Sounds.startSound);

    _status.health = _player.health;
    switch (_shared.mode) {
    case 0:
      if (_status.level < 7) {
	_status.time = 100;
      } else {
	_status.time = 90;
      }
      break;
    case 1:
      _status.time = 90;
      break;
    }
    _status.update();

    _compass = null;

    _state = INITED;
  }

  // startGame()
  private function startGame():void
  {
    trace("startGame");
    // start the timer.
    _tleft = _status.time*1000;
    _t0 = getTimer();

    _player.visible = true;
    _soundman.addSound(Sounds.stepSound);

    _state = STARTED;
  }

  // updateGame()
  private function updateGame():void
  {
    _maze.update(_ticks);
    _maze.makeNoises(_player.rect);
    _maze.detectCollision(_player.rect);
    
    if (_status.time < 100 && _t0 != 0) {
      var t:int = Math.floor((_tleft-(getTimer()-_t0)+999)/1000);
      if (_status.time != t) {
	_status.time = t;
	_status.update();
	if (t == 0) {
	  Sounds.doomSound.play();
	  gameOver();
	} else if (t < 10) {
	  Sounds.doomAlarmSound.play();
	} else if (t == 60 || t == 30 || t == 20 || t == 10) {
	  Sounds.doomAlarmSound.play();
	}
      }
    }
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
    if (_status.level+1 < Levels.LEVELS.length) {
      _status.level++;
      _status.update();
      initLevel();
    } else {
      // Game beaten.
      _state = FINISHED;
      _title.show("CONGRATURATIONS!");
      _guide.show("PRESS KEY TO PLAY AGAIN.");
    }
  }

  // badMiss()
  private function badMiss():void
  {
    trace("badMiss");
    Sounds.hurtSound.play();
    _player.health--;
    _status.health = _player.health;
    _status.update();
    if (_status.health == 0) {
      gameOver();
    }
  }

  // keydown(keycode)
  public override function keydown(keycode:int):void
  {
    _title.hide();
    _guide.hide();
    _soundman.reset();
    switch (_state) {
    case UNINITED:
      initGame();
      return;
    case GOALED:
      return;
    }

    _keypad.keydown(keycode);

    switch (keycode) {
    case Keyboard.F1:		// Cheat
      _shadow.visible = !_shadow.visible;
      break;
    case Keyboard.F2:		// Cheat
      nextLevel();
      break;

    case Keyboard.LEFT:
      movePlayer(-1, 0, _keypad.modifiers != 0);
      break;

    case Keyboard.RIGHT:
      movePlayer(+1, 0, _keypad.modifiers != 0);
      break;

    case Keyboard.UP:
      movePlayer(0, -1, _keypad.modifiers != 0);
      break;

    case Keyboard.DOWN:
      movePlayer(0, +1, _keypad.modifiers != 0);
      break;

    case Keyboard.SPACE:
      placeBomb();
      break;

    case Keyboard.SHIFT:
      _keypad.modifiers = M_SHIFT;
      break;
    }
  }

  // keyup(keycode)
  public override function keyup(keycode:int):void
  {
    switch (keycode) {
    case Keyboard.SHIFT:
      _keypad.modifiers = 0;
      break;
    }
  }

  // onMouseDown
  private function onMouseDown(e:MouseEvent):void
  {
    _title.hide();
    _guide.hide();
    _soundman.reset();
    switch (_state) {
    case UNINITED:
      initGame();
      return;
    case GOALED:
      return;
    }

    var p:Point = new Point(e.stageX, e.stageY);
    _keypad.mousedown(_keypad.globalToLocal(p), 1);
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
    movePlayer(dx, dy, e.modifiers != 0);
  }

  // movePlayer(dx, dy)
  private function movePlayer(dx:int, dy:int, moving:Boolean):void
  {
    if (_state != STARTED) {
      startGame();
      return;
    }
    var d:int = Math.abs(dx)+Math.abs(dy);
    if (d == 0) {
      playSound(Sounds.stepSound, dx);
    } else if (d == 1) {
      if (_maze.isOpen(_player.pos.x, _player.pos.y, dx, dy)) {
	if (moving) {
	  if (_compass != null) {
	    var d0:int = _compass[_player.pos.y][_player.pos.x];
	    var d1:int = _compass[_player.pos.y+dy][_player.pos.x+dx];
	    playSound((d1 < d0)? Sounds.correctSound : Sounds.wrongSound, dx);
	  } else {
	    playSound(Sounds.stepSound, dx);
	  }
	  _player.move(dx, dy);
	} else {
	  playSound(Sounds.movableSound, dx);
	}
      } else {
	playSound(Sounds.bumpSound, dx);
      }
    } else if (2 <= d) {
      playSound(Sounds.disabledSound, dx);
    }

    if (_maze.isGoal(_player.pos.x, _player.pos.y)) {
      if (_player.hasKey) {
	_state = GOALED;
	_maze.stopSound();
	_soundman.addSound(Sounds.goalSound)
	  .addEventListener(PlayListItem.STOP, 
			    function (e:Event):void { nextLevel(); });
      } else {
	_soundman.addSound(Sounds.needKeySound);
      }
    }
  }

  // playSound
  private function playSound(sound:Sound, dx:int):void
  {
    sound.play(0, 0, Utils.soundTransform(1, dx));
  }

  // placeBomb
  private function placeBomb():void
  {
    if (0 < _player.hasBomb) {
      _player.hasBomb--;
      _maze.placeBomb(_player.pos.x, _player.pos.y);
      _soundman.addSound(Sounds.bombPlaceSound);
    } else {
      _soundman.addSound(Sounds.disabledSound);
    }
  }

  // initCompass
  private function initCompass():void
  {
    var item:int = (_player.hasKey)? MazeCell.GOAL : MazeCell.ITEM_KEY;
    var p:Point = _maze.findCell(function (cell:MazeCell):Boolean
				 { return (cell.item == item); });
    _compass = new Vector.<Vector.<int>>();
    _maze.findPath(_compass, -1, -1, p.x, p.y);
  }

  // onActorCollided
  private function onActorCollided(e:ActorEvent):void
  {
    var actor:Actor = e.actor;
    if (actor is ActorItem) {
      switch (ActorItem(actor).item) {
      case MazeCell.ITEM_KEY:
	_player.hasKey = true;
	_soundman.addSound(Sounds.keyPickupSound);
	if (_player.hasCompass) {
	  initCompass();
	}
	break;
      case MazeCell.ITEM_HEALTH:
	_player.health++;
	_status.health = _player.health;
	_status.update();
	_soundman.addSound(Sounds.healthPickupSound);
	break;
      case MazeCell.ITEM_BOMB:
	_player.hasBomb++;
	_soundman.addSound(Sounds.bombPickupSound);
	break;
      case MazeCell.ITEM_COMPASS:
	_player.hasCompass = true;
	_soundman.addSound(Sounds.compassPickupSound);
	initCompass();
	break;
      }
      _maze.removeActor(actor);
    } else if (actor is ActorEnemy || actor is ActorTrap) {
      _soundman.addSound(Sounds.explosionSound);
      _maze.removeActor(actor);
      badMiss();
    }
  }

  // onActorExploded
  private function onActorExploded(e:ActorEvent):void
  {
    var actor:Actor = e.actor;
    if (actor is ActorEnemy) {
      _soundman.addSound(Sounds.explosionSound);
      _maze.removeActor(actor);
    }
  }
}

} // package

import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.media.Sound;
import flash.utils.Dictionary;
import baseui.Font;
import baseui.SoundPlayer;


//  Status
// 
class Status extends Sprite
{
  public var level:int;
  public var health:int;
  public var time:int;

  private var _text:Bitmap;

  public function Status()
  {
    _text = Font.createText("LEVEL: 00   HEALTH: 00   TIME: 00", 0xffffff, 0, 2);
    addChild(_text);
  }

  public function update():void
  {
    var text:String = "LEVEL: "+Utils.format(level+1,2);
    text += "   HEALTH: "+Utils.format(health,2);
    text += "   TIME: "+Utils.format(Math.min(99,time),2);
    Font.renderText(_text.bitmapData, text);
  }
}


//  Guide
// 
class Guide extends Sprite
{
  private var _text:Bitmap;

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

  public function show(text:String=null):void
  {
    this.text = text;
    visible = true;
  }

  public function hide():void
  {
    visible = false;
  }
}


//  SoundGuide
// 
class SoundGuide extends Guide
{
  private var _player:SoundPlayer;
  private var _played:Dictionary;

  public function SoundGuide(player:SoundPlayer,
			     width:int, height:int, alpha:Number=0.2)
  {
    super(width, height, alpha);
    _player = player;
    _played = new Dictionary();
    graphics.beginFill(0, alpha);
    graphics.drawRect(0, 0, width, height);
    graphics.endFill();
  }

  public function reset():void
  {
    _played = new Dictionary();
  }

  public function play(sound:Sound):void
  {
    if (_played[sound] === undefined) {
      // Do not play the same sound twice.
      _played[sound] = 1;
      _player.addSound(sound);
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
    graphics.drawRect(size*10.5, size*10.5, size*3, size*3);
    graphics.endFill();
    graphics.beginFill(0, 0.7);
    graphics.drawRect(size*10.5, size*10.5, size*3, size*3);
    graphics.drawRect(size*11, size*11, size*2, size*2);
    graphics.endFill();
  }
}
