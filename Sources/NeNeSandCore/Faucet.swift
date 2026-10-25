public enum Faucet {
  static let price = 60

  public static func isSpout(x: Int, y: Int, width: Int, height: Int) -> Bool {
    if width <= 0 || height <= 0 {
      return false
    }
    return y == 0 && x == width / 2
  }

  public static func drip(_ board: Board) -> Board {
    let x = board.width / 2
    if !isSpout(x: x, y: 0, width: board.width, height: board.height) {
      return board
    }
    if board.grain(x: x, y: 0) != .empty {
      return board
    }
    var next = board
    next.stamp(x: x, y: 0, grain: .water)
    return next
  }
}
