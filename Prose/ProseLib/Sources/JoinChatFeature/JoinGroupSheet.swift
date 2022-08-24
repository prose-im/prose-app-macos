//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import Assets
import ComposableArchitecture
import ProseCoreTCA
import ProseUI
import SwiftUI

private let l10n = L10n.JoinGroup.self

// MARK: - View

public struct JoinGroupSheet: View {
  public typealias ViewState = JoinGroupSheetState
  public typealias ViewAction = JoinGroupSheetAction

  let store: Store<ViewState, ViewAction>

  public init(store: Store<ViewState, ViewAction>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack(spacing: 16) {
        VStack(alignment: .leading) {
          Text(verbatim: l10n.Header.title)
            .font(.headline)
          Text(verbatim: l10n.Header.subtitle)
            .font(.subheadline)
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
        // TODO: [Rémi Bardon] Refactor `BasicAuthView.chatAddressHelpButton` so we can add the button here too.
        // TODO: [Rémi Bardon] Maybe we could even create a `JIDField`, which supports all of this out of the box.
        TextField(
          l10n.TextField.label,
          text: viewStore.binding(\.$text),
          prompt: Text(verbatim: l10n.TextField.prompt)
        )
        .textFieldStyle(.roundedBorder)
        .onSubmit(of: .text) { viewStore.send(.submitTapped) }
        .frame(maxWidth: .infinity, alignment: .leading)
        Self.infoMessage(for: viewStore.info)
          .symbolVariant(.fill)
          .fixedSize(horizontal: false, vertical: true)
        HStack {
          if viewStore.isProcessing {
            ProgressView()
              .scaleEffect(0.5, anchor: .center)
          }
          Button { viewStore.send(.cancelTapped) } label: {
            Text(verbatim: l10n.CancelAction.label)
          }
          .buttonStyle(.bordered)
          Button { viewStore.send(.submitTapped) } label: {
            if case .unknown = viewStore.info {
              Label(l10n.CreateGroupAction.label, systemImage: "rectangle.stack.badge.plus")
            } else {
              Label(l10n.JoinGroupAction.label, systemImage: "rectangle.stack.badge.person.crop")
            }
          }
          .buttonStyle(.borderedProminent)
          .disabled(!viewStore.isFormValid)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
      }
      .controlSize(.large)
      .padding(24)
      .frame(width: 360)
    }
  }

  @ViewBuilder
  static func infoMessage(for info: ViewState.InfoMessage) -> some View {
    switch info {
    case .none, .invalid:
      EmptyView()
    case .unknown:
      self.infoMessage(
        icon: "questionmark.circle",
        label: l10n.State.Unknown.label,
        secondaryLabel: l10n.State.Unknown.sublabel,
        color: .orange
      )
    case let .existing(peopleCount):
      self.infoMessage(
        icon: "bolt.circle",
        label: l10n.State.Existing.label,
        secondaryLabel: l10n.State.Existing.sublabel(peopleCount),
        color: .blue
      )
    }
  }

  static func infoMessage(
    icon: String,
    label: String,
    secondaryLabel: String? = nil,
    color: Color?
  ) -> some View {
    Label {
      VStack(alignment: .leading) {
        Text(label.asMarkdown)
        secondaryLabel.map { Text($0.asMarkdown) }
          .foregroundColor(.secondary)
      }
    } icon: {
      Image(systemName: icon)
    }
    .foregroundColor(color)
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let joinGroupReducer = Reducer<
  JoinGroupSheetState,
  JoinGroupSheetAction,
  JoinGroupSheetEnvironment
>.empty.binding()

// MARK: State

public struct JoinGroupSheetState: Equatable {
  public enum InfoMessage: Equatable {
    case none
    case invalid
    case unknown
    case existing(Int)
  }

  var info: InfoMessage
  var isProcessing: Bool

  @BindableState var text: String

  var isFormValid: Bool {
    switch self.info {
    case .existing, .unknown:
      return true
    default:
      return false
    }
  }

  public init(
    text: String = "",
    info: InfoMessage = .none,
    isProcessing: Bool = false
  ) {
    self.text = text
    self.info = info
    self.isProcessing = isProcessing
  }
}

// MARK: Actions

public enum JoinGroupSheetAction: Equatable, BindableAction {
  case didUpdateText(String), didCheckText(String)
  case cancelTapped, submitTapped
  case binding(BindingAction<JoinGroupSheetState>)
}

// MARK: Environment

public struct JoinGroupSheetEnvironment {
  var mainQueue: AnySchedulerOf<DispatchQueue>

  public init(
    mainQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.mainQueue = mainQueue
  }
}

public extension JoinGroupSheetEnvironment {
  static func live(
    mainQueue: AnySchedulerOf<DispatchQueue> = .main
  ) -> JoinGroupSheetEnvironment {
    JoinGroupSheetEnvironment(
      mainQueue: mainQueue
    )
  }
}

#if DEBUG

  // MARK: - Previews

  struct JoinGroupSheet_Previews: PreviewProvider {
    static func preview(_ initialState: JoinGroupSheetState = .init()) -> some View {
      JoinGroupSheet(store: Store(
        initialState: initialState,
        reducer: joinGroupReducer.combined(
          with:
          Reducer { state, action, environment in
            switch action {
            case let .didUpdateText(text):
              state.isProcessing = true
              return Effect(value: .didCheckText(text))
                .delay(for: 0.5, scheduler: environment.mainQueue)
                .eraseToEffect()

            case let .didCheckText(text):
              state.isProcessing = false

              switch text {
              case "":
                state.info = .none
              case "invalid":
                state.info = .invalid
              case "unknown@prose.org":
                state.info = .unknown
              case let text where text.hasSuffix("."):
                state.info = .invalid
              case let text
                where text.contains("@") && text.contains("."):
                state.info = .existing(4)
              default:
                state.info = .invalid
              }

              return .none

            case .binding(\.$text):
              struct Token: Hashable {}
              return Effect(value: .didUpdateText(state.text))
                .debounce(
                  id: Token(),
                  for: 0.5,
                  scheduler: environment.mainQueue
                )
                .eraseToEffect()

            default:
              return .none
            }
          }
        ),
        environment: .live()
      ))
    }

    static var previews: some View {
      preview()
        .previewDisplayName("Base")
      preview(.init(text: "remi@prose.org", info: .existing(4)))
        .previewDisplayName("Success")
      preview(.init(text: "someone@prose.org", info: .unknown))
        .previewDisplayName("Unknown")
      preview(.init(text: "remi@notfinished", info: .invalid))
        .previewDisplayName("Not finished")
      preview(.init(text: "remi@prose.org", info: .none, isProcessing: true))
        .previewDisplayName("Processing")
      Text("Preview")
        .frame(width: 480, height: 360)
        .sheet(isPresented: .constant(true)) { preview() }
        .previewDisplayName("Sheet")
    }
  }
#endif
