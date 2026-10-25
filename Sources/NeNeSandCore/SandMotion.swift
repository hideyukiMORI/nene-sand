enum SandMotion {
  static func slides(bias: Int) -> [Slide] {
    [
      Slide(dx: 0, dy: 1),
      Slide(dx: bias, dy: 1),
      Slide(dx: -bias, dy: 1),
    ]
  }

  static func enters(_ destination: Grain) -> Bool {
    switch destination {
    case .empty, .water, .oil:
      return true
    case .sand, .fire, .wood:
      return false
    }
  }
}
