public struct Frame: Equatable, Sendable {
  public let width: Int
  public let height: Int
  public let glyphs: [Glyph]

  public init(width: Int, height: Int, glyphs: [Glyph]) {
    self.width = width
    self.height = height
    self.glyphs = glyphs
  }
}
