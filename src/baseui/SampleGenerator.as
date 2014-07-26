package baseui {

//  SampleGenerator
//
public class SampleGenerator extends Object
{
  protected const FRAMERATE:int = 44100;

  public virtual function getSample(i:int):Number
  {
    throw new ArgumentError();    
  }
}

} // package
