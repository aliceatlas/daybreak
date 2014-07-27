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

class SBBookmarksView: SBView, SBBookmarkListViewDelegate {
    var splitView: SBFixedSplitView?
    var searchbar: SBSearchbar?
    var scrollView: SBBLKGUIScrollView?
    var listView: SBBookmarkListView?
    var delegate: SBBookmarksViewDelegate?
    
    func splitWidth(proposedWidth: CGFloat) -> CGFloat {
        return listView != nil ? listView!.splitWidth(proposedWidth) : 0
    }
    
    override var frame: NSRect {
        get { return super.frame }
        set(frame) {
            super.frame = frame
            listView!.layoutFrame()
            listView!.layoutItemViews()
        }
    }
    
    /*override func resizeSubviewsWithOldSize(oldBoundsSize: NSSize) {
        listView!.layoutFrame()
        listView!.layoutItemViews()
    }*/
    
    // Delegate
    
    func bookmarkListViewShouldOpenSearchbar(bookmarkListView: SBBookmarkListView) {
        if self.bounds.size.width >= SBSearchbar.availableWidth() {
            self.setShowSearchbar(true)
        } else {
            NSBeep()
        }
    }
   
    func bookmarkListViewShouldCloseSearchbar(bookmarkListView: SBBookmarkListView) -> Bool {
        return self.setShowSearchbar(false)
    }
    
    // Destruction
    
    func destructListView() {
        if listView != nil {
            listView!.removeFromSuperview()
            listView = nil
        }
    }
    
    // Construction
    
    func constructListView(inMode: SBBookmarkMode) {
        let r = self.bounds
        self.destructListView()
        scrollView = SBBLKGUIScrollView(frame: r)
        listView = SBBookmarkListView(frame: r)
        scrollView!.autoresizingMask = .ViewWidthSizable | .ViewHeightSizable
        scrollView!.autohidesScrollers = true
        scrollView!.hasHorizontalScroller = false
        scrollView!.hasVerticalScroller = true
        scrollView!.backgroundColor = NSColor(calibratedRed: SBBackgroundColors.0, green: SBBackgroundColors.1, blue: SBBackgroundColors.2, alpha: SBBackgroundColors.3)
        scrollView!.drawsBackground = true
        listView!.wrapperView = self
        listView!.cellWidth = CGFloat(NSUserDefaults.standardUserDefaults().integerForKey(kSBBookmarkCellWidth as NSString) as Int)
        scrollView!.documentView = listView
        scrollView!.contentView.copiesOnScroll = true
        self.addSubview(scrollView)
        listView!.setCellSizeForMode(inMode)
        listView!.createItemViews()
        listView!.delegate = self
    }
    
    // Getter
    
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
                SBDisembedViewInSplitView(scrollView, splitView)
                splitView = nil
                scrollView!.window.makeFirstResponder(scrollView)
                r = true
            }
        }
        return r
    }
    
    func searchWithText(text: String) {
        if text.utf16Count > 0 {
            listView?.searchWithText(text)
        }
    }
    
    func closeSearchbar() {
        self.setShowSearchbar(false)
    }
    
    // Execute
    
    func executeDidChangeMode() {
        delegate?.bookmarksView?(self, didChangeMode: listView!.mode)
    }
    
    func executeShouldEditItemAtIndex(index: UInt) {
        delegate?.bookmarksView?(self, shouldEditItemAtIndex: index)
    }
    
    func executeDidCellWidth() {
        delegate?.bookmarksView?(self, didChangeCellWidth: listView!.cellWidth)
    }
    
    // Actions
    
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
    
    // Drawing
    
   override func drawRect(rect: NSRect) {
        let ctxPtr = COpaquePointer(NSGraphicsContext.currentContext().graphicsPort)
        let ctx = Unmanaged<CGContext>.fromOpaque(ctxPtr).takeUnretainedValue()
        let r = NSRectToCGRect(self.bounds)
        let count: UInt = 2
        let locations: [CGFloat] = [0.0, 1.0]
        var colors: [CGFloat]
        if keyView {
            colors = [0.35, 0.35, 0.35, 1.0, 0.1, 0.1, 0.1, 1.0]
        } else {
            colors = [0.75, 0.75, 0.75, 1.0, 0.6, 0.6, 0.6, 1.0]
        }
        let points = [CGPointZero, CGPointMake(0.0, r.size.height)]
        CGContextSaveGState(ctx)
        CGContextAddRect(ctx, r)
        CGContextClip(ctx)
        SBDrawGradientInContext(ctx, count, UnsafePointer<CGFloat>(locations), UnsafePointer<CGFloat>(colors), UnsafePointer<CGPoint>(points))
        CGContextRestoreGState(ctx)
    }
}