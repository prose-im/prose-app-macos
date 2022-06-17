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
                Avatar(viewStore.avatar, size: 32)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(l10n.label)
            .overlay(alignment: .bottomTrailing) {
                AvailabilityIndicator(availability: viewStore.availability)
                    // Offset of half the size minus 2 points (otherwise it looks odd)
                    .alignmentGuide(.trailing) { d in d.width / 2 + 2 }
                    .alignmentGuide(.bottom) { d in d.height / 2 + 2 }
            }
            .popover(isPresented: viewStore.binding(\State.$showingPopover), content: popover)
        }
    }

    private func popover() -> some View {
        Self.popover(store: self.store)
    }

    fileprivate static func popover(store: Store<State, Action>) -> some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: 16) {
                // TODO: [Rémi Bardon] Refactor this view out
                HStack {
                    // TODO: [Rémi Bardon] Change this to Crisp icon
                    Avatar(PreviewImages.Avatars.baptiste.rawValue, size: 32)
                    VStack(alignment: .leading) {
                        Text(verbatim: viewStore.fullName)
                            .font(.headline)
                        Text(verbatim: viewStore.jid)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .foregroundColor(.primary)
                }
                // Make hit box full width
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(l10n.Header.label(viewStore.fullName, viewStore.jid))

                GroupBox {
                    Button { viewStore.send(.updateMoodTapped) } label: {
                        HStack(spacing: 4) {
                            Text(String(viewStore.statusIcon))
                                .accessibilityHidden(true)
                            Text(verbatim: l10n.UpdateMood.title)
                        }
                        .disclosureIndicator()
                    }
                    Menu(l10n.ChangeAvailability.title) {
                        Self.availabilityMenu(store: store)
                    }
                    // NOTE: [Rémi Bardon] This inverted padding fixes the padding SwiftUI adds for `Menu`s.
                    .padding(.leading, -3)
                    // NOTE: [Rémi Bardon] Having the disclosure indicator outside the menu label
                    //       reduces the hit box, but we can't have it inside, otherwise SwiftUI
                    //       places the `Image` on the leading edge.
                    .disclosureIndicator()
                    Button { viewStore.send(.pauseNotificationsTapped) } label: {
                        Text(verbatim: l10n.PauseNotifications.title)
                            .disclosureIndicator()
                    }
                }
                GroupBox {
                    Button(l10n.EditProfile.title) { viewStore.send(.editProfileTapped) }
                    Button(l10n.AccountSettings.title) { viewStore.send(.accountSettingsTapped) }
                }
                GroupBox {
                    Button { viewStore.send(.offlineModeTapped) } label: {
                        Text(verbatim: l10n.OfflineMode.title)
                            .disclosureIndicator()
                    }
                }
                GroupBox {
                    Button(l10n.SignOut.title, role: .destructive) { viewStore.send(.signOutTapped) }
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
    }

    static func availabilityMenu(store: Store<State, Action>) -> some View {
        WithViewStore(store) { viewStore in
            ForEach(Availability.allCases, id: \.self) { availability in
                Button { viewStore.send(.changeAvailabilityTapped(availability)) } label: {
                    HStack {
                        // NOTE: [Rémi Bardon] We could use a `Label` or `HStack` here,
                        //       to add the colored dot, but `Menu`s don't display it.
                        Text(availability.localizedDescription)
                        if viewStore.availability == availability {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .tag(availability)
                .disabled(viewStore.availability == availability)
            }
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

    case let .changeAvailabilityTapped(availability):
        state.availability = availability
        
    case .signOutTapped:
        state.showingPopover = false

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
    var avatar: String
    var availability: Availability
    var fullName: String
    var jid: String
    var statusIcon: Character
    var statusMessage: String

    @BindableState var showingPopover: Bool

    public init(
        avatar: String,
        availability: Availability = .available,
        fullName: String = "Baptiste Jamin",
        jid: String = "baptiste@crisp.chat",
        statusIcon: Character = "🚀",
        statusMessage: String = "Building new features.",
        showingPopover: Bool = false
    ) {
        self.avatar = avatar
        self.availability = availability
        self.showingPopover = showingPopover
        self.fullName = fullName
        self.jid = jid
        self.statusIcon = statusIcon
        self.statusMessage = statusMessage
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
                    ForEach(Availability.allCases, id: \.self) { availability in
                        content(state: FooterAvatarState(
                            avatar: PreviewImages.Avatars.valerian.rawValue,
                            availability: availability
                        ))
                    }
                }
                .padding()
                let store = Store(
                    initialState: FooterAvatarState(
                        avatar: PreviewImages.Avatars.valerian.rawValue,
                        availability: .available
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
