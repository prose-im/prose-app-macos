//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import Assets
import SwiftUI

public struct LEDIndicator: View {
  @Environment(\.redactionReasons) private var redactionReasons

  public enum State: Equatable {
    case off, on
  }

  let state: State
  let size: CGFloat

  private var fillColor = Colors.State.green.color

  public init(
    state: State = .off,
    size: CGFloat = 8
  ) {
    self.state = state
    self.size = size
  }

  public init(_ state: State) {
    self.init(state: state)
  }

  public var body: some View {
    // Having a `ZStack` with the background circle always present allows animations.
    // Conditional views (aka `if`, `switch`…) break identity, and thus animations.
    ZStack {
      Circle()
        .strokeBorder(Colors.State.grey.color)
      Circle()
        // Using `Color.clear` keeps identity, and thus animations
        .fill(
          self.redactionReasons.contains(.placeholder)
            ? .gray
            : (self.state == .on ? self.fillColor : Color.clear)
        )
    }
    .frame(width: self.size, height: self.size)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(String(describing: self.state))
  }
}

public extension LEDIndicator {
  func fillColor(_ color: Color) -> some View {
    var indicator = self
    indicator.fillColor = color
    return indicator
  }
}

public extension LEDIndicator {
  init(isOn: Bool, size: CGFloat) {
    self.init(state: isOn ? .on : .off, size: size)
  }

  init(isOn: Bool) {
    self.init(state: isOn ? .on : .off)
  }
}

struct LEDIndicator_Previews: PreviewProvider {
  private struct Preview: View {
    var body: some View {
      HStack {
        LEDIndicator()
        LEDIndicator(.on)
        LEDIndicator(.off)
      }
      .padding()
      .previewLayout(.sizeThatFits)
    }
  }

  static var previews: some View {
    Preview()
      .preferredColorScheme(.light)
      .previewDisplayName("Light")
    Preview()
      .preferredColorScheme(.dark)
      .previewDisplayName("Dark")
    Preview()
      .redacted(reason: .placeholder)
      .previewDisplayName("Placeholder")
  }
}
