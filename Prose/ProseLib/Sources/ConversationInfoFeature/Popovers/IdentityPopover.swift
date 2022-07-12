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
  var fullName: String = "Valerian Saliou"
  var signatureFingerprint: VerifiableWithData = .verified("C648A")
  var email: VerifiableWithData = .verified("valerian@crisp.chat")
  var phone: VerifiableWithData = .verified("+33631210280")
  var governmentId: Verifiable = .notVerified
  // NOTE: We're using `[…](…)` here, because the default Markdown parser doesn't recognize the link.
  var identityServer: String = "[id.prose.org](id.prose.org)"

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
          Text(verbatim: l10n.Header.title(self.fullName))
            .font(.headline)
          Text(verbatim: l10n.Header.subtitle)
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
      }
      .padding(.horizontal, 24)
      .padding(.vertical, 12)
      Divider()
      VStack(alignment: .labelIconCenter, spacing: 8) {
        HStack {
          Self.label(self.signatureFingerprint, icon: "key") {
            $0.text(
              notVerified: l10n.Fingerprint.StateNotVerified.label,
              verified: l10n.Fingerprint.StateVerified.label
            )
          }
          HelpButton { Text("TODO").padding() }
            .disabled(true)
        }
        HStack {
          Self.label(self.email, icon: "envelope") {
            $0.text(
              notVerified: l10n.Email.StateNotVerified.label,
              verified: l10n.Email.StateVerified.label
            )
          }
          HelpButton { Text("TODO").padding() }
            .disabled(true)
        }
        HStack {
          Self.label(self.phone, icon: "phone") {
            $0.text(
              notVerified: l10n.Phone.StateNotVerified.label,
              verified: l10n.Phone.StateVerified.label
            )
          }
          HelpButton { Text("TODO").padding() }
            .disabled(true)
        }
        HStack {
          Self.label(self.governmentId, icon: "signature") {
            $0.text(
              notVerified: l10n.GovernmentId.StateNotProvided.label,
              verified: l10n.GovernmentId.StateVerified.label
            )
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
      Text(l10n.Footer.label(self.identityServer).asMarkdown)
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .font(.footnote)
    }
    .multilineTextAlignment(.leading)
    .frame(width: 480)
  }

  static func label(
    _ item: VerifiableWithData,
    icon: String,
    text: (VerifiableWithData) -> String
  ) -> some View {
    Self.label(icon: icon, text: text(item), color: item.color)
  }

  static func label(
    _ item: Verifiable,
    icon: String,
    text: (Verifiable) -> String
  ) -> some View {
    Self.label(icon: icon, text: text(item), color: item.color)
  }

  static func label(icon: String, text: String, color: Color) -> some View {
    Label { Text(verbatim: text) } icon: {
      Image(systemName: icon)
        .foregroundColor(color)
    }
  }
}

private struct MyLabelStyle: LabelStyle {
  func makeBody(configuration: Configuration) -> some View {
    HStack(spacing: 4) {
      configuration.icon
        .alignmentGuide(.labelIconCenter) { $0[HorizontalAlignment.center] }
        .frame(width: 24)
        .accessibilityHidden(true)
      configuration.title
        .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

private struct LabelIconCenter: AlignmentID {
  static func defaultValue(in context: ViewDimensions) -> CGFloat {
    context[HorizontalAlignment.center]
  }
}

private extension HorizontalAlignment {
  static let labelIconCenter: HorizontalAlignment = .init(LabelIconCenter.self)
}

extension IdentityPopover {
  enum VerifiableWithData: Equatable {
    case notVerified, verified(String)

    var color: Color {
      switch self {
      case .notVerified: return Color.secondary
      case .verified: return Colors.State.green.color
      }
    }

    func text(notVerified: String, verified: (UnsafePointer<CChar>) -> String) -> String {
      switch self {
      case .notVerified: return notVerified
      case let .verified(data): return verified(data)
      }
    }
  }

  enum Verifiable: Equatable {
    case notVerified, verified

    var color: Color {
      switch self {
      case .notVerified: return Color.secondary
      case .verified: return Colors.State.green.color
      }
    }

    func text(notVerified: String, verified: String) -> String {
      switch self {
      case .notVerified: return notVerified
      case .verified: return verified
      }
    }
  }
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
