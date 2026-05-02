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
            path: ".", // 🚀 强制编译器以根目录为基准
            exclude: [
                ".github", 
                "preview", 
                "README.md",
                ".swiftpm"
            ],
            sources: [
                "Sources" // 🚀 明确告诉代码在 Sources 里
            ],
            resources: [
                .process("Assets.xcassets") // 🚀 明确告诉图片在根目录下
            ]
        )
    ]
)
