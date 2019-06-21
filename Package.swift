// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Capriccio",
    products: [
        .executable(
            name: "capriccio",
            targets: ["Capriccio"])
    ],
    dependencies: [
        .package(url: "https://github.com/FelipeDocil/SwiftGherkin", .branch("support_comments")),
        .package(url: "https://github.com/stencilproject/Stencil", .exact("0.13.1")),
        .package(url: "https://github.com/apple/swift-package-manager.git", .exact("0.3.0")),
        .package(url: "https://github.com/jpsim/Yams.git", .exact("2.0.0")),
        .package(url: "https://github.com/Quick/Nimble", .exact("8.0.2")), // dev
        .package(url: "https://github.com/f-meloni/TestSpy", .exact("0.4.0")), // dev
        .package(url: "https://github.com/shibapm/Rocket", from: "0.9.0") // dev
    ],
    targets: [
        .target(
            name: "CapriccioLib",
            dependencies: ["Gherkin", "Stencil"]),
        .target(
            name: "Capriccio",
            dependencies: ["CapriccioLib", "Utility", "Yams"]),
        .testTarget(
            name: "CapriccioLibTests",
            dependencies: ["CapriccioLib", "Nimble", "TestSpy"])
    ],
    swiftLanguageVersions: [.v5]
)
