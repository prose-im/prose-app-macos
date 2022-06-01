//
//  OnlineStatusIndicator.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import Assets
import SharedModels
import SwiftUI

public struct OnlineStatusIndicator: View {
    private let status: OnlineStatus
    private let size: CGFloat

    public init(
        status: OnlineStatus = .offline,
        size: CGFloat = 8.0
    ) {
        self.status = status
        self.size = size
    }

    public init(_ status: OnlineStatus) {
        self.init(status: status)
    }

    public var body: some View {
        // Having a `ZStack` with the background circle always present allows animations.
        // Conditional views (aka `if`, `switch`…) break identity, and thus animations.
        ZStack {
            Circle()
                .strokeBorder(Color.stateGrey)
            Circle()
                // Using `Color.clear` keeps identity, and thus animations
                .fill(status.fillColor ?? Color.clear)
        }
        .frame(width: size, height: size)
    }
}

private extension OnlineStatus {
    var fillColor: Color? {
        switch self {
        case .online:
            return .some(.stateGreen)
        case .offline:
            return .none
        }
    }
}

struct StatusIndicator_Previews: PreviewProvider {
    private struct Preview: View {
        var body: some View {
            HStack {
                ForEach(OnlineStatus.allCases, id: \.self, content: OnlineStatusIndicator.init(_:))
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
