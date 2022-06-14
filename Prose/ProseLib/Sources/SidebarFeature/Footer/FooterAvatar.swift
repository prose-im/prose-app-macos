//
//  FooterAvatar.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import AppLocalization
import ComposableArchitecture
import ProseUI
import SharedModels
import SwiftUI

private let l10n = L10n.Sidebar.Footer.Actions.Account.self

// MARK: - View

/// User avatar in the left sidebar footer
struct FooterAvatar: View {
    typealias State = FooterAvatarState
    typealias Action = FooterAvatarAction

    let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    var body: some View {
        WithViewStore(self.store) { viewStore in
            Button(action: { actions.send(.avatarTapped) }) {
                Avatar(viewStore.avatar, size: viewStore.size)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(l10n.label)
            .overlay(alignment: .bottomTrailing) {
                statusIndicator(viewStore: viewStore)
                    // Offset of half the size minus 2 points (otherwise it looks odd)
                    .alignmentGuide(.trailing) { d in d.width / 2 + 2 }
                    .alignmentGuide(.bottom) { d in d.height / 2 + 2 }
            }
            .popover(isPresented: viewStore.binding(\State.$showingPopover), content: popover)
        }
    }

    @ViewBuilder
    private func statusIndicator(viewStore: ViewStore<State, Action>) -> some View {
        if viewStore.status != .offline {
            OnlineStatusIndicator(status: viewStore.status)
                .padding(2)
                .background {
                    Circle()
                        .fill(Color.white)
                }
        }
    }

    private func popover() -> some View {
        Self.popover(store: self.store)
    }

    @ViewBuilder
    fileprivate static func popover(store: Store<State, Action>) -> some View {
        let actions: ViewStore<Void, Action> = ViewStore(store.stateless)
        VStack(alignment: .leading, spacing: 16) {
            // TODO: [Rémi Bardon] Refactor this view out
            HStack {
                // TODO: [Rémi Bardon] Change this to Crisp icon
                Avatar(PreviewImages.Avatars.baptiste.rawValue, size: 32)
                VStack(alignment: .leading) {
                    Text(verbatim: "Baptiste Jamin")
                        .font(.headline)
                    Text(verbatim: "baptiste@crisp.chat")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .foregroundColor(.primary)
            }
            // Make hit box full width
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Baptiste Jamin (baptiste@crisp.chat)")

            GroupBox {
                Button { actions.send(.updateMoodTapped) } label: {
                    HStack(spacing: 4) {
                        Text("🚀")
                        Text(verbatim: "Update mood")
                    }
                    .disclosureIndicator()
                }
//                .accessibilityElement(children: .ignore)
//                .accessibilityLabel(L10n.Server.ConnectedTo.label("Crisp (crisp.chat)"))
                Menu("Change availability") {
                    Self.availabilityMenu(store: store)
                }
                // NOTE: [Rémi Bardon] This inverted padding fixes the padding SwiftUI adds for `Menu`s.
                .padding(.leading, -3)
                // NOTE: [Rémi Bardon] Having the disclosure indicator outside the menu label
                //       reduces the hit box, but we can't have it inside, otherwise SwiftUI
                //       places the `Image` on the leading edge.
                .disclosureIndicator()
                Button { actions.send(.pauseNotificationsTapped) } label: {
                    Text(verbatim: "Pause notifications")
                        .disclosureIndicator()
                }
            }
            GroupBox {
                Button("Edit profile") { actions.send(.editProfileTapped) }
                Button("Account settings") { actions.send(.accountSettingsTapped) }
            }
            GroupBox {
                Button { actions.send(.offlineModeTapped) } label: {
                    Text(verbatim: "Offline mode")
                        .disclosureIndicator()
                }
            }
            GroupBox {
                Button("Sign me out", role: .destructive) { actions.send(.signOutTapped) }
            }
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .buttonStyle(SidebarFooterPopoverButtonStyle())
        .groupBoxStyle(VStackGroupBoxStyle(alignment: .leading, spacing: 6))
        .multilineTextAlignment(.leading)
        .padding(12)
        .frame(width: 196)
    }

    @ViewBuilder
    static func availabilityMenu(store: Store<State, Action>) -> some View {
        let actions: ViewStore<Void, Action> = ViewStore(store.stateless)
        ForEach(Availability.allCases, id: \.self) { availability in
            Button { actions.send(.changeAvailabilityTapped(availability)) } label: {
                // NOTE: [Rémi Bardon] We could use a `Label` or `HStack` here,
                //       to add the colored dot, but `Menu`s don't display it.
                Text(availability.localizedDescription)
            }
            .tag(availability)
        }
    }
}

struct VStackGroupBoxStyle: GroupBoxStyle {
    let alignment: HorizontalAlignment
    let spacing: CGFloat?

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: self.alignment, spacing: self.spacing) { configuration.content }
    }
}

struct SidebarFooterPopoverButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity((configuration.isPressed || !self.isEnabled) ? 0.5 : 1)
            .foregroundColor(Self.color(for: configuration.role))
            // Make hit box full width
            // NOTE: [Rémi Bardon] We could avoid making the hit box full width for destructive actions.
            .frame(maxWidth: .infinity, alignment: .leading)
            // Allow hits in the transparent areas
            .contentShape(Rectangle())
    }

    static func color(for role: ButtonRole?) -> Color? {
        switch role {
        case .some(.destructive):
            return .red
        default:
            return nil
        }
    }
}

extension View {
    func disclosureIndicator() -> some View {
        HStack(spacing: 4) {
            self
                .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: "chevron.forward")
                .padding(.trailing, 2)
        }
//        // Allow hits in the transparent areas
//        .contentShape(Rectangle())
    }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let footerAvatarReducer: Reducer<
    FooterAvatarState,
    FooterAvatarAction,
    Void
> = Reducer { state, action, _ in
    switch action {
    case .avatarTapped:
        state.showingPopover = true

    case .binding:
        break

    default:
        // TODO: [Rémi Bardon] Handle actions
        print("Received unhandled action: \(String(describing: action))")
    }

    return .none
}.binding()

// MARK: State

public struct FooterAvatarState: Equatable {
    let avatar: String
    let status: OnlineStatus
    let size: CGFloat

    @BindableState var showingPopover: Bool

    public init(
        avatar: String,
        status: OnlineStatus = .offline,
        size: CGFloat = 32,
        showingPopover: Bool = false
    ) {
        self.avatar = avatar
        self.status = status
        self.size = size
        self.showingPopover = showingPopover
    }
}

// MARK: Actions

public enum FooterAvatarAction: Equatable, BindableAction {
    case avatarTapped
    case updateMoodTapped
    case changeAvailabilityTapped(Availability)
    case pauseNotificationsTapped
    case editProfileTapped
    case accountSettingsTapped
    case offlineModeTapped
    case signOutTapped
    case binding(BindingAction<FooterAvatarState>)
}

// MARK: - Previews

#if DEBUG
    import PreviewAssets

    struct FooterAvatar_Previews: PreviewProvider {
        private struct Preview: View {
            var body: some View {
                HStack {
                    ForEach(OnlineStatus.allCases, id: \.self) { status in
                        content(state: FooterAvatarState(
                            avatar: PreviewImages.Avatars.valerian.rawValue,
                            status: status
                        ))
                    }
                }
                .padding()
                let store = Store(
                    initialState: FooterAvatarState(
                        avatar: PreviewImages.Avatars.valerian.rawValue,
                        status: .online
                    ),
                    reducer: footerAvatarReducer,
                    environment: ()
                )
                FooterAvatar.popover(store: store)
                VStack(alignment: .leading) {
                    FooterAvatar.availabilityMenu(store: store)
                }
                .padding()
                .buttonStyle(.plain)
            }

            private func content(state: FooterAvatarState) -> some View {
                FooterAvatar(store: Store(
                    initialState: state,
                    reducer: footerAvatarReducer,
                    environment: ()
                ))
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
#endif
