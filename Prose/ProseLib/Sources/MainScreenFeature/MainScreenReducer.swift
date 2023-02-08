import ComposableArchitecture
import ConversationFeature
import PasteboardClient
import ProseCoreTCA
import SidebarFeature
import TcaHelpers
import TCAUtils
import UnreadFeature

public struct MainScreen: ReducerProtocol {
  public typealias State = SessionState<MainScreenState>

  public struct MainScreenState: Equatable {
    public var sidebar = Sidebar.SidebarState()
    public fileprivate(set) var isPlaceholder = false

    // https://github.com/prose-im/prose-app-macos/issues/45 says we should disabled this,
    // but we don't support any other predictable value, so let's keep it like this for now.
    var route = Route.unreadStack(.init())

    public init() {}
  }

  public enum Action: Equatable {
    case sidebar(Sidebar.Action)
    case unreadStack(UnreadAction)
    case chat(ConversationAction)
  }

  enum Route: Equatable {
    case unreadStack(UnreadState)
    case replies
    case directMessages
    case peopleAndGroups
    case chat(ConversationState)
  }

  public init() {}

  @Dependency(\.legacyProseClient) var legacyProseClient
  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.pasteboardClient) var pasteboard

  public var body: some ReducerProtocol<State, Action> {
    Scope(state: \.sidebar, action: /Action.sidebar) {
      Sidebar()
    }
    Scope(state: \.route, action: /.self) {
      EmptyReducer()
        .ifCaseLet(/Route.unreadStack, action: /Action.unreadStack) {
          Reduce(unreadReducer, environment: .init())
        }
    }
    EmptyReducer()
      .ifLet(\.chat, action: /Action.chat) {
        Reduce(
          conversationReducer,
          environment: .init(
            proseClient: self.legacyProseClient,
            pasteboard: self.pasteboard,
            mainQueue: self.mainQueue
          )
        )
      }
    EmptyReducer()
      .onChange(of: \.sidebar.selection) { selection, state, _ in
        switch selection {
        case .unreadStack, .none:
          state.route = .unreadStack(.init())
        case .replies:
          state.route = .replies
        case .directMessages:
          state.route = .directMessages
        case .peopleAndGroups:
          state.route = .peopleAndGroups
        case let .chat(jid):
          var conversationState = SessionState(
            currentUser: state.currentUser,
            childState: ConversationState(chatId: jid)
          )
          var effects = EffectTask<MainScreen.Action>.none

          // If another chat was selected already, we'll manually send the `.onAppear` and
          // `.onDisappear` actions, because SwiftUI doesn't and simply sees it as a content change.
          if var priorConversationState = state.get(MainScreen.Route.Paths.chat) {
            let environment = ConversationEnvironment(
              proseClient: self.legacyProseClient,
              pasteboard: self.pasteboard,
              mainQueue: self.mainQueue
            )
          
            effects = .concatenate([
              conversationReducer(&priorConversationState, .onDisappear, environment)
                .map(MainScreen.Action.chat),
              conversationReducer(&conversationState, .onAppear, environment)
                .map(MainScreen.Action.chat),
            ])
          }

          state.route = .chat(conversationState.childState)
          return effects
        }
        return .none
      }
  }
}

public extension SessionState where ChildState == MainScreen.MainScreenState {
  static var placeholder: Self = {
    var state = SessionState(
      currentUser: .init(jid: .init(rawValue: "hello@world.org").expect("Invalid placeholder JID")),
      childState: MainScreen.MainScreenState()
    )
    state.isPlaceholder = true
    return state
  }()
}

private extension SessionState where ChildState == MainScreen.MainScreenState {
  var sidebar: Sidebar.State {
    get { self.get(\.sidebar) }
    set { self.set(\.sidebar, newValue) }
  }

  var chat: SessionState<ConversationState>? {
    get { self.get(MainScreen.Route.Paths.chat) }
    set { self.set(MainScreen.Route.Paths.chat, newValue) }
  }
}

private extension MainScreen.Route {
  enum Paths {
    static let chat: OptionalPath = (\MainScreen.MainScreenState.route)
      .case(CasePath(MainScreen.Route.chat))
  }
}
