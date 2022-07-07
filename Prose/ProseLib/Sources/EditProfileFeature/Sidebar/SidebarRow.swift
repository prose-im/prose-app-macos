//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import SwiftUI

struct SidebarRow: View {
  let icon: String
  let headline: String
  let subheadline: String
  var isSelected: Bool = false
  let action: () -> Void

  @State var isHovered: Bool = false

  var body: some View {
    Button(action: action, label: content)
      .buttonStyle(.plain)
      .onHover {
        self.isHovered = $0
        // FIXME: Use TCA and in-flight effect cancellation to avoid running `NSCursor.pop()` if some other view is asking for `NSCursor.pointingHand.push()`.
        DispatchQueue.main.async {
          if self.isHovered {
            NSCursor.pointingHand.push()
          } else {
            NSCursor.pop()
          }
        }
      }
  }

  @ViewBuilder
  func content() -> some View {
    let foregroundColor: Color = self.isSelected ? .white : .primary
    let backgroundOpacity: CGFloat = {
      switch (self.isSelected, self.isHovered) {
      case (true, _): return 1
      case (false, true): return 0.125
      default: return 0
      }
    }()
    ZStack {
      RoundedRectangle(cornerRadius: 4)
        .fill(Color.blue)
        .opacity(backgroundOpacity)
      HStack {
        ZStack {
          Circle()
            .fill(isSelected ? Color.white : Color.blue)
          Image(systemName: icon)
        }
        .symbolVariant(.fill)
        .foregroundColor(isSelected ? Color.blue : Color.white)
        .frame(width: 24, height: 24)
        VStack(alignment: .leading, spacing: 0) {
          Text(verbatim: headline)
          Text(verbatim: subheadline)
            .font(.subheadline)
            .foregroundColor(foregroundColor.opacity(0.75))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        Image(systemName: "chevron.forward.circle.fill")
          .symbolVariant(.fill)
          .foregroundColor(isSelected ? .white : .primary)
          .opacity(isSelected || isHovered ? 1 : 0)
      }
      .font(.headline)
      .padding(.vertical, 4)
      .padding(.horizontal, 8)
    }
    .foregroundColor(foregroundColor)
  }
}

struct SidebarRow_Previews: PreviewProvider {
  struct Preview: View {
    @State private var selected: Int = 0
    var body: some View {
      VStack(alignment: .leading, spacing: 4) {
        SidebarRow(
          icon: "person.text.rectangle",
          headline: "Identity",
          subheadline: "Name, Phone, Email",
          isSelected: selected == 0
        ) {
          selected = 0
        }
        SidebarRow(
          icon: "lock",
          headline: "Authentication",
          subheadline: "Password, MFA",
          isSelected: selected == 1
        ) {
          selected = 1
        }
        SidebarRow(
          icon: "person",
          headline: "Profile",
          subheadline: "Job, Location",
          isSelected: selected == 2
        ) {
          selected = 2
        }
        SidebarRow(
          icon: "key",
          headline: "Encryption",
          subheadline: "Certificates, Keys",
          isSelected: selected == 3
        ) {
          selected = 3
        }
      }
      .padding()
      .fixedSize()
    }
  }

  static var previews: some View {
    Preview()
  }
}
