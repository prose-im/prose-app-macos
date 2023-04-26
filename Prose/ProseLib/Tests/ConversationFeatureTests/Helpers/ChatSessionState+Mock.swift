//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import ConversationFeature
import Mocks

public extension ChatSessionState {
  static func mock(
    selectedAccountId: BareJid = .janeDoe,
    chatId: BareJid = .johnDoe,
    userInfos: [BareJid: Contact] = [.johnDoe: .johnDoe],
    composingUsers: [BareJid] = [],
    _ childState: ChildState
  ) -> Self {
    .init(
      selectedAccountId: selectedAccountId,
      chatId: chatId,
      userInfos: userInfos,
      composingUsers: composingUsers,
      childState: childState
    )
  }
}
