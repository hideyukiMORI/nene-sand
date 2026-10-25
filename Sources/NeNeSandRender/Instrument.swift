import NeNeSandCore

public enum Instrument {
  public static func top(width: Int, brush: Grain, marks: FramePainter.Marks) -> [Glyph] {
    let wide = width >= Self.namedWidth
    let open = marks.stone != .hidden
    let mode = mode(marks)
    return header(width, marks: marks, wide: wide)
      + meter(width, brush: brush, open: open, wide: wide)
      + lamps(width, mode: mode, wide: wide)
  }

  public static func bottom(width: Int, brush: Grain, marks: FramePainter.Marks) -> [Glyph] {
    let wide = width >= Self.namedWidth
    let mode = mode(marks)
    return status(width, brush: brush, mode: mode, wide: wide)
      + aside(width, brush: brush, mode: mode, wide: wide)
      + help(width, wide: wide)
  }

  private static let namedWidth = 76
  private static let ground = FramePainter.emptyColor
  private static let frame = CellColor(red: 43, green: 56, blue: 54)
  private static let frameBright = CellColor(red: 65, green: 82, blue: 78)
  private static let label = CellColor(red: 127, green: 163, blue: 154)
  private static let paper = CellColor(red: 220, green: 232, blue: 227)
  private static let amber = CellColor(red: 255, green: 181, blue: 71)
  private static let cyan = CellColor(red: 92, green: 200, blue: 255)
  private static let violet = CellColor(red: 183, green: 156, blue: 255)
  private static let select = CellColor(red: 24, green: 33, blue: 31)

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
    let sweep: [Part] = [
      .text("-=", frameBright, ground),
      .text("#", FramePainter.phosphor, ground),
      .text("=-", frameBright, ground),
    ]
    if wide {
      return compose(title() + sweep + tail(marks), width: width)
    }
    return compose(
      shortTitle(marks) + sweep + [.fill("-", frameBright), .text("  -\\", frameBright, ground)],
      width: width)
  }

  private static func title() -> [Part] {
    [
      .text("/-< ", frameBright, ground),
      .text("NENE", paper, ground),
      .text("//", FramePainter.phosphor, ground),
      .text("SAND", paper, ground),
      .text(" >", frameBright, ground),
    ]
  }

  private static func shortTitle(_ marks: FramePainter.Marks) -> [Part] {
    [.text("/-< brush ", label, ground)] + gauge(marks.width) + [.text(">", frameBright, ground)]
  }

  private static func tail(_ marks: FramePainter.Marks) -> [Part] {
    [.fill("-", frameBright), .text("  -< brush ", label, ground)]
      + gauge(marks.width)
      + [.text(">-\\", frameBright, ground)]
  }

  private static func meter(_ width: Int, brush: Grain, open: Bool, wide: Bool) -> [Glyph] {
    compose(
      [
        .text("| ", frameBright, ground),
        .cells(palette(brush, open: open, wide: wide)),
        .fill(" ", frameBright),
        .text(" |", frameBright, ground),
      ], width: width)
  }

  private static func lamps(_ width: Int, mode: Mode, wide: Bool) -> [Glyph] {
    let scale = wide ? "---:---|" : "---:"
    return compose(
      [
        .text("\\-  -+", frameBright, ground),
        .fill(scale, frameBright),
        .text(" ", ground, ground),
        .cells(lamp("hold", lit: mode == .hold, color: amber)),
        .text("  ", ground, ground),
        .cells(lamp("auto", lit: mode == .auto, color: cyan)),
        .text("  ", ground, ground),
        .cells(lamp("free", lit: mode == .free, color: violet)),
        .text(" +-/", frameBright, ground),
      ], width: width)
  }

  private static func status(_ width: Int, brush: Grain, mode: Mode, wide: Bool) -> [Glyph] {
    let ink = tone(mode, brush: brush)
    if wide {
      return compose(
        [
          .text(" >> ", ink, ground),
          .text(tag(mode, brush: brush), ink, ground),
          .text(" :: ", frameBright, ground),
          .text(line(mode, brush: brush), FramePainter.phosphor, ground),
          .fill(" .", frameBright),
          .cells(hint(mode)),
        ], width: width)
    }
    return compose(
      [
        .text(">> ", ink, ground),
        .text(tag(mode, brush: brush), ink, ground),
        .text(" " + line(mode, brush: brush), FramePainter.phosphor, ground),
        .fill(" ", frameBright),
      ], width: width)
  }

  private static func aside(_ width: Int, brush: Grain, mode: Mode, wide: Bool) -> [Glyph] {
    if wide {
      return compose(
        [
          .text(" // " + joke(mode, brush: brush), label, ground),
          .fill(" ", frameBright),
          .text("_.-^-._.-^-._ ", frameBright, ground),
        ], width: width)
    }
    return compose(
      [.text(" ", ground, ground), .cells(keys(mouseKeys())), .fill(" ", frameBright)], width: width
    )
  }

  private static func help(_ width: Int, wide: Bool) -> [Glyph] {
    let shown = wide ? keys(allKeys()) : keys(modeKeys())
    return compose(
      [.text(" ", ground, ground), .cells(shown), .fill(" ", frameBright)], width: width)
  }

  private struct Sample {
    let key: String
    let name: String
    let color: CellColor
    let on: Bool
    let shut: Bool
  }

  private static func palette(_ brush: Grain, open: Bool, wide: Bool) -> [Glyph] {
    chip(
      Sample(key: "1", name: "sand", color: FramePainter.sand, on: brush == .sand, shut: false),
      wide: wide)
      + chip(
        Sample(
          key: "2", name: "water", color: FramePainter.water, on: brush == .water, shut: false),
        wide: wide)
      + chip(
        Sample(key: "3", name: "oil", color: FramePainter.oil, on: brush == .oil, shut: false),
        wide: wide)
      + chip(
        Sample(key: "4", name: "fire", color: FramePainter.fire, on: brush == .fire, shut: false),
        wide: wide)
      + chip(
        Sample(key: "5", name: "wood", color: FramePainter.wood, on: brush == .wood, shut: false),
        wide: wide)
      + chip(
        Sample(key: "6", name: "lava", color: FramePainter.lava, on: brush == .lava, shut: false),
        wide: wide)
      + chip(
        Sample(
          key: "7", name: "stone", color: FramePainter.stone, on: brush == .stone, shut: !open),
        wide: wide)
  }

  private static func chip(_ sample: Sample, wide: Bool) -> [Glyph] {
    let paper = sample.on ? select : ground
    let sampleCells =
      sample.shut ? letters("..", foreground: label, background: paper) : swatch(sample.color)
    var cells = letters(sample.on ? "[" : " ", foreground: Self.paper, background: ground)
    cells.append(contentsOf: letters(sample.key, foreground: keyInk(sample), background: paper))
    cells.append(contentsOf: sampleCells)
    if wide {
      let nameInk = sample.on ? Self.paper : label
      cells.append(contentsOf: letters(" " + sample.name, foreground: nameInk, background: paper))
    }
    cells.append(
      contentsOf: letters(sample.on ? "]" : " ", foreground: Self.paper, background: ground))
    return cells
  }

  private static func keyInk(_ sample: Sample) -> CellColor {
    if sample.on {
      return FramePainter.phosphor
    }
    if sample.shut {
      return label
    }
    return paper
  }

  private static func gauge(_ width: Int) -> [Part] {
    let lit = hashes(width)
    return [
      .text("|", frameBright, ground),
      .text(String(repeating: "#", count: lit), paper, ground),
      .text(String(repeating: ".", count: 3 - lit), frameBright, ground),
      .text("| \(width) ", paper, ground),
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

  private static func lamp(_ name: String, lit: Bool, color: CellColor) -> [Glyph] {
    if lit {
      return letters("#" + name.uppercased(), foreground: color, background: ground)
    }
    return letters(".", foreground: frameBright, background: ground)
      + letters(name, foreground: label, background: ground)
  }

  private static func hint(_ mode: Mode) -> [Glyph] {
    switch mode {
    case .quiet:
      return []
    case .hold:
      return cue("space", "resume")
    case .auto:
      return cue("a", "stop")
    case .free:
      return cue("m", "leave")
    }
  }

  private static func cue(_ key: String, _ word: String) -> [Glyph] {
    letters(" ", foreground: ground, background: ground)
      + letters(key, foreground: paper, background: ground)
      + letters(" " + word, foreground: label, background: ground)
  }

  private static func tone(_ mode: Mode, brush: Grain) -> CellColor {
    switch mode {
    case .quiet:
      return grainColor(brush)
    case .hold:
      return amber
    case .auto:
      return cyan
    case .free:
      return violet
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

  private static func grainColor(_ grain: Grain) -> CellColor {
    switch grain {
    case .empty:
      return ground
    case .sand:
      return FramePainter.sand
    case .water:
      return FramePainter.water
    case .oil:
      return FramePainter.oil
    case .fire:
      return FramePainter.fire
    case .wood:
      return FramePainter.wood
    case .lava:
      return FramePainter.lava
    case .stone:
      return FramePainter.stone
    }
  }

  private static func mouseKeys() -> [(String, String)] {
    [("left", "draw"), ("right", "erase"), ("c", "clear"), ("q", "quit")]
  }

  private static func modeKeys() -> [(String, String)] {
    [("space", "hold"), ("[ ]", "brush"), ("a", "auto"), ("m", "free")]
  }

  private static func allKeys() -> [(String, String)] {
    mouseKeys() + modeKeys()
  }

  private static func keys(_ pairs: [(String, String)]) -> [Glyph] {
    var cells: [Glyph] = []
    var index = 0
    while index < pairs.count {
      cells.append(contentsOf: letters(pairs[index].0, foreground: paper, background: ground))
      cells.append(contentsOf: letters(" " + pairs[index].1, foreground: label, background: ground))
      if index + 1 < pairs.count {
        cells.append(contentsOf: letters("  ", foreground: ground, background: ground))
      }
      index += 1
    }
    return cells
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

  private static func compose(_ parts: [Part], width: Int) -> [Glyph] {
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
        take(painted(pattern, count: count, ink: ink), into: &glyphs, width: width)
      }
    }
    while glyphs.count < width {
      glyphs.append(Glyph(shape: .blank, foreground: ground, background: ground))
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

  private static func painted(_ pattern: String, count: Int, ink: CellColor) -> [Glyph] {
    let chars = Array(pattern)
    var cells: [Glyph] = []
    var index = 0
    while index < count {
      cells.append(
        Glyph(shape: .text(chars[index % chars.count]), foreground: ink, background: ground))
      index += 1
    }
    return cells
  }
}
