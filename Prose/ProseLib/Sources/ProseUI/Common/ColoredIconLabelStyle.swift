//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import SwiftUI

public struct ColoredIconLabelStyle: LabelStyle {
  public func makeBody(configuration: Configuration) -> some View {
    Label {
      configuration.title
    } icon: {
      configuration.icon
        .foregroundColor(.accentColor)
    }
  }
}

public extension LabelStyle where Self == ColoredIconLabelStyle {
  static var coloredIcon: Self { ColoredIconLabelStyle() }
}

struct ColoredIconLabelStyle_Previews: PreviewProvider {
  static var previews: some View {
    Label("Valerian Saliou", systemImage: "message")
      .labelStyle(.coloredIcon)
  }
}
