//
//  StatusStore.swift
//  Prose
//
//  Created by Rémi Bardon on 03/06/2022.
//

import Foundation
import SharedModels

/// This is just a simple store sendiong fake data.
/// It should not go into production, it's intended to dynamise the (currently static) app.
public final class StatusStore {
    public static let shared = StatusStore()

    private let onlineStatuses: [String: OnlineStatus] = [
        "id-alexandre": .offline,
        "id-antoine": .online,
        "id-baptiste": .online,
        "id-camille": .online,
        "id-constellation-health": .online,
        "id-eliott": .offline,
        "id-julien": .offline,
        "id-valerian": .online,
    ]
    private let lastSeenDates: [String: Date] = [
        "id-alexandre": Date.now - 10_000,
        "id-antoine": Date.now - 1_000,
        "id-baptiste": Date.now - 30,
        "id-camille": Date.now - 200,
        "id-constellation-health": Date.now,
        "id-eliott": Date.now - 12_000,
        "id-julien": Date.now - 5_000,
        "id-valerian": Date.now - 100,
    ]
    private let timeZones: [String: TimeZone] = [
        "id-alexandre": TimeZone(abbreviation: "WEST")!,
        "id-antoine": TimeZone(abbreviation: "WEST")!,
        "id-baptiste": TimeZone(abbreviation: "WEST")!,
        "id-camille": TimeZone(abbreviation: "WEST")!,
        "id-constellation-health": TimeZone(abbreviation: "WEST")!,
        "id-eliott": TimeZone(abbreviation: "WEST")!,
        "id-julien": TimeZone(abbreviation: "WEST")!,
        "id-valerian": TimeZone(abbreviation: "WEST")!,
    ]
    private let statusLines: [String: (Character, String)] = [
        "id-alexandre": ("👨‍💻", "Working"),
        "id-antoine": ("👨‍💻", "Working"),
        "id-baptiste": ("🚀", "Building new features"),
        "id-camille": ("🛟", "Helping clients"),
        "id-constellation-health": ("🔭", "Monitoring things"),
        "id-eliott": ("👨‍💻", "Working"),
        "id-julien": ("👨‍💻", "Working"),
        "id-valerian": ("👨‍💻", "Focusing on code"),
    ]

    private init() {}

    public func onlineStatus(for userId: String) -> OnlineStatus? {
        self.onlineStatuses[userId]
    }

    public func lastSeenDate(for userId: String) -> Date? {
        self.lastSeenDates[userId]
    }

    public func timeZone(for userId: String) -> TimeZone? {
        self.timeZones[userId]
    }

    public func statusLine(for userId: String) -> (Character, String)? {
        self.statusLines[userId]
    }
}
