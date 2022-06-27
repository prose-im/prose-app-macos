//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation
import ProseCoreTCA

public struct UserDefaultsClient {
  public var loadCurrentAccount: () -> JID?
  public var saveCurrentAccount: (_ jid: JID) -> Void
  public var deleteCurrentAccount: () -> Void
}

public extension UserDefaultsClient {
  static var placeholder: UserDefaultsClient {
    UserDefaultsClient(
      loadCurrentAccount: { nil },
      saveCurrentAccount: { _ in () },
      deleteCurrentAccount: {}
    )
  }
}

public extension UserDefaultsClient {
  internal static let jidKey = "jid"

  static func live(_ defaults: UserDefaults) -> Self {
    Self(
      loadCurrentAccount: {
        defaults.string(forKey: Self.jidKey).flatMap(JID.init(rawValue:))
      },
      saveCurrentAccount: { jid in
        defaults.set(jid.jidString, forKey: Self.jidKey)
      },
      deleteCurrentAccount: {
        defaults.removeObject(forKey: Self.jidKey)
      }
    )
  }
}
