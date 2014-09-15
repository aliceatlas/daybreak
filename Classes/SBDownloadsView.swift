/*
SBDownloadsView.swift

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

@objc
protocol SBDownloadsViewDelegate {
    optional func downloadsViewDidRemoveAllItems(SBDownloadsView)
}

class SBDownloadsView: SBView, NSAnimationDelegate {
    weak var delegate: SBDownloadsViewDelegate?
    private var downloadViews: [SBDownloadView] = []
    private lazy var removeButton: SBButton = {
        let removeRect = self.removeButtonRect(nil)
        let removeButton = SBButton(frame: removeRect)
        removeButton.autoresizingMask = .ViewMaxXMargin | .ViewMinYMargin
        removeButton.image = NSImage(CGImage: SBIconImage(SBCloseIconImage(), .Left, removeRect.size))
        removeButton.action = "remove"
        return removeButton
    }()
    private lazy var finderButton: SBButton = {
        let finderRect = self.finderButtonRect(nil)
        let finderButton = SBButton(frame: finderRect)
        finderButton.autoresizingMask = .ViewMaxXMargin | .ViewMinYMargin;
        finderButton.image = NSImage(CGImage: SBIconImageWithName("Finder", .Right, finderRect.size))
        finderButton.action = "finder"
        return finderButton
    }()
    private var toolsItemView: SBDownloadView?
    
    // MARK: Responder

    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func becomeFirstResponder() -> Bool {
        needsDisplaySelectedItemViews()
        return true
    }

    override func resignFirstResponder() -> Bool {
        needsDisplaySelectedItemViews()
        return true
    }
    
    let cellSize = NSMakeSize(kSBDownloadItemSize, kSBDownloadItemSize)
    
    var blockX: Int {
        if bounds.size.width < cellSize.width {
            return 1
        }
        return Int(bounds.size.width / cellSize.width)
    }
    
    func cellFrameAtIndex(index: Int) -> NSRect {
        var r = NSZeroRect
        var p = NSZeroPoint
        r.size = cellSize
        p.y = (index >= blockX) ? CGFloat(index / blockX) : 0
        p.x = CGFloat(index) - p.y * CGFloat(blockX)
        r.origin.x = p.x * r.size.width
        r.origin.y = bounds.size.height - (p.y * r.size.height + r.size.height)
        return r
    }
    
    func removeButtonRect(itemView: SBDownloadView?) -> NSRect {
        var r = NSZeroRect
        r.size.width = 24.0
        r.size.height = 24.0
        if itemView != nil {
            r.origin.x = itemView!.frame.origin.x
            r.origin.y = NSMaxY(itemView!.frame) - r.size.height
        }
        return r
    }
    
    func finderButtonRect(itemView: SBDownloadView?) -> NSRect {
        var r = NSZeroRect
        r.size.width = 24.0
        r.size.height = 24.0
        if itemView != nil {
            r.origin.x = itemView!.frame.origin.x
            r.origin.y = NSMaxY(itemView!.frame) - r.size.height
        }
        r.origin.x += r.size.width
        return r
    }
    
    // MARK: Actions
    
    func addForItem(item: SBDownload) {
        var downloadView = downloadViews.first { $0.download.identifier == item.identifier }
        if downloadView == nil {
            let r = cellFrameAtIndex(downloadViews.count)
            downloadView = SBDownloadView(frame: r, download: item)
            downloadView!.autoresizingMask = .ViewMaxXMargin | .ViewMinYMargin
            downloadView!.update()
            downloadViews.append(downloadView!)
            addSubview(downloadView!)
        }
        downloadView!.download = item
        layoutItems(true)
    }
    
    func removeForItem(item: SBDownload) -> Bool {
        if let downloadView = downloadViews.first({ $0.download.identifier == item.identifier }) {
            downloadView.removeFromSuperview()
            removeObject(&downloadViews, downloadView)
            if !downloadViews.isEmpty {
                layoutItems(true)
            } else {
                executeDidRemoveAllItems()
            }
            return true
        }
        return false
    }
    
    func updateForItem(item: SBDownload) {
        downloadViews.first({ $0.download === item })?.update()
    }
    
    func finishForItem(item: SBDownload) {
        downloadViews.first({ $0.download === item })?.update()
    }
    
    func failForItem(item: SBDownload) {
        if item.status != .Undone {
            downloadViews.first({ $0.download === item })?.update()
        }
    }
    
    func layoutToolsForItem(itemView: SBDownloadView) {
        if toolsItemView !== itemView {
            toolsItemView = itemView
            SBDispatchDelay(kSBDownloadsToolsInterval) {
                if self.toolsItemView != nil {
                    self.removeButton.frame = self.removeButtonRect(self.toolsItemView)
                    self.finderButton.frame = self.finderButtonRect(self.toolsItemView)
                    self.removeButton.target = self.toolsItemView
                    self.finderButton.target = self.toolsItemView
                    self.addSubview(self.removeButton)
                    self.addSubview(self.finderButton)
                }
            }
        }
    }
    
    func layoutToolsHidden() {
        removeButton.target = nil
        finderButton.target = nil
        removeButton.removeFromSuperview()
        finderButton.removeFromSuperview()
        toolsItemView = nil
    }
    
    // MARK: Actions (Private)
    
    func needsDisplaySelectedItemViews() {
        for downloadView in downloadViews {
            if downloadView.selected {
                downloadView.needsDisplay = true
            }
        }
    }
    
    func executeDidRemoveAllItems() {
        delegate?.downloadsViewDidRemoveAllItems?(self)
    }
    
    func constructDownloadViews() {
        for item in SBDownloads.sharedDownloads.items {
            addForItem(item)
        }
        layoutItems(true)
    }
    
    func layoutItems(animated: Bool) {
        let enclosingSize = enclosingScrollView?.contentSize ?? bounds.size
        if enclosingSize.width > 0 && enclosingSize.height > 0 {
            var r = frame
            var block = NSZeroPoint
            var animations: [[NSObject: AnyObject]] = []
            let currentEvent = NSApplication.sharedApplication().currentEvent
            let location = currentEvent.locationInWindow
            var currentDownloadView: SBDownloadView?
            let count = downloadViews.count
            
            // Calculate the view frame
            block.x = CGFloat(blockX)
            block.y = CGFloat(count) / CGFloat(block.x)
            if block.y != round(block.y) {
                block.y += 1
            }
            r.size.width = enclosingSize.width
            r.size.height = SBConstrain(block.y * cellSize.height, min: enclosingSize.height)
            frame = r
            
            // Set frame of item views
            for (index, downloadView) in enumerate(downloadViews) {
                let r0 = downloadView.frame
                let r1 = cellFrameAtIndex(index)
                let point = convertPoint(location, fromView: nil)
                if r0 != r1 {
                    if animated && (NSIntersectsRect(visibleRect, downloadView.frame) || NSIntersectsRect(visibleRect, r)) { // Only visible views
                        animations.append([
                            NSViewAnimationTargetKey: downloadView,
                            NSViewAnimationStartFrameKey: NSValue(rect: r0),
                            NSViewAnimationEndFrameKey: NSValue(rect: r1)])
                    } else {
                        downloadView.frame = r1
                    }
                }
                if NSPointInRect(point, r1) {
                    currentDownloadView = downloadView
                }
            }
            if animations.count > 0 {
                let animation = NSViewAnimation(viewAnimations: animations)
                animation.duration = 0.25
                animation.delegate = self
                animation.startAnimation()
            }
            currentDownloadView !! { self.layoutToolsForItem($0) }
        }
    }
    
    // MARK: Menu Actions
    
    func delete(sender: AnyObject?) {
        let selectedDownloads = downloadViews.filter({ $0.selected }).map({ $0.download })
        if selectedDownloads.count > 0 {
            SBDownloads.sharedDownloads.removeItems(selectedDownloads)
        }
    }
    
    override func selectAll(sender: AnyObject?) {
        for downloadView in downloadViews {
            downloadView.selected = true
        }
    }
    
    // MARK: Event
    
    override func mouseDown(event: NSEvent) {
        let location = event.locationInWindow
        let point = convertPoint(location, fromView: nil)
        for (index, downloadView) in enumerate(downloadViews) {
            let r = cellFrameAtIndex(index)
            downloadView.selected = NSPointInRect(point, r)
        }
    }
    
    override func keyDown(event: NSEvent) {
        let characters = event.characters as NSString
        let character = Int(characters.characterAtIndex(0))
        if character == NSDeleteCharacter {
            delete(nil)
        }
    }
    
    override func mouseUp(event: NSEvent) {
        if event.clickCount == 2 {
            let location = event.locationInWindow
            let point = convertPoint(location, fromView: nil)
            for (index, downloadView) in enumerate(downloadViews) {
                let r = cellFrameAtIndex(index)
                if NSPointInRect(point, r) {
                    downloadView.open()
                }
            }
        }
    }
}