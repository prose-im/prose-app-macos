//
//  ToolbarDivider.swift
//  Prose
//
//  Created by Rémi Bardon on 27/03/2022.
//  Copyright © 2022 Prose. All rights reserved.
//

import SwiftUI

public struct ToolbarDivider: View {
    public init() {}

    public var body: some View {
        HStack {
            Divider()
                .frame(height: 24)
        }
    }
}
