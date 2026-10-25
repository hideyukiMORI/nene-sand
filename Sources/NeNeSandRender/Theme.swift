public enum Theme: Equatable, Sendable {
  case phosphor
  case amber

  public static let sand = CellColor(red: 214, green: 176, blue: 92)
  public static let water = CellColor(red: 64, green: 156, blue: 214)
  public static let oil = CellColor(red: 168, green: 124, blue: 36)
  public static let fire = CellColor(red: 228, green: 88, blue: 32)
  public static let wood = CellColor(red: 112, green: 78, blue: 42)
  public static let lava = CellColor(red: 196, green: 48, blue: 24)
  public static let stone = CellColor(red: 132, green: 136, blue: 144)

  public func next() -> Theme {
    switch self {
    case .phosphor:
      return .amber
    case .amber:
      return .phosphor
    }
  }

  public func ground() -> CellColor {
    chrome.ground
  }

  public func accent() -> CellColor {
    chrome.accent
  }

  struct Chrome: Equatable {
    let ground: CellColor
    let frame: CellColor
    let frameBright: CellColor
    let label: CellColor
    let paper: CellColor
    let accent: CellColor
    let hold: CellColor
    let auto: CellColor
    let free: CellColor
    let select: CellColor
  }

  var chrome: Chrome {
    switch self {
    case .phosphor:
      return Self.phosphorChrome()
    case .amber:
      return Self.amberChrome()
    }
  }

  private static func phosphorChrome() -> Chrome {
    Chrome(
      ground: CellColor(red: 16, green: 18, blue: 22),
      frame: CellColor(red: 43, green: 56, blue: 54),
      frameBright: CellColor(red: 65, green: 82, blue: 78),
      label: CellColor(red: 127, green: 163, blue: 154),
      paper: CellColor(red: 220, green: 232, blue: 227),
      accent: CellColor(red: 72, green: 220, blue: 176),
      hold: CellColor(red: 255, green: 181, blue: 71),
      auto: CellColor(red: 92, green: 200, blue: 255),
      free: CellColor(red: 183, green: 156, blue: 255),
      select: CellColor(red: 24, green: 33, blue: 31)
    )
  }

  private static func amberChrome() -> Chrome {
    Chrome(
      ground: CellColor(red: 22, green: 14, blue: 8),
      frame: CellColor(red: 84, green: 52, blue: 22),
      frameBright: CellColor(red: 164, green: 102, blue: 40),
      label: CellColor(red: 214, green: 164, blue: 96),
      paper: CellColor(red: 255, green: 226, blue: 180),
      accent: CellColor(red: 255, green: 176, blue: 48),
      hold: CellColor(red: 255, green: 214, blue: 120),
      auto: CellColor(red: 255, green: 112, blue: 48),
      free: CellColor(red: 255, green: 154, blue: 168),
      select: CellColor(red: 46, green: 28, blue: 12)
    )
  }
}
