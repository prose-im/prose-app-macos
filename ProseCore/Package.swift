// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "ProseCore",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "ProseCore", targets: ["ProseCore"]),
    ],
    targets: [
        .binaryTarget(
            name: "ProseCore",
            path: "ProseCore/ProseCore.xcframework"
        ),
    ]
)
