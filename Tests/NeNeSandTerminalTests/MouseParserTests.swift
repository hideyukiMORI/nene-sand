import NeNeSandTerminal
import Testing

struct MouseParserTests {
  @Test
  func pressDragAndRelease() {
    var parser = MouseParser()
    let pressed = parser.feed(Array("\u{1b}[<0;2;3M".utf8))
    let dragged = parser.feed(Array("\u{1b}[<32;4;3M".utf8))
    let released = parser.feed(Array("\u{1b}[<0;4;3m".utf8))
    #expect(pressed == [.press(Cursor(column: 1, row: 2))])
    #expect(dragged == [.drag(Cursor(column: 3, row: 2))])
    #expect(released == [.release(Cursor(column: 3, row: 2))])
  }

  @Test
  func splitSequenceWaits() {
    var parser = MouseParser()
    #expect(parser.feed(Array("\u{1b}[<0;2;3".utf8)).isEmpty)
    let finished = parser.feed(Array("M".utf8))
    #expect(finished == [.press(Cursor(column: 1, row: 2))])
  }

  @Test
  func quitBytes() {
    var parser = MouseParser()
    #expect(parser.feed([UInt8(ascii: "q")]) == [.quit])
    #expect(parser.feed([0x03]) == [.quit])
  }

  @Test
  func aTogglesAutomatic() {
    var parser = MouseParser()
    #expect(parser.feed([UInt8(ascii: "a")]) == [.automatic])
    #expect(parser.feed([UInt8(ascii: "A")]) == [.automatic])
  }

  @Test
  func digitsChooseMaterials() {
    var parser = MouseParser()
    #expect(parser.feed([UInt8(ascii: "1")]) == [.material(.sand)])
    #expect(parser.feed([UInt8(ascii: "2")]) == [.material(.water)])
    #expect(parser.feed([UInt8(ascii: "3")]) == [.material(.oil)])
    #expect(parser.feed([UInt8(ascii: "4")]) == [.material(.fire)])
  }

  @Test
  func rightClickIsIgnored() {
    var parser = MouseParser()
    #expect(parser.feed(Array("\u{1b}[<2;1;1M".utf8)).isEmpty)
  }
}
