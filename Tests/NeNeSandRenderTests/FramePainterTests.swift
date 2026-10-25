import NeNeSandCore
import NeNeSandRender
import Testing

struct FramePainterTests {
  @Test
  func emptyBoardIsBlank() {
    let frame = FramePainter.paint(Board(width: 2, height: 2), brush: .sand)
    #expect(frame.width == 2)
    #expect(frame.height == 2)
    #expect(frame.glyphs[0].shape == .text("砂"))
    #expect(frame.glyphs[1].shape == .gap)
    #expect(frame.glyphs[2].shape == .blank)
    #expect(frame.glyphs[3].shape == .blank)
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
      Board(width: 4, height: 2),
      brush: .water,
      marks: FramePainter.Marks(automatic: true)
    )
    #expect(frame.glyphs[0].shape == .text("水"))
    #expect(frame.glyphs[1].shape == .gap)
    #expect(frame.glyphs[2].shape == .text("自"))
    #expect(frame.glyphs[3].shape == .gap)
  }

  @Test
  func automaticMarkIsAbsentByDefault() {
    let frame = FramePainter.paint(Board(width: 4, height: 2), brush: .sand)
    #expect(frame.glyphs[2].shape == .blank)
    #expect(frame.glyphs[3].shape == .blank)
  }

  @Test
  func stoneMarkSitsBesideTheName() {
    let frame = FramePainter.paint(
      Board(width: 4, height: 2),
      brush: .water,
      marks: FramePainter.Marks(stoneKnown: true)
    )
    #expect(frame.glyphs[2].shape == .text("石"))
    #expect(frame.glyphs[2].foreground == FramePainter.stone)
    #expect(frame.glyphs[3].shape == .gap)
  }

  @Test
  func stoneMarkFollowsTheAutomaticMark() {
    let frame = FramePainter.paint(
      Board(width: 6, height: 2),
      brush: .water,
      marks: FramePainter.Marks(automatic: true, stoneKnown: true)
    )
    #expect(frame.glyphs[2].shape == .text("自"))
    #expect(frame.glyphs[4].shape == .text("石"))
    #expect(frame.glyphs[5].shape == .gap)
  }

  @Test
  func pauseMarkFollowsTheOtherMarks() {
    let frame = FramePainter.paint(
      Board(width: 8, height: 2),
      brush: .water,
      marks: FramePainter.Marks(automatic: true, stoneKnown: true, paused: true)
    )
    #expect(frame.glyphs[2].shape == .text("自"))
    #expect(frame.glyphs[4].shape == .text("石"))
    #expect(frame.glyphs[6].shape == .text("停"))
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
}
