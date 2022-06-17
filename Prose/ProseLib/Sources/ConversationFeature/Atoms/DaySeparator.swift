//
//  DaySeparator.swift
//  Prose
//
//  Created by Rémi Bardon on 02/03/2022.
//  Copyright © 2022 Prose. All rights reserved.
//

import Assets
import SwiftUI

struct DaySeparator: View {
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    let date: Date

    var body: some View {
        HStack {
            Asset.Color.Border.tertiary.swiftUIColor
                .frame(height: 1)
            Text(date, formatter: Self.formatter)
                .layoutPriority(1)
                .foregroundColor(.secondary)
            Asset.Color.Border.tertiary.swiftUIColor
                .frame(height: 1)
        }
    }
}

struct DaySeparator_Previews: PreviewProvider {
    static var previews: some View {
        DaySeparator(date: .now)
    }
}
