//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppLocalization
import Assets
import ComposableArchitecture
import SwiftUI

private let l10n = L10n.EditProfile.Identity.self

// MARK: - View

struct IdentityView: View {
  let store: StoreOf<IdentityReducer>

  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      WithViewStore(self.store) { viewStore in
        VStack(spacing: 24) {
          ContentSection(
            header: l10n.NameSection.Header.label,
            footer: l10n.NameSection.Footer.label
          ) {
            VStack(alignment: .leading) {
              ThreeColumns(l10n.FirstName.Header.label) {
                TextField(l10n.FirstName.TextField.label, text: viewStore.binding(\.$firstName))
                  .textFieldStyle(.roundedBorder)
                  .controlSize(.large)
              } column3: {
                self.verify(viewStore.isNameVerified) { viewStore.send(.verifyNameTapped) }
              }
              ThreeColumns(l10n.LastName.Header.label) {
                TextField(l10n.LastName.TextField.label, text: viewStore.binding(\.$lastName))
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
                TextField(l10n.Email.TextField.label, text: viewStore.binding(\.$email))
                  .textFieldStyle(.roundedBorder)
                  .controlSize(.large)
              } column3: {
                self.verify(viewStore.isEmailVerified) { viewStore.send(.verifyEmailTapped) }
              }
              ThreeColumns(l10n.Phone.Header.label) {
                TextField(l10n.Phone.TextField.label, text: viewStore.binding(\.$phone))
                  .textFieldStyle(.roundedBorder)
                  .controlSize(.large)
              } column3: {
                self.verify(viewStore.isPhoneVerified) { viewStore.send(.verifyPhoneTapped) }
              }
            }
            .padding(.horizontal)
          }
        }
        .padding(.vertical, 24)
      }
    }
  }

  @ViewBuilder
  func verify(_ isVerified: Bool, action: @escaping () -> Void) -> some View {
    if isVerified {
      Self.seal()
    } else {
      Button(L10n.EditProfile.GetVerified.Action.label, action: action)
        .buttonStyle(.plain)
        .foregroundColor(.accentColor)
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
