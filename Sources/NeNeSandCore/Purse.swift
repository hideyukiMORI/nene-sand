public struct Purse: Equatable, Sendable {
  public let amount: Int

  public static let zero = Purse(amount: 0)

  public func collecting(_ grain: Grain) -> Purse {
    Purse(amount: amount + Price.of(grain) * Self.rate)
  }

  func paying(_ price: Int) -> Purse {
    Purse(amount: amount - price)
  }

  private static let rate = 1

  private init(amount: Int) {
    self.amount = amount
  }
}
