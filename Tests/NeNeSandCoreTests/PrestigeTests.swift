import NeNeSandCore
import Testing

struct PrestigeTests {
  @Test
  func secondPressResetsThePurseAndRaisesTheRate() {
    let poor = Progression.beginning.holding(pile(3))
    #expect(Prestige.asking(false, progress: poor) == .idle)
    #expect(Prestige.asking(true, progress: poor) == .idle)
    #expect(poor.prestigeCost() == nil)
    let rich = Progression.beginning.holding(pile(3).collecting(.stone))
    #expect(rich.purse.amount == 100)
    #expect(rich.prestigeCost() == 100)
    #expect(Prestige.asking(false, progress: rich) == .armed)
    #expect(rich.purse.rate() == 1)
    let once = committed(rich)
    #expect(once.purse.amount == 0)
    #expect(once.purse.rate() == 2)
    #expect(once.worth(.water) == 4)
    #expect(once.purse.collecting(.water).amount == 4)
    #expect(once.purse.collecting(.water).rate() == 2)
    let twice = committed(once.holding(saved(once.purse, sands: 50)))
    #expect(twice.purse.rate() == 3)
    #expect(twice.worth(.sand) == 3)
  }

  @Test
  func prestigeKeepsMaterialsAndDropsTheFaucet() {
    let bought = Progression.beginning.holding(pile(4).collecting(.oil)).buying(.oil)
    #expect(bought.owns(.oil))
    #expect(bought.purse.amount == 104)
    let kept = committed(bought)
    #expect(kept.owns(.oil))
    #expect(!kept.ownsFaucet())
    #expect(kept.faucetCost() == 60)
    #expect(kept.buying(.oil).purse.amount == 0)
    let faucet = Progression.beginning.holding(pile(5)).buyingFaucet()
    #expect(faucet.ownsFaucet())
    #expect(faucet.purse.amount == 100)
    let dropped = committed(faucet)
    #expect(!dropped.ownsFaucet())
    #expect(dropped.purse.rate() == 2)
  }

  private func committed(_ progress: Progression) -> Progression {
    guard case .done(let next) = Prestige.asking(true, progress: progress) else {
      #expect(Bool(false))
      return progress
    }
    return next
  }

  private func saved(_ purse: Purse, sands: Int) -> Purse {
    var next = purse
    var index = 0
    while index < sands {
      next = next.collecting(.sand)
      index += 1
    }
    return next
  }

  private func pile(_ count: Int) -> Purse {
    var purse = Purse.zero
    var index = 0
    while index < count {
      purse = purse.collecting(.lava)
      index += 1
    }
    return purse
  }
}
