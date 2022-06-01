//
//  NavigationDestinationView.swift
//  Prose
//
//  Created by Valerian Saliou on 11/15/21.
//

import ComposableArchitecture
import ConversationFeature
import ProseUI
import SwiftUI

// swiftlint:disable file_types_order

// MARK: - View

/// The view displayed in the middle of the screen when a row is selected in the left sidebar.
///
/// - TODO: Migrate to TCA once `ConversationScreen` supports it.
struct NavigationDestinationView: View {
    let selection: Route?

    var body: some View {
        content()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("")
            .toolbar {
                ContentCommonToolbarComponent()
            }
    }

    @ViewBuilder
    private func content() -> some View {
        switch self.selection {
        case let .person(id), let .group(id):
            ConversationScreen(chatId: id)
        case .none:
            Text("No selection 🤷")
        case let .some(value):
            Text("\(String(describing: value)) (not supported yet)")
        }
    }
}

// MARK: - Previews

struct NavigationDestinationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationDestinationView(selection: .person(id: "id-valerian"))
    }
}
