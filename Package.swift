// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NTP",
    platforms: [
        .iOS(.v12),
        .macOS(.v12)
    ],
    products: [
        .library(name: "NTP", targets: ["NTP"]),
    ],
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint.git", from: "0.58.0"),
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.3"),
    ],
    targets: [
        .target(
            name: "NTP",
            dependencies: [],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")
            ]
        ),
        .testTarget(
            name: "NTPTests",
            dependencies: [
                "NTP"
            ]
        )
    ]
)
