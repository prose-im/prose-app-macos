//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import SwiftUI

/// Because it is cross-platform, SwiftUI doesn't really like the macOS form style with two columns.
/// It supports it, but we cannot put labels in the first column if they're not attached to a single control.
/// To work around it, this `GroupBoxStyle` mimics the macOS form style.
///
/// - Note: This style might break some layout, accessibility and readability benefits of the system style.
public struct FormGroupBoxStyle: GroupBoxStyle {
  let firstColumnWidth: CGFloat
  let titleAlignment: HorizontalAlignment

  public init(
    firstColumnWidth: CGFloat,
    titleAlignment: HorizontalAlignment = .trailing
  ) {
    self.firstColumnWidth = firstColumnWidth
    self.titleAlignment = titleAlignment
  }

  public func makeBody(configuration: Configuration) -> some View {
    HStack(alignment: .top) {
      VStack(alignment: self.titleAlignment) {
        configuration.label
      }
      .frame(
        width: self.firstColumnWidth,
        alignment: Alignment(horizontal: self.titleAlignment, vertical: .center)
      )
      VStack(alignment: .leading) {
        configuration.content
      }
      .textFieldStyle(.roundedBorder)
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}
