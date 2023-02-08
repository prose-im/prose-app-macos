import AppDomain

public struct ProseCoreClient {
  public var login: (Credentials) async throws -> Void
}
