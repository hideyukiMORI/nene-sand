import NeNeSandCore
import Testing

struct ProgressionTests {
  @Test
  func oilCostsFortyAndIsNotChargedTwice() {
    let poor = Progression.beginning.buying(.oil)
    #expect(!poor.owns(.oil))
    #expect(poor.purse.amount == 0)
    let purse = Purse.zero.collecting(.lava).collecting(.wood)
    let once = Progression.beginning.holding(purse).buying(.oil)
    #expect(once.owns(.oil))
    #expect(once.purse.amount == 0)
    let twice = once.buying(.oil)
    #expect(twice.purse.amount == 0)
    #expect(twice.owns(.oil))
  }

  @Test
  func woodAndLavaHaveTheirPrices() {
    let woodPurse = Purse.zero.collecting(.oil).collecting(.stone)
    let wood = Progression.beginning.holding(woodPurse).buying(.wood)
    #expect(wood.owns(.wood))
    #expect(wood.purse.amount == 0)
    let lavaPurse = Purse.zero.collecting(.lava).collecting(.lava).collecting(.oil)
    let lava = Progression.beginning.holding(lavaPurse).buying(.lava)
    #expect(lava.owns(.lava))
    #expect(lava.purse.amount == 0)
  }

  @Test
  func fireSandAndStoneAreNotForSale() {
    let rich = Progression.beginning.holding(Purse.zero.collecting(.lava).collecting(.lava))
    #expect(rich.buying(.fire).purse.amount == rich.purse.amount)
    #expect(rich.buying(.sand).purse.amount == rich.purse.amount)
    #expect(rich.buying(.stone).purse.amount == rich.purse.amount)
    #expect(!rich.owns(.fire))
    #expect(rich.cost(.oil) == 40)
    #expect(rich.cost(.fire) == nil)
  }

  @Test
  func automaticSkipsWhatIsNotOwned() {
    let start = Progression.beginning
    #expect(start.following(.water) == .sand)
    let wood = start.holding(Purse.zero.collecting(.oil).collecting(.stone)).buying(.wood)
    #expect(wood.following(.water) == .wood)
    #expect(wood.following(.wood) == .sand)
    let oil = start.holding(Purse.zero.collecting(.lava).collecting(.wood)).buying(.oil)
    #expect(oil.following(.water) == .oil)
    #expect(oil.following(.oil) == .sand)
    #expect(oil.following(.oil, fire: true) == .fire)
  }
}
