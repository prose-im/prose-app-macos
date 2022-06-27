//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length line_length implicit_return

// MARK: - Files

// swiftlint:disable explicit_type_interface identifier_name
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum Files {
  /// messaging.html
  internal static let messagingHtml = File(
    name: "messaging",
    ext: "html",
    relativePath: "",
    mimeType: "text/html"
  )
}

// swiftlint:enable explicit_type_interface identifier_name
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

internal struct File {
  internal let name: String
  internal let ext: String?
  internal let relativePath: String
  internal let mimeType: String

  internal var url: URL {
    url(locale: nil)
  }

  internal func url(locale: Locale?) -> URL {
    let bundle = Bundle.fixedModule
    let url = bundle.url(
      forResource: self.name,
      withExtension: self.ext,
      subdirectory: self.relativePath,
      localization: locale?.identifier
    )
    guard let result = url else {
      let file = self.name + (self.ext.flatMap { ".\($0)" } ?? "")
      fatalError("Could not locate file named \(file)")
    }
    return result
  }

  internal var path: String {
    path(locale: nil)
  }

  internal func path(locale: Locale?) -> String {
    self.url(locale: locale).path
  }
}
