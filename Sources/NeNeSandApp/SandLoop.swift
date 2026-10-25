import Foundation
import NeNeSandCore
import NeNeSandRender
import NeNeSandTerminal

struct SandLoop {
  private static let minimumColumns = 8
  private static let minimumRows = FramePainter.topRows + FramePainter.bottomRows + 1
  private static let step = Duration.milliseconds(16)
  private static let widestReach = 2

  private let trueColor: Bool
  private let clock = ContinuousClock()

  init(trueColor: Bool) {
    self.trueColor = trueColor
  }

  private struct Pen {
    var grain: Grain = .sand
    var stroke: Cursor?
    var automatic = false
    var paused = false
    var freely = false
    var codex = false
    var theme: Theme = .phosphor
    var reach = 0
    var hand = AutomaticStroke()
    var handAt: Cursor?
  }

  private struct Scene {
    var board: Board?
    var previous: Frame?
    var pen = Pen()
    var progress = Progression.beginning
    var toldTooSmall = false
    var nextTick: ContinuousClock.Instant
  }

  mutating func run() {
    var session = TerminalSession(trueColor: trueColor)
    guard session.begin() else {
      FileHandle.standardError.write(Data("端末ではない\n".utf8))
      return
    }
    defer { session.restore() }
    var scene = Scene(nextTick: clock.now)
    while turn(&session, &scene) {}
  }

  private mutating func turn(_ session: inout TerminalSession, _ scene: inout Scene) -> Bool {
    let events = session.poll(milliseconds: 16)
    if events.contains(where: isQuit) {
      return false
    }
    guard let size = session.measure(), fits(size) else {
      scene.board = nil
      scene.previous = nil
      scene.pen.stroke = nil
      if !scene.toldTooSmall {
        session.write("小さすぎる\n")
        scene.toldTooSmall = true
      }
      return true
    }
    scene.toldTooSmall = false
    var current = resized(scene.board, to: size)
    scene.pen = apply(events, to: &current, pen: scene.pen, progress: &scene.progress)
    if !scene.pen.paused && !scene.pen.codex && clock.now >= scene.nextTick {
      step(&current, pen: &scene.pen, progress: &scene.progress)
      scene.nextTick = clock.now.advanced(by: Self.step)
    }
    let frame = FramePainter.paint(
      current,
      brush: scene.pen.grain,
      marks: FramePainter.Marks(
        automatic: scene.pen.automatic,
        stone: stoneMark(scene.pen, known: current.stoneKnown),
        paused: scene.pen.paused,
        width: scene.pen.reach * 2 + 1,
        theme: scene.pen.theme,
        progress: scene.progress,
        fireKnown: current.fireKnown,
        earning: !scene.pen.freely,
        codex: scene.pen.codex
      )
    )
    session.write(AnsiDiff.text(previous: scene.previous, next: frame, trueColor: trueColor))
    scene.previous = frame
    scene.board = current
    return true
  }

  private func fits(_ size: (columns: Int, rows: Int)) -> Bool {
    size.columns >= Self.minimumColumns && size.rows >= Self.minimumRows
  }

  private func isQuit(_ event: TerminalEvent) -> Bool {
    switch event {
    case .quit:
      return true
    case .press, .drag, .release, .material, .automatic, .clear, .pause, .brush, .freely,
      .theme, .faucet, .codex:
      return false
    }
  }

  private func step(_ board: inout Board, pen: inout Pen, progress: inout Progression) {
    if pen.automatic {
      pen = follow(pen, on: &board, progress: &progress)
    }
    let gathered = earned(board, pen: pen, purse: progress.purse)
    board = gathered.board
    progress = progress.holding(gathered.purse)
    board.tick()
    if !pen.freely && progress.ownsFaucet() {
      board = Faucet.drip(board)
    }
  }

  private func earned(_ board: Board, pen: Pen, purse: Purse) -> Collector.Gathering {
    if pen.freely {
      return Collector.Gathering(board: board, purse: purse)
    }
    return Collector.gather(board, into: purse)
  }

  private func resized(_ board: Board?, to size: (columns: Int, rows: Int)) -> Board {
    let height = (size.rows - FramePainter.topRows - FramePainter.bottomRows) * 2
    guard let board else {
      return Board(width: size.columns, height: height)
    }
    if board.width == size.columns && board.height == height {
      return board
    }
    return Board(width: size.columns, height: height, keeping: board)
  }

  private func apply(
    _ events: [TerminalEvent],
    to board: inout Board,
    pen: Pen,
    progress: inout Progression
  ) -> Pen {
    var next = pen
    for event in events {
      next = applyOne(event, to: &board, pen: next, progress: &progress)
    }
    return next
  }

  private func applyOne(
    _ event: TerminalEvent,
    to board: inout Board,
    pen: Pen,
    progress: inout Progression
  ) -> Pen {
    if pen.codex {
      return reading(event, pen: pen)
    }
    return playing(event, to: &board, pen: pen, progress: &progress)
  }

  private func playing(
    _ event: TerminalEvent,
    to board: inout Board,
    pen: Pen,
    progress: inout Progression
  ) -> Pen {
    switch event {
    case .quit, .theme, .faucet, .codex:
      return tuned(event, pen: pen, progress: &progress)
    case .material(let key):
      return chosen(pen, key: key, known: learned(board), progress: &progress)
    case .clear:
      board.clear()
      var next = moved(pen, grain: pen.grain, stroke: nil)
      next.handAt = nil
      return next
    case .pause:
      return toggled(pen)
    case .brush(let delta):
      return sized(pen, delta: delta)
    case .freely:
      return freed(pen, known: learned(board), progress: progress)
    case .automatic:
      return Pen(
        grain: pen.grain,
        stroke: nil,
        automatic: !pen.automatic,
        paused: pen.paused,
        freely: pen.freely,
        codex: pen.codex,
        theme: pen.theme,
        reach: pen.reach,
        hand: AutomaticStroke(),
        handAt: nil
      )
    case .press(let cursor, let pointer):
      stampBrush(cursor, dab: dab(pointer, pen: pen), on: &board)
      return moved(pen, grain: pen.grain, stroke: cursor)
    case .drag(let cursor, let pointer):
      let start = pen.stroke ?? cursor
      connect(from: start, to: cursor, dab: dab(pointer, pen: pen), on: &board)
      return moved(pen, grain: pen.grain, stroke: cursor)
    case .release:
      return moved(pen, grain: pen.grain, stroke: nil)
    }
  }

  private func moved(_ pen: Pen, grain: Grain, stroke: Cursor?) -> Pen {
    Pen(
      grain: grain,
      stroke: stroke,
      automatic: pen.automatic,
      paused: pen.paused,
      freely: pen.freely,
      codex: pen.codex,
      theme: pen.theme,
      reach: pen.reach,
      hand: pen.hand,
      handAt: pen.handAt
    )
  }

  private func tuned(_ event: TerminalEvent, pen: Pen, progress: inout Progression) -> Pen {
    switch event {
    case .theme:
      return recolored(pen)
    case .faucet:
      return boughtFaucet(pen, progress: &progress)
    case .codex:
      return paged(pen)
    case .quit, .press, .drag, .release, .material, .automatic, .clear, .pause, .brush, .freely:
      return pen
    }
  }

  private func reading(_ event: TerminalEvent, pen: Pen) -> Pen {
    switch event {
    case .codex:
      return paged(pen)
    case .quit, .press, .drag, .release, .material, .automatic, .clear, .pause, .brush, .freely,
      .theme, .faucet:
      return pen
    }
  }

  private func paged(_ pen: Pen) -> Pen {
    var next = pen
    next.codex.toggle()
    next.stroke = nil
    next.handAt = nil
    return next
  }

  private func recolored(_ pen: Pen) -> Pen {
    var next = pen
    next.theme = pen.theme.next()
    return next
  }

  private func follow(_ pen: Pen, on board: inout Board, progress: inout Progression) -> Pen {
    var next = pen
    let rows = board.height / 2
    guard let point = next.hand.next(width: board.width, height: rows) else {
      if next.handAt != nil {
        next.grain = spent(next, progress: &progress, fire: board.fireKnown)
      }
      next.handAt = nil
      return next
    }
    let cursor = Cursor(column: point.x, row: point.y + FramePainter.topRows)
    let dab = Dab(grain: next.grain, reach: next.reach)
    if let previous = next.handAt {
      connect(from: previous, to: cursor, dab: dab, on: &board)
    } else {
      stampBrush(cursor, dab: dab, on: &board)
    }
    next.handAt = cursor
    return next
  }

  private func ink(_ pointer: TerminalEvent.Pointer, pen: Pen) -> Grain {
    switch pointer {
    case .draw:
      return pen.grain
    case .erase:
      return .empty
    }
  }

  private func grain(for key: BrushKey) -> Grain {
    switch key {
    case .sand:
      return .sand
    case .water:
      return .water
    case .oil:
      return .oil
    case .fire:
      return .fire
    case .wood:
      return .wood
    case .lava:
      return .lava
    case .stone:
      return .stone
    }
  }

  private struct Dab {
    var grain: Grain
    var reach: Int
  }

  private struct Known {
    var stone: Bool
    var fire: Bool
  }

  private func learned(_ board: Board) -> Known {
    Known(stone: board.stoneKnown, fire: board.fireKnown)
  }

  private func chosen(
    _ pen: Pen,
    key: BrushKey,
    known: Known,
    progress: inout Progression
  ) -> Pen {
    let grain = grain(for: key)
    if pen.freely {
      return picked(pen, grain)
    }
    if forSale(key) {
      return bought(pen, grain, progress: &progress)
    }
    return held(pen, grain, known: known)
  }

  private func held(_ pen: Pen, _ grain: Grain, known: Known) -> Pen {
    if grain == .fire && !known.fire {
      return pen
    }
    if grain == .stone && !known.stone {
      return pen
    }
    return picked(pen, grain)
  }

  private func forSale(_ key: BrushKey) -> Bool {
    switch key {
    case .oil, .wood, .lava:
      return true
    case .sand, .water, .fire, .stone:
      return false
    }
  }

  private func boughtFaucet(_ pen: Pen, progress: inout Progression) -> Pen {
    if !pen.freely {
      progress = progress.buyingFaucet()
    }
    return pen
  }

  private func bought(_ pen: Pen, _ grain: Grain, progress: inout Progression) -> Pen {
    if progress.owns(grain) {
      return picked(pen, grain)
    }
    let next = progress.buying(grain)
    if !next.owns(grain) {
      return pen
    }
    progress = next
    return picked(pen, grain)
  }

  private func picked(_ pen: Pen, _ grain: Grain) -> Pen {
    var next = moved(pen, grain: grain, stroke: nil)
    next.handAt = nil
    return next
  }

  private func freed(_ pen: Pen, known: Known, progress: Progression) -> Pen {
    var next = pen
    next.freely.toggle()
    if next.freely || keeps(next.grain, known: known, progress: progress) {
      return next
    }
    next.grain = .sand
    return next
  }

  private func keeps(_ grain: Grain, known: Known, progress: Progression) -> Bool {
    if grain == .stone {
      return known.stone
    }
    if grain == .fire {
      return known.fire
    }
    return progress.owns(grain)
  }

  private func spent(_ pen: Pen, progress: inout Progression, fire: Bool) -> Grain {
    if pen.freely {
      return AutomaticStroke.nextBrush(pen.grain)
    }
    let stepped = progress.advancing(pen.grain, fire: fire)
    progress = stepped.progress
    return stepped.grain
  }

  private func stoneMark(_ pen: Pen, known: Bool) -> FramePainter.StoneMark {
    if pen.freely {
      return .free
    }
    if known {
      return .known
    }
    return .hidden
  }

  private func toggled(_ pen: Pen) -> Pen {
    var next = pen
    next.paused.toggle()
    return next
  }

  private func sized(_ pen: Pen, delta: Int) -> Pen {
    let reach = pen.reach + delta
    if reach < 0 || reach > Self.widestReach {
      return pen
    }
    var next = pen
    next.reach = reach
    return next
  }

  private func dab(_ pointer: TerminalEvent.Pointer, pen: Pen) -> Dab {
    Dab(grain: ink(pointer, pen: pen), reach: pen.reach)
  }

  private func connect(from start: Cursor, to end: Cursor, dab: Dab, on board: inout Board) {
    let cells = Stroke.cells(
      from: Point(x: start.column, y: start.row),
      to: Point(x: end.column, y: end.row)
    )
    for cell in cells {
      stampBrush(Cursor(column: cell.x, row: cell.y), dab: dab, on: &board)
    }
  }

  private func stampBrush(_ cursor: Cursor, dab: Dab, on board: inout Board) {
    let fieldRow = cursor.row - FramePainter.topRows
    guard fieldRow >= 0 && fieldRow < board.height / 2 else {
      return
    }
    let cells = Brush.cells(around: Point(x: cursor.column, y: cursor.row), reach: dab.reach)
    for cell in cells {
      stampCell(Cursor(column: cell.x, row: cell.y), grain: dab.grain, on: &board)
    }
  }

  private func stampCell(_ cursor: Cursor, grain: Grain, on board: inout Board) {
    let row = cursor.row - FramePainter.topRows
    guard row >= 0 else {
      return
    }
    board.stamp(x: cursor.column, y: row * 2, grain: grain)
    board.stamp(x: cursor.column, y: row * 2 + 1, grain: grain)
  }
}
