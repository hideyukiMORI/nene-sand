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
  func textGlyphIsWritten() {
    let mark = Glyph(
      shape: .text("水"),
      foreground: Theme.phosphor.ink(.water),
      background: Theme.phosphor.ground()
    )
    let frame = Frame(width: 1, height: 1, glyphs: [mark])
    let text = AnsiDiff.text(previous: nil, next: frame, trueColor: true)
    #expect(text.contains("水"))
  }

  @Test
  func unchangedFrameIsEmpty() {
    let frame = Frame(width: 1, height: 1, glyphs: [blank])
    let text = AnsiDiff.text(previous: frame, next: frame, trueColor: false)
    #expect(text.isEmpty)
  }

  private var blank: Glyph {
    Glyph(
      shape: .blank, foreground: Theme.phosphor.ground(), background: Theme.phosphor.ground())
  }
}
