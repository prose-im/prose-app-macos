//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

@testable import App
import AppDomain
import Foundation
import Mocks

extension AppReducer.State {
  /// Returns an `AppState` with jane.doe@prose.org logged in.
  static let authenticated: AppReducer.State = {
    var state = AppReducer.State()
    state.initialized = true
    state.currentUser = .janeDoe
    state.availableAccounts = [
      .init(
        jid: .janeDoe,
        status: .connected,
        settings: .init(availability: .available),
        contacts: {
          let contacts = Contact.random()
          return Dictionary(
            zip(contacts.map(\.jid), contacts),
            uniquingKeysWith: { _, last in last }
          )
        }()
      ),
    ]
    state.mainState = .init()
    return state
  }()
}

extension Contact {
  static func random(count: Int = 5) -> [Contact] {
    RNDResult.all()
      .prefix(count)
      .map { user in
        Contact(
          jid: BareJid(stringLiteral: user.email),
          name: "\(user.name.first) \(user.name.last)",
          avatar: nil,
          availability: .available,
          status: nil,
          groups: ["Contacts"]
        )
      }
  }
}
