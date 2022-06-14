#if canImport(SwiftUI)
    import SwiftUI
#endif

public enum OnlineStatus: Hashable, CaseIterable {
    case offline, online
}

public extension OnlineStatus {
    var localizedDescription: String {
        switch self {
        case .offline:
            return "Offline"
        case .online:
            return "Online"
        }
    }
}

public enum Availability: Hashable, CaseIterable {
    case available, doNotDisturb
}

public extension Availability {
    var localizedDescription: String {
        switch self {
        case .available:
            return "Available for chat"
        case .doNotDisturb:
            return "Do not disturb"
        }
    }

    #if canImport(SwiftUI)
        var color: Color {
            switch self {
            case .available:
                return .green
            case .doNotDisturb:
                return .orange
            }
        }
    #endif
}
