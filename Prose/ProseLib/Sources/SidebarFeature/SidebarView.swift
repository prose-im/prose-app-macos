//
//  SidebarView.swift
//  Prose
//
//  Created by Valerian Saliou on 11/15/21.
//

import ComposableArchitecture
import SwiftUI

public struct SidebarView: View {
    public typealias State = SidebarState
    public typealias Action = SidebarAction
    
    let store: Store<State, Action>
    
    public init(store: Store<State, Action>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(spacing: 0) {
                Content(selection: viewStore.binding(\.$selection))
                Footer(store: self.store)
            }
            .toolbar(content: SidebarToolbar.init)
        }
    }
}
