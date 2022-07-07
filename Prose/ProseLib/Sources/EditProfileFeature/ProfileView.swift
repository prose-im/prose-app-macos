//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Assets
import ProseUI
import SwiftUI

struct ProfileView: View {
  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      VStack(spacing: 24) {
        ContentSection(
          header: "Job information",
          footer: """
          Your current organization and job title are shared with your team members and contacts to identify your position within your company.
          """
        ) {
          VStack(alignment: .leading) {
            ThreeColumns {
              Text("Organization:")
            } column2: {
              TextField(text: .constant("Crisp"), label: { Text("Label") })
                .textFieldStyle(.roundedBorder)
                .controlSize(.large)
            } column3: {
              EmptyView()
            }
            ThreeColumns {
              Text("Title:")
            } column2: {
              TextField(text: .constant("CEO"), label: { Text("Label") })
                .textFieldStyle(.roundedBorder)
                .controlSize(.large)
            } column3: {
              EmptyView()
            }
          }
          .padding(.horizontal)
        }
        Divider()
          .padding(.horizontal)
        ContentSection(
          header: "Current location",
          footer: """
          You can opt-in to automatic location updates based on your last used device location. It is handy if you travel a lot, and would like this to be auto-managed. Your current city and country will be shared, not your exact GPS location.

          **Note that geolocation permissions are required for automatic mode.**
          """
        ) {
          VStack(alignment: .leading) {
            ThreeColumns {
              Text("Auto-detect:")
            } column2: {
              Toggle(isOn: .constant(true), label: { Text("Label") })
                .toggleStyle(.switch)
                .labelsHidden()
            } column3: {
              EmptyView()
            }
            ThreeColumns {
              Text("Location:")
            } column2: {
              TextField(text: .constant("Nantes, France"), label: { Text("Label") })
                .textFieldStyle(.roundedBorder)
                .controlSize(.large)
                .disabled(true)
            } column3: {
              EmptyView()
            }
            HStack {
              Text(verbatim: "Status:")
                .bold()
              HStack(spacing: 4) {
                Image(systemName: "location.fill")
                  .foregroundColor(.blue)
                Text(verbatim: "Automatic")
              }
            }
            HStack {
              Text(verbatim: "Geolocation permission:")
                .bold()
              Text(verbatim: "Allowed")
              Button {} label: {
                Text(verbatim: "Manage")
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
