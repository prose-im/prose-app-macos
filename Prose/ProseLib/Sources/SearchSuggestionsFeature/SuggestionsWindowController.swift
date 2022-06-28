//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Cocoa

/// - Copyright: https://github.com/lucasderraugh/AppleProg-Cocoa-Tutorials/tree/master/Lesson%2090
class SuggestionsWindowController: NSWindowController {
  private var suggestions = [String]()

  private lazy var tableView: NSTableView = {
    let t = NSTableView()
    t.translatesAutoresizingMaskIntoConstraints = false
    t.addTableColumn(NSTableColumn(identifier: NSUserInterfaceItemIdentifier("Main")))
    t.usesAutomaticRowHeights = true
    t.register(TableCellView.nib, forIdentifier: TableCellView.identifier)
    t.dataSource = self
    t.delegate = self
    return t
  }()

  convenience init(owner: Any) {
    let path = Bundle.module.path(forResource: String(describing: Self.self), ofType: "nib")!
    self.init(windowNibPath: path, owner: owner)
  }

//  override func awakeFromNib() {
//    super.awakeFromNib()
  override func windowDidLoad() {
    super.windowDidLoad()

    guard let contentView = window?.contentView else {
      fatalError("`window` has no `contentView`")
    }

    contentView.addSubview(self.tableView)
    NSLayoutConstraint.activate([
      self.tableView.topAnchor.constraint(equalTo: contentView.topAnchor),
      self.tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      self.tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      self.tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
    ])
  }

  func orderOut() {
    self.tableView.deselectAll(nil)
    window?.orderOut(nil)
  }

  func showSuggestions(_ suggestions: [String], for textField: NSTextField) {
    guard !suggestions.isEmpty else { return self.orderOut() }

    self.suggestions = suggestions
    guard let textFieldWindow = textField.window, let window = self.window else {
      fatalError("`window` is `nil`")
    }
    var textFieldRect = textField.convert(textField.bounds, to: nil)
    textFieldRect = textFieldWindow.convertToScreen(textFieldRect)
    textFieldRect.origin.y -= 5
    window.setFrameTopLeftPoint(textFieldRect.origin)

    var frame = window.frame
    frame.size.width = textField.frame.width
    window.setFrame(frame, display: false)
    textFieldWindow.addChildWindow(window, ordered: .above)

    self.tableView.reloadData()
  }

  func moveUp() {
    let selectedRow = max(tableView.selectedRow - 1, 0)
    self.tableView.selectRowIndexes(IndexSet(integer: selectedRow), byExtendingSelection: false)
  }

  func moveDown() {
    let selectedRow = min(tableView.selectedRow + 1, self.suggestions.count - 1)
    self.tableView.selectRowIndexes(IndexSet(integer: selectedRow), byExtendingSelection: false)
  }

  var currentSuggestion: String? {
    let selectedRow = self.tableView.selectedRow
    return selectedRow == -1 ? nil : self.suggestions[selectedRow]
  }
}

extension SuggestionsWindowController: NSTableViewDataSource {
  func numberOfRows(in _: NSTableView) -> Int {
    self.suggestions.count
  }
}

extension SuggestionsWindowController: NSTableViewDelegate {
  func tableView(_ tableView: NSTableView, viewFor _: NSTableColumn?, row: Int) -> NSView? {
    guard let view = tableView.makeView(
      withIdentifier: TableCellView.identifier,
      owner: self
    ) as? TableCellView else { return nil }
    view.textField?.stringValue = self.suggestions[row]
    return view
  }
}
