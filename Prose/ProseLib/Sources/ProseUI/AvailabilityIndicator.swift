//
//  AvailabilityIndicator.swift
//  Prose
//
//  Created by Valerian Saliou on 14/06/2022.
//

import Assets
import SharedModels
import SwiftUI

public struct AvailabilityIndicator: View {
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
                .fill(availability.fillColor)
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
