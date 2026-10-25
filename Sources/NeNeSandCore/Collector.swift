public enum Collector {
  public struct Gathering {
    public let board: Board
    public let purse: Purse

    public init(board: Board, purse: Purse) {
      self.board = board
      self.purse = purse
    }
  }

  public static func isMouth(x: Int, y: Int, width: Int, height: Int) -> Bool {
    if width <= 0 || height <= 0 {
      return false
    }
    return y == height - 1 && x == width / 2
  }

  public static func gather(_ board: Board, into purse: Purse) -> Gathering {
    var next = board
    var paid = purse
    let mouth = Point(x: board.width / 2, y: board.height - 1)
    if isMouth(x: mouth.x, y: mouth.y, width: board.width, height: board.height) {
      paid = take(mouth, from: &next, into: paid)
    }
    return Gathering(board: next, purse: paid)
  }

  private static func take(_ mouth: Point, from board: inout Board, into purse: Purse) -> Purse {
    let grain = board.grain(x: mouth.x, y: mouth.y)
    if grain == .empty {
      return purse
    }
    board.stamp(x: mouth.x, y: mouth.y, grain: .empty)
    return purse.collecting(grain)
  }
}
