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

    public init(
      automatic: Bool = false,
      stone: StoneMark = .hidden,
      paused: Bool = false,
      width: Int = 1,
      theme: Theme = .phosphor
    ) {
      self.automatic = automatic
      self.stone = stone
      self.paused = paused
      self.width = width
      self.theme = theme
    }
  }

  public static func paint(_ board: Board, brush: Grain, marks: Marks = Marks()) -> Frame {
    var glyphs = Instrument.top(width: board.width, brush: brush, marks: marks)
    glyphs.append(contentsOf: field(board, theme: marks.theme))
    glyphs.append(contentsOf: Instrument.bottom(width: board.width, brush: brush, marks: marks))
    let rows = (board.height + 1) / 2
    return Frame(width: board.width, height: rows + topRows + bottomRows, glyphs: glyphs)
  }

  private static func field(_ board: Board, theme: Theme) -> [Glyph] {
    let rows = (board.height + 1) / 2
    var glyphs: [Glyph] = []
    var row = 0
    while row < rows {
      var column = 0
      while column < board.width {
        glyphs.append(glyph(board, column: column, row: row, theme: theme))
        column += 1
      }
      row += 1
    }
    return glyphs
  }

  private static func glyph(_ board: Board, column: Int, row: Int, theme: Theme) -> Glyph {
    let top = board.grain(x: column, y: row * 2)
    let bottom = board.grain(x: column, y: row * 2 + 1)
    if top == .empty && bottom == .empty {
      return blank(theme)
    }
    return Glyph(
      shape: .upperHalf,
      foreground: color(top, theme: theme),
      background: color(bottom, theme: theme)
    )
  }

  private static func blank(_ theme: Theme) -> Glyph {
    Glyph(shape: .blank, foreground: theme.ground(), background: theme.ground())
  }

  private static func color(_ grain: Grain, theme: Theme) -> CellColor {
    switch grain {
    case .empty:
      return theme.ground()
    case .sand:
      return Theme.sand
    case .water:
      return Theme.water
    case .oil:
      return Theme.oil
    case .fire:
      return Theme.fire
    case .wood:
      return Theme.wood
    case .lava:
      return Theme.lava
    case .stone:
      return Theme.stone
    }
  }
}
