//
//  SwadowedButtonStyle.swift
//  Prose
//
//  Created by Rémi Bardon on 27/03/2022.
//

import SwiftUI

public struct SwadowedButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.5 : 1)
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background {
                RoundedRectangle(cornerRadius: 6)
                    .fill(.background)
                    .shadow(color: .gray.opacity(0.5), radius: 2)
            }
    }
}

public extension ButtonStyle where Self == SwadowedButtonStyle {
    static var shadowed: Self { SwadowedButtonStyle() }
}

struct SwadowedButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Button(action: {}) {
                Label("Reply", systemImage: "arrowshape.turn.up.right")
                    .frame(maxWidth: .infinity)
            }
            .foregroundColor(.accentColor)
            Button(action: {}) {
                Text("Mark read")
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(width: 96)
        .labelStyle(.vertical)
        .buttonStyle(.shadowed)
        .padding()
        .background(.background)
    }
}
