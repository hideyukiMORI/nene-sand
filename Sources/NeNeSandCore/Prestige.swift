public enum Prestige {
  static let ask = 100

  public enum Answer: Equatable, Sendable {
    case idle
    case armed
    case done(Progression)
  }

  public static func asking(_ armed: Bool, progress: Progression) -> Answer {
    if progress.purse.amount < ask {
      return .idle
    }
    if !armed {
      return .armed
    }
    return .done(progress.prestiging())
  }
}
