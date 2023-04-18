//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppLocalization
import SwiftUI

private let l10n = L10n.Settings.Accounts.self

struct AccountSettingsAccountView: View {
  @AppStorage("settings.accounts.x.account.enabled") var enabled = true
  @AppStorage("settings.accounts.x.account.username") var username = ""
  @State var password = ""

  var body: some View {
    VStack(spacing: 24) {
      GroupBox(l10n.enabledLabel) {
        Toggle("", isOn: self.$enabled)
          .toggleStyle(.switch)
          .labelsHidden()
          .disabled(true)
      }

      GroupBox(l10n.statusLabel) {
        HStack(spacing: 4) {
          ConnectionStatusIndicator(status: .connected)
          Text(l10n.statusConnected)
            .font(.system(size: 13))
            .fontWeight(.semibold)
        }
      }

      VStack {
        GroupBox(l10n.addressLabel) {
          TextField("", text: self.$username, prompt: Text(l10n.addressPlaceholder))
            .textContentType(.username)
            .disableAutocorrection(true)
        }

        GroupBox(l10n.passwordLabel) {
          SecureField("", text: self.$password, prompt: Text(l10n.passwordPlaceholder))
            .textContentType(.password)
        }
      }

      Spacer()
    }
    .groupBoxStyle(FormGroupBoxStyle(
      firstColumnWidth: SettingsConstants
        .firstFormColumnConstrainedWidth
    ))
    .padding()
  }
}

struct AccountSettingsAccountView_Previews: PreviewProvider {
  static var previews: some View {
    AccountSettingsAccountView()
  }
}
