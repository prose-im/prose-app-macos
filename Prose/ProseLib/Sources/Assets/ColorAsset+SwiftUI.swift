//
//  ColorAsset+SwiftUI.swift
//  Prose
//
//  Created by Rémi Bardon on 17/06/2022.
//

import SwiftUI

public extension ColorAsset {
    var swiftUIColor: SwiftUI.Color {
        SwiftUI.Color(nsColor: self.color)
    }
}
