//
//  ContentView.swift
//  Prose
//
//  Created by Valerian Saliou on 11/15/21.
//

import SwiftUI

struct ContentView: View {
    let selection: SidebarID?
    
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
        switch selection {
        case .person(let id), .group(let id):
            ConversationScreen(chatId: id)
        case .none:
            Text("No selection 🤷")
        default:
            Text("Not supported yet")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(selection: .person(id: "id-valerian"))
    }
}
