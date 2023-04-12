//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppDomain
import ComposableArchitecture
import Foundation

private enum KeychainError: Error {
  case unexpectedPasswordData
  case unhandledError(status: OSStatus)
}

public extension CredentialsClient {
  static var placeholder: CredentialsClient {
    CredentialsClient(
      loadCredentials: { _ in nil },
      save: { _ in () },
      deleteCredentials: { _ in () }
    )
  }
}

extension CredentialsClient: DependencyKey {
  public static var liveValue = Self.live(service: "org.prose.app")
}

public extension CredentialsClient {
  static func live(service: String) -> CredentialsClient {
    let deleteCredentials = { (jid: BareJid) in
      let query: [CFString: Any] = [
        kSecClass: kSecClassGenericPassword,
        kSecAttrService: service,
        kSecAttrAccount: jid.rawValue,
      ]

      let status = SecItemDelete(query as CFDictionary)
      guard status == errSecSuccess || status == errSecItemNotFound else {
        throw KeychainError.unhandledError(status: status)
      }
    }

    return CredentialsClient(
      loadCredentials: { (jid: BareJid) in
        let query: [CFString: Any] = [
          kSecClass: kSecClassGenericPassword,
          kSecAttrService: service,
          kSecAttrAccount: jid.rawValue,
          kSecMatchLimit: kSecMatchLimitOne,
          kSecReturnAttributes: true,
          kSecReturnData: true,
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status != errSecItemNotFound else {
          return nil
        }

        guard status == errSecSuccess else {
          throw KeychainError.unhandledError(status: status)
        }

        guard let existingItem = item as? [CFString: Any] else {
          throw KeychainError.unexpectedPasswordData
        }

        guard let itemData = existingItem[kSecValueData] as? Data else {
          throw KeychainError.unexpectedPasswordData
        }

        if let password = String(data: itemData, encoding: .utf8) {
          return Credentials(jid: jid, password: password)
        } else {
          return nil
        }
      },
      save: { (credentials: Credentials) in
        try? deleteCredentials(credentials.jid)

        let query: [CFString: Any] = [
          kSecClass: kSecClassGenericPassword,
          kSecAttrService: service,
          kSecAttrAccount: credentials.jid.rawValue,
          kSecValueData: credentials.password,
          kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock,
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
          throw KeychainError.unhandledError(status: status)
        }
      },
      deleteCredentials: deleteCredentials
    )
  }
}
