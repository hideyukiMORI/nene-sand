import NeNeSandCore
import NeNeSandRender
import Testing

struct FramePainterTests {
  @Test
  func emptyBoardKeepsTheFieldUnderTheInstrument() {
    let frame = FramePainter.paint(Board(width: 2, height: 2), brush: .sand)
    #expect(frame.height == 1 + FramePainter.topRows + FramePainter.bottomRows)
    #expect(frame.glyphs.count == frame.width * frame.height)
    #expect(frame.glyphs[FramePainter.topRows * frame.width].shape == .blank)
  }

  @Test
  func sandFillsTheUpperHalf() {
    var board = Board(width: 1, height: 2)
    board.stamp(x: 0, y: 0)
    let frame = FramePainter.paint(board, brush: .sand)
    let field = FramePainter.topRows
    #expect(frame.glyphs[field].shape == .upperHalf)
    #expect(frame.glyphs[field].foreground == Theme.phosphor.ink(.sand))
    #expect(frame.glyphs[field].background == Theme.phosphor.ground())
  }

  @Test
  func quietSandShowsTheEnglishInstrument() {
    let frame = FramePainter.paint(Board(width: 80, height: 2), brush: .sand)
    #expect(shown(frame, row: 0).contains("NENE//SAND"))
    #expect(shown(frame, row: 1).contains("[1"))
    #expect(shown(frame, row: 1).contains("sand"))
    #expect(shown(frame, row: 1).contains("7.."))
    #expect(shown(frame, row: 2).contains(".hold"))
    #expect(shown(frame, row: 4).contains("SAND"))
    #expect(shown(frame, row: 4).contains("grains settle where they land."))
    #expect(shown(frame, row: 5).contains("sand does not do deadlines."))
    #expect(shown(frame, row: 6).contains("q quit"))
  }

  @Test
  func holdAutoAndFreeLightOneLamp() {
    let hold = FramePainter.paint(
      Board(width: 80, height: 2),
      brush: .sand,
      marks: FramePainter.Marks(paused: true, width: 3)
    )
    let automatic = FramePainter.paint(
      Board(width: 80, height: 2),
      brush: .oil,
      marks: FramePainter.Marks(automatic: true)
    )
    let free = FramePainter.paint(
      Board(width: 80, height: 2),
      brush: .water,
      marks: FramePainter.Marks(stone: .free)
    )
    #expect(shown(hold, row: 0).contains("|##.| 3"))
    #expect(shown(hold, row: 2).contains("#HOLD"))
    #expect(shown(hold, row: 5).contains("coffee break"))
    #expect(shown(automatic, row: 2).contains("#AUTO"))
    #expect(shown(automatic, row: 4).contains("AUTO"))
    #expect(shown(free, row: 1).contains("[2"))
    #expect(!shown(free, row: 1).contains("7.."))
    #expect(shown(free, row: 2).contains("#FREE"))
    #expect(shown(free, row: 5).contains("geology speedrun."))
  }

  @Test
  func knownStonePaintsTheSeventhSwatch() {
    let frame = FramePainter.paint(
      Board(width: 80, height: 2),
      brush: .sand,
      marks: FramePainter.Marks(stone: .known)
    )
    #expect(!shown(frame, row: 1).contains("7.."))
    #expect(shown(frame, row: 1).contains("stone"))
  }

  @Test
  func narrowWidthDropsTheTitleAndSplitsTheKeys() {
    let frame = FramePainter.paint(Board(width: 40, height: 2), brush: .sand)
    #expect(!shown(frame, row: 0).contains("NENE"))
    #expect(shown(frame, row: 5).contains("q quit"))
    #expect(shown(frame, row: 6).contains("m free"))
    #expect(!shown(frame, row: 5).contains("deadlines"))
  }

  @Test
  func codexListsSellPricesForWhatIsOpen() {
    let board = Board(width: 20, height: 16)
    let shut = FramePainter.paint(board, brush: .sand, marks: FramePainter.Marks(codex: true))
    #expect(shown(shut, row: 3).contains("1 sand  1"))
    #expect(shown(shut, row: 5).contains("3 oil  .."))
    #expect(shown(shut, row: 9).contains("7 stone  .."))
    #expect(shown(shut, row: 10).contains("f faucet  .."))
    let oil = Progression.beginning.holding(Purse.zero.collecting(.lava).collecting(.wood))
      .buying(.oil)
    let open = FramePainter.paint(
      board,
      brush: .sand,
      marks: FramePainter.Marks(progress: oil, codex: true)
    )
    #expect(shown(open, row: 5).contains("3 oil  16"))
    let free = FramePainter.paint(
      board,
      brush: .sand,
      marks: FramePainter.Marks(stone: .free, codex: true)
    )
    #expect(shown(free, row: 5).contains("3 oil  16"))
    #expect(shown(free, row: 9).contains("7 stone  4"))
  }

  @Test
  func wideHelpNamesTheThemeKey() {
    let frame = FramePainter.paint(Board(width: 100, height: 2), brush: .sand)
    #expect(shown(frame, row: 6).contains("t phosphor"))
    #expect(shown(frame, row: 6).contains("k codex"))
  }

  @Test
  func amberRecolorsTheGroundAndKeepsSand() {
    var board = Board(width: 1, height: 2)
    board.stamp(x: 0, y: 0, grain: .sand)
    let frame = FramePainter.paint(
      board,
      brush: .sand,
      marks: FramePainter.Marks(theme: .amber)
    )
    let field = frame.glyphs[FramePainter.topRows]
    let sand = Theme.amber.ink(.sand)
    let water = Theme.amber.ink(.water)
    #expect(field.foreground == sand)
    #expect(sand != Theme.phosphor.ink(.sand))
    #expect(sand.red > sand.blue)
    #expect(water.blue > water.red)
    #expect(field.background == Theme.amber.ground())
    #expect(Theme.amber.ground() != Theme.phosphor.ground())
    let wide = FramePainter.paint(
      Board(width: 80, height: 2),
      brush: .sand,
      marks: FramePainter.Marks(theme: .amber)
    )
    #expect(wide.glyphs.contains { $0.foreground == Theme.amber.accent() })
  }

  @Test
  func eachBrushNamesItself() {
    let voices: [(Grain, String)] = [
      (.water, "WATER"),
      (.oil, "OIL"),
      (.fire, "FIRE"),
      (.wood, "WOOD"),
      (.lava, "LAVA"),
      (.stone, "STONE"),
    ]
    for voice in voices {
      let frame = FramePainter.paint(Board(width: 80, height: 2), brush: voice.0)
      #expect(shown(frame, row: 4).contains(voice.1))
    }
  }

  @Test
  func materialsColorTheField() {
    let samples: [(Grain, CellColor)] = [
      (.sand, Theme.phosphor.ink(.sand)),
      (.water, Theme.phosphor.ink(.water)),
      (.oil, Theme.phosphor.ink(.oil)),
      (.fire, Theme.phosphor.ink(.fire)),
      (.wood, Theme.phosphor.ink(.wood)),
      (.lava, Theme.phosphor.ink(.lava)),
      (.stone, Theme.phosphor.ink(.stone)),
    ]
    for sample in samples {
      var board = Board(width: 1, height: 2)
      board.stamp(x: 0, y: 0, grain: sample.0)
      let frame = FramePainter.paint(board, brush: sample.0)
      #expect(frame.glyphs[FramePainter.topRows].foreground == sample.1)
    }
  }

  @Test
  func shopShowsThePriceUntilItIsBought() {
    let locked = FramePainter.paint(Board(width: 80, height: 2), brush: .sand)
    let row = shown(locked, row: 1)
    #expect(row.contains("20"))
    #expect(row.contains("40"))
    #expect(row.contains("80"))
    #expect(row.contains("4.."))
    let purse = Purse.zero.collecting(.lava).collecting(.wood)
    let bought = FramePainter.paint(
      Board(width: 80, height: 2),
      brush: .oil,
      marks: FramePainter.Marks(progress: Progression.beginning.holding(purse).buying(.oil))
    )
    let open = shown(bought, row: 1)
    #expect(open.contains("oil"))
    #expect(!open.contains("40"))
    #expect(open.contains("4.."))
    let lit = FramePainter.paint(
      Board(width: 80, height: 2),
      brush: .sand,
      marks: FramePainter.Marks(fireKnown: true)
    )
    let fire = shown(lit, row: 1)
    #expect(fire.contains("fire"))
    #expect(!fire.contains("4.."))
  }

  @Test
  func earningShowsThePurseAndTheMouth() {
    let board = Board(width: 80, height: 2)
    let frame = FramePainter.paint(
      board,
      brush: .sand,
      marks: FramePainter.Marks(
        progress: Progression.beginning.holding(Purse.zero.collecting(.lava)),
        earning: true
      )
    )
    #expect(shown(frame, row: 4).contains("$ 32"))
    #expect(shown(frame, row: 4).contains("f 60"))
    let mouth = FramePainter.topRows * board.width + board.width / 2
    #expect(frame.glyphs[mouth].background == Theme.phosphor.accent())
  }

  @Test
  func ownedFaucetHidesThePriceAndMarksTheSpout() {
    let board = Board(width: 80, height: 2)
    let bought = Progression.beginning.holding(Purse.zero.collecting(.lava).collecting(.lava))
      .buyingFaucet()
    let frame = FramePainter.paint(
      board,
      brush: .sand,
      marks: FramePainter.Marks(progress: bought, earning: true)
    )
    #expect(!shown(frame, row: 4).contains("f 60"))
    let spout = FramePainter.topRows * board.width + board.width / 2
    #expect(frame.glyphs[spout].foreground == Theme.phosphor.accent())
  }

  @Test
  func freePlayHidesThePurse() {
    let frame = FramePainter.paint(
      Board(width: 80, height: 2),
      brush: .sand,
      marks: FramePainter.Marks(
        stone: .free,
        progress: Progression.beginning.holding(Purse.zero.collecting(.oil))
      )
    )
    #expect(!shown(frame, row: 4).contains("$"))
  }

  private func shown(_ frame: Frame, row: Int) -> String {
    var text = ""
    var column = 0
    while column < frame.width {
      let glyph = frame.glyphs[row * frame.width + column]
      switch glyph.shape {
      case .text(let character):
        text.append(character)
      case .blank, .upperHalf, .gap:
        break
      }
      column += 1
    }
    return text
  }
}
