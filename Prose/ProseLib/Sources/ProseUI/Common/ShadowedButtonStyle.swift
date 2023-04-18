//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import SwiftUI

public struct ShadowedButtonStyle: ButtonStyle {
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .opacity(configuration.isPressed ? 0.5 : 1)
      .padding(.vertical, 6)
      .padding(.horizontal, 12)
      .background {
        RoundedRectangle(cornerRadius: 6)
          .fill(.background)
          .shadow(color: .gray.opacity(0.5), radius: 2)
      }
  }
}

public extension ButtonStyle where Self == ShadowedButtonStyle {
  static var shadowed: Self { ShadowedButtonStyle() }
}

struct ShadowedButtonStyle_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      Button(action: {}) {
        Label("Reply", systemImage: "arrowshape.turn.up.right")
          .frame(maxWidth: .infinity)
      }
      .foregroundColor(.accentColor)
      Button(action: {}) {
        Text("Mark read")
          .frame(maxWidth: .infinity)
      }
    }
    .frame(width: 96)
    .labelStyle(.vertical)
    .buttonStyle(.shadowed)
    .padding()
    .background(.background)
  }
}
