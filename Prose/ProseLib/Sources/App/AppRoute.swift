//
//  AppRoute.swift
//  Prose
//
//  Created by Rémi Bardon on 02/06/2022.
//

import AuthenticationFeature
import MainWindowFeature

public enum AppRoute: Equatable {
    case auth(AuthenticationState)
    case main(MainScreenState)
}

public extension AppRoute {
    enum Tag {
        case auth, main
    }

    var tag: Tag {
        switch self {
        case .auth:
            return .auth
        case .main:
            return .main
        }
    }
}
