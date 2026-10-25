enum WoodMotion {
  static func slides(bias: Int) -> [Slide] {
    []
  }

  static func enters(_ destination: Grain) -> Bool {
    switch destination {
    case .empty, .sand, .water, .oil, .fire, .wood, .lava, .stone:
      return false
    }
  }
}
