//
//  Counter.swift
//  Prose
//
//  Created by Valerian Saliou on 11/30/21.
//

import SwiftUI

struct Counter: View {
    var count = 0

    var body: some View {
        if count > 0 {
            Text(count, format: .number)
                .font(.system(size: 11, weight: .semibold))
                .padding(.vertical, 2)
                .padding(.horizontal, 5)
                .foregroundColor(.secondary)
                .background {
                    Capsule()
                        .fill(.quaternary)
                }
        }
    }
}

struct Counter_Previews: PreviewProvider {
    private struct Preview: View {
        private static let values = [0, 2, 10, 1_000]

        var body: some View {
            VStack {
                ForEach(Self.values, id: \.self) { count in
                    HStack {
                        Text(count.description)
                            .unredacted()
                        Spacer()
                        Counter(count: count)
                    }
                }
            }
            .frame(width: 128)
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
        Preview()
            .redacted(reason: .placeholder)
            .previewDisplayName("Placeholder")
    }
}
