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

  private struct Scene {
    var board: Board?
    var previous: Frame?
    var stroke: Cursor?
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
      scene.stroke = nil
      if !scene.toldTooSmall {
        session.write("小さすぎる\n")
        scene.toldTooSmall = true
      }
      return true
    }
    scene.toldTooSmall = false
    var current = resized(scene.board, to: size)
    scene.stroke = apply(events, to: &current, stroke: scene.stroke)
    if clock.now >= scene.nextTick {
      current.tick()
      scene.nextTick = clock.now.advanced(by: Self.step)
    }
    let frame = FramePainter.paint(current)
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
    case .press, .drag, .release:
      return false
    }
  }

  private func resized(_ board: Board?, to size: (columns: Int, rows: Int)) -> Board {
    let height = size.rows * 2
    guard let board else {
      return Board(width: size.columns, height: height)
    }
    if board.width == size.columns && board.height == height {
      return board
    }
    return Board(width: size.columns, height: height, keeping: board)
  }

  private func apply(_ events: [TerminalEvent], to board: inout Board, stroke: Cursor?) -> Cursor? {
    var last = stroke
    for event in events {
      last = applyOne(event, to: &board, stroke: last)
    }
    return last
  }

  private func applyOne(_ event: TerminalEvent, to board: inout Board, stroke: Cursor?) -> Cursor? {
    switch event {
    case .quit:
      return stroke
    case .press(let cursor):
      stampCell(cursor, on: &board)
      return cursor
    case .drag(let cursor):
      let start = stroke ?? cursor
      connect(from: start, to: cursor, on: &board)
      return cursor
    case .release:
      return nil
    }
  }

  private func connect(from start: Cursor, to end: Cursor, on board: inout Board) {
    let cells = Stroke.cells(
      from: Point(x: start.column, y: start.row),
      to: Point(x: end.column, y: end.row)
    )
    for cell in cells {
      stampCell(Cursor(column: cell.x, row: cell.y), on: &board)
    }
  }

  private func stampCell(_ cursor: Cursor, on board: inout Board) {
    board.stamp(x: cursor.column, y: cursor.row * 2)
    board.stamp(x: cursor.column, y: cursor.row * 2 + 1)
  }
}
