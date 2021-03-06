//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import ComposableArchitecture
import ProseUI
import SwiftUI
import SwiftUINavigation
import TcaHelpers

private let l10n = L10n.Authentication.BasicAuth.self

struct BasicAuthView: View {
  typealias State = BasicAuthState
  typealias Action = BasicAuthAction

  @Environment(\.redactionReasons) private var redactionReasons

  let store: Store<State, Action>
  private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

  @FocusState private var focusedField: State.Field?

  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack(spacing: 32) {
        Self.header()
        fields(viewStore: viewStore)
        logInButton(viewStore: viewStore)
        footer(viewStore: viewStore)
      }
      .multilineTextAlignment(.center)
      .controlSize(.large)
      .textFieldStyle(.roundedBorder)
      .buttonBorderShape(.roundedRectangle)
      .padding(.horizontal, 48)
      .padding(.vertical, 24)
      .synchronize(viewStore.binding(\.$focusedField), self.$focusedField)
      .alert(self.store.scope(state: \.alert), dismiss: .alertDismissed)
    }
  }

  static func header() -> some View {
    VStack(spacing: 4) {
      Text("👋")
        .font(.system(size: 64))
        .padding(.bottom, 20)
      Text(l10n.Header.title)
        .font(.system(size: 24, weight: .bold))
      Text(l10n.Header.subtitle)
        .foregroundColor(.secondary)
        .font(.system(size: 16))
    }
    .unredacted()
    .accessibilityElement()
    .accessibilityLabel(l10n.Header.subtitle)
  }

  func fields(viewStore: ViewStore<State, Action>) -> some View {
    VStack {
      TextField(l10n.Form.ChatAddress.placeholder, text: viewStore.binding(\.$jid))
        .onSubmit { actions.send(.submitTapped(.address)) }
        .textContentType(.username)
        .disableAutocorrection(true)
        .focused($focusedField, equals: .address)
        .overlay(alignment: .trailing) {
          HelpButton(content: Self.chatAddressPopover)
            .alignmentGuide(.trailing) { d in d[.trailing] - 24 }
        }
      SecureField(l10n.Form.Password.placeholder, text: viewStore.binding(\.$password))
        .onSubmit { actions.send(.submitTapped(.password)) }
        .textContentType(.password)
        .disableAutocorrection(true)
        .focused($focusedField, equals: .password)
    }
    .disabled(viewStore.isLoading || self.redactionReasons.contains(.placeholder))
    .unredacted()
  }

  func logInButton(viewStore: ViewStore<State, Action>) -> some View {
    Button {
      actions.send(viewStore.isLoading ? .cancelLogInTapped : .loginButtonTapped)
    } label: {
      Text(viewStore.isLoading ? l10n.Cancel.Action.title : l10n.LogIn.Action.title)
        .frame(minWidth: 196)
    }
    .overlay(alignment: .leading) {
      if viewStore.isLoading {
        ProgressView()
          .scaleEffect(0.5, anchor: .center)
      }
    }
    .disabled(!viewStore.isActionButtonEnabled || self.redactionReasons.contains(.placeholder))
    .unredacted()
  }

  func footer(viewStore: ViewStore<State, Action>) -> some View {
    HStack(spacing: 16) {
      Button(l10n.PasswordLost.Action.title) {
        actions.send(.showPopoverTapped(.passwordLost))
      }
      .popover(
        unwrapping: viewStore.binding(\.$popover),
        case: CasePath(State.Popover.passwordLost),
        content: { _ in Self.passwordLostPopover() }
      )
      Divider().frame(height: 18)
      Button(l10n.NoAccount.Action.title) { actions.send(.showPopoverTapped(.noAccount)) }
        .popover(
          unwrapping: viewStore.binding(\.$popover),
          case: CasePath(State.Popover.noAccount),
          content: { _ in Self.noAccountPopover() }
        )
    }
    .buttonStyle(.link)
    .foregroundColor(.accentColor)
    .unredacted()
    .disabled(self.redactionReasons.contains(.placeholder))
  }

  static func chatAddressPopover() -> some View {
    GroupBox(l10n.ChatAddress.Popover.title) {
      Text(l10n.ChatAddress.Popover.content.asMarkdown)
    }
    .groupBoxStyle(PopoverGroupBoxStyle())
    .unredacted()
  }

  static func passwordLostPopover() -> some View {
    GroupBox(l10n.PasswordLost.Popover.title) {
      Text(l10n.PasswordLost.Popover.content.asMarkdown)
    }
    .groupBoxStyle(PopoverGroupBoxStyle())
    .unredacted()
  }

  static func noAccountPopover() -> some View {
    GroupBox(l10n.NoAccount.Popover.title) {
      Text(l10n.NoAccount.Popover.content.asMarkdown)
    }
    .groupBoxStyle(PopoverGroupBoxStyle())
    .unredacted()
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
    .scaledToFit()
    .multilineTextAlignment(.leading)
    .padding(16)
  }
}

#if DEBUG
  struct BasicAuthView_Previews: PreviewProvider {
    private struct Preview: View {
      let state: BasicAuthView.State

      var body: some View {
        BasicAuthView(store: Store(
          initialState: state,
          reducer: basicAuthReducer,
          environment: AuthenticationEnvironment(
            proseClient: .noop,
            credentials: .live(service: "org.prose.app.preview.\(Self.self)"),
            mainQueue: .main
          )
        ))
        .previewLayout(.sizeThatFits)
      }
    }

    static var previews: some View {
      Preview(state: .init())
      Preview(state: .init(jid: "remi@prose.org", password: "password"))
      Preview(state: .init(jid: "remi@prose.org", password: "password"))
        .preferredColorScheme(.dark)
        .previewDisplayName("Dark mode")
      Preview(state: .init())
        .redacted(reason: .placeholder)
        .previewDisplayName("Placeholder")
    }
  }
#endif
