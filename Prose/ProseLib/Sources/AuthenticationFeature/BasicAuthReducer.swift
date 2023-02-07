import AppKit
import AppLocalization
import Combine
import ComposableArchitecture
import Foundation
import ProseCoreTCA
import Toolbox

private let l10n = L10n.Authentication.BasicAuth.self

public struct BasicAuth: ReducerProtocol {
  public struct State: Equatable {
    public enum Field: String, Hashable {
      case address, password
    }

    public enum Popover: String, Hashable {
      case chatAddress, noAccount, passwordLost
    }

    @BindingState var jid: String
    @BindingState var password: String
    @BindingState var focusedField: Field?
    @BindingState var popover: Popover?

    var isLoading: Bool
    var alert: AlertState<Action>?

    var isFormValid: Bool { self.isAddressValid && self.isPasswordValid }
    var isAddressValid: Bool { !self.jid.isEmpty }
    var isPasswordValid: Bool { !self.password.isEmpty }
    var isLogInButtonEnabled: Bool { self.isFormValid }
    /// The action button is shown either when the form is valid or when the login request is in
    /// flight
    /// (for cancellation).
    var isActionButtonEnabled: Bool { self.isLogInButtonEnabled || self.isLoading }

    public init(
      jid: String = "",
      password: String = "",
      focusedField: Field? = nil,
      popover: Popover? = nil,
      isLoading: Bool = false,
      alert: AlertState<Action>? = nil
    ) {
      self.jid = jid
      self.password = password
      self.focusedField = focusedField
      self.popover = popover
      self.isLoading = isLoading
      self.alert = alert
    }
  }

  public enum Action: Equatable, BindableAction {
    case alertDismissed
    case loginButtonTapped, showPopoverTapped(State.Popover)
    case submitTapped(State.Field), cancelLogInTapped
    case loginResult(Result<Authentication.Route, EquatableError>)
    case didPassChallenge(next: Authentication.Route)
    case binding(BindingAction<State>)
  }
  
  @Dependency(\.mainQueue) var mainQueue

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    Reduce { state, action in
      struct CancelId: Hashable {}

      func performLogin() -> EffectTask<Action> {
        guard state.isFormValid else {
          return .none
        }

        state.focusedField = nil
        state.isLoading = true

        let jid: JID
        do {
          jid = try JID(string: state.jid)
        } catch {
          return EffectTask(value: .loginResult(.failure(EquatableError(error))))
        }
        let password = state.password
        
        return .none

//        return environment.proseClient.login(jid, password)
//          .map { _ in AuthRoute.success(jid: jid, password: password) }
//          .receive(on: self.mainQueue)
//          .catchToEffect(Action.loginResult)
//          .cancellable(id: CancelId())
      }

      switch action {
      case .alertDismissed:
        state.alert = nil

      case .loginButtonTapped:
        return performLogin()

      case let .showPopoverTapped(popover):
        state.focusedField = nil
        state.popover = popover

      case .submitTapped(.address):
        state.focusedField = .password

      case .submitTapped(.password):
        return performLogin()

      case .cancelLogInTapped:
        state.isLoading = false
        return EffectTask.cancel(id: CancelId())

      case let .loginResult(.success(route)):
        state.isLoading = false
        return EffectTask(value: .didPassChallenge(next: route))

      case let .loginResult(.failure(reason)):
        logger.debug("Login failure: \(String(reflecting: reason))")
        state.isLoading = false

        state.alert = .init(
          title: TextState(l10n.Error.title),
          message: TextState(reason.localizedDescription)
        )

      case .didPassChallenge, .binding:
        break
      }

      return .none
    }
  }
}
