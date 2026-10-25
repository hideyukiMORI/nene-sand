import Foundation
import NeNeSandCore
import NeNeSandSave

enum SaveStore {
  static func opening() -> Archive.Sheet {
    switch place() {
    case .nowhere:
      report("セーブ先が無い")
      return fresh
    case .folder(let folder):
      return loaded(folder + "/save")
    }
  }

  static func closing(_ sheet: Archive.Sheet) {
    switch place() {
    case .nowhere:
      return
    case .folder(let folder):
      write(Archive.text(sheet), to: folder)
    }
  }

  private static let fresh = Archive.Sheet(
    progress: .beginning,
    fireKnown: false,
    stoneKnown: false
  )

  private enum Place {
    case nowhere
    case folder(String)
  }

  private enum Bytes {
    case missing
    case unreadable
    case ready(Data)
  }

  private static func place() -> Place {
    let env = ProcessInfo.processInfo.environment
    if let root = env["XDG_DATA_HOME"], !root.isEmpty {
      return .folder(root + "/nene-sand")
    }
    if let home = env["HOME"], !home.isEmpty {
      return .folder(home + "/.local/share/nene-sand")
    }
    return .nowhere
  }

  private static func loaded(_ path: String) -> Archive.Sheet {
    switch bytes(path) {
    case .missing:
      return fresh
    case .unreadable:
      report("セーブを読めなかったので、新規で始める")
      return fresh
    case .ready(let data):
      return decoded(data)
    }
  }

  private static func bytes(_ path: String) -> Bytes {
    if !FileManager.default.fileExists(atPath: path) {
      return .missing
    }
    do {
      return .ready(try Data(contentsOf: URL(fileURLWithPath: path)))
    } catch {
      return .unreadable
    }
  }

  private static func decoded(_ data: Data) -> Archive.Sheet {
    if let text = String(data: data, encoding: .utf8) {
      switch Archive.reading(text) {
      case .ready(let sheet):
        return sheet
      case .rejected:
        break
      }
    }
    report("セーブを読めなかったので、新規で始める")
    return fresh
  }

  private static func write(_ text: String, to folder: String) {
    let directory = URL(fileURLWithPath: folder)
    let file = directory.appendingPathComponent("save")
    do {
      try FileManager.default.createDirectory(
        at: directory,
        withIntermediateDirectories: true
      )
      try Data(text.utf8).write(to: file, options: .atomic)
    } catch {
      report("セーブを書けなかった")
    }
  }

  private static func report(_ line: String) {
    FileHandle.standardError.write(Data((line + "\n").utf8))
  }
}
