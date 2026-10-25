enum LiquidMotion {
  static func slides(bias: Int) -> [Slide] {
    [
      Slide(dx: 0, dy: 1),
      Slide(dx: bias, dy: 1),
      Slide(dx: -bias, dy: 1),
      Slide(dx: bias, dy: 0),
      Slide(dx: -bias, dy: 0),
    ]
  }

  static func canLevel(from surface: Int, toward neighbor: Int) -> Bool {
    neighbor > surface
  }

  static func steep(from surface: Int, toward neighbor: Int) -> Bool {
    neighbor > surface + 1
  }

  static func keepsCourse(drift: Int, dx: Int) -> Bool {
    drift == 0 || drift == dx
  }
}
