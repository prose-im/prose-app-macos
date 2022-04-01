// swift-tools-version:5.6

import PackageDescription

let package = Package(
  name: "ProseLib",
  defaultLocalization: "en",
  platforms: [.iOS(.v15), .macOS(.v12)],
  products: [
    .library(name: "App", targets: ["App"]),
    .library(name: "ProseUI", targets: ["ProseUI"]),
  ],
  dependencies: [
    .package(url: "https://github.com/sindresorhus/Preferences", .upToNextMajor(from: "2.5.0")),
    .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.2")),
    .package(
      name: "swift-composable-architecture",
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      .upToNextMajor(from: "0.33.1")
    ),
  ],
  targets: [
    .target(
      name: "App",
      dependencies: [
        "SettingsFeature",
        "SidebarFeature",
        "AuthenticationFeature",
        "TcaHelpers",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .target(name: "Assets"),
    .target(name: "PreviewAssets"),
    .target(name: "ProseUI", dependencies: ["Assets", "PreviewAssets", "SharedModels"]),
    .target(name: "SharedModels"),
    .target(
      name: "TcaHelpers",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .target(name: "SettingsFeature", dependencies: ["Preferences", "Assets", "ProseUI"]),
    .target(
      name: "SidebarFeature",
      dependencies: ["Assets", "ProseUI", "PreviewAssets", "ConversationFeature"]
    ),
    .target(
      name: "ConversationFeature",
      dependencies: [
        "Assets",
        "ProseUI",
        "PreviewAssets",
        .product(name: "OrderedCollections", package: "swift-collections"),
      ]
    ),
    .target(
      name: "AuthenticationFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
  ]
)
