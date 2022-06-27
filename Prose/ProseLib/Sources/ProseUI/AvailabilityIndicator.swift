//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Assets
import ProseCoreTCA
import SwiftUI

public struct AvailabilityIndicator: View {
  @Environment(\.redactionReasons) private var redactionReasons

  private let availability: Availability
  private let size: CGFloat

  public init(
    availability: Availability,
    size: CGFloat = 11.0
  ) {
    self.availability = availability
    self.size = size
  }

  public init(_ availability: Availability) {
    self.init(availability: availability)
  }

  public var body: some View {
    // Having a `ZStack` with the background circle always present allows animations.
    // Conditional views (aka `if`, `switch`…) break identity, and thus animations.
    ZStack {
      Circle()
        .fill(Color.white)
      Circle()
        .fill(redactionReasons.contains(.placeholder) ? .gray : availability.fillColor)
        .padding(2)
      Circle()
        .strokeBorder(Color(nsColor: .separatorColor), lineWidth: 0.5)
    }
    .frame(width: size, height: size)
    .drawingGroup()
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(String(describing: availability))
  }
}

private extension Availability {
  var fillColor: Color {
    switch self {
    case .available:
      return .green
    case .doNotDisturb:
      return .orange
    }
  }
}

struct AvailabilityIndicator_Previews: PreviewProvider {
  private struct Preview: View {
    var body: some View {
      HStack {
        ForEach(Availability.allCases, id: \.self, content: AvailabilityIndicator.init(_:))
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
