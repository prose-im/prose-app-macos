//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation
import Mocks
import ProseCoreTCA

extension Roster {
  static let mock: Roster = {
    let all = RNDResult.all()

    return Roster(groups: [
      .init(name: "Team members", users: all.prefix(5)),
      .init(name: "Other contacts", users: all[5..<15]),
    ])
  }()
}

private extension Roster.Group {
  init(name: String, users: some Sequence<RNDResult>) {
    self.init(
      name: name,
      items: users.map { user in
        Roster.Group.Item(
          jid: (try? JID(string: user.email)).expect("Invalid email"),
          subscription: .both
        )
      }
    )
  }
}
