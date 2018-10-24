// swift-tools-version:4.2
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
        .package(url: "https://github.com/f-meloni/SwiftGherkin", .branch("gherkin_indentation")),
        .package(url: "https://github.com/stencilproject/Stencil", from: "0.12.1"),
        .package(url: "https://github.com/Quick/Nimble", from: "7.2.0"),
        .package(url: "https://github.com/f-meloni/TestSpy", .branch("master")),
        .package(url: "https://github.com/apple/swift-package-manager.git", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "CapriccioLib",
            dependencies: ["Gherkin", "Stencil"]),
        .target(
            name: "Capriccio",
            dependencies: ["CapriccioLib", "Utility"]),
        .testTarget(
            name: "CapriccioLibTests",
            dependencies: ["CapriccioLib", "Nimble", "TestSpy"])
    ]
)
