package {

import flash.media.Sound;
import baseui.SoundGenerator;

//  Sounds
//
public class Sounds
{
  public static var beepSound:Sound;
  public static var disabledSound:Sound;
  public static var startSound:Sound;
  public static var stepSound:Sound;
  public static var bumpSound:Sound;
  public static var pickupSound:Sound;
  public static var explosionSound:Sound;
  public static var doomAlarmSound:Sound;
  public static var goalSound:Sound;
  public static var trapSound:Sound;
  public static var leftSound:Sound;
  public static var rightSound:Sound;

  public static function init():void
  {
    var sound:SoundGenerator;

    sound = new SoundGenerator();
    sound.tone = SoundGenerator.ConstRectTone(200);
    sound.envelope = SoundGenerator.CutoffEnvelope(0.04);
    beepSound = sound;

    sound = new SoundGenerator();
    sound.tone = SoundGenerator.ConstSineTone(440);
    sound.envelope = SoundGenerator.DecayEnvelope(0.01, 0.1);
    disabledSound = sound;

    sound = new SoundGenerator();
    sound.tone = SoundGenerator.RectTone(function (t:Number):Number {
	return ((0 <= Math.sin(t*t*100))? 220 : 330);
      });
    sound.envelope = SoundGenerator.CutoffEnvelope(0.6);
    startSound = sound;

    sound = new SoundGenerator();
    sound.tone = SoundGenerator.ConstSawTone(100);
    sound.envelope = SoundGenerator.DecayEnvelope(0.01, 0.1);
    stepSound = sound;

    sound = new SoundGenerator();
    sound.tone = SoundGenerator.ConstNoise(300);
    sound.envelope = SoundGenerator.DecayEnvelope(0.01, 0.1);
    bumpSound = sound;

    sound = new SoundGenerator();
    sound.tone = SoundGenerator.RectTone(function (t:Number):Number {
	return (t<0.05)? 660 : 800; 
      });
    sound.envelope = SoundGenerator.DecayEnvelope(0.01, 0.3);
    pickupSound = sound;

    sound = new SoundGenerator();
    sound.tone = SoundGenerator.Noise(function (t:Number):Number { 
	return 400-t*300; 
      });
    sound.envelope = SoundGenerator.DecayEnvelope(0.1, 0.9);
    explosionSound = sound;

    sound = new SoundGenerator();
    sound.tone = SoundGenerator.ConstSineTone(880);
    sound.envelope = SoundGenerator.DecayEnvelope(0.0, 0.3, 0.1, 2);
    doomAlarmSound = sound;

    sound = new SoundGenerator();
    sound.tone = SoundGenerator.RectTone(function (t:Number):Number {
	return ((0 <= Math.sin(t*t*200))? 440+t*100 : 880+t*400);
      });
    sound.envelope = SoundGenerator.CutoffEnvelope(0.6);
    goalSound = sound;

    sound = new SoundGenerator();
    sound.tone = SoundGenerator.Mix(SoundGenerator.ConstSawTone(380),
				    SoundGenerator.ConstSawTone(192));
    sound.envelope = SoundGenerator.ConstantEnvelope(1.0);
    trapSound = sound;

    sound = new SoundGenerator();
    sound.tone = SoundGenerator.ConstRectTone(100);
    sound.envelope = SoundGenerator.DecayEnvelope(0.01, 0.4);
    leftSound = sound;

    sound = new SoundGenerator();
    sound.tone = SoundGenerator.ConstRectTone(300);
    sound.envelope = SoundGenerator.DecayEnvelope(0.01, 0.4);
    rightSound = sound;
  }
}

} // package
