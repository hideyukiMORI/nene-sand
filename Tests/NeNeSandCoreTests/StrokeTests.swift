import NeNeSandCore
import Testing

struct StrokeTests {
  @Test
  func horizontalLineHasNoGap() {
    let cells = Stroke.cells(from: Point(x: 0, y: 0), to: Point(x: 5, y: 0))
    #expect(cells.count == 6)
    var previous = cells[0]
    for cell in cells.dropFirst() {
      #expect(abs(cell.x - previous.x) <= 1)
      #expect(abs(cell.y - previous.y) <= 1)
      previous = cell
    }
  }

  @Test
  func diagonalLineReachesTheEnd() {
    let cells = Stroke.cells(from: Point(x: 0, y: 0), to: Point(x: 3, y: 2))
    #expect(cells.first == Point(x: 0, y: 0))
    #expect(cells.last == Point(x: 3, y: 2))
  }
}
