//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Assets
import IdentifiedCollections
import ProseUI
import SwiftUI

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
      header: "Current device",
      footer: """
      Your security key fingerprint is shown as a short hash, which you can use to compare with the one your contacts see on their end. **Both must match.**

      **You may roll it anytime.** This will not make your message history unreadable.
      """
    ) {
      HStack(spacing: 16) {
        HStack {
          ZStack {
            RoundedRectangle(cornerRadius: 2)
              .fill(Color.white)
            RoundedRectangle(cornerRadius: 2)
              .stroke(Color.primary.opacity(0.5))
          }
          .frame(width: 48, height: 64)
          VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
              Text(verbatim: "macOS")
                .font(.headline)
              Text(verbatim: "Prose 1.0.0")
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            Text(verbatim: "OMEMO v0.7.0")
              .font(.footnote)
              .foregroundColor(.blue)
          }
        }
        Divider()
        VStack(alignment: .leading, spacing: 8) {
          HStack {
            Text(verbatim: "Device name:")
              .bold()
            Text(verbatim: "Prose (MacBook Baptiste)")
          }
          HStack {
            Text(verbatim: "Device ID:")
              .bold()
            Text(verbatim: "120645")
          }
          HStack {
            Text(verbatim: "Security hash:")
              .bold()
            Text(verbatim: "ERT65")
            Button {} label: {
              Text(verbatim: "Roll")
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
      header: "Other devices",
      footer: """
      Removing a device will not sign out from account. It prevents all messages sent to you from being decrypted by this device, until you reconnect with this device.
      """
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
      TableColumn("") { (device: Device) in
        Toggle("Enabled?", isOn: Binding(
          get: { device.isEnabled },
          set: { self.devices[id: device.id]?.isEnabled = $0 }
        ))
        .labelsHidden()
      }
      .width(16)
      TableColumn(
        "Device Name",
        value: \Device.name,
        comparator: Self.deviceNameComparator
      ) { (device: Device) in
        Text(verbatim: device.name)
      }
      .width(ideal: 196)
      TableColumn(
        "Device ID",
        value: \Device.id,
        comparator: Self.deviceIdComparator
      ) { (device: Device) in
        Text(verbatim: device.id)
      }
      .width(min: 48, ideal: 64, max: 128)
      TableColumn(
        "Security Hash",
        value: \Device.securityHash,
        comparator: Self.securityHashComparator
      ) { (device: Device) in
        HStack {
          Text(verbatim: device.securityHash)
            .frame(maxWidth: .infinity, alignment: .leading)
          Button {} label: {
            Image(systemName: "info.circle")
          }
          .buttonStyle(.link)
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
        TableFooterButton(systemImage: "gear", disclosureIndicator: true) {}
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
