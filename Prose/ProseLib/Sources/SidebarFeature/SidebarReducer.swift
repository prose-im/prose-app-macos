import ComposableArchitecture
import Foundation
// import ProseCore

public struct UserCredentials: Equatable {
    public var jid: String

    public init(jid: String) {
        self.jid = jid
    }
}

public struct SidebarState: Equatable {
    var credentials: UserCredentials

    @BindableState var selection: SidebarID? = .unread

    public init(credentials: UserCredentials) {
        self.credentials = credentials
    }
}

public enum SidebarAction: BindableAction {
    case binding(BindingAction<SidebarState>)
}

public struct SidebarEnvironment {
    public init() {}
}

public let sidebarReducer = Reducer<
    SidebarState,
    SidebarAction,
    SidebarEnvironment
> { _, action, _ in
    switch action {
    case .binding:
        return .none
    }
}.binding()
