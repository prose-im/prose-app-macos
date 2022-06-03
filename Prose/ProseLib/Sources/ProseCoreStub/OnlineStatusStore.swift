//
//  OnlineStatusStore.swift
//  Prose
//
//  Created by Rémi Bardon on 03/06/2022.
//

import SharedModels

/// This is just a simple store sendiong fake data.
/// It should not go into production, it's intended to dynamise the (currently static) app.
public final class OnlineStatusStore {
    public static let shared = OnlineStatusStore()
    
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
    
    private init() {}
    
    public func onlineStatus(for userId: String) -> OnlineStatus? {
        self.onlineStatuses[userId]
    }
}
