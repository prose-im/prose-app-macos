//
//  StatusStore.swift
//  Prose
//
//  Created by Rémi Bardon on 03/06/2022.
//

import Foundation
import SharedModels

public struct StatusStore {
    public let onlineStatus: (_ jid: JID) -> OnlineStatus?
    public let lastSeenDate: (_ jid: JID) -> Date?
    public let timeZone: (_ jid: JID) -> TimeZone?
    public let statusLine: (_ jid: JID) -> (Character, String)?
}

public extension StatusStore {
    static var stub: Self {
        Self(
            onlineStatus: StubStatusStore.shared.onlineStatus(for:),
            lastSeenDate: StubStatusStore.shared.lastSeenDate(for:),
            timeZone: StubStatusStore.shared.timeZone(for:),
            statusLine: StubStatusStore.shared.statusLine(for:)
        )
    }
}

/// This is just a simple store sending fake data.
/// It should not go into production, it's intended to dynamise the (currently static) app.
fileprivate final class StubStatusStore {
    fileprivate static let shared = StubStatusStore()

    private lazy var _onlineStatuses: [JID: OnlineStatus] = [
        "alexandre@crisp.chat": .offline,
        "antoine@crisp.chat": .online,
        "baptiste@crisp.chat": .online,
        "camille@crisp.chat": .online,
        "constellation-health@crisp.chat": .online,
        "eliott@crisp.chat": .offline,
        "julien@thefamily.com": .offline,
        "valerian@crisp.chat": .online,
    ]
    private lazy var _lastSeenDates: [JID: Date] = [
        "alexandre@crisp.chat": Date.now - 10_000,
        "antoine@crisp.chat": Date.now - 1_000,
        "baptiste@crisp.chat": Date.now - 30,
        "camille@crisp.chat": Date.now - 200,
        "constellation-health@crisp.chat": Date.now,
        "eliott@crisp.chat": Date.now - 12_000,
        "julien@thefamily.com": Date.now - 5_000,
        "valerian@crisp.chat": Date.now - 100,
    ]
    private lazy var _timeZones: [JID: TimeZone] = [
        "alexandre@crisp.chat": TimeZone(abbreviation: "WEST")!,
        "antoine@crisp.chat": TimeZone(abbreviation: "WEST")!,
        "baptiste@crisp.chat": TimeZone(abbreviation: "WEST")!,
        "camille@crisp.chat": TimeZone(abbreviation: "WEST")!,
        "constellation-health@crisp.chat": TimeZone(abbreviation: "WEST")!,
        "eliott@crisp.chat": TimeZone(abbreviation: "WEST")!,
        "julien@thefamily.com": TimeZone(abbreviation: "WEST")!,
        "valerian@crisp.chat": TimeZone(abbreviation: "WEST")!,
    ]
    private lazy var _statusLines: [JID: (Character, String)] = [
        "alexandre@crisp.chat": ("👨‍💻", "Working"),
        "antoine@crisp.chat": ("👨‍💻", "Working"),
        "baptiste@crisp.chat": ("🚀", "Building new features"),
        "camille@crisp.chat": ("🛟", "Helping clients"),
        "constellation-health@crisp.chat": ("🔭", "Monitoring things"),
        "eliott@crisp.chat": ("👨‍💻", "Working"),
        "julien@thefamily.com": ("👨‍💻", "Working"),
        "valerian@crisp.chat": ("👨‍💻", "Focusing on code"),
    ]

    private init() {}

    fileprivate func onlineStatus(for jid: JID) -> OnlineStatus? {
        self._onlineStatuses[jid]
    }

    fileprivate func lastSeenDate(for jid: JID) -> Date? {
        self._lastSeenDates[jid]
    }

    fileprivate func timeZone(for jid: JID) -> TimeZone? {
        self._timeZones[jid]
    }

    fileprivate func statusLine(for jid: JID) -> (Character, String)? {
        self._statusLines[jid]
    }
}
