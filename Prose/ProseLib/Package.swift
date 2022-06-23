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
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            .upToNextMajor(from: "0.33.1")
        ),
        .package(url: "https://github.com/pointfreeco/swiftui-navigation", .upToNextMajor(from: "0.1.0")),
        // https://github.com/prose-im/prose-wrapper-swift/issues/1
        .package(url: "https://github.com/prose-im/prose-wrapper-swift", branch: "0.1.3"),
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
                "ProseCoreTCA",
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
            "SidebarFeature",
            "TcaHelpers",
            "AddressBookFeature",
            "ConversationFeature",
            "UnreadFeature",
            "ProseCoreTCA",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        ]),
        .target(name: "AddressBookFeature", dependencies: [
            "ProseUI",
            "SharedModels",
        ]),
        .target(name: "SettingsFeature", dependencies: [
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
                "ProseCoreTCA",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "ConversationFeature",
            dependencies: [
                "AppLocalization",
                "Assets",
                "ConversationInfoFeature",
                "ProseUI",
                "PreviewAssets",
                "SharedModels",
                "ProseCoreTCA",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            resources: [.process("Resources")]
        ),
        .target(name: "ConversationInfoFeature", dependencies: [
            "PreviewAssets",
            "SharedModels",
            "ProseCoreTCA",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        ]),
        .target(
            name: "AuthenticationFeature",
            dependencies: [
                "AppLocalization",
                "CredentialsClient",
                "ProseUI",
                "SharedModels",
                "TcaHelpers",
                "ProseCoreTCA",
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
                "ProseCoreTCA",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),

        // MARK: Dependencies

        .target(name: "CredentialsClient", dependencies: [
            "SharedModels",
        ]),
        .testTarget(name: "CredentialsClientTests", dependencies: ["CredentialsClient"]),
        .target(name: "UserDefaultsClient", dependencies: [
            "SharedModels",
        ]),
        .target(
            name: "ProseCore",
            dependencies: [
                .product(name: "ProseCoreClientFFI", package: "prose-wrapper-swift"),
            ]
        ),
        .target(
            name: "ProseCoreTCA",
            dependencies: [
                "ProseCore",
                "SharedModels",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
    ]
)
