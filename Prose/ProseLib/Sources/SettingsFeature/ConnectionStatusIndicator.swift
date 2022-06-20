//
//  ConnectionStatusIndicator.swift
//  Prose
//
//  Created by Valerian Saliou on 12/11/21.
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
            .fill(status.fillColor)
            .frame(width: size, height: size)
    }
}

struct ConnectionStatusIndicator_Previews: PreviewProvider {
    private struct Preview: View {
        var body: some View {
            HStack {
                ForEach(ConnectionStatus.allCases, id: \.self, content: ConnectionStatusIndicator.init(_:))
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
