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
  func oilFallsOneCell() {
    var board = Board(width: 1, height: 3)
    board.stamp(x: 0, y: 0, grain: .oil)
    board.tick()
    #expect(board.grain(x: 0, y: 1) == .oil)
    #expect(board.grain(x: 0, y: 0) == .empty)
  }

  @Test
  func oilRestsOnWater() {
    var board = Board(width: 1, height: 2)
    board.stamp(x: 0, y: 0, grain: .oil)
    board.stamp(x: 0, y: 1, grain: .water)
    board.tick()
    #expect(board.grain(x: 0, y: 0) == .oil)
    #expect(board.grain(x: 0, y: 1) == .water)
  }

  @Test
  func waterSinksThroughOil() {
    var board = Board(width: 1, height: 2)
    board.stamp(x: 0, y: 0, grain: .water)
    board.stamp(x: 0, y: 1, grain: .oil)
    board.tick()
    #expect(board.grain(x: 0, y: 0) == .oil)
    #expect(board.grain(x: 0, y: 1) == .water)
  }

  @Test
  func sandSinksThroughOil() {
    var board = Board(width: 1, height: 2)
    board.stamp(x: 0, y: 0, grain: .sand)
    board.stamp(x: 0, y: 1, grain: .oil)
    board.tick()
    #expect(board.grain(x: 0, y: 0) == .oil)
    #expect(board.grain(x: 0, y: 1) == .sand)
  }

  @Test
  func oilRestsOnSand() {
    var board = Board(width: 1, height: 2)
    board.stamp(x: 0, y: 0, grain: .oil)
    board.stamp(x: 0, y: 1, grain: .sand)
    board.tick()
    #expect(board.grain(x: 0, y: 0) == .oil)
    #expect(board.grain(x: 0, y: 1) == .sand)
  }

  @Test
  func oilFlowsLeftOnEvenTick() {
    var board = Board(width: 3, height: 2)
    board.stamp(x: 1, y: 1, grain: .oil)
    board.tick()
    #expect(board.grain(x: 0, y: 1) == .oil)
    #expect(board.grain(x: 1, y: 1) == .empty)
  }

  @Test
  func flatOilStaysStill() {
    var board = Board(width: 4, height: 3)
    var x = 0
    while x < 4 {
      board.stamp(x: x, y: 1, grain: .oil)
      board.stamp(x: x, y: 2, grain: .sand)
      x += 1
    }
    board.tick()
    board.tick()
    x = 0
    while x < 4 {
      #expect(board.grain(x: x, y: 1) == .oil)
      #expect(board.grain(x: x, y: 0) == .empty)
      x += 1
    }
  }

  @Test
  func oilMoundLevelsAndRests() {
    var board = Board(width: 7, height: 6)
    var x = 0
    while x < 7 {
      board.stamp(x: x, y: 5, grain: .sand)
      x += 1
    }
    board.stamp(x: 2, y: 4, grain: .oil)
    board.stamp(x: 3, y: 4, grain: .oil)
    board.stamp(x: 4, y: 4, grain: .oil)
    board.stamp(x: 3, y: 3, grain: .oil)
    let oil = board.count(of: .oil)
    var tickCount = 0
    while tickCount < 30 {
      board.tick()
      tickCount += 1
    }
    let rested = grains(board)
    board.tick()
    #expect(grains(board) == rested)
    #expect(board.grain(x: 3, y: 3) == .empty)
    #expect(board.count(of: .oil) == oil)
  }

  @Test
  func flatOilOnWaterStaysLevel() {
    var board = Board(width: 5, height: 4)
    var x = 0
    while x < 5 {
      board.stamp(x: x, y: 1, grain: .oil)
      board.stamp(x: x, y: 2, grain: .water)
      board.stamp(x: x, y: 3, grain: .sand)
      x += 1
    }
    board.tick()
    board.tick()
    x = 0
    while x < 5 {
      #expect(board.grain(x: x, y: 1) == .oil)
      #expect(board.grain(x: x, y: 2) == .water)
      x += 1
    }
  }

  @Test
  func oilWaterBoundaryLevels() {
    var board = Board(width: 6, height: 5)
    var x = 0
    while x < 6 {
      board.stamp(x: x, y: 1, grain: .oil)
      board.stamp(x: x, y: 3, grain: .water)
      board.stamp(x: x, y: 4, grain: .sand)
      x += 1
    }
    board.stamp(x: 0, y: 2, grain: .oil)
    board.stamp(x: 1, y: 2, grain: .oil)
    board.stamp(x: 2, y: 2, grain: .water)
    board.stamp(x: 3, y: 2, grain: .water)
    board.stamp(x: 4, y: 2, grain: .oil)
    board.stamp(x: 5, y: 2, grain: .oil)
    let oil = board.count(of: .oil)
    let water = board.count(of: .water)
    var tickCount = 0
    while tickCount < 40 {
      board.tick()
      tickCount += 1
    }
    let rested = grains(board)
    board.tick()
    #expect(grains(board) == rested)
    #expect(board.count(of: .oil) == oil)
    #expect(board.count(of: .water) == water)
    #expect(boundarySpread(board) <= 1)
  }

  private func boundarySpread(_ board: Board) -> Int {
    var low = board.height
    var high = 0
    var found = false
    var x = 0
    while x < board.width {
      var y = 0
      var seenOil = false
      while y < board.height {
        let grain = board.grain(x: x, y: y)
        if grain == .oil {
          seenOil = true
        }
        if grain == .water && seenOil {
          found = true
          if y < low {
            low = y
          }
          if y > high {
            high = y
          }
          break
        }
        y += 1
      }
      x += 1
    }
    if !found {
      return 0
    }
    return high - low
  }

  @Test
  func oilWaterAndSandKeepTheirCounts() {
    var board = Board(width: 5, height: 6)
    board.stamp(x: 2, y: 0, grain: .sand)
    board.stamp(x: 2, y: 1, grain: .oil)
    board.stamp(x: 1, y: 4, grain: .water)
    board.stamp(x: 3, y: 2, grain: .oil)
    for _ in 0..<16 {
      board.tick()
    }
    #expect(board.count(of: .sand) == 1)
    #expect(board.count(of: .water) == 1)
    #expect(board.count(of: .oil) == 2)
  }

  @Test
  func flatWaterStaysStill() {
    var board = Board(width: 6, height: 3)
    var x = 0
    while x < 6 {
      board.stamp(x: x, y: 1, grain: .water)
      board.stamp(x: x, y: 2, grain: .sand)
      x += 1
    }
    board.tick()
    board.tick()
    x = 0
    while x < 6 {
      #expect(board.grain(x: x, y: 1) == .water)
      #expect(board.grain(x: x, y: 0) == .empty)
      x += 1
    }
  }

  @Test
  func waterMoundLevelsAndRests() {
    var board = Board(width: 9, height: 8)
    var x = 0
    while x < 9 {
      board.stamp(x: x, y: 7, grain: .sand)
      x += 1
    }
    var y = 4
    while y <= 6 {
      let reach = y - 4
      x = 4 - reach
      while x <= 4 + reach {
        board.stamp(x: x, y: y, grain: .water)
        x += 1
      }
      y += 1
    }
    let water = board.count(of: .water)
    var tickCount = 0
    while tickCount < 40 {
      board.tick()
      tickCount += 1
    }
    let rested = grains(board)
    board.tick()
    #expect(grains(board) == rested)
    #expect(board.grain(x: 4, y: 4) == .empty)
    #expect(board.count(of: .water) == water)
  }

  private func grains(_ board: Board) -> [Grain] {
    var copied: [Grain] = []
    var y = 0
    while y < board.height {
      var x = 0
      while x < board.width {
        copied.append(board.grain(x: x, y: y))
        x += 1
      }
      y += 1
    }
    return copied
  }

  @Test
  func buriedWaterGapCloses() {
    var board = Board(width: 1, height: 4)
    board.stamp(x: 0, y: 0, grain: .water)
    board.stamp(x: 0, y: 3, grain: .water)
    board.tick()
    #expect(board.grain(x: 0, y: 2) == .water)
    #expect(board.grain(x: 0, y: 3) == .water)
    #expect(board.count(of: .water) == 2)
  }

  @Test
  func buriedBarCloses() {
    var board = Board(width: 5, height: 4)
    var x = 0
    while x < 5 {
      board.stamp(x: x, y: 0, grain: .water)
      board.stamp(x: x, y: 3, grain: .sand)
      x += 1
    }
    board.tick()
    x = 0
    while x < 5 {
      #expect(board.grain(x: x, y: 2) == .water)
      #expect(board.grain(x: x, y: 3) == .sand)
      x += 1
    }
    #expect(board.count(of: .water) == 5)
    #expect(board.count(of: .sand) == 5)
  }

  @Test
  func openSandStillFallsOneCell() {
    var board = Board(width: 3, height: 8)
    board.stamp(x: 1, y: 0)
    board.stamp(x: 1, y: 7)
    board.tick()
    #expect(board.grain(x: 1, y: 1) == .sand)
    #expect(board.grain(x: 1, y: 7) == .sand)
    #expect(board.grain(x: 1, y: 2) == .empty)
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
