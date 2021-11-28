//
//  MessageView.swift
//  Prose
//
//  Created by Valerian Saliou on 11/21/21.
//

import SwiftUI

struct MessageView: View {
    var body: some View {
        HStack(spacing: 0) {
            MessageMessengerView()
            
            Divider()
            
            MessageDetailsView(
                avatar: "avatar-valerian",
                name: "Valerian Saliou"
            )
                .frame(width: 200.0)
        }
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView()
    }
}
