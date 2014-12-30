package {

import flash.display.Bitmap;
import flash.events.Event;
import baseui.Font;
import baseui.Screen;
import baseui.ScreenEvent;
import baseui.SoundPlayer;
import baseui.ChoiceMenu;

//  MenuScreen
// 
public class MenuScreen extends Screen
{
  private var _menu:ChoiceMenu;
  private var _soundman:SoundPlayer;
  private var _shared:SharedInfo;

  public function MenuScreen(width:int, height:int, soundman:SoundPlayer, shared:Object)
  {
    super(width, height, soundman, shared);

    var text:Bitmap;
    text = Font.createText(" ESCAPE\nTHE CAVE", 0xffff00, 4, 4);
    text.x = (width-text.width)/2;
    text.y = (height-text.height)/4;
    addChild(text);

    _menu = new ChoiceMenu(soundman);
    _menu.addEventListener(ChoiceMenu.CHOOSE, onMenuChoose);
    _menu.addChoice("NORMAL MODE", "NORMAL", Guides.normal_mode);
    _menu.addChoice("RANDOM MODE", "RANDOM", Guides.random_mode);
    _menu.x = (width-_menu.width)/2;
    _menu.y = (height*3-_menu.height)/4;
    addChild(_menu);

    _soundman = soundman;
    _shared = SharedInfo(shared);
  }

  public override function open():void
  {
    _soundman.addSound(Guides.escape_the_cave);
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
