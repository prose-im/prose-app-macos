// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
    import AppKit
#elseif os(iOS)
    import UIKit
#elseif os(tvOS) || os(watchOS)
    import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
public typealias AssetColorTypeAlias = ColorAsset.Color

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum Asset {
    public enum Color {
        public enum Background {
            public static let message = ColorAsset(name: "color/background/message")
        }

        public enum Border {
            public static let primary = ColorAsset(name: "color/border/primary")
            public static let secondary = ColorAsset(name: "color/border/secondary")
            public static let tertiary = ColorAsset(name: "color/border/tertiary")
            public static let tertiaryLight = ColorAsset(name: "color/border/tertiaryLight")
        }

        public enum Button {
            public static let actionGradientFromText = ColorAsset(name: "color/button/actionGradientFromText")
            public static let actionGradientToText = ColorAsset(name: "color/button/actionGradientToText")
            public static let actionShadow = ColorAsset(name: "color/button/actionShadow")
            public static let actionText = ColorAsset(name: "color/button/actionText")
            public static let primary = ColorAsset(name: "color/button/primary")
        }

        public enum State {
            public static let blue = ColorAsset(name: "color/state/blue")
            public static let green = ColorAsset(name: "color/state/green")
            public static let greenLight = ColorAsset(name: "color/state/greenLight")
            public static let grey = ColorAsset(name: "color/state/grey")
            public static let greyLight = ColorAsset(name: "color/state/greyLight")
        }

        public enum Text {
            public static let primary = ColorAsset(name: "color/text/primary")
            public static let primaryLight = ColorAsset(name: "color/text/primaryLight")
            public static let secondary = ColorAsset(name: "color/text/secondary")
            public static let secondaryLight = ColorAsset(name: "color/text/secondaryLight")
        }
    }
}

// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public final class ColorAsset {
    public fileprivate(set) var name: String

    #if os(macOS)
        public typealias Color = NSColor
    #elseif os(iOS) || os(tvOS) || os(watchOS)
        public typealias Color = UIColor
    #endif

    @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
    public private(set) lazy var color: Color = {
        guard let color = Color(asset: self) else {
            fatalError("Unable to load color asset named \(name).")
        }
        return color
    }()

    #if os(iOS) || os(tvOS)
        @available(iOS 11.0, tvOS 11.0, *)
        public func color(compatibleWith traitCollection: UITraitCollection) -> Color {
            let bundle = Bundle.fixedModule
            guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
                fatalError("Unable to load color asset named \(self.name).")
            }
            return color
        }
    #endif

    fileprivate init(name: String) {
        self.name = name
    }
}

public extension ColorAsset.Color {
    @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
    convenience init?(asset: ColorAsset) {
        let bundle = Bundle.fixedModule
        #if os(iOS) || os(tvOS)
            self.init(named: asset.name, in: bundle, compatibleWith: nil)
        #elseif os(macOS)
            self.init(named: NSColor.Name(asset.name), bundle: bundle)
        #elseif os(watchOS)
            self.init(named: asset.name)
        #endif
    }
}
