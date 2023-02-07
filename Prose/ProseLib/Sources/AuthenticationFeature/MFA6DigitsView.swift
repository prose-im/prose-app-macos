//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import Combine
import ComposableArchitecture
import ProseCoreTCA
import ProseCore
import ProseUI
import SwiftUI
import SwiftUINavigation
import TcaHelpers

private let l10n = L10n.Authentication.Mfa.self

// MARK: - View

public struct MFA6DigitsView: View {
  public typealias State = MFA6DigitsState
  public typealias Action = MFA6DigitsAction

  @Environment(\.redactionReasons) private var redactionReasons

  let store: Store<State, Action>
  private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

  @FocusState private var focusedField: State.Field?

  public var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack(spacing: 32) {
        Self.header()
        fields(viewStore: viewStore)
        mainButton(viewStore: viewStore)
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
      .onAppear { actions.send(.onAppear) }
      .onTapGesture { actions.send(.onGlobalTapGesture) }
    }
  }

  static func header() -> some View {
    VStack(spacing: 4) {
      Text("👇")
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
    HStack(spacing: 4) {
      ForEach(0..<6) { n in
        digit(viewStore.state.digit(n), selected: viewStore.filteredCode.count == n)
      }
    }
    // Hide fake fields in accessibility
    .accessibilityHidden(true)
    // Add a real `TextField` backing the interactions and accessibility
    .background {
      TextField(l10n.Form.OneTimeCode.placeholder, text: viewStore.binding(\.$rawCode))
        .focused($focusedField, equals: .textField)
        .textContentType(.oneTimeCode)
        .opacity(0)
    }
    .font(.system(size: 24))
    .disabled(viewStore.isLoading || self.redactionReasons.contains(.placeholder))
    .opacity(viewStore.isLoading ? 0.5 : 1)
  }

  func mainButton(viewStore: ViewStore<State, Action>) -> some View {
    Button { actions.send(.submitButtonTapped) } label: {
      Text(l10n.ConfirmButton.title)
        .frame(minWidth: 196)
    }
    .disabled(!viewStore.isMainButtonEnabled)
    .unredacted()
    .disabled(self.redactionReasons.contains(.placeholder))
  }

  func digit(_ digit: String, selected: Bool) -> some View {
    ZStack {
      RoundedRectangle(cornerRadius: 6)
        .fill(Color(nsColor: .controlBackgroundColor))
        .shadow(radius: 0.75, y: 0.5)
      if selected {
        RoundedRectangle(cornerRadius: 6)
          .strokeBorder(Color.accentColor.opacity(0.75), lineWidth: 3)
      }
      if digit.isEmpty {
        Text("0")
          .foregroundColor(.secondary)
      } else {
        Text(digit)
      }
    }
    .frame(width: 48, height: 56)
  }

  func footer(viewStore: ViewStore<State, Action>) -> some View {
    HStack(spacing: 16) {
      Button(l10n.Footer.CannotGenerateCode.title) {
        actions.send(.showPopoverTapped(.cannotGenerateCode))
      }
      .popover(
        unwrapping: viewStore.binding(\.$popover),
        case: CasePath(State.Popover.cannotGenerateCode),
        content: { _ in Self.cannotGenerateCodePopover() }
      )
      Divider().frame(height: 18)
      Button(l10n.Footer.NoAccount.title) { actions.send(.showPopoverTapped(.noAccount)) }
        .popover(
          unwrapping: viewStore.binding(\.$popover),
          case: CasePath(State.Popover.noAccount),
          content: { _ in BasicAuthView.noAccountPopover() }
        )
    }
    .buttonStyle(.link)
    .foregroundColor(.accentColor)
    .unredacted()
    .disabled(self.redactionReasons.contains(.placeholder))
  }

  static func cannotGenerateCodePopover() -> some View {
    GroupBox(l10n.Footer.CannotGenerateCode.title) {
      Text(l10n.Footer.CannotGenerateCode.content)
    }
    .groupBoxStyle(PopoverGroupBoxStyle())
    .unredacted()
  }
}

// MARK: - The Composabe Architecture

// MARK: Reducer

let mfa6DigitsReducer: AnyReducer<
  MFA6DigitsState,
  MFA6DigitsAction,
  AuthenticationEnvironment
> = AnyReducer { state, action, environment in
  struct CodeFilteringCancelId: Hashable {}

  switch action {
  case .onAppear, .onGlobalTapGesture:
    state.focusedField = .textField

  case .submitButtonTapped:
    return EffectTask(value: .verifyOneTimeCode)

  case let .showPopoverTapped(popover):
    state.popover = popover

  case .verifyOneTimeCode:
    state.isLoading = true

    let isFormValid = state.isFormValid
    let code = state.filteredCode
    let jid = state.jid
    let password = state.password
    return EffectTask.task {
      if isFormValid, code != "000000" {
        return .verifyOneTimeCodeResult(.success(.success(jid: jid, password: password)))
      } else {
        return .verifyOneTimeCodeResult(.failure(.badCode))
      }
    }
    .delay(for: .seconds(1), scheduler: environment.mainQueue)
    .eraseToEffect()

  case let .verifyOneTimeCodeResult(.success(route)):
    logger.trace("MFA success: \(String(describing: route))")

        // NOTE: [Rémi Bardon] Do not set `state.isLoading = false`, as the user might have a brief moment
        //       to trigger another call.

  case let .verifyOneTimeCodeResult(.failure(reason)):
    logger.trace("MFA failure: \(String(reflecting: reason))")

    state.rawCode = ""
    state.filteredCode = ""
    state.isLoading = false

    state.alert = .init(
      title: TextState(l10n.Error.title),
      message: TextState(reason.localizedDescription)
    )

  case .alertDismissed:
    state.alert = nil

  case .binding(\.$rawCode):
    let oldRawCode = state.rawCode
    let oldFilteredCode = state.filteredCode

    let filteredCode = String(
      oldRawCode.unicodeScalars
        .filter(CharacterSet.decimalDigits.contains).prefix(6)
    )

    var effects: [EffectTask<MFA6DigitsAction>] = []

    // Raw code needs update if the user typed letters (we need to remove them)
    let rawCodeNeedsUpdate = filteredCode != oldRawCode
    if rawCodeNeedsUpdate {
      effects.append(EffectTask(value: .binding(.set(\.$rawCode, filteredCode))))
    }

    // Filtered code needs update if the user typed numbers (we need to add them)
    let filteredCodeNeedsUpdate = filteredCode != oldFilteredCode
    if filteredCodeNeedsUpdate {
      effects.append(EffectTask(value: .binding(.set(\.$filteredCode, filteredCode))))
    }

    return EffectTask.merge(effects)
      .delay(for: .milliseconds(10), scheduler: environment.mainQueue)
      .eraseToEffect()
      .cancellable(id: CodeFilteringCancelId(), cancelInFlight: true)

  case .binding(\.$filteredCode):
    if state.isFormValid {
      return EffectTask(value: .verifyOneTimeCode)
    }

  case .verifyOneTimeCodeResult, .binding:
    break
  }

  return .none
}.binding()

// MARK: State

public struct MFA6DigitsState: Equatable {
  public enum Field: String, Hashable {
    case textField
  }

  public enum Popover: String, Hashable {
    case cannotGenerateCode, noAccount
  }

  let jid: BareJid
  /// - Note: [Rémi Bardon] This should only be temporary
  let password: String

  @BindingState var rawCode: String
  @BindingState var filteredCode: String
  var isLoading: Bool
  var alert: AlertState<MFA6DigitsAction>?

  @BindingState var focusedField: Field?
  @BindingState var popover: Popover?

  var isFormValid: Bool { self.filteredCode.count == 6 }
  var isMainButtonEnabled: Bool { self.isFormValid && !self.isLoading }

  public init(
    jid: BareJid,
    password: String,
    code: String = "",
    isLoading: Bool = false,
    alert: AlertState<MFA6DigitsAction>? = nil,
    focusedField: Field? = nil,
    popover: Popover? = nil
  ) {
    self.jid = jid
    self.password = password
    self.rawCode = code
    self.filteredCode = code
    self.isLoading = isLoading
    self.alert = alert
    self.focusedField = focusedField
    self.popover = popover
  }

  func digit(_ index: Int) -> String {
    self.filteredCode.count > index ? String(Array(self.filteredCode)[index]) : ""
  }
}

// MARK: Actions

public enum MFA6DigitsAction: Equatable, BindableAction {
  case onAppear, onGlobalTapGesture
  case submitButtonTapped, showPopoverTapped(MFA6DigitsState.Popover)
  case verifyOneTimeCode, verifyOneTimeCodeResult(Result<Authentication.Route, MFAError>)
  case alertDismissed
  case binding(BindingAction<MFA6DigitsState>)
}

#if DEBUG

  // MARK: - Previews

  struct MFA6DigitsView_Previews: PreviewProvider {
    private struct Preview: View {
      var body: some View {
        MFA6DigitsView(store: Store(
          initialState: MFA6DigitsState(
            jid: .init(rawValue: "remi@prose.org")!,
            password: "prose"
          ),
          reducer: mfa6DigitsReducer,
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
      Preview()
      Preview()
        .preferredColorScheme(.dark)
        .previewDisplayName("Dark mode")
      Preview()
        .redacted(reason: .placeholder)
        .previewDisplayName("Placeholder")
    }
  }
#endif
