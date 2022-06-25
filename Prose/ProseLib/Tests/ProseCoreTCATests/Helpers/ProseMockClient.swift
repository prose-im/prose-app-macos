import ProseCore
import ProseCoreClientFFI
import Foundation

final class ProseMockClient: ProseClientProtocol {
  let jid: BareJid
  let delegate: ProseClientDelegate
  
  var impl = ProseMockClientImpl()
  
  init(jid: BareJid, delegate: ProseCore.ProseClientDelegate) {
      self.jid = jid
      self.delegate = delegate
  }
  
  func connect(credential: ProseCore.Credential) throws {
      try self.impl.connect(credential)
  }
  
  func disconnect() {
      self.impl.disconnect()
  }
  
  func sendMessage(to jid: BareJid, text: String) throws {
      try self.impl.sendMessage(jid, text)
  }
  
  func loadRoster() throws {
      try self.impl.loadRoster()
  }
}

extension ProseMockClient {
  static func provider(
      _ handler: @escaping (ProseMockClient) -> Void
  ) -> ProseClientProvider<ProseMockClient> {
    { jid, delegate in
        let client = ProseMockClient(jid: jid, delegate: delegate)
        handler(client)
        return client
    }
  }
}

struct ProseMockClientImpl {
    var connect: (ProseCore.Credential) throws -> Void = { _ in }
    var disconnect: () -> Void = {}
    var sendMessage: (BareJid, String) throws -> Void = { _, _ in }
    var loadRoster: () throws -> Void = {}
}
