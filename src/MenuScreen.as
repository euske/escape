package {

import flash.display.Bitmap;
import flash.media.Sound;
import flash.events.Event;
import baseui.Font;
import baseui.Screen;
import baseui.ScreenEvent;
import baseui.ChoiceMenu;
import baseui.SoundGenerator;

//  MenuScreen
// 
public class MenuScreen extends Screen
{
  private static var beepSound:SoundGenerator;

  private var _menu:ChoiceMenu;
  private var _shared:SharedInfo;

  public function MenuScreen(width:int, height:int, shared:Object)
  {
    super(width, height, shared);
    if (beepSound == null) {
      beepSound = new SoundGenerator();
      beepSound.tone = SoundGenerator.ConstRectTone(200);
      beepSound.envelope = SoundGenerator.CutoffEnvelope(0.04);
    }
    var text:Bitmap;
    text = Font.createText(" ESCAPE\nTHE CAVE", 0xffffff, 4, 4);
    text.x = (width-text.width)/2;
    text.y = (height-text.height)/4;
    addChild(text);

    _menu = new ChoiceMenu();
    _menu.addEventListener(ChoiceMenu.CHOOSE, onMenuChoose);
    _menu.addChoice("NORMAL MODE", "NORMAL", beepSound);
    _menu.addChoice("RANDOM MODE", "RANDOM", beepSound);
    _menu.x = (width-_menu.width)/2;
    _menu.y = (height*3-_menu.height)/4;
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
