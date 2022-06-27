//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Assets
import ComposableArchitecture
import ProseCoreTCA
import ProseUI
import SwiftUI

// MARK: - View

struct IdentitySection: View {
  typealias State = IdentitySectionState
  typealias Action = IdentitySectionAction

  let store: Store<State, Action>
  private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

  var body: some View {
    VStack(alignment: .center, spacing: 10) {
      avatar()
        .cornerRadius(10.0)
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)

      VStack(spacing: 4) {
        WithViewStore(self.store) { viewStore in
          ContentCommonNameStatusComponent(
            name: viewStore.fullName,
            status: viewStore.status
          )

          Text("\(viewStore.jobTitle) at \(viewStore.company)")
            .font(.system(size: 11.5))
            .foregroundColor(Colors.Text.secondary.color)
        }
      }
    }
  }

  private func avatar() -> some View {
    WithViewStore(self.store.scope(state: \State.avatar)) { avatar in
      Avatar(avatar.state, size: 100)
    }
  }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let identitySectionReducer: Reducer<
  IdentitySectionState,
  IdentitySectionAction,
  Void
> = Reducer.empty

// MARK: State

public struct IdentitySectionState: Equatable {
  let avatar: AvatarImage
  let fullName: String
  let status: OnlineStatus
  let jobTitle: String
  let company: String

  public init(
    avatar: AvatarImage,
    fullName: String,
    status: OnlineStatus,
    jobTitle: String,
    company: String
  ) {
    self.avatar = avatar
    self.fullName = fullName
    self.status = status
    self.jobTitle = jobTitle
    self.company = company
  }
}

public extension IdentitySectionState {
  init(
    from user: User,
    status: OnlineStatus
  ) {
    self.init(
      avatar: AvatarImage(url: user.avatar),
      fullName: user.fullName,
      status: status,
      jobTitle: user.jobTitle,
      company: user.company
    )
  }
}

extension IdentitySectionState {
  static var placeholder: IdentitySectionState {
    IdentitySectionState(
      from: .placeholder,
      status: .offline
    )
  }
}

#if DEBUG
  import PreviewAssets

  extension IdentitySectionState {
    /// Only for previews
    static var valerian: Self {
      Self(
        avatar: AvatarImage(url: PreviewAsset.Avatars.valerian.customURL),
        fullName: "Valerian Saliou",
        status: .online,
        jobTitle: "CTO",
        company: "Crisp"
      )
    }
  }
#endif

// MARK: Actions

public enum IdentitySectionAction: Equatable {}

// MARK: - Previews

#if DEBUG
  struct IdentitySection_Previews: PreviewProvider {
    private struct Preview: View {
      let state: IdentitySectionState

      var body: some View {
        IdentitySection(store: Store(
          initialState: state,
          reducer: identitySectionReducer,
          environment: ()
        ))
      }
    }

    static var previews: some View {
      Preview(state: .valerian)
    }
  }
#endif
