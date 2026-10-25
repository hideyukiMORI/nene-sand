import NeNeSandCore
import Testing

struct FaucetTests {
  @Test
  func dripPutsWaterOnTheEmptySpout() {
    let board = Board(width: 3, height: 2)
    let poured = Faucet.drip(board)
    #expect(poured.grain(x: 1, y: 0) == .water)
    #expect(poured.grain(x: 0, y: 0) == .empty)
  }

  @Test
  func occupiedSpoutIsLeftAlone() {
    var board = Board(width: 3, height: 2)
    board.stamp(x: 1, y: 0, grain: .sand)
    let poured = Faucet.drip(board)
    #expect(poured.grain(x: 1, y: 0) == .sand)
  }
}
