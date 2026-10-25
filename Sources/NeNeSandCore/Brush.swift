public enum Brush {
  public static func cells(around center: Point, reach: Int) -> [Point] {
    var cells: [Point] = []
    var dy = -reach
    while dy <= reach {
      var dx = -reach
      while dx <= reach {
        cells.append(Point(x: center.x + dx, y: center.y + dy))
        dx += 1
      }
      dy += 1
    }
    return cells
  }
}
