package {

// MazeCell
public class MazeCell extends Object
{
  public static const GOAL:int = 1;
  public static const KEY:int = 2;
  public static const TRAP:int = 3;
  public static const ENEMY:int = 4;

  public var item:int;

  public var visited:Boolean;
  public var open_top:Boolean;
  public var open_left:Boolean;

  public var x:int, y:int;
  public var parent:MazeCell;
  public var distance:int;
  public var shortest:Boolean;

  public function MazeCell(x:int, y:int)
  {
    this.x = x;
    this.y = y;
  }

  public function toString():String
  {
    return ("<MazeCell: ("+x+","+y+")>")
  }
}

} // package
