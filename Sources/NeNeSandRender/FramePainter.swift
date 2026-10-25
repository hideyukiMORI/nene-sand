import NeNeSandCore

public enum FramePainter {
  public static let sand = CellColor(red: 214, green: 176, blue: 92)
  public static let emptyColor = CellColor(red: 16, green: 18, blue: 22)

  public static func paint(_ board: Board) -> Frame {
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
    return Frame(width: board.width, height: rows, glyphs: glyphs)
  }

  private static func glyph(_ board: Board, column: Int, row: Int) -> Glyph {
    let top = board.grain(x: column, y: row * 2)
    let bottom = board.grain(x: column, y: row * 2 + 1)
    if top == .empty && bottom == .empty {
      return Glyph(shape: .blank, foreground: emptyColor, background: emptyColor)
    }
    return Glyph(
      shape: .upperHalf,
      foreground: color(top),
      background: color(bottom)
    )
  }

  private static func color(_ grain: Grain) -> CellColor {
    switch grain {
    case .empty:
      return emptyColor
    case .sand:
      return sand
    }
  }
}
