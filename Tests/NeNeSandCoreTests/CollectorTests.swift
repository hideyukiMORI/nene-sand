import NeNeSandCore
import Testing

struct CollectorTests {
  @Test
  func sandReachesTheMouthThenTheNextGatherPays() {
    var board = Board(width: 3, height: 4)
    board.stamp(x: 1, y: 2)
    let waiting = Collector.gather(board, into: .zero)
    #expect(waiting.purse.amount == 0)
    var fallen = waiting.board
    fallen.tick()
    #expect(fallen.grain(x: 1, y: 3) == .sand)
    let paid = Collector.gather(fallen, into: waiting.purse)
    #expect(paid.purse.amount == 1)
    #expect(paid.board.grain(x: 1, y: 3) == .empty)
    #expect(paid.board.count(of: .sand) == 0)
  }

  @Test
  func grainBesideTheMouthStays() {
    var board = Board(width: 3, height: 4)
    board.stamp(x: 0, y: 3, grain: .water)
    let kept = Collector.gather(board, into: .zero)
    #expect(kept.purse.amount == 0)
    #expect(kept.board.grain(x: 0, y: 3) == .water)
  }

  @Test
  func emptyMouthPaysNothing() {
    let board = Board(width: 3, height: 4)
    let kept = Collector.gather(board, into: Purse.zero.collecting(.oil))
    #expect(kept.purse.amount == 16)
    #expect(kept.board.count(of: .empty) == 12)
  }

  @Test
  func eachGrainPaysOnce() {
    var purse = Purse.zero
    purse = purse.collecting(.empty)
    #expect(purse.amount == 0)
    purse = purse.collecting(.sand)
    #expect(purse.amount == 1)
    purse = purse.collecting(.water)
    #expect(purse.amount == 3)
    purse = purse.collecting(.stone)
    #expect(purse.amount == 7)
    purse = purse.collecting(.wood)
    #expect(purse.amount == 15)
    purse = purse.collecting(.oil)
    #expect(purse.amount == 31)
    purse = purse.collecting(.fire)
    #expect(purse.amount == 31)
    purse = purse.collecting(.lava)
    #expect(purse.amount == 63)
  }

  @Test
  func woodOnTheMouthIsSold() {
    var board = Board(width: 3, height: 2)
    board.stamp(x: 1, y: 1, grain: .wood)
    let paid = Collector.gather(board, into: .zero)
    #expect(paid.purse.amount == 8)
    #expect(paid.board.grain(x: 1, y: 1) == .empty)
  }

  @Test
  func fireOnTheMouthVanishesUnpaid() {
    var board = Board(width: 3, height: 2)
    board.stamp(x: 1, y: 1, grain: .fire)
    let paid = Collector.gather(board, into: .zero)
    #expect(paid.purse.amount == 0)
    #expect(paid.board.grain(x: 1, y: 1) == .empty)
  }
}
