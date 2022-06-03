//
//  UserStore.swift
//  Prose
//
//  Created by Rémi Bardon on 26/02/2022.
//  Copyright © 2022 Prose. All rights reserved.
//

import PreviewAssets

/// Just a temporary `struct` that will be replaced by a real implementation later.
public struct User: Equatable {
    public let userId: String
    public let displayName: String
    public let fullName: String
    public let avatar: String
    public let jobTitle: String
    public let company: String

    public init(
        userId: String,
        displayName: String,
        fullName: String,
        avatar: String,
        jobTitle: String,
        company: String
    ) {
        self.userId = userId
        self.displayName = displayName
        self.fullName = fullName
        self.avatar = avatar
        self.jobTitle = jobTitle
        self.company = company
    }
}

public extension User {
    static var placeholder: User {
        User(
            userId: "valerian@prose.org",
            displayName: "Valerian",
            fullName: "valerian Saliou",
            // FIXME: Allow setting avatar to `nil` to avoid importing `PreviewAssets`
            avatar: PreviewImages.Avatars.valerian.rawValue,
            jobTitle: "CTO",
            company: "Crisp"
        )
    }
}

/// This is just a simple store sendiong fake data.
/// It should not go into production, it's intended to dynamise the (currently static) app.
public final class UserStore {
    public static let shared = UserStore()

    private let users: [String: User] = [
        "id-alexandre": User(
            userId: "id-alexandre",
            displayName: "Alexandre",
            fullName: "Alexandre",
            avatar: PreviewImages.Avatars.alexandre.rawValue,
            jobTitle: "Software Engineer",
            company: "Crisp"
        ),
        "id-antoine": User(
            userId: "id-antoine",
            displayName: "Antoine",
            fullName: "Antoine Goret",
            avatar: PreviewImages.Avatars.antoine.rawValue,
            jobTitle: "Marketing & Sales",
            company: "Crisp"
        ),
        "id-baptiste": User(
            userId: "id-baptiste",
            displayName: "Baptiste",
            fullName: "Baptiste Jamin",
            avatar: PreviewImages.Avatars.baptiste.rawValue,
            jobTitle: "CEO",
            company: "Crisp"
        ),
        "id-camille": User(
            userId: "id-camille",
            displayName: "Camille",
            fullName: "Camille LB",
            avatar: PreviewImages.Avatars.camille.rawValue,
            jobTitle: "Technical Support",
            company: "Crisp"
        ),
        "id-constellation-health": User(
            userId: "id-constellation-health",
            displayName: "constellation-health",
            fullName: "constellation-health",
            avatar: PreviewImages.Avatars.constellationHealth.rawValue,
            jobTitle: "Bot",
            company: "Crisp"
        ),
        "id-eliott": User(
            userId: "id-eliott",
            displayName: "Eliott",
            fullName: "Eliott Vincent",
            avatar: PreviewImages.Avatars.eliott.rawValue,
            jobTitle: "Software Engineer",
            company: "Crisp"
        ),
        "id-julien": User(
            userId: "id-julien",
            displayName: "Julien",
            fullName: "Julien Le Coupanec",
            avatar: PreviewImages.Avatars.julien.rawValue,
            jobTitle: "Growth Hacker",
            company: "TheFamily"
        ),
        "id-valerian": User(
            userId: "id-valerian",
            displayName: "Valerian",
            fullName: "Valerian Saliou",
            avatar: PreviewImages.Avatars.valerian.rawValue,
            jobTitle: "CTO",
            company: "Crisp"
        ),
    ]

    private init() {}

    public func user(for userId: String) -> User? {
        self.users[userId]
    }
}
