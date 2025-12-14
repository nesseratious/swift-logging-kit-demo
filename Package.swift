// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "swift-logging-kit",
    platforms: [
        .iOS(.v15),
        .macCatalyst(.v15),
        .watchOS(.v10),
        .macOS(.v12),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "LoggingKit",
            targets: ["LoggingKit"]),
        .executable(
            name: "LoggingKitExample",
            targets: ["LoggingKitExample"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "600.0.0-latest"),
        .package(url: "https://github.com/apple/swift-atomics.git", from: "1.2.0"),
    ],
    targets: [
        .macro(
            name: "LoggingKitMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(
            name: "LoggingKit",
            dependencies: [
                "LoggingKitMacros",
                .product(name: "Atomics", package: "swift-atomics")
            ]),
        .executableTarget(
            name: "LoggingKitExample",
            dependencies: ["LoggingKit"]),
        .testTarget(
            name: "LoggingKitTests",
            dependencies: ["LoggingKit"]),
    ]
)

