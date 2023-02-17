import AppDomain
import Combine

public struct ProseCoreClient {
  public var connectionStatus: () -> AnyPublisher<ConnectionStatus, Never>

  public var connect: (Credentials, _ retry: Bool) async throws -> Void
  public var disconnect: () async throws -> Void
}
