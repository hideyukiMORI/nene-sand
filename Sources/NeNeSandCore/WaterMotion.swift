enum WaterMotion {
  static func enters(_ destination: Grain) -> Bool {
    switch destination {
    case .empty, .oil:
      return true
    case .water, .sand, .fire, .wood:
      return false
    }
  }
}
