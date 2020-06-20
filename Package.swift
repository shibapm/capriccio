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
        .package(url: "https://github.com/iainsmith/SwiftGherkin", .exact("0.2.0")),
        .package(url: "https://github.com/stencilproject/Stencil", .exact("0.13.1")),
        .package(url: "https://github.com/apple/swift-argument-parser", .exact("0.1.0")),
        .package(url: "https://github.com/jpsim/Yams.git", from: "2.0.0"),
//        .package(url: "https://github.com/Quick/Nimble", from: "8.0.0"), // dev
//        .package(url: "https://github.com/f-meloni/TestSpy", from: "0.4.0"), // dev
//        .package(url: "https://github.com/shibapm/Rocket", from: "0.9.0"), // dev
//        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.5.0") // dev
    ],
    targets: [
        .target(
            name: "CapriccioLib",
            dependencies: ["Gherkin", "Stencil"]),
        .target(
            name: "Capriccio",
            dependencies: ["CapriccioLib", "ArgumentParser", "Yams"]),
//        .testTarget(name: "CapriccioLibTests",dependencies: ["CapriccioLib", "Nimble", "TestSpy", "SnapshotTesting"]) // dev
    ],
    swiftLanguageVersions: [.v5]
)

#if canImport(PackageConfig)
import PackageConfig

let config = PackageConfiguration([
    "rocket": [
        "before": [
            "scripts/update_version.sh"
        ],
    ],
    ]).write()
#endif
