package {

// MazeCell
public class MazeCell extends Object
{
  public var item:int;

  public var visited:Boolean;
  public var open_top:Boolean;
  public var open_left:Boolean;

  public var x:int, y:int;
  public var parent:MazeCell;
  public var distance:int;

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