/*
SBSplitView.swift

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

@objc protocol SBSplitViewDelegate: NSSplitViewDelegate {
    optional func splitViewDidOpenDrawer(SBSplitView)
}

class SBSplitView: NSSplitView, SBSidebarDelegate {
    private var divideAnimation: NSViewAnimation?
    var animating: Bool { return divideAnimation != nil }
    var visibleSidebar: Bool { return sidebar?.superview != nil }
    var sidebarWidth = CGFloat(NSUserDefaults.standardUserDefaults().doubleForKey(kSBSidebarWidth))
    
    var view: NSView! {
        didSet {
            if view !== oldValue {
                oldValue?.removeFromSuperview()
                addSubview(view)
            }
        }
    }
    
    var sidebar: SBSidebar! {
        didSet {
            if sidebar !== oldValue {
                oldValue?.removeFromSuperview()
                addSubview(sidebar)
                switchView(sidebarPosition)
            }
        }
    }
    
    var sidebarPosition: SBSidebarPosition = SBSidebarPosition(rawValue: NSUserDefaults.standardUserDefaults().integerForKey(kSBSidebarPosition))! {
        didSet {
            if sidebarPosition != oldValue {
                switchView(sidebarPosition)
                sidebar.position = sidebarPosition
                if visibleSidebar {
                    openSidebar(nil)
                }
            }
        }
    }
    
    var invisibleDivider = false
    override var dividerThickness: CGFloat {
        return invisibleDivider ? 0.0 : 1.0
    }
    
    var sbDelegate: SBSplitViewDelegate? {
        get { return delegate as? SBSplitViewDelegate }
        set(sbDelegate) { delegate = sbDelegate }
    }

    override init(frame: NSRect) {
        super.init(frame: frame)
        if sidebarWidth < kSBSidebarMinimumWidth {
            sidebarWidth = kSBDefaultSidebarWidth
        }
        vertical = true
        dividerStyle = .Thin
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    deinit {
        divideAnimation = nil
    }
    
    // MARK: Rects
    
    var viewRect: NSRect {
        var r = bounds
        r.size.width -= sidebarWidth
        return r
    }
    
    var sidebarRect: NSRect {
        var r = bounds
        r.size.width = sidebarWidth
        return r
    }
    
    // MARK: SplitView
    
    override func drawDividerInRect(rect: NSRect) {
        NSColor.blackColor().set()
        NSRectFill(rect)
    }
    
    // MARK: Delegate
    
    func sidebarShouldOpen(sidebar: SBSidebar) {
        openSidebar(nil)
    }
    
    func sidebarShouldClose(sidebar: SBSidebar) {
        closeSidebar(nil)
    }
    
    func sidebarDidOpenDrawer(sidebar: SBSidebar) {
        sbDelegate?.splitViewDidOpenDrawer?(self)
    }
    
    override func adjustSubviews() {
        if !animating {
            super.adjustSubviews()
        }
    }
    
    // MARK: Actions
    
    func openSidebar(sender: AnyObject?) {
        SBConstrain(&sidebarWidth, min: kSBSidebarMinimumWidth)
        returnSidebarIfNeeded()
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: kSBSidebarVisibilityFlag)
    }
    
    func closeSidebar(sender: AnyObject?) {
        takeSidebarIfNeeded()
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: kSBSidebarVisibilityFlag)
    }
    
    func switchView(position: SBSidebarPosition) {
        var switching = false
        let subviews: [NSView] = self.subviews
        let subview0 = subviews.get(0)
        let subview1 = subviews.get(1)
        if position == .Left && subview0 === view && subview1 === sidebar {
            switching = true
        } else if position == .Right && subview0 === sidebar && subview1 === view {
            switching = true
        }
        if switching {
            if subview0 != nil {
                subview0!.removeFromSuperview()
                addSubview(subview0!)
            }
        }
    }
    
    func takeSidebarIfNeeded() {
        invisibleDivider = true
        if sidebar.superview === self {
            takeSidebar()
            sidebar.frame = sidebarRect
        }
        view.frame = viewRect
        adjustSubviews()
    }
    
    func takeSidebar() {
        sidebar.removeFromSuperview()
    }
    
    func returnSidebarIfNeeded() {
        invisibleDivider = false
        if sidebar.superview !== self {
            returnSidebar()
        }
        view.frame = viewRect
        sidebar.frame = sidebarRect
        adjustSubviews()
    }
    
    func returnSidebar() {
        if sidebarPosition == .Left {
            view.removeFromSuperview()
            addSubview(sidebar)
            addSubview(view)
        } else if sidebarPosition == .Right {
            addSubview(sidebar)
        }
    }
}