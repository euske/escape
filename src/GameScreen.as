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
		"PRESS Z KEY.")
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
