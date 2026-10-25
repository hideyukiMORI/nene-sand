public struct Progression: Equatable, Sendable {
  public let purse: Purse

  public static let beginning = Progression(purse: .zero, oil: false, wood: false, lava: false)

  public func holding(_ purse: Purse) -> Progression {
    Progression(purse: purse, oil: oil, wood: wood, lava: lava)
  }

  public func owns(_ grain: Grain) -> Bool {
    switch grain {
    case .sand, .water:
      return true
    case .oil:
      return oil
    case .wood:
      return wood
    case .lava:
      return lava
    case .empty, .fire, .stone:
      return false
    }
  }

  public func cost(_ grain: Grain) -> Int? {
    Price.ask(grain)
  }

  public func buying(_ grain: Grain) -> Progression {
    guard let ask = Price.ask(grain) else {
      return self
    }
    if owns(grain) || purse.amount < ask {
      return self
    }
    return Progression(
      purse: purse.paying(ask),
      oil: oil || grain == .oil,
      wood: wood || grain == .wood,
      lava: lava || grain == .lava
    )
  }

  public func following(_ grain: Grain) -> Grain {
    var next = AutomaticStroke.nextBrush(grain)
    var tries = 0
    while !owns(next) && tries < 8 {
      next = AutomaticStroke.nextBrush(next)
      tries += 1
    }
    return next
  }

  private let oil: Bool
  private let wood: Bool
  private let lava: Bool
}
