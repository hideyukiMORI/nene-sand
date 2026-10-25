import NeNeSandRender
import Testing

struct ThemeTests {
  @Test
  func twelveThemesReturnToPhosphor() {
    var theme = Theme.phosphor
    var names: [String] = []
    for _ in 0..<12 {
      let water = theme.ink(.water)
      let sand = theme.ink(.sand)
      #expect(water.blue > water.red)
      #expect(water.blue > water.green)
      #expect(sand.red > sand.blue)
      #expect(sum(theme.ink(.sand)) > sum(theme.ink(.oil)))
      #expect(sum(theme.ink(.oil)) > sum(theme.ink(.wood)))
      #expect(sum(theme.ink(.fire)) > sum(theme.ink(.lava)))
      names.append(theme.name())
      theme = theme.next()
    }
    #expect(theme == .phosphor)
    #expect(Set(names).count == 12)
  }

  @Test
  func laterThemesPullTheGrainsOffPhosphor() {
    let plainSand = Theme.phosphor.ink(.sand)
    let plainStone = Theme.phosphor.ink(.stone)
    var theme = Theme.plasma
    for _ in 0..<10 {
      #expect(spread(theme.ink(.sand), plainSand) >= 40)
      #expect(spread(theme.ink(.stone), plainStone) >= 40)
      theme = theme.next()
    }
    #expect(theme == .phosphor)
  }

  private func sum(_ color: CellColor) -> Int {
    color.red + color.green + color.blue
  }

  private func spread(_ left: CellColor, _ right: CellColor) -> Int {
    let red = abs(left.red - right.red)
    let green = abs(left.green - right.green)
    let blue = abs(left.blue - right.blue)
    return max(red, max(green, blue))
  }
}
