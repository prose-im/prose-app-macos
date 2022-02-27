//
//  MessageDetailsView.swift
//  Prose
//
//  Created by Valerian Saliou on 11/23/21.
//

import SwiftUI

struct MessageDetailsView: View {
    private static let titleSpacing: CGFloat = 9
    private static let sidesPadding: CGFloat = 15
    
    var avatar: String
    var name: String
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 10) {
                    VStack(spacing: 12) {
                        ContentMessageDetailsIdentityComponent(
                            avatar: avatar,
                            name: name
                        )
                        ContentMessageDetailsQuickActionsComponent()
                    }
                    .padding(.vertical)
                    
                    VStack(spacing: 22) {
                        informationSection()
                        securitySection()
                        actionsSection()
                    }
                }
            }
        }
        .background(.background)
    }
    
    private func informationSection() -> some View {
        VStack(alignment: .leading, spacing: Self.titleSpacing) {
            ContentMessageDetailsTitleComponent(
                title: "content_message_details_information_title".localized(),
                paddingSides: Self.sidesPadding
            )
            
            ContentMessageDetailsInformationComponent()
                .padding(.horizontal, Self.sidesPadding)
        }
    }
    
    private func securitySection() -> some View {
        VStack(alignment: .leading, spacing: Self.titleSpacing) {
            ContentMessageDetailsTitleComponent(
                title: "content_message_details_security_title".localized(),
                paddingSides: Self.sidesPadding
            )
            
            ContentMessageDetailsSecurityComponent()
                .padding(.horizontal, Self.sidesPadding)
        }
    }
    
    private func actionsSection() -> some View {
        VStack(alignment: .leading, spacing: Self.titleSpacing - 3) {
            let paddingActionsSides: CGFloat = 6
            
            ContentMessageDetailsTitleComponent(
                title: "content_message_details_actions_title".localized(),
                paddingSides: Self.sidesPadding
            )
            
            ContentMessageDetailsActionsComponent(
                paddingSides: Self.sidesPadding - paddingActionsSides
            )
                .padding(.horizontal, paddingActionsSides)
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
