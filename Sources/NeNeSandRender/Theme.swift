import NeNeSandCore

public enum Theme: Equatable, Sendable {
  case phosphor
  case amber
  case plasma
  case arctic
  case crimson
  case toxic
  case cobalt
  case rust
  case orchid
  case slate
  case nectar
  case void

  public func next() -> Theme {
    let following = Self.slot(of: self) + 1
    return Self.book[following % Self.book.count].theme
  }

  public func name() -> String {
    chrome.name
  }

  public func ground() -> CellColor {
    chrome.ground
  }

  public func accent() -> CellColor {
    chrome.accent
  }

  public func ink(_ grain: Grain) -> CellColor {
    switch grain {
    case .empty:
      return ground()
    case .sand:
      return chrome.sand
    case .water:
      return chrome.water
    case .oil:
      return chrome.oil
    case .fire:
      return chrome.fire
    case .wood:
      return chrome.wood
    case .lava:
      return chrome.lava
    case .stone:
      return chrome.stone
    }
  }

  struct Chrome: Equatable {
    let name: String
    let theme: Theme
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
    let sand: CellColor
    let water: CellColor
    let oil: CellColor
    let fire: CellColor
    let wood: CellColor
    let lava: CellColor
    let stone: CellColor
  }

  var chrome: Chrome {
    Self.book[Self.slot(of: self)]
  }

  private static let book: [Chrome] = [
    phosphorChrome(),
    amberChrome(),
    plasmaChrome(),
    arcticChrome(),
    crimsonChrome(),
    toxicChrome(),
    cobaltChrome(),
    rustChrome(),
    orchidChrome(),
    slateChrome(),
    nectarChrome(),
    voidChrome(),
  ]

  private static func slot(of theme: Theme) -> Int {
    if let found = slotBeforeToxic(theme) {
      return found
    }
    if let found = slotBeforeOrchid(theme) {
      return found
    }
    return slotFromOrchid(theme)
  }

  private static func slotBeforeToxic(_ theme: Theme) -> Int? {
    if theme == .phosphor {
      return 0
    }
    if theme == .amber {
      return 1
    }
    if theme == .plasma {
      return 2
    }
    if theme == .arctic {
      return 3
    }
    if theme == .crimson {
      return 4
    }
    return nil
  }

  private static func slotBeforeOrchid(_ theme: Theme) -> Int? {
    if theme == .toxic {
      return 5
    }
    if theme == .cobalt {
      return 6
    }
    if theme == .rust {
      return 7
    }
    return nil
  }

  private static func slotFromOrchid(_ theme: Theme) -> Int {
    if theme == .orchid {
      return 8
    }
    if theme == .slate {
      return 9
    }
    if theme == .nectar {
      return 10
    }
    return 11
  }

  private static func phosphorChrome() -> Chrome {
    Chrome(
      name: "phosphor",
      theme: .phosphor,
      ground: CellColor(red: 16, green: 18, blue: 22),
      frame: CellColor(red: 43, green: 56, blue: 54),
      frameBright: CellColor(red: 65, green: 82, blue: 78),
      label: CellColor(red: 127, green: 163, blue: 154),
      paper: CellColor(red: 220, green: 232, blue: 227),
      accent: CellColor(red: 72, green: 220, blue: 176),
      hold: CellColor(red: 255, green: 181, blue: 71),
      auto: CellColor(red: 92, green: 200, blue: 255),
      free: CellColor(red: 183, green: 156, blue: 255),
      select: CellColor(red: 24, green: 33, blue: 31),
      sand: CellColor(red: 214, green: 176, blue: 92),
      water: CellColor(red: 64, green: 156, blue: 214),
      oil: CellColor(red: 168, green: 124, blue: 36),
      fire: CellColor(red: 228, green: 88, blue: 32),
      wood: CellColor(red: 112, green: 78, blue: 42),
      lava: CellColor(red: 196, green: 48, blue: 24),
      stone: CellColor(red: 132, green: 136, blue: 144)
    )
  }

  private static func amberChrome() -> Chrome {
    Chrome(
      name: "amber",
      theme: .amber,
      ground: CellColor(red: 22, green: 14, blue: 8),
      frame: CellColor(red: 84, green: 52, blue: 22),
      frameBright: CellColor(red: 164, green: 102, blue: 40),
      label: CellColor(red: 214, green: 164, blue: 96),
      paper: CellColor(red: 255, green: 226, blue: 180),
      accent: CellColor(red: 255, green: 176, blue: 48),
      hold: CellColor(red: 255, green: 214, blue: 120),
      auto: CellColor(red: 255, green: 112, blue: 48),
      free: CellColor(red: 255, green: 154, blue: 168),
      select: CellColor(red: 46, green: 28, blue: 12),
      sand: CellColor(red: 236, green: 196, blue: 72),
      water: CellColor(red: 48, green: 128, blue: 200),
      oil: CellColor(red: 168, green: 104, blue: 24),
      fire: CellColor(red: 255, green: 96, blue: 24),
      wood: CellColor(red: 128, green: 76, blue: 36),
      lava: CellColor(red: 208, green: 40, blue: 24),
      stone: CellColor(red: 156, green: 140, blue: 124)
    )
  }

  private static func plasmaChrome() -> Chrome {
    Chrome(
      name: "plasma",
      theme: .plasma,
      ground: CellColor(red: 16, green: 10, blue: 22),
      frame: CellColor(red: 58, green: 40, blue: 72),
      frameBright: CellColor(red: 110, green: 72, blue: 140),
      label: CellColor(red: 186, green: 156, blue: 210),
      paper: CellColor(red: 236, green: 220, blue: 246),
      accent: CellColor(red: 196, green: 120, blue: 255),
      hold: CellColor(red: 255, green: 180, blue: 96),
      auto: CellColor(red: 120, green: 200, blue: 255),
      free: CellColor(red: 255, green: 140, blue: 210),
      select: CellColor(red: 28, green: 16, blue: 36),
      sand: CellColor(red: 236, green: 130, blue: 188),
      water: CellColor(red: 90, green: 80, blue: 240),
      oil: CellColor(red: 140, green: 60, blue: 110),
      fire: CellColor(red: 255, green: 70, blue: 160),
      wood: CellColor(red: 110, green: 50, blue: 90),
      lava: CellColor(red: 220, green: 40, blue: 80),
      stone: CellColor(red: 160, green: 90, blue: 200)
    )
  }

  private static func arcticChrome() -> Chrome {
    Chrome(
      name: "arctic",
      theme: .arctic,
      ground: CellColor(red: 8, green: 16, blue: 22),
      frame: CellColor(red: 36, green: 64, blue: 78),
      frameBright: CellColor(red: 64, green: 120, blue: 140),
      label: CellColor(red: 150, green: 196, blue: 210),
      paper: CellColor(red: 220, green: 240, blue: 246),
      accent: CellColor(red: 120, green: 220, blue: 255),
      hold: CellColor(red: 255, green: 196, blue: 120),
      auto: CellColor(red: 180, green: 255, blue: 230),
      free: CellColor(red: 170, green: 160, blue: 255),
      select: CellColor(red: 12, green: 28, blue: 36),
      sand: CellColor(red: 200, green: 214, blue: 150),
      water: CellColor(red: 40, green: 170, blue: 240),
      oil: CellColor(red: 120, green: 150, blue: 60),
      fire: CellColor(red: 255, green: 176, blue: 90),
      wood: CellColor(red: 60, green: 90, blue: 120),
      lava: CellColor(red: 210, green: 60, blue: 40),
      stone: CellColor(red: 140, green: 180, blue: 200)
    )
  }

  private static func crimsonChrome() -> Chrome {
    Chrome(
      name: "crimson",
      theme: .crimson,
      ground: CellColor(red: 20, green: 8, blue: 10),
      frame: CellColor(red: 78, green: 32, blue: 36),
      frameBright: CellColor(red: 150, green: 56, blue: 64),
      label: CellColor(red: 210, green: 140, blue: 146),
      paper: CellColor(red: 255, green: 220, blue: 220),
      accent: CellColor(red: 255, green: 80, blue: 96),
      hold: CellColor(red: 255, green: 180, blue: 80),
      auto: CellColor(red: 120, green: 190, blue: 255),
      free: CellColor(red: 220, green: 140, blue: 255),
      select: CellColor(red: 36, green: 12, blue: 16),
      sand: CellColor(red: 240, green: 80, blue: 70),
      water: CellColor(red: 70, green: 90, blue: 220),
      oil: CellColor(red: 150, green: 30, blue: 40),
      fire: CellColor(red: 255, green: 50, blue: 40),
      wood: CellColor(red: 100, green: 28, blue: 36),
      lava: CellColor(red: 200, green: 16, blue: 24),
      stone: CellColor(red: 160, green: 80, blue: 90)
    )
  }

  private static func toxicChrome() -> Chrome {
    Chrome(
      name: "toxic",
      theme: .toxic,
      ground: CellColor(red: 12, green: 18, blue: 8),
      frame: CellColor(red: 48, green: 64, blue: 24),
      frameBright: CellColor(red: 96, green: 130, blue: 40),
      label: CellColor(red: 170, green: 196, blue: 100),
      paper: CellColor(red: 230, green: 240, blue: 190),
      accent: CellColor(red: 190, green: 255, blue: 60),
      hold: CellColor(red: 255, green: 200, blue: 70),
      auto: CellColor(red: 80, green: 210, blue: 255),
      free: CellColor(red: 200, green: 140, blue: 255),
      select: CellColor(red: 20, green: 28, blue: 10),
      sand: CellColor(red: 190, green: 230, blue: 50),
      water: CellColor(red: 30, green: 120, blue: 210),
      oil: CellColor(red: 110, green: 150, blue: 20),
      fire: CellColor(red: 220, green: 255, blue: 40),
      wood: CellColor(red: 60, green: 90, blue: 30),
      lava: CellColor(red: 170, green: 50, blue: 20),
      stone: CellColor(red: 120, green: 150, blue: 70)
    )
  }

  private static func cobaltChrome() -> Chrome {
    Chrome(
      name: "cobalt",
      theme: .cobalt,
      ground: CellColor(red: 8, green: 12, blue: 24),
      frame: CellColor(red: 32, green: 48, blue: 90),
      frameBright: CellColor(red: 60, green: 90, blue: 170),
      label: CellColor(red: 150, green: 170, blue: 220),
      paper: CellColor(red: 220, green: 228, blue: 255),
      accent: CellColor(red: 90, green: 140, blue: 255),
      hold: CellColor(red: 255, green: 190, blue: 90),
      auto: CellColor(red: 80, green: 230, blue: 220),
      free: CellColor(red: 190, green: 140, blue: 255),
      select: CellColor(red: 12, green: 18, blue: 40),
      sand: CellColor(red: 240, green: 160, blue: 40),
      water: CellColor(red: 40, green: 110, blue: 255),
      oil: CellColor(red: 40, green: 70, blue: 140),
      fire: CellColor(red: 255, green: 90, blue: 50),
      wood: CellColor(red: 50, green: 60, blue: 110),
      lava: CellColor(red: 200, green: 40, blue: 50),
      stone: CellColor(red: 80, green: 100, blue: 190)
    )
  }

  private static func rustChrome() -> Chrome {
    Chrome(
      name: "rust",
      theme: .rust,
      ground: CellColor(red: 18, green: 10, blue: 8),
      frame: CellColor(red: 90, green: 48, blue: 28),
      frameBright: CellColor(red: 170, green: 80, blue: 40),
      label: CellColor(red: 210, green: 150, blue: 110),
      paper: CellColor(red: 245, green: 210, blue: 180),
      accent: CellColor(red: 220, green: 100, blue: 48),
      hold: CellColor(red: 255, green: 190, blue: 100),
      auto: CellColor(red: 100, green: 180, blue: 220),
      free: CellColor(red: 220, green: 130, blue: 160),
      select: CellColor(red: 36, green: 18, blue: 12),
      sand: CellColor(red: 220, green: 100, blue: 40),
      water: CellColor(red: 40, green: 100, blue: 190),
      oil: CellColor(red: 140, green: 60, blue: 16),
      fire: CellColor(red: 255, green: 70, blue: 16),
      wood: CellColor(red: 80, green: 40, blue: 28),
      lava: CellColor(red: 180, green: 30, blue: 12),
      stone: CellColor(red: 150, green: 80, blue: 60)
    )
  }

  private static func orchidChrome() -> Chrome {
    Chrome(
      name: "orchid",
      theme: .orchid,
      ground: CellColor(red: 20, green: 10, blue: 16),
      frame: CellColor(red: 80, green: 40, blue: 64),
      frameBright: CellColor(red: 160, green: 80, blue: 120),
      label: CellColor(red: 220, green: 160, blue: 190),
      paper: CellColor(red: 255, green: 226, blue: 236),
      accent: CellColor(red: 255, green: 120, blue: 180),
      hold: CellColor(red: 255, green: 196, blue: 110),
      auto: CellColor(red: 120, green: 200, blue: 255),
      free: CellColor(red: 200, green: 140, blue: 255),
      select: CellColor(red: 36, green: 14, blue: 28),
      sand: CellColor(red: 240, green: 120, blue: 170),
      water: CellColor(red: 80, green: 100, blue: 230),
      oil: CellColor(red: 160, green: 50, blue: 100),
      fire: CellColor(red: 255, green: 70, blue: 130),
      wood: CellColor(red: 120, green: 40, blue: 80),
      lava: CellColor(red: 210, green: 30, blue: 70),
      stone: CellColor(red: 180, green: 100, blue: 160)
    )
  }

  private static func slateChrome() -> Chrome {
    Chrome(
      name: "slate",
      theme: .slate,
      ground: CellColor(red: 14, green: 16, blue: 18),
      frame: CellColor(red: 48, green: 54, blue: 60),
      frameBright: CellColor(red: 90, green: 100, blue: 110),
      label: CellColor(red: 160, green: 170, blue: 178),
      paper: CellColor(red: 220, green: 226, blue: 230),
      accent: CellColor(red: 170, green: 190, blue: 200),
      hold: CellColor(red: 230, green: 180, blue: 90),
      auto: CellColor(red: 100, green: 180, blue: 220),
      free: CellColor(red: 180, green: 150, blue: 210),
      select: CellColor(red: 24, green: 28, blue: 32),
      sand: CellColor(red: 168, green: 150, blue: 130),
      water: CellColor(red: 90, green: 120, blue: 160),
      oil: CellColor(red: 90, green: 85, blue: 70),
      fire: CellColor(red: 210, green: 100, blue: 60),
      wood: CellColor(red: 70, green: 68, blue: 64),
      lava: CellColor(red: 160, green: 55, blue: 45),
      stone: CellColor(red: 70, green: 80, blue: 100)
    )
  }

  private static func nectarChrome() -> Chrome {
    Chrome(
      name: "nectar",
      theme: .nectar,
      ground: CellColor(red: 20, green: 16, blue: 8),
      frame: CellColor(red: 80, green: 64, blue: 24),
      frameBright: CellColor(red: 160, green: 130, blue: 40),
      label: CellColor(red: 210, green: 180, blue: 100),
      paper: CellColor(red: 255, green: 236, blue: 190),
      accent: CellColor(red: 255, green: 210, blue: 70),
      hold: CellColor(red: 255, green: 160, blue: 70),
      auto: CellColor(red: 90, green: 190, blue: 230),
      free: CellColor(red: 210, green: 150, blue: 220),
      select: CellColor(red: 36, green: 28, blue: 10),
      sand: CellColor(red: 245, green: 210, blue: 40),
      water: CellColor(red: 40, green: 130, blue: 210),
      oil: CellColor(red: 180, green: 140, blue: 20),
      fire: CellColor(red: 255, green: 160, blue: 20),
      wood: CellColor(red: 120, green: 70, blue: 20),
      lava: CellColor(red: 210, green: 60, blue: 16),
      stone: CellColor(red: 170, green: 140, blue: 60)
    )
  }

  private static func voidChrome() -> Chrome {
    Chrome(
      name: "void",
      theme: .void,
      ground: CellColor(red: 8, green: 8, blue: 10),
      frame: CellColor(red: 36, green: 36, blue: 42),
      frameBright: CellColor(red: 70, green: 70, blue: 80),
      label: CellColor(red: 150, green: 150, blue: 160),
      paper: CellColor(red: 210, green: 210, blue: 216),
      accent: CellColor(red: 200, green: 200, blue: 210),
      hold: CellColor(red: 255, green: 170, blue: 80),
      auto: CellColor(red: 90, green: 180, blue: 255),
      free: CellColor(red: 190, green: 140, blue: 255),
      select: CellColor(red: 16, green: 16, blue: 20),
      sand: CellColor(red: 150, green: 110, blue: 70),
      water: CellColor(red: 40, green: 80, blue: 140),
      oil: CellColor(red: 90, green: 60, blue: 30),
      fire: CellColor(red: 200, green: 70, blue: 40),
      wood: CellColor(red: 60, green: 40, blue: 36),
      lava: CellColor(red: 130, green: 28, blue: 20),
      stone: CellColor(red: 50, green: 52, blue: 60)
    )
  }
}
