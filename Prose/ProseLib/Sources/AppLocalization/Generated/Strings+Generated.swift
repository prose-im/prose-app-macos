//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {
  public enum Authentication {
    public enum AccountErrorAlert {
      /// Prose failed connecting to your account, as the server reported an account error.
      ///
      /// This might mean that your credentials are invalid, or your account does not exist anymore on this server, or was blocked.
      public static let content = L10n.tr(
        "Localizable",
        "authentication.account_error_alert.content",
        fallback: #"Prose failed connecting to your account, as the server reported an account error.\n\nThis might mean that your credentials are invalid, or your account does not exist anymore on this server, or was blocked."#
      )
      /// Account Error
      public static let title = L10n.tr(
        "Localizable",
        "authentication.account_error_alert.title",
        fallback: #"Account Error"#
      )
      public enum GoToAccountSettingsAction {
        /// Account settings
        public static let title = L10n.tr(
          "Localizable",
          "authentication.account_error_alert.go_to_account_settings_action.title",
          fallback: #"Account settings"#
        )
      }

      public enum TryAgainAction {
        /// Try again
        public static let title = L10n.tr(
          "Localizable",
          "authentication.account_error_alert.try_again_action.title",
          fallback: #"Try again"#
        )
      }

      public enum WorkOfflineAction {
        /// Work offline
        public static let title = L10n.tr(
          "Localizable",
          "authentication.account_error_alert.work_offline_action.title",
          fallback: #"Work offline"#
        )
      }
    }

    public enum BasicAuth {
      public enum Alert {
        public enum BadCredentials {
          /// Bad credentials
          public static let title = L10n.tr(
            "Localizable",
            "authentication.basic_auth.alert.bad_credentials.title",
            fallback: #"Bad credentials"#
          )
        }
      }

      public enum Cancel {
        public enum Action {
          /// Cancel
          public static let title = L10n.tr(
            "Localizable",
            "authentication.basic_auth.cancel.action.title",
            fallback: #"Cancel"#
          )
        }
      }

      public enum ChatAddress {
        public enum Popover {
          /// A chat address is not an email address, but it is very likely
          /// the same as your professional email address.
          ///
          /// **It might be:** [your username]@[your company domain].
          public static let content = L10n.tr(
            "Localizable",
            "authentication.basic_auth.chat_address.popover.content",
            fallback: #"A chat address is not an email address, but it is very likely\nthe same as your professional email address.\n\n**It might be:** [your username]@[your company domain]."#
          )
          /// What is my chat address? (XMPP address)
          public static let title = L10n.tr(
            "Localizable",
            "authentication.basic_auth.chat_address.popover.title",
            fallback: #"What is my chat address? (XMPP address)"#
          )
        }
      }

      public enum Error {
        /// Login failure
        public static let title = L10n.tr(
          "Localizable",
          "authentication.basic_auth.error.title",
          fallback: #"Login failure"#
        )
      }

      public enum Form {
        public enum ChatAddress {
          /// Enter your chat address
          public static let placeholder = L10n.tr(
            "Localizable",
            "authentication.basic_auth.form.chat_address.placeholder",
            fallback: #"Enter your chat address"#
          )
        }

        public enum Password {
          /// Enter your password…
          public static let placeholder = L10n.tr(
            "Localizable",
            "authentication.basic_auth.form.password.placeholder",
            fallback: #"Enter your password…"#
          )
        }
      }

      public enum Header {
        /// Sign in to your chat account
        public static let subtitle = L10n.tr(
          "Localizable",
          "authentication.basic_auth.header.subtitle",
          fallback: #"Sign in to your chat account"#
        )
        /// Welcome!
        public static let title = L10n.tr(
          "Localizable",
          "authentication.basic_auth.header.title",
          fallback: #"Welcome!"#
        )
      }

      public enum LogIn {
        public enum Action {
          /// Log into your account
          public static let title = L10n.tr(
            "Localizable",
            "authentication.basic_auth.log_in.action.title",
            fallback: #"Log into your account"#
          )
        }
      }

      public enum NoAccount {
        public enum Action {
          /// No account yet?
          public static let title = L10n.tr(
            "Localizable",
            "authentication.basic_auth.no_account.action.title",
            fallback: #"No account yet?"#
          )
        }

        public enum Popover {
          /// Chat accounts are hosted on your organization chat server.
          /// If you are a server administrator, and you are not yet running
          /// a chat server, please [read this guide](https://prose.org). You will be able to
          /// invite all your team members afterwards.
          ///
          /// If you are a team member, ask for an administrator in your
          /// team to email you an invitation to create your chat account.
          public static let content = L10n.tr(
            "Localizable",
            "authentication.basic_auth.no_account.popover.content",
            fallback: #"Chat accounts are hosted on your organization chat server.\nIf you are a server administrator, and you are not yet running\na chat server, please [read this guide](https://prose.org). You will be able to\ninvite all your team members afterwards.\n\nIf you are a team member, ask for an administrator in your\nteam to email you an invitation to create your chat account."#
          )
          /// How do I create a new account? (XMPP address)
          public static let title = L10n.tr(
            "Localizable",
            "authentication.basic_auth.no_account.popover.title",
            fallback: #"How do I create a new account? (XMPP address)"#
          )
        }
      }

      public enum PasswordLost {
        public enum Action {
          /// Lost your password?
          public static let title = L10n.tr(
            "Localizable",
            "authentication.basic_auth.password_lost.action.title",
            fallback: #"Lost your password?"#
          )
        }

        public enum Popover {
          /// Please open this link to our website
          /// to [recover your password](https://prose.org).
          public static let content = L10n.tr(
            "Localizable",
            "authentication.basic_auth.password_lost.popover.content",
            fallback: #"Please open this link to our website\nto [recover your password](https://prose.org)."#
          )
          /// Lost your password?
          public static let title = L10n.tr(
            "Localizable",
            "authentication.basic_auth.password_lost.popover.title",
            fallback: #"Lost your password?"#
          )
        }
      }
    }

    public enum Mfa {
      public enum ConfirmButton {
        /// Confirm login code
        public static let title = L10n.tr(
          "Localizable",
          "authentication.mfa.confirm_button.title",
          fallback: #"Confirm login code"#
        )
      }

      public enum Error {
        /// Multi factor authentication failure
        public static let title = L10n.tr(
          "Localizable",
          "authentication.mfa.error.title",
          fallback: #"Multi factor authentication failure"#
        )
      }

      public enum Footer {
        public enum CannotGenerateCode {
          /// Not implemented yet.
          public static let content = L10n.tr(
            "Localizable",
            "authentication.mfa.footer.cannot_generate_code.content",
            fallback: #"Not implemented yet."#
          )
          /// Cannot generate code?
          public static let title = L10n.tr(
            "Localizable",
            "authentication.mfa.footer.cannot_generate_code.title",
            fallback: #"Cannot generate code?"#
          )
        }

        public enum NoAccount {
          /// No account yet?
          public static let title = L10n.tr(
            "Localizable",
            "authentication.mfa.footer.no_account.title",
            fallback: #"No account yet?"#
          )
        }
      }

      public enum Form {
        public enum OneTimeCode {
          /// One time code
          public static let placeholder = L10n.tr(
            "Localizable",
            "authentication.mfa.form.one_time_code.placeholder",
            fallback: #"One time code"#
          )
        }
      }

      public enum Header {
        /// Enter your 6-digit access code
        public static let subtitle = L10n.tr(
          "Localizable",
          "authentication.mfa.header.subtitle",
          fallback: #"Enter your 6-digit access code"#
        )
        /// One more step…
        public static let title = L10n.tr(
          "Localizable",
          "authentication.mfa.header.title",
          fallback: #"One more step…"#
        )
      }
    }
  }

  public enum Chat {
    public enum OfflineBanner {
      /// New messages will not appear, drafts will be saved for later.
      public static let content = L10n.tr(
        "Localizable",
        "chat.offline_banner.content",
        fallback: #"New messages will not appear, drafts will be saved for later."#
      )
      /// You are offline
      public static let title = L10n.tr(
        "Localizable",
        "chat.offline_banner.title",
        fallback: #"You are offline"#
      )
      public enum ReconnectAction {
        /// Reconnect now
        public static let title = L10n.tr(
          "Localizable",
          "chat.offline_banner.reconnect_action.title",
          fallback: #"Reconnect now"#
        )
      }
    }
  }

  public enum Content {
    public enum MessageBar {
      /// %s is typing…
      public static func composeTyping(_ p1: UnsafePointer<CChar>) -> String {
        L10n.tr(
          "Localizable",
          "content.message_bar.compose_typing",
          p1,
          fallback: #"%s is typing…"#
        )
      }

      /// Message %s
      public static func fieldPlaceholder(_ p1: UnsafePointer<CChar>) -> String {
        L10n.tr(
          "Localizable",
          "content.message_bar.field_placeholder",
          p1,
          fallback: #"Message %s"#
        )
      }
    }

    public enum MessageDetails {
      public enum Actions {
        /// Block contact
        public static let block = L10n.tr(
          "Localizable",
          "content.message_details.actions.block",
          fallback: #"Block contact"#
        )
        /// Encryption settings
        public static let encryptionSettings = L10n.tr(
          "Localizable",
          "content.message_details.actions.encryption_settings",
          fallback: #"Encryption settings"#
        )
        /// Remove from contacts
        public static let removeContact = L10n.tr(
          "Localizable",
          "content.message_details.actions.remove_contact",
          fallback: #"Remove from contacts"#
        )
        /// View shared files
        public static let sharedFiles = L10n.tr(
          "Localizable",
          "content.message_details.actions.shared_files",
          fallback: #"View shared files"#
        )
        /// Actions
        public static let title = L10n.tr(
          "Localizable",
          "content.message_details.actions.title",
          fallback: #"Actions"#
        )
      }

      public enum Information {
        /// Information
        public static let title = L10n.tr(
          "Localizable",
          "content.message_details.information.title",
          fallback: #"Information"#
        )
      }

      public enum Security {
        /// Encrypted (%s)
        public static func encrypted(_ p1: UnsafePointer<CChar>) -> String {
          L10n.tr(
            "Localizable",
            "content.message_details.security.encrypted",
            p1,
            fallback: #"Encrypted (%s)"#
          )
        }

        /// Identity verified
        public static let identityVerified = L10n.tr(
          "Localizable",
          "content.message_details.security.identity_verified",
          fallback: #"Identity verified"#
        )
        /// Security
        public static let title = L10n.tr(
          "Localizable",
          "content.message_details.security.title",
          fallback: #"Security"#
        )
      }
    }
  }

  public enum EditProfile {
    public enum Authentication {
      public enum MfaSection {
        public enum Footer {
          /// Multi-factor authentication adds an extra layer of security to your account, by asking for a temporary code generated by an app, upon login.
          ///
          /// In the event that you are unable to generate MFA tokens, you can still use your recovery phone number to login to your account.
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.authentication.mfa_section.footer.label",
            fallback: #"Multi-factor authentication adds an extra layer of security to your account, by asking for a temporary code generated by an app, upon login.\n\nIn the event that you are unable to generate MFA tokens, you can still use your recovery phone number to login to your account."#
          )
        }

        public enum Header {
          /// Multi-factor authentication
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.authentication.mfa_section.header.label",
            fallback: #"Multi-factor authentication"#
          )
        }
      }

      public enum MfaStatus {
        public enum Header {
          /// Status:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.authentication.mfa_status.header.label",
            fallback: #"Status:"#
          )
        }

        public enum StateDisabled {
          /// Disabled
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.authentication.mfa_status.state_disabled.label",
            fallback: #"Disabled"#
          )
        }

        public enum StateEnabled {
          /// Enabled
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.authentication.mfa_status.state_enabled.label",
            fallback: #"Enabled"#
          )
        }
      }

      public enum MfaToken {
        public enum DisableMfaAction {
          /// Disable MFA…
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.authentication.mfa_token.disable_mfa_action.label",
            fallback: #"Disable MFA…"#
          )
        }

        public enum Header {
          /// Token:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.authentication.mfa_token.header.label",
            fallback: #"Token:"#
          )
        }
      }

      public enum Password {
        public enum ChangePasswordAction {
          /// Change password…
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.authentication.password.change_password_action.label",
            fallback: #"Change password…"#
          )
        }

        public enum Header {
          /// Password:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.authentication.password.header.label",
            fallback: #"Password:"#
          )
        }
      }

      public enum PasswordSection {
        public enum Footer {
          /// Your password is what keeps your account secure. If you forget it, you can still recover it from your recovery email. **Make sure to keep it up-to-date.**
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.authentication.password_section.footer.label",
            fallback: #"Your password is what keeps your account secure. If you forget it, you can still recover it from your recovery email. **Make sure to keep it up-to-date.**"#
          )
        }

        public enum Header {
          /// Account password
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.authentication.password_section.header.label",
            fallback: #"Account password"#
          )
        }
      }

      public enum RecoveryEmail {
        public enum EditAction {
          /// Edit
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.authentication.recovery_email.edit_action.label",
            fallback: #"Edit"#
          )
        }

        public enum Header {
          /// Recovery email:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.authentication.recovery_email.header.label",
            fallback: #"Recovery email:"#
          )
        }
      }

      public enum RecoveryPhone {
        public enum EditAction {
          /// Edit
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.authentication.recovery_phone.edit_action.label",
            fallback: #"Edit"#
          )
        }

        public enum Header {
          /// Recovery phone:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.authentication.recovery_phone.header.label",
            fallback: #"Recovery phone:"#
          )
        }
      }
    }

    public enum CancelAction {
      /// Cancel
      public static let label = L10n.tr(
        "Localizable",
        "edit_profile.cancel_action.label",
        fallback: #"Cancel"#
      )
    }

    public enum Encryption {
      public enum CurrentDeviceId {
        public enum Header {
          /// Device ID:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.encryption.current_device_id.header.label",
            fallback: #"Device ID:"#
          )
        }
      }

      public enum CurrentDeviceName {
        public enum Header {
          /// Device name:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.encryption.current_device_name.header.label",
            fallback: #"Device name:"#
          )
        }
      }

      public enum CurrentDeviceSection {
        public enum Footer {
          /// Your security key fingerprint is shown as a short hash, which you can use to compare with the one your contacts see on their end. **Both must match.**
          ///
          /// **You may roll it anytime.** This will not make your message history unreadable.
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.encryption.current_device_section.footer.label",
            fallback: #"Your security key fingerprint is shown as a short hash, which you can use to compare with the one your contacts see on their end. **Both must match.**\n\n**You may roll it anytime.** This will not make your message history unreadable."#
          )
        }

        public enum Header {
          /// Current device
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.encryption.current_device_section.header.label",
            fallback: #"Current device"#
          )
        }
      }

      public enum CurrentDeviceSecurityHash {
        public enum Header {
          /// Security hash:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.encryption.current_device_security_hash.header.label",
            fallback: #"Security hash:"#
          )
        }
      }

      public enum DeviceEnabled {
        public enum Toggle {
          /// Enabled?
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.encryption.device_enabled.toggle.label",
            fallback: #"Enabled?"#
          )
        }
      }

      public enum DeviceId {
        public enum Column {
          /// Device ID
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.encryption.device_id.column.label",
            fallback: #"Device ID"#
          )
        }
      }

      public enum DeviceName {
        public enum Column {
          /// Device Name
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.encryption.device_name.column.label",
            fallback: #"Device Name"#
          )
        }
      }

      public enum DeviceSecurityHash {
        public enum Column {
          /// Security Hash
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.encryption.device_security_hash.column.label",
            fallback: #"Security Hash"#
          )
        }
      }

      public enum OtherDevicesSection {
        public enum Footer {
          /// Removing a device will not sign out from account. It prevents all messages sent to you from being decrypted by this device, until you reconnect with this device.
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.encryption.other_devices_section.footer.label",
            fallback: #"Removing a device will not sign out from account. It prevents all messages sent to you from being decrypted by this device, until you reconnect with this device."#
          )
        }

        public enum Header {
          /// Other devices
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.encryption.other_devices_section.header.label",
            fallback: #"Other devices"#
          )
        }
      }

      public enum RollSecurityHashAction {
        /// Roll
        public static let label = L10n.tr(
          "Localizable",
          "edit_profile.encryption.roll_security_hash_action.label",
          fallback: #"Roll"#
        )
      }
    }

    public enum GetVerified {
      public enum Action {
        /// Get verified
        public static let label = L10n.tr(
          "Localizable",
          "edit_profile.get_verified.action.label",
          fallback: #"Get verified"#
        )
      }

      public enum StateVerified {
        /// Verified
        public static let label = L10n.tr(
          "Localizable",
          "edit_profile.get_verified.state_verified.label",
          fallback: #"Verified"#
        )
      }
    }

    public enum Identity {
      public enum ContactSection {
        public enum Footer {
          /// **Your email address and phone number are public.** They are visible to all team members and contacts. They will not be available to other users.
          ///
          /// It is recommended that your email address and phone number each get verified, as it increases the level of trust of your profile. The process only takes a few seconds: you will receive a link to verify your contact details.
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.identity.contact_section.footer.label",
            fallback: #"**Your email address and phone number are public.** They are visible to all team members and contacts. They will not be available to other users.\n\nIt is recommended that your email address and phone number each get verified, as it increases the level of trust of your profile. The process only takes a few seconds: you will receive a link to verify your contact details."#
          )
        }

        public enum Header {
          /// Contact information
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.identity.contact_section.header.label",
            fallback: #"Contact information"#
          )
        }
      }

      public enum Email {
        public enum Header {
          /// Email:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.identity.email.header.label",
            fallback: #"Email:"#
          )
        }

        public enum TextField {
          /// Your email address
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.identity.email.text_field.label",
            fallback: #"Your email address"#
          )
        }
      }

      public enum FirstName {
        public enum Header {
          /// First name:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.identity.first_name.header.label",
            fallback: #"First name:"#
          )
        }

        public enum TextField {
          /// Your first name
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.identity.first_name.text_field.label",
            fallback: #"Your first name"#
          )
        }
      }

      public enum LastName {
        public enum Header {
          /// Last name:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.identity.last_name.header.label",
            fallback: #"Last name:"#
          )
        }

        public enum TextField {
          /// Your last name
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.identity.last_name.text_field.label",
            fallback: #"Your last name"#
          )
        }
      }

      public enum NameSection {
        public enum Footer {
          /// In order to show a verified badge on your profile, visible to other users, you should get your real identity verified (first name & last name). The process takes a few seconds: you will be asked to submit a government ID (ID card, passport or driving license). **Note that the verified status is optional.**
          ///
          /// Your data will be processed on an external service. This service does not keep any record of your ID after your verified status is confirmed.
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.identity.name_section.footer.label",
            fallback: #"In order to show a verified badge on your profile, visible to other users, you should get your real identity verified (first name & last name). The process takes a few seconds: you will be asked to submit a government ID (ID card, passport or driving license). **Note that the verified status is optional.**\n\nYour data will be processed on an external service. This service does not keep any record of your ID after your verified status is confirmed."#
          )
        }

        public enum Header {
          /// Name
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.identity.name_section.header.label",
            fallback: #"Name"#
          )
        }
      }

      public enum Phone {
        public enum Header {
          /// Phone:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.identity.phone.header.label",
            fallback: #"Phone:"#
          )
        }

        public enum TextField {
          /// Your phone number
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.identity.phone.text_field.label",
            fallback: #"Your phone number"#
          )
        }
      }
    }

    public enum Profile {
      public enum AutoDetectLocation {
        public enum Header {
          /// Auto-detect:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.auto_detect_location.header.label",
            fallback: #"Auto-detect:"#
          )
        }

        public enum Toggle {
          /// Auto-detect your location?
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.auto_detect_location.toggle.label",
            fallback: #"Auto-detect your location?"#
          )
        }
      }

      public enum JobSection {
        public enum Footer {
          /// Your current organization and job title are shared with your team members and contacts to identify your position within your company.
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.job_section.footer.label",
            fallback: #"Your current organization and job title are shared with your team members and contacts to identify your position within your company."#
          )
        }

        public enum Header {
          /// Job information
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.job_section.header.label",
            fallback: #"Job information"#
          )
        }
      }

      public enum JobTitle {
        public enum Header {
          /// Title:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.job_title.header.label",
            fallback: #"Title:"#
          )
        }

        public enum TextField {
          /// Your job title
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.job_title.text_field.label",
            fallback: #"Your job title"#
          )
        }
      }

      public enum Location {
        public enum Header {
          /// Location:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.location.header.label",
            fallback: #"Location:"#
          )
        }

        public enum TextField {
          /// Your current location
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.location.text_field.label",
            fallback: #"Your current location"#
          )
        }
      }

      public enum LocationPermission {
        public enum Header {
          /// Geolocation permission:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.location_permission.header.label",
            fallback: #"Geolocation permission:"#
          )
        }

        public enum ManageAction {
          /// Manage
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.location_permission.manage_action.label",
            fallback: #"Manage"#
          )
        }

        public enum StateAllowed {
          /// Allowed
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.location_permission.state_allowed.label",
            fallback: #"Allowed"#
          )
        }

        public enum StateDenied {
          /// Allowed
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.location_permission.state_denied.label",
            fallback: #"Allowed"#
          )
        }
      }

      public enum LocationSection {
        public enum Footer {
          /// You can opt-in to automatic location updates based on your last used device location. It is handy if you travel a lot, and would like this to be auto-managed. Your current city and country will be shared, not your exact GPS location.
          ///
          /// **Note that geolocation permissions are required for automatic mode.**
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.location_section.footer.label",
            fallback: #"You can opt-in to automatic location updates based on your last used device location. It is handy if you travel a lot, and would like this to be auto-managed. Your current city and country will be shared, not your exact GPS location.\n\n**Note that geolocation permissions are required for automatic mode.**"#
          )
        }

        public enum Header {
          /// Current location
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.location_section.header.label",
            fallback: #"Current location"#
          )
        }
      }

      public enum LocationStatus {
        public enum Header {
          /// Status:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.location_status.header.label",
            fallback: #"Status:"#
          )
        }

        public enum StateAuto {
          /// Automatic
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.location_status.state_auto.label",
            fallback: #"Automatic"#
          )
        }
      }

      public enum Organization {
        public enum Header {
          /// Organization:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.organization.header.label",
            fallback: #"Organization:"#
          )
        }

        public enum TextField {
          /// Name of your organization
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.organization.text_field.label",
            fallback: #"Name of your organization"#
          )
        }
      }
    }

    public enum SaveProfileAction {
      /// Save profile
      public static let label = L10n.tr(
        "Localizable",
        "edit_profile.save_profile_action.label",
        fallback: #"Save profile"#
      )
    }

    public enum Sidebar {
      public enum Authentication {
        /// Authentication
        public static let label = L10n.tr(
          "Localizable",
          "edit_profile.sidebar.authentication.label",
          fallback: #"Authentication"#
        )
        /// Password, MFA
        public static let sublabel = L10n.tr(
          "Localizable",
          "edit_profile.sidebar.authentication.sublabel",
          fallback: #"Password, MFA"#
        )
      }

      public enum Encryption {
        /// Encryption
        public static let label = L10n.tr(
          "Localizable",
          "edit_profile.sidebar.encryption.label",
          fallback: #"Encryption"#
        )
        /// Certificates, Keys
        public static let sublabel = L10n.tr(
          "Localizable",
          "edit_profile.sidebar.encryption.sublabel",
          fallback: #"Certificates, Keys"#
        )
      }

      public enum Header {
        public enum ChangeAvatarAction {
          /// Opens a file selector to choose for a new profile picture
          public static let axHint = L10n.tr(
            "Localizable",
            "edit_profile.sidebar.header.change_avatar_action.ax_hint",
            fallback: #"Opens a file selector to choose for a new profile picture"#
          )
          /// Edit your profile picture
          public static let axLabel = L10n.tr(
            "Localizable",
            "edit_profile.sidebar.header.change_avatar_action.ax_label",
            fallback: #"Edit your profile picture"#
          )
        }

        public enum ProfileDetails {
          /// Profile: %s, %s
          public static func axLabel(
            _ p1: UnsafePointer<CChar>,
            _ p2: UnsafePointer<CChar>
          ) -> String {
            L10n.tr(
              "Localizable",
              "edit_profile.sidebar.header.profile_details.ax_label",
              p1,
              p2,
              fallback: #"Profile: %s, %s"#
            )
          }
        }
      }

      public enum Identity {
        /// Identity
        public static let label = L10n.tr(
          "Localizable",
          "edit_profile.sidebar.identity.label",
          fallback: #"Identity"#
        )
        /// Name, Phone, Email
        public static let sublabel = L10n.tr(
          "Localizable",
          "edit_profile.sidebar.identity.sublabel",
          fallback: #"Name, Phone, Email"#
        )
      }

      public enum Profile {
        /// Profile
        public static let label = L10n.tr(
          "Localizable",
          "edit_profile.sidebar.profile.label",
          fallback: #"Profile"#
        )
        /// Job, Location
        public static let sublabel = L10n.tr(
          "Localizable",
          "edit_profile.sidebar.profile.sublabel",
          fallback: #"Job, Location"#
        )
      }

      public enum Row {
        /// %s (%s)
        public static func axLabel(
          _ p1: UnsafePointer<CChar>,
          _ p2: UnsafePointer<CChar>
        ) -> String {
          L10n.tr("Localizable", "edit_profile.sidebar.row.ax_label", p1, p2, fallback: #"%s (%s)"#)
        }
      }
    }
  }

  public enum Info {
    public enum Identity {
      public enum Popover {
        public enum Email {
          public enum StateNotVerified {
            /// Email not verified
            public static let label = L10n.tr(
              "Localizable",
              "info.identity.popover.email.state_not_verified.label",
              fallback: #"Email not verified"#
            )
          }

          public enum StateVerified {
            /// Email verified: %s
            public static func label(_ p1: UnsafePointer<CChar>) -> String {
              L10n.tr(
                "Localizable",
                "info.identity.popover.email.state_verified.label",
                p1,
                fallback: #"Email verified: %s"#
              )
            }
          }
        }

        public enum Fingerprint {
          public enum StateNotVerified {
            /// User signature fingerprint not verified
            public static let label = L10n.tr(
              "Localizable",
              "info.identity.popover.fingerprint.state_not_verified.label",
              fallback: #"User signature fingerprint not verified"#
            )
          }

          public enum StateVerified {
            /// User signature fingerprint verified: %s
            public static func label(_ p1: UnsafePointer<CChar>) -> String {
              L10n.tr(
                "Localizable",
                "info.identity.popover.fingerprint.state_verified.label",
                p1,
                fallback: #"User signature fingerprint verified: %s"#
              )
            }
          }
        }

        public enum Footer {
          /// User data is verified on your configured identity server, which is %s.
          public static func label(_ p1: UnsafePointer<CChar>) -> String {
            L10n.tr(
              "Localizable",
              "info.identity.popover.footer.label",
              p1,
              fallback: #"User data is verified on your configured identity server, which is %s."#
            )
          }
        }

        public enum GovernmentId {
          public enum StateNotProvided {
            /// Government ID not verified (not provided yet)
            public static let label = L10n.tr(
              "Localizable",
              "info.identity.popover.government_id.state_not_provided.label",
              fallback: #"Government ID not verified (not provided yet)"#
            )
          }

          public enum StateVerified {
            /// Government ID verified
            public static let label = L10n.tr(
              "Localizable",
              "info.identity.popover.government_id.state_verified.label",
              fallback: #"Government ID verified"#
            )
          }
        }

        public enum Header {
          /// Prose checked on the identity server for matches. It could verify this user.
          public static let subtitle = L10n.tr(
            "Localizable",
            "info.identity.popover.header.subtitle",
            fallback: #"Prose checked on the identity server for matches. It could verify this user."#
          )
          /// Looks like this is the real %s
          public static func title(_ p1: UnsafePointer<CChar>) -> String {
            L10n.tr(
              "Localizable",
              "info.identity.popover.header.title",
              p1,
              fallback: #"Looks like this is the real %s"#
            )
          }
        }

        public enum Phone {
          public enum StateNotVerified {
            /// Phone not verified
            public static let label = L10n.tr(
              "Localizable",
              "info.identity.popover.phone.state_not_verified.label",
              fallback: #"Phone not verified"#
            )
          }

          public enum StateVerified {
            /// Phone verified: %s
            public static func label(_ p1: UnsafePointer<CChar>) -> String {
              L10n.tr(
                "Localizable",
                "info.identity.popover.phone.state_verified.label",
                p1,
                fallback: #"Phone verified: %s"#
              )
            }
          }
        }
      }
    }
  }

  public enum Server {
    public enum ConnectedTo {
      /// Connected to %s
      public static func label(_ p1: UnsafePointer<CChar>) -> String {
        L10n.tr("Localizable", "server.connected_to.label", p1, fallback: #"Connected to %s"#)
      }
    }
  }

  public enum Settings {
    public enum Accounts {
      /// Address:
      public static let addressLabel = L10n.tr(
        "Localizable",
        "settings.accounts.address_label",
        fallback: #"Address:"#
      )
      /// Enter your address...
      public static let addressPlaceholder = L10n.tr(
        "Localizable",
        "settings.accounts.address_placeholder",
        fallback: #"Enter your address..."#
      )
      /// Enabled:
      public static let enabledLabel = L10n.tr(
        "Localizable",
        "settings.accounts.enabled_label",
        fallback: #"Enabled:"#
      )
      /// Password:
      public static let passwordLabel = L10n.tr(
        "Localizable",
        "settings.accounts.password_label",
        fallback: #"Password:"#
      )
      /// Enter password...
      public static let passwordPlaceholder = L10n.tr(
        "Localizable",
        "settings.accounts.password_placeholder",
        fallback: #"Enter password..."#
      )
      /// Connected
      public static let statusConnected = L10n.tr(
        "Localizable",
        "settings.accounts.status_connected",
        fallback: #"Connected"#
      )
      /// Status:
      public static let statusLabel = L10n.tr(
        "Localizable",
        "settings.accounts.status_label",
        fallback: #"Status:"#
      )
      public enum Tabs {
        /// Account
        public static let account = L10n.tr(
          "Localizable",
          "settings.accounts.tabs.account",
          fallback: #"Account"#
        )
        /// Features
        public static let features = L10n.tr(
          "Localizable",
          "settings.accounts.tabs.features",
          fallback: #"Features"#
        )
        /// Security
        public static let security = L10n.tr(
          "Localizable",
          "settings.accounts.tabs.security",
          fallback: #"Security"#
        )
      }
    }

    public enum Advanced {
      public enum Reports {
        /// Automatically send crash reports
        public static let crashToggle = L10n.tr(
          "Localizable",
          "settings.advanced.reports.crash_toggle",
          fallback: #"Automatically send crash reports"#
        )
        /// Reports:
        public static let label = L10n.tr(
          "Localizable",
          "settings.advanced.reports.label",
          fallback: #"Reports:"#
        )
        /// Send anonymous usage analytics
        public static let usageToggle = L10n.tr(
          "Localizable",
          "settings.advanced.reports.usage_toggle",
          fallback: #"Send anonymous usage analytics"#
        )
      }

      public enum UpdateChannel {
        /// Update channel:
        public static let label = L10n.tr(
          "Localizable",
          "settings.advanced.update_channel.label",
          fallback: #"Update channel:"#
        )
        /// Beta releases
        public static let optionBeta = L10n.tr(
          "Localizable",
          "settings.advanced.update_channel.option_beta",
          fallback: #"Beta releases"#
        )
        /// Stable releases
        public static let optionStable = L10n.tr(
          "Localizable",
          "settings.advanced.update_channel.option_stable",
          fallback: #"Stable releases"#
        )
      }
    }

    public enum Calls {
      public enum AudioInput {
        /// Default audio input:
        public static let defaultLabel = L10n.tr(
          "Localizable",
          "settings.calls.audio_input.default_label",
          fallback: #"Default audio input:"#
        )
        /// Same as System
        public static let defaultOptionSystem = L10n.tr(
          "Localizable",
          "settings.calls.audio_input.default_option_system",
          fallback: #"Same as System"#
        )
        /// Microphone tester:
        public static let testerLabel = L10n.tr(
          "Localizable",
          "settings.calls.audio_input.tester_label",
          fallback: #"Microphone tester:"#
        )
      }

      public enum AudioOutput {
        /// Default audio output:
        public static let defaultLabel = L10n.tr(
          "Localizable",
          "settings.calls.audio_output.default_label",
          fallback: #"Default audio output:"#
        )
        /// Same as System
        public static let defaultOptionSystem = L10n.tr(
          "Localizable",
          "settings.calls.audio_output.default_option_system",
          fallback: #"Same as System"#
        )
        /// Play Test Sound
        public static let testerButton = L10n.tr(
          "Localizable",
          "settings.calls.audio_output.tester_button",
          fallback: #"Play Test Sound"#
        )
        /// Speakers tester:
        public static let testerLabel = L10n.tr(
          "Localizable",
          "settings.calls.audio_output.tester_label",
          fallback: #"Speakers tester:"#
        )
      }

      public enum VideoInput {
        /// Default video input:
        public static let defaultLabel = L10n.tr(
          "Localizable",
          "settings.calls.video_input.default_label",
          fallback: #"Default video input:"#
        )
        /// Same as System
        public static let defaultOptionSystem = L10n.tr(
          "Localizable",
          "settings.calls.video_input.default_option_system",
          fallback: #"Same as System"#
        )
        /// Camera tester:
        public static let testerLabel = L10n.tr(
          "Localizable",
          "settings.calls.video_input.tester_label",
          fallback: #"Camera tester:"#
        )
      }
    }

    public enum General {
      /// Save downloads to:
      public static let downloadsLabel = L10n.tr(
        "Localizable",
        "settings.general.downloads_label",
        fallback: #"Save downloads to:"#
      )
      /// When idle:
      public static let idleLabel = L10n.tr(
        "Localizable",
        "settings.general.idle_label",
        fallback: #"When idle:"#
      )
      /// Phone contacts:
      public static let phoneLabel = L10n.tr(
        "Localizable",
        "settings.general.phone_label",
        fallback: #"Phone contacts:"#
      )
      /// Theme:
      public static let themeLabel = L10n.tr(
        "Localizable",
        "settings.general.theme_label",
        fallback: #"Theme:"#
      )
      /// Dark
      public static let themeOptionDark = L10n.tr(
        "Localizable",
        "settings.general.theme_option_dark",
        fallback: #"Dark"#
      )
      /// Light
      public static let themeOptionLight = L10n.tr(
        "Localizable",
        "settings.general.theme_option_light",
        fallback: #"Light"#
      )
      /// Match system
      public static let themeOptionMatchSystem = L10n.tr(
        "Localizable",
        "settings.general.theme_option_match_system",
        fallback: #"Match system"#
      )
      public enum IdleAutomaticallyMarkAway {
        /// After:
        public static let afterLabel = L10n.tr(
          "Localizable",
          "settings.general.idle_automatically_mark_away.after_label",
          fallback: #"After:"#
        )
        /// 15 minutes
        public static let afterOptionFifteenMinutes = L10n.tr(
          "Localizable",
          "settings.general.idle_automatically_mark_away.after_option_fifteen_minutes",
          fallback: #"15 minutes"#
        )
        /// 5 minutes
        public static let afterOptionFiveMinutes = L10n.tr(
          "Localizable",
          "settings.general.idle_automatically_mark_away.after_option_five_minutes",
          fallback: #"5 minutes"#
        )
        /// 1 hour
        public static let afterOptionOneHour = L10n.tr(
          "Localizable",
          "settings.general.idle_automatically_mark_away.after_option_one_hour",
          fallback: #"1 hour"#
        )
        /// 10 minutes
        public static let afterOptionTenMinutes = L10n.tr(
          "Localizable",
          "settings.general.idle_automatically_mark_away.after_option_ten_minutes",
          fallback: #"10 minutes"#
        )
        /// 30 minutes
        public static let afterOptionThirtyMinutes = L10n.tr(
          "Localizable",
          "settings.general.idle_automatically_mark_away.after_option_thirty_minutes",
          fallback: #"30 minutes"#
        )
        /// Automatically mark me as away
        public static let enabledToggle = L10n.tr(
          "Localizable",
          "settings.general.idle_automatically_mark_away.enabled_toggle",
          fallback: #"Automatically mark me as away"#
        )
      }

      public enum PhoneFromAddressBook {
        /// This is for local use only. Data does not get sent to a server.
        public static let description = L10n.tr(
          "Localizable",
          "settings.general.phone_from_address_book.description",
          fallback: #"This is for local use only. Data does not get sent to a server."#
        )
        /// Use phone numbers from my address book
        public static let toggle = L10n.tr(
          "Localizable",
          "settings.general.phone_from_address_book.toggle",
          fallback: #"Use phone numbers from my address book"#
        )
      }
    }

    public enum Messages {
      public enum Composing {
        /// Composing:
        public static let label = L10n.tr(
          "Localizable",
          "settings.messages.composing.label",
          fallback: #"Composing:"#
        )
        /// Let users know when I am typing
        public static let showWhenTypingToggle = L10n.tr(
          "Localizable",
          "settings.messages.composing.show_when_typing_toggle",
          fallback: #"Let users know when I am typing"#
        )
        /// Enable spell checker
        public static let spellCheckToggle = L10n.tr(
          "Localizable",
          "settings.messages.composing.spell_check_toggle",
          fallback: #"Enable spell checker"#
        )
      }

      public enum Messages {
        /// Use a 24-hour clock
        public static let _24HourClockToggle = L10n.tr(
          "Localizable",
          "settings.messages.messages.24_hour_clock_toggle",
          fallback: #"Use a 24-hour clock"#
        )
        /// Show a preview of image files
        public static let imagePreviewsToggle = L10n.tr(
          "Localizable",
          "settings.messages.messages.image_previews_toggle",
          fallback: #"Show a preview of image files"#
        )
        /// Messages:
        public static let label = L10n.tr(
          "Localizable",
          "settings.messages.messages.label",
          fallback: #"Messages:"#
        )
      }

      public enum Thumbnails {
        /// Image thumbnails:
        public static let label = L10n.tr(
          "Localizable",
          "settings.messages.thumbnails.label",
          fallback: #"Image thumbnails:"#
        )
        /// Large
        public static let sizeOptionLarge = L10n.tr(
          "Localizable",
          "settings.messages.thumbnails.size_option_large",
          fallback: #"Large"#
        )
        /// Small
        public static let sizeOptionSmall = L10n.tr(
          "Localizable",
          "settings.messages.thumbnails.size_option_small",
          fallback: #"Small"#
        )
      }
    }

    public enum Notifications {
      public enum Action {
        /// Show a badge on the Dock icon
        public static let badgeToggle = L10n.tr(
          "Localizable",
          "settings.notifications.action.badge_toggle",
          fallback: #"Show a badge on the Dock icon"#
        )
        /// Pop a banner
        public static let bannerToggle = L10n.tr(
          "Localizable",
          "settings.notifications.action.banner_toggle",
          fallback: #"Pop a banner"#
        )
        /// When notified:
        public static let label = L10n.tr(
          "Localizable",
          "settings.notifications.action.label",
          fallback: #"When notified:"#
        )
        /// Play a sound
        public static let soundToggle = L10n.tr(
          "Localizable",
          "settings.notifications.action.sound_toggle",
          fallback: #"Play a sound"#
        )
      }

      public enum Handover {
        /// Mobile alerts:
        public static let label = L10n.tr(
          "Localizable",
          "settings.notifications.handover.label",
          fallback: #"Mobile alerts:"#
        )
        public enum ForwardMobile {
          /// 5 minutes
          public static let afterOptionFiveMinutes = L10n.tr(
            "Localizable",
            "settings.notifications.handover.forward_mobile.after_option_five_minutes",
            fallback: #"5 minutes"#
          )
          /// A minute
          public static let afterOptionOneMinute = L10n.tr(
            "Localizable",
            "settings.notifications.handover.forward_mobile.after_option_one_minute",
            fallback: #"A minute"#
          )
          /// 10 minutes
          public static let afterOptionTenMinutes = L10n.tr(
            "Localizable",
            "settings.notifications.handover.forward_mobile.after_option_ten_minutes",
            fallback: #"10 minutes"#
          )
          /// Forward to mobile if inactive after time on desktop:
          public static let toggle = L10n.tr(
            "Localizable",
            "settings.notifications.handover.forward_mobile.toggle",
            fallback: #"Forward to mobile if inactive after time on desktop:"#
          )
        }
      }

      public enum NotifyGovernor {
        /// Notify me about:
        public static let label = L10n.tr(
          "Localizable",
          "settings.notifications.notify_governor.label",
          fallback: #"Notify me about:"#
        )
        /// All messages
        public static let optionAll = L10n.tr(
          "Localizable",
          "settings.notifications.notify_governor.option_all",
          fallback: #"All messages"#
        )
        /// Private messages
        public static let optionDirect = L10n.tr(
          "Localizable",
          "settings.notifications.notify_governor.option_direct",
          fallback: #"Private messages"#
        )
        /// Nothing
        public static let optionNone = L10n.tr(
          "Localizable",
          "settings.notifications.notify_governor.option_none",
          fallback: #"Nothing"#
        )
      }

      public enum NotifyOnReply {
        /// Let me know when I receive a message reply
        public static let toggle = L10n.tr(
          "Localizable",
          "settings.notifications.notify_on_reply.toggle",
          fallback: #"Let me know when I receive a message reply"#
        )
      }

      public enum Schedule {
        /// Get notified:
        public static let label = L10n.tr(
          "Localizable",
          "settings.notifications.schedule.label",
          fallback: #"Get notified:"#
        )
        /// Evening
        public static let timeOptionEvening = L10n.tr(
          "Localizable",
          "settings.notifications.schedule.time_option_evening",
          fallback: #"Evening"#
        )
        /// Morning
        public static let timeOptionMorning = L10n.tr(
          "Localizable",
          "settings.notifications.schedule.time_option_morning",
          fallback: #"Morning"#
        )
        /// to
        public static let timeSeparator = L10n.tr(
          "Localizable",
          "settings.notifications.schedule.time_separator",
          fallback: #"to"#
        )
        public enum Days {
          /// Anytime
          public static let optionAnytime = L10n.tr(
            "Localizable",
            "settings.notifications.schedule.days.option_anytime",
            fallback: #"Anytime"#
          )
          /// On weekdays
          public static let optionWeekdays = L10n.tr(
            "Localizable",
            "settings.notifications.schedule.days.option_weekdays",
            fallback: #"On weekdays"#
          )
          /// On weekends
          public static let optionWeekends = L10n.tr(
            "Localizable",
            "settings.notifications.schedule.days.option_weekends",
            fallback: #"On weekends"#
          )
        }
      }
    }

    public enum Tabs {
      /// Accounts
      public static let accounts = L10n.tr(
        "Localizable",
        "settings.tabs.accounts",
        fallback: #"Accounts"#
      )
      /// Advanced
      public static let advanced = L10n.tr(
        "Localizable",
        "settings.tabs.advanced",
        fallback: #"Advanced"#
      )
      /// Calls
      public static let calls = L10n.tr("Localizable", "settings.tabs.calls", fallback: #"Calls"#)
      /// General
      public static let general = L10n.tr(
        "Localizable",
        "settings.tabs.general",
        fallback: #"General"#
      )
      /// Messages
      public static let messages = L10n.tr(
        "Localizable",
        "settings.tabs.messages",
        fallback: #"Messages"#
      )
      /// Notifications
      public static let notifications = L10n.tr(
        "Localizable",
        "settings.tabs.notifications",
        fallback: #"Notifications"#
      )
    }
  }

  public enum Sidebar {
    public enum Favorites {
      /// Favorites
      public static let title = L10n.tr(
        "Localizable",
        "sidebar.favorites.title",
        fallback: #"Favorites"#
      )
    }

    public enum Footer {
      /// Footer
      public static let label = L10n.tr("Localizable", "sidebar.footer.label", fallback: #"Footer"#)
      public enum Actions {
        public enum Account {
          /// Account actions
          public static let label = L10n.tr(
            "Localizable",
            "sidebar.footer.actions.account.label",
            fallback: #"Account actions"#
          )
          public enum AccountSettings {
            /// Account settings
            public static let title = L10n.tr(
              "Localizable",
              "sidebar.footer.actions.account.account_settings.title",
              fallback: #"Account settings"#
            )
          }

          public enum ChangeAvailability {
            /// Change availability
            public static let title = L10n.tr(
              "Localizable",
              "sidebar.footer.actions.account.change_availability.title",
              fallback: #"Change availability"#
            )
          }

          public enum EditProfile {
            /// Edit profile
            public static let title = L10n.tr(
              "Localizable",
              "sidebar.footer.actions.account.edit_profile.title",
              fallback: #"Edit profile"#
            )
          }

          public enum Header {
            /// %s (%s)
            public static func label(
              _ p1: UnsafePointer<CChar>,
              _ p2: UnsafePointer<CChar>
            ) -> String {
              L10n.tr(
                "Localizable",
                "sidebar.footer.actions.account.header.label",
                p1,
                p2,
                fallback: #"%s (%s)"#
              )
            }
          }

          public enum OfflineMode {
            /// Offline mode
            public static let title = L10n.tr(
              "Localizable",
              "sidebar.footer.actions.account.offline_mode.title",
              fallback: #"Offline mode"#
            )
          }

          public enum PauseNotifications {
            /// Pause notifications
            public static let title = L10n.tr(
              "Localizable",
              "sidebar.footer.actions.account.pause_notifications.title",
              fallback: #"Pause notifications"#
            )
          }

          public enum SignOut {
            /// Sign me out
            public static let title = L10n.tr(
              "Localizable",
              "sidebar.footer.actions.account.sign_out.title",
              fallback: #"Sign me out"#
            )
          }

          public enum UpdateMood {
            /// Update mood
            public static let title = L10n.tr(
              "Localizable",
              "sidebar.footer.actions.account.update_mood.title",
              fallback: #"Update mood"#
            )
          }
        }

        public enum Server {
          /// Server actions
          public static let label = L10n.tr(
            "Localizable",
            "sidebar.footer.actions.server.label",
            fallback: #"Server actions"#
          )
          public enum ServerSettings {
            /// Server settings
            public static let title = L10n.tr(
              "Localizable",
              "sidebar.footer.actions.server.server_settings.title",
              fallback: #"Server settings"#
            )
            public enum Manage {
              /// Manage server
              public static let label = L10n.tr(
                "Localizable",
                "sidebar.footer.actions.server.server_settings.manage.label",
                fallback: #"Manage server"#
              )
            }
          }

          public enum SwitchAccount {
            /// Switch to %s
            public static func label(_ p1: UnsafePointer<CChar>) -> String {
              L10n.tr(
                "Localizable",
                "sidebar.footer.actions.server.switch_account.label",
                p1,
                fallback: #"Switch to %s"#
              )
            }

            /// Switch account
            public static let title = L10n.tr(
              "Localizable",
              "sidebar.footer.actions.server.switch_account.title",
              fallback: #"Switch account"#
            )
            public enum New {
              /// Connect account
              public static let label = L10n.tr(
                "Localizable",
                "sidebar.footer.actions.server.switch_account.new.label",
                fallback: #"Connect account"#
              )
            }
          }
        }
      }
    }

    public enum Groups {
      /// Groups
      public static let title = L10n.tr("Localizable", "sidebar.groups.title", fallback: #"Groups"#)
      public enum Add {
        /// Add a group
        public static let label = L10n.tr(
          "Localizable",
          "sidebar.groups.add.label",
          fallback: #"Add a group"#
        )
      }
    }

    public enum OtherContacts {
      /// Other contacts
      public static let title = L10n.tr(
        "Localizable",
        "sidebar.other_contacts.title",
        fallback: #"Other contacts"#
      )
      public enum Add {
        /// Add a contact
        public static let label = L10n.tr(
          "Localizable",
          "sidebar.other_contacts.add.label",
          fallback: #"Add a contact"#
        )
      }
    }

    public enum Spotlight {
      /// Direct messages
      public static let directMessages = L10n.tr(
        "Localizable",
        "sidebar.spotlight.direct_messages",
        fallback: #"Direct messages"#
      )
      /// People & groups
      public static let peopleAndGroups = L10n.tr(
        "Localizable",
        "sidebar.spotlight.people_and_groups",
        fallback: #"People & groups"#
      )
      /// Replies
      public static let replies = L10n.tr(
        "Localizable",
        "sidebar.spotlight.replies",
        fallback: #"Replies"#
      )
      /// Spotlight
      public static let title = L10n.tr(
        "Localizable",
        "sidebar.spotlight.title",
        fallback: #"Spotlight"#
      )
      /// Unread stack
      public static let unreadStack = L10n.tr(
        "Localizable",
        "sidebar.spotlight.unread_stack",
        fallback: #"Unread stack"#
      )
    }

    public enum TeamMembers {
      /// Team members
      public static let title = L10n.tr(
        "Localizable",
        "sidebar.team_members.title",
        fallback: #"Team members"#
      )
      public enum Add {
        /// Add a member
        public static let label = L10n.tr(
          "Localizable",
          "sidebar.team_members.add.label",
          fallback: #"Add a member"#
        )
      }
    }

    public enum Toolbar {
      public enum Actions {
        public enum StartCall {
          /// Opens a window to start a new call.
          public static let hint = L10n.tr(
            "Localizable",
            "sidebar.toolbar.actions.start_call.hint",
            fallback: #"Opens a window to start a new call."#
          )
          /// Start a call
          public static let label = L10n.tr(
            "Localizable",
            "sidebar.toolbar.actions.start_call.label",
            fallback: #"Start a call"#
          )
        }

        public enum WriteMessage {
          /// Asks for recipients then starts composing a message.
          public static let hint = L10n.tr(
            "Localizable",
            "sidebar.toolbar.actions.write_message.hint",
            fallback: #"Asks for recipients then starts composing a message."#
          )
          /// Write a message
          public static let label = L10n.tr(
            "Localizable",
            "sidebar.toolbar.actions.write_message.label",
            fallback: #"Write a message"#
          )
        }
      }
    }
  }
}

// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(
    _ table: String,
    _ key: String,
    _ args: CVarArg...,
    fallback value: String
  ) -> String {
    let format = Bundle.fixedModule.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
