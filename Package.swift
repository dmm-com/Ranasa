// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Ranasa",
    platforms: [
        .macOS(.v11),
    ],
    products: [
        .executable(
            name: "ranasa",
            targets: ["Ranasa"]),
        .library(
            name: "RanasaCore",
            targets: ["RanasaCore"])
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
    ],
    targets: [
        .target(
            name: "Ranasa",
            dependencies: [
                .target(name: "RanasaCore"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]),
        .target(
            name: "RanasaCore",
            dependencies: [
                .product(name: "ShellOut", package: "ShellOut")
            ]),
        .testTarget(
            name: "RanasaCoreTests",
            dependencies: ["RanasaCore"]),
    ]
)
