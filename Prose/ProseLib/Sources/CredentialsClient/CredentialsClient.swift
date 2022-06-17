//
//  CredentialsClient.swift
//  Prose
//
//  Created by Rémi Bardon on 15/06/2022.
//

import Foundation
import SharedModels

/// - Note: See <https://developer.apple.com/documentation/security/keychain_services/keychain_items/using_the_keychain_to_manage_user_secrets>
///         for documentation about the Keychain.
/// - Copyright: Inspired by <https://gist.github.com/nesium/4a3da805d6000b76350cbe9c8aa35cf2>.
public struct CredentialsClient {
    public var loadCredentials: (_ jid: JID) throws -> Credentials?
    public var save: (_ credentials: Credentials) throws -> Void
    public var deleteCredentials: (_ jid: JID) throws -> Void
}

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

public extension CredentialsClient {
    static func live(service: String) -> CredentialsClient {
        let deleteCredentials = { (jid: JID) in
            let query: [CFString: Any] = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrService: service,
                kSecAttrAccount: jid.jidString,
            ]

            let status = SecItemDelete(query as CFDictionary)
            guard status == errSecSuccess || status == errSecItemNotFound else {
                throw KeychainError.unhandledError(status: status)
            }
        }

        return CredentialsClient(
            loadCredentials: { (jid: JID) in
                let query: [CFString: Any] = [
                    kSecClass: kSecClassGenericPassword,
                    kSecAttrService: service,
                    kSecAttrAccount: jid.jidString,
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
                    kSecAttrAccount: credentials.jid.jidString,
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
