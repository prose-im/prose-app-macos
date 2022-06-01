// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {

  public enum Content {
    public enum MessageBar {
      /// %@ is typing…
      public static func composeTyping(_ p1: Any) -> String {
        return L10n.tr("Localizable", "content.message_bar.compose_typing", String(describing: p1))
      }
      /// Message %@
      public static func fieldPlaceholder(_ p1: Any) -> String {
        return L10n.tr("Localizable", "content.message_bar.field_placeholder", String(describing: p1))
      }
    }
    public enum MessageDetails {
      public enum Actions {
        /// Block contact
        public static let block = L10n.tr("Localizable", "content.message_details.actions.block")
        /// Encryption settings
        public static let encryptionSettings = L10n.tr("Localizable", "content.message_details.actions.encryption_settings")
        /// Remove from contacts
        public static let removeContact = L10n.tr("Localizable", "content.message_details.actions.remove_contact")
        /// View shared files
        public static let sharedFiles = L10n.tr("Localizable", "content.message_details.actions.shared_files")
        /// Actions
        public static let title = L10n.tr("Localizable", "content.message_details.actions.title")
      }
      public enum Information {
        /// Information
        public static let title = L10n.tr("Localizable", "content.message_details.information.title")
      }
      public enum Security {
        /// Encrypted
        public static let encrypted = L10n.tr("Localizable", "content.message_details.security.encrypted")
        /// Identity verified
        public static let identityVerified = L10n.tr("Localizable", "content.message_details.security.identity_verified")
        /// Security
        public static let title = L10n.tr("Localizable", "content.message_details.security.title")
      }
    }
  }

  public enum Settings {
    public enum Accounts {
      /// Address:
      public static let addressLabel = L10n.tr("Localizable", "settings.accounts.address_label")
      /// Enter your address...
      public static let addressPlaceholder = L10n.tr("Localizable", "settings.accounts.address_placeholder")
      /// Enabled:
      public static let enabledLabel = L10n.tr("Localizable", "settings.accounts.enabled_label")
      /// Password:
      public static let passwordLabel = L10n.tr("Localizable", "settings.accounts.password_label")
      /// Enter password...
      public static let passwordPlaceholder = L10n.tr("Localizable", "settings.accounts.password_placeholder")
      /// Connected
      public static let statusConnected = L10n.tr("Localizable", "settings.accounts.status_connected")
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
        public static let crashToggle = L10n.tr("Localizable", "settings.advanced.reports.crash_toggle")
        /// Reports:
        public static let label = L10n.tr("Localizable", "settings.advanced.reports.label")
        /// Send anonymous usage analytics
        public static let usageToggle = L10n.tr("Localizable", "settings.advanced.reports.usage_toggle")
      }
      public enum UpdateChannel {
        /// Update channel:
        public static let label = L10n.tr("Localizable", "settings.advanced.update_channel.label")
        /// Beta releases
        public static let optionBeta = L10n.tr("Localizable", "settings.advanced.update_channel.option_beta")
        /// Stable releases
        public static let optionStable = L10n.tr("Localizable", "settings.advanced.update_channel.option_stable")
      }
    }
    public enum Calls {
      public enum AudioInput {
        /// Default audio input:
        public static let defaultLabel = L10n.tr("Localizable", "settings.calls.audio_input.default_label")
        /// Same as System
        public static let defaultOptionSystem = L10n.tr("Localizable", "settings.calls.audio_input.default_option_system")
        /// Microphone tester:
        public static let testerLabel = L10n.tr("Localizable", "settings.calls.audio_input.tester_label")
      }
      public enum AudioOutput {
        /// Default audio output:
        public static let defaultLabel = L10n.tr("Localizable", "settings.calls.audio_output.default_label")
        /// Same as System
        public static let defaultOptionSystem = L10n.tr("Localizable", "settings.calls.audio_output.default_option_system")
        /// Play Test Sound
        public static let testerButton = L10n.tr("Localizable", "settings.calls.audio_output.tester_button")
        /// Speakers tester:
        public static let testerLabel = L10n.tr("Localizable", "settings.calls.audio_output.tester_label")
      }
      public enum VideoInput {
        /// Default video input:
        public static let defaultLabel = L10n.tr("Localizable", "settings.calls.video_input.default_label")
        /// Same as System
        public static let defaultOptionSystem = L10n.tr("Localizable", "settings.calls.video_input.default_option_system")
        /// Camera tester:
        public static let testerLabel = L10n.tr("Localizable", "settings.calls.video_input.tester_label")
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
      public static let themeOptionDark = L10n.tr("Localizable", "settings.general.theme_option_dark")
      /// Light
      public static let themeOptionLight = L10n.tr("Localizable", "settings.general.theme_option_light")
      /// Match system
      public static let themeOptionMatchSystem = L10n.tr("Localizable", "settings.general.theme_option_match_system")
      public enum IdleAutomaticallyMarkAway {
        /// 15 minutes
        public static let afterOptionFifteenMinutes = L10n.tr("Localizable", "settings.general.idle_automatically_mark_away.after_option_fifteen_minutes")
        /// 5 minutes
        public static let afterOptionFiveMinutes = L10n.tr("Localizable", "settings.general.idle_automatically_mark_away.after_option_five_minutes")
        /// 1 hour
        public static let afterOptionOneHour = L10n.tr("Localizable", "settings.general.idle_automatically_mark_away.after_option_one_hour")
        /// 10 minutes
        public static let afterOptionTenMinutes = L10n.tr("Localizable", "settings.general.idle_automatically_mark_away.after_option_ten_minutes")
        /// 30 minutes
        public static let afterOptionThirtyMinutes = L10n.tr("Localizable", "settings.general.idle_automatically_mark_away.after_option_thirty_minutes")
        /// Automatically mark me as away after:
        public static let enabledToggle = L10n.tr("Localizable", "settings.general.idle_automatically_mark_away.enabled_toggle")
      }
      public enum PhoneFromAddressBook {
        /// This is for local use only. Data does not get sent to a server.
        public static let description = L10n.tr("Localizable", "settings.general.phone_from_address_book.description")
        /// Use phone numbers from my address book
        public static let toggle = L10n.tr("Localizable", "settings.general.phone_from_address_book.toggle")
      }
    }
    public enum Messages {
      public enum Composing {
        /// Composing:
        public static let label = L10n.tr("Localizable", "settings.messages.composing.label")
        /// Let users know when I am typing
        public static let showWhenTypingToggle = L10n.tr("Localizable", "settings.messages.composing.show_when_typing_toggle")
        /// Enable spell checker
        public static let spellCheckToggle = L10n.tr("Localizable", "settings.messages.composing.spell_check_toggle")
      }
      public enum Messages {
        /// Use a 24-hour clock
        public static let _24HourClockToggle = L10n.tr("Localizable", "settings.messages.messages.24_hour_clock_toggle")
        /// Show a preview of image files
        public static let imagePreviewsToggle = L10n.tr("Localizable", "settings.messages.messages.image_previews_toggle")
        /// Messages:
        public static let label = L10n.tr("Localizable", "settings.messages.messages.label")
      }
      public enum Thumbnails {
        /// Image thumbnails:
        public static let label = L10n.tr("Localizable", "settings.messages.thumbnails.label")
        /// Large
        public static let sizeOptionLarge = L10n.tr("Localizable", "settings.messages.thumbnails.size_option_large")
        /// Small
        public static let sizeOptionSmall = L10n.tr("Localizable", "settings.messages.thumbnails.size_option_small")
      }
    }
    public enum Notifications {
      public enum Action {
        /// Show a badge on the Dock icon
        public static let badgeToggle = L10n.tr("Localizable", "settings.notifications.action.badge_toggle")
        /// Pop a banner
        public static let bannerToggle = L10n.tr("Localizable", "settings.notifications.action.banner_toggle")
        /// When notified:
        public static let label = L10n.tr("Localizable", "settings.notifications.action.label")
        /// Play a sound
        public static let soundToggle = L10n.tr("Localizable", "settings.notifications.action.sound_toggle")
      }
      public enum Handover {
        /// Mobile alerts:
        public static let label = L10n.tr("Localizable", "settings.notifications.handover.label")
        public enum ForwardMobile {
          /// 5 minutes
          public static let afterOptionFiveMinutes = L10n.tr("Localizable", "settings.notifications.handover.forward_mobile.after_option_five_minutes")
          /// A minute
          public static let afterOptionOneMinute = L10n.tr("Localizable", "settings.notifications.handover.forward_mobile.after_option_one_minute")
          /// 10 minutes
          public static let afterOptionTenMinutes = L10n.tr("Localizable", "settings.notifications.handover.forward_mobile.after_option_ten_minutes")
          /// Forward to mobile if inactive after time on desktop:
          public static let toggle = L10n.tr("Localizable", "settings.notifications.handover.forward_mobile.toggle")
        }
      }
      public enum NotifyGovernor {
        /// Notify me about:
        public static let label = L10n.tr("Localizable", "settings.notifications.notify_governor.label")
        /// All messages
        public static let optionAll = L10n.tr("Localizable", "settings.notifications.notify_governor.option_all")
        /// Private messages
        public static let optionDirect = L10n.tr("Localizable", "settings.notifications.notify_governor.option_direct")
        /// Nothing
        public static let optionNone = L10n.tr("Localizable", "settings.notifications.notify_governor.option_none")
      }
      public enum NotifyOnReply {
        /// Let me know when I receive a message reply
        public static let toggle = L10n.tr("Localizable", "settings.notifications.notify_on_reply.toggle")
      }
      public enum Schedule {
        /// Get notified:
        public static let label = L10n.tr("Localizable", "settings.notifications.schedule.label")
        /// Evening
        public static let timeOptionEvening = L10n.tr("Localizable", "settings.notifications.schedule.time_option_evening")
        /// Morning
        public static let timeOptionMorning = L10n.tr("Localizable", "settings.notifications.schedule.time_option_morning")
        /// to
        public static let timeSeparator = L10n.tr("Localizable", "settings.notifications.schedule.time_separator")
        public enum Days {
          /// Anytime
          public static let optionAnytime = L10n.tr("Localizable", "settings.notifications.schedule.days.option_anytime")
          /// On weekdays
          public static let optionWeekdays = L10n.tr("Localizable", "settings.notifications.schedule.days.option_weekdays")
          /// On weekends
          public static let optionWeekends = L10n.tr("Localizable", "settings.notifications.schedule.days.option_weekends")
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
    /// Add a group
    public static let groupsAdd = L10n.tr("Localizable", "sidebar.groups_add")
    /// Add a contact
    public static let otherContactsAdd = L10n.tr("Localizable", "sidebar.other_contacts_add")
    /// Add a member
    public static let teamMembersAdd = L10n.tr("Localizable", "sidebar.team_members_add")
    public enum Section {
      /// Favorites
      public static let favorites = L10n.tr("Localizable", "sidebar.section.favorites")
      /// Groups
      public static let groups = L10n.tr("Localizable", "sidebar.section.groups")
      /// Other contacts
      public static let otherContacts = L10n.tr("Localizable", "sidebar.section.other_contacts")
      /// Spotlight
      public static let spotlight = L10n.tr("Localizable", "sidebar.section.spotlight")
      /// Team members
      public static let teamMembers = L10n.tr("Localizable", "sidebar.section.team_members")
    }
    public enum Spotlight {
      /// Direct messages
      public static let directMessages = L10n.tr("Localizable", "sidebar.spotlight.direct_messages")
      /// People & groups
      public static let peopleAndGroups = L10n.tr("Localizable", "sidebar.spotlight.people_and_groups")
      /// Replies
      public static let replies = L10n.tr("Localizable", "sidebar.spotlight.replies")
      /// Unread stack
      public static let unreadStack = L10n.tr("Localizable", "sidebar.spotlight.unread_stack")
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
