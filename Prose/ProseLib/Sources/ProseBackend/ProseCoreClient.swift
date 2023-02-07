import ComposableArchitecture
import Foundation
import ProseCore

public struct ProseCoreClient {
  var login: (_ jid: BareJid, _ password: String) async throws -> Void
}

public extension DependencyValues {
  var proseCoreClient: ProseCoreClient {
    get { self[ProseCoreClient.self] }
    set { self[ProseCoreClient.self] = newValue }
  }
}

extension ProseCoreClient: TestDependencyKey {
  public static var testValue = ProseCoreClient(
    login: unimplemented("\(Self.self).login")
  )
}
