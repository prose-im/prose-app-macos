//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import Assets
import ComposableArchitecture
import IdentifiedCollections
import ProseUI
import SwiftUI

private let l10n = L10n.EditProfile.Encryption.self

#if os(macOS)
  private let platform = "macOS"
#else
  #error("OS not supported, add a case")
#endif

struct EncryptionView: View {
  @Environment(\EnvironmentValues.font) private var font: Font?

  let store: StoreOf<EncryptionReducer>

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

  func currentDeviceView(viewStore: ViewStoreOf<EncryptionReducer>) -> some View {
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

  func otherDevicesView(viewStore: ViewStoreOf<EncryptionReducer>) -> some View {
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

  func table(viewStore: ViewStoreOf<EncryptionReducer>) -> some View {
    Table<EncryptionReducer.State.Device, _, _>(
      viewStore.sortedDevices,
      selection: viewStore.binding(\.$selectedDevice),
      sortOrder: viewStore.binding(\.$sortOrder)
    ) {
      TableColumn(String("")) { (device: EncryptionReducer.State.Device) in
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
        comparator: EncryptionReducer.State.deviceNameComparator
      ) { (device: EncryptionReducer.State.Device) in
        Text(verbatim: device.name)
      }
      .width(ideal: 196)
      TableColumn(
        l10n.DeviceId.Column.label,
        value: \.id,
        comparator: EncryptionReducer.State.deviceIdComparator
      ) { (device: EncryptionReducer.State.Device) in
        Text(verbatim: device.id)
          .font(.body.monospaced())
      }
      .width(min: 48, ideal: 64, max: 128)
      TableColumn(
        l10n.DeviceSecurityHash.Column.label,
        value: \.securityHash,
        comparator: EncryptionReducer.State.securityHashComparator
      ) { (device: EncryptionReducer.State.Device) in
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

  func tableFooter(viewStore: ViewStoreOf<EncryptionReducer>) -> some View {
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
