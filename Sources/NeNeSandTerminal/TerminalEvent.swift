public enum TerminalEvent: Equatable, Sendable {
  public enum Pointer: Equatable, Sendable {
    case draw
    case erase
  }

  case quit
  case press(Cursor, Pointer)
  case drag(Cursor, Pointer)
  case release(Cursor, Pointer)
  case material(BrushKey)
  case automatic
  case clear
  case pause
  case brush(Int)
  case freely
}
