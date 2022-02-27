//
//  SidebarCounter.swift
//  Prose
//
//  Created by Valerian Saliou on 11/30/21.
//

import SwiftUI

struct SidebarCounter: View {
    
    private let count: UInt16?
    
    init(count: UInt16? = nil) {
        self.count = count
    }
    
    var body: some View {
        if let count = count, count > 0 {
            Text(count, format: .number)
                .font(.system(size: 11, weight: .semibold))
                .padding(.vertical, 2)
                .padding(.horizontal, 5)
                .foregroundColor(.secondary)
                .background {
                    Capsule()
                        .fill(.quaternary)
                }
        }
    }
    
}

struct SidebarCounter_Previews: PreviewProvider {
    
    private struct Preview: View {
        
        private static let values: [UInt16?] = [nil, 0, 2, 10, 1000]
        
        var body: some View {
            VStack {
                ForEach(Self.values, id: \.self) { count in
                    HStack {
                        Text(count?.description ?? "nil")
                        Spacer()
                        SidebarCounter(count: count)
                    }
                }
            }
            .frame(width: 128)
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
