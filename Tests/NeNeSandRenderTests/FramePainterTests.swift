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
  func waterColorsTheLowerHalf() {
    var board = Board(width: 1, height: 2)
    board.stamp(x: 0, y: 1, grain: .water)
    let frame = FramePainter.paint(board, brush: .water)
    #expect(frame.glyphs[0].shape == .text("水"))
    #expect(frame.glyphs[1].background == FramePainter.water)
  }
}
