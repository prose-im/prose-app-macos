// swift-tools-version:5.6

import Foundation
import PackageDescription

let package = Package(
  name: "ProseLib",
  defaultLocalization: "en",
  platforms: [.macOS(.v12)],
  products: [
    .library(name: "App", targets: ["App"]),
    .library(name: "TestHostApp", targets: ["TestHostApp"]),
    // For efficiency, Xcode doesn't build all targets when building for previews. This library does it.
    .library(name: "Previews", targets: [
      "AddressBookFeature",
      "AuthenticationFeature",
      "ConversationFeature",
      "ConversationInfoFeature",
      "EditProfileFeature",
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
    .package(
      url: "https://github.com/pointfreeco/swift-case-paths",
      .upToNextMajor(from: "0.9.1")
    ),
    .package(
      url: "https://github.com/pointfreeco/swiftui-navigation",
      .upToNextMajor(from: "0.1.0")
    ),
    .package(url: "https://github.com/pointfreeco/swift-tagged", .upToNextMajor(from: "0.7.0")),
    .proseCore("0.2.0"),
  ],
  targets: [
    .target(
      name: "App",
      dependencies: [
        "MainWindowFeature",
        "SettingsFeature",
        "AuthenticationFeature",
        "CredentialsClient",
        "UserDefaultsClient",
        "NotificationsClient",
      ]
    ),

    .target(
      name: "TestHostApp",
      dependencies: ["App", "Mocks"]
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
      "ProseCoreTCA",
    ]),
    .target(name: "SettingsFeature", dependencies: [.featureBase]),
    .target(name: "SidebarFeature", dependencies: [
      .featureBase,
      "EditProfileFeature",
    ]),
    .target(
      name: "ConversationFeature",
      dependencies: [
        .featureBase,
        "ConversationInfoFeature",
        "PasteboardClient",
        "ProseCoreViews",
      ]
    ),
    .testTarget(
      name: "ConversationFeatureTests",
      dependencies: ["ConversationFeature", "TestHelpers"]
    ),
    .target(name: "ConversationInfoFeature", dependencies: [.featureBase]),
    .target(name: "EditProfileFeature", dependencies: [.featureBase]),
    .target(
      name: "AuthenticationFeature",
      dependencies: [
        "CredentialsClient",
        .featureBase,
        .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
      ]
    ),
    .target(
      name: "UnreadFeature",
      dependencies: [
        "ConversationFeature",
        .featureBase,
      ]
    ),

    // MARK: Dependencies

    .target(name: "CredentialsClient", dependencies: [.base]),
    .testTarget(name: "CredentialsClientTests", dependencies: ["CredentialsClient"]),

    .target(name: "UserDefaultsClient", dependencies: [.base]),
    .target(name: "NotificationsClient", dependencies: [.base]),
    .target(name: "PasteboardClient", dependencies: [.base]),

    .target(
      name: "FeatureBase",
      dependencies: [.base, "ProseUI", "TcaHelpers", "AppLocalization", "Assets"]
    ),
    .target(
      name: "Base",
      dependencies: ["ProseCoreTCA"]
    ),

    .target(name: "Assets", resources: [.process("Resources")]),
    .target(name: "AppLocalization", resources: [.process("Resources")]),
    .target(
      name: "ProseUI",
      dependencies: [
        "Assets",
        "ProseCoreTCA",
        .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
      ]
      .appendingDebugDependencies(["PreviewAssets"])
    ),
    .target(name: "Toolbox"),
    .target(
      name: "TcaHelpers",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),

    .target(name: "PreviewAssets", resources: [.process("Resources")]),

    .target(name: "ProseCoreViews", dependencies: [.base], resources: [.process("Resources")]),
    .testTarget(
      name: "ProseCoreViewsTests",
      dependencies: [
        "ProseCoreViews",
        "TestHelpers",
      ]
    ),

    .target(name: "ProseCore", dependencies: [.proseCore]),
    .target(
      name: "ProseCoreTCA",
      dependencies: [
        "ProseCore",
        "Toolbox",
        .product(name: "Tagged", package: "swift-tagged"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .testTarget(name: "ProseCoreTCATests", dependencies: ["ProseCoreTCA", "TestHelpers"]),

    .target(name: "TestHelpers"),

    .target(
      name: "Mocks",
      dependencies: ["ProseCoreTCA"],
      resources: [.copy("RandomUser/random_user.json")]
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
    // No better way yet? https://forums.swift.org/t/spm-resources-only-in-debug-configuration/38046/14
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

extension Target.Dependency {
  static var proseCore: Target.Dependency {
    Environment.settings.useLocalProseLib
      ? "ProseCoreClientFFI"
      : .product(name: "ProseCoreClientFFI", package: "prose-wrapper-swift")
  }

  static let base = Target.Dependency.target(name: "Base")
  static var featureBase = Target.Dependency.target(name: "FeatureBase")
}

extension Array where Element == Target.Dependency {
  func appendingDebugDependencies(_ dependencies: [Target.Dependency]) -> Self {
    if Environment.settings.configuration == .debug {
      return self + dependencies
    }
    return self
  }
}
