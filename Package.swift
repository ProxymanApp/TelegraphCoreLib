// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TelegraphCoreLib",
    platforms: [.macOS(.v10_14)],
    products: [
        .library(
            name: "TelegraphCoreLib",
            targets: ["TelegraphCoreLib"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
         .package(url: "https://github.com/Building42/HTTPParserC", from: "2.9.4"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "TelegraphCoreLib",
            dependencies: [.product(name: "HTTPParserC", package: "HTTPParserC")]),
    ]
)
