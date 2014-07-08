package {

import flash.display.Shape;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.media.Sound;

//  ActorTrap
// 
public class ActorTrap extends Actor
{
  private static var sound:Sound =
    new SoundGenerator().setBuzz(380, 192).setConstantEnvelope(1.0);

  public function ActorTrap(maze:Maze)
  {
    super(maze);
    var size:int = maze.cellSize;
    graphics.lineStyle(0);
    graphics.beginFill(0x008822);
    graphics.drawCircle(size/2, size/2, 3*size/8);
    graphics.endFill();
  }

  public override function makeNoise(dx:Number, dy:Number):void
  {
    if (!isPlayingSound) {
      playSound(sound);
    }
    var volume:Number = 1.0-Math.abs(dx)*0.1-Math.abs(dy)*0.2;
    setSoundTransform(volume, dx*0.5);
  }
}

} // package