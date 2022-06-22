//
//  ChatModel.swift
//  Prose
//
//  Created by Rémi Bardon on 27/03/2022.
//  Copyright © 2022 Prose. All rights reserved.
//

public enum ChatID: Hashable {
    case person(id: JID)
    case group(id: JID)

    public var jid: JID {
        switch self {
        case let .person(id: jid),
             let .group(id: jid):
            return jid
        }
    }

    public var icon: Icon {
        switch self {
        case .person:
            return Icon.directMessage
        case .group:
            return Icon.group
        }
    }
}
