//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import Assets
import ProseUI
import SwiftUI

private let l10n = L10n.EditProfile.Profile.self

struct ProfileView: View {
  @State var organization: String = "Crisp"
  @State var jobTitle: String = "CEO"
  @State var autoDetectLocation: Bool = true
  @State var location: String = "Nantes, France"
  @State var isLocationPermissionAllowed: Bool = true

  var locationPermissionLabel: String {
    self.isLocationPermissionAllowed
      ? l10n.LocationPermission.StateAllowed.label
      : l10n.LocationPermission.StateDenied.label
  }

  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      VStack(spacing: 24) {
        ContentSection(
          header: l10n.JobSection.Header.label,
          footer: l10n.JobSection.Footer.label
        ) {
          VStack(alignment: .leading) {
            ThreeColumns(l10n.Organization.Header.label) {
              TextField(l10n.Organization.TextField.label, text: self.$organization)
                .textFieldStyle(.roundedBorder)
                .controlSize(.large)
            }
            ThreeColumns(l10n.JobTitle.Header.label) {
              TextField(l10n.JobTitle.TextField.label, text: self.$jobTitle)
                .textFieldStyle(.roundedBorder)
                .controlSize(.large)
            }
          }
          .padding(.horizontal)
        }
        Divider()
          .padding(.horizontal)
        ContentSection(
          header: l10n.LocationSection.Header.label,
          footer: l10n.LocationSection.Footer.label
        ) {
          VStack(alignment: .leading) {
            ThreeColumns(l10n.AutoDetectLocation.Header.label) {
              Toggle(l10n.AutoDetectLocation.Toggle.label, isOn: self.$autoDetectLocation)
                .toggleStyle(.switch)
                .labelsHidden()
            }
            ThreeColumns(l10n.Location.Header.label) {
              TextField(l10n.Location.TextField.label, text: self.$location)
                .textFieldStyle(.roundedBorder)
                .controlSize(.large)
                .disabled(self.autoDetectLocation)
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
              Text(verbatim: self.locationPermissionLabel)
              Button(l10n.LocationPermission.ManageAction.label) {
                self.isLocationPermissionAllowed.toggle()
              }
              .controlSize(.small)
            }
          }
          .padding(.horizontal)
        }
      }
      .padding(.vertical, 24)
    }
  }
}

struct ProfileView_Previews: PreviewProvider {
  static var previews: some View {
    ProfileView()
      .frame(width: 480, height: 512)
  }
}
