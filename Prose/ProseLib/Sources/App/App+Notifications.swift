import ComposableArchitecture

extension ReducerProtocol<App.State, App.Action> {
  func handleNotifications() -> some ReducerProtocol<App.State, App.Action> {
    Notifications(base: self)
  }
}

private struct Notifications<
  Base: ReducerProtocol<App.State, App.Action>
>: ReducerProtocol {
  let base: Base

  var body: some ReducerProtocol<App.State, App.Action> {
    self.base
    self.core
  }

  @ReducerBuilder<State, Action>
  private var core: some ReducerProtocol<State, Action> {
//          environment.proseClient.incomingMessages()
//            .flatMap { message in
//              environment.proseClient.userInfos([message.from])
//                .catch { _ in Just([:]) }
//                .compactMap { userInfos in
//                  userInfos[message.from].map { (message: message, userInfo: $0) }
//                }
//                .prefix(1)
//            }
//            .receive(on: environment.mainQueue)
//            .eraseToEffect()
//            .map { args in AppAction.didReceiveMessage(args.message, args.userInfo) }
  
    Reduce { _, _ in
      .none
    }
  }
}
