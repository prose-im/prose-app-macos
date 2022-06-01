//
//  FooterActionMenu.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import ComposableArchitecture
import PreviewAssets
import SwiftUI

// swiftlint:disable file_types_order

// MARK: - View

/// Quick actions button in the left sidebar footer.
struct FooterActionMenu: View {
    typealias State = FooterActionMenuState
    typealias Action = FooterActionMenuAction

    let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    var body: some View {
        WithViewStore(self.store) { viewStore in
            Button(action: { actions.send(.showMenuTapped) }) {
                ZStack {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.textSecondary)

                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color.secondary.opacity(0.125))
                        .frame(width: 24, height: 32)
                }
            }
            .buttonStyle(.plain)
            .popover(isPresented: viewStore.binding(\State.$showingMenu), content: popover)
        }
    }

    @ViewBuilder
    private func popover() -> some View {
        VStack(alignment: .leading) {
            // TODO: [Rémi Bardon] Refactor this view out
            HStack {
                // TODO: [Rémi Bardon] Change this to Crisp icon
                Image(PreviewImages.Avatars.baptiste.rawValue)
                    .resizable()
                    .frame(width: 48, height: 48)
                    .cornerRadius(4)
                VStack(alignment: .leading) {
                    Text("Crisp")
                        .font(.title3.bold())
                    Text("crisp.chat")
                        .monospacedDigit()
                        .foregroundColor(.secondary)
                }
                .foregroundColor(.primary)
            }

            GroupBox("Switch account") {
                VStack(spacing: 4) {
                    Button { actions.send(.switchAccountTapped(account: "crisp.chat")) } label: {
                        Label {
                            HStack(spacing: 4) {
                                Text("Crisp")
                                Text("–")
                                Text("crisp.chat").monospacedDigit()
                            }
                            Spacer()
                            Image(systemName: "checkmark")
                                .padding(.horizontal, 4)
                        } icon: {
                            // TODO: [Rémi Bardon] Change this to Crisp icon
                            Image(PreviewImages.Avatars.baptiste.rawValue)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 24, height: 24)
                                .cornerRadius(4)
                        }
                        // Make hit box full width
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(.interaction, Rectangle())
                    }
                    Button { actions.send(.switchAccountTapped(account: "makair.life")) } label: {
                        Label {
                            HStack(spacing: 4) {
                                Text("MakAir")
                                Text("–")
                                Text("makair.life").monospacedDigit()
                            }
                        } icon: {
                            // TODO: [Rémi Bardon] Change this to MakAir icon
                            Image(PreviewImages.Avatars.baptiste.rawValue)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 24, height: 24)
                                .cornerRadius(4)
                        }
                        // Make hit box full width
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(.interaction, Rectangle())
                    }
                    Button { actions.send(.connectAccountTapped) } label: {
                        Label {
                            Text("Connect account")
                        } icon: {
                            Image(systemName: "plus")
                                .frame(width: 24, height: 24)
                        }
                        // Make hit box full width
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(.interaction, Rectangle())
                    }
                    .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
            }

            GroupBox("Server settings") {
                Link(destination: URL(string: "https://crisp.chat")!) {
                    HStack {
                        Text("Manage server")
                        Spacer()
                        Image(systemName: "arrow.up.forward.square")
                    }
                    // Make hit box full width
                    .frame(maxWidth: .infinity)
                    .contentShape(.interaction, Rectangle())
                }
                .foregroundColor(.accentColor)
            }
        }
        .padding(8)
        .frame(minWidth: 256)
    }
}

// MARK: - The Composabe Architecture

// MARK: Reducer

private let footerActionMenuCoreReducer: Reducer<
    FooterActionMenuState,
    FooterActionMenuAction,
    Void
> = Reducer { state, action, _ in
    switch action {
    case .showMenuTapped:
        state.showingMenu = true

    case let .switchAccountTapped(account: account):
        // TODO: [Rémi Bardon] Handle action
        print("Switch account to '\(account)' tapped")
        state.showingMenu = false

    case .connectAccountTapped:
        // TODO: [Rémi Bardon] Handle action
        print("Connect account tapped")

    case .binding:
        break
    }

    return .none
}.binding()
let footerActionMenuReducer: Reducer<
    FooterActionMenuState,
    FooterActionMenuAction,
    Void
> = Reducer.combine([
    footerActionMenuCoreReducer,
])

// MARK: State

public struct FooterActionMenuState: Equatable {
    @BindableState public var showingMenu: Bool

    public init(
        showingMenu: Bool = false
    ) {
        self.showingMenu = showingMenu
    }
}

// MARK: Actions

public enum FooterActionMenuAction: Equatable, BindableAction {
    case showMenuTapped
    case switchAccountTapped(account: String)
    case connectAccountTapped
    case binding(BindingAction<FooterActionMenuState>)
}

// MARK: - Previews

struct FooterActionMenu_Previews: PreviewProvider {
    private struct Preview: View {
        var body: some View {
            FooterActionMenu(store: Store(
                initialState: FooterActionMenuState(),
                reducer: footerActionMenuReducer,
                environment: ()
            ))
            .padding()
        }
    }

    static var previews: some View {
        Preview()
            .preferredColorScheme(.light)
            .previewDisplayName("Light")

        Preview()
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark")
    }
}
