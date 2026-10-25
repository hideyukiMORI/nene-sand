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
        let kept = previous.grain(x: x, y: y)
        if kept != .empty {
          stamp(x: x, y: y, grain: kept)
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

  public mutating func stamp(x: Int, y: Int, grain: Grain = .sand) {
    guard let offset = offset(x: x, y: y) else {
      return
    }
    cells[offset] = grain
  }

  public mutating func tick() {
    var settled = Array(repeating: false, count: cells.count)
    let columns = columnOrder()
    let bias = step % 2 == 0 ? -1 : 1
    var y = height - 1
    while y >= 0 {
      for x in columns {
        stepCell(x: x, y: y, bias: bias, settled: &settled)
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

  private mutating func stepCell(x: Int, y: Int, bias: Int, settled: inout [Bool]) {
    guard let from = offset(x: x, y: y), !settled[from] else {
      return
    }
    let grain = cells[from]
    for slide in grain.slides(bias: bias) {
      if shift(from: from, grain: grain, slide: slide, settled: &settled) {
        return
      }
    }
  }

  private mutating func shift(
    from: Int, grain: Grain, slide: Slide, settled: inout [Bool]
  ) -> Bool {
    let destX = (from % width) + slide.dx
    let destY = (from / width) + slide.dy
    guard let to = offset(x: destX, y: destY), !settled[to] else {
      return false
    }
    let destination = cells[to]
    guard grain.enters(destination) else {
      return false
    }
    cells[from] = destination
    cells[to] = grain
    settled[to] = true
    return true
  }
}
