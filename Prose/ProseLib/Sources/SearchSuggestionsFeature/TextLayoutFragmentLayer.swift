//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

#if os(iOS)
  import UIKit
  private typealias Color = UIColor
#else
  import Cocoa
  private typealias Color = NSColor
#endif
import CoreGraphics

class TextLayoutFragmentLayer: CALayer {
  var layoutFragment: NSTextLayoutFragment!
  var padding: CGFloat
  var showLayerFrames: Bool

  let strokeWidth: CGFloat = 2

  override class func defaultAction(forKey _: String) -> CAAction? {
    // Suppress default opacity animations.
    NSNull()
  }

  func updateGeometry() {
    bounds = self.layoutFragment.renderingSurfaceBounds
    if self.showLayerFrames {
      var typographicBounds = self.layoutFragment.layoutFragmentFrame
      typographicBounds.origin = .zero
      bounds = bounds.union(typographicBounds)
    }
    // The (0, 0) point in layer space should be the anchor point.
    anchorPoint = CGPoint(
      x: -bounds.origin.x / bounds.size.width,
      y: -bounds.origin.y / bounds.size.height
    )
    position = self.layoutFragment.layoutFragmentFrame.origin
    position.x += self.padding
  }

  init(layoutFragment: NSTextLayoutFragment, padding: CGFloat) {
    self.layoutFragment = layoutFragment
    self.padding = padding
    self.showLayerFrames = false
    super.init()
    contentsScale = 2
    self.updateGeometry()
    setNeedsDisplay()
  }

  override init(layer: Any) {
    let tlfLayer = layer as! TextLayoutFragmentLayer
    self.layoutFragment = tlfLayer.layoutFragment
    self.padding = tlfLayer.padding
    self.showLayerFrames = tlfLayer.showLayerFrames
    super.init(layer: layer)
    self.updateGeometry()
    setNeedsDisplay()
  }

  required init?(coder: NSCoder) {
    self.layoutFragment = nil
    self.padding = 0
    self.showLayerFrames = false
    super.init(coder: coder)
  }

  override func draw(in ctx: CGContext) {
    self.layoutFragment.draw(at: .zero, in: ctx)
    if self.showLayerFrames {
      let inset = 0.5 * self.strokeWidth
      // Draw rendering surface bounds.
      ctx.setLineWidth(self.strokeWidth)
      ctx.setStrokeColor(self.renderingSurfaceBoundsStrokeColor.cgColor)
      ctx.setLineDash(phase: 0, lengths: []) // Solid line.
      ctx.stroke(self.layoutFragment.renderingSurfaceBounds.insetBy(dx: inset, dy: inset))

      // Draw typographic bounds.
      ctx.setStrokeColor(self.typographicBoundsStrokeColor.cgColor)
      ctx.setLineDash(phase: 0, lengths: [self.strokeWidth, self.strokeWidth]) // Square dashes.
      var typographicBounds = self.layoutFragment.layoutFragmentFrame
      typographicBounds.origin = .zero
      ctx.stroke(typographicBounds.insetBy(dx: inset, dy: inset))
    }
  }

  private var renderingSurfaceBoundsStrokeColor: Color { .systemOrange }
  private var typographicBoundsStrokeColor: Color { .systemPurple }
}
