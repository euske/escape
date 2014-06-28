package {

import flash.media.Sound;
import flash.events.SampleDataEvent;

//  SoundGenerator
//
public class SoundGenerator extends Sound
{
  public static function getPitch(note:String):int
  {
    return Frequencies[note];
  }

  public static function createSine(pitch:Number,
				    attack:Number=0.01,
				    decay:Number=0.5):SoundGenerator
  {
    return new SineSoundGenerator(pitch, attack, decay);
  }
  
  public static function createRect(pitch:Number,
				    attack:Number=0.01,
				    decay:Number=0.5):SoundGenerator
  {
    return new RectSoundGenerator(pitch, attack, decay);
  }
  
  public static function createSaw(pitch:Number,
				   attack:Number=0.01,
				   decay:Number=0.5):SoundGenerator
  {
    return new SawSoundGenerator(pitch, attack, decay);
  }
  
  public static function createNoise(pitch:Number,
				     attack:Number=0.01,
				     decay:Number=0.5):SoundGenerator
  {
    return new NoiseSoundGenerator(pitch, attack, decay);
  }
  
  protected const FRAMERATE:int = 44100;
  protected const SAMPLES:int = 8192;

  private var _attackframes:int;
  private var _decayframes:int;

  public function SoundGenerator(attack:Number,
				 decay:Number)
  {
    this.attack = attack;
    this.decay = decay;
    addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
  }

  public function set attack(v:Number):void
  {
    _attackframes = Math.floor(v*FRAMERATE);
  }

  public function set decay(v:Number):void
  {
    _decayframes = Math.floor(v*FRAMERATE);
  }

  private function onSampleData(e:SampleDataEvent):void
  {
    for (var d:int = 0; d < SAMPLES; d++) {
      var i:int = e.position+d;
      var x:Number;
      try {
	x = generateEnvelope(i) * generateTone(i);
      } catch (error:ArgumentError) {
	break;
      }
      e.data.writeFloat(x); // L
      e.data.writeFloat(x); // R
    }
  }

  private function generateEnvelope(i:int):Number
  {
    var a:Number;
    if (i < _attackframes) {
      a = i/_attackframes;
    } else if ((i-_attackframes) <= _decayframes) {
      a = 1.0 - (i-_attackframes)/_decayframes;
    } else {
      throw new ArgumentError();
    }
    return a;
  }

  public virtual function set pitch(v:Number):void
  {
  }

  protected virtual function generateTone(i:int):Number
  {
    return 0.0;
  }
}

} // package

class SineSoundGenerator extends SoundGenerator
{
  public function SineSoundGenerator(pitch:Number,
				     attack:Number,
				     decay:Number)
  {
    super(attack, decay);
    this.pitch = pitch;
  }

  private var _r:Number;
  public override function set pitch(v:Number):void
  {
    _r = 2.0*Math.PI*v / FRAMERATE;
  }

  protected override function generateTone(i:int):Number
  {
    return Math.sin(_r*i);
  }
}

class RectSoundGenerator extends SoundGenerator
{
  public function RectSoundGenerator(pitch:Number,
				     attack:Number,
				     decay:Number)
  {
    super(attack, decay);
    this.pitch = pitch;
  }

  private var _r:Number;
  public override function set pitch(v:Number):void
  {
    _r = 2*v / FRAMERATE;
  }

  protected override function generateTone(i:int):Number
  {
    return ((Math.floor(_r*i) % 2) == 0)? +1 : -1;
  }
}

class SawSoundGenerator extends SoundGenerator
{
  public function SawSoundGenerator(pitch:Number,
				    attack:Number,
				    decay:Number)
  {
    super(attack, decay);
    this.pitch = pitch;
  }

  private var _r:Number;
  public override function set pitch(v:Number):void
  {
    _r = 2*v / FRAMERATE;
  }

  protected override function generateTone(i:int):Number
  {
    var r:Number = _r*i;
    return (r-Math.floor(r))*2-1;
  }
}

class NoiseSoundGenerator extends SoundGenerator
{
  public function NoiseSoundGenerator(pitch:Number,
				      attack:Number,
				      decay:Number)
  {
    super(attack, decay);
    this.pitch = pitch;
  }

  private var _step:int;
  public override function set pitch(v:Number):void
  {
    _step = Math.floor(FRAMERATE/v/2);
  }

  private var _x:Number;
  protected override function generateTone(i:int):Number
  {
    if ((i % _step) == 0) {
      _x = Math.random()*2-1;
    }
    return _x;
  }
}

class Frequencies extends Object
{
  public static const A0:int = 28;
  public static const A0s:int = 29;
  public static const B0:int = 31;
  public static const C1:int = 33;
  public static const C1s:int = 35;
  public static const D1:int = 37;
  public static const D1s:int = 39;
  public static const E1:int = 41;
  public static const F1:int = 44;
  public static const F1s:int = 46;
  public static const G1:int = 49;
  public static const G1s:int = 52;
  public static const A1:int = 55;
  public static const A1s:int = 58;
  public static const B1:int = 62;
  public static const C2:int = 65;
  public static const C2s:int = 69;
  public static const D2:int = 73;
  public static const D2s:int = 78;
  public static const E2:int = 82;
  public static const F2:int = 87;
  public static const F2s:int = 93;
  public static const G2:int = 98;
  public static const G2s:int = 104;
  public static const A2:int = 110;
  public static const A2s:int = 117;
  public static const B2:int = 123;
  public static const C3:int = 131;
  public static const C3s:int = 139;
  public static const D3:int = 147;
  public static const D3s:int = 156;
  public static const E3:int = 165;
  public static const F3:int = 175;
  public static const F3s:int = 185;
  public static const G3:int = 196;
  public static const G3s:int = 208;
  public static const A3:int = 220;
  public static const A3s:int = 233;
  public static const B3:int = 247;
  public static const C4:int = 262;
  public static const C4s:int = 277;
  public static const D4:int = 294;
  public static const D4s:int = 311;
  public static const E4:int = 330;
  public static const F4:int = 349;
  public static const F4s:int = 370;
  public static const G4:int = 392;
  public static const G4s:int = 415;
  public static const A4:int = 440;
  public static const A4s:int = 466;
  public static const B4:int = 494;
  public static const C5:int = 523;
  public static const C5s:int = 554;
  public static const D5:int = 587;
  public static const D5s:int = 622;
  public static const E5:int = 659;
  public static const F5:int = 698;
  public static const F5s:int = 740;
  public static const G5:int = 784;
  public static const G5s:int = 831;
  public static const A5:int = 880;
  public static const A5s:int = 932;
  public static const B5:int = 988;
  public static const C6:int = 1047;
  public static const C6s:int = 1109;
  public static const D6:int = 1175;
  public static const D6s:int = 1245;
  public static const E6:int = 1319;
  public static const F6:int = 1397;
  public static const F6s:int = 1480;
  public static const G6:int = 1568;
  public static const G6s:int = 1661;
  public static const A6:int = 1760;
  public static const A6s:int = 1865;
  public static const B6:int = 1976;
  public static const C7:int = 2093;
  public static const C7s:int = 2217;
  public static const D7:int = 2349;
  public static const D7s:int = 2489;
  public static const E7:int = 2637;
  public static const F7:int = 2794;
  public static const F7s:int = 2960;
  public static const G7:int = 3136;
  public static const G7s:int = 3322;
  public static const A7:int = 3520;
  public static const A7s:int = 3729;
  public static const B7:int = 3951;
  public static const C8:int = 4186;
}
