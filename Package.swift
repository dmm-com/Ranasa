// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Alefgard",
    platforms: [
        .macOS(.v11),
    ],
    products: [
        .executable(
            name: "alefgard",
            targets: ["Alefgard"]),
        .library(
            name: "AlefgardCore",
            targets: ["AlefgardCore"])
    ],
    dependencies: [
        .package(
            name: "swift-argument-parser",
            url: "https://github.com/apple/swift-argument-parser.git",
            .upToNextMajor(from: "0.4.3")
        ),
        .package(
            name: "ShellOut",
            url: "https://github.com/JohnSundell/ShellOut.git",
            .upToNextMajor(from: "2.3.0")
        ),
        .package(
            name: "arm64-to-sim",
            url: "https://github.com/darrarski/arm64-to-sim.git",
            .upToNextMajor(from: "1.0.0")
        ),
    ],
    targets: [
        .target(
            name: "Alefgard",
            dependencies: [
                .target(name: "AlefgardCore"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]),
        .target(
            name: "AlefgardCore",
            dependencies: [
                .product(name: "ShellOut", package: "ShellOut"),
                .product(name: "Arm64ToSim", package: "arm64-to-sim")
            ]),
        .testTarget(
            name: "AlefgardTests",
            dependencies: ["Alefgard"]),
    ]
)
