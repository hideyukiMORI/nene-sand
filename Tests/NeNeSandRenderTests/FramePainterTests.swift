import NeNeSandCore
import NeNeSandRender
import Testing

struct FramePainterTests {
  @Test
  func emptyBoardIsBlank() {
    let frame = FramePainter.paint(Board(width: 2, height: 2), brush: .sand)
    #expect(frame.width == 2)
    #expect(frame.height == 2 + FramePainter.deckRows)
    #expect(frame.glyphs.count == frame.width * frame.height)
    #expect(frame.glyphs[0].shape == .text("砂"))
    #expect(frame.glyphs[1].shape == .gap)
    #expect(frame.glyphs[2].shape == .blank)
    #expect(frame.glyphs[3].shape == .blank)
    #expect(frame.glyphs[4].shape == .text("S"))
    #expect(frame.glyphs[5].shape == .text("A"))
  }

  @Test
  func sandFillsTheUpperHalf() {
    var board = Board(width: 1, height: 2)
    board.stamp(x: 0, y: 0)
    let frame = FramePainter.paint(board, brush: .sand)
    #expect(frame.glyphs[1].shape == .upperHalf)
    #expect(frame.glyphs[1].foreground == FramePainter.sand)
    #expect(frame.glyphs[1].background == FramePainter.emptyColor)
  }

  @Test
  func automaticMarkSitsBesideTheName() {
    let frame = FramePainter.paint(
      Board(width: 6, height: 2),
      brush: .water,
      marks: FramePainter.Marks(automatic: true)
    )
    #expect(frame.glyphs[0].shape == .text("水"))
    #expect(frame.glyphs[1].shape == .gap)
    #expect(frame.glyphs[2].shape == .text("１"))
    #expect(frame.glyphs[4].shape == .text("自"))
    #expect(frame.glyphs[5].shape == .gap)
  }

  @Test
  func automaticMarkIsAbsentByDefault() {
    let frame = FramePainter.paint(Board(width: 6, height: 2), brush: .sand)
    #expect(frame.glyphs[2].shape == .text("１"))
    #expect(frame.glyphs[3].shape == .gap)
    #expect(frame.glyphs[4].shape == .blank)
  }

  @Test
  func stoneMarkSitsBesideTheName() {
    let frame = FramePainter.paint(
      Board(width: 6, height: 2),
      brush: .water,
      marks: FramePainter.Marks(stone: .known)
    )
    #expect(frame.glyphs[2].shape == .text("１"))
    #expect(frame.glyphs[4].shape == .text("石"))
    #expect(frame.glyphs[4].foreground == FramePainter.stone)
    #expect(frame.glyphs[5].shape == .gap)
  }

  @Test
  func stoneMarkFollowsTheAutomaticMark() {
    let frame = FramePainter.paint(
      Board(width: 8, height: 2),
      brush: .water,
      marks: FramePainter.Marks(automatic: true, stone: .known)
    )
    #expect(frame.glyphs[2].shape == .text("１"))
    #expect(frame.glyphs[4].shape == .text("自"))
    #expect(frame.glyphs[6].shape == .text("石"))
    #expect(frame.glyphs[7].shape == .gap)
  }

  @Test
  func pauseMarkFollowsTheOtherMarks() {
    let frame = FramePainter.paint(
      Board(width: 10, height: 2),
      brush: .water,
      marks: FramePainter.Marks(automatic: true, stone: .known, paused: true, width: 5)
    )
    #expect(frame.glyphs[2].shape == .text("５"))
    #expect(frame.glyphs[4].shape == .text("自"))
    #expect(frame.glyphs[6].shape == .text("石"))
    #expect(frame.glyphs[8].shape == .text("停"))
    #expect(frame.glyphs[8].foreground == FramePainter.water)
    #expect(frame.glyphs[9].shape == .gap)
  }

  @Test
  func freePlayShowsStoneAndTheMode() {
    let frame = FramePainter.paint(
      Board(width: 8, height: 2),
      brush: .water,
      marks: FramePainter.Marks(stone: .free)
    )
    #expect(frame.glyphs[2].shape == .text("１"))
    #expect(frame.glyphs[4].shape == .text("石"))
    #expect(frame.glyphs[4].foreground == FramePainter.stone)
    #expect(frame.glyphs[6].shape == .text("遊"))
    #expect(frame.glyphs[6].foreground == FramePainter.water)
    #expect(frame.glyphs[7].shape == .gap)
  }

  @Test
  func stoneNamesTheBrush() {
    var board = Board(width: 1, height: 2)
    board.stamp(x: 0, y: 0, grain: .stone)
    let frame = FramePainter.paint(board, brush: .stone)
    #expect(frame.glyphs[0].shape == .text("石"))
    #expect(frame.glyphs[1].foreground == FramePainter.stone)
  }

  @Test
  func lavaNamesTheBrush() {
    var board = Board(width: 1, height: 2)
    board.stamp(x: 0, y: 0, grain: .lava)
    let frame = FramePainter.paint(board, brush: .lava)
    #expect(frame.glyphs[0].shape == .text("溶"))
    #expect(frame.glyphs[1].foreground == FramePainter.lava)
  }

  @Test
  func woodNamesTheBrush() {
    var board = Board(width: 1, height: 2)
    board.stamp(x: 0, y: 0, grain: .wood)
    let frame = FramePainter.paint(board, brush: .wood)
    #expect(frame.glyphs[0].shape == .text("木"))
    #expect(frame.glyphs[1].foreground == FramePainter.wood)
  }

  @Test
  func fireNamesTheBrush() {
    var board = Board(width: 1, height: 2)
    board.stamp(x: 0, y: 0, grain: .fire)
    let frame = FramePainter.paint(board, brush: .fire)
    #expect(frame.glyphs[0].shape == .text("火"))
    #expect(frame.glyphs[1].foreground == FramePainter.fire)
  }

  @Test
  func oilNamesTheBrush() {
    var board = Board(width: 1, height: 2)
    board.stamp(x: 0, y: 0, grain: .oil)
    let frame = FramePainter.paint(board, brush: .oil)
    #expect(frame.glyphs[0].shape == .text("油"))
    #expect(frame.glyphs[1].foreground == FramePainter.oil)
  }

  @Test
  func waterColorsTheLowerHalf() {
    var board = Board(width: 1, height: 2)
    board.stamp(x: 0, y: 1, grain: .water)
    let frame = FramePainter.paint(board, brush: .water)
    #expect(frame.glyphs[0].shape == .text("水"))
    #expect(frame.glyphs[1].background == FramePainter.water)
  }

  @Test
  func deckSitsUnderTheField() {
    let frame = FramePainter.paint(Board(width: 72, height: 2), brush: .sand)
    let fieldRows = 1
    #expect(frame.height == fieldRows + 1 + FramePainter.deckRows)
    #expect(shown(frame, row: fieldRows + 1).contains("SAND"))
    #expect(shown(frame, row: fieldRows + 1).contains("交渉は短い"))
    #expect(shown(frame, row: fieldRows + 2).contains("1砂"))
    #expect(shown(frame, row: fieldRows + 2).contains("q終"))
    #expect(frame.glyphs[(fieldRows + 1) * frame.width].foreground == FramePainter.phosphor)
  }

  @Test
  func deckPrefersTheModeOverTheMaterial() {
    let paused = FramePainter.paint(
      Board(width: 72, height: 2),
      brush: .sand,
      marks: FramePainter.Marks(paused: true)
    )
    let automatic = FramePainter.paint(
      Board(width: 72, height: 2),
      brush: .sand,
      marks: FramePainter.Marks(automatic: true)
    )
    let free = FramePainter.paint(
      Board(width: 72, height: 2),
      brush: .water,
      marks: FramePainter.Marks(stone: .free)
    )
    #expect(shown(paused, row: 2).contains("HOLD"))
    #expect(shown(automatic, row: 2).contains("AUTO"))
    #expect(shown(free, row: 2).contains("FREE"))
    #expect(shown(free, row: 2).contains("通貨は無い"))
  }

  @Test
  func deckNamesEachBrush() {
    let voices: [(Grain, String)] = [
      (.water, "H2O"),
      (.oil, "OIL"),
      (.fire, "FIRE"),
      (.wood, "WOOD"),
      (.lava, "LAVA"),
      (.stone, "ROCK"),
    ]
    for voice in voices {
      let frame = FramePainter.paint(Board(width: 72, height: 2), brush: voice.0)
      #expect(shown(frame, row: 2).contains(voice.1))
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
