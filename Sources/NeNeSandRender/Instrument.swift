import NeNeSandCore

public enum Instrument {
  public static func top(width: Int, brush: Grain, marks: FramePainter.Marks) -> [Glyph] {
    let wide = width >= Self.namedWidth
    let mode = mode(marks)
    return header(width, marks: marks, wide: wide)
      + meter(width, brush: brush, marks: marks)
      + lamps(width, mode: mode, theme: marks.theme)
  }

  public static func bottom(width: Int, brush: Grain, marks: FramePainter.Marks) -> [Glyph] {
    let mode = mode(marks)
    return status(width, brush: brush, mode: mode, marks: marks)
      + aside(width, brush: brush, mode: mode, theme: marks.theme)
      + help(width, theme: marks.theme)
  }

  private static let namedWidth = 76

  private enum Mode {
    case quiet
    case hold
    case auto
    case free
  }

  private enum Part {
    case text(String, CellColor, CellColor)
    case cells([Glyph])
    case fill(String, CellColor)
  }

  private static func mode(_ marks: FramePainter.Marks) -> Mode {
    if marks.paused {
      return .hold
    }
    if marks.automatic {
      return .auto
    }
    if marks.stone == .free {
      return .free
    }
    return .quiet
  }

  private static func header(_ width: Int, marks: FramePainter.Marks, wide: Bool) -> [Glyph] {
    let ink = marks.theme.chrome
    let sweep: [Part] = [
      .text("-=", ink.frameBright, ink.ground),
      .text("#", ink.accent, ink.ground),
      .text("=-", ink.frameBright, ink.ground),
    ]
    if wide {
      return compose(title(marks.theme) + sweep + tail(marks), width: width, theme: marks.theme)
    }
    let narrow = shortTitle(marks) + sweep
    return compose(
      narrow + [.fill("-", ink.frameBright), .text("  -\\", ink.frameBright, ink.ground)],
      width: width,
      theme: marks.theme
    )
  }

  private static func title(_ theme: Theme) -> [Part] {
    let ink = theme.chrome
    return [
      .text("/-< ", ink.frameBright, ink.ground),
      .text("NENE", ink.paper, ink.ground),
      .text("//", ink.accent, ink.ground),
      .text("SAND", ink.paper, ink.ground),
      .text(" >", ink.frameBright, ink.ground),
    ]
  }

  private static func shortTitle(_ marks: FramePainter.Marks) -> [Part] {
    let ink = marks.theme.chrome
    return [.text("/-< brush ", ink.label, ink.ground)] + gauge(marks.width, theme: marks.theme)
      + [.text(">", ink.frameBright, ink.ground)]
  }

  private static func tail(_ marks: FramePainter.Marks) -> [Part] {
    let ink = marks.theme.chrome
    return [.fill("-", ink.frameBright), .text("  -< brush ", ink.label, ink.ground)]
      + gauge(marks.width, theme: marks.theme)
      + [.text(">-\\", ink.frameBright, ink.ground)]
  }

  private static func meter(_ width: Int, brush: Grain, marks: FramePainter.Marks) -> [Glyph] {
    let ink = marks.theme.chrome
    let wide = width >= namedWidth
    return compose(
      [
        .text("| ", ink.frameBright, ink.ground),
        .cells(palette(brush, marks: marks, wide: wide)),
        .fill(" ", ink.frameBright),
        .text(" |", ink.frameBright, ink.ground),
      ],
      width: width,
      theme: marks.theme
    )
  }

  private static func lamps(_ width: Int, mode: Mode, theme: Theme) -> [Glyph] {
    let ink = theme.chrome
    let scale = width >= namedWidth ? "---:---|" : "---:"
    return compose(
      [
        .text("\\-  -+", ink.frameBright, ink.ground),
        .fill(scale, ink.frameBright),
        .text(" ", ink.ground, ink.ground),
        .cells(lamp("hold", lit: mode == .hold, color: ink.hold, theme: theme)),
        .text("  ", ink.ground, ink.ground),
        .cells(lamp("auto", lit: mode == .auto, color: ink.auto, theme: theme)),
        .text("  ", ink.ground, ink.ground),
        .cells(lamp("free", lit: mode == .free, color: ink.free, theme: theme)),
        .text(" +-/", ink.frameBright, ink.ground),
      ],
      width: width,
      theme: theme
    )
  }

  private static func status(_ width: Int, brush: Grain, mode: Mode, marks: FramePainter.Marks)
    -> [Glyph]
  {
    let theme = marks.theme
    let ink = theme.chrome
    let voice = tone(mode, brush: brush, theme: theme)
    let words = sentence(mode, brush: brush, marks: marks)
    if width >= namedWidth {
      return compose(
        worth(marks) + [
          .text(" >> ", voice, ink.ground),
          .text(tag(mode, brush: brush), voice, ink.ground),
          .text(" :: ", ink.frameBright, ink.ground),
          .text(words, ink.accent, ink.ground),
          .fill(" .", ink.frameBright),
          .cells(hint(mode, theme: theme)),
        ],
        width: width,
        theme: theme
      )
    }
    return compose(
      worth(marks) + [
        .text(">> ", voice, ink.ground),
        .text(tag(mode, brush: brush), voice, ink.ground),
        .text(" " + words, ink.accent, ink.ground),
        .fill(" ", ink.frameBright),
      ],
      width: width,
      theme: theme
    )
  }

  private static func worth(_ marks: FramePainter.Marks) -> [Part] {
    if !marks.earning {
      return []
    }
    let ink = marks.theme.chrome
    var line = " $ " + String(marks.progress.purse.amount)
    if marks.progress.purse.rate() > 1 {
      line += "  x" + String(marks.progress.purse.rate())
    }
    if let ask = marks.progress.faucetCost() {
      line += "  f " + String(ask)
    }
    if !marks.confirming, let ask = marks.progress.prestigeCost() {
      line += "  p " + String(ask)
    }
    return [.text(line, ink.accent, ink.ground)]
  }

  private static func sentence(_ mode: Mode, brush: Grain, marks: FramePainter.Marks) -> String {
    if marks.confirming {
      return "p again resets the board, purse, and faucet."
    }
    return line(mode, brush: brush)
  }

  private static func aside(_ width: Int, brush: Grain, mode: Mode, theme: Theme) -> [Glyph] {
    let ink = theme.chrome
    if width >= namedWidth {
      return compose(
        [
          .text(" // " + joke(mode, brush: brush), ink.label, ink.ground),
          .fill(" ", ink.frameBright),
          .text("_.-^-._.-^-._ ", ink.frameBright, ink.ground),
        ],
        width: width,
        theme: theme
      )
    }
    return compose(
      [.text(" ", ink.ground, ink.ground)] + keyParts(mouseKeys(), theme: theme)
        + [.fill(" ", ink.frameBright)],
      width: width,
      theme: theme
    )
  }

  private static func help(_ width: Int, theme: Theme) -> [Glyph] {
    let ink = theme.chrome
    let pairs = width >= namedWidth ? allKeys(theme) : modeKeys(theme)
    return compose(
      [.text(" ", ink.ground, ink.ground)] + keyParts(pairs, theme: theme)
        + [.fill(" ", ink.frameBright)],
      width: width,
      theme: theme
    )
  }

  private struct Sample {
    let key: String
    let name: String
    let color: CellColor
    let on: Bool
    let shut: Bool
    let tag: String
  }

  private static func palette(_ brush: Grain, marks: FramePainter.Marks, wide: Bool) -> [Glyph] {
    let theme = marks.theme
    return chip(sample("1", .sand, brush: brush, marks: marks), wide: wide, theme: theme)
      + chip(sample("2", .water, brush: brush, marks: marks), wide: wide, theme: theme)
      + chip(sample("3", .oil, brush: brush, marks: marks), wide: wide, theme: theme)
      + chip(sample("4", .fire, brush: brush, marks: marks), wide: wide, theme: theme)
      + chip(sample("5", .wood, brush: brush, marks: marks), wide: wide, theme: theme)
      + chip(sample("6", .lava, brush: brush, marks: marks), wide: wide, theme: theme)
      + chip(sample("7", .stone, brush: brush, marks: marks), wide: wide, theme: theme)
  }

  private static func sample(
    _ key: String,
    _ grain: Grain,
    brush: Grain,
    marks: FramePainter.Marks
  ) -> Sample {
    let shut = closed(grain, marks: marks)
    return Sample(
      key: key,
      name: label(grain, shut: shut, marks: marks),
      color: marks.theme.ink(grain),
      on: brush == grain,
      shut: shut,
      tag: ".."
    )
  }

  private static func closed(_ grain: Grain, marks: FramePainter.Marks) -> Bool {
    if marks.stone == .free {
      return false
    }
    if grain == .stone {
      return marks.stone == .hidden
    }
    if grain == .fire {
      return !marks.fireKnown
    }
    return !marks.progress.owns(grain)
  }

  private static func label(_ grain: Grain, shut: Bool, marks: FramePainter.Marks) -> String {
    if shut, let ask = marks.progress.cost(grain) {
      return String(ask)
    }
    return chipName(grain)
  }

  static func chipName(_ grain: Grain) -> String {
    switch grain {
    case .empty:
      return ""
    case .sand:
      return "sand"
    case .water:
      return "water"
    case .oil:
      return "oil"
    case .fire:
      return "fire"
    case .wood:
      return "wood"
    case .lava:
      return "lava"
    case .stone:
      return "stone"
    }
  }

  private static func chip(_ sample: Sample, wide: Bool, theme: Theme) -> [Glyph] {
    let ink = theme.chrome
    let bed = sample.on ? ink.select : ink.ground
    let sampleCells =
      sample.shut
      ? letters(sample.tag, foreground: ink.label, background: bed) : swatch(sample.color)
    var cells = letters(sample.on ? "[" : " ", foreground: ink.paper, background: ink.ground)
    cells.append(
      contentsOf: letters(sample.key, foreground: keyInk(sample, theme: theme), background: bed))
    cells.append(contentsOf: sampleCells)
    if wide {
      let nameInk = sample.on ? ink.paper : ink.label
      cells.append(contentsOf: letters(" " + sample.name, foreground: nameInk, background: bed))
    }
    cells.append(
      contentsOf: letters(sample.on ? "]" : " ", foreground: ink.paper, background: ink.ground))
    return cells
  }

  private static func keyInk(_ sample: Sample, theme: Theme) -> CellColor {
    if sample.on {
      return theme.chrome.accent
    }
    if sample.shut {
      return theme.chrome.label
    }
    return theme.chrome.paper
  }

  private static func gauge(_ width: Int, theme: Theme) -> [Part] {
    let ink = theme.chrome
    let lit = hashes(width)
    return [
      .text("|", ink.frameBright, ink.ground),
      .text(String(repeating: "#", count: lit), ink.paper, ink.ground),
      .text(String(repeating: ".", count: 3 - lit), ink.frameBright, ink.ground),
      .text("| \(width) ", ink.paper, ink.ground),
    ]
  }

  private static func hashes(_ width: Int) -> Int {
    if width == 5 {
      return 3
    }
    if width == 3 {
      return 2
    }
    return 1
  }

  private static func lamp(_ name: String, lit: Bool, color: CellColor, theme: Theme) -> [Glyph] {
    let ink = theme.chrome
    if lit {
      return letters("#" + name.uppercased(), foreground: color, background: ink.ground)
    }
    return letters(".", foreground: ink.frameBright, background: ink.ground)
      + letters(name, foreground: ink.label, background: ink.ground)
  }

  private static func hint(_ mode: Mode, theme: Theme) -> [Glyph] {
    switch mode {
    case .quiet:
      return []
    case .hold:
      return cue("space", "resume", theme: theme)
    case .auto:
      return cue("a", "stop", theme: theme)
    case .free:
      return cue("m", "leave", theme: theme)
    }
  }

  private static func cue(_ key: String, _ word: String, theme: Theme) -> [Glyph] {
    let ink = theme.chrome
    return letters(" ", foreground: ink.ground, background: ink.ground)
      + letters(key, foreground: ink.paper, background: ink.ground)
      + letters(" " + word, foreground: ink.label, background: ink.ground)
  }

  private static func tone(_ mode: Mode, brush: Grain, theme: Theme) -> CellColor {
    switch mode {
    case .quiet:
      return theme.ink(brush)
    case .hold:
      return theme.chrome.hold
    case .auto:
      return theme.chrome.auto
    case .free:
      return theme.chrome.free
    }
  }

  private static func tag(_ mode: Mode, brush: Grain) -> String {
    switch mode {
    case .quiet:
      return name(brush)
    case .hold:
      return "HOLD"
    case .auto:
      return "AUTO"
    case .free:
      return "FREE"
    }
  }

  private static func line(_ mode: Mode, brush: Grain) -> String {
    switch mode {
    case .quiet:
      return quietLine(brush)
    case .hold:
      return "flow paused. drawing and erasing still work."
    case .auto:
      return "auto draw. each line swaps the material."
    case .free:
      return "free play. 7 draws stone before any reaction."
    }
  }

  private static func joke(_ mode: Mode, brush: Grain) -> String {
    switch mode {
    case .quiet:
      return quietJoke(brush)
    case .hold:
      return "even physics needs a coffee break."
    case .auto:
      return "look ma, no hands."
    case .free:
      return "geology speedrun."
    }
  }

  private static func name(_ grain: Grain) -> String {
    switch grain {
    case .empty:
      return "IDLE"
    case .sand:
      return "SAND"
    case .water:
      return "WATER"
    case .oil:
      return "OIL"
    case .fire:
      return "FIRE"
    case .wood:
      return "WOOD"
    case .lava:
      return "LAVA"
    case .stone:
      return "STONE"
    }
  }

  private static func quietLine(_ grain: Grain) -> String {
    switch grain {
    case .empty:
      return "the brush is empty."
    case .sand:
      return "grains settle where they land."
    case .water:
      return "it finds the low place, then rests."
    case .oil:
      return "it floats. fire and lava want it."
    case .fire:
      return "it rises and dies at 48."
    case .wood:
      return "it stays put, and it burns."
    case .lava:
      return "even ticks only. water makes stone."
    case .stone:
      return "it falls, piles, and stays known."
    }
  }

  private static func quietJoke(_ grain: Grain) -> String {
    switch grain {
    case .empty:
      return "nothing on the pen."
    case .sand:
      return "sand does not do deadlines."
    case .water:
      return "water hates a hill."
    case .oil:
      return "oil keeps its chin up."
    case .fire:
      return "fire works on a short contract."
    case .wood:
      return "wood does not negotiate."
    case .lava:
      return "lava thinks twice."
    case .stone:
      return "stone remembers."
    }
  }

  private static func mouseKeys() -> [(String, String)] {
    [("left", "draw"), ("right", "erase"), ("c", "clear"), ("q", "quit")]
  }

  private static func modeKeys(_ theme: Theme) -> [(String, String)] {
    [
      ("space", "hold"), ("[ ]", "brush"), ("a", "auto"), ("m", "free"), ("t", theme.name()),
      ("k", "codex"), ("p", "again"),
    ]
  }

  private static func allKeys(_ theme: Theme) -> [(String, String)] {
    mouseKeys() + modeKeys(theme)
  }

  private static func keyParts(_ pairs: [(String, String)], theme: Theme) -> [Part] {
    let ink = theme.chrome
    var parts: [Part] = []
    var index = 0
    while index < pairs.count {
      let pair =
        letters(pairs[index].0, foreground: ink.paper, background: ink.ground)
        + letters(" " + pairs[index].1, foreground: ink.label, background: ink.ground)
      parts.append(.cells(pair))
      if index + 1 < pairs.count {
        parts.append(.text("  ", ink.ground, ink.ground))
      }
      index += 1
    }
    return parts
  }

  private static func swatch(_ color: CellColor) -> [Glyph] {
    let cell = Glyph(shape: .blank, foreground: color, background: color)
    return [cell, cell]
  }

  private static func letters(_ text: String, foreground: CellColor, background: CellColor)
    -> [Glyph]
  {
    var cells: [Glyph] = []
    for character in text {
      cells.append(Glyph(shape: .text(character), foreground: foreground, background: background))
    }
    return cells
  }

  private static func compose(_ parts: [Part], width: Int, theme: Theme) -> [Glyph] {
    let room = max(0, width - fixed(parts))
    let fills = fillCount(parts)
    var glyphs: [Glyph] = []
    var fillIndex = 0
    for part in parts {
      if glyphs.count >= width {
        break
      }
      switch part {
      case .text(let text, let foreground, let background):
        take(
          letters(text, foreground: foreground, background: background), into: &glyphs, width: width
        )
      case .cells(let cells):
        take(cells, into: &glyphs, width: width)
      case .fill(let pattern, let ink):
        let count = share(room, fills: fills, index: fillIndex)
        fillIndex += 1
        take(
          painted(pattern, count: count, ink: ink, bed: theme.chrome.ground), into: &glyphs,
          width: width)
      }
    }
    while glyphs.count < width {
      glyphs.append(
        Glyph(shape: .blank, foreground: theme.chrome.ground, background: theme.chrome.ground))
    }
    return glyphs
  }

  private static func fixed(_ parts: [Part]) -> Int {
    var count = 0
    for part in parts {
      switch part {
      case .text(let text, _, _):
        count += text.count
      case .cells(let cells):
        count += cells.count
      case .fill:
        break
      }
    }
    return count
  }

  private static func fillCount(_ parts: [Part]) -> Int {
    var count = 0
    for part in parts {
      switch part {
      case .fill:
        count += 1
      case .text, .cells:
        break
      }
    }
    return count
  }

  private static func share(_ room: Int, fills: Int, index: Int) -> Int {
    if fills == 0 {
      return 0
    }
    return (room / fills) + (index < room % fills ? 1 : 0)
  }

  private static func take(_ cells: [Glyph], into glyphs: inout [Glyph], width: Int) {
    if glyphs.count + cells.count > width {
      return
    }
    glyphs.append(contentsOf: cells)
  }

  private static func painted(_ pattern: String, count: Int, ink: CellColor, bed: CellColor)
    -> [Glyph]
  {
    let chars = Array(pattern)
    var cells: [Glyph] = []
    var index = 0
    while index < count {
      cells.append(
        Glyph(shape: .text(chars[index % chars.count]), foreground: ink, background: bed))
      index += 1
    }
    return cells
  }
}
