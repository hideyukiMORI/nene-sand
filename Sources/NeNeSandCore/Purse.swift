public struct Purse: Equatable, Sendable {
  public let amount: Int

  public static let zero = Purse(amount: 0)

  public func collecting(_ grain: Grain) -> Purse {
    Purse(amount: amount + Price.of(grain) * multiplier, multiplier: multiplier)
  }

  public func rate() -> Int {
    multiplier
  }

  func paying(_ price: Int) -> Purse {
    Purse(amount: amount - price, multiplier: multiplier)
  }

  func quicker() -> Purse {
    Purse(amount: amount, multiplier: multiplier + 1)
  }

  static func restored(amount: Int, multiplier: Int) -> Purse {
    Purse(amount: amount, multiplier: multiplier)
  }

  private let multiplier: Int

  private init(amount: Int, multiplier: Int = 1) {
    self.amount = amount
    self.multiplier = multiplier
  }
}
