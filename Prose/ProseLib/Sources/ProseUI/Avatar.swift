//
//  Avatar.swift
//  Prose
//
//  Created by Rémi Bardon on 27/02/2022.
//  Copyright © 2022 Prose. All rights reserved.
//

import Assets
import Foundation
import SwiftUI

public struct Avatar: View {
    private let imageName: String
    private let size: CGFloat

    public init(_ imageName: String, size: CGFloat) {
        self.imageName = imageName
        self.size = size
    }

    public var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .background(Color.borderSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay {
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(Color(nsColor: .separatorColor))
            }
    }
}

// MARK: - Previews

#if DEBUG
    import PreviewAssets

    struct Avatar_Previews: PreviewProvider {
        private struct Preview: View {
            var body: some View {
                VStack {
                    Avatar(PreviewImages.Avatars.valerian.rawValue, size: 48)
                    Avatar(PreviewImages.Avatars.valerian.rawValue, size: 24)
                }
                .padding()
                .previewLayout(.sizeThatFits)
            }
        }

        static var previews: some View {
            Preview()
                .preferredColorScheme(.light)
                .previewDisplayName("Light mode")
            Preview()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark mode")
            Preview()
                .redacted(reason: .placeholder)
                .previewDisplayName("Placeholder")
        }
    }
#endif
