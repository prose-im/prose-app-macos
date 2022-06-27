//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import ProseUI
import SwiftUI

// MARK: - View

public struct ConversationInfoView: View {
  public typealias State = ConversationInfoState
  public typealias Action = ConversationInfoAction

  private let store: Store<State, Action>
  private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

  public init(store: Store<State, Action>) {
    self.store = store
  }

  public var body: some View {
    ScrollView(.vertical) {
      VStack(spacing: 24) {
        VStack(spacing: 12) {
          IdentitySection(
            store: self.store
              .scope(state: \State.identity, action: Action.identity)
          )
          QuickActionsSection(
            store: self.store
              .scope(state: \State.quickActions, action: Action.quickActions)
          )
        }
        .padding(.horizontal)

        InformationSection(
          store: self.store
            .scope(state: \State.information, action: Action.information)
        )
        SecuritySection(
          store: self.store
            .scope(state: \State.security, action: Action.security)
        )
        ActionsSection(
          store: self.store
            .scope(state: \State.actions, action: Action.actions)
        )
      }
      .padding(.vertical)
    }
    .groupBoxStyle(SectionGroupStyle())
    .background(.background)
  }
}

public extension ConversationInfoView {
  static var placeholder: some View {
    ConversationInfoView(store: Store(
      initialState: ConversationInfoState(
        identity: .placeholder,
        quickActions: .placeholder,
        information: .placeholder,
        security: .placeholder,
        actions: .placeholder
      ),
      reducer: Reducer.empty,
      environment: ()
    ))
    .redacted(reason: .placeholder)
  }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let conversationInfoReducer: Reducer<
  ConversationInfoState,
  ConversationInfoAction,
  Void
> = Reducer.combine([
  identitySectionReducer.pullback(
    state: \ConversationInfoState.identity,
    action: CasePath(ConversationInfoAction.identity),
    environment: { $0 }
  ),
  quickActionsSectionReducer.pullback(
    state: \ConversationInfoState.quickActions,
    action: CasePath(ConversationInfoAction.quickActions),
    environment: { $0 }
  ),
  securitySectionReducer.pullback(
    state: \ConversationInfoState.security,
    action: CasePath(ConversationInfoAction.security),
    environment: { $0 }
  ),
  actionsSectionReducer.pullback(
    state: \ConversationInfoState.actions,
    action: CasePath(ConversationInfoAction.actions),
    environment: { $0 }
  ),
])

// MARK: State

public struct ConversationInfoState: Equatable {
  var identity: IdentitySectionState
  var quickActions: QuickActionsSectionState
  var information: InformationSectionState
  var security: SecuritySectionState
  var actions: ActionsSectionState

  public init(
    identity: IdentitySectionState,
    quickActions: QuickActionsSectionState,
    information: InformationSectionState,
    security: SecuritySectionState,
    actions: ActionsSectionState
  ) {
    self.identity = identity
    self.quickActions = quickActions
    self.information = information
    self.security = security
    self.actions = actions
  }
}

public extension ConversationInfoState {
  static let demo = ConversationInfoState(
    identity: .init(
      avatar: .placeholder,
      fullName: "Valerian Saliou",
      status: .online,
      jobTitle: "CTO",
      company: "Crisp"
    ),
    quickActions: .init(),
    information: .init(
      emailAddress: "valerian@crisp.chat",
      phoneNumber: "+33 6 12 34 56",
      lastSeenDate: Date.now - 1000,
      timeZone: TimeZone.current,
      location: "Lisbon, Portugal",
      statusIcon: "👨‍💻",
      statusMessage: "Focusing on code"
    ),
    security: .init(
      isIdentityVerified: true,
      encryptionFingerprint: "V5I92"
    ),
    actions: .init()
  )
}

// MARK: Actions

public enum ConversationInfoAction: Equatable {
  case identity(IdentitySectionAction)
  case quickActions(QuickActionsSectionAction)
  case information(InformationSectionAction)
  case security(SecuritySectionAction)
  case actions(ActionsSectionAction)
}

// MARK: - Previews

#if DEBUG
  import PreviewAssets

  internal struct ConversationInfoView_Previews: PreviewProvider {
    private struct Preview: View {
      var body: some View {
        ConversationInfoView(store: Store(
          initialState: ConversationInfoState(
            identity: .init(
              avatar: AvatarImage(url: PreviewAsset.Avatars.valerian.customURL),
              fullName: "Valerian Saliou",
              status: .online,
              jobTitle: "CTO",
              company: "Crisp"
            ),
            quickActions: .init(),
            information: .init(
              emailAddress: "valerian@crisp.chat",
              phoneNumber: "+33 6 12 34 56",
              lastSeenDate: Date.now - 1000,
              timeZone: TimeZone(identifier: "WEST")!,
              location: "Lisbon, Portugal",
              statusIcon: "👨‍💻",
              statusMessage: "Focusing on code"
            ),
            security: .init(
              isIdentityVerified: true,
              encryptionFingerprint: "V5I92"
            ),
            actions: .init()
          ),
          reducer: conversationInfoReducer,
          environment: ()
        ))
        .frame(width: 220, height: 720)
      }
    }

    static var previews: some View {
      Preview()
        .previewDisplayName("Normal")
      Preview()
        .previewDisplayName("Real placeholder")
      ConversationInfoView.placeholder
        .previewDisplayName("Simple placeholder")
    }
  }
#endif
