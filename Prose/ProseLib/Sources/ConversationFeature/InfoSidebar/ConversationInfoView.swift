//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import AppLocalization
import Assets
import ComposableArchitecture
import ProseUI
import SwiftUI

struct ConversationInfoView: View {
  struct ViewState: Equatable {
    var name: String
    var avatar: URL?
    var availability: Availability
    var status: String?
    var org: String?
    var title: String?
    var email: String?
    var tel: String?
    var location: String?
    var isIdentityVerified: Bool
    var encryptionFingerprint: String?

    var hasUserInfo: Bool {
      self.tel != nil || self.email != nil || self.location != nil || self.status != nil
    }
  }

  private let store: StoreOf<ConversationInfoReducer>
  @ObservedObject var viewStore: ViewStore<ViewState, ConversationInfoReducer.Action>

  init(store: StoreOf<ConversationInfoReducer>) {
    self.store = store
    self.viewStore = ViewStore(store.scope(state: ViewState.init))
  }

  var body: some View {
    ScrollView(.vertical) {
      VStack(spacing: 24) {
        VStack(spacing: 12) {
          self.identitySection
          self.quickActionsSection
        }
        .padding(.horizontal)

        if self.viewStore.hasUserInfo {
          self.informationSection
        }

        self.securitySection
        self.actionsSection
      }
      .padding(.vertical)
    }
    .groupBoxStyle(SectionGroupStyle())
    .background(.background)
    .onAppear { self.viewStore.send(.onAppear) }
    .onDisappear { self.viewStore.send(.onDisappear) }
  }

  var identitySection: some View {
    VStack(alignment: .center, spacing: 10) {
      Avatar(.init(url: self.viewStore.avatar), size: 100)
        .cornerRadius(10.0)
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)

      VStack(spacing: 4) {
        ContentCommonNameStatusComponent(
          name: viewStore.name,
          status: viewStore.availability
        )

        Group {
          if let title = self.viewStore.title {
            Text(verbatim: title)
          }
          if let org = self.viewStore.org {
            Text(verbatim: org)
          }
        }
        .font(.system(size: 11.5))
        .foregroundColor(Colors.Text.secondary.color)
      }
    }
  }

  var quickActionsSection: some View {
    HStack(spacing: 24) {
      if self.viewStore.tel != nil {
        Button { viewStore.send(.startCallButtonTapped) } label: {
          Label("phone", systemImage: "phone")
        }
      }
      if self.viewStore.email != nil {
        Button { viewStore.send(.sendEmailButtonTapped) } label: {
          Label("email", systemImage: "envelope")
        }
      }
    }
    .buttonStyle(SubtitledActionButtonStyle())
  }

  var informationSection: some View {
    GroupBox(L10n.Content.MessageDetails.Information.title) {
      if let email = self.viewStore.email {
        Label(email, systemImage: "envelope.fill")
      }
      if let tel = self.viewStore.tel {
        Label(tel, systemImage: "iphone")
      }
//      Label {
//        Text("Active \(viewStore.lastSeenDate, format: .relative(presentation: .numeric, unitsStyle: .wide))")
//      } icon: {
//        Image(systemName: "hand.wave.fill")
//          .unredacted()
//      }
//      Label(viewStore.localDateString, systemImage: "clock.fill")
      if let location = self.viewStore.location {
        Label(location, systemImage: "location.fill")
      }
      if let status = self.viewStore.status {
        Text(verbatim: status)
      }
    }
  }

  var securitySection: some View {
    GroupBox(L10n.Content.MessageDetails.Security.title) {
      HStack(spacing: 8) {
        if viewStore.isIdentityVerified {
          Label {
            Text("Identity verified")
          } icon: {
            Image(systemName: "checkmark.seal.fill")
              .foregroundColor(Colors.State.green.color)
          }
        } else {
          Label {
            Text("Identity not verified")
          } icon: {
            Image(systemName: "xmark.seal.fill")
              .foregroundColor(.orange)
          }
        }

        Button(action: { viewStore.send(.showIdVerificationInfoTapped) }) {
          Image(systemName: "info.circle")
            .foregroundColor(Color.primary.opacity(0.50))
        }
        .buttonStyle(.plain)
//          .popover(unwrapping: viewStore.binding(\.$identityPopover)) { _ in
//            IfLetStore(
//              self.store.scope(
//                state: \.identityPopover,
//                action: ConversationInfoReducer.Action.identityPopover
//              ),
//              then: IdentityPopover.init(store:)
//            )
//          }
      }

      HStack(spacing: 8) {
        if let fingerprint = viewStore.encryptionFingerprint {
          Label {
            Text("Encrypted (\(fingerprint))")
          } icon: {
            Image(systemName: "lock.fill")
              .foregroundColor(.blue)
          }
        } else {
          Label {
            Text("Not encrypted")
          } icon: {
            Image(systemName: "lock.slash")
              .foregroundColor(.red)
          }
        }
        Button(action: { viewStore.send(.showEncryptionInfoTapped) }) {
          Image(systemName: "info.circle")
            .foregroundColor(Color.primary.opacity(0.50))
        }
        .buttonStyle(.plain)
      }
    }
  }

  var actionsSection: some View {
    GroupBox(L10n.Content.MessageDetails.Actions.title) {
      ActionRow(
        name: L10n.Content.MessageDetails.Actions.sharedFiles,
        deployTo: true,
        action: { viewStore.send(.viewSharedFilesTapped) }
      )
      ActionRow(
        name: L10n.Content.MessageDetails.Actions.encryptionSettings,
        deployTo: true,
        action: { viewStore.send(.encryptionSettingsTapped) }
      )
      ActionRow(
        name: L10n.Content.MessageDetails.Actions.removeContact,
        action: { viewStore.send(.removeContactTapped) }
      )
      ActionRow(
        name: L10n.Content.MessageDetails.Actions.block,
        action: { viewStore.send(.blockContactTapped) }
      )
    }
  }
}

private struct SectionGroupStyle: GroupBoxStyle {
  private static let sidesPadding: CGFloat = 15

  func makeBody(configuration: Configuration) -> some View {
    VStack(spacing: 8) {
      VStack(alignment: .leading, spacing: 2) {
        configuration.label
          .font(.system(size: 11, weight: .semibold))
          .foregroundColor(Color.primary.opacity(0.25))
          .padding(.horizontal, Self.sidesPadding)
          .unredacted()

        Divider()
      }

      configuration.content
        .font(.system(size: 13))
        .labelStyle(EntryRowLabelStyle())
        .padding(.horizontal, Self.sidesPadding)
    }
  }
}

extension ConversationInfoView.ViewState {
  init(state: ConversationInfoReducer.State) {
    self.availability = .unavailable
    self.name = state.chatId.rawValue

    if let contact = state.userInfos[state.chatId] {
      self.availability = contact.availability
      self.name = contact.name
      self.avatar = contact.avatar
      self.status = contact.status
    }

    if let profile = state.userProfile {
      self.org = profile.org
      self.title = profile.title
      self.email = profile.email
      self.tel = profile.tel
      self.location = profile.address.flatMap { address in
        var components = [String]()
        if let locality = address.locality {
          components.append(locality)
        }
        if let country = address.country {
          components.append(country)
        }
        return components.isEmpty ? nil : components.joined(separator: ", ")
      }
    }

    self.isIdentityVerified = false
  }
}
