/*
SBHistoryView.swift

Copyright (c) 2014, Alice Atlas
Copyright (c) 2010, Atsushi Jike
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

class SBHistoryView: SBView, NSTextFieldDelegate, NSTableViewDelegate, NSTableViewDataSource {
    private let kSBMinFrameSizeWidth: CGFloat = 480
    private let kSBMinFrameSizeHeight: CGFloat = 320
    
	private lazy var iconImageView: NSImageView = {
        let iconImageView = NSImageView(frame: self.iconRect)
        if let image = NSImage(named: "History") {
            image.size = iconImageView.frame.size
            iconImageView.image = image
        }
        return iconImageView
    }()
	private lazy var messageLabel: NSTextField = {
        let messageLabel = NSTextField(frame: self.messageLabelRect)
        messageLabel.autoresizingMask = .ViewMinXMargin | .ViewMinYMargin
        messageLabel.editable = false
        messageLabel.bordered = false
        messageLabel.drawsBackground = false
        messageLabel.textColor = NSColor.whiteColor()
        messageLabel.font = NSFont.boldSystemFontOfSize(16)
        messageLabel.alignment = .LeftTextAlignment
        (messageLabel.cell() as NSTextFieldCell).wraps = true
        return messageLabel
    }()
	private lazy var searchField: SBBLKGUISearchField = {
        let searchField = SBBLKGUISearchField(frame: self.searchFieldRect)
        searchField.delegate = self
        searchField.target = self
        searchField.action = "search:"
        let cell = searchField.cell() as NSSearchFieldCell
        cell.sendsWholeSearchString = true
        cell.sendsSearchStringImmediately = true
        return searchField
    }()
	private lazy var scrollView: SBBLKGUIScrollView = {
        let scrollView = SBBLKGUIScrollView(frame: self.tableViewRect)
        scrollView.autoresizingMask = .ViewWidthSizable | .ViewHeightSizable
        scrollView.autohidesScrollers = true
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.backgroundColor = NSColor.blackColor()
        scrollView.drawsBackground = false
        scrollView.documentView = self.tableView
        return scrollView
    }()
	private lazy var tableView: NSTableView = {
        var tableRect = NSZeroRect
        tableRect.size = self.tableViewRect.size
        let tableView = NSTableView(frame: tableRect)
        let iconColumn = NSTableColumn(identifier: kSBImage)
        let titleColumn = NSTableColumn(identifier: kSBTitle)
        let urlColumn = NSTableColumn(identifier: kSBURL)
        let dateColumn = NSTableColumn(identifier: kSBDate)
        let iconCell = SBIconDataCell()
        let textCell = NSCell()
        iconCell.drawsBackground = false
        iconColumn.width = 22.0
        iconColumn.dataCell = iconCell
        iconColumn.editable = false
        titleColumn.dataCell = textCell
        titleColumn.width = (tableRect.size.width - 22.0) * 0.3
        titleColumn.editable = false
        urlColumn.dataCell = textCell
        urlColumn.width = (tableRect.size.width - 22.0) * 0.4
        urlColumn.editable = false
        dateColumn.dataCell = textCell
        dateColumn.width = (tableRect.size.width - 22.0) * 0.3
        dateColumn.editable = false
        tableView.backgroundColor = NSColor.clearColor()
        tableView.rowHeight = 20
        tableView.addTableColumn(iconColumn)
        tableView.addTableColumn(titleColumn)
        tableView.addTableColumn(urlColumn)
        tableView.addTableColumn(dateColumn)
        tableView.allowsMultipleSelection = true
        tableView.allowsColumnSelection = false
        tableView.allowsEmptySelection = true
        tableView.doubleAction = "tableViewDidDoubleAction:"
        tableView.columnAutoresizingStyle = .LastColumnOnlyAutoresizingStyle
        tableView.headerView = nil
        tableView.cornerView = nil
        tableView.autoresizingMask = .ViewWidthSizable
        tableView.setDataSource(self)
        tableView.setDelegate(self)
        tableView.focusRingType = .None
        tableView.doubleAction = "open"
        return tableView
    }()
	private lazy var removeButton: SBBLKGUIButton = {
        let removeButton = SBBLKGUIButton(frame: self.removeButtonRect)
        removeButton.title = NSLocalizedString("Remove", comment: "")
        removeButton.target = self
        removeButton.action = "remove"
        removeButton.enabled = false
        return removeButton
    }()
	private lazy var removeAllButton: SBBLKGUIButton = {
        let removeAllButton = SBBLKGUIButton(frame: self.removeAllButtonRect)
        removeAllButton.title = NSLocalizedString("Remove All", comment: "")
        removeAllButton.target = self
        removeAllButton.action = "removeAll"
        removeAllButton.enabled = false
        return removeAllButton
    }()
	private lazy var backButton: SBBLKGUIButton = {
        let backButton = SBBLKGUIButton(frame: self.backButtonRect)
        backButton.title = NSLocalizedString("Back", comment: "")
        backButton.target = self
        backButton.action = "cancel"
        backButton.keyEquivalent = "\u{1B}"
        return backButton
    }()
    
    var message: String {
        get { return messageLabel.stringValue }
        set(message) { messageLabel.stringValue = message }
    }
	var items: [WebHistoryItem]
    
    override init(frame: NSRect) {
        var r = frame
        SBConstrain(&r.size.width, min: kSBMinFrameSizeWidth)
        SBConstrain(&r.size.height, min: kSBMinFrameSizeWidth)
        items = SBHistory.sharedHistory.items
        super.init(frame: r)
        addSubview(iconImageView)
        addSubview(messageLabel)
        addSubview(searchField)
        addSubview(scrollView)
        addSubview(removeButton)
        addSubview(removeAllButton)
        addSubview(backButton)
        makeResponderChain()
        autoresizingMask = .ViewMinXMargin | .ViewMaxXMargin | .ViewMinYMargin | .ViewMaxYMargin
    }

    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    // MARK: Rects
    
    let margin = NSMakePoint(36.0, 32.0)
    let labelWidth: CGFloat = 85.0
    let buttonHeight: CGFloat = 24.0
    let buttonMargin: CGFloat = 15.0
    let searchFieldWidth: CGFloat = 250.0
    
    var iconRect: NSRect {
        var r = NSZeroRect
        r.size.width = 32.0
        r.origin.x = labelWidth - r.size.width
        r.size.height = 32.0
        r.origin.y = bounds.size.height - margin.y - r.size.height
        return r
    }
    
    var messageLabelRect: NSRect {
        var r = NSZeroRect
        r.origin.x = NSMaxX(iconRect) + 10.0
        r.size.width = bounds.size.width - r.origin.x - searchFieldWidth - margin.x
        r.size.height = 20.0
        r.origin.y = bounds.size.height - margin.y - r.size.height - (iconRect.size.height - r.size.height) / 2
        return r
    }
    
    var searchFieldRect: NSRect {
        var r = NSZeroRect
        r.size.width = searchFieldWidth
        r.size.height = 20.0
        r.origin.x = bounds.size.width - r.size.width - margin.x
        r.origin.y = bounds.size.height - margin.y - r.size.height - (iconRect.size.height - r.size.height) / 2
        return r
    }
    
    var tableViewRect: NSRect {
        var r = NSZeroRect
        r.origin.x = margin.x
        r.size.width = bounds.size.width - r.origin.x - margin.x
        r.size.height = bounds.size.height - iconRect.size.height - 10.0 - margin.y * 3 - buttonHeight
        r.origin.y = margin.y * 2 + buttonHeight
        return r
    }
    
    var removeButtonRect: NSRect {
        var r = NSZeroRect
        r.size.width = 105.0
        r.size.height = buttonHeight
        r.origin.y = margin.y
        r.origin.x = margin.x
        return r
    }
    
    var removeAllButtonRect: NSRect {
        var r = NSZeroRect
        r.size.width = 140.0
        r.size.height = removeButtonRect.size.height
        r.origin.y = margin.y
        r.origin.x = NSMaxX(removeButtonRect) + 10.0
        return r
    }
    
    var backButtonRect: NSRect {
        var r = NSZeroRect
        r.size.width = 105.0
        r.size.height = buttonHeight
        r.origin.y = margin.y
        r.origin.x = bounds.size.width - r.size.width - margin.x
        return r
    }
    
    func showAllItems() {
        items = SBHistory.sharedHistory.items
        tableView.reloadData()
    }
    
    func updateItems() {
        let allItems = SBHistory.sharedHistory.items
        let searchFieldText = searchField.stringValue
        let searchWords = !searchFieldText.isEmpty ? (searchFieldText as NSString).componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) as [String] : []
        if !searchWords.isEmpty {
            items = []
            for item in allItems {
                var string = ""
                item.originalURLString !! { string += " \($0)" }
                item.URLString !! { string += " \($0)" }
                item.title !! { string += " \($0)" }
                if !string.isEmpty {
                    var index = 0
                    for searchWord in searchWords {
                        if searchWord.isEmpty || (string as NSString).rangeOfString(searchWord, options: .CaseInsensitiveSearch).location != NSNotFound {
                            if index == searchWords.count - 1 {
                                items.append(item)
                            }
                        } else {
                            break
                        }
                        index++
                    }
                }
            }
        } else {
            items = allItems
        }
    }
    
    // MARK: DataSource
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        removeAllButton.enabled = !items.isEmpty
        return items.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn, row rowIndex: Int) -> AnyObject? {
        let identifier = tableColumn.identifier
        let item = (rowIndex < items.count) &? items[rowIndex]
        switch identifier {
        case kSBTitle:
            return item?.title
        case kSBURL:
            return item?.URLString
        case kSBDate:
            return nil
        default:
            break
        }
        return nil
    }
    
    func tableView(tableView: NSTableView, willDisplayCell cell: NSCell, forTableColumn tableColumn: NSTableColumn, row rowIndex: Int) {
        let identifier = tableColumn.identifier
        let item = (rowIndex < items.count) &? items[rowIndex]
        var string: String?
        switch identifier {
        case kSBImage:
            if let image = item?.icon {
                cell.image = image
            }
        case kSBTitle:
            string = item?.title
        case kSBURL:
            string = item?.URLString
        case kSBDate:
            let interval = item?.lastVisitedTimeInterval ?? 0
            if interval > 0 {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "%Y/%m/%d %H:%M:%S"
                dateFormatter.formatterBehavior = .Behavior10_4
                dateFormatter.dateStyle = .LongStyle
                dateFormatter.timeStyle = .ShortStyle
                dateFormatter.locale = NSLocale.currentLocale()
                string = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: interval))
            }
        default:
            break
        }
        if !(string ?? "").isEmpty {
            let attributes = [NSFontAttributeName: NSFont.systemFontOfSize(14.0),
                              NSForegroundColorAttributeName: NSColor.whiteColor()]
            let attributedString = NSAttributedString(string: string!, attributes: attributes)
            cell.attributedStringValue = attributedString
        }
    }
    
    // MARK: Delegate
    
    override func controlTextDidChange(notification: NSNotification) {
        if notification.object === searchField {
            if searchField.stringValue.isEmpty {
                showAllItems()
            }
        }
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        removeButton.enabled = tableView.selectedRowIndexes.count > 0
    }
    
    // MARK: Construction
    
    func makeResponderChain() {
        removeButton.nextKeyView = removeAllButton
        backButton.nextKeyView = removeButton
        tableView.nextKeyView = backButton
        removeAllButton.nextKeyView = tableView
    }
    
    // MARK: Actions
    
    func search(sender: AnyObject) {
        let string = searchField.stringValue
        if !string.isEmpty {
            updateItems()
            tableView.reloadData()
        }
    }
    
    func remove() {
        let indexes = tableView.selectedRowIndexes
        let removedItems = indexes.count > 0 ? items.objectsAtIndexes(indexes) : []
        if !removedItems.isEmpty {
            SBHistory.sharedHistory.removeItems(removedItems)
            tableView.deselectAll(nil)
            updateItems()
            tableView.reloadData()
        }
    }
    
    func removeAll() {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Are you sure you want to remove all items?", comment: "")
        alert.addButtonWithTitle(NSLocalizedString("Remove All", comment: ""))
        alert.addButtonWithTitle(NSLocalizedString("Cancel", comment: ""))
        if alert.runModal() == NSOKButton {
            SBHistory.sharedHistory.removeAllItems()
            tableView.deselectAll(nil)
            updateItems()
            tableView.reloadData()
        }
    }
    
    func open() {
        var urls: [NSURL] = []
        let indexes = tableView.selectedRowIndexes
        for var index = indexes.lastIndex; index != NSNotFound; index = indexes.indexLessThanIndex(index) {
            let item = (index < items.count) &? items[index]
            let URLString = item?.URLString
            if let URL = URLString !! {NSURL(string: $0)} {
                urls.append(URL)
            }
        }
        if (target !! doneSelector) != nil {
            if target!.respondsToSelector(doneSelector) {
                NSApp.sendAction(doneSelector, to: target, from: urls as NSArray)
            }
        }
    }
}