import NeNeSandCore
import NeNeSandRender
import Testing

struct FramePainterTests {
  @Test
  func emptyBoardIsBlank() {
    let frame = FramePainter.paint(Board(width: 2, height: 2))
    #expect(frame.width == 2)
    #expect(frame.height == 1)
    #expect(frame.glyphs.allSatisfy { $0.shape == .blank })
  }

  @Test
  func sandFillsTheUpperHalf() {
    var board = Board(width: 1, height: 2)
    board.stamp(x: 0, y: 0)
    let frame = FramePainter.paint(board)
    #expect(frame.glyphs[0].shape == .upperHalf)
    #expect(frame.glyphs[0].foreground == FramePainter.sand)
    #expect(frame.glyphs[0].background == FramePainter.emptyColor)
  }
}
