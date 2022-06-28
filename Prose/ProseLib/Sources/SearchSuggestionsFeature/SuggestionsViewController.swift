//
//  SuggestionsViewController.swift
//  
//
//  Created by Rémi Bardon on 28/06/2022.
//

import AppKit

final class SuggestionsViewController: NSViewController {
  private var suggestions = [String]()

  lazy var tableView: NSTableView = {
    let t = NSTableView()
//    t.translatesAutoresizingMaskIntoConstraints = false
    t.addTableColumn(NSTableColumn(identifier: NSUserInterfaceItemIdentifier("Main")))
    t.usesAutomaticRowHeights = true
    t.register(TableCellView.nib, forIdentifier: TableCellView.identifier)
    t.dataSource = self
    t.delegate = self
    return t
  }()

  override func loadView() {
//    NSLayoutConstraint.activate([
//      self.tableView.topAnchor.constraint(equalTo: contentView.topAnchor),
//      self.tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//      self.tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//      self.tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//    ])

    self.view = self.tableView
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
  func numberOfRows(in _: NSTableView) -> Int {
    self.suggestions.count
  }
}

extension SuggestionsViewController: NSTableViewDelegate {
  func tableView(_ tableView: NSTableView, viewFor _: NSTableColumn?, row: Int) -> NSView? {
    guard let view = tableView.makeView(
      withIdentifier: TableCellView.identifier,
      owner: self
    ) as? TableCellView else { return nil }
    view.textField?.stringValue = self.suggestions[row]
    return view
  }
}
