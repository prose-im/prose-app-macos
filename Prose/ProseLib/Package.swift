// swift-tools-version:5.8

import Foundation
import PackageDescription

let package = Package(
  name: "ProseLib",
  defaultLocalization: "en",
  platforms: [.macOS(.v13)],
  products: [
    .library(name: "App", targets: ["App"]),
    .library(name: "ConversationFeature", targets: ["ConversationFeature"]),
    .library(name: "Mocks", targets: ["Mocks"]),
    .library(name: "TestHostApp", targets: ["TestHostApp"]),
    // For efficiency, Xcode doesn't build all targets when building for previews. This library does
    // it.
    .library(name: "Previews", targets: [
      "AddressBookFeature",
      "AuthenticationFeature",
      "ConversationFeature",
      "EditProfileFeature",
      "JoinChatFeature",
      "MainScreenFeature",
      "ProseUI",
      "SettingsFeature",
      "SidebarFeature",
      "UnreadFeature",
    ]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      .upToNextMajor(from: "0.52.0")
    ),
    .package(
      url: "https://github.com/pointfreeco/swiftui-navigation",
      .upToNextMajor(from: "0.7.1")
    ),
    .package(url: "https://github.com/nesium/swift-common-utils", .upToNextMajor(from: "1.2.0")),

//     .package(name: "ProseCoreFFI", path: "../../../../prose-wrapper-swift/Build/spm/ProseCoreFFI"),
    .package(url: "https://github.com/prose-im/prose-wrapper-swift", exact: "0.12.0"),
  ],
  targets: [
    .target(
      name: "App",
      dependencies: [
        "MainScreenFeature",
        "SettingsFeature",
        "AuthenticationFeature",
        "ConnectivityClient",
        "CredentialsClient",
        "NotificationsClient",
        "ProseCore",
      ]
    ),

    .target(
      name: "TestHostApp",
      dependencies: ["App", "Mocks"]
    ),

    .target(name: "MainScreenFeature", dependencies: [
      "SidebarFeature",
      "AddressBookFeature",
      "ConversationFeature",
      "UnreadFeature",
      "ProseCore",
      .product(name: "TCAUtils", package: "swift-common-utils"),
    ]),
    .target(name: "AddressBookFeature", dependencies: [
      "ProseUI",
    ]),
    .featureTarget(name: "JoinChatFeature"),
    .featureTarget(name: "SettingsFeature"),
    .featureTarget(name: "SidebarFeature", dependencies: [
      "AuthenticationFeature",
      "EditProfileFeature",
      "JoinChatFeature",
      "ProseCore",
    ]),
    .featureTarget(
      name: "ConversationFeature",
      dependencies: [
        "PasteboardClient",
        "ProseCoreViews",
        "ProseCore",
        .product(name: "TCAUtils", package: "swift-common-utils"),
      ],
      exclude: ["README.md"]
    ),
    .testTarget(
      name: "ConversationFeatureTests",
      dependencies: ["ConversationFeature", "TestHelpers", "Mocks"]
    ),
    .featureTarget(name: "EditProfileFeature", dependencies: ["ProseCore"]),
    .featureTarget(
      name: "AuthenticationFeature",
      dependencies: [
        "CredentialsClient",
        "ProseCore",
        .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
      ]
    ),
    .featureTarget(name: "UnreadFeature", dependencies: ["ConversationFeature"]),

    // MARK: Dependencies

    .dependencyTarget(name: "CredentialsClient"),
    .dependencyTarget(name: "ConnectivityClient", dependencies: ["Toolbox"]),

    .testTarget(name: "CredentialsClientTests", dependencies: ["CredentialsClient"]),

    .dependencyTarget(name: "NotificationsClient"),
    .dependencyTarget(name: "PasteboardClient"),

    .target(name: "Assets", resources: [.process("Resources")]),
    .target(
      name: "AppLocalization",
      dependencies: ["AppDomain"],
      resources: [.process("Resources")]
    ),
    .target(
      name: "ProseUI",
      dependencies: [
        "Assets",
        "AppDomain",
        .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
      ]
      .appendingDebugDependencies(["PreviewAssets"])
    ),
    .target(name: "Toolbox"),

    .target(name: "PreviewAssets", resources: [.process("Resources")]),

    .target(
      name: "ProseCoreViews",
      dependencies: ["AppDomain"],
      resources: [.process("Resources")]
    ),
    .testTarget(
      name: "ProseCoreViewsTests",
      dependencies: [
        "ProseCoreViews",
        "TestHelpers",
      ]
    ),

    .target(name: "TestHelpers"),

    .target(
      name: "Mocks",
      dependencies: ["AppDomain"],
      resources: [.copy("RandomUser/random_user.json")]
    ),

    .target(
      name: "AppDomain",
      dependencies: [
        //         .product(name: "ProseCoreFFI", package: "ProseCoreFFI"),
        .product(name: "ProseCoreFFI", package: "prose-wrapper-swift"),
        .product(name: "BareMinimum", package: "swift-common-utils"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .target(
      name: "ProseCore",
      dependencies: [
        "AppDomain",
        "Toolbox",
      ]
    ),
  ]
)

enum Environment {
  enum Configuration: String, Decodable {
    case debug
    case release
  }

  static let configuration: Configuration = {
    // If the `IS_RELEASE_BUILD` env var is set we're switching to the release settings.
    // The env var can only be set when running xcodebuild outside of Xcode.
    // No better way yet?
    // https://forums.swift.org/t/spm-resources-only-in-debug-configuration/38046/14
    guard ProcessInfo.processInfo.environment["IS_RELEASE_BUILD"] != "1" else {
      return .release
    }

    return .debug
  }()
}

extension PackageDescription.Target {
  /// A target that describes a fully-fledged app feature
  static func featureTarget(
    name: String,
    dependencies: [Dependency] = [],
    exclude: [String] = []
  ) -> PackageDescription.Target {
    self.target(
      name: name,
      dependencies: dependencies + [
        "AppDomain",
        "AppLocalization",
        "Assets",
        "ProseUI",
      ],
      exclude: exclude
    )
  }

  /// A target that describes a TCA dependency
  static func dependencyTarget(
    name: String,
    dependencies: [Dependency] = [],
    exclude: [String] = []
  ) -> PackageDescription.Target {
    self.target(
      name: name,
      dependencies: dependencies + ["AppDomain"],
      exclude: exclude
    )
  }
}

extension Array where Element == Target.Dependency {
  func appendingDebugDependencies(_ dependencies: [Target.Dependency]) -> Self {
    if Environment.configuration == .debug {
      return self + dependencies
    }
    return self
  }
}
