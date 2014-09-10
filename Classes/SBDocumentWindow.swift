/*
SBDocumentWindow.swift

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
protocol SBDocumentWindowDelegate: NSWindowDelegate {
    optional func window(window: SBDocumentWindow, shouldClose: AnyObject?) -> Bool
    optional func window(window: SBDocumentWindow, shouldHandleKeyEvent: NSEvent) -> Bool
    optional func windowDidFinishFlipping(window: SBDocumentWindow)
}

class SBDocumentWindow: NSWindow {
    let kSBFlipAnimationDuration: CGFloat = 0.8
    let kSBFlipAnimationRectMargin: CGFloat = 100
    let kSBBackWindowFrameWidth: CGFloat = 800.0
    let kSBBackWindowFrameHeight: CGFloat = 600.0

	var backWindow: NSWindow?
	var keyView = false
	lazy var innerView: SBInnerView = {
        let innerView = SBInnerView(frame: self.innerRect)
        innerView.autoresizingMask = .ViewWidthSizable | .ViewHeightSizable
        return innerView
    }()
	var coverWindow: SBCoverWindow?
    var tabbar: SBTabbar? {
        didSet {
            oldValue?.removeFromSuperview()
            if tabbar != nil {
                tabbar!.frame = tabbarRect
                tabbar!.autoresizingMask = .ViewWidthSizable | .ViewMinYMargin
                innerView.addSubview(tabbar!)
            }
        }
    }
	var tabbarVisibility: Bool = false
    var sbToolbar: SBToolbar? {
        get { return super.toolbar as? SBToolbar }
        set(sbToolbar) { super.toolbar = sbToolbar }
    }
    var sbDelegate: SBDocumentWindowDelegate? {
        get { return delegate as? SBDocumentWindowDelegate }
        set(sbDelegate) { delegate = sbDelegate }
    }
    var splitView: SBSplitView? {
        didSet {
            oldValue?.removeFromSuperview()
            if splitView != nil {
                splitView!.frame = splitViewRect
                splitView!.autoresizingMask = .ViewWidthSizable | .ViewMinYMargin
                innerView.addSubview(splitView!)
            }
        }
    }
    override var title: String! {
        didSet {
            let title: String? = self.title
            super.title = (title ?? "") as String
        }
    }

    init(frame: NSRect, delegate: SBDocumentWindowDelegate?, tabbarVisibility inTabbarVisibility: Bool) {
        let styleMask = NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask
        super.init(contentRect: frame, styleMask: styleMask, backing: .Buffered, defer: true)
        
        contentView.addSubview(innerView)
        minSize = NSMakeSize(kSBDocumentWindowMinimumSizeWidth, kSBDocumentWindowMinimumSizeHeight)
        sbDelegate = delegate
        releasedWhenClosed = true
        showsToolbarButton = true
        oneShot = true
        acceptsMouseMovedEvents = true
        collectionBehavior = .FullScreenPrimary | .FullScreenAuxiliary
        animationBehavior = .None
        tabbarVisibility = inTabbarVisibility
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    deinit {
        sbDelegate = nil
        destructCoverWindow()
    }
    
    var covering: Bool {
        if let keyWindow = NSApplication.sharedApplication().keyWindow {
            return keyWindow === coverWindow
        }
        return false
    }
    
    override var canBecomeKeyWindow: Bool {
        return covering ? false : super.canBecomeKeyWindow
    }
    
    override func becomeKeyWindow() {
        super.becomeKeyWindow()
        coverWindow?.makeKeyWindow()
    }
    
    // MARK: Rects
    
    var innerRect: NSRect { return contentView.bounds }
    let tabbarHeight = kSBTabbarHeight
    
    var tabbarRect: NSRect {
        var r = NSZeroRect
        r.size.width = innerRect.size.width
        r.size.height = tabbarHeight
        r.origin.y = tabbarVisibility ? innerRect.size.height - r.size.height : innerRect.size.height
        return r
    }
    
    var splitViewRect: NSRect {
        var r = NSZeroRect
        r.size.width = innerRect.size.width
        r.size.height = tabbarVisibility ? innerRect.size.height - tabbarHeight : innerRect.size.height
        return r
    }
    
    var sheetPosition: CGFloat { return splitViewRect.size.height }
    
    // MARK: Responding
    
    override func performKeyEquivalent(event: NSEvent) -> Bool {
        if sbDelegate?.window?(self, shouldHandleKeyEvent: event) ?? false {
            return true
        }
        return super.performKeyEquivalent(event)
    }
    
    // MARK: Actions
    
    override func performClose(sender: AnyObject?) {
        if sbDelegate?.window?(self, shouldClose: sender) ?? true {
            super.performClose(sender)
        }
    }
    
    // MARK: Menu validation
    
    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        if menuItem.action == "toggleToolbarShown:" {
            menuItem.title = toolbar.visible ? NSLocalizedString("Hide Toolbar", comment: "") : NSLocalizedString("Show Toolbar", comment: "")
            return coverWindow == nil
        }
        return super.validateMenuItem(menuItem)
    }
    
    // MARK: Actions
    
    override func zoom(sender: AnyObject?) {
        if coverWindow == nil {
            super.zoom(sender)
        }
    }
    
    func destructCoverWindow() {
        if coverWindow != nil {
            removeChildWindow(coverWindow!)
            coverWindow!.close()
            coverWindow = nil
        }
        showsToolbarButton = true
    }
    
    func showCoverWindow(view: SBView) {
        var r = view.frame
        let size = innerRect.size
        r.origin.x = (size.width - r.size.width) / 2
        r.origin.y = (size.height - r.size.height) / 2
        view.frame = r
        constructCoverWindowWithView(view)
    }
    
    func constructCoverWindowWithView(view: NSView) {
        let vr = view.frame
        let br = splitView!.bounds
        var r = NSZeroRect
        let hasHorizontalScroller = vr.size.width > br.size.width
        let hasVerticalScroller = vr.size.height > br.size.height
        r.origin.x = hasHorizontalScroller ? br.origin.x : vr.origin.x
        r.size.width = hasHorizontalScroller ? br.size.width : vr.size.width
        r.origin.y = hasVerticalScroller ? br.origin.y : vr.origin.y
        r.size.height = hasVerticalScroller ? br.size.height : vr.size.height
        destructCoverWindow()
        coverWindow = SBCoverWindow(parentWindow: self, size: br.size)
        let scrollView = SBBLKGUIScrollView(frame: NSIntegralRect(r))
        scrollView.autoresizingMask = .ViewWidthSizable | .ViewHeightSizable
        scrollView.hasHorizontalScroller = hasHorizontalScroller
        scrollView.hasVerticalScroller = hasVerticalScroller
        scrollView.drawsBackground = false
        coverWindow!.contentView.addSubview(scrollView)
        coverWindow!.releasedWhenClosed = false
        scrollView.documentView = view
        self.showsToolbarButton = false
        
        #if true
            addChildWindow(coverWindow, ordered: .Above)
            coverWindow!.makeKeyWindow()
        #else
            coverWindow.contentView.hidden = true
            NSApp.beginSheet(coverWindow, modalForWindow: self, modalDelegate: self, didEndSelector: "coverWindowDidEnd:returnCode:contextInfo:", contextInfo: nil)
            
            animation = NSViewAnimation(viewAnimations: [[
                NSViewAnimationTargetKey: coverWindow.contentView,
                NSViewAnimationEffectKey: NSViewAnimationFadeInEffect]])
            animation.duration = 0.35
            animation.animationBlockingMode = .NonblockingThreaded
            animation.animationCurve = .EaseIn
            animation.delegate = self
            animation.startAnimation()
            coverWindow.contentView.hidden = false
        #endif
    }

    #if true
        func hideCoverWindow() {
            removeChildWindow(coverWindow)
            coverWindow!.orderOut(nil)
            destructCoverWindow()
            makeKeyWindow()
        }
    #else
        func animationDidStop(animation: NSAnimation) {
            if coverWindow?.contentView != nil {
                coverWindow!.contentView!.hidden = false
            }
        }
        
        func coverWindowDidEnd(window: NSWindow, returnCode: Int, contextInfo: AnyObject?) {
            destructCoverWindow()
        }
        
        func hideCoverWindow() {
            NSApp.endSheet(coverWindow)
        }
    #endif
    
    func hideToolbar() {
        if toolbar.visible {
            toggleToolbarShown(self)
        }
    }
    
    func showToolbar() {
        if !toolbar.visible {
            toggleToolbarShown(self)
        }
    }
    
    func hideTabbar() {
        if tabbarVisibility {
            tabbarVisibility = false
            tabbar!.frame = tabbarRect
            splitView!.frame = splitViewRect
        }
    }

    func showTabbar() {
        if !tabbarVisibility {
            tabbarVisibility = true
            tabbar!.frame = tabbarRect
            splitView!.frame = splitViewRect
        }
    }
    
    func flip() {
        var doneRect = NSZeroRect
        doneRect.size.width = 105.0
        doneRect.size.height = 24.0
        let doneButton = SBBLKGUIButton(frame: doneRect)
        doneButton.title = NSLocalizedString("Done", comment: "")
        doneButton.target = self
        doneButton.action = "doneFlip"
        doneButton.enabled = true
        doneButton.keyEquivalent = "\r"
        flip(doneButton)
    }
    
    func flip(view: NSView) {
        var br = frame
        br.size.width = kSBBackWindowFrameWidth
        br.size.height = kSBBackWindowFrameHeight
        br.origin.x = frame.origin.x + (frame.size.width - br.size.width) / 2
        br.origin.y = frame.origin.y + (frame.size.height - br.size.height) / 2;
        br.size.height -= 23.0
        backWindow = NSWindow(contentRect: br, styleMask: (NSTitledWindowMask | NSClosableWindowMask), backing: .Buffered, defer: true)
        backWindow!.backgroundColor = SBWindowBackColor
        backWindow!.releasedWhenClosed = false
        view.frame = NSMakeRect((br.size.width - view.frame.size.width) / 2, (br.size.height - view.frame.size.height) / 2, view.frame.size.width, view.frame.size.height)
        backWindow!.contentView.addSubview(view)
        backWindow!.makeKeyAndOrderFront(nil)
        alphaValue = 0
    }
    
    func doneFlip() {
        backWindow?.close()
        backWindow = nil
        alphaValue = 1
    }
}