import NeNeSandCore

public enum FramePainter {
  public static let topRows = 3
  public static let bottomRows = 3

  public enum StoneMark: Equatable, Sendable {
    case hidden
    case known
    case free
  }

  public struct Marks: Equatable, Sendable {
    public let automatic: Bool
    public let stone: StoneMark
    public let paused: Bool
    public let width: Int
    public let theme: Theme
    public let purse: Purse
    public let earning: Bool

    public init(
      automatic: Bool = false,
      stone: StoneMark = .hidden,
      paused: Bool = false,
      width: Int = 1,
      theme: Theme = .phosphor,
      purse: Purse = .zero,
      earning: Bool = false
    ) {
      self.automatic = automatic
      self.stone = stone
      self.paused = paused
      self.width = width
      self.theme = theme
      self.purse = purse
      self.earning = earning
    }
  }

  public static func paint(_ board: Board, brush: Grain, marks: Marks = Marks()) -> Frame {
    var glyphs = Instrument.top(width: board.width, brush: brush, marks: marks)
    glyphs.append(contentsOf: field(board, marks: marks))
    glyphs.append(contentsOf: Instrument.bottom(width: board.width, brush: brush, marks: marks))
    let rows = (board.height + 1) / 2
    return Frame(width: board.width, height: rows + topRows + bottomRows, glyphs: glyphs)
  }

  private static func field(_ board: Board, marks: Marks) -> [Glyph] {
    let rows = (board.height + 1) / 2
    var glyphs: [Glyph] = []
    var row = 0
    while row < rows {
      var column = 0
      while column < board.width {
        glyphs.append(glyph(board, column: column, row: row, marks: marks))
        column += 1
      }
      row += 1
    }
    return glyphs
  }

  private static func glyph(_ board: Board, column: Int, row: Int, marks: Marks) -> Glyph {
    let top = board.grain(x: column, y: row * 2)
    let bottom = board.grain(x: column, y: row * 2 + 1)
    let mouth = openMouth(board, column: column, row: row, marks: marks)
    if top == .empty && bottom == .empty && !mouth {
      return blank(marks.theme)
    }
    return Glyph(
      shape: .upperHalf,
      foreground: marks.theme.ink(top),
      background: bed(bottom, mouth: mouth, theme: marks.theme)
    )
  }

  private static func openMouth(_ board: Board, column: Int, row: Int, marks: Marks) -> Bool {
    marks.earning
      && Collector.isMouth(
        x: column,
        y: row * 2 + 1,
        width: board.width,
        height: board.height
      )
  }

  private static func bed(_ grain: Grain, mouth: Bool, theme: Theme) -> CellColor {
    if mouth && grain == .empty {
      return theme.accent()
    }
    return theme.ink(grain)
  }

  private static func blank(_ theme: Theme) -> Glyph {
    Glyph(shape: .blank, foreground: theme.ground(), background: theme.ground())
  }
}
