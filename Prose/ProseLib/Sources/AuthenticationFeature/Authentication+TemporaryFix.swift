//
//  Authentication+TemporaryFix.swift
//  Prose
//
//  Created by Rémi Bardon on 09/06/2022.
//

import Foundation

public enum AuthenticationError: Error, Equatable {
    case badCredentials
}

extension AuthenticationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .badCredentials:
            return "Bad credentials"
        }
    }
}
