//
//  Authentication+TemporaryFix.swift
//  Prose
//
//  Created by Rémi Bardon on 09/06/2022.
//

import AppLocalization
import Foundation

public enum LogInError: Error, Equatable {
    case badCredentials
}

extension LogInError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .badCredentials:
            return L10n.Authentication.BasicAuth.Alert.BadCredentials.title
        }
    }
}
