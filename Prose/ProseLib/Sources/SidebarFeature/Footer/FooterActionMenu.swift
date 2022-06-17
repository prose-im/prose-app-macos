//
//  FooterActionMenu.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import AppLocalization
import ComposableArchitecture
import PreviewAssets
import ProseUI
import SwiftUI

// MARK: - View

private let l10n = L10n.Sidebar.Footer.Actions.self

/// Quick actions button in the left sidebar footer.
struct FooterActionMenu: View {
    typealias State = FooterActionMenuState
    typealias Action = FooterActionMenuAction

    @Environment(\.redactionReasons) private var redactionReasons

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
                .unredacted()
                .disabled(redactionReasons.contains(.placeholder))
            }
            .buttonStyle(.plain)
            .popover(isPresented: viewStore.binding(\State.$showingMenu), content: popover)
            .accessibilityLabel(l10n.Server.label)
            // FIXME: [Rémi Bardon] Custom actions don't show up in the Accessibility Inspector, is it working?
            .accessibilityAction(named: l10n.Server.SwitchAccount.New.label) { actions.send(.connectAccountTapped) }
            .accessibilityAction(named: l10n.Server.ServerSettings.Manage.label) { actions.send(.manageServerTapped) }
        }
    }

    @ViewBuilder
    private func popover() -> some View {
        Self.popover(store: self.store)
    }

    @ViewBuilder
    fileprivate static func popover(store: Store<State, Action>) -> some View {
        let actions: ViewStore<Void, Action> = ViewStore(store.stateless)
        VStack(alignment: .leading) {
            // TODO: [Rémi Bardon] Refactor this view out
            HStack {
                // TODO: [Rémi Bardon] Change this to Crisp icon
                Avatar(PreviewImages.Avatars.baptiste.rawValue, size: 48)
                VStack(alignment: .leading) {
                    Text("Crisp")
                        .font(.title3.bold())
                    Text("crisp.chat")
                        .monospacedDigit()
                        .foregroundColor(.secondary)
                }
                .foregroundColor(.primary)
            }
            // Make hit box full width
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape([.interaction, .focusEffect], Rectangle())
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(L10n.Server.ConnectedTo.label("Crisp (crisp.chat)"))

            GroupBox(l10n.Server.SwitchAccount.title) {
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
                        .contentShape([.interaction, .focusEffect], Rectangle())
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(L10n.Server.ConnectedTo.label("Crisp (crisp.chat)"))
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
                        .contentShape([.interaction, .focusEffect], Rectangle())
                    }
                    .accessibilityLabel(l10n.Server.SwitchAccount.label("MakAir (makair.life)"))
                    Button { actions.send(.connectAccountTapped) } label: {
                        Label {
                            Text(l10n.Server.SwitchAccount.New.label)
                        } icon: {
                            Image(systemName: "plus")
                                .frame(width: 24, height: 24)
                        }
                        // Make hit box full width
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape([.interaction, .focusEffect], Rectangle())
                    }
                    .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
            }

            GroupBox(l10n.Server.ServerSettings.title) {
                Link(destination: URL(string: "https://crisp.chat")!) {
                    HStack {
                        Text(l10n.Server.ServerSettings.Manage.label)
                        Spacer()
                        Image(systemName: "arrow.up.forward.square")
                    }
                    // Make hit box full width
                    .frame(maxWidth: .infinity)
                    .contentShape([.interaction, .focusEffect], Rectangle())
                }
                .foregroundColor(.accentColor)
            }
        }
        .padding(8)
        .frame(minWidth: 256)
    }
}

// MARK: - The Composable Architecture

// MARK: Reducer

let footerActionMenuReducer: Reducer<
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

    case .manageServerTapped:
        // TODO: [Rémi Bardon] Handle action (find a way to open a URL)
        print("Manage server tapped")

    case .binding:
        break
    }

    return .none
}.binding()

// MARK: State

public struct FooterActionMenuState: Equatable {
    @BindableState var showingMenu: Bool

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
    /// Only here for accessibility
    case manageServerTapped
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
            FooterActionMenu.popover(store: Store(
                initialState: FooterActionMenuState(),
                reducer: footerActionMenuReducer,
                environment: ()
            ))
            .frame(width: 256)
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
