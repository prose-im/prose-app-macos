import AppDomain

public struct ProseCoreClient {
  public var connect: (Credentials) async throws -> Void
  public var disconnect: () async throws -> Void
}
