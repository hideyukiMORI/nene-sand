import NeNeSandCore
import Testing

struct BrushTests {
  @Test
  func oneCellIsTheCenter() {
    let cells = Brush.cells(around: Point(x: 4, y: 5), reach: 0)
    #expect(cells == [Point(x: 4, y: 5)])
  }

  @Test
  func threeByThreeIsCentered() {
    let cells = Brush.cells(around: Point(x: 4, y: 5), reach: 1)
    #expect(cells.count == 9)
    #expect(cells.first == Point(x: 3, y: 4))
    #expect(cells.last == Point(x: 5, y: 6))
  }

  @Test
  func fiveByFiveHasTwentyFiveCells() {
    #expect(Brush.cells(around: Point(x: 0, y: 0), reach: 2).count == 25)
  }
}
