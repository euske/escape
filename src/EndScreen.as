package {

import flash.media.Sound;
import flash.display.Bitmap;
import flash.events.Event;
import flash.ui.Keyboard;
import baseui.Font;
import baseui.Screen;
import baseui.ScreenEvent;
import baseui.SoundPlayer;
import baseui.SoundLoop;

//  EndScreen
// 
public class EndScreen extends Screen
{
  private var _soundman:SoundPlayer;
  private var _soundloop:SoundLoop;
  
  [Embed(source="../assets/sounds/ending.mp3", mimetype="audio/mpeg")]
  private static const endingMusic_class:Class;
  private static const endingMusic:Sound = new endingMusic_class();
  
  public function EndScreen(width:int, height:int,
			    soundman:SoundPlayer, shared:Object)
  {
    super(width, height, soundman, shared);
    _soundman = soundman;
    _soundloop = new SoundLoop(endingMusic);

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

  public override function open():void
  {
    _soundloop.start();
    _soundman.addPause(2000);
    _soundman.addSound(Guides.you_escaped);
  }

  public override function close():void
  {
    _soundloop.stop();
  }
  
  public override function pause():void
  {
    _soundloop.pause();
  }
  
  public override function resume():void
  {
    _soundloop.resume();
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
