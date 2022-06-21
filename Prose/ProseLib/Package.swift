// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "ProseLib",
    defaultLocalization: "en",
    platforms: [.macOS(.v12)],
    products: [
        .library(name: "App", targets: ["App"]),
        .library(name: "ProseUI", targets: ["ProseUI"]),
        // For efficiency, Xcode doesn't build all targets when building for previews. This library does it.
        .library(name: "Previews", targets: [
            "AddressBookFeature",
            "AuthenticationFeature",
            "ConversationFeature",
            "ConversationInfoFeature",
            "MainWindowFeature",
            "ProseUI",
            "SettingsFeature",
            "SidebarFeature",
            "UnreadFeature",
        ]),
    ],
    dependencies: [
        // .package(path: "../../ProseCore"),
        .package(url: "https://github.com/sindresorhus/Preferences", .upToNextMajor(from: "2.5.0")),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.2")),
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            .upToNextMajor(from: "0.33.1")
        ),
        .package(url: "https://github.com/pointfreeco/swiftui-navigation", .upToNextMajor(from: "0.1.0")),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                "MainWindowFeature",
                "SettingsFeature",
                "AuthenticationFeature",
                "CredentialsClient",
                "TcaHelpers",
                "UserDefaultsClient",
                // "ProseCore",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(name: "Assets", resources: [.process("Resources")]),
        .target(name: "AppLocalization", resources: [.process("Resources")]),
        .target(name: "PreviewAssets", resources: [.process("Resources")]),
        .target(name: "ProseUI", dependencies: ["Assets", "PreviewAssets", "SharedModels"]),
        .target(name: "SharedModels"),
        .testTarget(name: "SharedModelsTests", dependencies: ["SharedModels"]),
        .target(
            name: "TcaHelpers",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(name: "MainWindowFeature", dependencies: [
            "AuthenticationClient",
            "SidebarFeature",
            "TcaHelpers",
            "AddressBookFeature",
            "ConversationFeature",
            "UnreadFeature",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        ]),
        .target(name: "AddressBookFeature", dependencies: [
            "ProseUI",
            "SharedModels",
        ]),
        .target(name: "SettingsFeature", dependencies: [
            "Preferences",
            "AppLocalization",
            "Assets",
            "ProseUI",
        ]),
        .target(
            name: "SidebarFeature",
            dependencies: [
                "AppLocalization",
                "Assets",
                "ProseUI",
                "PreviewAssets",
                "SharedModels",
                "TcaHelpers",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "ConversationFeature",
            dependencies: [
                "AppLocalization",
                "Assets",
                "AuthenticationClient",
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
            "PreviewAssets",
            "ProseCoreStub",
            "SharedModels",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        ]),
        .target(
            name: "AuthenticationFeature",
            dependencies: [
                "AppLocalization",
                "CredentialsClient",
                // "ProseCore",
                "ProseUI",
                "SharedModels",
                "TcaHelpers",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
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
            "SharedModels",
            .product(name: "OrderedCollections", package: "swift-collections"),
        ]),

        // MARK: Dependencies

        .target(name: "AuthenticationClient", dependencies: [
            "SharedModels",
            "UserDefaultsClient",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        ]),
        .target(name: "CredentialsClient", dependencies: [
            "SharedModels",
        ]),
        .testTarget(name: "CredentialsClientTests", dependencies: ["CredentialsClient"]),
        .target(name: "UserDefaultsClient", dependencies: [
            "SharedModels",
        ]),
    ]
)
