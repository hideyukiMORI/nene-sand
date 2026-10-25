public struct Glyph: Equatable, Sendable {
  public enum Shape: Equatable, Sendable {
    case blank
    case upperHalf
    case text(Character)
    case gap
  }

  public let shape: Shape
  public let foreground: CellColor
  public let background: CellColor

  public init(shape: Shape, foreground: CellColor, background: CellColor) {
    self.shape = shape
    self.foreground = foreground
    self.background = background
  }
}
