// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "grdb-cli-test",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "grdb-cli", targets: ["grdb-cli-test"]),
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift", from: "6.27.0"),
        // CLI
        .package(url: "https://github.com/mxcl/Path.swift", from: "1.4.1"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "grdb-cli-test",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "Path", package: "Path.swift"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
    ]
)
