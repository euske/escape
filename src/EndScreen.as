package {

import flash.display.Bitmap;
import flash.events.Event;
import flash.ui.Keyboard;
import baseui.Font;
import baseui.Screen;
import baseui.ScreenEvent;

//  EndScreen
// 
public class EndScreen extends Screen
{
  public function EndScreen(width:int, height:int, shared:Object)
  {
    super(width, height, shared);

    var text:Bitmap;
    text = Font.createText("ESCAPED!", 0x00ffff, 4, 4);
    text.x = (width-text.width)/2;
    text.y = (height-text.height)/4;
    addChild(text);

    text = Font.createText(
      "      THANK YOU FOR PLAYING!\n\n"+
      "PRESS ENTER KEY TO RETURN TO MENU",
      0xffffff, 2, 2);
    text.x = (width-text.width)/2;
    text.y = (height*3-text.height)/4;
    addChild(text);
  }

  public override function keydown(keycode:int):void
  {
    switch (keycode) {
    case Keyboard.SPACE:
    case Keyboard.ENTER:
      dispatchEvent(new ScreenEvent(MenuScreen));
      break;
    }
  }
}

} // package
