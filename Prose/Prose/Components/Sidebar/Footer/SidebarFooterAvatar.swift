//
//  SidebarFooterAvatar.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

struct SidebarFooterAvatar: View {
    
    private let avatar: String
    private let status: OnlineStatus
    private let size: CGFloat
    
    init(
        avatar: String,
        status: OnlineStatus = .offline,
        size: CGFloat = 32
    ) {
        self.avatar = avatar
        self.status = status
        self.size = size
    }
    
    var body: some View {
        ZStack {
            Avatar(avatar, size: size)
                .overlay(alignment: .bottomTrailing) {
                    statusIndicator()
                        // Offset of half the size minus 2 points (otherwise it looks odd)
                        .alignmentGuide(.trailing) { d in d.width / 2 + 2 }
                        .alignmentGuide(.bottom) { d in d.height / 2 + 2 }
                }
        }
    }
    
    @ViewBuilder
    private func statusIndicator() -> some View {
        if status != .offline {
            OnlineStatusIndicator(status: status)
                .padding(2)
                .background {
                    Circle()
                        .fill(Color.white)
                }
        }
    }
    
}

struct SidebarFooterAvatar_Previews: PreviewProvider {
    
    private struct Preview: View {
        
        var body: some View {
            HStack {
                ForEach(OnlineStatus.allCases, id: \.self) { status in
                    SidebarFooterAvatar(
                        avatar: PreviewImages.Avatars.valerian.rawValue,
                        status: status
                    )
                }
            }
            .padding()
        }
        
    }
    
    static var previews: some View {
        Preview()
            .preferredColorScheme(.light)
            .previewDisplayName("Light")
        
        Preview()
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark")
    }
    
}
