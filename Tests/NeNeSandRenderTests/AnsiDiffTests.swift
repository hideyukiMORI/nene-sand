import NeNeSandRender
import Testing

struct AnsiDiffTests {
  @Test
  func firstFrameClears() {
    let frame = Frame(width: 1, height: 1, glyphs: [blank])
    let text = AnsiDiff.text(previous: nil, next: frame, trueColor: true)
    #expect(text.contains("\u{1b}[2J"))
  }

  @Test
  func unchangedFrameIsEmpty() {
    let frame = Frame(width: 1, height: 1, glyphs: [blank])
    let text = AnsiDiff.text(previous: frame, next: frame, trueColor: false)
    #expect(text.isEmpty)
  }

  private var blank: Glyph {
    Glyph(shape: .blank, foreground: FramePainter.emptyColor, background: FramePainter.emptyColor)
  }
}
