// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TinPlayer",
    platforms: [.iOS(.v16)],
    products: [
        .executable(name: "TinPlayer", targets: ["TinPlayer"])
    ],
    targets: [
        .executableTarget(
            name: "TinPlayer",
            path: "Sources/TinPlayer",
            resources: [
                .process("Assets.xcassets")
            ]
        )
    ]
)
