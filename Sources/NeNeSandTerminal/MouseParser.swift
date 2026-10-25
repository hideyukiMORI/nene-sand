public struct MouseParser {
  private var pending: [UInt8] = []

  public init() {}

  public mutating func feed(_ bytes: [UInt8]) -> [TerminalEvent] {
    pending.append(contentsOf: bytes)
    var events: [TerminalEvent] = []
    var index = 0
    while index < pending.count {
      let consumed = consume(from: index, into: &events)
      if consumed == 0 {
        break
      }
      index += consumed
    }
    if index > 0 {
      pending.removeFirst(index)
    }
    if pending.count > 1024 {
      pending.removeFirst(pending.count - 16)
    }
    return events
  }

  private func consume(from index: Int, into events: inout [TerminalEvent]) -> Int {
    let byte = pending[index]
    if byte == 0x03 || byte == UInt8(ascii: "q") || byte == UInt8(ascii: "Q") {
      events.append(.quit)
      return 1
    }
    if byte != 0x1b {
      return 1
    }
    return mouse(from: index, into: &events)
  }

  private func mouse(from index: Int, into events: inout [TerminalEvent]) -> Int {
    guard let end = mouseEnd(from: index) else {
      return 0
    }
    if let event = mouseEvent(from: index, end: end) {
      events.append(event)
    }
    return end - index + 1
  }

  private func mouseEnd(from index: Int) -> Int? {
    guard index + 2 < pending.count else {
      return nil
    }
    if pending[index + 1] != UInt8(ascii: "[") || pending[index + 2] != UInt8(ascii: "<") {
      return index
    }
    var cursor = index + 3
    while cursor < pending.count {
      let byte = pending[cursor]
      if byte == UInt8(ascii: "M") || byte == UInt8(ascii: "m") {
        return cursor
      }
      if !isMouseByte(byte) {
        return cursor
      }
      cursor += 1
    }
    return nil
  }

  private func isMouseByte(_ byte: UInt8) -> Bool {
    byte == UInt8(ascii: ";") || (byte >= UInt8(ascii: "0") && byte <= UInt8(ascii: "9"))
  }

  private func mouseEvent(from index: Int, end: Int) -> TerminalEvent? {
    let payload = pending[(index + 3)..<end]
    let text = String(decoding: payload, as: UTF8.self)
    let parts = text.split(separator: ";", omittingEmptySubsequences: false)
    guard parts.count == 3, let button = Int(parts[0]), let column = Int(parts[1]),
      let row = Int(parts[2])
    else {
      return nil
    }
    guard column > 0, row > 0 else {
      return nil
    }
    let cursor = Cursor(column: column - 1, row: row - 1)
    let pressed = pending[end] == UInt8(ascii: "M")
    return buttonEvent(button: button, pressed: pressed, cursor: cursor)
  }

  private func buttonEvent(button: Int, pressed: Bool, cursor: Cursor) -> TerminalEvent? {
    let kind = button & 3
    if kind != 0 {
      return nil
    }
    if button & 32 != 0 {
      return .drag(cursor)
    }
    if pressed {
      return .press(cursor)
    }
    return .release(cursor)
  }
}
