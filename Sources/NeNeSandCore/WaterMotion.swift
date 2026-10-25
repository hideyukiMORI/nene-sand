enum WaterMotion {
  static func slides(bias: Int) -> [Slide] {
    [
      Slide(dx: 0, dy: 1),
      Slide(dx: bias, dy: 1),
      Slide(dx: -bias, dy: 1),
      Slide(dx: bias, dy: 0),
      Slide(dx: -bias, dy: 0),
    ]
  }

  static func enters(_ destination: Grain) -> Bool {
    switch destination {
    case .empty:
      return true
    case .water, .sand:
      return false
    }
  }

  static func canLevel(from surface: Int, toward neighbor: Int) -> Bool {
    neighbor > surface
  }

  static func keepsCourse(drift: Int, dx: Int) -> Bool {
    drift == 0 || drift == dx
  }
}
