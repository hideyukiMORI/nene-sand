public enum Grain: Equatable, Sendable {
  case empty
  case sand
  case water
  case oil
  case fire

  func slides(bias: Int) -> [Slide] {
    switch self {
    case .empty:
      return []
    case .sand:
      return SandMotion.slides(bias: bias)
    case .water, .oil:
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
    }
  }

  func flows() -> Bool {
    switch self {
    case .water, .oil:
      return true
    case .empty, .sand, .fire:
      return false
    }
  }
}
