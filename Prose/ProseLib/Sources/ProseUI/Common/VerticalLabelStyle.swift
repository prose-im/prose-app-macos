//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import SwiftUI

public struct VerticalLabelStyle: LabelStyle {
  public func makeBody(configuration: Configuration) -> some View {
    VStack {
      configuration.icon
        .font(.system(size: 24))
      configuration.title
    }
  }
}

public extension LabelStyle where Self == VerticalLabelStyle {
  static var vertical: Self { VerticalLabelStyle() }
}

struct VerticalLabelStyle_Previews: PreviewProvider {
  static var previews: some View {
    Label("Reply", systemImage: "arrowshape.turn.up.right")
      .labelStyle(.vertical)
    Button(action: {}) {
      Label("Reply", systemImage: "arrowshape.turn.up.right")
    }
//        .buttonStyle(.plain)
    .labelStyle(.vertical)
    .padding()
  }
}
