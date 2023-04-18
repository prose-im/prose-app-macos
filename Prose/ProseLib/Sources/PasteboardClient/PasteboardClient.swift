//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import ComposableArchitecture
import Foundation

public struct PasteboardClient {
  public var copyString: (String) -> Void

  public init(copyString: @escaping (String) -> Void) {
    self.copyString = copyString
  }
}

public extension DependencyValues {
  var pasteboardClient: PasteboardClient {
    get { self[PasteboardClient.self] }
    set { self[PasteboardClient.self] = newValue }
  }
}

extension PasteboardClient: TestDependencyKey {
  public static var testValue = PasteboardClient(
    copyString: unimplemented("\(Self.self).copyString")
  )
}
