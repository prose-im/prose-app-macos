//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import Assets
import IdentifiedCollections
import ProseUI
import SwiftUI

private let l10n = L10n.EditProfile.Encryption.self

#if os(macOS)
  private let platform: String = "macOS"
#else
  #error("OS not supported, add a case")
#endif

struct EncryptionView: View {
  typealias ViewState = EncryptionState
  typealias ViewAction = EncryptionAction

  @Environment(\EnvironmentValues.font) private var font: Font?

  let store: Store<ViewState, ViewAction>

  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      WithViewStore(self.store) { viewStore in
        VStack(spacing: 24) {
          self.currentDeviceView(viewStore: viewStore)
          Divider()
            .padding(.horizontal)
          self.otherDevicesView(viewStore: viewStore)
        }
        .padding(.vertical, 24)
      }
    }
  }

  func currentDeviceView(viewStore: ViewStore<ViewState, ViewAction>) -> some View {
    ContentSection(
      header: l10n.CurrentDeviceSection.Header.label,
      footer: l10n.CurrentDeviceSection.Footer.label
    ) {
      HStack(spacing: 16) {
        HStack {
          Image(nsImage: Images.platformLogo.image)
            .resizable()
            .frame(width: 48, height: 64)
            .accessibilityHidden(true)
          VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
              Text(verbatim: platform)
                .font(.headline)
              Text(verbatim: viewStore.appVersion)
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            Text(verbatim: viewStore.omemoVersion)
              .font(.footnote)
              .foregroundColor(.accentColor)
          }
        }
        Divider()
        VStack(alignment: .leading, spacing: 8) {
          SecondaryRow(l10n.CurrentDeviceName.Header.label) {
            Text(verbatim: viewStore.deviceName)
          }
          SecondaryRow(l10n.CurrentDeviceId.Header.label) {
            Text(verbatim: viewStore.deviceId)
              .font(.body.monospaced())
          }
          SecondaryRow(l10n.CurrentDeviceSecurityHash.Header.label) {
            Text(verbatim: viewStore.deviceSecurityHash)
              .font(.body.monospaced())
            Button(l10n.RollSecurityHashAction.label) {
              viewStore.send(.rollSecurityHashTapped)
            }
            .controlSize(.small)
          }
        }
      }
      .padding(.horizontal)
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  func otherDevicesView(viewStore: ViewStore<ViewState, ViewAction>) -> some View {
    ContentSection(
      header: l10n.OtherDevicesSection.Header.label,
      footer: l10n.OtherDevicesSection.Footer.label
    ) {
      VStack(spacing: 0) {
        Divider()
        self.table(viewStore: viewStore)
          .safeAreaInset(edge: .bottom, spacing: 0) { self.tableFooter(viewStore: viewStore) }
        Divider()
      }
      .frame(height: 196)
    }
  }

  func table(viewStore: ViewStore<ViewState, ViewAction>) -> some View {
    Table<ViewState.Device, _, _>(
      viewStore.sortedDevices,
      selection: viewStore.binding(\.$selectedDevice),
      sortOrder: viewStore.binding(\.$sortOrder)
    ) {
      TableColumn(String("")) { (device: ViewState.Device) in
        Toggle(l10n.DeviceEnabled.Toggle.label, isOn: Binding(
          get: { device.isEnabled },
          set: { viewStore.send(.setEnabled(device.id, $0)) }
        ))
        .labelsHidden()
      }
      .width(16)
      TableColumn(
        l10n.DeviceName.Column.label,
        value: \.name,
        comparator: ViewState.deviceNameComparator
      ) { (device: ViewState.Device) in
        Text(verbatim: device.name)
      }
      .width(ideal: 196)
      TableColumn(
        l10n.DeviceId.Column.label,
        value: \.id,
        comparator: ViewState.deviceIdComparator
      ) { (device: ViewState.Device) in
        Text(verbatim: device.id)
          .font(.body.monospaced())
      }
      .width(min: 48, ideal: 64, max: 128)
      TableColumn(
        l10n.DeviceSecurityHash.Column.label,
        value: \.securityHash,
        comparator: ViewState.securityHashComparator
      ) { (device: ViewState.Device) in
        HStack {
          Text(verbatim: device.securityHash)
            .font(.body.monospaced())
            .frame(maxWidth: .infinity, alignment: .leading)
          Button { viewStore.send(.deviceInfoTapped(device.id)) } label: {
            Image(systemName: "info.circle")
          }
          .buttonStyle(.plain)
          .foregroundColor(.accentColor)
        }
      }
      .width(min: 80, ideal: 96, max: 128)
    }
  }

  func tableFooter(viewStore: ViewStore<ViewState, ViewAction>) -> some View {
    VStack(spacing: 0) {
      Divider()
      HStack(spacing: 0) {
        TableFooterButton(systemImage: "minus") {
          viewStore.send(.removeDeviceTapped)
        }
        Spacer()
        TableFooterButton(systemImage: "gear", disclosureIndicator: true) {
          viewStore.send(.devicesSettingsTapped)
        }
      }
    }
    .frame(height: 22)
    .background(Material.thick)
  }
}

import ComposableArchitecture

// MARK: - View

// MARK: - The Composable Architecture

// MARK: Reducer

public let encryptionReducer = AnyReducer<
  EncryptionState,
  EncryptionAction,
  Void
> { state, action, _ in
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
}.binding()

// MARK: State

public struct EncryptionState: Equatable {
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

  let appVersion: String = "Prose 1.0.0"
  let omemoVersion: String = "OMEMO v0.7.0"

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

// MARK: Actions

public enum EncryptionAction: Equatable, BindableAction {
  case rollSecurityHashTapped, removeDeviceTapped, devicesSettingsTapped
  case setEnabled(EncryptionState.Device.ID, Bool)
  case deviceInfoTapped(EncryptionState.Device.ID)
  case binding(BindingAction<EncryptionState>)
}

// MARK: - Previews

struct EncryptionView_Previews: PreviewProvider {
  static var previews: some View {
    EncryptionView(store: Store(
      initialState: EncryptionState(),
      reducer: encryptionReducer,
      environment: ()
    ))
    .frame(width: 480, height: 544)
  }
}
