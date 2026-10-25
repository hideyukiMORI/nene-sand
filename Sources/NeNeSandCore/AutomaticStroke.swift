public struct AutomaticStroke: Sendable {
  private var path: [Point]
  private var index: Int
  private var serial: Int
  private var resting: Bool

  public static func nextBrush(_ grain: Grain) -> Grain {
    switch grain {
    case .sand:
      return .water
    case .water:
      return .oil
    case .oil:
      return .fire
    case .fire:
      return .sand
    case .empty:
      return .sand
    }
  }

  public init() {
    path = []
    index = 0
    serial = 0
    resting = true
  }

  public mutating func next(width: Int, height: Int) -> Point? {
    if width <= 0 || height <= 0 {
      return nil
    }
    if resting {
      resting = false
      begin(width: width, height: height)
      return placed(path[index], width: width, height: height)
    }
    if index + 1 < path.count {
      index += 1
      return placed(path[index], width: width, height: height)
    }
    resting = true
    return nil
  }

  private mutating func begin(width: Int, height: Int) {
    let start = Self.place(serial: serial, width: width, height: height)
    let end = Self.place(serial: serial + 1, width: width, height: height)
    serial += 2
    path = Stroke.cells(from: start, to: end)
    index = 0
  }

  private static func place(serial: Int, width: Int, height: Int) -> Point {
    Point(x: (serial * 7 + 3) % width, y: (serial * 5 + 1) % height)
  }

  private func placed(_ point: Point, width: Int, height: Int) -> Point {
    Point(
      x: min(max(point.x, 0), width - 1),
      y: min(max(point.y, 0), height - 1)
    )
  }
}
