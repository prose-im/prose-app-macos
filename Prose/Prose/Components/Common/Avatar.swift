//
//  Avatar.swift
//  Prose
//
//  Created by Rémi Bardon on 27/02/2022.
//  Copyright © 2022 Prose. All rights reserved.
//

import Foundation
import SwiftUI

struct Avatar: View {
    
    private let imageName: String
    private let size: CGFloat
    
    init(_ imageName: String, size: CGFloat) {
        self.imageName = imageName
        self.size = size
    }
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .background(Color.borderSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
    
}

struct Avatar_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Avatar(PreviewImages.Avatars.valerian.rawValue, size: 48)
            Avatar(PreviewImages.Avatars.valerian.rawValue, size: 24)
        }
        .padding()
    }
}
