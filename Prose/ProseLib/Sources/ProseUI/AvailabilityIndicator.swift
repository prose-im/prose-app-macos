//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import Assets
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
        .fill(self.redactionReasons.contains(.placeholder) ? .gray : self.availability.fillColor)
        .padding(2)
      Circle()
        .strokeBorder(Color(nsColor: .separatorColor), lineWidth: 0.5)
    }
    .frame(width: self.size, height: self.size)
    .drawingGroup()
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(String(describing: self.availability))
  }
}

private extension Availability {
  var fillColor: Color {
    switch self {
    case .available:
      return .green
    case .doNotDisturb, .away, .unavailable:
      return .orange
    }
  }
}
