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

// MARK: - View

struct ProfileView: View {
  typealias ViewState = ProfileState
  typealias ViewAction = ProfileAction

  let store: Store<ViewState, ViewAction>

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

  static func jobSection(viewStore: ViewStore<ViewState, ViewAction>) -> some View {
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

  static func locationSection(viewStore: ViewStore<ViewState, ViewAction>) -> some View {
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

// MARK: - The Composable Architecture

// MARK: Reducer

public let profileReducer = Reducer<
  ProfileState,
  ProfileAction,
  Void
> { state, action, _ in
  switch action {
  case .manageLocationPermissionTapped:
    state.isLocationPermissionAllowed.toggle()
    return .none

  case .binding:
    return .none
  }
}.binding()

// MARK: State

public struct ProfileState: Equatable {
  @BindableState var organization: String
  @BindableState var jobTitle: String
  @BindableState var autoDetectLocation: Bool
  @BindableState var location: String
  @BindableState var isLocationPermissionAllowed: Bool

  var locationPermissionLabel: String {
    self.isLocationPermissionAllowed
      ? l10n.LocationPermission.StateAllowed.label
      : l10n.LocationPermission.StateDenied.label
  }

  public init(
    organization: String = "Crisp",
    jobTitle: String = "CEO",
    autoDetectLocation: Bool = true,
    location: String = "Nantes, France",
    isLocationPermissionAllowed: Bool = true
  ) {
    self.organization = organization
    self.jobTitle = jobTitle
    self.autoDetectLocation = autoDetectLocation
    self.location = location
    self.isLocationPermissionAllowed = isLocationPermissionAllowed
  }
}

// MARK: Actions

public enum ProfileAction: Equatable, BindableAction {
  case manageLocationPermissionTapped
  case binding(BindingAction<ProfileState>)
}

// MARK: - Previews

struct ProfileView_Previews: PreviewProvider {
  static var previews: some View {
    ProfileView(store: Store(
      initialState: ProfileState(),
      reducer: profileReducer,
      environment: ()
    ))
    .frame(width: 480, height: 512)
  }
}
