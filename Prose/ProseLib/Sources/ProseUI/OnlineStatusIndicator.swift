//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import Assets
import SwiftUI

public struct OnlineStatusIndicator: View {
  let availability: Availability

  public init(_ availability: Availability) {
    self.availability = availability
  }

  public var body: some View {
    LEDIndicator(isOn: self.availability != .unavailable)
      .fillColor(self.availability == .available ? Colors.State.green.color : Color.orange)
      // Override `LEDIndicator` accessibility label as it says "on"/"off"
      .accessibilityElement(children: .ignore)
      // FIXME: Localize ProseCoreFFI.Availability
      .accessibilityLabel(String(describing: self.availability))
  }
}
