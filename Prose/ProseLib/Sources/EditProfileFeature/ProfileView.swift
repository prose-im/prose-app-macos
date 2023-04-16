//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import Assets
import ComposableArchitecture
import ProseUI
import SwiftUI

private let l10n = L10n.EditProfile.Profile.self

struct ProfileView: View {
  let store: StoreOf<ProfileReducer>

  var body: some View {
    WithViewStore(self.store) { viewStore in
      ScrollView(.vertical, showsIndicators: false) {
        VStack(spacing: 24) {
          Self.jobSection(viewStore: viewStore)
          Divider()
            .padding(.horizontal)
          Self.locationSection(viewStore: viewStore)
        }
        .padding(.vertical, 24)
      }
    }
  }

  static func jobSection(viewStore: ViewStoreOf<ProfileReducer>) -> some View {
    ContentSection(
      header: l10n.JobSection.Header.label,
      footer: l10n.JobSection.Footer.label
    ) {
      VStack(alignment: .leading) {
        ThreeColumns(l10n.Organization.Header.label) {
          TextField(l10n.Organization.TextField.label, text: viewStore.binding(\.$organization))
            .textFieldStyle(.roundedBorder)
            .controlSize(.large)
        }
        ThreeColumns(l10n.JobTitle.Header.label) {
          TextField(l10n.JobTitle.TextField.label, text: viewStore.binding(\.$jobTitle))
            .textFieldStyle(.roundedBorder)
            .controlSize(.large)
        }
      }
      .padding(.horizontal)
    }
  }

  static func locationSection(viewStore: ViewStoreOf<ProfileReducer>) -> some View {
    ContentSection(
      header: l10n.LocationSection.Header.label,
      footer: l10n.LocationSection.Footer.label
    ) {
      VStack(alignment: .leading) {
        ThreeColumns(l10n.AutoDetectLocation.Header.label) {
          Toggle(
            l10n.AutoDetectLocation.Toggle.label,
            isOn: viewStore.binding(\.$autoDetectLocation)
          )
          .toggleStyle(.switch)
          .labelsHidden()
        }
        ThreeColumns(l10n.Location.Header.label) {
          TextField(l10n.Location.TextField.label, text: viewStore.binding(\.$location))
            .textFieldStyle(.roundedBorder)
            .controlSize(.large)
            .disabled(viewStore.autoDetectLocation)
        }
        SecondaryRow(l10n.LocationStatus.Header.label) {
          HStack(spacing: 4) {
            Image(systemName: "location.fill")
              .foregroundColor(.blue)
              .accessibilityHidden(true)
            Text(verbatim: l10n.LocationStatus.StateAuto.label)
          }
          .accessibilityElement(children: .combine)
        }
        SecondaryRow(l10n.LocationPermission.Header.label) {
          Text(verbatim: viewStore.locationPermissionLabel)
          Button(l10n.LocationPermission.ManageAction.label) {
            viewStore.send(.manageLocationPermissionTapped)
          }
          .controlSize(.small)
        }
      }
      .padding(.horizontal)
    }
  }
}
