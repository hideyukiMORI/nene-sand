import NeNeSandTerminal
import Testing

struct MouseParserTests {
  @Test
  func pressDragAndRelease() {
    var parser = MouseParser()
    let pressed = parser.feed(Array("\u{1b}[<0;2;3M".utf8))
    let dragged = parser.feed(Array("\u{1b}[<32;4;3M".utf8))
    let released = parser.feed(Array("\u{1b}[<0;4;3m".utf8))
    #expect(pressed == [.press(Cursor(column: 1, row: 2), .draw)])
    #expect(dragged == [.drag(Cursor(column: 3, row: 2), .draw)])
    #expect(released == [.release(Cursor(column: 3, row: 2), .draw)])
  }

  @Test
  func splitSequenceWaits() {
    var parser = MouseParser()
    #expect(parser.feed(Array("\u{1b}[<0;2;3".utf8)).isEmpty)
    let finished = parser.feed(Array("M".utf8))
    #expect(finished == [.press(Cursor(column: 1, row: 2), .draw)])
  }

  @Test
  func quitBytes() {
    var parser = MouseParser()
    #expect(parser.feed([UInt8(ascii: "q")]) == [.quit])
    #expect(parser.feed([0x03]) == [.quit])
  }

  @Test
  func mTogglesFreePlay() {
    var parser = MouseParser()
    #expect(parser.feed([UInt8(ascii: "m")]) == [.freely])
    #expect(parser.feed([UInt8(ascii: "M")]) == [.freely])
  }

  @Test
  func bracketsChangeTheBrush() {
    var parser = MouseParser()
    #expect(parser.feed([UInt8(ascii: "[")]) == [.brush(-1)])
    #expect(parser.feed([UInt8(ascii: "]")]) == [.brush(1)])
  }

  @Test
  func spacePauses() {
    var parser = MouseParser()
    #expect(parser.feed([UInt8(ascii: " ")]) == [.pause])
  }

  @Test
  func cClearsTheBoard() {
    var parser = MouseParser()
    #expect(parser.feed([UInt8(ascii: "c")]) == [.clear])
    #expect(parser.feed([UInt8(ascii: "C")]) == [.clear])
  }

  @Test
  func fBuysTheFaucet() {
    var parser = MouseParser()
    #expect(parser.feed([UInt8(ascii: "f")]) == [.faucet])
    #expect(parser.feed([UInt8(ascii: "F")]) == [.faucet])
  }

  @Test
  func tCyclesTheTheme() {
    var parser = MouseParser()
    #expect(parser.feed([UInt8(ascii: "t")]) == [.theme])
    #expect(parser.feed([UInt8(ascii: "T")]) == [.theme])
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
    #expect(parser.feed([UInt8(ascii: "5")]) == [.material(.wood)])
    #expect(parser.feed([UInt8(ascii: "6")]) == [.material(.lava)])
    #expect(parser.feed([UInt8(ascii: "7")]) == [.material(.stone)])
  }

  @Test
  func rightClickErases() {
    var parser = MouseParser()
    let pressed = parser.feed(Array("\u{1b}[<2;2;3M".utf8))
    let dragged = parser.feed(Array("\u{1b}[<34;4;3M".utf8))
    let released = parser.feed(Array("\u{1b}[<2;4;3m".utf8))
    #expect(pressed == [.press(Cursor(column: 1, row: 2), .erase)])
    #expect(dragged == [.drag(Cursor(column: 3, row: 2), .erase)])
    #expect(released == [.release(Cursor(column: 3, row: 2), .erase)])
  }

  @Test
  func middleClickIsIgnored() {
    var parser = MouseParser()
    #expect(parser.feed(Array("\u{1b}[<1;1;1M".utf8)).isEmpty)
  }
}
