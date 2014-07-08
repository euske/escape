package {

import flash.display.Bitmap;
import flash.media.Sound;
import flash.events.Event;
import baseui.Font;
import baseui.Screen;
import baseui.ScreenEvent;
import baseui.ChoiceMenu;

//  MenuScreen
// 
public class MenuScreen extends Screen
{
  public var beepSound:Sound = new SoundGenerator().setSawTone(200).setCutoffEnvelope(0.04);

  private var _menu:ChoiceMenu;
  private var _shared:SharedInfo;

  public function MenuScreen(width:int, height:int, shared:Object)
  {
    super(width, height, shared);

    var text:Bitmap;
    text = Font.createText("ESCAPE THE CAVE\nPRESS ENTER TO START", 0xffffff, 2, 2);
    text.x = (width-text.width)/2;
    text.y = (height-text.height)/4;
    addChild(text);

    _menu = new ChoiceMenu();
    _menu.addEventListener(ChoiceMenu.CHOOSE, onMenuChoose);
    _menu.addChoice("NORMAL MODE", "NORMAL", beepSound);
    _menu.addChoice("RANDOM MODE", "RANDOM", beepSound);
    _menu.x = (width-_menu.width)/2;
    _menu.y = (height*2-_menu.height)/4;
    addChild(_menu);

    _shared = SharedInfo(shared);
    _menu.choiceIndex = _shared.mode;
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
