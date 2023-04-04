// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "MusanovaKit",
  platforms: [.iOS(.v15), .macOS(.v12), .watchOS(.v8), .tvOS(.v15)],
  products: [
    .library(name: "MusanovaKit", targets: ["MusanovaKit"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    .package(url: "https://github.com/lukepistrol/SwiftLintPlugin", from: "0.2.2"),
    .package(url: "https://github.com/rryam/MusadoraKit", branch: "main")
  ],
  targets: [
    .target(name: "MusanovaKit", dependencies: ["MusadoraKit"], resources: [.process("Resources")], plugins: [.plugin(name: "SwiftLint", package: "SwiftLintPlugin")]),
    .testTarget(name: "MusanovaKitTests", dependencies: ["MusanovaKit"], resources: [.process("Resources")]),
  ]
)
