//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import Foundation

// MARK: - RNDRandomUserResponse

public struct RNDRandomUserResponse: Codable {
  public var results: [RNDResult]
  public var info: RNDInfo
}

// MARK: - RNDInfo

public struct RNDInfo: Codable {
  public var seed: String
  public var results, page: Int
  public var version: String
}

// MARK: - RNDResult

public struct RNDResult: Codable {
  public var gender: RNDGender
  public var name: RNDName
  public var location: RNDLocation
  public var email: String
  public var login: RNDLogin
  public var dob, registered: RNDDob
  public var phone, cell: String
  public var id: RNDID
  public var picture: RNDPicture
  public var nat: String
}

// MARK: - RNDDob

public struct RNDDob: Codable {
  public var date: String
  public var age: Int
}

public enum RNDGender: String, Codable {
  case female
  case male
}

// MARK: - RNDID

public struct RNDID: Codable {
  public var name: String
  public var value: String?
}

// MARK: - RNDLocation

public struct RNDLocation: Codable {
  public var street: RNDStreet
  public var city, state, country: String
  public var postcode: RNDPostcode
  public var coordinates: RNDCoordinates
  public var timezone: RNDTimezone
}

// MARK: - RNDCoordinates

public struct RNDCoordinates: Codable {
  public var latitude, longitude: String
}

public enum RNDPostcode: Codable {
  case integer(Int)
  case string(String)

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let x = try? container.decode(Int.self) {
      self = .integer(x)
      return
    }
    if let x = try? container.decode(String.self) {
      self = .string(x)
      return
    }
    throw DecodingError.typeMismatch(
      RNDPostcode.self,
      DecodingError
        .Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for RNDPostcode")
    )
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case let .integer(x):
      try container.encode(x)
    case let .string(x):
      try container.encode(x)
    }
  }
}

// MARK: - RNDStreet

public struct RNDStreet: Codable {
  public var number: Int
  public var name: String
}

// MARK: - RNDTimezone

public struct RNDTimezone: Codable {
  public var offset, timezoneDescription: String

  enum CodingKeys: String, CodingKey {
    case offset
    case timezoneDescription = "description"
  }
}

// MARK: - RNDLogin

public struct RNDLogin: Codable {
  public var uuid, username, password, salt: String
  public var md5, sha1, sha256: String
}

// MARK: - RNDName

public struct RNDName: Codable {
  public var title: RNDTitle
  public var first, last: String
}

public enum RNDTitle: String, Codable {
  case madame = "Madame"
  case miss = "Miss"
  case monsieur = "Monsieur"
  case mr = "Mr"
  case mrs = "Mrs"
  case ms = "Ms"
}

// MARK: - RNDPicture

public struct RNDPicture: Codable {
  public var large, medium, thumbnail: String
}
