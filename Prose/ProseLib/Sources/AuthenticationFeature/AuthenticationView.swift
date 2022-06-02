// import ComposableArchitecture
// import SwiftUI
//
// public struct AuthenticationView: View {
//    public typealias State = AuthenticationState
//    public typealias Action = AuthenticationAction
//
//    let store: Store<State, Action>
//
//    public init(store: Store<State, Action>) {
//        self.store = store
//    }
//
//    public var body: some View {
//        WithViewStore(self.store) { viewStore in
//            HStack {
//                Spacer()
//                Form {
//                    Section {
//                        TextField("Jid", text: viewStore.binding(\.$jid))
//                        SecureField("Password", text: viewStore.binding(\.$password))
//                    }
//                    Button("Login") {
//                        viewStore.send(.loginButtonTapped)
//                    }.disabled(!viewStore.isFormValid)
//                }.frame(maxWidth: 500)
//                Spacer()
//            }
//            .alert(self.store.scope(state: \.alert), dismiss: .alertDismissed)
//        }
//    }
// }
