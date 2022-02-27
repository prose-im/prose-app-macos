//
//  CallsSettingsView.swift
//  Prose
//
//  Created by Valerian Saliou on 12/7/21.
//

import SwiftUI
import Preferences

enum CallsSettingsVideoInputDefault: String, Equatable, CaseIterable {
    case system = "settings_calls_video_input_default_option_system"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

enum CallsSettingsAudioInputDefault: String, Equatable, CaseIterable {
    case system = "settings_calls_audio_input_default_option_system"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

enum CallsSettingsAudioOutputDefault: String, Equatable, CaseIterable {
    case system = "settings_calls_audio_output_default_option_system"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
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
                title: "settings_calls_video_input_tester_label".localized(),
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
                title: "settings_calls_video_input_default_label".localized(),
                bottomDivider: true,
                verticalAlignment: .center
            ) {
                Picker("", selection: $videoInputDefault) {
                    ForEach(CallsSettingsVideoInputDefault.allCases, id: \.self) { value in
                        Text(value.localizedName)
                            .tag(value)
                    }
                }
                .labelsHidden()
                .frame(width: SettingsContants.selectLargeWidth)
            }
            
            // "Microphone tester"
            Preferences.Section(
                title: "settings_calls_audio_input_tester_label".localized(),
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
                title: "settings_calls_audio_input_default_label".localized(),
                bottomDivider: true,
                verticalAlignment: .center
            ) {
                Picker("", selection: $audioInputDefault) {
                    ForEach(CallsSettingsAudioInputDefault.allCases, id: \.self) { value in
                        Text(value.localizedName)
                            .tag(value)
                    }
                }
                .labelsHidden()
                .frame(width: SettingsContants.selectLargeWidth)
            }
            
            // "Speakers tester"
            Preferences.Section(
                title: "settings_calls_audio_output_tester_label".localized(),
                verticalAlignment: .center
            ) {
                Button(action: {}) {
                    Text("settings_calls_audio_output_tester_button".localized())
                }
            }
            
            // "Default audio output"
            Preferences.Section(
                title: "settings_calls_audio_output_default_label".localized(),
                verticalAlignment: .center
            ) {
                Picker("", selection: $audioOutputDefault) {
                    ForEach(CallsSettingsAudioOutputDefault.allCases, id: \.self) { value in
                        Text(value.localizedName)
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
