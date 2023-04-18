//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppLocalization
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

struct CallsTab: View {
  @State var videoInputStreamPath: String = "webcam-valerian"

  @State private var audioInputLevel: Double = 0.6

  @AppStorage(
    "settings.calls.videoInputDefault"
  ) var videoInputDefault: CallsSettingsVideoInputDefault =
    .system
  @AppStorage(
    "settings.calls.audioInputDefault"
  ) var audioInputDefault: CallsSettingsAudioInputDefault =
    .system
  @AppStorage(
    "settings.calls.audioOutputDefault"
  ) var audioOutputDefault: CallsSettingsAudioOutputDefault =
    .system

  var body: some View {
    VStack(spacing: 24) {
      VStack {
        // "Camera tester"
        GroupBox(l10n.VideoInput.testerLabel) {
          VideoPreviewView(
            streamPath: self.videoInputStreamPath,
            sizeWidth: 260.0,
            sizeHeight: 180.0
          )
        }

        // "Default video input"
        GroupBox(l10n.VideoInput.defaultLabel) {
          Picker("", selection: self.$videoInputDefault) {
            ForEach(CallsSettingsVideoInputDefault.allCases, id: \.self) { value in
              Text(value.localizedDescription)
                .tag(value)
            }
          }
          .labelsHidden()
          .frame(width: SettingsConstants.selectLargeWidth)
        }
      }

      Divider()

      VStack {
        // "Microphone tester"
        GroupBox(l10n.AudioInput.testerLabel) {
          LevelIndicator(
            currentValue: self.audioInputLevel,
            tickMarkFactor: 8.0
          )
          .frame(width: SettingsConstants.selectLargeWidth)
        }

        // "Default audio input"
        GroupBox(l10n.AudioInput.defaultLabel) {
          Picker("", selection: self.$audioInputDefault) {
            ForEach(CallsSettingsAudioInputDefault.allCases, id: \.self) { value in
              Text(value.localizedDescription)
                .tag(value)
            }
          }
          .labelsHidden()
          .frame(width: SettingsConstants.selectLargeWidth)
        }
      }

      Divider()

      VStack {
        // "Speakers tester"
        GroupBox(l10n.AudioOutput.testerLabel) {
          Button(action: {}) {
            Text(l10n.AudioOutput.testerButton)
          }
        }

        // "Default audio output"
        GroupBox(l10n.AudioOutput.defaultLabel) {
          Picker("", selection: self.$audioOutputDefault) {
            ForEach(CallsSettingsAudioOutputDefault.allCases, id: \.self) { value in
              Text(value.localizedDescription)
                .tag(value)
            }
          }
          .labelsHidden()
          .frame(width: SettingsConstants.selectLargeWidth)
        }
      }
    }
    .groupBoxStyle(FormGroupBoxStyle())
    .padding()
    .disabled(true)
  }
}

struct CallsTab_Previews: PreviewProvider {
  static var previews: some View {
    CallsTab()
  }
}
