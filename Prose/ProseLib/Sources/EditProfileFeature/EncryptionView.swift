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

private let appVersion: String = "Prose 1.0.0"
private let omemoVersion: String = "OMEMO v0.7.0"

struct EncryptionView: View {
  struct Device: Equatable, Identifiable {
    let id: String
    let name: String
    let securityHash: String
    var isEnabled: Bool
  }

  static let deviceNameComparator = String
    .Comparator(options: [.caseInsensitive, .diacriticInsensitive, .numeric])
  static let deviceIdComparator = String.Comparator(options: [.numeric])
  static let securityHashComparator = String.Comparator(.lexical)

  @Environment(\EnvironmentValues.font) private var font: Font?

  let deviceName: String = "Prose (MacBook Baptiste)"
  let deviceId: String = "120645"
  @State var deviceSecurityHash: String = "ERT65"

  @State var devices: IdentifiedArrayOf<Device> = [
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
  ]
  @State var sortOrder: [KeyPathComparator<EncryptionView.Device>] = [
    KeyPathComparator(\Device.name, comparator: Self.deviceNameComparator, order: .reverse),
  ]
  @State private var selectedDevice: Device.ID?

  var sortedDevices: [Device] {
    self.devices.sorted(using: self.sortOrder)
  }

  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      VStack(spacing: 24) {
        self.currentDeviceView()
        Divider()
          .padding(.horizontal)
        self.otherDevicesView()
      }
      .padding(.vertical, 24)
    }
  }

  func currentDeviceView() -> some View {
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
              Text(verbatim: appVersion)
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            Text(verbatim: omemoVersion)
              .font(.footnote)
              .foregroundColor(.blue)
          }
        }
        Divider()
        VStack(alignment: .leading, spacing: 8) {
          SecondaryRow(l10n.CurrentDeviceName.Header.label) {
            Text(verbatim: self.deviceName)
          }
          SecondaryRow(l10n.CurrentDeviceId.Header.label) {
            Text(verbatim: self.deviceId)
              .font(.body.monospaced())
          }
          SecondaryRow(l10n.CurrentDeviceSecurityHash.Header.label) {
            Text(verbatim: self.deviceSecurityHash)
              .font(.body.monospaced())
            Button(l10n.RollSecurityHashAction.label) {
              self.deviceSecurityHash = String(UUID().uuidString.prefix(5))
            }
            .controlSize(.small)
          }
        }
      }
      .padding(.horizontal)
    }
  }

  func otherDevicesView() -> some View {
    ContentSection(
      header: l10n.OtherDevicesSection.Header.label,
      footer: l10n.OtherDevicesSection.Footer.label
    ) {
      VStack(spacing: 0) {
        Divider()
        self.table()
          .safeAreaInset(edge: .bottom, spacing: 0, content: self.tableFooter)
        Divider()
      }
      .frame(height: 196)
    }
  }

  func table() -> some View {
    Table<Device, _, _>(
      self.sortedDevices,
      selection: self.$selectedDevice,
      sortOrder: self.$sortOrder
    ) {
      TableColumn(String("")) { (device: Device) in
        Toggle(l10n.DeviceEnabled.Toggle.label, isOn: Binding(
          get: { device.isEnabled },
          set: { self.devices[id: device.id]?.isEnabled = $0 }
        ))
        .labelsHidden()
      }
      .width(16)
      TableColumn(
        l10n.DeviceName.Column.label,
        value: \Device.name,
        comparator: Self.deviceNameComparator
      ) { (device: Device) in
        Text(verbatim: device.name)
      }
      .width(ideal: 196)
      TableColumn(
        l10n.DeviceId.Column.label,
        value: \Device.id,
        comparator: Self.deviceIdComparator
      ) { (device: Device) in
        Text(verbatim: device.id)
          .font(.body.monospaced())
      }
      .width(min: 48, ideal: 64, max: 128)
      TableColumn(
        l10n.DeviceSecurityHash.Column.label,
        value: \Device.securityHash,
        comparator: Self.securityHashComparator
      ) { (device: Device) in
        HStack {
          Text(verbatim: device.securityHash)
            .font(.body.monospaced())
            .frame(maxWidth: .infinity, alignment: .leading)
          Button {
            logger.trace("Device \(device.id) info tapped")
          } label: {
            Image(systemName: "info.circle")
          }
          .buttonStyle(.plain)
          .foregroundColor(.blue)
        }
      }
      .width(min: 80, ideal: 96, max: 128)
    }
  }

  func tableFooter() -> some View {
    VStack(spacing: 0) {
      Divider()
      HStack(spacing: 0) {
        TableFooterButton(systemImage: "minus") {
          if let selection = self.selectedDevice {
            self.devices.remove(id: selection)
            self.selectedDevice = nil
          }
        }
        Spacer()
        TableFooterButton(systemImage: "gear", disclosureIndicator: true) {
          logger.trace("Devices settings tapped")
        }
      }
    }
    .frame(height: 22)
    .background(Material.thick)
  }
}

struct EncryptionView_Previews: PreviewProvider {
  static var previews: some View {
    EncryptionView()
      .frame(width: 480, height: 544)
  }
}
