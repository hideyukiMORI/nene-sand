import NeNeSandCore

enum Codex {
  static func glyphs(width: Int, rows: Int, marks: FramePainter.Marks) -> [Glyph] {
    let lines = lines(marks)
    var glyphs: [Glyph] = []
    var row = 0
    while row < rows {
      let text = row < lines.count ? lines[row] : ""
      glyphs.append(contentsOf: paint(text, width: width, marks: marks))
      row += 1
    }
    return glyphs
  }

  private static func lines(_ marks: FramePainter.Marks) -> [String] {
    [
      entry("1", .sand, marks),
      entry("2", .water, marks),
      entry("3", .oil, marks),
      entry("4", .fire, marks),
      entry("5", .wood, marks),
      entry("6", .lava, marks),
      entry("7", .stone, marks),
      faucet(marks),
    ]
  }

  private static func entry(_ key: String, _ grain: Grain, _ marks: FramePainter.Marks) -> String {
    let tail = open(grain, marks) ? String(marks.progress.worth(grain)) : ".."
    return key + " " + Instrument.chipName(grain) + "  " + tail
  }

  private static func faucet(_ marks: FramePainter.Marks) -> String {
    if marks.progress.ownsFaucet() {
      return "f faucet  on"
    }
    return "f faucet  .."
  }

  private static func open(_ grain: Grain, _ marks: FramePainter.Marks) -> Bool {
    if marks.stone == .free {
      return true
    }
    if grain == .fire {
      return marks.fireKnown
    }
    if grain == .stone {
      return marks.stone == .known
    }
    return marks.progress.owns(grain)
  }

  private static func paint(_ text: String, width: Int, marks: FramePainter.Marks) -> [Glyph] {
    let ink = marks.theme.chrome
    var glyphs: [Glyph] = []
    for character in text {
      if glyphs.count == width {
        break
      }
      glyphs.append(
        Glyph(shape: .text(character), foreground: ink.paper, background: ink.ground)
      )
    }
    while glyphs.count < width {
      glyphs.append(
        Glyph(shape: .blank, foreground: ink.ground, background: ink.ground)
      )
    }
    return glyphs
  }
}
