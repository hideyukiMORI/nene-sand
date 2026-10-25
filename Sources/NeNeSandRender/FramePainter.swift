import NeNeSandCore

public enum FramePainter {
  public static let sand = CellColor(red: 214, green: 176, blue: 92)
  public static let water = CellColor(red: 64, green: 156, blue: 214)
  public static let oil = CellColor(red: 168, green: 124, blue: 36)
  public static let fire = CellColor(red: 228, green: 88, blue: 32)
  public static let wood = CellColor(red: 112, green: 78, blue: 42)
  public static let lava = CellColor(red: 196, green: 48, blue: 24)
  public static let stone = CellColor(red: 132, green: 136, blue: 144)
  public static let emptyColor = CellColor(red: 16, green: 18, blue: 22)
  public static let phosphor = CellColor(red: 72, green: 220, blue: 176)
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

    public init(
      automatic: Bool = false,
      stone: StoneMark = .hidden,
      paused: Bool = false,
      width: Int = 1
    ) {
      self.automatic = automatic
      self.stone = stone
      self.paused = paused
      self.width = width
    }
  }

  public static func paint(_ board: Board, brush: Grain, marks: Marks = Marks()) -> Frame {
    var glyphs = Instrument.top(width: board.width, brush: brush, marks: marks)
    glyphs.append(contentsOf: field(board))
    glyphs.append(contentsOf: Instrument.bottom(width: board.width, brush: brush, marks: marks))
    let rows = (board.height + 1) / 2
    return Frame(width: board.width, height: rows + topRows + bottomRows, glyphs: glyphs)
  }

  private static func field(_ board: Board) -> [Glyph] {
    let rows = (board.height + 1) / 2
    var glyphs: [Glyph] = []
    var row = 0
    while row < rows {
      var column = 0
      while column < board.width {
        glyphs.append(glyph(board, column: column, row: row))
        column += 1
      }
      row += 1
    }
    return glyphs
  }

  private static func glyph(_ board: Board, column: Int, row: Int) -> Glyph {
    let top = board.grain(x: column, y: row * 2)
    let bottom = board.grain(x: column, y: row * 2 + 1)
    if top == .empty && bottom == .empty {
      return blank()
    }
    return Glyph(
      shape: .upperHalf,
      foreground: color(top),
      background: color(bottom)
    )
  }

  private static func blank() -> Glyph {
    Glyph(shape: .blank, foreground: emptyColor, background: emptyColor)
  }

  private static func color(_ grain: Grain) -> CellColor {
    switch grain {
    case .empty:
      return emptyColor
    case .sand:
      return sand
    case .water:
      return water
    case .oil:
      return oil
    case .fire:
      return fire
    case .wood:
      return wood
    case .lava:
      return lava
    case .stone:
      return stone
    }
  }
}
