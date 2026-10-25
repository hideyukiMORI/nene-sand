import NeNeSandCore

public enum Archive {
  public struct Sheet: Equatable, Sendable {
    public let progress: Progression
    public let fireKnown: Bool
    public let stoneKnown: Bool

    public init(progress: Progression, fireKnown: Bool, stoneKnown: Bool) {
      self.progress = progress
      self.fireKnown = fireKnown
      self.stoneKnown = stoneKnown
    }
  }

  public enum Outcome: Equatable, Sendable {
    case ready(Sheet)
    case rejected
  }

  public static func text(_ sheet: Sheet) -> String {
    let progress = sheet.progress
    let lines = [
      "nene-sand 1",
      "amount \(progress.purse.amount)",
      "rate \(progress.purse.rate())",
      "oil \(bit(progress.owns(.oil)))",
      "wood \(bit(progress.owns(.wood)))",
      "lava \(bit(progress.owns(.lava)))",
      "faucet \(bit(progress.ownsFaucet()))",
      "fire \(bit(sheet.fireKnown))",
      "stone \(bit(sheet.stoneKnown))",
    ]
    return lines.joined(separator: "\n") + "\n"
  }

  public static func reading(_ text: String) -> Outcome {
    switch rows(text) {
    case .rejected:
      return .rejected
    case .ready(let lines):
      switch numbers(lines) {
      case .rejected:
        return .rejected
      case .ready(let values):
        return sheet(values)
      }
    }
  }

  private static let keys = [
    "amount", "rate", "oil", "wood", "lava", "faucet", "fire", "stone",
  ]

  private enum Rows {
    case ready([String])
    case rejected
  }

  private enum Numbers {
    case ready([Int])
    case rejected
  }

  private enum One {
    case ready(Int)
    case rejected
  }

  private static func bit(_ on: Bool) -> String {
    if on {
      return "1"
    }
    return "0"
  }

  private static func rows(_ text: String) -> Rows {
    if !text.hasSuffix("\n") || text.contains("\r") {
      return .rejected
    }
    let body = String(text.dropLast())
    if body.isEmpty {
      return .rejected
    }
    let lines = body.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
    return .ready(lines)
  }

  private static func numbers(_ lines: [String]) -> Numbers {
    if lines.count != keys.count + 1 || lines[0] != "nene-sand 1" {
      return .rejected
    }
    var values: [Int] = []
    var index = 0
    while index < keys.count {
      switch field(lines[index + 1], key: keys[index]) {
      case .ready(let value):
        values.append(value)
      case .rejected:
        return .rejected
      }
      index += 1
    }
    return .ready(values)
  }

  private static func field(_ line: String, key: String) -> One {
    let prefix = key + " "
    if !line.hasPrefix(prefix) {
      return .rejected
    }
    return whole(String(line.dropFirst(prefix.count)))
  }

  private static func whole(_ token: String) -> One {
    if token.isEmpty || (token.count > 1 && token.hasPrefix("0")) {
      return .rejected
    }
    var value = 0
    for character in token {
      switch digit(character) {
      case .rejected:
        return .rejected
      case .ready(let piece):
        let scaled = value.multipliedReportingOverflow(by: 10)
        if scaled.overflow {
          return .rejected
        }
        let next = scaled.partialValue.addingReportingOverflow(piece)
        if next.overflow {
          return .rejected
        }
        value = next.partialValue
      }
    }
    return .ready(value)
  }

  private static func digit(_ character: Character) -> One {
    let utf8 = Array(String(character).utf8)
    if utf8.count != 1 {
      return .rejected
    }
    let code = Int(utf8[0])
    if code < 48 || code > 57 {
      return .rejected
    }
    return .ready(code - 48)
  }

  private static func sheet(_ values: [Int]) -> Outcome {
    if values.count != 8 {
      return .rejected
    }
    var index = 2
    while index < values.count {
      if values[index] != 0 && values[index] != 1 {
        return .rejected
      }
      index += 1
    }
    let resume = Progression.Resume(
      amount: values[0],
      rate: values[1],
      oil: values[2] == 1,
      wood: values[3] == 1,
      lava: values[4] == 1,
      faucet: values[5] == 1
    )
    switch Progression.resuming(resume) {
    case .rejected:
      return .rejected
    case .ready(let progress):
      return .ready(
        Sheet(progress: progress, fireKnown: values[6] == 1, stoneKnown: values[7] == 1)
      )
    }
  }
}
