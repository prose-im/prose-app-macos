//
//  Info+EntryRow.swift
//  Prose
//
//  Created by Valerian Saliou on 12/1/21.
//

import SwiftUI

enum ContentMessageDetailsEntryImage {
    case system(String)
    case literal(String)
}

extension ContentMessageDetailsEntryImage: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .system(inner):
            hasher.combine(0)
            hasher.combine(inner)
        case let .literal(inner):
            hasher.combine(1)
            hasher.combine(inner)
        }
    }
}

struct ContentMessageDetailsEntryOption: Hashable {
    let value: String
    let image: ContentMessageDetailsEntryImage
    var valueColor: Color = .textPrimaryLight
    var imageColor: Color = .stateGrey
    var informationAction: Bool = false
}

extension ConversationInfoView {
    struct EntryRow: View {
        @Environment(\.redactionReasons) private var redactionReasons

        var entry: ContentMessageDetailsEntryOption

        var body: some View {
            let iconFrameMinWidth: CGFloat = 16

            HStack(alignment: .center, spacing: 8) {
                switch entry.image {
                case let .system(inner):
                    Image(systemName: inner)
                        .font(.system(size: 13))
                        .foregroundColor(entry.imageColor)
                        .frame(width: iconFrameMinWidth, alignment: .center)
                        .unredacted()
                case let .literal(inner):
                    Text(verbatim: inner)
                        .frame(width: iconFrameMinWidth, alignment: .center)
                }

                Text(verbatim: entry.value)
                    .font(.system(size: 13))
                    .foregroundColor(entry.valueColor)

                Spacer()

                if entry.informationAction {
                    Button(action: {}) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 13))
                            .foregroundColor(Color.primary.opacity(0.50))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .unredacted()
                    .disabled(redactionReasons.contains(.placeholder))
                }
            }
        }
    }
}

struct ConversationInfoView_EntryRow_Previews: PreviewProvider {
    static var previews: some View {
        ConversationInfoView.EntryRow(
            entry: .init(
                value: "Lima, Peru",
                image: .system("location.fill"),
                informationAction: true
            )
        )
    }
}
