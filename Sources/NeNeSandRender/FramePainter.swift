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
  public static let phosphorDim = CellColor(red: 48, green: 140, blue: 124)
  public static let deckRows = 2

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
    var glyphs = label(brush, width: board.width, marks: marks)
    glyphs.append(contentsOf: field(board))
    glyphs.append(contentsOf: deck(board.width, brush: brush, marks: marks))
    let rows = (board.height + 1) / 2
    return Frame(width: board.width, height: rows + 1 + deckRows, glyphs: glyphs)
  }

  private static func label(_ brush: Grain, width: Int, marks: Marks) -> [Glyph] {
    let shown = texts(marks)
    var glyphs: [Glyph] = []
    var column = 0
    while column < width {
      glyphs.append(labelGlyph(brush, column: column, shown: shown))
      column += 1
    }
    return glyphs
  }

  private static func texts(_ marks: Marks) -> [Character] {
    var shown: [Character] = [widthMark(marks.width)]
    if marks.automatic {
      shown.append("自")
    }
    switch marks.stone {
    case .hidden:
      break
    case .known:
      shown.append("石")
    case .free:
      shown.append("石")
      shown.append("遊")
    }
    if marks.paused {
      shown.append("停")
    }
    return shown
  }

  private static func labelGlyph(_ brush: Grain, column: Int, shown: [Character]) -> Glyph {
    if column == 0 {
      return Glyph(shape: .text(name(brush)), foreground: color(brush), background: emptyColor)
    }
    if let mark = placed(shown, column: column, brush: brush) {
      return mark
    }
    if column == 1 || isSpacer(column, count: shown.count) {
      return Glyph(shape: .gap, foreground: emptyColor, background: emptyColor)
    }
    return blank()
  }

  private static func placed(_ shown: [Character], column: Int, brush: Grain) -> Glyph? {
    var index = 0
    while index < shown.count {
      if column == 2 + index * 2 {
        let text = shown[index]
        return Glyph(
          shape: .text(text),
          foreground: markColor(text, brush: brush),
          background: emptyColor
        )
      }
      index += 1
    }
    return nil
  }

  private static func widthMark(_ width: Int) -> Character {
    if width == 3 {
      return "３"
    }
    if width == 5 {
      return "５"
    }
    return "１"
  }

  private static func markColor(_ text: Character, brush: Grain) -> CellColor {
    if text == "石" {
      return stone
    }
    return color(brush)
  }

  private static func isSpacer(_ column: Int, count: Int) -> Bool {
    if column < 3 || count == 0 {
      return false
    }
    if column % 2 == 0 {
      return false
    }
    return column <= count * 2 + 1
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
    case .stone:
      return "石"
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
    case .stone:
      return stone
    }
  }

  private static let helpText =
    "1砂 2水 3油 4火 5木 6溶 7石  L描 R消 c全 sp停 []筆 a自 m遊 q終"

  private static func deck(_ width: Int, brush: Grain, marks: Marks) -> [Glyph] {
    var glyphs = line(remark(brush, marks: marks), width: width, ink: phosphor)
    glyphs.append(contentsOf: line(helpText, width: width, ink: phosphorDim))
    return glyphs
  }

  private static func remark(_ brush: Grain, marks: Marks) -> String {
    if marks.paused {
      return "HOLD // 物理は停止。マウスはまだ書ける。"
    }
    if marks.automatic {
      return "AUTO // 筆がひとりで歩く。線ごとに物質が回る。"
    }
    if marks.stone == .free {
      return "FREE // 石を先に開放。このモードに通貨は無い。"
    }
    return voice(brush)
  }

  private static func voice(_ grain: Grain) -> String {
    switch grain {
    case .empty:
      return "IDLE // 筆が空。まだ何も書いていない。"
    case .sand:
      return "SAND // 落ちて積もる。液体より重く、交渉は短い。"
    case .water:
      return "H2O  // 低い方へ流れる。平らになると、往復をやめる。"
    case .oil:
      return "OIL  // 水の上で余裕を見せる。火とは仲が悪い。"
    case .fire:
      return "FIRE // 上へ揺れて、48tickで消える。水が消火器。"
    case .wood:
      return "WOOD // 落ちない固体。燃えることだけは素直。"
    case .lava:
      return "LAVA // 偶数tickだけ歩く。水に触れると石になる。"
    case .stone:
      return "ROCK // 落ちて溜まる。一度覚えたら、盤を縮めても残る。"
    }
  }

  private static func line(_ text: String, width: Int, ink: CellColor) -> [Glyph] {
    var glyphs: [Glyph] = []
    var column = 0
    for character in text {
      let span = columns(character)
      if column + span > width {
        break
      }
      glyphs.append(Glyph(shape: .text(character), foreground: ink, background: emptyColor))
      column += 1
      if span == 2 && column < width {
        glyphs.append(Glyph(shape: .gap, foreground: emptyColor, background: emptyColor))
        column += 1
      }
    }
    while column < width {
      glyphs.append(blank())
      column += 1
    }
    return glyphs
  }

  private static func columns(_ character: Character) -> Int {
    if character.unicodeScalars.allSatisfy({ $0.value < 128 }) {
      return 1
    }
    return 2
  }
}
