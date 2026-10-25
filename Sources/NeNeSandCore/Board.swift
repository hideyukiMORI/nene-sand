public struct Board {
  public let width: Int
  public let height: Int
  private var cells: [Grain]
  private var step: Int

  public init(width: Int, height: Int) {
    let safeWidth = max(width, 0)
    let safeHeight = max(height, 0)
    self.width = safeWidth
    self.height = safeHeight
    self.cells = Array(repeating: .empty, count: safeWidth * safeHeight)
    self.step = 0
  }

  public init(width: Int, height: Int, keeping previous: Board) {
    self.init(width: width, height: height)
    let columns = min(self.width, previous.width)
    let rows = min(self.height, previous.height)
    var y = 0
    while y < rows {
      var x = 0
      while x < columns {
        if previous.grain(x: x, y: y) == .sand {
          stamp(x: x, y: y)
        }
        x += 1
      }
      y += 1
    }
    step = previous.step
  }

  public func grain(x: Int, y: Int) -> Grain {
    guard let offset = offset(x: x, y: y) else {
      return .empty
    }
    return cells[offset]
  }

  public mutating func stamp(x: Int, y: Int) {
    guard let offset = offset(x: x, y: y) else {
      return
    }
    cells[offset] = .sand
  }

  public mutating func tick() {
    let columns = columnOrder()
    var y = height - 2
    while y >= 0 {
      for x in columns {
        move(x: x, y: y)
      }
      y -= 1
    }
    step += 1
  }

  public func count(of grain: Grain) -> Int {
    cells.filter { $0 == grain }.count
  }

  private func offset(x: Int, y: Int) -> Int? {
    guard x >= 0, y >= 0, x < width, y < height else {
      return nil
    }
    return y * width + x
  }

  private func columnOrder() -> [Int] {
    let range = Array(0..<width)
    if step % 2 == 0 {
      return range
    }
    return Array(range.reversed())
  }

  private mutating func move(x: Int, y: Int) {
    guard grain(x: x, y: y) == .sand else {
      return
    }
    if shift(x: x, y: y, dx: 0) {
      return
    }
    let first = step % 2 == 0 ? -1 : 1
    if shift(x: x, y: y, dx: first) {
      return
    }
    _ = shift(x: x, y: y, dx: -first)
  }

  private mutating func shift(x: Int, y: Int, dx: Int) -> Bool {
    guard grain(x: x + dx, y: y + 1) == .empty else {
      return false
    }
    guard let from = offset(x: x, y: y), let to = offset(x: x + dx, y: y + 1) else {
      return false
    }
    cells[from] = .empty
    cells[to] = .sand
    return true
  }
}
