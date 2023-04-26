//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain

public extension SessionState {
  static func mock(
    account: Account = .init(
      jid: .janeDoe,
      status: .connected,
      settings: .init(availability: .available)
    ),
    _ childState: ChildState
  ) -> Self {
    .init(
      selectedAccountId: account.jid,
      accounts: [account],
      childState: childState
    )
  }
}
