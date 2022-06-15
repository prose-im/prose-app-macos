//
//  Authentication+TemporaryFix.swift
//  Prose
//
//  Created by Rémi Bardon on 09/06/2022.
//

import AppLocalization
import Foundation

public enum AuthenticationError: Error, Equatable {
    case badCredentials
}

extension AuthenticationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .badCredentials:
            return L10n.Authentication.BasicAuth.Alert.BadCredentials.title
        }
    }
}
