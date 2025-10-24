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
        .package(url: "https://github.com/rryam/MusadoraKit", branch: "main"),
        .package(path: "Packages/SwiftLintPlugin"),
        .package(url: "https://github.com/apple/swift-testing", from: "0.9.0")
    ],
    targets: [
        .target(name: "MusanovaKit", dependencies: ["MusadoraKit"], plugins: [.plugin(name: "SwiftLint", package: "SwiftLintPlugin")]),
        .testTarget(
            name: "MusanovaKitTests",
            dependencies: [
                "MusanovaKit",
                .product(name: "Testing", package: "swift-testing")
            ],
            resources: [.process("Resources")]
        ),
    ]
)