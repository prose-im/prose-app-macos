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
                        .frame(height: 2)
                     
                    VStack(spacing: 22) {
                        let titleSpacing: CGFloat = 9
                        let paddingSides: CGFloat = 15
                        
                        VStack(alignment: .leading, spacing: titleSpacing) {
                            // Information
                            ContentMessageDetailsTitleComponent(
                                title: "content_message_details_information_title".localized(),
                                paddingSides: paddingSides
                            )
                            
                            ContentMessageDetailsInformationComponent()
                                .padding(.horizontal, paddingSides)
                        }
                        
                        // Security
                        VStack(alignment: .leading, spacing: titleSpacing) {
                            ContentMessageDetailsTitleComponent(
                                title: "content_message_details_security_title".localized(),
                                paddingSides: paddingSides
                            )
                            
                            ContentMessageDetailsSecurityComponent()
                                .padding(.horizontal, paddingSides)
                        }
                        
                        // Actions
                        VStack(alignment: .leading, spacing: titleSpacing - 3) {
                            let paddingActionsSides: CGFloat = 6
                            
                            ContentMessageDetailsTitleComponent(
                                title: "content_message_details_actions_title".localized(),
                                paddingSides: paddingSides
                            )
                            
                            ContentMessageDetailsActionsComponent(
                                paddingSides: paddingSides - paddingActionsSides
                            )
                                .padding(.horizontal, paddingActionsSides)
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
            .background(.white)
            .frame(width: 220.0, height: 720)
    }
}
