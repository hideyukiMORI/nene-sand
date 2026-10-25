enum StoneMotion {
  static func enters(_ destination: Grain) -> Bool {
    switch destination {
    case .empty, .water, .oil, .lava:
      return true
    case .stone, .sand, .fire, .wood:
      return false
    }
  }
}
