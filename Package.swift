// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MusanovaKit",
    platforms: [.iOS(.v15), .macOS(.v12), .watchOS(.v8), .tvOS(.v15), .visionOS(.v1)],
    products: [
        .library(name: "MusanovaKit", targets: ["MusanovaKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/rryam/MusadoraKit", branch: "main")
    ],
    targets: [
        .target(name: "MusanovaKit", dependencies: ["MusadoraKit"]),
        .testTarget(name: "MusanovaKitTests", dependencies: ["MusanovaKit"], resources: [.process("Resources")]),
    ]
)
