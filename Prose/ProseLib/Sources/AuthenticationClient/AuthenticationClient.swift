//
//  AuthenticationClient.swift
//  Prose
//
//  Created by Rémi Bardon on 21/06/2022.
//

import Combine
import ComposableArchitecture
import SharedModels
import UserDefaultsClient

public struct AuthenticationClient {
    /// Ask for a `JID`. This can be instantaneous, or it can trigger a new log in if some error happens.
    /// The result might come after a long time (needs user input).
    public internal(set) var requireJID: () -> Effect<JID, Never>
    /// This `Publisher` sends a value every time we need a new log in.
    /// Some `Reducer` should listen to this `Publisher` and trigger the login flow when receiving a value.
    /// The result needs to be sent to ``jidSubject``.
    public internal(set) var loginSubject: PassthroughSubject<Void, Never>
    /// After a successful login, this `Publisher` receives the new `JID`.
    public internal(set) var jidSubject: PassthroughSubject<JID, Never>
}

public extension AuthenticationClient {
    static func live(
        userDefaults: UserDefaultsClient,
        loginSubject: PassthroughSubject<Void, Never> = .init(),
        jidSubject: PassthroughSubject<JID, Never> = .init(),
        queue: AnySchedulerOf<DispatchQueue> = .main
    ) -> AuthenticationClient {
        AuthenticationClient(
            requireJID: {
                if let jid = userDefaults.loadCurrentAccount() {
                    return Effect(value: jid)
                }

                loginSubject.send(())

                // NOTE: [Rémi Bardon] We're getting the first result here, but it's not sure the answer
                //       we're getting originated from this request. We could pass a token through
                //       the whole process but I don't think it's worth it at the moment.
                //       I tried creating a new `jidSubject` every time and sending it through `loginSubject`.
                //       It works, and it's probably a very good solution, but at the end we'd need to pass
                //       the publisher through the login flow too, and I thought now is not the right moment
                //       to introduce such a feature.
                return jidSubject.first().receive(on: queue).eraseToEffect()
            },
            loginSubject: loginSubject,
            jidSubject: jidSubject
        )
    }

    static var placeholder: AuthenticationClient {
        AuthenticationClient(
            requireJID: { Effect.none },
            loginSubject: .init(),
            jidSubject: .init()
        )
    }
}
