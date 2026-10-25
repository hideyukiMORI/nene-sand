public enum Grain: Equatable, Sendable {
  case empty
  case sand
  case water

  func slides(bias: Int) -> [Slide] {
    switch self {
    case .empty:
      return []
    case .sand:
      return SandMotion.slides(bias: bias)
    case .water:
      return WaterMotion.slides(bias: bias)
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
    }
  }
}
