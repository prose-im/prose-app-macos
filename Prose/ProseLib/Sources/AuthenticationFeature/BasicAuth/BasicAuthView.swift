//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppLocalization
import ComposableArchitecture
import ProseUI
import SwiftUI
import SwiftUINavigation

private let l10n = L10n.Authentication.BasicAuth.self

struct BasicAuthView: View {
  let store: StoreOf<BasicAuthReducer>

  @ObservedObject var viewStore: ViewStoreOf<BasicAuthReducer>
  @FocusState private var focusedField: BasicAuthReducer.State.Field?

  init(store: StoreOf<BasicAuthReducer>) {
    self.store = store
    self.viewStore = ViewStore(store)
  }

  var body: some View {
    VStack(spacing: 32) {
      VStack {
        TextField(l10n.Form.ChatAddress.placeholder, text: self.viewStore.binding(\.$jid))
          .onSubmit { self.viewStore.send(.fieldSubmitted(.address)) }
          .textContentType(.username)
          .disableAutocorrection(true)
          .focused(self.$focusedField, equals: .address)
          .overlay(alignment: .trailing) {
            HelpButton(content: Self.chatAddressPopover)
              .alignmentGuide(.trailing) { d in d[.trailing] - 24 }
          }
        SecureField(l10n.Form.Password.placeholder, text: self.viewStore.binding(\.$password))
          .onSubmit { self.viewStore.send(.fieldSubmitted(.password)) }
          .textContentType(.password)
          .disableAutocorrection(true)
          .focused(self.$focusedField, equals: .password)
      }
      .disabled(self.viewStore.isLoading)

      Button(action: { self.viewStore.send(.submitButtonTapped) }) {
        Text(self.viewStore.isLoading ? l10n.Cancel.Action.title : l10n.LogIn.Action.title)
          .frame(minWidth: 196)
      }
      .overlay(alignment: .leading) {
        if self.viewStore.isLoading {
          ProgressView()
            .scaleEffect(0.5, anchor: .center)
        }
      }

      HStack(spacing: 16) {
        Button(l10n.PasswordLost.Action.title) {
          self.viewStore.send(.showPopoverTapped(.passwordLost))
        }
        .popover(
          unwrapping: self.viewStore.binding(\.$popover),
          case: /BasicAuthReducer.State.Popover.passwordLost,
          content: { _ in Self.passwordLostPopover() }
        )
        Divider().frame(height: 18)
        Button(l10n.NoAccount.Action.title) { self.viewStore.send(.showPopoverTapped(.noAccount))
        }
        .popover(
          unwrapping: self.viewStore.binding(\.$popover),
          case: /BasicAuthReducer.State.Popover.noAccount,
          content: { _ in Self.noAccountPopover() }
        )
      }
      .buttonStyle(.link)
      .foregroundColor(.accentColor)
    }
    .synchronize(self.viewStore.binding(\.$focusedField), self.$focusedField)
    .alert(self.store.scope(state: \.alert), dismiss: .alertDismissed)
  }

  static func chatAddressPopover() -> some View {
    GroupBox(l10n.ChatAddress.Popover.title) {
      Text(l10n.ChatAddress.Popover.content.asMarkdown)
    }
    .groupBoxStyle(PopoverGroupBoxStyle())
  }

  static func passwordLostPopover() -> some View {
    GroupBox(l10n.PasswordLost.Popover.title) {
      Text(l10n.PasswordLost.Popover.content.asMarkdown)
    }
    .groupBoxStyle(PopoverGroupBoxStyle())
  }

  static func noAccountPopover() -> some View {
    GroupBox(l10n.NoAccount.Popover.title) {
      Text(l10n.NoAccount.Popover.content.asMarkdown)
    }
    .groupBoxStyle(PopoverGroupBoxStyle())
  }
}

struct PopoverGroupBoxStyle: GroupBoxStyle {
  func makeBody(configuration: Configuration) -> some View {
    VStack(alignment: .leading, spacing: 16) {
      configuration.label
        .font(.headline)
      configuration.content
    }
    .font(.body)
    .foregroundColor(.primary)
    .scaledToFit()
    .multilineTextAlignment(.leading)
    .padding(16)
  }
}
