package {

import flash.display.Bitmap;
import flash.events.Event;
import baseui.Font;
import baseui.Screen;
import baseui.ScreenEvent;
import baseui.ChoiceMenu;

//  MenuScreen
// 
public class MenuScreen extends Screen
{
  private var _menu:ChoiceMenu;
  private var _shared:SharedInfo;

  public function MenuScreen(width:int, height:int, shared:Object)
  {
    super(width, height, shared);

    var text:Bitmap;
    text = Font.createText(" ESCAPE\nTHE CAVE", 0xffff00, 4, 4);
    text.x = (width-text.width)/2;
    text.y = (height-text.height)/4;
    addChild(text);

    _menu = new ChoiceMenu();
    _menu.addEventListener(ChoiceMenu.CHOOSE, onMenuChoose);
    _menu.addChoice("NORMAL MODE", "NORMAL", Sounds.beepSound);
    _menu.addChoice("RANDOM MODE", "RANDOM", Sounds.beepSound);
    _menu.x = (width-_menu.width)/2;
    _menu.y = (height*3-_menu.height)/4;
    addChild(_menu);

    _shared = SharedInfo(shared);
  }

  public override function keydown(keycode:int):void
  {
    _menu.keydown(keycode);
  }

  private function onMenuChoose(e:Event):void
  {
    _shared.mode = _menu.choiceIndex;
    dispatchEvent(new ScreenEvent(GameScreen));
  }
}

} // package
