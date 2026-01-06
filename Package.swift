// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ObjectiveHUD",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "ObjectiveHUD", targets: ["ObjectiveHUD"])
    ],
    targets: [
        .executableTarget(
            name: "ObjectiveHUD",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
