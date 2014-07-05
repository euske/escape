package {

import flash.display.Bitmap;
import baseui.Font;
import baseui.Screen;
import baseui.ScreenEvent;

//  MenuScreen
// 
public class MenuScreen extends Screen
{
  private var _menu:ChoiceMenu;

  public function MenuScreen(width:int, height:int)
  {
    super(width, height);

    var text:Bitmap;
    text = Font.createText("ESCAPE THE CAVE\nPRESS ENTER TO START", 0xffffff, 2, 2);
    text.x = (width-text.width)/2;
    text.y = (height-text.height)/4;
    addChild(text);

    _menu = new ChoiceMenu();
    _menu.addEventListener(MenuChoiceEvent.CHOOSE, onMenuChoose);
    _menu.addChoice("NORMAL MODE");
    _menu.addChoice("RANDOM MODE");
    _menu.x = (width-_menu.width)/2;
    _menu.y = (height*2-_menu.height)/4;
    addChild(_menu);
  }

  public override function keydown(keycode:int):void
  {
    _menu.keydown(keycode);
  }

  private function onMenuChoose(e:MenuChoiceEvent):void
  {
    dispatchEvent(new ScreenEvent(GameScreen));
  }
}

} // package

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.ui.Keyboard;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;
import flash.media.Sound;
import baseui.Font;

class MenuChoiceEvent extends Event
{
  public static const FOCUS:String = "MenuChoiceEvent.FOCUS";
  public static const CHOOSE:String = "MenuChoiceEvent.CHOOSE";

  public var choice:MenuChoice;

  public function MenuChoiceEvent(type:String, choice:MenuChoice=null)
  {
    super(type);
    this.choice = choice;
  }
}

class MenuChoice extends Sprite
{
  public var label:String;
  public var value:Object;

  public override function toString():String
  {
    return ("<MenuChoice: "+label+", "+value+">");
  }

  public function MenuChoice(label:String, value:Object=null)
  {
    this.label = label;
    this.value = (value != null)? value : label;
    addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
    addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
    addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
  }

  protected virtual function onMouseOver(e:MouseEvent):void 
  {
    dispatchEvent(new MenuChoiceEvent(MenuChoiceEvent.FOCUS, this));
  }

  protected virtual function onMouseOut(e:MouseEvent):void 
  {
    dispatchEvent(new MenuChoiceEvent(MenuChoiceEvent.FOCUS, null));
  }

  protected virtual function onMouseDown(e:MouseEvent):void 
  {
    dispatchEvent(new MenuChoiceEvent(MenuChoiceEvent.CHOOSE, this));
  }

  public virtual function set highlit(v:Boolean):void
  {
  }
}

class BitmapMenuChoice extends MenuChoice
{
  public var margin:int = 8;
  public var scale:int = 2;
  public var fgColor:uint = 0xffffff;
  public var hiColor:uint = 0xff0000;

  private var _text:Bitmap;
  private var _highlit:Boolean;

  public function BitmapMenuChoice(label:String, value:Object=null)
  {
    super(label, value);

    _text = Font.createText(label, 0xffffff, scale, scale);
    _text.x = margin;
    _text.y = margin;
    addChild(_text);

    update();
  }

  public override function set highlit(v:Boolean):void
  {
    _highlit = v;
    update();
  }

  public function update():void
  {
    var color:uint = _highlit? hiColor : fgColor;
    var ct:ColorTransform = new ColorTransform();
    ct.color = color;
    _text.bitmapData.colorTransform(_text.bitmapData.rect, ct);

    graphics.clear();
    graphics.beginFill(0, 0.5);
    graphics.drawRect(0, 0, _text.width+margin*2, _text.height+margin*2);
    graphics.endFill();
  }
}

class ChoiceMenu extends Sprite
{
  public var margin:int = 16;

  public var beepSound:Sound = new SoundGenerator().setSineTone(400).setCutoffEnvelope(0.1);

  private var _totalHeight:int;
  private var _choices:Vector.<MenuChoice>;

  private var _current:int = -1;

  public function ChoiceMenu()
  {
    _totalHeight = margin;
    _choices = new Vector.<MenuChoice>();
  }
  
  public function addChoice(label:String, value:Object=null):void
  {
    var choice:MenuChoice = new BitmapMenuChoice(label, value);
    choice.y = _totalHeight;
    choice.addEventListener(MenuChoiceEvent.FOCUS, onMenuFocus);
    choice.addEventListener(MenuChoiceEvent.CHOOSE, onMenuChoose);
    _totalHeight += choice.height + margin;
    _choices.push(choice);
    addChild(choice);
  }
  
  private function onMenuFocus(e:MenuChoiceEvent):void
  {
    if (e.choice != null) {
      _current = _choices.indexOf(e.choice);
      update();
    }
  }

  private function onMenuChoose(e:MenuChoiceEvent):void
  {
    beepSound.play();
    dispatchEvent(new MenuChoiceEvent(MenuChoiceEvent.CHOOSE, e.choice));
  }

  public function get choice():MenuChoice
  {
    if (0 <= _current && _current < _choices.length) {
      return _choices[_current];
    } else {
      return null;
    }
  }

  public function update():void
  {
    for (var i:int = 0; i < _choices.length; i++) {
      _choices[i].highlit = (_current == i);
    }
  }

  public function keydown(keycode:int):void
  {
    switch (keycode) {
    case Keyboard.UP:
      if (_current < 0 && 0 < _choices.length) {
	_current = 0;
	update();
	beepSound.play();
      } else if (0 < _current) {
	_current--;
	update();
	beepSound.play();
      }
      break;

    case Keyboard.DOWN:
      if (_current < 0 && 0 < _choices.length) {
	_current = 0;
	update();
	beepSound.play();
      } else if (_current < _choices.length-1) {
	_current++;
	update();
	beepSound.play();
      }
      break;
      
    case 49:			// 1-9
    case 50:
    case 51:
    case 52:
    case 53:
    case 54:
    case 55:
    case 56:
    case 57:
    case 58:
      if (keycode-49 < _choices.length) {
	_current = keycode-49;
	update();
	beepSound.play();
      }
      break;

    case Keyboard.SPACE:
    case Keyboard.ENTER:
      if (this.choice != null) {
	beepSound.play();
	dispatchEvent(new MenuChoiceEvent(MenuChoiceEvent.CHOOSE, this.choice));
      }
      break;
    }
  }
}
