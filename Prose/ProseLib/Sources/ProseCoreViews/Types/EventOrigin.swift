//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import Foundation

public struct Point: Equatable, Decodable {
  public let x, y: Double
  public var cgPoint: CGPoint { CGPoint(x: self.x, y: self.y) }
}

public struct Frame: Equatable, Decodable {
  public let x, y, width, height: Double
  public var cgRect: CGRect { CGRect(x: self.x, y: self.y, width: self.width, height: self.height) }
}

public struct EventOrigin: Equatable, Decodable {
  public let anchor: Point
  public let parent: Frame?
  public var cgRect: CGRect {
    self.parent?.cgRect ?? CGRect(origin: self.anchor.cgPoint, size: .zero)
  }
}
