//
//  MFA6DigitsView.swift
//  Prose
//
//  Created by Rémi Bardon on 13/06/2022.
//

import AppLocalization
import ComposableArchitecture
import SwiftUI
import SwiftUINavigation
import TcaHelpers

private let l10n = L10n.Authentication.Mfa.self

// MARK: - View

public struct MFA6DigitsView: View {
    public typealias State = MFA6DigitsState
    public typealias Action = MFA6DigitsAction

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
        .accessibilityElement()
        .accessibilityLabel(l10n.Header.subtitle)
    }

    func fields(viewStore: ViewStore<State, Action>) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<6) { n in
                digit(viewStore.state.digit(n), selected: viewStore.code.count == n)
            }
        }
        // Hide fake fields in accessibility
        .accessibilityHidden(true)
        // Add a real `TextField` backing the interactions and accessibility
        .background {
            TextField(l10n.Form.OneTimeCode.placeholder, text: viewStore.binding(\.$code))
                .focused($focusedField, equals: .textField)
                .textContentType(.oneTimeCode)
                .opacity(0)
        }
        .font(.system(size: 24))
        .disabled(viewStore.isLoading)
        .opacity(viewStore.isLoading ? 0.5 : 1)
    }

    func mainButton(viewStore: ViewStore<State, Action>) -> some View {
        Button { actions.send(.mainButtonTapped) } label: {
            Text(l10n.ConfirmButton.title)
                .frame(minWidth: 196)
        }
        .disabled(!viewStore.isMainButtonEnabled)
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
            Button(l10n.Footer.CannotGenerateCode.title) { actions.send(.showPopoverTapped(.cannotGenerateCode)) }
                .popover(
                    unwrapping: viewStore.binding(\.$popover),
                    case: /State.Popover.cannotGenerateCode,
                    content: { _ in Self.cannotGenerateCodePopover() }
                )
            Divider().frame(height: 18)
            Button(l10n.Footer.NoAccount.title) { actions.send(.showPopoverTapped(.noAccount)) }
                .popover(
                    unwrapping: viewStore.binding(\.$popover),
                    case: /State.Popover.noAccount,
                    content: { _ in BasicAuthView.noAccountPopover() }
                )
        }
        .buttonStyle(.link)
    }

    static func cannotGenerateCodePopover() -> some View {
        GroupBox(l10n.Footer.CannotGenerateCode.title) {
            Text(l10n.Footer.CannotGenerateCode.content)
        }
        .groupBoxStyle(PopoverGroupBoxStyle())
    }
}

// MARK: - The Composabe Architecture

// MARK: Reducer

public let mfa6DigitsReducer: Reducer<
    MFA6DigitsState,
    MFA6DigitsAction,
    AuthenticationEnvironment
> = Reducer { state, action, environment in
    switch action {
    case .onAppear, .onGlobalTapGesture:
        state.focusedField = .textField

    case .mainButtonTapped:
        return Effect(value: .verifyOneTimeCode)

    case let .showPopoverTapped(popover):
        state.popover = popover

    case .verifyOneTimeCode:
        state.isLoading = true

        let isFormValid = state.isFormValid
        let code = state.code
        let jid = state.jid
        return Effect.task {
            if isFormValid, code != "000000" {
                // NOTE: [Rémi Bardon] This is just a placeholder
                let token = UUID().uuidString
                return .verifyOneTimeCodeResult(.success(.success(jid: jid, token: token)))
            } else {
                return .verifyOneTimeCodeResult(.failure(.badCode))
            }
        }
        .delay(for: .seconds(1), scheduler: environment.mainQueue)
        .eraseToEffect()

    case let .verifyOneTimeCodeResult(.success(route)):
        print("MFA success: \(route)")

        // NOTE: [Rémi Bardon] Do not set `state.isLoading = false`, as the user might have a brief moment
        //       to trigger another call.

    case let .verifyOneTimeCodeResult(.failure(reason)):
        print("MFA failure: \(String(reflecting: reason))")

        state.code = ""
        state.isLoading = false

        state.alert = .init(
            title: TextState(l10n.Error.title),
            message: TextState(reason.localizedDescription)
        )

    case .alertDismissed:
        state.alert = nil

    case .binding(\.$code):
        state.code = String(state.code.unicodeScalars.filter(CharacterSet.decimalDigits.contains))

        if state.isFormValid {
            return Effect(value: .verifyOneTimeCode)
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

    let jid: String

    @BindableState var code: String
    var isLoading: Bool
    var alert: AlertState<MFA6DigitsAction>?

    @BindableState var focusedField: Field?
    @BindableState var popover: Popover?

    var isFormValid: Bool { self.code.count == 6 }
    var isMainButtonEnabled: Bool { self.isFormValid && !self.isLoading }

    public init(
        jid: String,
        code: String = "",
        isLoading: Bool = false,
        alert: AlertState<MFA6DigitsAction>? = nil,
        focusedField: Field? = nil,
        popover: Popover? = nil
    ) {
        self.jid = jid
        self.code = code
        self.isLoading = isLoading
        self.alert = alert
        self.focusedField = focusedField
        self.popover = popover
    }

    func digit(_ index: Int) -> String {
        self.code.count > index ? String(Array(self.code)[index]) : ""
    }
}

// MARK: Actions

public enum MFA6DigitsAction: Equatable, BindableAction {
    case onAppear, onGlobalTapGesture
    case mainButtonTapped, showPopoverTapped(MFA6DigitsState.Popover)
    case verifyOneTimeCode, verifyOneTimeCodeResult(Result<AuthRoute, MFAError>)
    case alertDismissed
    case binding(BindingAction<MFA6DigitsState>)
}

// MARK: - Previews

internal struct MFA6DigitsView_Previews: PreviewProvider {
    static var previews: some View {
        MFA6DigitsView(store: Store(
            initialState: MFA6DigitsState(jid: "remi@prose.org"),
            reducer: mfa6DigitsReducer,
            environment: AuthenticationEnvironment(
                mainQueue: .main
            )
        ))
        .previewLayout(.sizeThatFits)
    }
}
