public enum Stroke {
  public static func cells(from start: Point, to end: Point) -> [Point] {
    var points: [Point] = []
    var x = start.x
    var y = start.y
    let dx = abs(end.x - start.x)
    let dy = abs(end.y - start.y)
    let stepX = start.x < end.x ? 1 : -1
    let stepY = start.y < end.y ? 1 : -1
    var error = dx - dy
    while true {
      points.append(Point(x: x, y: y))
      if x == end.x && y == end.y {
        return points
      }
      let doubled = error * 2
      if doubled > -dy {
        error -= dy
        x += stepX
      }
      if doubled < dx {
        error += dx
        y += stepY
      }
    }
  }
}
