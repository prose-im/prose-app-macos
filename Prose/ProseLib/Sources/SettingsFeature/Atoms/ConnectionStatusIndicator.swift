//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import Assets
import SwiftUI

enum ConnectionStatus: Hashable, CaseIterable {
  case disconnected, connected

  var fillColor: Color {
    switch self {
    case .connected:
      return Colors.State.greenLight.color
    case .disconnected:
      return Colors.State.greyLight.color
    }
  }
}

struct ConnectionStatusIndicator: View {
  private let status: ConnectionStatus
  private let size: CGFloat

  init(
    status: ConnectionStatus = .disconnected,
    size: CGFloat = 10.0
  ) {
    self.status = status
    self.size = size
  }

  init(_ status: ConnectionStatus) {
    self.init(status: status)
  }

  var body: some View {
    Circle()
      .fill(self.status.fillColor)
      .frame(width: self.size, height: self.size)
  }
}

struct ConnectionStatusIndicator_Previews: PreviewProvider {
  private struct Preview: View {
    var body: some View {
      HStack {
        ForEach(
          ConnectionStatus.allCases,
          id: \.self,
          content: ConnectionStatusIndicator.init(_:)
        )
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
