// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Prose",
    dependencies: [
        .package(url: "https://github.com/sindresorhus/Preferences.git", from: "2.5.0"),
    ],
    targets: [
        .target(
            name: "Prose",
            dependencies: ["Preferences"],
            path: "Vendor"
        ),
    ]
)
