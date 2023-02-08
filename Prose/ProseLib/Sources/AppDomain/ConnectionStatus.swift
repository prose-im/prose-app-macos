import BareMinimum
import Foundation

public enum ConnectionStatus: Hashable {
  case disconnected
  case connecting
  case connected
  case error(Error)
}

public extension ConnectionStatus {
  static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.disconnected, .disconnected):
      return true
    case (.connecting, .connecting):
      return true
    case (.connected, .connected):
      return true
    case let (.error(lErr), .error(rErr)):
      return lErr.isEqual(to: rErr)
    case (.disconnected, _), (.connecting, _), (.connected, _), (.error, _):
      return false
    }
  }

  func hash(into hasher: inout Hasher) {
    switch self {
    case .disconnected:
      hasher.combine(1)
    case .connecting:
      hasher.combine(2)
    case .connected:
      hasher.combine(3)
    case let .error(error):
      hasher.combine(EquatableError(error))
    }
  }
}
