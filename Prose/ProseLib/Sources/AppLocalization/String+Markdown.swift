//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import SwiftUI

public extension String {
  /// Convert a `String` to a Markdown `AttributedString`.
  ///
  /// SwiftUI automatically renders Markdown, but only for static strings used in the `Text`
  /// initializer.
  /// If a string is localized, it doesn't render Markdown.
  /// That's why we have to use:
  ///
  /// ```swift
  /// Text(L10n.myString.asMarkdown)
  /// ```
  var asMarkdown: AttributedString {
    do {
      return try AttributedString(
        markdown: self,
        options: AttributedString.MarkdownParsingOptions(
          // Render `\n`s as new lines.
          interpretedSyntax: .inlineOnlyPreservingWhitespace
        )
      )
    } catch {
      logger.warning("Error parsing markdown: \(error.localizedDescription)")
      return AttributedString(self)
    }
  }
}
