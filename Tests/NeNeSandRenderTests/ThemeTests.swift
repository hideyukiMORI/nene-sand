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
      #expect(sand.red > sand.blue)
      names.append(theme.name())
      theme = theme.next()
    }
    #expect(theme == .phosphor)
    #expect(Set(names).count == 12)
  }
}
