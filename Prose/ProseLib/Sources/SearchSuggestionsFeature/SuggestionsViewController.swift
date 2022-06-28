//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppKit

final class SuggestionsViewController: NSViewController {
  private var suggestions = [String]()

  lazy var tableView: NSTableView = {
    let t = NSTableView()
    t.addTableColumn(NSTableColumn())
    t.usesAutomaticRowHeights = true
    t.dataSource = self
    t.delegate = self
    return t
  }()

  override func loadView() {
    self.view = NSView()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.addSubview(self.tableView)
    self.tableView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
      self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
    ])
  }

  func showSuggestions(_ suggestions: [String]) {
    self.suggestions = suggestions
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

extension SuggestionsViewController: NSTableViewDataSource {
  func numberOfRows(in _: NSTableView) -> Int { self.suggestions.count }
}

extension SuggestionsViewController: NSTableViewDelegate {
  func tableView(_ tableView: NSTableView, viewFor _: NSTableColumn?, row: Int) -> NSView? {
    var result: NSTextField? = tableView.makeView(
      withIdentifier: TableCellView.identifier,
      owner: self
    ) as? NSTextField
    let value = self.suggestions[row]
    if let result = result {
      result.stringValue = value
    } else {
      let cell = NSTextField(labelWithString: value)
      cell.identifier = TableCellView.identifier
      result = cell
    }
    return result
  }
}
