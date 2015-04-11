/*
SBWebResourcesView.swift

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

import BLKGUI

@objc protocol SBWebResourcesViewDataSource {
    func numberOfRowsInWebResourcesView(SBWebResourcesView) -> Int
    func webResourcesView(SBWebResourcesView, objectValueForTableColumn: NSTableColumn, row: Int) -> AnyObject?
    func webResourcesView(SBWebResourcesView, willDisplayCell: AnyObject?, forTableColumn: NSTableColumn, row: Int)
}

@objc protocol SBWebResourcesViewDelegate {
    optional func webResourcesView(SBWebResourcesView, shouldSaveAtRow: Int)
    optional func webResourcesView(SBWebResourcesView, shouldDownloadAtRow: Int)
}

class SBWebResourcesView: SBView, NSTableViewDataSource, NSTableViewDelegate {
    weak var dataSource: SBWebResourcesViewDataSource?
    weak var delegate: SBWebResourcesViewDelegate?
    
    lazy var scrollView: NSScrollView = {
        let scrollView = BLKGUI.ScrollView(frame: self.bounds)
        scrollView.autoresizingMask = .ViewWidthSizable | .ViewHeightSizable
        scrollView.autohidesScrollers = true
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.backgroundColor = SBBackgroundColor
        scrollView.drawsBackground = true
        scrollView.documentView = self.tableView
        return scrollView
    }()
    
    lazy var tableView: NSTableView = {
        var tableRect = NSZeroRect
        let lengthWidth: CGFloat = 110.0
        let cachedWidth: CGFloat = 22.0
        let actionWidth: CGFloat = 22.0
        tableRect.size = self.bounds.size
        let tableView = NSTableView(frame: tableRect)
        let urlColumn = NSTableColumn(identifier: kSBURL)
        let lengthColumn = NSTableColumn(identifier: "Length")
        let cachedColumn = NSTableColumn(identifier: "Cached")
        let actionColumn = NSTableColumn(identifier: "Action")
        let urlTextCell = SBTableCell()
        let lengthTextCell = SBTableCell()
        let cachedCell = SBWebResourceButtonCell()
        let actionCell = SBWebResourceButtonCell()
        urlTextCell.font = NSFont.systemFontOfSize(12.0)
        urlTextCell.showRoundedPath = true
        urlTextCell.alignment = .LeftTextAlignment
        urlTextCell.lineBreakMode = .ByTruncatingMiddle
        lengthTextCell.font = NSFont.systemFontOfSize(10.0)
        lengthTextCell.showRoundedPath = false
        lengthTextCell.showSelection = false
        lengthTextCell.alignment = .RightTextAlignment
        cachedCell.target = self
        cachedCell.action = "save:"
        actionCell.target = self
        actionCell.action = "download:"
        urlColumn.dataCell = urlTextCell
        urlColumn.width = tableRect.size.width - lengthWidth - cachedWidth - actionWidth
        urlColumn.editable = false
        urlColumn.resizingMask = .AutoresizingMask
        lengthColumn.dataCell = lengthTextCell
        lengthColumn.width = lengthWidth
        lengthColumn.editable = false
        lengthColumn.resizingMask = .NoResizing
        cachedColumn.dataCell = cachedCell
        cachedColumn.width = cachedWidth
        cachedColumn.editable = false
        cachedColumn.resizingMask = .NoResizing
        actionColumn.dataCell = actionCell
        actionColumn.width = actionWidth
        actionColumn.editable = false
        actionColumn.resizingMask = .NoResizing
        tableView.backgroundColor = NSColor.clearColor()
        tableView.rowHeight = 20
        tableView.addTableColumn(urlColumn)
        tableView.addTableColumn(lengthColumn)
        tableView.addTableColumn(cachedColumn)
        tableView.addTableColumn(actionColumn)
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
        tableView.intercellSpacing = NSZeroSize
        return tableView
    }()
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        addSubview(scrollView)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    // MARK: DataSource
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return dataSource?.numberOfRowsInWebResourcesView(self) ?? 0
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row rowIndex: Int) -> AnyObject? {
        return dataSource?.webResourcesView(self, objectValueForTableColumn: tableColumn!, row: rowIndex)
    }
    
    func tableView(tableView: NSTableView, willDisplayCell cell: AnyObject, forTableColumn tableColumn: NSTableColumn?, row rowIndex: Int) {
        dataSource?.webResourcesView(self, willDisplayCell: cell, forTableColumn: tableColumn!, row: rowIndex)
    }
    
    // MARK: Actions
    
    func reload() {
        tableView.reloadData()
    }
    
    func save(tableView: NSTableView) {
        let rowIndex = tableView.clickedRow
        if rowIndex != NSNotFound {
            delegate?.webResourcesView?(self, shouldSaveAtRow: rowIndex)
        }
    }
    
    func download(tableView: NSTableView) {
        let rowIndex = tableView.clickedRow
        if rowIndex != NSNotFound {
            delegate?.webResourcesView?(self, shouldDownloadAtRow: rowIndex)
        }
    }
    
    // MARK: Drawing
    
    override func drawRect(rect: NSRect) {
        
    }
}

class SBWebResourceButtonCell: NSButtonCell {
    var highlightedImage: NSImage?
    let side: CGFloat = 5.0
    
    // MARK: Drawing
    
    override func drawWithFrame(cellFrame: NSRect, inView controlView: NSView) {
        drawInteriorWithFrame(cellFrame, inView: controlView)
        drawImageWithFrame(cellFrame, inView: controlView)
    }
    
    override func drawInteriorWithFrame(cellFrame: NSRect, inView controlView: NSView) {
        SBBackgroundColor.set()
        NSRectFill(cellFrame)
        SBTableCellColor.set()
        NSRectFill(NSInsetRect(cellFrame, 0.0, 0.5))
    }
    
    func drawImageWithFrame(cellFrame: NSRect, inView controlView: NSView) {
        var fraction: CGFloat = 1.0
        var image: NSImage? = self.image
        if highlighted {
            fraction = highlightedImage !! 1.0 ?? 0.5
            image = highlightedImage ?? image
        }
        if image != nil {
            var r = NSZeroRect
            r.size = image!.size
            r.origin.x = cellFrame.origin.x + side + ((cellFrame.size.width - side * 2) - r.size.width) / 2
            r.origin.y = cellFrame.origin.y + (cellFrame.size.height - r.size.height) / 2;
            r = NSIntegralRect(r)
            image!.drawInRect(r, operation: .CompositeSourceOver, fraction: fraction, respectFlipped: true)
        }
    }
}