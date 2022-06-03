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

struct EntryRow: View {
    @Environment(\.redactionReasons) private var redactionReasons

    var entry: ContentMessageDetailsEntryOption

    var body: some View {
        let iconFrameMinWidth: CGFloat = 16

        HStack(alignment: .center, spacing: 8) {
            Label {
                Text(verbatim: entry.value)
                    .foregroundColor(entry.valueColor)
            } icon: {
                switch entry.image {
                case let .system(inner):
                    Image(systemName: inner)
                        .foregroundColor(entry.imageColor)
                        .unredacted()
                case let .literal(inner):
                    Text(verbatim: inner)
                }
            }
            .labelStyle(EntryRowLabelStyle())

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

struct EntryRowLabelStyle: LabelStyle {
    static let iconFrameMinWidth: CGFloat = 16

    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            configuration.icon
                .foregroundColor(.stateGrey)
                .frame(width: Self.iconFrameMinWidth, alignment: .center)

            configuration.title
                .foregroundColor(.textPrimaryLight)
        }
        .font(.system(size: 13))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ConversationInfoView_EntryRow_Previews: PreviewProvider {
    static var previews: some View {
        EntryRow(
            entry: .init(
                value: "Lima, Peru",
                image: .system("location.fill"),
                informationAction: true
            )
        )
    }
}
