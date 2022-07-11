//
//  IdentityPopover.swift
//  
//
//  Created by Rémi Bardon on 11/07/2022.
//

import AppLocalization
import Assets
import ProseUI
import SwiftUI

struct IdentityPopover: View {
    var body: some View {
      VStack(alignment: .leading, spacing: 0) {
        HStack {
          ZStack {
            Circle().fill(Colors.State.green.color)
              .frame(width: 32, height: 32)
            Image(systemName: "checkmark.seal.fill")
              .font(.system(size: 18))
          }
          VStack(alignment: .leading) {
            Text(verbatim: "Looks like this is the real Valerian Saliou")
              .font(.headline)
            Text(verbatim: "Prose checked on the identity server for matches. It could verify this user.")
              .font(.subheadline)
              .foregroundColor(.secondary)
          }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        Divider()
        VStack(alignment: .customCenter, spacing: 8) {
          HStack {
            Label {
              Text(verbatim: "User signature fingerprint verified: C648A")
            } icon: {
              Image(systemName: "key")
                .foregroundColor(Colors.State.green.color)
            }
            HelpButton { Text("TODO").padding() }
          }
          HStack {
            Label {
              Text(verbatim: "Email verified: valerian@crisp.chat")
            } icon: {
              Image(systemName: "envelope")
                .foregroundColor(Colors.State.green.color)
            }
            HelpButton { Text("TODO").padding() }
          }
          HStack {
            Label {
              Text(verbatim: "Phone verified: +33631210280")
            } icon: {
              Image(systemName: "phone")
                .foregroundColor(Colors.State.green.color)
            }
            HelpButton { Text("TODO").padding() }
          }
          HStack {
            Label {
              Text(verbatim: "Government ID not verified (not provided yet)")
            } icon: {
              Image(systemName: "signature")
                .foregroundColor(.secondary)
            }
            HelpButton { Text("TODO").padding() }
          }
        }
        .labelStyle(MyLabelStyle())
        .symbolVariant(.fill)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(Color(nsColor: .windowBackgroundColor))
        Divider()
        Text("User data is verified on your configured identity server, which is [id.prose.org](id.prose.org).".asMarkdown)
          .padding(.horizontal, 24)
          .padding(.vertical, 12)
          .frame(maxWidth: .infinity, alignment: .leading)
          .font(.footnote)
      }
      .multilineTextAlignment(.leading)
      .frame(width: 480)
    }
}

struct MyLabelStyle: LabelStyle {
  func makeBody(configuration: Configuration) -> some View {
    HStack(spacing: 4) {
      configuration.icon
        .alignmentGuide(.customCenter) { $0[HorizontalAlignment.center] }
        .frame(width: 24)
      configuration.title
        .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

struct CustomCenter: AlignmentID {
  static func defaultValue(in context: ViewDimensions) -> CGFloat {
    context[HorizontalAlignment.center]
  }
}

extension HorizontalAlignment {
  static let customCenter: HorizontalAlignment = .init(CustomCenter.self)
}

struct IdentityPopover_Previews: PreviewProvider {
  struct Preview: View {
    @State private var isShowingPopover: Bool = true
    var body: some View {
      Button("Show popover") { self.isShowingPopover = true }
        .padding()
        .popover(isPresented: self.$isShowingPopover, content: IdentityPopover.init)
    }
  }
    static var previews: some View {
      IdentityPopover()
      Preview()
    }
}
