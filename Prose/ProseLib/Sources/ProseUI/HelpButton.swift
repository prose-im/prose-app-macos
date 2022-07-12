//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import SwiftUI

// MARK: - View

public struct HelpButton<Content: View>: View {
  @Environment(\.redactionReasons) private var redactionReasons

  @State private var isShowingPopover: Bool = false

  let content: () -> Content

  public init(content: @escaping () -> Content) {
    self.content = content
  }

  public var body: some View {
    Button { self.isShowingPopover = true } label: {
      Image(systemName: "questionmark")
    }
    .buttonStyle(CircleButtonStyle())
    .unredacted()
    .disabled(self.redactionReasons.contains(.placeholder))
    .popover(isPresented: self.$isShowingPopover, content: self.content)
  }
}

private struct CircleButtonStyle: ButtonStyle {
  @Environment(\.isEnabled) private var isEnabled
  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .font(.system(size: 12, weight: .semibold, design: .rounded))
      .frame(width: 20, height: 20)
      .contentShape(Circle())
      .background {
        Circle()
          .fill(Color(nsColor: .controlColor))
          .shadow(color: Color.black.opacity(0.25), radius: 0, y: 0.5)
      }
      .overlay {
        Circle()
          .strokeBorder(Color.black.opacity(0.15), lineWidth: 0.5)
      }
      .opacity((configuration.isPressed || !self.isEnabled) ? 0.5 : 1)
  }
}

// MARK: - Previews

struct HelpButton_Previews: PreviewProvider {
  static var previews: some View {
    HelpButton {
      Text("Test")
        .padding()
    }
  }
}
