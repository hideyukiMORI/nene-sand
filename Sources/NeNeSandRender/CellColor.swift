public struct CellColor: Equatable, Sendable {
  public let red: Int
  public let green: Int
  public let blue: Int

  public init(red: Int, green: Int, blue: Int) {
    self.red = red
    self.green = green
    self.blue = blue
  }
}
