// swift-tools-version:5.8

import Foundation
import PackageDescription

let package = Package(
  name: "ProseLib",
  defaultLocalization: "en",
  platforms: [.macOS(.v13)],
  products: [
    .library(name: "App", targets: ["App"]),
    .library(name: "TestHostApp", targets: ["TestHostApp"]),
    // For efficiency, Xcode doesn't build all targets when building for previews. This library does
    // it.
    .library(name: "Previews", targets: [
      "AddressBookFeature",
      "AuthenticationFeature",
      "ConversationFeature",
      "ConversationInfoFeature",
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
    .package(
      name: "ProseCoreFFI",
      path: "/Users/mb/Documents/Prose/prose-wrapper-swift/Build/spm/ProseCoreFFI"
    ),
    .package(url: "https://github.com/nesium/swift-common-utils", .upToNextMajor(from: "1.2.0")),
    // .proseCore("0.4.3"),
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
        "AccountBookmarksClient",
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
        "ConversationInfoFeature",
        "PasteboardClient",
        "ProseCoreViews",
      ]
    ),
    .testTarget(
      name: "ConversationFeatureTests",
      dependencies: ["ConversationFeature", "TestHelpers"]
    ),
    .featureTarget(name: "ConversationInfoFeature"),
    .featureTarget(name: "EditProfileFeature", dependencies: ["ProseCore"]),
    .featureTarget(
      name: "AuthenticationFeature",
      dependencies: [
        "AccountBookmarksClient",
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

    .dependencyTarget(name: "AccountBookmarksClient"),
    .dependencyTarget(name: "NotificationsClient"),
    .dependencyTarget(name: "PasteboardClient"),

    .target(name: "Assets", resources: [.process("Resources")]),
    .target(name: "AppLocalization", resources: [.process("Resources")]),
    .target(
      name: "ProseUI",
      dependencies: [
        "Assets",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
      ]
      .appendingDebugDependencies(["PreviewAssets"])
    ),
    .target(name: "Toolbox"),

    .target(name: "PreviewAssets", resources: [.process("Resources")]),

    .target(
      name: "ProseCoreViews",
      dependencies: [
        "AppDomain",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ],
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
        .product(name: "ProseCoreFFI", package: "ProseCoreFFI"),
        .product(name: "BareMinimum", package: "swift-common-utils"),
      ]
    ),
    .target(
      name: "ProseCore",
      dependencies: [
        "AppDomain",
        "Toolbox",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
  ]
)

enum Environment {
  struct Settings: Decodable {
    enum Configuration: String, Decodable {
      case debug
      case release
    }

    var configuration: Configuration
    var useLocalProseLib: Bool
    var proseLibPath: String
  }

  static let settings: Settings = {
    // If the `IS_RELEASE_BUILD` env var is set we're switching to the release settings.
    // The env var can only be set when running xcodebuild outside of Xcode.
    // No better way yet?
    // https://forums.swift.org/t/spm-resources-only-in-debug-configuration/38046/14
    guard ProcessInfo.processInfo.environment["IS_RELEASE_BUILD"] != "1" else {
      return .release
    }

    // Let's see if we have a .env.json file next to our Package.swift. If not, we're
    // assuming debug settings.
    let envFilePath = URL(fileURLWithPath: #file)
      .deletingLastPathComponent()
      .appendingPathComponent(".env.json")

    guard FileManager.default.fileExists(atPath: envFilePath.path) else {
      return .debug
    }

    // Finally load the .env.json. If you're fiddling with this file, you'll probably need to
    // close & reopen the project file.
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let env: Data
    do {
      env = try Data(contentsOf: envFilePath)
      return try decoder.decode(Settings.self, from: env)
    } catch { fatalError(String(describing: error)) }
  }()
}

extension Environment.Settings {
  static let release = Self(
    configuration: .release,
    useLocalProseLib: false,
    proseLibPath: ""
  )

  static let debug = Self(
    configuration: .debug,
    useLocalProseLib: false,
    proseLibPath: ""
  )
}

extension Package.Dependency {
  static func proseCore(_ version: String) -> Package.Dependency {
    Environment.settings.useLocalProseLib
      ? .package(path: Environment.settings.proseLibPath)
      : .package(url: "https://github.com/prose-im/prose-wrapper-swift", branch: version)
  }
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
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
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
      dependencies: dependencies + [
        "AppDomain",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ],
      exclude: exclude
    )
  }
}

extension Target.Dependency {
  static var proseCore: Target.Dependency {
//    Environment.settings.useLocalProseLib
    "ProseCoreClientFFI"
//      : .product(name: "ProseCoreClientFFI", package: "prose-wrapper-swift")
  }
}

extension Array where Element == Target.Dependency {
  func appendingDebugDependencies(_ dependencies: [Target.Dependency]) -> Self {
    if Environment.settings.configuration == .debug {
      return self + dependencies
    }
    return self
  }
}
