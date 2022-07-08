//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import Assets
import SwiftUI

private let l10n = L10n.EditProfile.Identity.self

struct IdentityView: View {
  @State var isNameVerified: Bool = false
  @State var isEmailVerified: Bool = true
  @State var isPhoneVerified: Bool = false

  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      VStack(spacing: 24) {
        ContentSection(
          header: l10n.NameSection.Header.label,
          footer: l10n.NameSection.Footer.label
        ) {
          VStack(alignment: .leading) {
            ThreeColumns(l10n.FirstName.Header.label) {
              TextField(l10n.FirstName.TextField.label, text: .constant("Baptiste"))
                .textFieldStyle(.roundedBorder)
                .controlSize(.large)
            } column3: {
              self.verify(\._isNameVerified)
            }
            ThreeColumns(l10n.LastName.Header.label) {
              TextField(l10n.LastName.TextField.label, text: .constant("Jamin"))
                .textFieldStyle(.roundedBorder)
                .controlSize(.large)
            }
          }
          .padding(.horizontal)
        }
        Divider()
          .padding(.horizontal)
        ContentSection(
          header: l10n.ContactSection.Header.label,
          footer: l10n.ContactSection.Footer.label
        ) {
          VStack(alignment: .leading) {
            ThreeColumns(l10n.Email.Header.label) {
              TextField(l10n.Email.TextField.label, text: .constant("baptiste@crisp.chat"))
                .textFieldStyle(.roundedBorder)
                .controlSize(.large)
            } column3: {
              self.verify(\._isEmailVerified)
            }
            ThreeColumns(l10n.Phone.Header.label) {
              TextField(l10n.Phone.TextField.label, text: .constant("+33631893345"))
                .textFieldStyle(.roundedBorder)
                .controlSize(.large)
            } column3: {
              self.verify(\._isPhoneVerified)
            }
          }
          .padding(.horizontal)
        }
      }
      .padding(.vertical, 24)
    }
  }

  @ViewBuilder
  func verify(_ isVerified: WritableKeyPath<Self, State<Bool>>) -> some View {
    if self[keyPath: isVerified].wrappedValue {
      Self.seal()
    } else {
      Button(L10n.EditProfile.GetVerified.Action.label) {
        self[keyPath: isVerified].wrappedValue = true
      }
      .buttonStyle(.plain)
      .foregroundColor(.blue)
    }
  }

  static func seal() -> some View {
    HStack(spacing: 4) {
      Image(systemName: "checkmark.seal.fill")
        .accessibilityHidden(true)
      Text(verbatim: L10n.EditProfile.GetVerified.StateVerified.label)
    }
    .foregroundColor(Colors.State.green.color)
    .accessibilityElement(children: .combine)
  }
}

struct IdentityView_Previews: PreviewProvider {
  static var previews: some View {
    IdentityView()
      .frame(width: 480, height: 512)
  }
}
