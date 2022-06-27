//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Cocoa
import SwiftUI

public struct LevelIndicator: View {
  private let minimumValue, maximumValue: Double
  private let warningValue, criticalValue: Double
  private let tickMarkFactor: Double
  private let currentValue: Double

  public init(
    currentValue: Double,
    minimumValue: Double = 0.0,
    maximumValue: Double = 1.0,
    warningValue: Double = 0.5,
    criticalValue: Double = 0.75,
    tickMarkFactor: Double = 6.0
  ) {
    self.minimumValue = minimumValue
    self.maximumValue = maximumValue
    self.warningValue = warningValue
    self.criticalValue = criticalValue
    self.tickMarkFactor = tickMarkFactor
    self.currentValue = currentValue
  }

  public var body: some View {
    let indicator = NSLevelIndicator()

    // Configure bounds
    indicator.minValue = minimumValue * tickMarkFactor
    indicator.maxValue = maximumValue * tickMarkFactor
    indicator.warningValue = warningValue * tickMarkFactor
    indicator.criticalValue = criticalValue * tickMarkFactor

    // Apply value
    indicator.doubleValue = currentValue * tickMarkFactor

    return ViewWrap(indicator)
  }
}

struct LevelIndicator_Previews: PreviewProvider {
  private struct Preview: View {
    var body: some View {
      VStack {
        ForEach([-2, 0, 0.2, 0.4, 0.6, 0.8, 1, 2], id: \.self) { value in
          LevelIndicator(
            currentValue: value
          )
        }
      }
      .padding()
    }
  }

  static var previews: some View {
    Preview()
      .preferredColorScheme(.light)
      .previewDisplayName("Light")

    Preview()
      .preferredColorScheme(.dark)
      .previewDisplayName("Dark")
  }
}
