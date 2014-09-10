/*
SBBookmarksView.swift

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

import Cocoa

@objc
protocol SBBookmarksViewDelegate {
    optional func bookmarksView(SBBookmarksView, didChangeMode: SBBookmarkMode)
    optional func bookmarksView(SBBookmarksView, shouldEditItemAtIndex: UInt)
    optional func bookmarksView(SBBookmarksView, didChangeCellWidth: CGFloat)
}

class SBBookmarksView: SBView, SBBookmarkListViewDelegate {
    var splitView: SBFixedSplitView?
    var searchbar: SBSearchbar?
    var scrollView: SBBLKGUIScrollView?
    var listView: SBBookmarkListView?
    weak var delegate: SBBookmarksViewDelegate?
    
    func splitWidth(proposedWidth: CGFloat) -> CGFloat {
        return listView?.splitWidth(proposedWidth) ?? 0
    }
    
    override var frame: NSRect {
        didSet {
            listView!.layoutFrame()
            listView!.layoutItemViews()
        }
    }
    
    /*override func resizeSubviewsWithOldSize(oldBoundsSize: NSSize) {
        listView!.layoutFrame()
        listView!.layoutItemViews()
    }*/
    
    // MARK: Delegate
    
    func bookmarkListViewShouldOpenSearchbar(bookmarkListView: SBBookmarkListView) {
        if bounds.size.width >= SBSearchbar.availableWidth() {
            setShowSearchbar(true)
        } else {
            NSBeep()
        }
    }
   
    func bookmarkListViewShouldCloseSearchbar(bookmarkListView: SBBookmarkListView) -> Bool {
        return setShowSearchbar(false)
    }
    
    // MARK: Destruction
    
    func destructListView() {
        listView?.removeFromSuperview()
        listView = nil
    }
    
    // MARK: Construction
    
    func constructListView(inMode: SBBookmarkMode) {
        destructListView()
        scrollView = SBBLKGUIScrollView(frame: bounds)
        listView = SBBookmarkListView(frame: bounds)
        scrollView!.autoresizingMask = .ViewWidthSizable | .ViewHeightSizable
        scrollView!.autohidesScrollers = true
        scrollView!.hasHorizontalScroller = false
        scrollView!.hasVerticalScroller = true
        scrollView!.backgroundColor = SBBackgroundColor
        scrollView!.drawsBackground = true
        listView!.wrapperView = self
        listView!.cellWidth = CGFloat(NSUserDefaults.standardUserDefaults().integerForKey(kSBBookmarkCellWidth as NSString) as Int)
        scrollView!.documentView = listView
        scrollView!.contentView.copiesOnScroll = true
        addSubview(scrollView!)
        listView!.setCellSizeForMode(inMode)
        listView!.createItemViews()
        listView!.delegate = self
    }
    
    // MARK: Getter
    
    var cellWidth: CGFloat {
        get { return listView!.cellWidth }
        set(cellWidth) {
            if listView!.cellWidth != cellWidth {
                listView!.cellWidth = cellWidth
                NSUserDefaults.standardUserDefaults().setInteger(Int(cellWidth), forKey: kSBBookmarkCellWidth)
            }
        }
    }
    
    var mode: SBBookmarkMode {
        get { return listView!.mode }
        set(mode) {
            listView!.mode = mode
            NSUserDefaults.standardUserDefaults().setInteger(mode.toRaw(), forKey: kSBBookmarkMode)
        }
    }
    
    func setShowSearchbar(showSearchbar: Bool) -> Bool {
        var r = false
        if showSearchbar {
            if splitView == nil {
                searchbar = SBSearchbar(frame: NSMakeRect(0, 0, scrollView!.frame.size.width, 24.0))
                searchbar!.target = self
                searchbar!.doneSelector = "searchWithText:"
                searchbar!.cancelSelector = "closeSearchbar"
                splitView = SBFixedSplitView(embedViews: [searchbar!, scrollView!], frameRect: scrollView!.frame)
                splitView!.autoresizingMask = .ViewWidthSizable | .ViewHeightSizable
                r = true
            }
            searchbar!.selectText(nil)
        } else {
            if splitView != nil {
                SBDisembedViewInSplitView(scrollView!, splitView!)
                splitView = nil
                scrollView!.window!.makeFirstResponder(scrollView!)
                r = true
            }
        }
        return r
    }
    
    func searchWithText(text: String) {
        if !text.isEmpty {
            listView?.searchWithText(text)
        }
    }
    
    func closeSearchbar() {
        setShowSearchbar(false)
    }
    
    // MARK: Execute
    
    func executeDidChangeMode() {
        delegate?.bookmarksView?(self, didChangeMode: listView!.mode)
    }
    
    func executeShouldEditItemAtIndex(index: UInt) {
        delegate?.bookmarksView?(self, shouldEditItemAtIndex: index)
    }
    
    func executeDidCellWidth() {
        delegate?.bookmarksView?(self, didChangeCellWidth: listView!.cellWidth)
    }
    
    // MARK: Actions
    
    func addForBookmarkItem(item: NSDictionary) {
        listView?.addForItem(item)
    }
    
    func scrollToItem(bookmarkItem: NSDictionary) {
        let bookmarks = SBBookmarks.sharedBookmarks
        let index = bookmarks.indexOfItem(bookmarkItem)
        if index != NSNotFound {
            let itemRect = listView!.itemRectAtIndex(Int(index))
            scrollView!.scrollRectToVisible(itemRect)
        }
    }
    
    func reload() {
        listView!.updateItems()
    }
    
    // MARK: Drawing
    
    override func drawRect(rect: NSRect) {
        var colors: [NSColor]!
        if keyView {
            colors = [NSColor(deviceWhite: 0.35, alpha: 1.0), NSColor(deviceWhite: 0.1, alpha: 1.0)]
        } else {
            colors = [NSColor(deviceWhite: 0.75, alpha: 1.0), NSColor(deviceWhite: 0.6, alpha: 1.0)]
        }
        let gradient = NSGradient(startingColor: colors[0], endingColor: colors[1])
        gradient.drawInRect(bounds, angle: 90)
    }
}