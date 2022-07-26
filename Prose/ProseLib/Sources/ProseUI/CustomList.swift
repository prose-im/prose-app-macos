//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import IdentifiedCollections
import SwiftUI

public struct CustomList<SelectionValue: Hashable, Content: View>: View {
  public typealias BaseContent<Element: Identifiable, Row: View> = ForEach<
    IdentifiedArrayOf<Element>,
    Element.ID,
    ModifiedContent<Row, CustomListRow<Element.ID>>
  >

  let content: Content
  let spacing, padding: CGFloat
  let isEmpty: Bool

  init(
    content: Content,
    isEmpty: Bool = false,
    spacing: CGFloat = 0,
    padding: CGFloat = 8
  ) {
    self.content = content
    self.spacing = spacing
    self.padding = padding
    self.isEmpty = isEmpty
  }

  public init<Element, Row>(
    _ elements: IdentifiedArrayOf<Element>,
    selection: Binding<SelectionValue?>,
    padding: CGFloat = 8,
    canDeselect: Bool = true,
    @ViewBuilder row: @escaping (Element) -> Row
  ) where SelectionValue == Element.ID,
    Content == BaseContent<Element, Row>
  {
    self.init(
      content: ForEach(elements) { element in
        row(element)
          .modifier(CustomListRow(id: element.id, selection: selection, canDeselect: canDeselect))
      },
      isEmpty: elements.isEmpty,
      padding: padding
    )
  }

  public init<Element, Row>(
    _ elements: IdentifiedArrayOf<Element>,
    selection: Binding<Set<SelectionValue>>,
    padding: CGFloat = 8,
    @ViewBuilder row: @escaping (Element) -> Row
  ) where SelectionValue == Element.ID,
    Content == ForEach<
      IdentifiedArrayOf<Element>,
      SelectionValue,
      ModifiedContent<Row, CustomListRow<SelectionValue>>
    >
  {
    self.init(
      content: ForEach(elements) { element in
        row(element)
          .modifier(CustomListRow(id: element.id, selection: selection, elements: elements))
      },
      isEmpty: elements.isEmpty,
      padding: padding
    )
  }

  public init<Section, Header, Element, Row>(
    _ sections: IdentifiedArrayOf<Section>,
    elements: KeyPath<Section, IdentifiedArrayOf<Element>>,
    selection: Binding<Set<SelectionValue>>,
    @ViewBuilder row: @escaping (Element) -> Row,
    @ViewBuilder header: @escaping (Section) -> Header
  ) where SelectionValue == Element.ID,
    Content == ForEach<
      IdentifiedArrayOf<Section>,
      Section.ID,
      CustomListSection<
        CustomListSectionHeader<Header>,
        SelectionValue,
        BaseContent<Element, Row>
      >
    >
  {
    self.init(
      content: ForEach(sections, id: sections.id) { section in
        CustomListSection(
          header: CustomListSectionHeader {
            header(section)
          },
          content: CustomList<SelectionValue, BaseContent<Element, Row>>(
            section[keyPath: elements],
            selection: selection,
            padding: 0,
            row: row
          )
        )
      },
      spacing: 16
    )
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: self.spacing) {
      self.content
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, self.padding)
  }
}

public struct CustomListRow<ID: Hashable>: ViewModifier {
  let id: ID
  fileprivate let modifier: Selected
  let toggleSelection: () -> Void

  fileprivate init(
    id: ID,
    isSelected: Bool,
    modifier: Selected,
    select: @escaping () -> Void,
    deselect: @escaping () -> Void
  ) {
    self.id = id
    self.modifier = modifier
    self.toggleSelection = isSelected ? deselect : select
  }

  init(id: ID, selection: Binding<ID?>, canDeselect: Bool = true) {
    let isSelected: Bool = selection.wrappedValue == id
    self.init(
      id: id,
      isSelected: isSelected,
      modifier: Selected(isSelected),
      select: { selection.wrappedValue = id },
      deselect: {
        if canDeselect {
          selection.wrappedValue = nil
        }
      }
    )
  }

  init<Element: Identifiable>(
    id: ID,
    selection: Binding<Set<ID>>,
    elements: IdentifiedArrayOf<Element>
  ) where Element.ID == ID {
    let isSelected: Bool = selection.wrappedValue.contains(id)
    guard let index: Int = elements.index(id: id) else {
      fatalError()
    }
    let isPreviousSelected: Bool = index > elements.ids.startIndex
      && selection.wrappedValue.contains(elements.ids[index - 1])
    let isNextSelected: Bool = index < elements.ids.endIndex - 1
      && selection.wrappedValue.contains(elements.ids[index + 1])

    self.init(
      id: id,
      isSelected: isSelected,
      modifier: Selected(
        isSelected,
        isPreviousSelected: isPreviousSelected,
        isNextSelected: isNextSelected
      ),
      select: { selection.wrappedValue.insert(id) },
      deselect: { selection.wrappedValue.remove(id) }
    )
  }

  public func body(content: Content) -> some View {
    content
      .tag(self.id)
      .modifier(self.modifier)
      .padding(.horizontal, 8)
      .contentShape(.interaction, Rectangle())
      .onTapGesture(perform: self.toggleSelection)
  }
}

public struct CustomListSectionHeader<Content: View>: View {
  @Environment(\.headerProminence) private var prominence: Prominence

  let content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  var isLarge: Bool {
    switch self.prominence {
    case .standard:
      return false
    case .increased:
      return true
    @unknown default:
      return false
    }
  }

  var font: Font? {
    self.isLarge ? Font.title2.weight(.semibold) : Font.headline
  }

  var foregroundColor: Color {
    self.isLarge ? Color.primary : Color.secondary
  }

  public var body: some View {
    self.content
      .font(self.font)
      .foregroundColor(self.foregroundColor)
      .padding(.horizontal, 16)
  }
}

public struct CustomListSection<Header: View, SelectionValue: Hashable, ListContent: View>: View {
  typealias Content = CustomList<SelectionValue, ListContent>

  let header: Header
  let content: Content

  public var body: some View {
    if !self.content.isEmpty {
      VStack(alignment: .leading, spacing: 4) {
        self.header
        self.content
      }
    }
  }
}

private struct Selected: ViewModifier {
  let isSelected, isPreviousSelected, isNextSelected: Bool
  let alignment: Alignment

  var selectionStyleConfig: CustomListSelectionStyle.Configuration {
    CustomListSelectionStyle.Configuration(
      isSelected: self.isSelected,
      isPreviousSelected: self.isPreviousSelected,
      isNextSelected: self.isNextSelected
    )
  }

  init(
    _ isSelected: Bool,
    isPreviousSelected: Bool = false,
    isNextSelected: Bool = false,
    alignment: Alignment = .leading
  ) {
    self.isSelected = isSelected
    self.isPreviousSelected = isPreviousSelected
    self.isNextSelected = isNextSelected
    self.alignment = alignment
  }

  func body(content: Content) -> some View {
    HStack {
      content
    }
    .frame(maxWidth: .infinity, alignment: self.alignment)
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
    .modifier(CustomListSelectionStyle(configuration: self.selectionStyleConfig))
    .compositingGroup()
    .accessibilityAddTraits(self.isSelected ? .isSelected : [])
  }
}

public struct CustomListSelectionStyle: ViewModifier {
  public struct Configuration {
    let isSelected, isPreviousSelected, isNextSelected: Bool
  }

  @Environment(\.controlActiveState) private var controlActiveState: ControlActiveState

  let configuration: Configuration

  var isKey: Bool {
    switch self.controlActiveState {
    case .key, .active:
      return true
    case .inactive:
      return false
    @unknown default:
      return false
    }
  }

  var foregroundColor: Color? {
    self.isKey && self.configuration.isSelected ? Color.white : nil
  }

  public func body(content: Content) -> some View {
    content
      .foregroundColor(self.foregroundColor)
      .background {
        if self.configuration.isSelected {
          GeometryReader { _ in self.background(configuration: self.configuration) }
        }
      }
  }

  @ViewBuilder
  func background(configuration: Configuration) -> some View {
    if self.isKey {
      self.selectionShape(configuration: configuration)
        .fill(.tint)
    } else {
      self.selectionShape(configuration: configuration)
        .fill(.selection)
    }
  }

  func selectionShape(configuration: Configuration) -> some Shape {
    CustomSelectionShape(
      roundedTop: !configuration.isPreviousSelected,
      roundedBottom: !configuration.isNextSelected
    )
  }
}

private struct CustomSelectionShape: Shape {
  let radius: CGFloat
  let roundedTop: Bool
  let roundedBottom: Bool

  init(
    radius: CGFloat = 4,
    roundedTop: Bool,
    roundedBottom: Bool
  ) {
    self.radius = radius
    self.roundedTop = roundedTop
    self.roundedBottom = roundedBottom
  }

  func path(in rect: CGRect) -> Path {
    var path = Path()

    let angleRotation = Angle.degrees(90)

    let lc = CGPoint(x: rect.minX, y: rect.midY)
    let tl = CGPoint(x: rect.minX, y: rect.minY)
    let tls = CGPoint(x: tl.x, y: tl.y + self.radius)
    let tlc = CGPoint(x: tl.x + self.radius, y: tl.y + self.radius)
    let tr = CGPoint(x: rect.maxX, y: rect.minY)
    let trs = CGPoint(x: tr.x - self.radius, y: tr.y)
    let trc = CGPoint(x: tr.x - self.radius, y: tr.y + self.radius)
    let rc = CGPoint(x: rect.maxX, y: rect.midY)
    let br = CGPoint(x: rect.maxX, y: rect.maxY)
    let brs = CGPoint(x: br.x, y: br.y - self.radius)
    let brc = CGPoint(x: br.x - self.radius, y: br.y - self.radius)
    let bl = CGPoint(x: rect.minX, y: rect.maxY)
    let bls = CGPoint(x: bl.x + self.radius, y: bl.y)
    let blc = CGPoint(x: bl.x + self.radius, y: bl.y - self.radius)

    path.move(to: lc)

    if self.roundedTop {
      path.addLine(to: tls)
      path.addRelativeArc(
        center: tlc, radius: self.radius,
        startAngle: .degrees(-180), delta: angleRotation
      )
      path.addLine(to: trs)
      path.addRelativeArc(
        center: trc, radius: self.radius,
        startAngle: .degrees(-90), delta: angleRotation
      )
    } else {
      path.addLine(to: tl)
      path.addLine(to: tr)
    }
    path.addLine(to: rc)

    if self.roundedBottom {
      path.addLine(to: brs)
      path.addRelativeArc(
        center: brc, radius: self.radius,
        startAngle: .zero, delta: angleRotation
      )
      path.addLine(to: bls)
      path.addRelativeArc(
        center: blc, radius: self.radius,
        startAngle: angleRotation, delta: angleRotation
      )
    } else {
      path.addLine(to: br)
      path.addLine(to: bl)
    }
    path.addLine(to: lc)

    return path
  }
}

struct CustomList_Previews: PreviewProvider {
  struct Preview: View {
    struct Element: Hashable, Identifiable {
      let id = UUID()
      var label: String { String(self.id.uuidString.prefix(8)) }
    }

    struct Section<Element: Hashable & Identifiable>: Identifiable {
      let id: Int
      let elements: IdentifiedArrayOf<Element>
    }

    let singleSectionElements: IdentifiedArrayOf<Element> = Self.elements(8)
    let multiSectionElements: IdentifiedArrayOf<Section<Element>> = [
      Section(id: 1, elements: Self.elements(2)),
      Section(id: 2, elements: IdentifiedArray()),
      Section(id: 3, elements: Self.elements(3)),
    ]

    @State var singleExclusiveSelection: Element.ID?
    @State var multipleSelection = Set<Element.ID>()

    var body: some View {
      HStack(alignment: .top) {
        VStack(alignment: .leading) {
          Text(verbatim: "Single exclusive selection")
            .font(.headline)
          Text(verbatim: "Simple rows")
            .font(.subheadline)
          CustomList(
            self.singleSectionElements,
            selection: self.$singleExclusiveSelection,
            canDeselect: false
          ) { element in
            Text(element.label)
          }
          .border(Color.red)
          .onAppear {
            self.singleExclusiveSelection = self.singleSectionElements.first!.id
          }
        }
        VStack(alignment: .leading) {
          Text(verbatim: "Multiple selection")
            .font(.headline)
          Text(verbatim: "Complex rows")
            .font(.subheadline)
          CustomList(
            self.singleSectionElements,
            selection: self.$multipleSelection
          ) { element in
            Image(systemName: "\(element.label.first!.lowercased()).circle")
              .font(.title.bold())
            VStack(alignment: .leading) {
              Text(element.label)
                .font(.headline)
              Text(element.label)
                .font(.subheadline)
              if element == self.singleSectionElements[5] {
                Text(verbatim: "This row is bigger\nbut it still works")
                  .fixedSize()
              }
            }
            Spacer()
            Button {} label: {
              Image(systemName: "\(element.label.last!.lowercased()).circle")
            }
            .foregroundColor(Color(nsColor: .controlTextColor))
          }
          .border(Color.red)
          .onAppear {
            self.multipleSelection.insert(self.singleSectionElements[0].id)
            self.multipleSelection.insert(self.singleSectionElements[1].id)
            self.multipleSelection.insert(self.singleSectionElements[3].id)
            self.multipleSelection.insert(self.singleSectionElements[5].id)
            self.multipleSelection.insert(self.singleSectionElements[6].id)
            self.multipleSelection.insert(self.singleSectionElements[7].id)
          }
        }
      }
      .padding()
      HStack(alignment: .top) {
        VStack(alignment: .leading) {
          Text(verbatim: "Multiple selection")
            .font(.headline)
          Text(verbatim: "Simple rows + sections")
            .font(.subheadline)
          CustomList(
            self.multiSectionElements,
            elements: \.elements,
            selection: self.$multipleSelection
          ) { element in
            Text(verbatim: element.label)
          } header: { section in
            Text(verbatim: "Section \(section.id)")
          }
          .border(Color.red)
          .onAppear {
            self.multipleSelection.insert(self.multiSectionElements[2].elements[1].id)
          }
        }
        VStack(alignment: .leading) {
          Text(verbatim: "Multiple selection")
            .font(.headline)
          Text(verbatim: "Simple rows + prominent sections")
            .font(.subheadline)
          CustomList(
            self.multiSectionElements,
            elements: \.elements,
            selection: self.$multipleSelection
          ) { element in
            Text(verbatim: element.label)
          } header: { section in
            Text(verbatim: "Section \(section.id)")
          }
          .border(Color.red)
          .headerProminence(.increased)
        }
      }
      .padding()
    }

    static func elements(_ count: Int) -> IdentifiedArrayOf<Element> {
      IdentifiedArray(uniqueElements: Array(repeating: Element.init, count: count).map { $0() })
    }
  }

  static var previews: some View {
    Preview()
      .preferredColorScheme(.light)
      .previewDisplayName("Light")
    Preview()
      .preferredColorScheme(.dark)
      .previewDisplayName("Dark")
    VStack(alignment: .leading, spacing: 16) {
      Self.shape(roundedTop: false, roundedBottom: false)
      Self.shape(roundedTop: false, roundedBottom: true)
      Self.shape(roundedTop: true, roundedBottom: false)
      Self.shape(roundedTop: true, roundedBottom: true)
    }
    .padding()
    .preferredColorScheme(.light)
    .previewDisplayName("Selection shape")
    List(0..<3, id: \.self, selection: .constant(1)) { n in
      Label(String(describing: n), systemImage: "\(n).circle.fill")
//        .listItemTint(ListItemTint.monochrome)
        .listItemTint(ListItemTint.fixed(Color.red))
//        .listItemTint(ListItemTint.preferred(Color.green))
    }
    .frame(width: 256)
    .preferredColorScheme(.light)
    .previewDisplayName("List item tint")
  }

  static func shape(roundedTop: Bool, roundedBottom: Bool) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(verbatim: "roundedTop: \(roundedTop)\nroundedBottom: \(roundedBottom)")
        .font(.headline)
        .fixedSize()
      CustomSelectionShape(radius: 16, roundedTop: roundedTop, roundedBottom: roundedBottom)
        .fill(Color.red)
        .frame(width: 200, height: 64)
        .padding(1)
        .border(Color.gray.opacity(0.5))
    }
  }
}
