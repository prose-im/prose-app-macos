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

// MARK: - View

public struct AddMemberSheet: View {
  public typealias ViewState = AddMemberSheetState
  public typealias ViewAction = AddMemberSheetAction

  private let store: Store<ViewState, ViewAction>
  private var actions: ViewStore<Void, ViewAction> { ViewStore(self.store.stateless) }

  public init(store: Store<ViewState, ViewAction>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack(spacing: 16) {
        VStack(alignment: .leading) {
          Text(verbatim: "Add a new member")
            .font(.headline)
          Text(verbatim: "Add an existing chat address, or invite an email to join your team.")
            .font(.subheadline)
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
        // TODO: [Rémi Bardon] Refactor `BasicAuthView.chatAddressHelpButton` so we can add the button here too.
        // TODO: [Rémi Bardon] Maybe we could even create a `JIDField`, which supports all of this out of the box.
        TextField(
          "Text field",
          text: viewStore.binding(\.$text),
          prompt: Text("someone@domain.tld")
        )
        .textFieldStyle(.roundedBorder)
        .onSubmit(of: .text) { viewStore.send(.submitTapped) }
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .custom) {
          if !viewStore.suggestions.isEmpty {
//          ScrollView(.vertical) {
              VStack(alignment: .leading) {
                ForEach(viewStore.suggestions, id: \.self) { suggestion in
                  Button { print("\(suggestion) tapped") } label: {
                    HStack(spacing: 4) {
                      Avatar(.placeholder, size: 16)
                      Text(verbatim: suggestion)
                    }
                  }
                }
              }
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(8)
//          }
            .buttonStyle(.plain)
            .frame(maxHeight: 256)
            .background(Material.regular, in: RoundedRectangle(cornerRadius: 8))
            // Apply the shadow to the whole view, not every child view
            .compositingGroup()
            .shadow(radius: 1, y: 1)
            // Offset a bit to avoid the text field outline
            .alignmentGuide(.custom) { $0[VerticalAlignment.top] - 3 }
          }
        }
        .zIndex(1)
        Self.infoMessage(for: viewStore.info)
          .symbolVariant(.fill)
          .fixedSize(horizontal: false, vertical: true)
          .redacted(reason: viewStore.isProcessing ? .placeholder : [])
        HStack {
          Button { viewStore.send(.cancelTapped) } label: {
            Text("Cancel")
          }
          .buttonStyle(.bordered)
          Button { viewStore.send(.submitTapped) } label: {
            if case .unknown = viewStore.info {
              Label("Invite", systemImage: "link.circle.fill")
            } else {
              Label("Send Request", systemImage: "person.crop.circle.fill.badge.plus")
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
        icon: "person.crop.circle.badge.questionmark",
        label: "This chat address doesn't exist yet.",
        secondaryLabel: "You can invite this person to join your team.",
        color: .orange
      )
    case let .existing(name):
      self.infoMessage(
        icon: "person.crop.circle.badge.checkmark",
        label: "A contact request will be sent to **\(name)**.",
        secondaryLabel: "Once **\(name)** accepts your request, you will be able to chat and call.",
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

extension VerticalAlignment {
  struct CustomAlignment: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
      return context[VerticalAlignment.bottom]
    }
  }

  static let custom = VerticalAlignment(CustomAlignment.self)
}

extension Alignment {
  static let custom = Alignment(horizontal: .center, vertical: .custom)
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
    state.suggestions = ["Valerian Saliou – valerian@prose.org"]
//    "Marc Bauer – marc@prose.org"
//    "Rémi Bardon – remi@prose.org"
//    "The other Valerian – nairelav@prose.org"
//    "The other Marc – cram@prose.org"
//    "The other Rémi – imer@prose.org"

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
  public enum InfoMessage: Equatable {
    case none
    case invalid
    case unknown
    case existing(String)
  }

  var info: InfoMessage
  var isProcessing: Bool

  var suggestions: [String]

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
    isProcessing: Bool = false,
    suggestions: [String] = ["Valerian Saliou – valerian@prose.org"]
  ) {
    self.text = text
    self.info = info
    self.isProcessing = isProcessing
    self.suggestions = suggestions
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
    preview(.init(text: "remi@prose.org", info: .invalid, isProcessing: true))
      .previewDisplayName("Processing")
    Text("Preview")
      .frame(width: 480, height: 360)
      .sheet(isPresented: .constant(true)) { preview() }
      .previewDisplayName("Sheet")
  }
}
