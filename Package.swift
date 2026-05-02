// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TinPlayer",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .executable(name: "TinPlayer", targets: ["TinPlayer"])
    ],
    targets: [
        .executableTarget(
            name: "TinPlayer",
            dependencies: [],
            path: "Sources",
            resources: [
                .process("Resources/Assets.xcassets")
            ]
        )
    ]
)
