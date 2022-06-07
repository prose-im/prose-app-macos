// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "ProseLib",
    defaultLocalization: "en",
    platforms: [.macOS(.v12)],
    products: [
        .library(name: "App", targets: ["App"]),
        .library(name: "ProseUI", targets: ["ProseUI"]),
    ],
    dependencies: [
        // .package(path: "../../ProseCore"),
        .package(url: "https://github.com/sindresorhus/Preferences", .upToNextMajor(from: "2.5.0")),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.2")),
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            .upToNextMajor(from: "0.33.1")
        ),
        .package(url: "https://github.com/pointfreeco/swift-parsing", .upToNextMajor(from: "0.9.2")),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                "MainWindowFeature",
                "SettingsFeature",
                "AuthenticationFeature",
                "TcaHelpers",
                // "ProseCore",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(name: "Assets"),
        .target(name: "AppLocalization", resources: [.process("Resources")]),
        .target(name: "PreviewAssets"),
        .target(name: "ProseUI", dependencies: ["Assets", "PreviewAssets", "SharedModels"]),
        .target(name: "SharedModels", dependencies: [
            .product(name: "Parsing", package: "swift-parsing"),
        ]),
        .testTarget(name: "SharedModelsTests", dependencies: ["SharedModels"]),
        .target(
            name: "TcaHelpers",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(name: "MainWindowFeature", dependencies: [
            "SidebarFeature",
            "TcaHelpers",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        ]),
        .target(name: "AddressBookFeature", dependencies: [
            "ProseUI",
            "SharedModels",
        ]),
        .target(name: "SettingsFeature", dependencies: ["Preferences", "Assets", "ProseUI"]),
        .target(
            name: "SidebarFeature",
            dependencies: [
                "AddressBookFeature",
                "AppLocalization",
                "Assets",
                "ConversationFeature",
                "ProseUI",
                "PreviewAssets",
                "SharedModels",
                // "ProseCore",
                "UnreadFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "ConversationFeature",
            dependencies: [
                "AppLocalization",
                "Assets",
                "ConversationInfoFeature",
                "ProseCoreStub",
                "ProseUI",
                "PreviewAssets",
                "SharedModels",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "OrderedCollections", package: "swift-collections"),
            ]
        ),
        .target(name: "ConversationInfoFeature", dependencies: [
            "ProseCoreStub",
            "SharedModels",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        ]),
        .target(
            name: "AuthenticationFeature",
            dependencies: [
                // "ProseCore",
                "SharedModels",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "UnreadFeature",
            dependencies: [
                "ConversationFeature",
                "ProseUI",
                "PreviewAssets",
                "SharedModels",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "OrderedCollections", package: "swift-collections"),
            ]
        ),
        .target(name: "ProseCoreStub", dependencies: [
            .product(name: "OrderedCollections", package: "swift-collections"),
        ]),
    ]
)
