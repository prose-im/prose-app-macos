//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Assets
import ProseCoreTCA
import SwiftUI

public struct BooleanIndicator: View {
  @Environment(\.redactionReasons) private var redactionReasons

  let bool: Bool
  let size: CGFloat

  public init(
    bool: Bool = false,
    size: CGFloat = 8.0
  ) {
    self.bool = bool
    self.size = size
  }

  public init(_ bool: Bool) {
    self.init(bool: bool)
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
          redactionReasons
            .contains(.placeholder) ? .gray : (bool.fillColor ?? Color.clear)
        )
    }
    .frame(width: size, height: size)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(String(describing: bool))
  }
}

private extension Bool {
  var fillColor: Color? {
    self ? .some(Colors.State.green.color) : .none
  }
}

struct BooleanIndicator_Previews: PreviewProvider {
  private struct Preview: View {
    var body: some View {
      HStack {
        BooleanIndicator()
        BooleanIndicator(false)
        BooleanIndicator(true)
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
