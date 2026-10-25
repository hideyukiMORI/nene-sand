public enum AnsiDiff {
  public static func text(previous: Frame?, next: Frame, trueColor: Bool) -> String {
    var painted = ""
    if needsClear(previous: previous, next: next) {
      painted += "\u{1b}[2J"
    }
    for index in next.glyphs.indices {
      if unchanged(previous: previous, next: next, index: index) {
        continue
      }
      painted += cursor(index: index, width: next.width)
      painted += codes(next.glyphs[index], trueColor: trueColor)
    }
    return painted
  }

  private static func needsClear(previous: Frame?, next: Frame) -> Bool {
    guard let previous else {
      return true
    }
    return previous.width != next.width || previous.height != next.height
  }

  private static func unchanged(previous: Frame?, next: Frame, index: Int) -> Bool {
    guard let previous, previous.width == next.width, previous.height == next.height else {
      return false
    }
    guard index < previous.glyphs.count else {
      return false
    }
    return previous.glyphs[index] == next.glyphs[index]
  }

  private static func cursor(index: Int, width: Int) -> String {
    let row = (index / max(width, 1)) + 1
    let column = (index % max(width, 1)) + 1
    return "\u{1b}[\(row);\(column)H"
  }

  private static func codes(_ glyph: Glyph, trueColor: Bool) -> String {
    let foreground = channel(glyph.foreground, background: false, trueColor: trueColor)
    let background = channel(glyph.background, background: true, trueColor: trueColor)
    return foreground + background + character(glyph)
  }

  private static func character(_ glyph: Glyph) -> String {
    switch glyph.shape {
    case .blank:
      return " "
    case .upperHalf:
      return "▀"
    case .text(let character):
      return String(character)
    case .gap:
      return ""
    }
  }

  private static func channel(_ color: CellColor, background: Bool, trueColor: Bool) -> String {
    let ground = background ? 48 : 38
    if trueColor {
      return "\u{1b}[\(ground);2;\(color.red);\(color.green);\(color.blue)m"
    }
    return "\u{1b}[\(ground);5;\(cube(color))m"
  }

  private static func cube(_ color: CellColor) -> Int {
    let red = band(color.red)
    let green = band(color.green)
    let blue = band(color.blue)
    return 16 + (36 * red) + (6 * green) + blue
  }

  private static func band(_ channel: Int) -> Int {
    let clamped = min(max(channel, 0), 255)
    return (clamped * 5) / 255
  }
}
