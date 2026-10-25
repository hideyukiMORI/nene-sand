public struct Glyph: Equatable, Sendable {
  public enum Shape: Equatable, Sendable {
    case blank
    case upperHalf
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
