import AppDomain
import Combine
import Foundation

public struct ProseCoreClient {
  public var connectionStatus: () -> AsyncStream<ConnectionStatus>

  public var connect: (Credentials, _ retry: Bool) async throws -> Void
  public var disconnect: () async throws -> Void
  
  public var loadProfile: (BareJid) async throws -> UserProfile
  public var loadRoster: () async throws -> [RosterItem]
  public var loadAvatar: (BareJid) async throws -> URL?
}
