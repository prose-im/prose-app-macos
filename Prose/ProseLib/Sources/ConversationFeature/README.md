Mind you that SwiftUI's `onAppear` hooks will not be called when a different conversation is
selected. SwiftUI is reusing the `ConversationScreen` so we have to call it ourselves. For this
reason you'll see reducers send .onAppear and .onDisappear to their child reducers, e.g. in
`ConversationScreenReducer`…

```swift
case .onAppear:
  return .merge(
    // …
    MessageBarReducer().reduce(into: &state.messageBar, action: .onAppear)
      .map(Action.messageBar)
  )
```

`MainScreenReducer` is responsible for initiating this mechanism.

Let's have a uniform symmetry here and send .onAppear to child reducers last and send .onDisappear
first.
