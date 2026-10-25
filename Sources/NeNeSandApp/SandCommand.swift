import Foundation
import NeNeSandSave

@main
enum SandCommand {
  static func main() {
    _ = NeNeSandSave.self
    var loop = SandLoop(trueColor: prefersTrueColor())
    loop.run()
  }

  private static func prefersTrueColor() -> Bool {
    let value = ProcessInfo.processInfo.environment["COLORTERM"] ?? ""
    return value == "truecolor" || value == "24bit"
  }
}
