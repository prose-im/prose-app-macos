//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Assets
import SwiftUI

struct IdentityView: View {
  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      VStack(spacing: 24) {
        ContentSection(
          header: "Name",
          footer: """
          In order to show a verified badge on your profile, visible to other users, you should get your real identity verified (first name & last name). The process takes a few seconds: you will be asked to submit a government ID (ID card, passport or driving license). **Note that the verified status is optional.**

          Your data will be processed on an external service. This service does not keep any record of your ID after your verified status is confirmed.
          """
        ) {
          VStack(alignment: .leading) {
            ThreeColumns {
              Text("First name:")
            } column2: {
              TextField(text: .constant("Baptiste"), label: { Text("Label") })
                .textFieldStyle(.roundedBorder)
                .controlSize(.large)
            } column3: {
              Button {} label: {
                Text("Get verified")
              }
              .buttonStyle(.link)
            }
            ThreeColumns {
              Text("Last name:")
            } column2: {
              TextField(text: .constant("Jamin"), label: { Text("Label") })
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
          header: "Contact information",
          footer: """
          **Your email address and phone number are public.** They are visible to all team members and contacts. They will not be available to other users.

          It is recommended that your email address and phone number each get verified, as it increases the level of trust of your profile. The process only takes a few seconds: you will receive a link to verify your contact details.
          """
        ) {
          VStack(alignment: .leading) {
            ThreeColumns {
              Text("Email:")
            } column2: {
              TextField(text: .constant("baptiste@crisp.chat"), label: { Text("Label") })
                .textFieldStyle(.roundedBorder)
                .controlSize(.large)
            } column3: {
              HStack(spacing: 4) {
                Image(systemName: "checkmark.seal.fill")
                Text("Verified")
              }
              .foregroundColor(Colors.State.green.color)
            }
            ThreeColumns {
              Text("Phone:")
            } column2: {
              TextField(text: .constant("+33631893345"), label: { Text("Label") })
                .textFieldStyle(.roundedBorder)
                .controlSize(.large)
            } column3: {
              Button {} label: {
                Text("Get verified")
              }
              .buttonStyle(.link)
            }
          }
          .padding(.horizontal)
        }
      }
      .padding(.vertical, 24)
    }
  }
}

struct IdentityView_Previews: PreviewProvider {
  static var previews: some View {
    IdentityView()
      .frame(width: 480, height: 512)
  }
}
