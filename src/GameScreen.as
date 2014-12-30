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

  private const INITED:String = "INITED";
  private const STARTED:String = "STARTED";
  private const GOALED:String = "GOALED";

  private var _shared:SharedInfo;
  private var _title:Guide;
  private var _guide:SoundGuide;
  private var _keypad:Keypad;
  private var _status:Status;
  private var _soundman:SoundPlayer;

  private var _state:String;
  private var _ticks:int;
  private var _tleft:int;
  private var _t0:int;
  private var _modifiers:uint;

  private var _maze:Maze;
  private var _shadow:Shadow;
  private var _player:Player;
  private var _compass:Vector.<Vector.<int>>;

  private var _tutorial_move:Boolean;
  private var _tutorial_time:Boolean;
  private var _tutorial_trap:Boolean;
  private var _tutorial_enemy:Boolean;
  private var _tutorial_key:Boolean;
  private var _tutorial_health:Boolean;
  private var _tutorial_bomb:Boolean;
  private var _tutorial_compass:Boolean;
  
  public function GameScreen(width:int, height:int,
			     soundman:SoundPlayer, shared:Object)
  {
    super(width, height, soundman, shared);
    _soundman = soundman;
    _shared = SharedInfo(shared);

    _keypad = new Keypad();
    _keypad.addEventListener(KeypadEvent.PRESSED, onKeypadPressed);
    _keypad.layoutFull(4, 10, CELL_SIZE, CELL_SIZE, CELL_MARGIN);
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

    _guide = new SoundGuide(_soundman, width, height/8, 0x88ffff);
    _guide.x = (width-_guide.width)/2;
    _guide.y = _status.y-_guide.height-16;
    addChild(_guide);

    addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
  }

  // open()
  public override function open():void
  {
    switch (_shared.mode) {
    case 0:			// Normal mode
      _tutorial_move = false;
      _tutorial_time = true;
      _tutorial_trap = false;
      _tutorial_enemy = false;
      _tutorial_key = false;
      _tutorial_health = false;
      _tutorial_bomb = false;
      _tutorial_compass = false;
      break;
      
    case 1:			// Random mode
      _tutorial_move = true;
      _tutorial_time = false;
      _tutorial_trap = true;
      _tutorial_enemy = true;
      _tutorial_key = true;
      _tutorial_health = true;
      _tutorial_bomb = true;
      _tutorial_compass = true;
      break;
    }
    
    _ticks = 0;

    trace("initGame");
    _status.level = 0;
    initLevel();
  }

  // close()
  public override function close():void
  {
    _maze.stopSound();
  }

  // pause()
  public override function pause():void
  {
    _maze.stopSound();
    _tleft -= (getTimer()-_t0);
  }

  // resume()
  public override function resume():void
  {
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

  // initLevel()
  private function initLevel():void
  {
    trace("initLevel");
    _maze.clear();
    switch (_shared.mode) {
    case 0:			// Normal mode
      _maze.buildFromArray(Levels.getLevel(_status.level));
      break;
      
    case 1:			// Random mode
      _maze.buildAuto();
      _maze.placeItem(MazeCell.ITEM_KEY, (_status.level < 5)? +1 : -1);
      if (Utils.rnd(2) == 0) {
	_maze.placeItem(MazeCell.ITEM_COMPASS, (_status.level < 5)? 0 : -1);
      }
      var i:int;
      var ntraps:int = Utils.rnd(Math.floor(_status.level/2)+1);
      for (i = 0; i < ntraps; i++) {
	_maze.placeItem(MazeCell.TRAP, -1);
      }
      var nenemies:int = Utils.rnd(Math.floor(_status.level/2)+1);
      for (i = 0; i < nenemies; i++) {
	_maze.placeItem(MazeCell.ENEMY, 0);
      }
      var nhealths:int = Utils.rnd(ntraps+nenemies+1);
      for (i = 0; i < nhealths; i++) {
	_maze.placeItem(MazeCell.ITEM_HEALTH, 0);
      }
      var nbombs:int = Utils.rnd(nenemies+1);
      for (i = 0; i < nbombs; i++) {
	_maze.placeItem(MazeCell.ITEM_BOMB, 0);
      }
      break;
    }
    
    initState();
  }
  
  // initState()
  private function initState():void
  {
    trace("initState");
    _maze.clearActors();
    _maze.placeActors();
    _maze.paint();

    var p:Point = _maze.findCell(function (cell:MazeCell):Boolean
				 { return (cell.item == MazeCell.START); });
    _player.visible = false;
    _player.init(p.x, p.y, PLAYER_HEALTH);

    _compass = null;
    
    _title.show("LEVEL "+(_status.level+1));
    _soundman.addSound(Guides.getLevel(_status.level+1));
    _soundman.addSound(Sounds.startSound);

    _guide.show("PRESS Z KEY TO START.");
    _guide.play(Guides.press_z);

    _status.health = _player.health;
    switch (_shared.mode) {
    case 0:			// Normal mode
      _status.time = -1;
      break;
      
    case 1:			// Random mode
      _status.time = 90;
      break;
    }
    _status.update();

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
    if (!_tutorial_move) {
      _tutorial_move = true;
      _guide.show("REACH UPPERRIGHT CORNER.\nSHIFT+KEY TO MOVE.");
      _guide.play(Guides.tutorial_move);
    } else if (!_tutorial_time) {
      _tutorial_time = true;
      _guide.show("RANDOM MODE HAS TIME LIMIT.\nGET OUT WITHIN 1.5 MINUTE.");
      _guide.play(Guides.tutorial_time);
    } else if (!_tutorial_trap && _maze.hasItem(MazeCell.TRAP)) {
      _tutorial_trap = true;
      _guide.show("ELECTRICAL TRAPS IN THIS LEVEL.");
      _guide.play(Guides.tutorial_trap);
    } else if (!_tutorial_enemy && _maze.hasItem(MazeCell.ENEMY)) {
      _tutorial_enemy = true;
      _guide.show("ROBOT ENEMIES MAKE NOISES\nBASED ON ITS DIRECTION.");
      _guide.play(Guides.tutorial_enemy);
    } else if (!_tutorial_health && _maze.hasItem(MazeCell.ITEM_HEALTH)) {
      _tutorial_health = true;
      _guide.show("EXTRA HEALTH ITEM IN THIS LEVEL.\nIT RECOVERS YOU BY ONE.");
      _guide.play(Guides.tutorial_health);
    } else if (!_tutorial_bomb && _maze.hasItem(MazeCell.ITEM_BOMB)) {
      _tutorial_bomb = true;
      _guide.show("PICK UP A MINE. IT BLOWS UP ENEMIES.\nPRESS SPACE KEY TO PLACE IT.");
      _guide.play(Guides.tutorial_bomb);
    } else if (!_tutorial_compass && _maze.hasItem(MazeCell.ITEM_COMPASS)) {
      _tutorial_compass = true;
      _guide.show("COMPASS LEADS YOU TO GOAL.\nMAKES HIGH PITCH SOUND FOR RIGHT WAY.");
      _guide.play(Guides.tutorial_compass);
    }
  }

  // updateGame()
  private function updateGame():void
  {
    _maze.update(_ticks);
    _maze.makeNoises(_player.rect);
    _maze.detectCollision(_player.rect);
    
    if (0 <= _status.time && _t0 != 0) {
      var t:int = Math.floor((_tleft-(getTimer()-_t0)+999)/1000);
      if (_status.time != t) {
	_status.time = t;
	_status.update();
	_guide.play(Guides.getSecond(t));
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
    _guide.play(Guides.game_over);

    initState();
  }

  // goalReached()
  private function goalReached():void
  {
    trace("goalReached");
    
    _maze.stopSound();
    _state = GOALED;
    _title.show("GOAL!");
    _guide.show("PRESS ENTER KEY.");
    _guide.play(Guides.reached_goal);
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
      dispatchEvent(new ScreenEvent(EndScreen));
    }
  }

  // badMiss()
  private function badMiss():void
  {
    trace("badMiss");
    
    _player.health--;
    switch (_player.health) {
    case 0:
      Sounds.hurtFatalSound.play();
      break;
    case 1:
      Sounds.hurtMoreSound.play();
      break;
    default:
      Sounds.hurtSound.play();
      break;
    }
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
    case INITED:
    case STARTED:
      _keypad.keydown(keycode);

      switch (keycode) {
      case Keyboard.F7:		// Cheat
	_shadow.visible = !_shadow.visible;
	break;
      case Keyboard.F8:		// Cheat
	nextLevel();
	break;

      case Keyboard.LEFT:
	movePlayer(-1, 0, isMoving(_modifiers));
	break;

      case Keyboard.RIGHT:
	movePlayer(+1, 0, isMoving(_modifiers));
	break;

      case Keyboard.UP:
	movePlayer(0, -1, isMoving(_modifiers));
	break;

      case Keyboard.DOWN:
	movePlayer(0, +1, isMoving(_modifiers));
	break;

      case Keyboard.SPACE:
      case Keyboard.ENTER:
	placeBomb();
	break;
      }
      break;

    case GOALED:
      switch (keycode) {
      case Keyboard.SPACE:
      case Keyboard.ENTER:
	nextLevel();
	break;
      }
      break;
    }

    if (keycode == Keyboard.SHIFT) {
      _modifiers |= M_SHIFT;
    }
  }

  // keyup(keycode)
  public override function keyup(keycode:int):void
  {
    if (keycode == Keyboard.SHIFT) {
      _modifiers &= ~M_SHIFT;
    }
  }

  // onMouseDown
  private function onMouseDown(e:MouseEvent):void
  {
    _title.hide();
    _guide.hide();
    _soundman.reset();

    switch (_state) {
    case INITED:
    case STARTED:
      var p:Point = new Point(e.stageX, e.stageY);
      _keypad.mousedown(_keypad.globalToLocal(p));
      break;
      
    case GOALED:
      nextLevel();
      break;
    }
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
    movePlayer(dx, dy, isMoving(_modifiers));
  }

  private function isMoving(modifiers:uint):Boolean
  {
    return ((modifiers & M_SHIFT) != 0);
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
	_soundman.addSound(Sounds.goalSound);
	goalReached();
      } else {
	_soundman.addSound(Sounds.needKeySound);
	_guide.show("YOU NEED A KEY.");
	_guide.play(Guides.need_key);
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
      _guide.show("PLACED A MINE.");
      _guide.play(Guides.placed_bomb);
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
	if (!_tutorial_key) {
	  _tutorial_key = true;
	  _guide.show("PICKED UP A KEY.\nA KEY IS REQUIRED FOR EXIT.");
	  _guide.play(Guides.tutorial_key);
	} else {
	  _guide.show("PICKED UP A KEY.");
	  _guide.play(Guides.picked_key);
	}
	if (_player.hasCompass) {
	  initCompass();
	}
	break;
	
      case MazeCell.ITEM_HEALTH:
	_player.health++;
	_status.health = _player.health;
	_status.update();
	_soundman.addSound(Sounds.healthPickupSound);
	_guide.show("PICKED UP A HEALTH.");
	_guide.play(Guides.picked_health);
	break;
	
      case MazeCell.ITEM_BOMB:
	_player.hasBomb++;
	_soundman.addSound(Sounds.bombPickupSound);
	_guide.show("PICKED UP A MINE.");
	_guide.play(Guides.picked_bomb);
	break;
	
      case MazeCell.ITEM_COMPASS:
	_player.hasCompass = true;
	_soundman.addSound(Sounds.compassPickupSound);
	_guide.show("PICKED UP A COMPASS.");
	_guide.play(Guides.picked_compass);
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
    if (0 <= time) {
      text += "   TIME: "+Utils.format(time,2);
    } else {
      text += "           ";
    }
    Font.renderText(_text.bitmapData, text);
  }
}


//  Guide
// 
class Guide extends Sprite
{
  private var _text:Bitmap;
  private var _color:uint;

  public function Guide(width:int, height:int,
			color:uint=0xffffff, alpha:Number=0.2)
  {
    graphics.beginFill(0, alpha);
    graphics.drawRect(0, 0, width, height);
    graphics.endFill();
    _color = color;
  }

  public function set text(v:String):void
  {
    if (_text != null) {
      removeChild(_text);
      _text = null;
    }
    if (v != null) {
      _text = Font.createText(v, _color, 4, 2);
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

  public function SoundGuide(player:SoundPlayer,
			     width:int, height:int, alpha:Number=0.2)
  {
    super(width, height, alpha);
    _player = player;
    graphics.beginFill(0, alpha);
    graphics.drawRect(0, 0, width, height);
    graphics.endFill();
  }

  public function play(sound:Sound):void
  {
    if (sound != null) {
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
    graphics.drawRect(size*11.25, size*11.25, size*1.5, size*1.5);
    graphics.endFill();
    graphics.beginFill(0, 0.7);
    graphics.drawRect(size*11.25, size*11.25, size*1.5, size*1.5);
    graphics.drawRect(size*11.4, size*11.4, size*1.2, size*1.2);
    graphics.endFill();
  }
}
