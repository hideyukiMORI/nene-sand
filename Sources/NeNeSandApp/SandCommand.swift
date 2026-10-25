import NeNeSandCore
import NeNeSandRender
import NeNeSandSave
import NeNeSandTerminal

@main
enum SandCommand {
  static func main() {
    _ = NeNeSandCore.self
    _ = NeNeSandSave.self
    _ = NeNeSandRender.self
    _ = NeNeSandTerminal.self
  }
}
