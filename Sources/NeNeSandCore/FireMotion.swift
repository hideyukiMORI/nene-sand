enum FireMotion {
  static let lifetime = 48

  static func slides(bias: Int) -> [Slide] {
    [
      Slide(dx: bias, dy: -1),
      Slide(dx: 0, dy: -1),
      Slide(dx: -bias, dy: -1),
    ]
  }

  static func enters(_ destination: Grain) -> Bool {
    switch destination {
    case .empty:
      return true
    case .fire, .sand, .water, .oil:
      return false
    }
  }
}
