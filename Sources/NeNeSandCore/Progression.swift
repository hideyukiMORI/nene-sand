public struct Progression: Equatable, Sendable {
  public let purse: Purse

  public static let beginning = Progression(
    purse: .zero,
    oil: false,
    wood: false,
    lava: false,
    faucet: false
  )

  public func holding(_ purse: Purse) -> Progression {
    Progression(purse: purse, oil: oil, wood: wood, lava: lava, faucet: faucet)
  }

  public func ownsFaucet() -> Bool {
    faucet
  }

  public func faucetCost() -> Int? {
    if faucet {
      return nil
    }
    return Faucet.price
  }

  public func buyingFaucet() -> Progression {
    if faucet || purse.amount < Faucet.price {
      return self
    }
    return Progression(
      purse: purse.paying(Faucet.price),
      oil: oil,
      wood: wood,
      lava: lava,
      faucet: true
    )
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
      lava: lava || grain == .lava,
      faucet: faucet
    )
  }

  public func following(_ grain: Grain, fire: Bool = false) -> Grain {
    var next = AutomaticStroke.nextBrush(grain)
    var tries = 0
    while !draws(next, fire: fire) && tries < 8 {
      next = AutomaticStroke.nextBrush(next)
      tries += 1
    }
    return next
  }

  private func draws(_ grain: Grain, fire: Bool) -> Bool {
    if grain == .fire {
      return fire
    }
    return owns(grain)
  }

  private let oil: Bool
  private let wood: Bool
  private let lava: Bool
  private let faucet: Bool
}
