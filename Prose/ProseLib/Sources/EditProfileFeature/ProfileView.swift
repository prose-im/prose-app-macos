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
  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      VStack(spacing: 24) {
        ContentSection(
          header: l10n.JobSection.Header.label,
          footer: l10n.JobSection.Footer.label
        ) {
          VStack(alignment: .leading) {
            ThreeColumns(l10n.Organization.Header.label) {
              TextField(l10n.Organization.TextField.label, text: .constant("Crisp"))
                .textFieldStyle(.roundedBorder)
                .controlSize(.large)
            }
            ThreeColumns(l10n.JobTitle.Header.label) {
              TextField(l10n.JobTitle.TextField.label, text: .constant("CEO"))
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
              Toggle(l10n.AutoDetectLocation.Toggle.label, isOn: .constant(true))
                .toggleStyle(.switch)
                .labelsHidden()
            }
            ThreeColumns(l10n.Location.Header.label) {
              TextField(l10n.Location.TextField.label, text: .constant("Nantes, France"))
                .textFieldStyle(.roundedBorder)
                .controlSize(.large)
                .disabled(true)
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
              Text(verbatim: l10n.LocationPermission.StateAllowed.label)
//              Text(verbatim: l10n.LocationPermission.StateDenied.label)
              Button(l10n.LocationPermission.ManageAction.label) {}
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
