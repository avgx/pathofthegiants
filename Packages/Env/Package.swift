// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Env",
    platforms: [
        .iOS(.v26),
        .tvOS(.v26),
        .macOS(.v26)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Env",
            targets: ["Env"]
        ),
    ],
    dependencies: [
        .package(name: "Models", path: "../Models"),
        .package(name: "Api", path: "../Api"),
        .package(url: "https://github.com/avgx/keychain-swift", branch: "master"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Env",
            dependencies: [
                "Models", "Api",
                .product(name: "KeychainSwift", package: "keychain-swift"),
            ]
        ),

    ]
)
