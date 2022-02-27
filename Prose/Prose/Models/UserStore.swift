//
//  UserStore.swift
//  Prose
//
//  Created by Rémi Bardon on 26/02/2022.
//  Copyright © 2022 Prose. All rights reserved.
//

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
        "id-valerian": User(
            userId: "id-valerian",
            displayName: "Valerian",
            avatar: "avatar-valerian"
        ),
        "id-julian": User(
            userId: "id-julian",
            displayName: "Julian",
            avatar: "avatar-valerian"
        ),
        "id-eliso": User(
            userId: "id-julian",
            displayName: "Julian",
            avatar: "avatar-valerian"
        ),
    ]
    
    private init() {}
    
    func user(for userId: String) -> User? {
        users[userId]
    }
}
