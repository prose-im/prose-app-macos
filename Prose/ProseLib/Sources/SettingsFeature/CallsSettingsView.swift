//
//  CallsSettingsView.swift
//  Prose
//
//  Created by Valerian Saliou on 12/7/21.
//

import AppLocalization
import Preferences
import ProseUI
import SwiftUI

private let l10n = L10n.Settings.Calls.self

enum CallsSettingsVideoInputDefault: String, Equatable, CaseIterable {
    case system

    var localizedDescription: String {
        switch self {
        case .system:
            return l10n.VideoInput.defaultOptionSystem
        }
    }
}

enum CallsSettingsAudioInputDefault: String, Equatable, CaseIterable {
    case system

    var localizedDescription: String {
        switch self {
        case .system:
            return l10n.AudioInput.defaultOptionSystem
        }
    }
}

enum CallsSettingsAudioOutputDefault: String, Equatable, CaseIterable {
    case system

    var localizedDescription: String {
        switch self {
        case .system:
            return l10n.AudioOutput.defaultOptionSystem
        }
    }
}

struct CallsSettingsView: View {
    @State var videoInputStreamPath: String

    @State private var audioInputLevel: Double = 0.6

    @AppStorage("settings.calls.videoInputDefault") var videoInputDefault: CallsSettingsVideoInputDefault = .system
    @AppStorage("settings.calls.audioInputDefault") var audioInputDefault: CallsSettingsAudioInputDefault = .system
    @AppStorage("settings.calls.audioOutputDefault") var audioOutputDefault: CallsSettingsAudioOutputDefault = .system

    var body: some View {
        Preferences.Container(contentWidth: SettingsContants.contentWidth) {
            // "Camera tester"
            Preferences.Section(
                title: l10n.VideoInput.testerLabel,
                verticalAlignment: .center
            ) {
                SettingsPreviewVideoComponent(
                    streamPath: videoInputStreamPath,
                    sizeWidth: 260.0,
                    sizeHeight: 180.0
                )
            }

            // "Default video input"
            Preferences.Section(
                title: l10n.VideoInput.defaultLabel,
                bottomDivider: true,
                verticalAlignment: .center
            ) {
                Picker("", selection: $videoInputDefault) {
                    ForEach(CallsSettingsVideoInputDefault.allCases, id: \.self) { value in
                        Text(value.localizedDescription)
                            .tag(value)
                    }
                }
                .labelsHidden()
                .frame(width: SettingsContants.selectLargeWidth)
            }

            // "Microphone tester"
            Preferences.Section(
                title: l10n.AudioInput.testerLabel,
                verticalAlignment: .center
            ) {
                LevelIndicator(
                    currentValue: audioInputLevel,
                    tickMarkFactor: 8.0
                )
                .frame(width: SettingsContants.selectLargeWidth)
            }

            // "Default audio input"
            Preferences.Section(
                title: l10n.AudioInput.defaultLabel,
                bottomDivider: true,
                verticalAlignment: .center
            ) {
                Picker("", selection: $audioInputDefault) {
                    ForEach(CallsSettingsAudioInputDefault.allCases, id: \.self) { value in
                        Text(value.localizedDescription)
                            .tag(value)
                    }
                }
                .labelsHidden()
                .frame(width: SettingsContants.selectLargeWidth)
            }

            // "Speakers tester"
            Preferences.Section(
                title: l10n.AudioOutput.testerLabel,
                verticalAlignment: .center
            ) {
                Button(action: {}) {
                    Text(l10n.AudioOutput.testerButton)
                }
            }

            // "Default audio output"
            Preferences.Section(
                title: l10n.AudioOutput.defaultLabel,
                verticalAlignment: .center
            ) {
                Picker("", selection: $audioOutputDefault) {
                    ForEach(CallsSettingsAudioOutputDefault.allCases, id: \.self) { value in
                        Text(value.localizedDescription)
                            .tag(value)
                    }
                }
                .labelsHidden()
                .frame(width: SettingsContants.selectLargeWidth)
            }
        }
    }
}

struct CallsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        CallsSettingsView(
            videoInputStreamPath: "webcam-valerian"
        )
    }
}
