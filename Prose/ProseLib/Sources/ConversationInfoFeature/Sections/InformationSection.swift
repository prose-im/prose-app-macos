//
//  Info+InformationSection.swift
//  Prose
//
//  Created by Valerian Saliou on 11/23/21.
//

import AppLocalization
import Assets
import ProseCoreStub
import SwiftUI

private let l10n = L10n.Content.MessageDetails.Information.self

struct InformationSection: View {
    let model: InformationSectionModel
    var localDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = self.model.timeZone
        dateFormatter.timeStyle = .long
        return dateFormatter.string(from: Date.now)
    }

    var body: some View {
        GroupBox(l10n.title) {
            label(model.emailAddress, systemImage: "envelope.fill")
            label(model.phoneNumber, systemImage: "iphone")
            Label {
                // TODO: Localize
                Text("Active \(model.lastSeenDate, format: .relative(presentation: .numeric, unitsStyle: .wide))")
            } icon: {
                Image(systemName: "hand.wave.fill")
                    .unredacted()
            }
            label(localDateString, systemImage: "clock.fill")
            label(model.location, systemImage: "location.fill")
            Label {
                Text("“\(model.statusMessage)”")
                    .foregroundColor(.textSecondary)
            } icon: {
                Text(String(model.statusIcon))
            }
        }
    }

    @ViewBuilder
    private func label(_ title: String, systemImage: String) -> some View {
        Label {
            Text(title)
        } icon: {
            Image(systemName: systemImage)
                .unredacted()
        }
    }
}

public struct InformationSectionModel: Equatable {
    let emailAddress: String
    let phoneNumber: String
    let lastSeenDate: Date
    let timeZone: TimeZone
    let location: String
    let statusIcon: Character
    let statusMessage: String

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

public extension InformationSectionModel {
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

extension InformationSectionModel {
    static var placeholder: Self {
        Self(
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

// struct InformationSection_Previews: PreviewProvider {
//    static var previews: some View {
//        InformationSection()
//    }
// }
