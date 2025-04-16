// swift-tools-version: 5.10
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
    targets: [
        .target(name: "NTP"),
        .testTarget(
            name: "NTPTests",
            dependencies: [
                "NTP"
            ]
        )
    ],
    swiftLanguageVersions: [
        .v5,
        .version("6")
    ]
)
