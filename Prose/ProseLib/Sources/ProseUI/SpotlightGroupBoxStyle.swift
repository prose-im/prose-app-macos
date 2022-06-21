//
//  SpotlightGroupBoxStyle.swift
//  Prose
//
//  Created by Rémi Bardon on 27/03/2022.
//

import SwiftUI

public extension GroupBoxStyle where Self == SpotlightGroupBoxStyle {
    static var spotlight: Self { SpotlightGroupBoxStyle() }
}

public struct SpotlightGroupBoxStyle: GroupBoxStyle {
    public func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 12) {
            configuration.label
                .padding(.horizontal, 4)
            VStack(spacing: 6) {
                configuration.content
                    .modifier(SpotlightItemBackground())
            }
        }
    }
}

private struct SpotlightItemBackground: ViewModifier {
    var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 3)
    }

    func body(content: Content) -> some View {
        content
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background {
                shape
                    .fill(.background)
                    .shadow(color: .gray.opacity(0.5), radius: 1)
            }
    }
}

#if DEBUG
    import PreviewAssets

    struct SpotlightGroupBoxStyle_Previews: PreviewProvider {
        static var previews: some View {
            GroupBox {
                Text("GroupBox Content goes here")
            } label: {
                HStack {
                    Label("support", systemImage: "circle.grid.2x2")
                        .labelStyle(.coloredIcon)
                        .font(.title2.bold())
                    Spacer()
                    Text("dummy")
                        .foregroundColor(.secondary)
                }
            }
            .groupBoxStyle(.spotlight)
        }
    }

    struct SpotlightItemBackground_Previews: PreviewProvider {
        static var previews: some View {
            Text("GroupBox Content goes here")
                .modifier(SpotlightItemBackground())
                .padding()
        }
    }
#endif
