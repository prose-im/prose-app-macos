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

private let l10n = L10n.AddMember.self

// MARK: - View

public struct AddMemberSheet: View {
  public typealias ViewState = AddMemberSheetState
  public typealias ViewAction = AddMemberSheetAction

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
              Label(l10n.InviteAction.label, systemImage: "link.circle.fill")
            } else {
              Label(l10n.SendRequestAction.label, systemImage: "person.crop.circle.fill.badge.plus")
            }
          }
          .buttonStyle(.borderedProminent)
          .disabled(!viewStore.isSubmitButtonEnabled)
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
        icon: "person.crop.circle.badge.questionmark",
        label: l10n.State.Unknown.label,
        secondaryLabel: l10n.State.Unknown.sublabel,
        color: .orange
      )
    case let .existing(name):
      self.infoMessage(
        icon: "person.crop.circle.badge.checkmark",
        label: l10n.State.Existing.label(name),
        secondaryLabel: l10n.State.Existing.sublabel(name),
        color: Colors.State.green.color
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

public let addMemberReducer = Reducer<
  AddMemberSheetState,
  AddMemberSheetAction,
  AddMemberSheetEnvironment
> { state, action, environment in
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
    case let text where text.contains("@") && text.contains("."):
      state.info = .existing("Firstname Lastname")
    default:
      state.info = .invalid
    }

    return .none

  case .binding(\.$text):
    struct Token: Hashable {}
    return Effect(value: .didUpdateText(state.text))
      .debounce(id: Token(), for: 0.5, scheduler: environment.mainQueue)
      .eraseToEffect()

  default:
    return .none
  }
}.binding()

// MARK: State

public struct AddMemberSheetState: Equatable {
  enum InfoMessage: Equatable {
    case none
    case invalid
    case unknown
    case existing(String)
  }

  var info: InfoMessage = .none
  var isProcessing: Bool = false

  @BindableState var text: String

  var isFormValid: Bool {
    switch self.info {
    case .existing, .unknown:
      return true
    case .none, .invalid:
      return false
    }
  }

  var isSubmitButtonEnabled: Bool {
    self.isFormValid && !self.isProcessing
  }

  init(
    text: String,
    info: InfoMessage = .none,
    isProcessing: Bool = false
  ) {
    self.text = text
    self.info = info
    self.isProcessing = isProcessing
  }

  public init(text: String = "") {
    self.text = text
  }
}

// MARK: Actions

public enum AddMemberSheetAction: Equatable, BindableAction {
  case didUpdateText(String), didCheckText(String)
  case cancelTapped, submitTapped
  case binding(BindingAction<AddMemberSheetState>)
}

// MARK: Environment

public struct AddMemberSheetEnvironment {
  var mainQueue: AnySchedulerOf<DispatchQueue>

  public init(
    mainQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.mainQueue = mainQueue
  }
}

public extension AddMemberSheetEnvironment {
  static func live(
    mainQueue: AnySchedulerOf<DispatchQueue> = .main
  ) -> AddMemberSheetEnvironment {
    AddMemberSheetEnvironment(
      mainQueue: mainQueue
    )
  }
}

// MARK: - Previews

struct AddMemberSheet_Previews: PreviewProvider {
  static func preview(_ initialState: AddMemberSheetState = .init()) -> some View {
    AddMemberSheet(store: Store(
      initialState: initialState,
      reducer: addMemberReducer,
      environment: .live()
    ))
  }

  static var previews: some View {
    preview()
      .previewDisplayName("Base")
    preview(.init(text: "remi@prose.org", info: .existing("Rémi Bardon")))
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
