//
//  MessageDetailsView.swift
//  Prose
//
//  Created by Valerian Saliou on 11/23/21.
//

import SwiftUI

struct MessageDetailsView: View {
    var avatar: String
    var name: String
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(spacing: 14) {
                    Spacer()
                    
                    VStack(spacing: 3) {
                        ContentMessageDetailsIdentityComponent(
                            avatar: avatar,
                            name: name
                        )
                        
                        Spacer()
                        
                        ContentMessageDetailsQuickActionsComponent()
                    }
                     
                    VStack(spacing: 10) {
                        // Information
                        Text("content_message_details_information_title".localized())
                        
                        ContentMessageDetailsInformationComponent()
                        
                        // Security
                        Text("content_message_details_security_title".localized())
                        
                        ContentMessageDetailsSecurityComponent()
                        
                        // Actions
                        Text("content_message_details_actions_title".localized())
                        
                        ContentMessageDetailsActionsComponent()
                    }
                    
                    Spacer()
                }
            }
        }
    }
}

struct MessageDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        MessageDetailsView(
            avatar: "avatar-valerian",
            name: "Valerian Saliou"
        )
    }
}
