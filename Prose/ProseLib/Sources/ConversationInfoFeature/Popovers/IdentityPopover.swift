//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import Assets
import ProseUI
import SwiftUI

private let l10n = L10n.Info.Identity.Popover.self

struct IdentityPopover: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack {
        ZStack {
          Circle().fill(Colors.State.green.color)
            .frame(width: 32, height: 32)
          Image(systemName: "checkmark.seal.fill")
            .font(.system(size: 18))
            .foregroundColor(.white)
        }
        .accessibilityHidden(true)
        VStack(alignment: .leading) {
          Text(verbatim: l10n.Header.title("Valerian Saliou"))
            .font(.headline)
          Text(verbatim: l10n.Header.subtitle)
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
      }
      .padding(.horizontal, 24)
      .padding(.vertical, 12)
      Divider()
      VStack(alignment: .customCenter, spacing: 8) {
        HStack {
          Label {
            Text(verbatim: l10n.Fingerprint.StateVerified.label("C648A"))
          } icon: {
            Image(systemName: "key")
              .foregroundColor(Colors.State.green.color)
          }
          HelpButton { Text("TODO").padding() }
            .disabled(true)
        }
        HStack {
          Label {
            Text(verbatim: l10n.Email.StateVerified.label("valerian@crisp.chat"))
          } icon: {
            Image(systemName: "envelope")
              .foregroundColor(Colors.State.green.color)
          }
          HelpButton { Text("TODO").padding() }
            .disabled(true)
        }
        HStack {
          Label {
            Text(verbatim: l10n.Phone.StateVerified.label("+33631210280"))
          } icon: {
            Image(systemName: "phone")
              .foregroundColor(Colors.State.green.color)
          }
          HelpButton { Text("TODO").padding() }
            .disabled(true)
        }
        HStack {
          Label {
            Text(verbatim: l10n.GovernmentId.StateNotProvided.label)
          } icon: {
            Image(systemName: "signature")
              .foregroundColor(.secondary)
          }
          HelpButton { Text("TODO").padding() }
            .disabled(true)
        }
      }
      .labelStyle(MyLabelStyle())
      .symbolVariant(.fill)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, 24)
      .padding(.vertical, 12)
      .background(Color(nsColor: .windowBackgroundColor))
      Divider()
      // NOTE: We're using `[…](…)` here, because the default Markdown parser doesn't recognize the link.
      Text(l10n.Footer.label("[id.prose.org](id.prose.org)").asMarkdown)
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .font(.footnote)
    }
    .multilineTextAlignment(.leading)
    .frame(width: 480)
  }
}

struct MyLabelStyle: LabelStyle {
  func makeBody(configuration: Configuration) -> some View {
    HStack(spacing: 4) {
      configuration.icon
        .alignmentGuide(.customCenter) { $0[HorizontalAlignment.center] }
        .frame(width: 24)
        .accessibilityHidden(true)
      configuration.title
        .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

struct CustomCenter: AlignmentID {
  static func defaultValue(in context: ViewDimensions) -> CGFloat {
    context[HorizontalAlignment.center]
  }
}

extension HorizontalAlignment {
  static let customCenter: HorizontalAlignment = .init(CustomCenter.self)
}

struct IdentityPopover_Previews: PreviewProvider {
  struct Preview: View {
    @State private var isShowingPopover: Bool = true
    var body: some View {
      Button("Show popover") { self.isShowingPopover = true }
        .popover(isPresented: self.$isShowingPopover, content: IdentityPopover.init)
        .padding()
    }
  }

  static var previews: some View {
    IdentityPopover()
    Preview()
  }
}
