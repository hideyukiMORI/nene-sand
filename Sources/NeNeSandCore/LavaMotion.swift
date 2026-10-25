enum LavaMotion {
  static func moves(on step: Int) -> Bool {
    step % 2 == 0
  }

  static func enters(_ destination: Grain) -> Bool {
    switch destination {
    case .empty:
      return true
    case .lava, .sand, .water, .oil, .fire, .wood, .stone:
      return false
    }
  }
}
