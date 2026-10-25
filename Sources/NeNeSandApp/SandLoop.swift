import Foundation
import NeNeSandCore
import NeNeSandRender
import NeNeSandTerminal

struct SandLoop {
  private static let minimumColumns = 8
  private static let minimumRows = 4
  private static let step = Duration.milliseconds(16)

  private let trueColor: Bool
  private let clock = ContinuousClock()

  init(trueColor: Bool) {
    self.trueColor = trueColor
  }

  private struct Pen {
    var grain: Grain = .sand
    var stroke: Cursor?
    var automatic = false
    var hand = AutomaticStroke()
    var handAt: Cursor?
  }

  private struct Scene {
    var board: Board?
    var previous: Frame?
    var pen = Pen()
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
    scene.pen = apply(events, to: &current, pen: scene.pen)
    if clock.now >= scene.nextTick {
      if scene.pen.automatic {
        scene.pen = follow(scene.pen, on: &current)
      }
      current.tick()
      scene.nextTick = clock.now.advanced(by: Self.step)
    }
    let frame = FramePainter.paint(
      current,
      brush: scene.pen.grain,
      automatic: scene.pen.automatic,
      stoneKnown: current.stoneKnown
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
    case .press, .drag, .release, .material, .automatic:
      return false
    }
  }

  private func resized(_ board: Board?, to size: (columns: Int, rows: Int)) -> Board {
    let height = (size.rows - 1) * 2
    guard let board else {
      return Board(width: size.columns, height: height)
    }
    if board.width == size.columns && board.height == height {
      return board
    }
    return Board(width: size.columns, height: height, keeping: board)
  }

  private func apply(_ events: [TerminalEvent], to board: inout Board, pen: Pen) -> Pen {
    var next = pen
    for event in events {
      next = applyOne(event, to: &board, pen: next)
    }
    return next
  }

  private func applyOne(_ event: TerminalEvent, to board: inout Board, pen: Pen) -> Pen {
    switch event {
    case .quit:
      return pen
    case .material(let key):
      if key == .stone && !board.stoneKnown {
        return pen
      }
      var next = moved(pen, grain: grain(for: key), stroke: nil)
      next.handAt = nil
      return next
    case .automatic:
      return Pen(
        grain: pen.grain,
        stroke: nil,
        automatic: !pen.automatic,
        hand: AutomaticStroke(),
        handAt: nil
      )
    case .press(let cursor, let pointer):
      stampCell(cursor, grain: ink(pointer, pen: pen), on: &board)
      return moved(pen, grain: pen.grain, stroke: cursor)
    case .drag(let cursor, let pointer):
      let start = pen.stroke ?? cursor
      connect(from: start, to: cursor, grain: ink(pointer, pen: pen), on: &board)
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
      hand: pen.hand,
      handAt: pen.handAt
    )
  }

  private func follow(_ pen: Pen, on board: inout Board) -> Pen {
    var next = pen
    let rows = board.height / 2
    guard let point = next.hand.next(width: board.width, height: rows) else {
      if next.handAt != nil {
        next.grain = AutomaticStroke.nextBrush(next.grain)
      }
      next.handAt = nil
      return next
    }
    let cursor = Cursor(column: point.x, row: point.y + 1)
    if let previous = next.handAt {
      connect(from: previous, to: cursor, grain: next.grain, on: &board)
    } else {
      stampCell(cursor, grain: next.grain, on: &board)
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

  private func connect(from start: Cursor, to end: Cursor, grain: Grain, on board: inout Board) {
    let cells = Stroke.cells(
      from: Point(x: start.column, y: start.row),
      to: Point(x: end.column, y: end.row)
    )
    for cell in cells {
      stampCell(Cursor(column: cell.x, row: cell.y), grain: grain, on: &board)
    }
  }

  private func stampCell(_ cursor: Cursor, grain: Grain, on board: inout Board) {
    let row = cursor.row - 1
    guard row >= 0 else {
      return
    }
    board.stamp(x: cursor.column, y: row * 2, grain: grain)
    board.stamp(x: cursor.column, y: row * 2 + 1, grain: grain)
  }
}
