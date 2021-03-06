//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import Assets
import ComposableArchitecture
import SwiftUI
import SwiftUINavigation

private let l10n = L10n.Content.MessageDetails.Security.self

// MARK: - View

struct SecuritySection: View {
  typealias State = SecuritySectionState
  typealias Action = SecuritySectionAction

  @Environment(\.redactionReasons) private var redactionReasons

  let store: Store<State, Action>
  private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

  var body: some View {
    GroupBox(l10n.title) {
      identityVerified()
      encryption()
    }
  }

  private func identityVerified() -> some View {
    HStack(spacing: 8) {
      WithViewStore(
        self.store
          .scope(state: \State.isIdentityVerified)
      ) { isIdentityVerified in
        if isIdentityVerified.state {
          Label {
            Text("Identity verified")
          } icon: {
            Image(systemName: "checkmark.seal.fill")
              .foregroundColor(Colors.State.green.color)
          }
        } else {
          Label {
            Text("Identity not verified")
          } icon: {
            Image(systemName: "xmark.seal.fill")
              .foregroundColor(.orange)
          }
        }
      }
      WithViewStore(
        self.store,
        removeDuplicates: { $0.identityPopover == $1.identityPopover }
      ) { viewStore in
        infoButton(action: { actions.send(.showIdVerificationInfoTapped) })
          .popover(unwrapping: viewStore.binding(\.$identityPopover)) { _ in
            IfLetStore(
              self.store.scope(state: \State.identityPopover, action: Action.identityPopover),
              then: IdentityPopover.init(store:)
            )
          }
      }
    }
  }

  private func encryption() -> some View {
    HStack(spacing: 8) {
      WithViewStore(self.store.scope(state: \State.encryptionFingerprint)) { fingerprint in
        if let fingerprint = fingerprint.state {
          Label {
            Text("Encrypted (\(fingerprint))")
          } icon: {
            Image(systemName: "lock.fill")
              .foregroundColor(.blue)
          }
        } else {
          Label {
            Text("Not encrypted")
          } icon: {
            Image(systemName: "lock.slash")
              .foregroundColor(.red)
          }
        }
      }
      infoButton(action: { actions.send(.showEncryptionInfoTapped) })
    }
  }

  func infoButton(action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Image(systemName: "info.circle")
        .foregroundColor(Color.primary.opacity(0.50))
    }
    .buttonStyle(.plain)
    .unredacted()
    .disabled(self.redactionReasons.contains(.placeholder))
  }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let securitySectionReducer = Reducer<
  SecuritySectionState,
  SecuritySectionAction,
  Void
> { state, action, _ in
  switch action {
  case .showIdVerificationInfoTapped:
    state.identityPopover = IdentityPopoverState()
    return .none

  case .showEncryptionInfoTapped:
    logger.info("Show encryption info tapped")
    return .none

  case .identityPopover, .binding:
    return .none
  }
}.binding()

// MARK: State

public struct SecuritySectionState: Equatable {
  let isIdentityVerified: Bool
  let encryptionFingerprint: String?

  @BindableState var identityPopover: IdentityPopoverState?
}

extension SecuritySectionState {
  static var placeholder: SecuritySectionState {
    SecuritySectionState(
      isIdentityVerified: false,
      encryptionFingerprint: nil
    )
  }
}

// MARK: Actions

public enum SecuritySectionAction: Equatable, BindableAction {
  case showIdVerificationInfoTapped
  case showEncryptionInfoTapped
  case identityPopover(IdentityPopoverAction)
  case binding(BindingAction<SecuritySectionState>)
}

// MARK: - Previews

struct SecuritySection_Previews: PreviewProvider {
  private struct Preview: View {
    let state: SecuritySectionState

    var body: some View {
      SecuritySection(store: Store(
        initialState: state,
        reducer: securitySectionReducer,
        environment: ()
      ))
    }
  }

  static var previews: some View {
    Preview(state: .init(
      isIdentityVerified: true,
      encryptionFingerprint: "NW6DB"
    ))
    Preview(state: .init(
      isIdentityVerified: false,
      encryptionFingerprint: nil
    ))
  }
}
