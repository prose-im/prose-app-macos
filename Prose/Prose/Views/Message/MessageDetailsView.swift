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
                VStack(spacing: 10) {
                    Spacer()
                    
                    VStack(spacing: 3) {
                        ContentMessageDetailsIdentityComponent(
                            avatar: avatar,
                            name: name
                        )
                        
                        Spacer()
                        
                        ContentMessageDetailsQuickActionsComponent()
                    }
                    
                    Spacer()
                     
                    VStack(spacing: 16) {
                        let paddingSides: CGFloat = 15
                        
                        VStack(alignment: .leading, spacing: 0) {
                            // Information
                            ContentMessageDetailsTitleComponent(
                                title: "content_message_details_information_title".localized(),
                                paddingSides: paddingSides
                            )
                            
                            ContentMessageDetailsInformationComponent()
                                .padding(.horizontal, paddingSides)
                        }
                        
                        // Security
                        VStack(alignment: .leading, spacing: 0) {
                            ContentMessageDetailsTitleComponent(
                                title: "content_message_details_security_title".localized(),
                                paddingSides: paddingSides
                            )
                            
                            ContentMessageDetailsSecurityComponent()
                                .padding(.horizontal, paddingSides)
                        }
                        
                        // Actions
                        VStack(alignment: .leading, spacing: 0) {
                            ContentMessageDetailsTitleComponent(
                                title: "content_message_details_actions_title".localized(),
                                paddingSides: paddingSides
                            )
                            
                            ContentMessageDetailsActionsComponent()
                                .padding(.horizontal, paddingSides)
                        }
                    }
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
