//
//  TableFooterButton.swift
//  Prose
//
//  Created by Valerian Saliou on 12/12/21.
//

import SwiftUI

/// This is supposed to look like a macOS "Gradient button".
/// See https://developers.apple.com/design/human-interface-guidelines/components/menus-and-actions/buttons#gradient-buttons/
/// for more information.
struct TableFooterButton: View {
    var actionName: String

    var body: some View {
        HStack(spacing: 0) {
            Button { logger.debug("Button tapped") } label: {
                Image(systemName: actionName)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.primary)
                    // Make tap area bigger
                    .frame(width: 26)
                    .frame(maxHeight: .infinity)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Divider()
                .padding(.vertical, 3.0)
        }
    }
}

struct TableFooterButton_Previews: PreviewProvider {
    static var previews: some View {
        TableFooterButton(
            actionName: "plus"
        )
    }
}
