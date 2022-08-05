//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation
import ProseCoreClientFFI

public struct Presence: Equatable {
  public var kind: Kind?
  public var show: Show?
  public var status: String?
  public var timestamp: Date

  public init(kind: Presence.Kind?, show: Presence.Show?, status: String?, timestamp: Date) {
    self.kind = kind
    self.show = show
    self.status = status
    self.timestamp = timestamp
  }
}

public extension Presence {
  /// https://datatracker.ietf.org/doc/html/rfc6121#section-4.7.1
  enum Kind: Equatable {
    case unavailable
    case subscribe
    case subscribed
    case unsubscribe
    case unsubscribed
    case probe
    case error
  }

  /// https://datatracker.ietf.org/doc/html/rfc6121#section-4.7.2.1
  enum Show: Equatable {
    case away
    case chat
    case dnd
    case xa
  }
}

extension Presence {
  init(presence: XmppPresence, timestamp: Date) {
    self.kind = presence.kind.map(Presence.Kind.init)
    self.show = presence.show.map(Presence.Show.init)
    self.status = presence.status
    self.timestamp = timestamp
  }
}

extension Presence.Kind {
  init(kind: XmppPresenceKind) {
    switch kind {
    case .unavailable:
      self = .unavailable
    case .subscribe:
      self = .subscribe
    case .subscribed:
      self = .subscribed
    case .unsubscribe:
      self = .unsubscribe
    case .unsubscribed:
      self = .unsubscribed
    case .probe:
      self = .probe
    case .error:
      self = .error
    @unknown default:
      fatalError("Unknown PresenceKind \(kind)")
    }
  }
}

extension Presence.Show {
  init(show: XmppShowKind) {
    switch show {
    case .away:
      self = .away
    case .chat:
      self = .chat
    case .dnd:
      self = .dnd
    case .xa:
      self = .xa
    @unknown default:
      fatalError("Unknown ShowKind \(show)")
    }
  }
}

extension Presence.Show {
  var ffi: XmppShowKind {
    switch self {
    case .away:
      return .away
    case .chat:
      return .chat
    case .dnd:
      return .dnd
    case .xa:
      return .xa
    }
  }
}
