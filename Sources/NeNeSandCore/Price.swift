enum Price {
  static func of(_ grain: Grain) -> Int {
    switch grain {
    case .empty:
      return 0
    case .sand:
      return 1
    case .water:
      return 2
    case .stone:
      return 4
    case .wood:
      return 8
    case .oil:
      return 16
    case .fire:
      return 0
    case .lava:
      return 32
    }
  }

  static func ask(_ grain: Grain) -> Int? {
    switch grain {
    case .wood:
      return 20
    case .oil:
      return 40
    case .lava:
      return 80
    case .empty, .sand, .water, .fire, .stone:
      return nil
    }
  }
}
