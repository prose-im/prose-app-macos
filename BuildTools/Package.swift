// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "BuildTools",
    platforms: [.macOS(.v10_11)],
    dependencies: [
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.49.9"),
        .package(url: "https://github.com/SwiftGen/SwiftGen", from: "6.5.1"),
        .package(url: "https://github.com/thii/xcbeautify", from: "0.13.0"),
    ],
    targets: [.target(name: "BuildTools", path: "")]
)
