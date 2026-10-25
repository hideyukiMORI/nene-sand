import NeNeSandCore
import Testing

struct BoardTests {
  @Test
  func sandFallsOneCell() {
    var board = Board(width: 3, height: 4)
    board.stamp(x: 1, y: 0)
    board.tick()
    #expect(board.grain(x: 1, y: 1) == .sand)
    #expect(board.grain(x: 1, y: 0) == .empty)
  }

  @Test
  func eachGrainMovesOnce() {
    var board = Board(width: 1, height: 5)
    board.stamp(x: 0, y: 0)
    board.stamp(x: 0, y: 1)
    board.stamp(x: 0, y: 2)
    board.tick()
    #expect(board.grain(x: 0, y: 0) == .empty)
    #expect(board.grain(x: 0, y: 1) == .sand)
    #expect(board.grain(x: 0, y: 2) == .sand)
    #expect(board.grain(x: 0, y: 3) == .sand)
    #expect(board.grain(x: 0, y: 4) == .empty)
    #expect(board.count(of: .sand) == 3)
  }

  @Test
  func sandStacksOnTheFloor() {
    var board = Board(width: 1, height: 3)
    board.stamp(x: 0, y: 2)
    board.stamp(x: 0, y: 1)
    board.tick()
    #expect(board.grain(x: 0, y: 1) == .sand)
    #expect(board.grain(x: 0, y: 2) == .sand)
    #expect(board.count(of: .sand) == 2)
  }

  @Test
  func evenTickSlidesLeft() {
    var board = Board(width: 3, height: 3)
    board.stamp(x: 1, y: 1)
    board.stamp(x: 1, y: 2)
    board.tick()
    #expect(board.grain(x: 0, y: 2) == .sand)
    #expect(board.grain(x: 1, y: 1) == .empty)
  }

  @Test
  func oddTickSlidesRight() {
    var board = Board(width: 3, height: 3)
    board.tick()
    board.stamp(x: 1, y: 1)
    board.stamp(x: 1, y: 2)
    board.tick()
    #expect(board.grain(x: 2, y: 2) == .sand)
    #expect(board.grain(x: 1, y: 1) == .empty)
  }

  @Test
  func stampOutsideDoesNothing() {
    var board = Board(width: 2, height: 2)
    board.stamp(x: -1, y: 0)
    board.stamp(x: 4, y: 4)
    #expect(board.count(of: .sand) == 0)
  }

  @Test
  func waterFallsOneCell() {
    var board = Board(width: 1, height: 3)
    board.stamp(x: 0, y: 0, grain: .water)
    board.tick()
    #expect(board.grain(x: 0, y: 1) == .water)
    #expect(board.grain(x: 0, y: 0) == .empty)
  }

  @Test
  func waterMovesOncePerTick() {
    var board = Board(width: 1, height: 4)
    board.stamp(x: 0, y: 0, grain: .water)
    board.stamp(x: 0, y: 1, grain: .water)
    board.tick()
    #expect(board.grain(x: 0, y: 0) == .empty)
    #expect(board.grain(x: 0, y: 1) == .water)
    #expect(board.grain(x: 0, y: 2) == .water)
    #expect(board.count(of: .water) == 2)
  }

  @Test
  func waterSlidesDiagonally() {
    var board = Board(width: 3, height: 2)
    board.stamp(x: 1, y: 0, grain: .water)
    board.stamp(x: 1, y: 1, grain: .sand)
    board.tick()
    #expect(board.grain(x: 0, y: 1) == .water)
    #expect(board.grain(x: 1, y: 0) == .empty)
  }

  @Test
  func waterFlowsLeftOnEvenTick() {
    var board = Board(width: 3, height: 2)
    board.stamp(x: 1, y: 1, grain: .water)
    board.tick()
    #expect(board.grain(x: 0, y: 1) == .water)
    #expect(board.grain(x: 1, y: 1) == .empty)
  }

  @Test
  func waterFlowsRightOnOddTick() {
    var board = Board(width: 3, height: 2)
    board.tick()
    board.stamp(x: 1, y: 1, grain: .water)
    board.tick()
    #expect(board.grain(x: 2, y: 1) == .water)
  }

  @Test
  func waterRestsOnSand() {
    var board = Board(width: 1, height: 2)
    board.stamp(x: 0, y: 0, grain: .water)
    board.stamp(x: 0, y: 1, grain: .sand)
    board.tick()
    #expect(board.grain(x: 0, y: 0) == .water)
    #expect(board.grain(x: 0, y: 1) == .sand)
  }

  @Test
  func sandSinksThroughWater() {
    var board = Board(width: 1, height: 2)
    board.stamp(x: 0, y: 0, grain: .sand)
    board.stamp(x: 0, y: 1, grain: .water)
    board.tick()
    #expect(board.grain(x: 0, y: 0) == .water)
    #expect(board.grain(x: 0, y: 1) == .sand)
  }

  @Test
  func sandAndWaterKeepTheirCounts() {
    var board = Board(width: 5, height: 6)
    board.stamp(x: 2, y: 0, grain: .sand)
    board.stamp(x: 2, y: 1, grain: .water)
    board.stamp(x: 1, y: 5, grain: .water)
    for _ in 0..<12 {
      board.tick()
    }
    #expect(board.count(of: .sand) == 1)
    #expect(board.count(of: .water) == 2)
  }

  @Test
  func resizeKeepsWater() {
    var board = Board(width: 2, height: 2)
    board.stamp(x: 0, y: 0, grain: .water)
    let grown = Board(width: 3, height: 2, keeping: board)
    #expect(grown.grain(x: 0, y: 0) == .water)
    #expect(grown.count(of: .water) == 1)
  }

  @Test
  func resizeKeepsOverlap() {
    var board = Board(width: 2, height: 2)
    board.stamp(x: 1, y: 1)
    let grown = Board(width: 3, height: 3, keeping: board)
    #expect(grown.grain(x: 1, y: 1) == .sand)
    #expect(grown.count(of: .sand) == 1)
  }
}
