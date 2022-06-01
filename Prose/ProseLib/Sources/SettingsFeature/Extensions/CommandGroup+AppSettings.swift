import Preferences
import SwiftUI

public struct AppSettings: Commands {
    public init() {}

    public var body: some Commands {
        CommandGroup(replacing: CommandGroupPlacement.appSettings) {
            Button("Preferences...") {
                PreferencesWindowController(
                    preferencePanes: [
                        GeneralSettingsViewController(),
                        AccountsSettingsViewController(),
                        NotificationsSettingsViewController(),
                        MessagesSettingsViewController(),
                        CallsSettingsViewController(),
                        AdvancedSettingsViewController(),
                    ],

                    style: .toolbarItems,
                    animated: true,
                    hidesToolbarForSingleItem: true
                ).show()
            }
            .keyboardShortcut(KeyEquivalent(","), modifiers: .command)
        }
    }
}
