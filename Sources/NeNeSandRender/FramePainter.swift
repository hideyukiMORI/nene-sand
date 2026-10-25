import NeNeSandCore

public enum FramePainter {
  public static let sand = CellColor(red: 214, green: 176, blue: 92)
  public static let water = CellColor(red: 64, green: 156, blue: 214)
  public static let oil = CellColor(red: 168, green: 124, blue: 36)
  public static let fire = CellColor(red: 228, green: 88, blue: 32)
  public static let wood = CellColor(red: 112, green: 78, blue: 42)
  public static let lava = CellColor(red: 196, green: 48, blue: 24)
  public static let emptyColor = CellColor(red: 16, green: 18, blue: 22)

  public static func paint(_ board: Board, brush: Grain, automatic: Bool = false) -> Frame {
    var glyphs = label(brush, width: board.width, automatic: automatic)
    glyphs.append(contentsOf: field(board))
    let rows = (board.height + 1) / 2
    return Frame(width: board.width, height: rows + 1, glyphs: glyphs)
  }

  private static func label(_ brush: Grain, width: Int, automatic: Bool) -> [Glyph] {
    var glyphs: [Glyph] = []
    var column = 0
    while column < width {
      glyphs.append(labelGlyph(brush, column: column, automatic: automatic))
      column += 1
    }
    return glyphs
  }

  private static func labelGlyph(_ brush: Grain, column: Int, automatic: Bool) -> Glyph {
    if column == 0 {
      return Glyph(shape: .text(name(brush)), foreground: color(brush), background: emptyColor)
    }
    if column == 1 || (automatic && column == 3) {
      return Glyph(shape: .gap, foreground: emptyColor, background: emptyColor)
    }
    if automatic && column == 2 {
      return Glyph(shape: .text("自"), foreground: color(brush), background: emptyColor)
    }
    return blank()
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

  private static func name(_ grain: Grain) -> Character {
    switch grain {
    case .empty:
      return " "
    case .sand:
      return "砂"
    case .water:
      return "水"
    case .oil:
      return "油"
    case .fire:
      return "火"
    case .wood:
      return "木"
    case .lava:
      return "溶"
    }
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
    }
  }
}
