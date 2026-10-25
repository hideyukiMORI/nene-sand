import NeNeSandCore
import Testing

struct AutomaticStrokeTests {
  @Test
  func strokeStepsThenLifts() {
    var stroke = AutomaticStroke()
    let first = stroke.next(width: 8, height: 4)
    #expect(first != nil)
    guard let first else {
      return
    }
    var previous = first
    var lifted = false
    var lifts = 0
    var steps = 0
    while steps < 40 {
      let point = stroke.next(width: 8, height: 4)
      if let point {
        #expect(point.x >= 0 && point.x < 8)
        #expect(point.y >= 0 && point.y < 4)
        if !lifted {
          #expect(abs(point.x - previous.x) <= 1)
          #expect(abs(point.y - previous.y) <= 1)
        }
        previous = point
        lifted = false
      } else {
        lifted = true
        lifts += 1
      }
      steps += 1
    }
    #expect(lifts > 0)
  }

  @Test
  func sameStartRepeats() {
    var left = AutomaticStroke()
    var right = AutomaticStroke()
    var index = 0
    while index < 12 {
      #expect(left.next(width: 10, height: 6) == right.next(width: 10, height: 6))
      index += 1
    }
  }

  @Test
  func emptyFieldDrawsNothing() {
    var stroke = AutomaticStroke()
    #expect(stroke.next(width: 0, height: 4) == nil)
    #expect(stroke.next(width: 8, height: 0) == nil)
  }
}
