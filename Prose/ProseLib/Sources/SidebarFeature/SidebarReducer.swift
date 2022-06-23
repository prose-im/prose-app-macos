import ComposableArchitecture
import Foundation
import SharedModels

public typealias UserCredentials = JID

public struct SidebarState: Equatable {
    public internal(set) var selection: Selection?

    var credentials: UserCredentials
    var footer: FooterState
    var toolbar = ToolbarState()

    public init(credentials: UserCredentials, selection: Selection? = .unreadStack) {
        self.credentials = credentials
        self.selection = selection
        self.footer = .init(credentials: credentials)
    }
}

public extension SidebarState {
    enum Selection: Hashable {
        case unreadStack
        case replies
        case directMessages
        case peopleAndGroups
        case chat(JID)
    }
}

public enum SidebarAction: Equatable {
    case selection(SidebarState.Selection?)

    case addContactButtonTapped
    case addGroupButtonTapped

    case footer(FooterAction)
    case toolbar(ToolbarAction)
}

public let sidebarReducer: Reducer<
    SidebarState,
    SidebarAction,
    Void
> = Reducer.combine([
    footerReducer.pullback(
        state: \SidebarState.footer,
        action: CasePath(SidebarAction.footer),
        environment: { _ in () }
    ),
    toolbarReducer.pullback(
        state: \SidebarState.toolbar,
        action: CasePath(SidebarAction.toolbar),
        environment: { $0 }
    ),
    Reducer { state, action, _ in
        switch action {
        case let .selection(selection):
            state.selection = selection
            return .none

        case .addContactButtonTapped:
            logger.info("Add contact button tapped")
            return .none

        case .addGroupButtonTapped:
            logger.info("Add group button tapped")
            return .none

        case .footer, .toolbar:
            return .none
        }
    },
])
