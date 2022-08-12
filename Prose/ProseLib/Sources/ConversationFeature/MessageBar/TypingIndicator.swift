//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import Assets
import ProseCoreTCA
import SwiftUI

private let l10n = L10n.Content.MessageBar.self

// TODO: Find a better name
public enum TypingUser: Equatable {
  case jid(JID), displayName(String)

  var displayName: String {
    switch self {
    case let .jid(jid):
      let name: String = (jid.node ?? jid.domain)
      return name
        .split(separator: ".", omittingEmptySubsequences: true)
        .joined(separator: " ")
        .localizedCapitalized
    case let .displayName(displayName):
      return displayName
    }
  }
}

struct TypingIndicator: View {
  static let cornerRadius: CGFloat = 12
  static let fontSize: CGFloat = 10

  var typing: [String]

  var text: String {
    let maxNames = 3
    var components = self.typing.prefix(maxNames)
    let others = self.typing.dropFirst(maxNames)
    if !others.isEmpty {
      components.append(l10n.others(others.count))
    }
    return [
      components.formatted(.list(type: .and)),
      l10n.typing(self.typing.count),
    ].joined(separator: " ")
  }

  init(typing: [TypingUser]) {
    self.typing = typing.map(\.displayName)
  }

  var body: some View {
    if !self.typing.isEmpty {
      GeometryReader { geo in
        ZStack {
          // TODO: Handle plural in localization
          // FIXME: https://github.com/prose-im/prose-app-macos/issues/87
          Text(verbatim: self.text)
            .font(.system(size: Self.fontSize, weight: .light))
            .lineLimit(nil)
            .padding(.vertical, 2 * (Self.cornerRadius - Self.fontSize))
            .padding(.horizontal, Self.cornerRadius)
            .foregroundColor(Colors.Text.secondary.color)
            .background(
              ZStack {
                RoundedRectangle(cornerRadius: Self.cornerRadius)
                  .fill(.background)
                RoundedRectangle(cornerRadius: Self.cornerRadius)
                  .strokeBorder(Colors.Border.tertiary.color)
              }
            )
            .compositingGroup()
            .shadow(color: .black.opacity(0.0625), radius: 2, y: 1)
            .frame(maxWidth: geo.size.width, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
      }
      // Align the bottom of the typing indicator to the alignment guide, with a little offset
      .alignmentGuide(.typingIndicator) { $0[VerticalAlignment.bottom] - Self.cornerRadius }
    }
  }
}

private struct TypingIndicatorAlignment: AlignmentID {
  static func defaultValue(in context: ViewDimensions) -> CGFloat {
    // Align the typing indicator to the top of the view
    context[VerticalAlignment.top] - 1
  }
}

private extension VerticalAlignment {
  static let typingIndicator: Self = .init(TypingIndicatorAlignment.self)
}

private extension Alignment {
  // Align the typing indicator to the leading edge of the view
  static let typingIndicator: Self = .init(horizontal: .leading, vertical: .typingIndicator)
}

struct TypingIndicator_Previews: PreviewProvider {
  private struct Preview: View {
    let typing: [TypingUser]
    let name: String
    var height: CGFloat = 48
    var border: Bool = false
    var body: some View {
      VStack(spacing: 0) {
        VStack(alignment: .leading) {
          ZStack {
            RoundedRectangle(cornerRadius: 8)
              .fill(.background)
            RoundedRectangle(cornerRadius: 8)
              .strokeBorder(.separator)
          }
          .frame(height: self.height)
          .overlay(alignment: .typingIndicator) {
            TypingIndicator(typing: self.typing)
              .border(self.border ? Color.red.opacity(0.5) : .clear)
              .padding(.horizontal, 8)
          }
          Text(verbatim: self.name)
            .font(.headline)
        }
        .padding()
      }
      Divider()
    }
  }

  static var previews: some View {
    let previews = VStack(spacing: 0) {
      Group {
        Preview(typing: [], name: "Empty list")
        Preview(typing: ["marc.preview@prose.org"].map(TypingUser.jid), name: "Single name")
        Preview(
          typing: ["marc.preview@prose.org", "remi.preview@prose.org"].map(TypingUser.jid),
          name: "Two names"
        )
        Preview(
          typing: ["marc.preview@prose.org", "remi.preview@prose.org", "marc.preview@prose.org"]
            .map(TypingUser.jid),
          name: "Three names"
        )
        Preview(typing: [
          "marc.preview@prose.org", "remi.preview@prose.org", "valerian.preview@prose.org",
          "preview@prose.org",
        ].map(TypingUser.jid), name: "Four names")
        Preview(typing: [
          "marc.preview@prose.org", "remi.preview@prose.org", "valerian.preview@prose.org",
          "bot1@prose.org", "bot2@prose.org",
        ].map(TypingUser.jid), name: "Five names")
        Preview(typing: [
          "marc.preview@prose.org", "remi.preview@prose.org", "valerian.preview@prose.org",
          "marc.other@prose.org", "remi.other@prose.org",
        ].map(TypingUser.jid), name: "Five names small space")
          .frame(width: 200)
        Preview(typing: [
          "marc.preview@prose.org", "remi.preview@prose.org", "valerian.preview@prose.org",
          "preview@prose.org", "bot1@prose.org", "bot2@prose.org", "bot3@prose.org",
        ].map(TypingUser.jid), name: "More names")
      }
      Group {
        Preview(
          typing: ["Two\nlines"].map(TypingUser.displayName),
          name: "With small field",
          height: 10
        )
        Preview(
          typing: ["remi.preview@prose.org"].map(TypingUser.jid),
          name: "With border",
          border: true
        )
        Preview(typing: ["Rémi"].map(TypingUser.displayName), name: "With diacritics")
        Preview(typing: ["remi.preview@prose.org"].map(TypingUser.jid), name: "Colorful background")
          .background(Color.purple)
      }
    }
    .frame(width: 500)
    .fixedSize()
    previews
      .preferredColorScheme(.light)
      .previewDisplayName("Light")
    previews
      .preferredColorScheme(.dark)
      .previewDisplayName("Dark")
  }
}
