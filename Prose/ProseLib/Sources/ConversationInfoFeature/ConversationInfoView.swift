//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppLocalization
import Assets
import ComposableArchitecture
import ProseUI
import SwiftUI

public struct ConversationInfoView: View {
  private let store: StoreOf<ConversationInfoReducer>

  public init(store: StoreOf<ConversationInfoReducer>) {
    self.store = store
  }

  public var body: some View {
    ScrollView(.vertical) {
      VStack(spacing: 24) {
        VStack(spacing: 12) {
          self.identitySection
          self.quickActionsSection
        }
        .padding(.horizontal)

        self.informationSection
        self.securitySection
        self.actionsSection
      }
      .padding(.vertical)
    }
    .groupBoxStyle(SectionGroupStyle())
    .background(.background)
  }

  var identitySection: some View {
    WithViewStore(self.store.scope(state: \.identity)) { viewStore in
      VStack(alignment: .center, spacing: 10) {
        Avatar(viewStore.avatar, size: 100)
          .cornerRadius(10.0)
          .shadow(color: .black.opacity(0.08), radius: 4, y: 2)

        VStack(spacing: 4) {
          ContentCommonNameStatusComponent(
            name: viewStore.fullName,
            status: viewStore.status
          )

          Text("\(viewStore.jobTitle) at \(viewStore.company)")
            .font(.system(size: 11.5))
            .foregroundColor(Colors.Text.secondary.color)
        }
      }
    }
  }

  var quickActionsSection: some View {
    WithViewStore(self.store.stateless) { viewStore in
      HStack(spacing: 24) {
        Button { viewStore.send(.startCallButtonTapped) } label: {
          Label("phone", systemImage: "phone")
        }
        Button { viewStore.send(.sendEmailButtonTapped) } label: {
          Label("email", systemImage: "envelope")
        }
      }
      .buttonStyle(SubtitledActionButtonStyle())
    }
  }

  var informationSection: some View {
    WithViewStore(self.store.scope(state: \.information)) { viewStore in
      GroupBox(L10n.Content.MessageDetails.Information.title) {
        Label(viewStore.emailAddress, systemImage: "envelope.fill")
        Label(viewStore.phoneNumber, systemImage: "iphone")
        Label {
          // TODO: Localize
          Text(
            "Active \(viewStore.lastSeenDate, format: .relative(presentation: .numeric, unitsStyle: .wide))"
          )
        } icon: {
          Image(systemName: "hand.wave.fill")
            .unredacted()
        }
        Label(viewStore.localDateString, systemImage: "clock.fill")
        Label(viewStore.location, systemImage: "location.fill")
        Label {
          Text("“\(viewStore.statusMessage)”")
            .foregroundColor(Colors.Text.secondary.color)
        } icon: {
          Text(String(viewStore.statusIcon))
        }
      }
    }
  }

  var securitySection: some View {
    WithViewStore(self.store) { viewStore in
      GroupBox(L10n.Content.MessageDetails.Security.title) {
        HStack(spacing: 8) {
          if viewStore.security.isIdentityVerified {
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
          .popover(unwrapping: viewStore.binding(\.$identityPopover)) { _ in
            IfLetStore(
              self.store.scope(
                state: \.identityPopover,
                action: ConversationInfoReducer.Action.identityPopover
              ),
              then: IdentityPopover.init(store:)
            )
          }
        }

        HStack(spacing: 8) {
          if let fingerprint = viewStore.security.encryptionFingerprint {
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
    WithViewStore(self.store.stateless) { viewStore in
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
