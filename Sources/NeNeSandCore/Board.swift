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
    closeBuriedGaps()
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

  private struct Gap {
    let top: Int
    let length: Int
  }

  private mutating func closeBuriedGaps() {
    var guardCount = width * height
    while guardCount > 0 {
      guardCount -= 1
      if !closeOneBuriedGap() {
        return
      }
    }
  }

  private mutating func closeOneBuriedGap() -> Bool {
    let open = skyReachable()
    var x = 0
    while x < width {
      if closeColumn(x, open: open) {
        return true
      }
      x += 1
    }
    return false
  }

  private func skyReachable() -> [Bool] {
    var open = Array(repeating: false, count: cells.count)
    var queue: [Int] = []
    var x = 0
    while x < width {
      if let index = offset(x: x, y: 0), cells[index] == .empty {
        queue.append(index)
      }
      x += 1
    }
    var head = 0
    while head < queue.count {
      let index = queue[head]
      head += 1
      if open[index] || cells[index] != .empty {
        continue
      }
      open[index] = true
      spread(index, open: open, queue: &queue)
    }
    return open
  }

  private func spread(_ index: Int, open: [Bool], queue: inout [Int]) {
    let x = index % width
    let y = index / width
    enqueue(x - 1, y, open: open, queue: &queue)
    enqueue(x + 1, y, open: open, queue: &queue)
    enqueue(x, y - 1, open: open, queue: &queue)
    enqueue(x, y + 1, open: open, queue: &queue)
  }

  private func enqueue(_ x: Int, _ y: Int, open: [Bool], queue: inout [Int]) {
    guard let index = offset(x: x, y: y), cells[index] == .empty, !open[index] else {
      return
    }
    queue.append(index)
  }

  private mutating func closeColumn(_ x: Int, open: [Bool]) -> Bool {
    var floorY = height - 1
    while floorY > 0 {
      if let gap = buriedGap(x: x, floorY: floorY, open: open) {
        dropStack(x: x, gapTop: gap.top, length: gap.length)
        return true
      }
      floorY -= 1
    }
    return false
  }

  private func buriedGap(x: Int, floorY: Int, open: [Bool]) -> Gap? {
    guard grain(x: x, y: floorY) != .empty else {
      return nil
    }
    guard let bottom = buriedBottom(x: x, floorY: floorY, open: open) else {
      return nil
    }
    guard let top = buriedTop(x: x, bottom: bottom, open: open) else {
      return nil
    }
    return Gap(top: top, length: bottom - top + 1)
  }

  private func buriedBottom(x: Int, floorY: Int, open: [Bool]) -> Int? {
    let bottom = floorY - 1
    guard bottom >= 1, let index = offset(x: x, y: bottom) else {
      return nil
    }
    guard cells[index] == .empty, !open[index] else {
      return nil
    }
    return bottom
  }

  private func buriedTop(x: Int, bottom: Int, open: [Bool]) -> Int? {
    var top = bottom
    while top > 1 {
      guard let above = offset(x: x, y: top - 1), cells[above] == .empty, !open[above] else {
        break
      }
      top -= 1
    }
    guard let cap = offset(x: x, y: top - 1), cells[cap] != .empty else {
      return nil
    }
    return top
  }

  private mutating func dropStack(x: Int, gapTop: Int, length: Int) {
    let stackBottom = gapTop - 1
    var stackTop = stackBottom
    while stackTop > 0 && grain(x: x, y: stackTop - 1) != .empty {
      stackTop -= 1
    }
    var y = stackBottom
    while y >= stackTop {
      let moving = grain(x: x, y: y)
      place(x: x, y: y + length, grain: moving)
      place(x: x, y: y, grain: .empty)
      y -= 1
    }
  }

  private mutating func place(x: Int, y: Int, grain: Grain) {
    guard let index = offset(x: x, y: y) else {
      return
    }
    cells[index] = grain
  }
}
