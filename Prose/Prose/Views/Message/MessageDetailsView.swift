//
//  MessageDetailsView.swift
//  Prose
//
//  Created by Valerian Saliou on 11/23/21.
//

import SwiftUI

struct MessageDetailsView: View {
    struct SectionGroupStyle: GroupBoxStyle {
        private static let sidesPadding: CGFloat = 15
        
        func makeBody(configuration: Configuration) -> some View {
            VStack(spacing: 8) {
                ContentMessageDetailsTitleComponent(
                    label: configuration.label,
                    sidesPadding: Self.sidesPadding
                )
                
                configuration.content
                    .padding(.horizontal, Self.sidesPadding)
            }
        }
    }
    
    var avatar: String
    var name: String
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 12) {
                ContentMessageDetailsIdentityComponent(
                    avatar: avatar,
                    name: name
                )
                ContentMessageDetailsQuickActionsComponent()
            }
            .padding()
            .frame(maxWidth: .infinity)
            
            VStack(spacing: 24) {
                ContentMessageDetailsInformationComponent()
                ContentMessageDetailsSecurityComponent()
                ContentMessageDetailsActionsComponent()
            }
        }
        .groupBoxStyle(SectionGroupStyle())
        .background(.background)
    }
}

struct MessageDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        MessageDetailsView(
            avatar: "avatar-valerian",
            name: "Valerian Saliou"
        )
            .frame(width: 220.0, height: 720, alignment: .top)
    }
}
