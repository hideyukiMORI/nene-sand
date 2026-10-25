import Glibc
import NeNeSandRender

nonisolated(unsafe) private var wakeWrite: Int32 = -1

private func handleInterrupt(_: Int32) {
  signalByte(1)
}

private func handleResize(_: Int32) {
  signalByte(2)
}

private func signalByte(_ value: UInt8) {
  var byte = value
  if wakeWrite >= 0 {
    _ = write(wakeWrite, &byte, 1)
  }
}

public struct TerminalSession {
  public let trueColor: Bool
  private var saved = termios()
  private var savedFlags: Int32?
  private var active = false
  private var wakeRead: Int32 = -1
  private var wakeWriteEnd: Int32 = -1
  private var parser = MouseParser()

  public init(trueColor: Bool) {
    self.trueColor = trueColor
  }

  public mutating func begin() -> Bool {
    guard isatty(STDIN_FILENO) == 1, isatty(STDOUT_FILENO) == 1 else {
      return false
    }
    guard installWake() else {
      return false
    }
    enableRaw()
    enterScreen()
    active = true
    return true
  }

  public mutating func restore() {
    guard active else {
      return
    }
    leaveScreen()
    disableRaw()
    removeWake()
    active = false
  }

  public mutating func poll(milliseconds: Int) -> [TerminalEvent] {
    var descriptors = [
      pollfd(fd: STDIN_FILENO, events: Int16(POLLIN), revents: 0),
      pollfd(fd: wakeRead, events: Int16(POLLIN), revents: 0),
    ]
    _ = Glibc.poll(&descriptors, 2, Int32(milliseconds))
    var events = wakeEvents()
    events.append(contentsOf: readInput())
    return events
  }

  public func write(_ text: String) {
    Self.writeAll(Array(text.utf8), to: STDOUT_FILENO)
  }

  static func writeAll(_ bytes: [UInt8], to descriptor: Int32) {
    var offset = 0
    while offset < bytes.count {
      let wrote = Self.writeSome(bytes, at: offset, to: descriptor)
      if wrote > 0 {
        offset += wrote
      } else if !Self.again(wrote, on: descriptor) {
        return
      }
    }
  }

  private static func again(_ wrote: Int, on descriptor: Int32) -> Bool {
    if wrote < 0 && errno == EINTR {
      return true
    }
    if wrote < 0 && (errno == EAGAIN || errno == EWOULDBLOCK) {
      var waiting = pollfd(fd: descriptor, events: Int16(POLLOUT), revents: 0)
      while Glibc.poll(&waiting, 1, -1) < 0 && errno == EINTR {}
      return true
    }
    return false
  }

  private static func writeSome(_ bytes: [UInt8], at offset: Int, to descriptor: Int32) -> Int {
    bytes.withUnsafeBufferPointer { buffer in
      guard let base = buffer.baseAddress else {
        return -1
      }
      return Glibc.write(descriptor, base.advanced(by: offset), bytes.count - offset)
    }
  }

  public func measure() -> (columns: Int, rows: Int)? {
    var size = winsize()
    guard ioctl(STDOUT_FILENO, UInt(TIOCGWINSZ), &size) == 0 else {
      return nil
    }
    guard size.ws_col > 0, size.ws_row > 0 else {
      return nil
    }
    return (Int(size.ws_col), Int(size.ws_row))
  }

  private mutating func installWake() -> Bool {
    var pipes = [Int32](repeating: -1, count: 2)
    guard pipe(&pipes) == 0 else {
      return false
    }
    wakeRead = pipes[0]
    wakeWriteEnd = pipes[1]
    wakeWrite = pipes[1]
    let flags = fcntl(wakeRead, F_GETFL)
    _ = fcntl(wakeRead, F_SETFL, flags | O_NONBLOCK)
    _ = signal(SIGINT, handleInterrupt)
    _ = signal(SIGWINCH, handleResize)
    return true
  }

  private mutating func removeWake() {
    _ = signal(SIGINT, SIG_DFL)
    _ = signal(SIGWINCH, SIG_DFL)
    if wakeRead >= 0 {
      _ = close(wakeRead)
    }
    if wakeWriteEnd >= 0 {
      _ = close(wakeWriteEnd)
    }
    wakeRead = -1
    wakeWriteEnd = -1
    wakeWrite = -1
  }

  private mutating func enableRaw() {
    _ = tcgetattr(STDIN_FILENO, &saved)
    var raw = saved
    raw.c_iflag &= ~UInt32(BRKINT | ICRNL | INPCK | ISTRIP | IXON)
    raw.c_oflag &= ~UInt32(OPOST)
    raw.c_cflag |= UInt32(CS8)
    raw.c_lflag &= ~UInt32(ECHO | ICANON | IEXTEN)
    raw.c_lflag |= UInt32(ISIG)
    raw.c_cc.6 = 0
    raw.c_cc.5 = 0
    _ = tcsetattr(STDIN_FILENO, TCSANOW, &raw)
    let flags = fcntl(STDIN_FILENO, F_GETFL)
    if flags >= 0 {
      savedFlags = flags
      _ = fcntl(STDIN_FILENO, F_SETFL, flags | O_NONBLOCK)
    }
  }

  private mutating func disableRaw() {
    var copy = saved
    _ = tcsetattr(STDIN_FILENO, TCSAFLUSH, &copy)
    if let flags = savedFlags {
      _ = fcntl(STDIN_FILENO, F_SETFL, flags)
      savedFlags = nil
    }
  }

  private func enterScreen() {
    write("\u{1b}[?1049h\u{1b}[?25l\u{1b}[?1002h\u{1b}[?1006h")
  }

  private func leaveScreen() {
    write("\u{1b}[?1006l\u{1b}[?1002l\u{1b}[?25h\u{1b}[?1049l")
  }

  private func wakeEvents() -> [TerminalEvent] {
    var events: [TerminalEvent] = []
    var buffer = [UInt8](repeating: 0, count: 16)
    while true {
      let count = read(wakeRead, &buffer, buffer.count)
      if count <= 0 {
        return events
      }
      var index = 0
      while index < count {
        if buffer[index] == 1 {
          events.append(.quit)
        }
        index += 1
      }
    }
  }

  private mutating func readInput() -> [TerminalEvent] {
    var buffer = [UInt8](repeating: 0, count: 256)
    let count = read(STDIN_FILENO, &buffer, buffer.count)
    guard count > 0 else {
      return []
    }
    return parser.feed(Array(buffer[0..<count]))
  }
}
