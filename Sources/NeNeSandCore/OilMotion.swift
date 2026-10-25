enum OilMotion {
  static func enters(_ destination: Grain) -> Bool {
    switch destination {
    case .empty:
      return true
    case .oil, .water, .sand, .fire, .wood, .lava:
      return false
    }
  }
}
