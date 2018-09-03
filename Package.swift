// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Capriccio",
    products: [
        .executable(
            name: "Capriccio",
            targets: ["Capriccio"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Capriccio",
            dependencies: []),
        .testTarget(
            name: "CapriccioTests",
            dependencies: ["Capriccio"]),
    ]
)
