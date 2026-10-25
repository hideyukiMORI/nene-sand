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
}
