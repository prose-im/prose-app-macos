//
//  AccountPickerRow.swift
//  Prose
//
//  Created by Valerian Saliou on 12/12/21.
//

import ProseUI
import SwiftUI

struct AccountPickerRow: View {
    struct ViewModel: Equatable, Identifiable {
        let teamLogo: String
        let teamDomain: String
        let userName: String
        var id: String { self.teamDomain }
    }

    let viewModel: ViewModel

    var body: some View {
        HStack {
            Avatar(.placeholder, size: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: viewModel.userName)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(verbatim: viewModel.teamDomain)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct AccountPickerRow_Previews: PreviewProvider {
    static var previews: some View {
        AccountPickerRow(viewModel: .init(
            teamLogo: "logo-crisp",
            teamDomain: "crisp.chat",
            userName: "Baptiste"
        ))
    }
}
