//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppLocalization
import ComposableArchitecture

public struct ProfileReducer: ReducerProtocol {
  public struct State: Equatable {
    @BindingState var organization: String
    @BindingState var jobTitle: String
    @BindingState var autoDetectLocation: Bool
    @BindingState var location: String
    @BindingState var isLocationPermissionAllowed: Bool

    var locationPermissionLabel: String {
      self.isLocationPermissionAllowed
        ? L10n.EditProfile.Profile.LocationPermission.StateAllowed.label
        : L10n.EditProfile.Profile.LocationPermission.StateDenied.label
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

  public enum Action: Equatable, BindableAction {
    case manageLocationPermissionTapped
    case binding(BindingAction<State>)
  }

  public init() {}

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    self.core
  }

  @ReducerBuilder<State, Action>
  private var core: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .manageLocationPermissionTapped:
        state.isLocationPermissionAllowed.toggle()
        return .none

      case .binding:
        return .none
      }
    }
  }
}
