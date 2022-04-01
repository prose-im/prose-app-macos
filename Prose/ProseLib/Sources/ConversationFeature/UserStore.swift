//
//  UserStore.swift
//  Prose
//
//  Created by Rémi Bardon on 26/02/2022.
//  Copyright © 2022 Prose. All rights reserved.
//

import PreviewAssets
import SwiftUI

/// Just a temporary `struct` that will be replaced by a real implementation later.
struct User {
    let userId: String
    let displayName: String
    let avatar: String
}

/// This is just a simple store sendiong fake data.
/// It should not go into production, it's intended to dynamise the (currently static) app.
final class UserStore {
    static let shared = UserStore()
    
    private let users: [String: User] = [
        "id-alexandre": User(
            userId: "id-alexandre",
            displayName: "Alexandre",
            avatar: PreviewImages.Avatars.alexandre.rawValue
        ),
        "id-antoine": User(
            userId: "id-antoine",
            displayName: "Antoine",
            avatar: PreviewImages.Avatars.antoine.rawValue
        ),
        "id-baptiste": User(
            userId: "id-baptiste",
            displayName: "Baptiste",
            avatar: PreviewImages.Avatars.baptiste.rawValue
        ),
        "id-eliott": User(
            userId: "id-eliott",
            displayName: "Eliott",
            avatar: PreviewImages.Avatars.eliott.rawValue
        ),
        "id-camille": User(
            userId: "id-camille",
            displayName: "Camille",
            avatar: PreviewImages.Avatars.camille.rawValue
        ),
        "id-valerian": User(
            userId: "id-valerian",
            displayName: "Valerian",
            avatar: PreviewImages.Avatars.valerian.rawValue
        ),
    ]
    
    private init() {}
    
    func user(for userId: String) -> User? {
        users[userId]
    }
}
