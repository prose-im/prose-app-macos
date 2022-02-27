//
//  ContentMessageDetailsActionsComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/23/21.
//

import SwiftUI

struct ContentMessageDetailsActionsComponent: View {
    let actions: [ContentMessageDetailsActionOption] = [
        .init(
            name: "content_message_details_actions_shared_files".localized(),
            deployTo: true
        ),
        .init(
            name: "content_message_details_actions_encryption_settings".localized(),
            deployTo: true
        ),
        .init(
            name: "content_message_details_actions_remove_contact".localized()
        ),
        .init(
            name: "content_message_details_actions_block".localized()
        ),
    ]
    
    var body: some View {
        GroupBox("content_message_details_actions_title".localized()) {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(actions, id: \.self) { action in
                    ContentMessageDetailsActionComponent(
                        action: action
                    )
                }
            }
        }
    }
}

struct ContentMessageDetailsActionsComponent_Previews: PreviewProvider {
    static var previews: some View {
        ContentMessageDetailsActionsComponent()
    }
}
