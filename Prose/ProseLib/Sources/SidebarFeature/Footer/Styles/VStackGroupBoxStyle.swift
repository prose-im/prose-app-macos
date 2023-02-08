import SwiftUI

struct VStackGroupBoxStyle: GroupBoxStyle {
  let alignment: HorizontalAlignment
  let spacing: CGFloat?

  func makeBody(configuration: Configuration) -> some View {
    VStack(alignment: self.alignment, spacing: self.spacing) { configuration.content }
  }
}
