public enum TerminalEvent: Equatable, Sendable {
  case quit
  case press(Cursor)
  case drag(Cursor)
  case release(Cursor)
}
