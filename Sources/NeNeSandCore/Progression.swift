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

  public func worth(_ grain: Grain) -> Int {
    Price.of(grain) * purse.rate()
  }

  public func prestigeCost() -> Int? {
    if purse.amount < Prestige.ask {
      return nil
    }
    return Prestige.ask
  }

  func prestiging() -> Progression {
    if purse.amount < Prestige.ask {
      return self
    }
    return Progression(
      purse: purse.paying(purse.amount).quicker(),
      oil: oil,
      wood: wood,
      lava: lava,
      faucet: false
    )
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
    walking(grain, fire: fire, spend: false).grain
  }

  public func advancing(_ grain: Grain, fire: Bool = false) -> (
    progress: Progression, grain: Grain
  ) {
    walking(grain, fire: fire, spend: true)
  }

  private func walking(
    _ grain: Grain,
    fire: Bool,
    spend: Bool
  ) -> (progress: Progression, grain: Grain) {
    var progress = self
    var next = AutomaticStroke.nextBrush(grain)
    var tries = 0
    while tries < 8 && !progress.draws(next, fire: fire) {
      if spend && progress.affordable(next) {
        progress = progress.buying(next)
        break
      }
      next = AutomaticStroke.nextBrush(next)
      tries += 1
    }
    if spend {
      progress = progress.buyingFaucet()
    }
    return (progress, next)
  }

  private func affordable(_ grain: Grain) -> Bool {
    guard let ask = cost(grain) else {
      return false
    }
    return purse.amount >= ask
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
