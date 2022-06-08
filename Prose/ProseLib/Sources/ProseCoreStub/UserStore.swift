//
//  UserStore.swift
//  Prose
//
//  Created by Rémi Bardon on 26/02/2022.
//  Copyright © 2022 Prose. All rights reserved.
//

import PreviewAssets
import SharedModels

/// Just a temporary `struct` that will be replaced by a real implementation later.
/// It more or less represents a vCard.
public struct User: Equatable {
    public let jid: JID
    public let displayName: String
    public let fullName: String
    public let avatar: String
    public let jobTitle: String
    public let company: String
    public let emailAddress: String
    public let phoneNumber: String
    public let location: String

    public init(
        jid: JID,
        displayName: String,
        fullName: String,
        avatar: String,
        jobTitle: String,
        company: String,
        emailAddress: String,
        phoneNumber: String,
        location: String
    ) {
        self.jid = jid
        self.displayName = displayName
        self.fullName = fullName
        self.avatar = avatar
        self.jobTitle = jobTitle
        self.company = company
        self.emailAddress = emailAddress
        self.phoneNumber = phoneNumber
        self.location = location
    }
}

public extension User {
    static var placeholder: User {
        User(
            jid: "valerian@prose.org",
            displayName: "Valerian",
            fullName: "valerian Saliou",
            // FIXME: Allow setting avatar to `nil` to avoid importing `PreviewAssets`
            avatar: PreviewImages.Avatars.valerian.rawValue,
            jobTitle: "CTO",
            company: "Crisp",
            emailAddress: "valerian@crisp.chat",
            phoneNumber: "+33 6 12 34 56",
            location: "Lisbon, Portugal"
        )
    }
}

public struct UserStore {
    public let user: (_ jid: JID) -> User?
}

public extension UserStore {
    static var stub: Self {
        Self(
            user: StubUserStore.shared.user(for:)
        )
    }
}

/// This is just a simple store sending fake data.
/// It should not go into production, it's intended to dynamise the (currently static) app.
private final class StubUserStore {
    fileprivate static let shared = StubUserStore()

    private lazy var users: [JID: User] = [
        "alexandre@crisp.chat": User(
            jid: "alexandre@crisp.chat",
            displayName: "Alexandre",
            fullName: "Alexandre",
            avatar: PreviewImages.Avatars.alexandre.rawValue,
            jobTitle: "Software Engineer",
            company: "Crisp",
            emailAddress: "alexandre@crisp.chat",
            phoneNumber: "+33 6 12 34 56",
            location: "Somewhere"
        ),
        "antoine@crisp.chat": User(
            jid: "antoine@crisp.chat",
            displayName: "Antoine",
            fullName: "Antoine Goret",
            avatar: PreviewImages.Avatars.antoine.rawValue,
            jobTitle: "Marketing & Sales",
            company: "Crisp",
            emailAddress: "antoine@crisp.chat",
            phoneNumber: "+33 6 12 34 56",
            location: "Somewhere"
        ),
        "baptiste@crisp.chat": User(
            jid: "baptiste@crisp.chat",
            displayName: "Baptiste",
            fullName: "Baptiste Jamin",
            avatar: PreviewImages.Avatars.baptiste.rawValue,
            jobTitle: "CEO",
            company: "Crisp",
            emailAddress: "baptiste@crisp.chat",
            phoneNumber: "+33 6 12 34 56",
            location: "Nantes, France"
        ),
        "camille@crisp.chat": User(
            jid: "camille@crisp.chat",
            displayName: "Camille",
            fullName: "Camille LB",
            avatar: PreviewImages.Avatars.camille.rawValue,
            jobTitle: "Technical Support",
            company: "Crisp",
            emailAddress: "camille@crisp.chat",
            phoneNumber: "+33 6 12 34 56",
            location: "Somewhere"
        ),
        "constellation-health@crisp.chat": User(
            jid: "constellation-health@crisp.chat",
            displayName: "constellation-health",
            fullName: "constellation-health",
            avatar: PreviewImages.Avatars.constellationHealth.rawValue,
            jobTitle: "Bot",
            company: "Crisp",
            emailAddress: "constellation@crisp.chat",
            phoneNumber: "+33 6 12 34 56",
            location: "Around the globe"
        ),
        "eliott@crisp.chat": User(
            jid: "eliott@crisp.chat",
            displayName: "Eliott",
            fullName: "Eliott Vincent",
            avatar: PreviewImages.Avatars.eliott.rawValue,
            jobTitle: "Software Engineer",
            company: "Crisp",
            emailAddress: "eliott@crisp.chat",
            phoneNumber: "+33 6 12 34 56",
            location: "Somewhere"
        ),
        "julien@thefamily.com": User(
            jid: "julien@thefamily.com",
            displayName: "Julien",
            fullName: "Julien Le Coupanec",
            avatar: PreviewImages.Avatars.julien.rawValue,
            jobTitle: "Growth Hacker",
            company: "TheFamily",
            emailAddress: "julien@thefamily.com",
            phoneNumber: "+33 6 12 34 56",
            location: "Somewhere"
        ),
        "valerian@crisp.chat": User(
            jid: "valerian@crisp.chat",
            displayName: "Valerian",
            fullName: "Valerian Saliou",
            avatar: PreviewImages.Avatars.valerian.rawValue,
            jobTitle: "CTO",
            company: "Crisp",
            emailAddress: "valerian@crisp.chat",
            phoneNumber: "+33 6 12 34 56",
            location: "Lisbon, Portugal"
        ),
    ]

    private init() {}

    fileprivate func user(for jid: JID) -> User? {
        self.users[jid]
    }
}
