//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import SwiftUI
#if os(macOS)
  import AppKit
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit
#endif

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum Colors {
  public enum Background {
    public static let message = ColorAsset(name: "background/message")
  }

  public enum Border {
    public static let primary = ColorAsset(name: "border/primary")
    public static let secondary = ColorAsset(name: "border/secondary")
    public static let tertiary = ColorAsset(name: "border/tertiary")
    public static let tertiaryLight = ColorAsset(name: "border/tertiaryLight")
  }

  public enum State {
    public static let green = ColorAsset(name: "state/green")
    public static let greenLight = ColorAsset(name: "state/greenLight")
    public static let grey = ColorAsset(name: "state/grey")
    public static let greyLight = ColorAsset(name: "state/greyLight")
  }

  public enum Text {
    public static let primary = ColorAsset(name: "text/primary")
    public static let primaryLight = ColorAsset(name: "text/primaryLight")
    public static let secondary = ColorAsset(name: "text/secondary")
    public static let secondaryLight = ColorAsset(name: "text/secondaryLight")
  }
}

// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

private let bundle = Bundle.fixedModule

public final class ColorAsset {
  public fileprivate(set) var name: String

  #if os(macOS)
    fileprivate typealias _Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
    fileprivate typealias _Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  public private(set) lazy var color = SwiftUI.Color(self.name, bundle: bundle)

  fileprivate init(name: String) {
    self.name = name
  }
}

public extension ColorAsset {
  #if os(macOS)
    @available(macOS 10.13, *)
    var nsColor: NSColor? {
      guard let color = _Color(asset: self) else {
        fatalError("Unable to load color asset named \(name).")
      }
      return color
    }

  #elseif os(iOS) || os(tvOS) || os(watchOS)
    @available(iOS 11.0, tvOS 11.0, watchOS 4.0, *)
    var uiColor: UIColor {
      guard let color = _Color(asset: self) else {
        fatalError("Unable to load color asset named \(self.name).")
      }
      return color
    }
  #endif

  #if os(iOS) || os(tvOS)
    @available(iOS 11.0, tvOS 11.0, *)
    func uiColor(compatibleWith traitCollection: UITraitCollection) -> UIColor {
      let bundle = Bundle.fixedModule
      guard let color = UIColor(named: name, in: bundle, compatibleWith: traitCollection) else {
        fatalError("Unable to load color asset named \(self.name).")
      }
      return color
    }
  #endif
}

private extension ColorAsset._Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    #if os(iOS) || os(tvOS)
      self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
      self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
      self.init(named: asset.name)
    #endif
  }
}
