public struct Board {
  public let width: Int
  public let height: Int
  private var cells: [Grain]
  private var drift: [Int]
  private var age: [Int]
  private var step: Int

  public init(width: Int, height: Int) {
    let safeWidth = max(width, 0)
    let safeHeight = max(height, 0)
    self.width = safeWidth
    self.height = safeHeight
    let count = safeWidth * safeHeight
    self.cells = Array(repeating: .empty, count: count)
    self.drift = Array(repeating: 0, count: count)
    self.age = Array(repeating: 0, count: count)
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
          copyDrift(from: previous, x: x, y: y)
          copyAge(from: previous, x: x, y: y)
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
    drift[offset] = 0
    age[offset] = 0
  }

  public mutating func tick() {
    react()
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
    ageFire()
    step += 1
  }

  private mutating func react() {
    let products = reactionProducts()
    var index = 0
    while index < products.count {
      if let product = products[index] {
        cells[index] = product
        drift[index] = 0
        age[index] = 0
      }
      index += 1
    }
  }

  private func reactionProducts() -> [Grain?] {
    var products: [Grain?] = Array(repeating: nil, count: cells.count)
    var index = 0
    while index < cells.count {
      products[index] = product(at: index)
      index += 1
    }
    return products
  }

  private func product(at index: Int) -> Grain? {
    let target = cells[index]
    var row = 0
    while row < Reaction.rows.count {
      let rule = Reaction.rows[row]
      if rule.target == target && touches(index, source: rule.source) {
        return rule.product
      }
      row += 1
    }
    return nil
  }

  private func touches(_ index: Int, source: Grain) -> Bool {
    let x = index % width
    let y = index / width
    if grain(x: x - 1, y: y) == source {
      return true
    }
    if grain(x: x + 1, y: y) == source {
      return true
    }
    if grain(x: x, y: y - 1) == source {
      return true
    }
    if grain(x: x, y: y + 1) == source {
      return true
    }
    return false
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
    if !acts(grain) {
      return
    }
    for slide in grain.slides(bias: bias) {
      if grain.flows() && !liquidMaySlide(slide, x: x, y: y, from: from) {
        continue
      }
      if shift(from: from, grain: grain, slide: slide, settled: &settled) {
        return
      }
    }
  }

  private func acts(_ grain: Grain) -> Bool {
    switch grain {
    case .lava:
      return LavaMotion.moves(on: step)
    case .empty, .sand, .water, .oil, .fire, .wood:
      return true
    }
  }

  private func liquidMaySlide(_ slide: Slide, x: Int, y: Int, from: Int) -> Bool {
    if slide.dy != 0 {
      return true
    }
    if boundarySlide(slide, x: x, y: y, from: from) {
      return true
    }
    if y > 0 && grain(x: x, y: y - 1) != .empty {
      return false
    }
    let toward = surface(x + slide.dx)
    if !LiquidMotion.canLevel(from: surface(x), toward: toward) {
      return false
    }
    return LiquidMotion.keepsCourse(drift: drift[from], dx: slide.dx)
  }

  private func boundarySlide(_ slide: Slide, x: Int, y: Int, from: Int) -> Bool {
    if grain(x: x, y: y) != .water {
      return false
    }
    if y == 0 || grain(x: x, y: y - 1) != .oil {
      return false
    }
    let neighbor = oilWaterLine(x + slide.dx)
    if !LiquidMotion.canLevel(from: y, toward: neighbor) {
      return false
    }
    return LiquidMotion.keepsCourse(drift: drift[from], dx: slide.dx)
  }

  private enum LineLook {
    case skip
    case blocked
    case found(Int)
  }

  private func oilWaterLine(_ x: Int) -> Int {
    guard x >= 0, x < width else {
      return -1
    }
    var y = 0
    var seenOil = false
    while y < height {
      switch lineUnderOil(grain(x: x, y: y), seenOil: seenOil, y: y) {
      case .found(let line):
        return line
      case .blocked:
        return -1
      case .skip:
        if grain(x: x, y: y) == .oil {
          seenOil = true
        }
      }
      y += 1
    }
    if seenOil {
      return height
    }
    return -1
  }

  private func lineUnderOil(_ grain: Grain, seenOil: Bool, y: Int) -> LineLook {
    switch grain {
    case .water:
      if seenOil {
        return .found(y)
      }
      return .skip
    case .sand, .fire, .wood, .lava:
      if seenOil {
        return .blocked
      }
      return .skip
    case .oil, .empty:
      return .skip
    }
  }

  private func surface(_ x: Int) -> Int {
    guard x >= 0, x < width else {
      return -1
    }
    var y = 0
    while y < height {
      if grain(x: x, y: y) != .empty {
        return y
      }
      y += 1
    }
    return height
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
    let incoming = drift[from]
    let outgoing = drift[to]
    let incomingAge = age[from]
    let outgoingAge = age[to]
    cells[from] = destination
    cells[to] = grain
    drift[from] = outgoing
    drift[to] = incoming
    age[from] = outgoingAge
    age[to] = incomingAge
    settleDrift(grain, slide: slide, to: to)
    settled[to] = true
    return true
  }

  private mutating func settleDrift(_ grain: Grain, slide: Slide, to: Int) {
    if !grain.flows() {
      return
    }
    drift[to] = slide.dy == 0 ? slide.dx : 0
  }

  private mutating func copyDrift(from previous: Board, x: Int, y: Int) {
    guard let source = previous.offset(x: x, y: y), let dest = offset(x: x, y: y) else {
      return
    }
    drift[dest] = previous.drift[source]
  }

  private mutating func copyAge(from previous: Board, x: Int, y: Int) {
    guard let source = previous.offset(x: x, y: y), let dest = offset(x: x, y: y) else {
      return
    }
    age[dest] = previous.age[source]
  }

  private mutating func ageFire() {
    var index = 0
    while index < cells.count {
      if cells[index] == .fire {
        age[index] += 1
        if age[index] >= FireMotion.lifetime {
          cells[index] = .empty
          drift[index] = 0
          age[index] = 0
        }
      }
      index += 1
    }
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
    guard let cap = offset(x: x, y: top - 1), fallsIntoGaps(cells[cap]) else {
      return nil
    }
    return top
  }

  private mutating func dropStack(x: Int, gapTop: Int, length: Int) {
    let stackBottom = gapTop - 1
    var stackTop = stackBottom
    while stackTop > 0 && fallsIntoGaps(grain(x: x, y: stackTop - 1)) {
      stackTop -= 1
    }
    var y = stackBottom
    while y >= stackTop {
      let moving = grain(x: x, y: y)
      let carried = driftAt(x: x, y: y)
      let carriedAge = ageAt(x: x, y: y)
      place(x: x, y: y + length, grain: moving, drift: carried)
      writeAge(x: x, y: y + length, age: carriedAge)
      place(x: x, y: y, grain: .empty, drift: 0)
      y -= 1
    }
  }

  private func fallsIntoGaps(_ grain: Grain) -> Bool {
    switch grain {
    case .sand, .water, .oil, .fire, .lava:
      return true
    case .empty, .wood:
      return false
    }
  }

  private func driftAt(x: Int, y: Int) -> Int {
    guard let index = offset(x: x, y: y) else {
      return 0
    }
    return drift[index]
  }

  private func ageAt(x: Int, y: Int) -> Int {
    guard let index = offset(x: x, y: y) else {
      return 0
    }
    return age[index]
  }

  private mutating func writeAge(x: Int, y: Int, age: Int) {
    guard let index = offset(x: x, y: y) else {
      return
    }
    self.age[index] = age
  }

  private mutating func place(x: Int, y: Int, grain: Grain, drift: Int) {
    guard let index = offset(x: x, y: y) else {
      return
    }
    cells[index] = grain
    self.drift[index] = drift
    if grain == .empty {
      age[index] = 0
    }
  }
}
