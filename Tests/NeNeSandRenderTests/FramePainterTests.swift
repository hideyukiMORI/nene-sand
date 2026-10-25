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
    #expect(frame.glyphs[field].foreground == FramePainter.sand)
    #expect(frame.glyphs[field].background == FramePainter.emptyColor)
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
      (.sand, FramePainter.sand),
      (.water, FramePainter.water),
      (.oil, FramePainter.oil),
      (.fire, FramePainter.fire),
      (.wood, FramePainter.wood),
      (.lava, FramePainter.lava),
      (.stone, FramePainter.stone),
    ]
    for sample in samples {
      var board = Board(width: 1, height: 2)
      board.stamp(x: 0, y: 0, grain: sample.0)
      let frame = FramePainter.paint(board, brush: sample.0)
      #expect(frame.glyphs[FramePainter.topRows].foreground == sample.1)
    }
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
