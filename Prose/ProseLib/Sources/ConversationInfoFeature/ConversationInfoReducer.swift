//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppDomain
import ComposableArchitecture
import Foundation
import ProseUI

public struct ConversationInfoReducer: ReducerProtocol {
  public struct State: Equatable {
    var identity = IdentitySectionState(
      avatar: .placeholder,
      fullName: "n/a",
      status: .away,
      jobTitle: "n/a",
      company: "n/a"
    )
    var information = InformationSectionState(
      emailAddress: "n/a",
      phoneNumber: "n/a",
      lastSeenDate: .distantPast,
      timeZone: .current,
      location: "n/a",
      statusIcon: "🪲",
      statusMessage: "n/a"
    )
    var security = SecuritySectionState(isIdentityVerified: false, encryptionFingerprint: nil)

    @BindingState var identityPopover: IdentityPopoverState?

    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case startCallButtonTapped
    case sendEmailButtonTapped

    case showIdVerificationInfoTapped
    case showEncryptionInfoTapped
    case identityPopover(IdentityPopoverAction)
    case binding(BindingAction<State>)

    case viewSharedFilesTapped
    case encryptionSettingsTapped
    case removeContactTapped
    case blockContactTapped
  }

  public init() {}

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .startCallButtonTapped:
        logger.info("Start call button tapped")
        return .none

      case .sendEmailButtonTapped:
        logger.info("Send email button tapped")
        return .none

      case .showIdVerificationInfoTapped:
        state.identityPopover = IdentityPopoverState()
        return .none

      case .showEncryptionInfoTapped:
        logger.info("Show encryption info tapped")
        return .none

      case .identityPopover, .binding:
        return .none

      case .viewSharedFilesTapped:
        logger.info("View shared files tapped")
        return .none

      case .encryptionSettingsTapped:
        logger.info("Encryption settings tapped")
        return .none

      case .removeContactTapped:
        logger.info("Remove contact tapped")
        return .none

      case .blockContactTapped:
        logger.info("Block tapped")
        return .none
      }
    }
  }
}

struct IdentitySectionState: Equatable {
  let avatar: AvatarImage
  let fullName: String
  let status: Availability
  let jobTitle: String
  let company: String
}

struct InformationSectionState: Equatable {
  let emailAddress: String
  let phoneNumber: String
  let lastSeenDate: Date
  let timeZone: TimeZone
  let location: String
  let statusIcon: Character
  let statusMessage: String

  var localDateString: String {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = self.timeZone
    dateFormatter.timeStyle = .long
    return dateFormatter.string(from: Date.now)
  }
}

struct SecuritySectionState: Equatable {
  let isIdentityVerified: Bool
  let encryptionFingerprint: String?
}
