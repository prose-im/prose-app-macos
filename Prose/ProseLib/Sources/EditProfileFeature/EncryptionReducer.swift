//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import Foundation

public struct EncryptionReducer: ReducerProtocol {
  public struct State: Equatable {
    public struct Device: Equatable, Identifiable {
      public let id: String
      let name: String
      let securityHash: String
      var isEnabled: Bool

      public init(
        id: String,
        name: String,
        securityHash: String,
        isEnabled: Bool
      ) {
        self.id = id
        self.name = name
        self.securityHash = securityHash
        self.isEnabled = isEnabled
      }
    }

    static let deviceNameComparator = String
      .Comparator(options: [.caseInsensitive, .diacriticInsensitive, .numeric])
    static let deviceIdComparator = String.Comparator(options: [.numeric])
    static let securityHashComparator = String.Comparator(.lexical)

    let appVersion = "Prose 1.0.0"
    let omemoVersion = "OMEMO v0.7.0"

    let deviceName: String
    let deviceId: String

    @BindingState var deviceSecurityHash: String

    @BindingState var devices: IdentifiedArrayOf<Device>
    @BindingState var sortOrder: [KeyPathComparator<Device>]
    @BindingState var selectedDevice: Device.ID?

    var sortedDevices: [Device] {
      self.devices.sorted(using: self.sortOrder)
    }

    public init(
      deviceName: String = "Prose (MacBook Baptiste)",
      deviceId: String = "120645",
      deviceSecurityHash: String = "ERT65",
      devices: IdentifiedArrayOf<Device> = [
        Device(
          id: "938173",
          name: "Prose (iPhone Baptiste)",
          securityHash: "Z29QD",
          isEnabled: true
        ),
        Device(
          id: "163012",
          name: "Prose (iPad Baptiste)",
          securityHash: "OB21A",
          isEnabled: false
        ),
        Device(
          id: "129",
          name: "Gajim (Ubuntu VM)",
          securityHash: "AQW02",
          isEnabled: false
        ),
      ],
      sortOrder: [KeyPathComparator<Device>]? = nil
    ) {
      self.deviceName = deviceName
      self.deviceId = deviceId
      self.deviceSecurityHash = deviceSecurityHash
      self.devices = devices
      self.sortOrder = sortOrder ?? [
        KeyPathComparator(\Device.name, comparator: Self.deviceNameComparator, order: .reverse),
      ]
    }
  }

  public enum Action: Equatable, BindableAction {
    case rollSecurityHashTapped, removeDeviceTapped, devicesSettingsTapped
    case setEnabled(State.Device.ID, Bool)
    case deviceInfoTapped(State.Device.ID)
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
      case .rollSecurityHashTapped:
        state.deviceSecurityHash = String(UUID().uuidString.prefix(5))
        return .none

      case .removeDeviceTapped:
        if let selection = state.selectedDevice {
          state.devices.remove(id: selection)
          state.selectedDevice = nil
        }
        return .none

      case .devicesSettingsTapped:
        logger.trace("Devices settings tapped")
        return .none

      case let .deviceInfoTapped(deviceId):
        logger.trace("Device \(deviceId) info tapped")
        return .none

      case let .setEnabled(deviceId, isEnabled):
        state.devices[id: deviceId]?.isEnabled = isEnabled
        return .none

      case .binding:
        return .none
      }
    }
  }
}
