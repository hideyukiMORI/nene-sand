// swift-tools-version: 6.4

import PackageDescription

let strictSettings: [SwiftSetting] = [
  .unsafeFlags(["-warnings-as-errors"])
]

let package = Package(
  name: "nene-sand",
  products: [
    .executable(name: "nene-sand", targets: ["NeNeSandApp"])
  ],
  targets: [
    .target(
      name: "NeNeSandCore",
      swiftSettings: strictSettings
    ),
    .target(
      name: "NeNeSandSave",
      dependencies: ["NeNeSandCore"],
      swiftSettings: strictSettings
    ),
    .target(
      name: "NeNeSandRender",
      dependencies: ["NeNeSandCore"],
      swiftSettings: strictSettings
    ),
    .target(
      name: "NeNeSandTerminal",
      dependencies: ["NeNeSandRender"],
      swiftSettings: strictSettings
    ),
    .executableTarget(
      name: "NeNeSandApp",
      dependencies: [
        "NeNeSandCore",
        "NeNeSandSave",
        "NeNeSandRender",
        "NeNeSandTerminal",
      ],
      swiftSettings: strictSettings
    ),
    .testTarget(
      name: "NeNeSandCoreTests",
      dependencies: ["NeNeSandCore"],
      swiftSettings: strictSettings
    ),
    .testTarget(
      name: "NeNeSandRenderTests",
      dependencies: ["NeNeSandRender"],
      swiftSettings: strictSettings
    ),
    .testTarget(
      name: "NeNeSandTerminalTests",
      dependencies: ["NeNeSandTerminal"],
      swiftSettings: strictSettings
    ),
  ]
)
