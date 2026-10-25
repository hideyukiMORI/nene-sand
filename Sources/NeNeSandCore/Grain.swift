public enum Grain: Equatable, Sendable {
  case empty
  case sand
  case water
  case oil
  case fire
  case wood
  case lava
  case stone

  func slides(bias: Int) -> [Slide] {
    switch self {
    case .empty:
      return []
    case .wood:
      return WoodMotion.slides(bias: bias)
    case .sand, .stone:
      return SandMotion.slides(bias: bias)
    case .water, .oil, .lava:
      return LiquidMotion.slides(bias: bias)
    case .fire:
      return FireMotion.slides(bias: bias)
    }
  }

  func enters(_ destination: Grain) -> Bool {
    switch self {
    case .empty:
      return false
    case .sand:
      return SandMotion.enters(destination)
    case .water:
      return WaterMotion.enters(destination)
    case .oil:
      return OilMotion.enters(destination)
    case .fire:
      return FireMotion.enters(destination)
    case .wood:
      return WoodMotion.enters(destination)
    case .lava:
      return LavaMotion.enters(destination)
    case .stone:
      return StoneMotion.enters(destination)
    }
  }

  func flows() -> Bool {
    switch self {
    case .water, .oil, .lava:
      return true
    case .empty, .sand, .fire, .wood, .stone:
      return false
    }
  }
}
