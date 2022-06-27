//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation

/// Just a temporary `struct` that will be replaced by a real implementation later.
/// It more or less represents a vCard.
public struct User: Equatable {
  public let jid: JID
  public let displayName: String
  public let fullName: String
  public let avatar: URL?
  public let jobTitle: String
  public let company: String
  public let emailAddress: String
  public let phoneNumber: String
  public let location: String

  public init(
    jid: JID,
    displayName: String,
    fullName: String,
    avatar: URL?,
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
      jid: .init(bareJid: .init(node: "valerian", domain: "prose.org")),
      displayName: "Valerian",
      fullName: "valerian Saliou",
      // FIXME: Allow setting avatar to `nil` to avoid importing `PreviewAssets`
      avatar: nil,
      jobTitle: "CTO",
      company: "Crisp",
      emailAddress: "valerian@crisp.chat",
      phoneNumber: "+33 6 12 34 56",
      location: "Lisbon, Portugal"
    )
  }
}
