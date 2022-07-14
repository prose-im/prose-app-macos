//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

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
        "authentication.account_error_alert.content"
      )
      /// Account Error
      public static let title = L10n.tr("Localizable", "authentication.account_error_alert.title")
      public enum GoToAccountSettingsAction {
        /// Account settings
        public static let title = L10n.tr(
          "Localizable",
          "authentication.account_error_alert.go_to_account_settings_action.title"
        )
      }

      public enum TryAgainAction {
        /// Try again
        public static let title = L10n.tr(
          "Localizable",
          "authentication.account_error_alert.try_again_action.title"
        )
      }

      public enum WorkOfflineAction {
        /// Work offline
        public static let title = L10n.tr(
          "Localizable",
          "authentication.account_error_alert.work_offline_action.title"
        )
      }
    }

    public enum BasicAuth {
      public enum Alert {
        public enum BadCredentials {
          /// Bad credentials
          public static let title = L10n.tr(
            "Localizable",
            "authentication.basic_auth.alert.bad_credentials.title"
          )
        }
      }

      public enum Cancel {
        public enum Action {
          /// Cancel
          public static let title = L10n.tr(
            "Localizable",
            "authentication.basic_auth.cancel.action.title"
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
            "authentication.basic_auth.chat_address.popover.content"
          )
          /// What is my chat address? (XMPP address)
          public static let title = L10n.tr(
            "Localizable",
            "authentication.basic_auth.chat_address.popover.title"
          )
        }
      }

      public enum Error {
        /// Login failure
        public static let title = L10n.tr("Localizable", "authentication.basic_auth.error.title")
      }

      public enum Form {
        public enum ChatAddress {
          /// Enter your chat address
          public static let placeholder = L10n.tr(
            "Localizable",
            "authentication.basic_auth.form.chat_address.placeholder"
          )
        }

        public enum Password {
          /// Enter your password…
          public static let placeholder = L10n.tr(
            "Localizable",
            "authentication.basic_auth.form.password.placeholder"
          )
        }
      }

      public enum Header {
        /// Sign in to your chat account
        public static let subtitle = L10n.tr(
          "Localizable",
          "authentication.basic_auth.header.subtitle"
        )
        /// Welcome!
        public static let title = L10n.tr("Localizable", "authentication.basic_auth.header.title")
      }

      public enum LogIn {
        public enum Action {
          /// Log into your account
          public static let title = L10n.tr(
            "Localizable",
            "authentication.basic_auth.log_in.action.title"
          )
        }
      }

      public enum NoAccount {
        public enum Action {
          /// No account yet?
          public static let title = L10n.tr(
            "Localizable",
            "authentication.basic_auth.no_account.action.title"
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
            "authentication.basic_auth.no_account.popover.content"
          )
          /// How do I create a new account? (XMPP address)
          public static let title = L10n.tr(
            "Localizable",
            "authentication.basic_auth.no_account.popover.title"
          )
        }
      }

      public enum PasswordLost {
        public enum Action {
          /// Lost your password?
          public static let title = L10n.tr(
            "Localizable",
            "authentication.basic_auth.password_lost.action.title"
          )
        }

        public enum Popover {
          /// Please open this link to our website
          /// to [recover your password](https://prose.org).
          public static let content = L10n.tr(
            "Localizable",
            "authentication.basic_auth.password_lost.popover.content"
          )
          /// Lost your password?
          public static let title = L10n.tr(
            "Localizable",
            "authentication.basic_auth.password_lost.popover.title"
          )
        }
      }
    }

    public enum Mfa {
      public enum ConfirmButton {
        /// Confirm login code
        public static let title = L10n.tr("Localizable", "authentication.mfa.confirm_button.title")
      }

      public enum Error {
        /// Multi factor authentication failure
        public static let title = L10n.tr("Localizable", "authentication.mfa.error.title")
      }

      public enum Footer {
        public enum CannotGenerateCode {
          /// Not implemented yet.
          public static let content = L10n.tr(
            "Localizable",
            "authentication.mfa.footer.cannot_generate_code.content"
          )
          /// Cannot generate code?
          public static let title = L10n.tr(
            "Localizable",
            "authentication.mfa.footer.cannot_generate_code.title"
          )
        }

        public enum NoAccount {
          /// No account yet?
          public static let title = L10n.tr(
            "Localizable",
            "authentication.mfa.footer.no_account.title"
          )
        }
      }

      public enum Form {
        public enum OneTimeCode {
          /// One time code
          public static let placeholder = L10n.tr(
            "Localizable",
            "authentication.mfa.form.one_time_code.placeholder"
          )
        }
      }

      public enum Header {
        /// Enter your 6-digit access code
        public static let subtitle = L10n.tr("Localizable", "authentication.mfa.header.subtitle")
        /// One more step…
        public static let title = L10n.tr("Localizable", "authentication.mfa.header.title")
      }
    }
  }

  public enum Chat {
    public enum OfflineBanner {
      /// New messages will not appear, drafts will be saved for later.
      public static let content = L10n.tr("Localizable", "chat.offline_banner.content")
      /// You are offline
      public static let title = L10n.tr("Localizable", "chat.offline_banner.title")
      public enum ReconnectAction {
        /// Reconnect now
        public static let title = L10n.tr(
          "Localizable",
          "chat.offline_banner.reconnect_action.title"
        )
      }
    }
  }

  public enum Content {
    public enum MessageBar {
      /// %s is typing…
      public static func composeTyping(_ p1: UnsafePointer<CChar>) -> String {
        L10n.tr("Localizable", "content.message_bar.compose_typing", p1)
      }

      /// Message %s
      public static func fieldPlaceholder(_ p1: UnsafePointer<CChar>) -> String {
        L10n.tr("Localizable", "content.message_bar.field_placeholder", p1)
      }
    }

    public enum MessageDetails {
      public enum Actions {
        /// Block contact
        public static let block = L10n.tr("Localizable", "content.message_details.actions.block")
        /// Encryption settings
        public static let encryptionSettings = L10n.tr(
          "Localizable",
          "content.message_details.actions.encryption_settings"
        )
        /// Remove from contacts
        public static let removeContact = L10n.tr(
          "Localizable",
          "content.message_details.actions.remove_contact"
        )
        /// View shared files
        public static let sharedFiles = L10n.tr(
          "Localizable",
          "content.message_details.actions.shared_files"
        )
        /// Actions
        public static let title = L10n.tr("Localizable", "content.message_details.actions.title")
      }

      public enum Information {
        /// Information
        public static let title = L10n.tr(
          "Localizable",
          "content.message_details.information.title"
        )
      }

      public enum Security {
        /// Encrypted (%s)
        public static func encrypted(_ p1: UnsafePointer<CChar>) -> String {
          L10n.tr("Localizable", "content.message_details.security.encrypted", p1)
        }

        /// Identity verified
        public static let identityVerified = L10n.tr(
          "Localizable",
          "content.message_details.security.identity_verified"
        )
        /// Security
        public static let title = L10n.tr("Localizable", "content.message_details.security.title")
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
            "edit_profile.authentication.mfa_section.footer.label"
          )
        }

        public enum Header {
          /// Multi-factor authentication
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.authentication.mfa_section.header.label"
          )
        }
      }

      public enum MfaStatus {
        public enum Header {
          /// Status:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.authentication.mfa_status.header.label"
          )
        }

        public enum StateDisabled {
          /// Disabled
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.authentication.mfa_status.state_disabled.label"
          )
        }

        public enum StateEnabled {
          /// Enabled
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.authentication.mfa_status.state_enabled.label"
          )
        }
      }

      public enum MfaToken {
        public enum DisableMfaAction {
          /// Disable MFA…
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.authentication.mfa_token.disable_mfa_action.label"
          )
        }

        public enum Header {
          /// Token:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.authentication.mfa_token.header.label"
          )
        }
      }

      public enum Password {
        public enum ChangePasswordAction {
          /// Change password…
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.authentication.password.change_password_action.label"
          )
        }

        public enum Header {
          /// Password:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.authentication.password.header.label"
          )
        }
      }

      public enum PasswordSection {
        public enum Footer {
          /// Your password is what keeps your account secure. If you forget it, you can still recover it from your recovery email. **Make sure to keep it up-to-date.**
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.authentication.password_section.footer.label"
          )
        }

        public enum Header {
          /// Account password
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.authentication.password_section.header.label"
          )
        }
      }

      public enum RecoveryEmail {
        public enum EditAction {
          /// Edit
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.authentication.recovery_email.edit_action.label"
          )
        }

        public enum Header {
          /// Recovery email:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.authentication.recovery_email.header.label"
          )
        }
      }

      public enum RecoveryPhone {
        public enum EditAction {
          /// Edit
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.authentication.recovery_phone.edit_action.label"
          )
        }

        public enum Header {
          /// Recovery phone:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.authentication.recovery_phone.header.label"
          )
        }
      }
    }

    public enum CancelAction {
      /// Cancel
      public static let label = L10n.tr("Localizable", "edit_profile.cancel_action.label")
    }

    public enum Encryption {
      public enum CurrentDeviceId {
        public enum Header {
          /// Device ID:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.encryption.current_device_id.header.label"
          )
        }
      }

      public enum CurrentDeviceName {
        public enum Header {
          /// Device name:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.encryption.current_device_name.header.label"
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
            "edit_profile.encryption.current_device_section.footer.label"
          )
        }

        public enum Header {
          /// Current device
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.encryption.current_device_section.header.label"
          )
        }
      }

      public enum CurrentDeviceSecurityHash {
        public enum Header {
          /// Security hash:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.encryption.current_device_security_hash.header.label"
          )
        }
      }

      public enum DeviceEnabled {
        public enum Toggle {
          /// Enabled?
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.encryption.device_enabled.toggle.label"
          )
        }
      }

      public enum DeviceId {
        public enum Column {
          /// Device ID
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.encryption.device_id.column.label"
          )
        }
      }

      public enum DeviceName {
        public enum Column {
          /// Device Name
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.encryption.device_name.column.label"
          )
        }
      }

      public enum DeviceSecurityHash {
        public enum Column {
          /// Security Hash
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.encryption.device_security_hash.column.label"
          )
        }
      }

      public enum OtherDevicesSection {
        public enum Footer {
          /// Removing a device will not sign out from account. It prevents all messages sent to you from being decrypted by this device, until you reconnect with this device.
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.encryption.other_devices_section.footer.label"
          )
        }

        public enum Header {
          /// Other devices
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.encryption.other_devices_section.header.label"
          )
        }
      }

      public enum RollSecurityHashAction {
        /// Roll
        public static let label = L10n.tr(
          "Localizable",
          "edit_profile.encryption.roll_security_hash_action.label"
        )
      }
    }

    public enum GetVerified {
      public enum Action {
        /// Get verified
        public static let label = L10n.tr("Localizable", "edit_profile.get_verified.action.label")
      }

      public enum StateVerified {
        /// Verified
        public static let label = L10n.tr(
          "Localizable",
          "edit_profile.get_verified.state_verified.label"
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
            "edit_profile.identity.contact_section.footer.label"
          )
        }

        public enum Header {
          /// Contact information
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.identity.contact_section.header.label"
          )
        }
      }

      public enum Email {
        public enum Header {
          /// Email:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.identity.email.header.label"
          )
        }

        public enum TextField {
          /// Your email address
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.identity.email.text_field.label"
          )
        }
      }

      public enum FirstName {
        public enum Header {
          /// First name:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.identity.first_name.header.label"
          )
        }

        public enum TextField {
          /// Your first name
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.identity.first_name.text_field.label"
          )
        }
      }

      public enum LastName {
        public enum Header {
          /// Last name:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.identity.last_name.header.label"
          )
        }

        public enum TextField {
          /// Your last name
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.identity.last_name.text_field.label"
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
            "edit_profile.identity.name_section.footer.label"
          )
        }

        public enum Header {
          /// Name
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.identity.name_section.header.label"
          )
        }
      }

      public enum Phone {
        public enum Header {
          /// Phone:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.identity.phone.header.label"
          )
        }

        public enum TextField {
          /// Your phone number
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.identity.phone.text_field.label"
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
            "edit_profile.profile.auto_detect_location.header.label"
          )
        }

        public enum Toggle {
          /// Auto-detect your location?
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.auto_detect_location.toggle.label"
          )
        }
      }

      public enum JobSection {
        public enum Footer {
          /// Your current organization and job title are shared with your team members and contacts to identify your position within your company.
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.job_section.footer.label"
          )
        }

        public enum Header {
          /// Job information
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.job_section.header.label"
          )
        }
      }

      public enum JobTitle {
        public enum Header {
          /// Title:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.job_title.header.label"
          )
        }

        public enum TextField {
          /// Your job title
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.job_title.text_field.label"
          )
        }
      }

      public enum Location {
        public enum Header {
          /// Location:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.location.header.label"
          )
        }

        public enum TextField {
          /// Your current location
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.location.text_field.label"
          )
        }
      }

      public enum LocationPermission {
        public enum Header {
          /// Geolocation permission:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.location_permission.header.label"
          )
        }

        public enum ManageAction {
          /// Manage
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.location_permission.manage_action.label"
          )
        }

        public enum StateAllowed {
          /// Allowed
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.location_permission.state_allowed.label"
          )
        }

        public enum StateDenied {
          /// Allowed
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.location_permission.state_denied.label"
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
            "edit_profile.profile.location_section.footer.label"
          )
        }

        public enum Header {
          /// Current location
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.location_section.header.label"
          )
        }
      }

      public enum LocationStatus {
        public enum Header {
          /// Status:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.location_status.header.label"
          )
        }

        public enum StateAuto {
          /// Automatic
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.location_status.state_auto.label"
          )
        }
      }

      public enum Organization {
        public enum Header {
          /// Organization:
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.organization.header.label"
          )
        }

        public enum TextField {
          /// Name of your organization
          public static let label = L10n.tr(
            "Localizable",
            "edit_profile.profile.organization.text_field.label"
          )
        }
      }
    }

    public enum SaveProfileAction {
      /// Save profile
      public static let label = L10n.tr("Localizable", "edit_profile.save_profile_action.label")
    }

    public enum Sidebar {
      public enum Authentication {
        /// Authentication
        public static let label = L10n.tr(
          "Localizable",
          "edit_profile.sidebar.authentication.label"
        )
        /// Password, MFA
        public static let sublabel = L10n.tr(
          "Localizable",
          "edit_profile.sidebar.authentication.sublabel"
        )
      }

      public enum Encryption {
        /// Encryption
        public static let label = L10n.tr("Localizable", "edit_profile.sidebar.encryption.label")
        /// Certificates, Keys
        public static let sublabel = L10n.tr(
          "Localizable",
          "edit_profile.sidebar.encryption.sublabel"
        )
      }

      public enum Header {
        public enum ChangeAvatarAction {
          /// Opens a file selector to choose for a new profile picture
          public static let axHint = L10n.tr(
            "Localizable",
            "edit_profile.sidebar.header.change_avatar_action.ax_hint"
          )
          /// Edit your profile picture
          public static let axLabel = L10n.tr(
            "Localizable",
            "edit_profile.sidebar.header.change_avatar_action.ax_label"
          )
        }

        public enum ProfileDetails {
          /// Profile: %s, %s
          public static func axLabel(
            _ p1: UnsafePointer<CChar>,
            _ p2: UnsafePointer<CChar>
          ) -> String {
            L10n.tr("Localizable", "edit_profile.sidebar.header.profile_details.ax_label", p1, p2)
          }
        }
      }

      public enum Identity {
        /// Identity
        public static let label = L10n.tr("Localizable", "edit_profile.sidebar.identity.label")
        /// Name, Phone, Email
        public static let sublabel = L10n.tr(
          "Localizable",
          "edit_profile.sidebar.identity.sublabel"
        )
      }

      public enum Profile {
        /// Profile
        public static let label = L10n.tr("Localizable", "edit_profile.sidebar.profile.label")
        /// Job, Location
        public static let sublabel = L10n.tr("Localizable", "edit_profile.sidebar.profile.sublabel")
      }

      public enum Row {
        /// %s (%s)
        public static func axLabel(
          _ p1: UnsafePointer<CChar>,
          _ p2: UnsafePointer<CChar>
        ) -> String {
          L10n.tr("Localizable", "edit_profile.sidebar.row.ax_label", p1, p2)
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
              "info.identity.popover.email.state_not_verified.label"
            )
          }

          public enum StateVerified {
            /// Email verified: %s
            public static func label(_ p1: UnsafePointer<CChar>) -> String {
              L10n.tr("Localizable", "info.identity.popover.email.state_verified.label", p1)
            }
          }
        }

        public enum Fingerprint {
          public enum StateNotVerified {
            /// User signature fingerprint not verified
            public static let label = L10n.tr(
              "Localizable",
              "info.identity.popover.fingerprint.state_not_verified.label"
            )
          }

          public enum StateVerified {
            /// User signature fingerprint verified: %s
            public static func label(_ p1: UnsafePointer<CChar>) -> String {
              L10n.tr("Localizable", "info.identity.popover.fingerprint.state_verified.label", p1)
            }
          }
        }

        public enum Footer {
          /// User data is verified on your configured identity server, which is %s.
          public static func label(_ p1: UnsafePointer<CChar>) -> String {
            L10n.tr("Localizable", "info.identity.popover.footer.label", p1)
          }
        }

        public enum GovernmentId {
          public enum StateNotProvided {
            /// Government ID not verified (not provided yet)
            public static let label = L10n.tr(
              "Localizable",
              "info.identity.popover.government_id.state_not_provided.label"
            )
          }

          public enum StateVerified {
            /// Government ID verified
            public static let label = L10n.tr(
              "Localizable",
              "info.identity.popover.government_id.state_verified.label"
            )
          }
        }

        public enum Header {
          /// Prose checked on the identity server for matches. It could verify this user.
          public static let subtitle = L10n.tr(
            "Localizable",
            "info.identity.popover.header.subtitle"
          )
          /// Looks like this is the real %s
          public static func title(_ p1: UnsafePointer<CChar>) -> String {
            L10n.tr("Localizable", "info.identity.popover.header.title", p1)
          }
        }

        public enum Phone {
          public enum StateNotVerified {
            /// Phone not verified
            public static let label = L10n.tr(
              "Localizable",
              "info.identity.popover.phone.state_not_verified.label"
            )
          }

          public enum StateVerified {
            /// Phone verified: %s
            public static func label(_ p1: UnsafePointer<CChar>) -> String {
              L10n.tr("Localizable", "info.identity.popover.phone.state_verified.label", p1)
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
        L10n.tr("Localizable", "server.connected_to.label", p1)
      }
    }
  }

  public enum Settings {
    public enum Accounts {
      /// Address:
      public static let addressLabel = L10n.tr("Localizable", "settings.accounts.address_label")
      /// Enter your address...
      public static let addressPlaceholder = L10n.tr(
        "Localizable",
        "settings.accounts.address_placeholder"
      )
      /// Enabled:
      public static let enabledLabel = L10n.tr("Localizable", "settings.accounts.enabled_label")
      /// Password:
      public static let passwordLabel = L10n.tr("Localizable", "settings.accounts.password_label")
      /// Enter password...
      public static let passwordPlaceholder = L10n.tr(
        "Localizable",
        "settings.accounts.password_placeholder"
      )
      /// Connected
      public static let statusConnected = L10n.tr(
        "Localizable",
        "settings.accounts.status_connected"
      )
      /// Status:
      public static let statusLabel = L10n.tr("Localizable", "settings.accounts.status_label")
      public enum Tabs {
        /// Account
        public static let account = L10n.tr("Localizable", "settings.accounts.tabs.account")
        /// Features
        public static let features = L10n.tr("Localizable", "settings.accounts.tabs.features")
        /// Security
        public static let security = L10n.tr("Localizable", "settings.accounts.tabs.security")
      }
    }

    public enum Advanced {
      public enum Reports {
        /// Automatically send crash reports
        public static let crashToggle = L10n.tr(
          "Localizable",
          "settings.advanced.reports.crash_toggle"
        )
        /// Reports:
        public static let label = L10n.tr("Localizable", "settings.advanced.reports.label")
        /// Send anonymous usage analytics
        public static let usageToggle = L10n.tr(
          "Localizable",
          "settings.advanced.reports.usage_toggle"
        )
      }

      public enum UpdateChannel {
        /// Update channel:
        public static let label = L10n.tr("Localizable", "settings.advanced.update_channel.label")
        /// Beta releases
        public static let optionBeta = L10n.tr(
          "Localizable",
          "settings.advanced.update_channel.option_beta"
        )
        /// Stable releases
        public static let optionStable = L10n.tr(
          "Localizable",
          "settings.advanced.update_channel.option_stable"
        )
      }
    }

    public enum Calls {
      public enum AudioInput {
        /// Default audio input:
        public static let defaultLabel = L10n.tr(
          "Localizable",
          "settings.calls.audio_input.default_label"
        )
        /// Same as System
        public static let defaultOptionSystem = L10n.tr(
          "Localizable",
          "settings.calls.audio_input.default_option_system"
        )
        /// Microphone tester:
        public static let testerLabel = L10n.tr(
          "Localizable",
          "settings.calls.audio_input.tester_label"
        )
      }

      public enum AudioOutput {
        /// Default audio output:
        public static let defaultLabel = L10n.tr(
          "Localizable",
          "settings.calls.audio_output.default_label"
        )
        /// Same as System
        public static let defaultOptionSystem = L10n.tr(
          "Localizable",
          "settings.calls.audio_output.default_option_system"
        )
        /// Play Test Sound
        public static let testerButton = L10n.tr(
          "Localizable",
          "settings.calls.audio_output.tester_button"
        )
        /// Speakers tester:
        public static let testerLabel = L10n.tr(
          "Localizable",
          "settings.calls.audio_output.tester_label"
        )
      }

      public enum VideoInput {
        /// Default video input:
        public static let defaultLabel = L10n.tr(
          "Localizable",
          "settings.calls.video_input.default_label"
        )
        /// Same as System
        public static let defaultOptionSystem = L10n.tr(
          "Localizable",
          "settings.calls.video_input.default_option_system"
        )
        /// Camera tester:
        public static let testerLabel = L10n.tr(
          "Localizable",
          "settings.calls.video_input.tester_label"
        )
      }
    }

    public enum General {
      /// Save downloads to:
      public static let downloadsLabel = L10n.tr("Localizable", "settings.general.downloads_label")
      /// When idle:
      public static let idleLabel = L10n.tr("Localizable", "settings.general.idle_label")
      /// Phone contacts:
      public static let phoneLabel = L10n.tr("Localizable", "settings.general.phone_label")
      /// Theme:
      public static let themeLabel = L10n.tr("Localizable", "settings.general.theme_label")
      /// Dark
      public static let themeOptionDark = L10n.tr(
        "Localizable",
        "settings.general.theme_option_dark"
      )
      /// Light
      public static let themeOptionLight = L10n.tr(
        "Localizable",
        "settings.general.theme_option_light"
      )
      /// Match system
      public static let themeOptionMatchSystem = L10n.tr(
        "Localizable",
        "settings.general.theme_option_match_system"
      )
      public enum IdleAutomaticallyMarkAway {
        /// After:
        public static let afterLabel = L10n.tr(
          "Localizable",
          "settings.general.idle_automatically_mark_away.after_label"
        )
        /// 15 minutes
        public static let afterOptionFifteenMinutes = L10n.tr(
          "Localizable",
          "settings.general.idle_automatically_mark_away.after_option_fifteen_minutes"
        )
        /// 5 minutes
        public static let afterOptionFiveMinutes = L10n.tr(
          "Localizable",
          "settings.general.idle_automatically_mark_away.after_option_five_minutes"
        )
        /// 1 hour
        public static let afterOptionOneHour = L10n.tr(
          "Localizable",
          "settings.general.idle_automatically_mark_away.after_option_one_hour"
        )
        /// 10 minutes
        public static let afterOptionTenMinutes = L10n.tr(
          "Localizable",
          "settings.general.idle_automatically_mark_away.after_option_ten_minutes"
        )
        /// 30 minutes
        public static let afterOptionThirtyMinutes = L10n.tr(
          "Localizable",
          "settings.general.idle_automatically_mark_away.after_option_thirty_minutes"
        )
        /// Automatically mark me as away
        public static let enabledToggle = L10n.tr(
          "Localizable",
          "settings.general.idle_automatically_mark_away.enabled_toggle"
        )
      }

      public enum PhoneFromAddressBook {
        /// This is for local use only. Data does not get sent to a server.
        public static let description = L10n.tr(
          "Localizable",
          "settings.general.phone_from_address_book.description"
        )
        /// Use phone numbers from my address book
        public static let toggle = L10n.tr(
          "Localizable",
          "settings.general.phone_from_address_book.toggle"
        )
      }
    }

    public enum Messages {
      public enum Composing {
        /// Composing:
        public static let label = L10n.tr("Localizable", "settings.messages.composing.label")
        /// Let users know when I am typing
        public static let showWhenTypingToggle = L10n.tr(
          "Localizable",
          "settings.messages.composing.show_when_typing_toggle"
        )
        /// Enable spell checker
        public static let spellCheckToggle = L10n.tr(
          "Localizable",
          "settings.messages.composing.spell_check_toggle"
        )
      }

      public enum Messages {
        /// Use a 24-hour clock
        public static let _24HourClockToggle = L10n.tr(
          "Localizable",
          "settings.messages.messages.24_hour_clock_toggle"
        )
        /// Show a preview of image files
        public static let imagePreviewsToggle = L10n.tr(
          "Localizable",
          "settings.messages.messages.image_previews_toggle"
        )
        /// Messages:
        public static let label = L10n.tr("Localizable", "settings.messages.messages.label")
      }

      public enum Thumbnails {
        /// Image thumbnails:
        public static let label = L10n.tr("Localizable", "settings.messages.thumbnails.label")
        /// Large
        public static let sizeOptionLarge = L10n.tr(
          "Localizable",
          "settings.messages.thumbnails.size_option_large"
        )
        /// Small
        public static let sizeOptionSmall = L10n.tr(
          "Localizable",
          "settings.messages.thumbnails.size_option_small"
        )
      }
    }

    public enum Notifications {
      public enum Action {
        /// Show a badge on the Dock icon
        public static let badgeToggle = L10n.tr(
          "Localizable",
          "settings.notifications.action.badge_toggle"
        )
        /// Pop a banner
        public static let bannerToggle = L10n.tr(
          "Localizable",
          "settings.notifications.action.banner_toggle"
        )
        /// When notified:
        public static let label = L10n.tr("Localizable", "settings.notifications.action.label")
        /// Play a sound
        public static let soundToggle = L10n.tr(
          "Localizable",
          "settings.notifications.action.sound_toggle"
        )
      }

      public enum Handover {
        /// Mobile alerts:
        public static let label = L10n.tr("Localizable", "settings.notifications.handover.label")
        public enum ForwardMobile {
          /// 5 minutes
          public static let afterOptionFiveMinutes = L10n.tr(
            "Localizable",
            "settings.notifications.handover.forward_mobile.after_option_five_minutes"
          )
          /// A minute
          public static let afterOptionOneMinute = L10n.tr(
            "Localizable",
            "settings.notifications.handover.forward_mobile.after_option_one_minute"
          )
          /// 10 minutes
          public static let afterOptionTenMinutes = L10n.tr(
            "Localizable",
            "settings.notifications.handover.forward_mobile.after_option_ten_minutes"
          )
          /// Forward to mobile if inactive after time on desktop:
          public static let toggle = L10n.tr(
            "Localizable",
            "settings.notifications.handover.forward_mobile.toggle"
          )
        }
      }

      public enum NotifyGovernor {
        /// Notify me about:
        public static let label = L10n.tr(
          "Localizable",
          "settings.notifications.notify_governor.label"
        )
        /// All messages
        public static let optionAll = L10n.tr(
          "Localizable",
          "settings.notifications.notify_governor.option_all"
        )
        /// Private messages
        public static let optionDirect = L10n.tr(
          "Localizable",
          "settings.notifications.notify_governor.option_direct"
        )
        /// Nothing
        public static let optionNone = L10n.tr(
          "Localizable",
          "settings.notifications.notify_governor.option_none"
        )
      }

      public enum NotifyOnReply {
        /// Let me know when I receive a message reply
        public static let toggle = L10n.tr(
          "Localizable",
          "settings.notifications.notify_on_reply.toggle"
        )
      }

      public enum Schedule {
        /// Get notified:
        public static let label = L10n.tr("Localizable", "settings.notifications.schedule.label")
        /// Evening
        public static let timeOptionEvening = L10n.tr(
          "Localizable",
          "settings.notifications.schedule.time_option_evening"
        )
        /// Morning
        public static let timeOptionMorning = L10n.tr(
          "Localizable",
          "settings.notifications.schedule.time_option_morning"
        )
        /// to
        public static let timeSeparator = L10n.tr(
          "Localizable",
          "settings.notifications.schedule.time_separator"
        )
        public enum Days {
          /// Anytime
          public static let optionAnytime = L10n.tr(
            "Localizable",
            "settings.notifications.schedule.days.option_anytime"
          )
          /// On weekdays
          public static let optionWeekdays = L10n.tr(
            "Localizable",
            "settings.notifications.schedule.days.option_weekdays"
          )
          /// On weekends
          public static let optionWeekends = L10n.tr(
            "Localizable",
            "settings.notifications.schedule.days.option_weekends"
          )
        }
      }
    }

    public enum Tabs {
      /// Accounts
      public static let accounts = L10n.tr("Localizable", "settings.tabs.accounts")
      /// Advanced
      public static let advanced = L10n.tr("Localizable", "settings.tabs.advanced")
      /// Calls
      public static let calls = L10n.tr("Localizable", "settings.tabs.calls")
      /// General
      public static let general = L10n.tr("Localizable", "settings.tabs.general")
      /// Messages
      public static let messages = L10n.tr("Localizable", "settings.tabs.messages")
      /// Notifications
      public static let notifications = L10n.tr("Localizable", "settings.tabs.notifications")
    }
  }

  public enum Sidebar {
    public enum Favorites {
      /// Favorites
      public static let title = L10n.tr("Localizable", "sidebar.favorites.title")
    }

    public enum Footer {
      /// Footer
      public static let label = L10n.tr("Localizable", "sidebar.footer.label")
      public enum Actions {
        public enum Account {
          /// Account actions
          public static let label = L10n.tr("Localizable", "sidebar.footer.actions.account.label")
          public enum AccountSettings {
            /// Account settings
            public static let title = L10n.tr(
              "Localizable",
              "sidebar.footer.actions.account.account_settings.title"
            )
          }

          public enum ChangeAvailability {
            /// Change availability
            public static let title = L10n.tr(
              "Localizable",
              "sidebar.footer.actions.account.change_availability.title"
            )
          }

          public enum EditProfile {
            /// Edit profile
            public static let title = L10n.tr(
              "Localizable",
              "sidebar.footer.actions.account.edit_profile.title"
            )
          }

          public enum Header {
            /// %s (%s)
            public static func label(
              _ p1: UnsafePointer<CChar>,
              _ p2: UnsafePointer<CChar>
            ) -> String {
              L10n.tr("Localizable", "sidebar.footer.actions.account.header.label", p1, p2)
            }
          }

          public enum OfflineMode {
            /// Offline mode
            public static let title = L10n.tr(
              "Localizable",
              "sidebar.footer.actions.account.offline_mode.title"
            )
          }

          public enum PauseNotifications {
            /// Pause notifications
            public static let title = L10n.tr(
              "Localizable",
              "sidebar.footer.actions.account.pause_notifications.title"
            )
          }

          public enum SignOut {
            /// Sign me out
            public static let title = L10n.tr(
              "Localizable",
              "sidebar.footer.actions.account.sign_out.title"
            )
          }

          public enum UpdateMood {
            /// Update mood
            public static let title = L10n.tr(
              "Localizable",
              "sidebar.footer.actions.account.update_mood.title"
            )
          }
        }

        public enum Server {
          /// Server actions
          public static let label = L10n.tr("Localizable", "sidebar.footer.actions.server.label")
          public enum ServerSettings {
            /// Server settings
            public static let title = L10n.tr(
              "Localizable",
              "sidebar.footer.actions.server.server_settings.title"
            )
            public enum Manage {
              /// Manage server
              public static let label = L10n.tr(
                "Localizable",
                "sidebar.footer.actions.server.server_settings.manage.label"
              )
            }
          }

          public enum SwitchAccount {
            /// Switch to %s
            public static func label(_ p1: UnsafePointer<CChar>) -> String {
              L10n.tr("Localizable", "sidebar.footer.actions.server.switch_account.label", p1)
            }

            /// Switch account
            public static let title = L10n.tr(
              "Localizable",
              "sidebar.footer.actions.server.switch_account.title"
            )
            public enum New {
              /// Connect account
              public static let label = L10n.tr(
                "Localizable",
                "sidebar.footer.actions.server.switch_account.new.label"
              )
            }
          }
        }
      }
    }

    public enum Groups {
      /// Groups
      public static let title = L10n.tr("Localizable", "sidebar.groups.title")
      public enum Add {
        /// Add a group
        public static let label = L10n.tr("Localizable", "sidebar.groups.add.label")
      }
    }

    public enum OtherContacts {
      /// Other contacts
      public static let title = L10n.tr("Localizable", "sidebar.other_contacts.title")
      public enum Add {
        /// Add a contact
        public static let label = L10n.tr("Localizable", "sidebar.other_contacts.add.label")
      }
    }

    public enum Spotlight {
      /// Direct messages
      public static let directMessages = L10n.tr("Localizable", "sidebar.spotlight.direct_messages")
      /// People & groups
      public static let peopleAndGroups = L10n.tr(
        "Localizable",
        "sidebar.spotlight.people_and_groups"
      )
      /// Replies
      public static let replies = L10n.tr("Localizable", "sidebar.spotlight.replies")
      /// Spotlight
      public static let title = L10n.tr("Localizable", "sidebar.spotlight.title")
      /// Unread stack
      public static let unreadStack = L10n.tr("Localizable", "sidebar.spotlight.unread_stack")
    }

    public enum TeamMembers {
      /// Team members
      public static let title = L10n.tr("Localizable", "sidebar.team_members.title")
      public enum Add {
        /// Add a member
        public static let label = L10n.tr("Localizable", "sidebar.team_members.add.label")
      }
    }

    public enum Toolbar {
      public enum Actions {
        public enum StartCall {
          /// Opens a window to start a new call.
          public static let hint = L10n.tr("Localizable", "sidebar.toolbar.actions.start_call.hint")
          /// Start a call
          public static let label = L10n.tr(
            "Localizable",
            "sidebar.toolbar.actions.start_call.label"
          )
        }

        public enum WriteMessage {
          /// Asks for recipients then starts composing a message.
          public static let hint = L10n.tr(
            "Localizable",
            "sidebar.toolbar.actions.write_message.hint"
          )
          /// Write a message
          public static let label = L10n.tr(
            "Localizable",
            "sidebar.toolbar.actions.write_message.label"
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
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = Bundle.fixedModule.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
