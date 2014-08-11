package {

import flash.media.Sound;
import baseui.SoundGenerator;
import baseui.SampleGenerator;

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
  public static var needKeySound:Sound;
  public static var placeSound:Sound;
  public static var goalSound:Sound;
  public static var trapSound:Sound;
  public static var leftSound:Sound;
  public static var rightSound:Sound;

  public static function init():void
  {
    var sound:SoundGenerator;

    beepSound = makeSound
      (SoundGenerator.ConstRectTone(200),
       SoundGenerator.CutoffEnvelope(0.04));

    disabledSound = makeSound
      (SoundGenerator.ConstSineTone(440),
       SoundGenerator.DecayEnvelope(0.01, 0.1));
    
    startSound = makeSound
      (SoundGenerator.RectTone(function (t:Number):Number {
	  return ((0 <= Math.sin(t*t*100))? 220 : 330);
	}),
	SoundGenerator.CutoffEnvelope(0.6));

    stepSound = makeSound
      (SoundGenerator.ConstSawTone(100),
       SoundGenerator.DecayEnvelope(0.01, 0.1));

    bumpSound = makeSound
      (SoundGenerator.ConstNoise(300),
       SoundGenerator.DecayEnvelope(0.01, 0.1));

    pickupSound = makeSound
      (SoundGenerator.RectTone(function (t:Number):Number {
	  return (t<0.05)? 990 : 1200; 
	}),
	SoundGenerator.DecayEnvelope(0.01, 0.3));

    explosionSound = makeSound
      (SoundGenerator.Noise(function (t:Number):Number { 
	  return 800+Math.sin(t*t*100)*100-t*500;
	}),
	SoundGenerator.DecayEnvelope(0.0, 0.6));

    doomAlarmSound = makeSound
      (SoundGenerator.ConstSineTone(880),
       SoundGenerator.DecayEnvelope(0.0, 0.3, 0.1, 2));

    needKeySound = makeSound
      (SoundGenerator.ConstRectTone(140),
       SoundGenerator.DecayEnvelope(0.0, 0.3, 0.1, 3));

    placeSound = makeSound
      (SoundGenerator.RectTone(function (t:Number):Number {
	  return (t<0.05)? 1200 : 990; 
	}),
	SoundGenerator.DecayEnvelope(0.01, 0.3));
    
    goalSound = makeSound
      (SoundGenerator.RectTone(function (t:Number):Number {
	  return ((0 <= Math.sin(t*t*200))? 440+t*100 : 880+t*400);
	}),
	SoundGenerator.CutoffEnvelope(0.6));

    trapSound = makeSound
      (SoundGenerator.Mix(SoundGenerator.ConstSawTone(380),
			  SoundGenerator.ConstSawTone(192)),
       SoundGenerator.ConstantEnvelope(1.0));

    leftSound = makeSound
      (SoundGenerator.ConstRectTone(100),
       SoundGenerator.DecayEnvelope(0.01, 0.4));

    rightSound = makeSound
      (SoundGenerator.ConstRectTone(300),
       SoundGenerator.DecayEnvelope(0.01, 0.4))
  }

  private static function makeSound(tone:SampleGenerator, 
				    envelope:SampleGenerator):Sound
  {
    var sound:SoundGenerator = new SoundGenerator();
    sound.tone = tone;
    sound.envelope = envelope;
    return sound;
  }
}

} // package
