// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Aztec",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "Aztec", targets: ["Aztec"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Aztec",
            path: "Aztec",
            exclude: ["Info.plist"],
            resources: [
                .process("Assets")
            ]
        )
    ]
)
