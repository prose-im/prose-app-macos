//
//  InformationSection.swift
//  Prose
//
//  Created by Valerian Saliou on 11/23/21.
//

import AppLocalization
import Assets
import ComposableArchitecture
import ProseCoreStub
import SwiftUI

private let l10n = L10n.Content.MessageDetails.Information.self

// MARK: - View

struct InformationSection: View {
    typealias State = InformationSectionState
    typealias Action = InformationSectionAction

    let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    var body: some View {
        GroupBox(l10n.title) {
            WithViewStore(self.store) { viewStore in
                label(viewStore.emailAddress, systemImage: "envelope.fill")
                label(viewStore.phoneNumber, systemImage: "iphone")
                Label {
                    // TODO: Localize
                    Text("Active \(viewStore.lastSeenDate, format: .relative(presentation: .numeric, unitsStyle: .wide))")
                } icon: {
                    Image(systemName: "hand.wave.fill")
                        .unredacted()
                }
                label(viewStore.localDateString, systemImage: "clock.fill")
                label(viewStore.location, systemImage: "location.fill")
                Label {
                    Text("“\(viewStore.statusMessage)”")
                        .foregroundColor(.textSecondary)
                } icon: {
                    Text(String(viewStore.statusIcon))
                }
            }
        }
    }

    private func label(_ title: String, systemImage: String) -> some View {
        Label {
            Text(title)
        } icon: {
            Image(systemName: systemImage)
                .unredacted()
        }
    }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let informationSectionReducer: Reducer<
    InformationSectionState,
    InformationSectionAction,
    Void
> = Reducer.empty

// MARK: State

public struct InformationSectionState: Equatable {
    let emailAddress: String
    let phoneNumber: String
    let lastSeenDate: Date
    let timeZone: TimeZone
    let location: String
    let statusIcon: Character
    let statusMessage: String

    var localDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = self.timeZone
        dateFormatter.timeStyle = .long
        return dateFormatter.string(from: Date.now)
    }

    public init(
        emailAddress: String,
        phoneNumber: String,
        lastSeenDate: Date,
        timeZone: TimeZone,
        location: String,
        statusIcon: Character,
        statusMessage: String
    ) {
        self.emailAddress = emailAddress
        self.phoneNumber = phoneNumber
        self.lastSeenDate = lastSeenDate
        self.timeZone = timeZone
        self.location = location
        self.statusIcon = statusIcon
        self.statusMessage = statusMessage
    }
}

public extension InformationSectionState {
    init(
        from user: User,
        lastSeenDate: Date,
        timeZone: TimeZone,
        statusIcon: Character,
        statusMessage: String
    ) {
        self.init(
            emailAddress: user.emailAddress,
            phoneNumber: user.phoneNumber,
            lastSeenDate: lastSeenDate,
            timeZone: timeZone,
            location: user.location,
            statusIcon: statusIcon,
            statusMessage: statusMessage
        )
    }
}

extension InformationSectionState {
    static var placeholder: InformationSectionState {
        InformationSectionState(
            emailAddress: "valerian@crisp.chat",
            phoneNumber: "+33 6 12 34 56",
            lastSeenDate: Date.now - 1_000,
            timeZone: TimeZone(abbreviation: "WEST")!,
            location: "Lisbon, Portugal",
            statusIcon: "👨‍💻",
            statusMessage: "Focusing on code"
        )
    }
}

// MARK: Actions

public enum InformationSectionAction: Equatable {}

// MARK: - Previews

struct InformationSection_Previews: PreviewProvider {
    static var previews: some View {
        InformationSection(store: Store(
            initialState: InformationSectionState(
                emailAddress: "valerian@crisp.chat",
                phoneNumber: "+33 6 12 34 56",
                lastSeenDate: Date.now - 1_000,
                timeZone: TimeZone(abbreviation: "WEST")!,
                location: "Lisbon, Portugal",
                statusIcon: "👨‍💻",
                statusMessage: "Focusing on code"
            ),
            reducer: informationSectionReducer,
            environment: ()
        ))
    }
}
