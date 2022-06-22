import ComposableArchitecture
import Foundation
import ProseCoreTCA
import SharedModels
import TcaHelpers

public typealias UserCredentials = JID

public struct SidebarState: Equatable {
    public internal(set) var selection: Selection?

    var credentials: UserCredentials
    var roster = Roster(groups: [])
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
    case onAppear
    case onDisappear

    case selection(SidebarState.Selection?)

    case addContactButtonTapped
    case addGroupButtonTapped

    case rosterChanged(Roster)

    case footer(FooterAction)
    case toolbar(ToolbarAction)
}

public struct SidebarEnvironment {
    var proseClient: ProseClient
    var mainQueue: AnySchedulerOf<DispatchQueue>

    public init(proseClient: ProseClient, mainQueue: AnySchedulerOf<DispatchQueue>) {
        self.proseClient = proseClient
        self.mainQueue = mainQueue
    }
}

private enum SidebarEffectToken: CaseIterable, Hashable {
    case rosterSubscription
}

public let sidebarReducer: Reducer<
    SidebarState,
    SidebarAction,
    SidebarEnvironment
> = Reducer.combine([
    footerReducer.pullback(
        state: \SidebarState.footer,
        action: CasePath(SidebarAction.footer),
        environment: { _ in () }
    ),
    toolbarReducer.pullback(
        state: \SidebarState.toolbar,
        action: CasePath(SidebarAction.toolbar),
        environment: { _ in () }
    ),
    Reducer { state, action, environment in
        switch action {
        case .onAppear:
            return environment.proseClient.roster()
                .receive(on: environment.mainQueue)
                .map(SidebarAction.rosterChanged)
                .eraseToEffect()
                .cancellable(id: SidebarEffectToken.rosterSubscription, cancelInFlight: true)

        case .onDisappear:
            return .cancel(token: SidebarEffectToken.self)

        case let .selection(selection):
            state.selection = selection
            return .none

        case .addContactButtonTapped:
            logger.info("Add contact button tapped")
            return .none

        case .addGroupButtonTapped:
            logger.info("Add group button tapped")
            return .none

        case let .rosterChanged(roster):
            state.roster = roster
            return .none

        case .footer, .toolbar:
            return .none
        }
    },
])
