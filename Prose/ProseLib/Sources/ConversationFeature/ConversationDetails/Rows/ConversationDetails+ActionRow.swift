//
//  ConversationDetails+ActionRow.swift
//  Prose
//
//  Created by Valerian Saliou on 12/1/21.
//

import SwiftUI

struct ContentMessageDetailsActionOption: Hashable {
    let name: String
    var deployTo: Bool = false
}

extension ConversationDetailsView {
    
    struct ActionRow: View {
        var action: ContentMessageDetailsActionOption
        
        var body: some View {
            HStack(spacing: 6) {
                Text(verbatim: action.name)
                    .font(.system(size: 12))
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimaryLight)
                
                Spacer()
                
                if action.deployTo {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10))
                        .foregroundColor(.textPrimary)
                }
            }
            .padding(.vertical, 4.0)
        }
    }
    
}

struct ConversationDetailsView_ActionRow_Previews: PreviewProvider {
    static var previews: some View {
        ConversationDetailsView.ActionRow(
            action: .init(
                name: "View full profile",
                deployTo: true
            )
        )
    }
}
