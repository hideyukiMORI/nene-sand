struct Reaction: Equatable {
  let source: Grain
  let target: Grain
  let product: Grain

  static let rows = [
    Reaction(source: .water, target: .fire, product: .empty),
    Reaction(source: .fire, target: .oil, product: .fire),
    Reaction(source: .fire, target: .wood, product: .fire),
  ]
}
