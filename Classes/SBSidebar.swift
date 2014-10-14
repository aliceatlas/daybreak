/*
SBSidebar.swift

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

// Sidebar positions
enum SBSidebarPosition: Int {
	case Left
    case Right
}

@objc protocol SBSidebarDelegate: NSSplitViewDelegate {
    optional func sidebarShouldOpen(SBSidebar)
    optional func sidebarShouldClose(SBSidebar)
    optional func sidebarDidOpenDrawer(SBSidebar)
    // func sidebar(SBSidebar, didDraggedResizer deltaX: CGFloat) -> CGFloat
}

@objc protocol SBSideBottombarDelegate {
    optional func bottombarDidSelectedOpen(SBSideBottombar)
    optional func bottombarDidSelectedClose(SBSideBottombar)
    optional func bottombarDidSelectedDrawerOpen(SBSideBottombar)
    optional func bottombarDidSelectedDrawerClose(SBSideBottombar)
    optional func bottombar(inBottombar: SBSideBottombar, didChangeSize: CGFloat)
    // func bottombar(SBSidebar, didDraggedResizer deltaX: CGFloat) -> CGFloat
}

class SBSidebar: NSSplitView, SBDownloadsViewDelegate, SBSideBottombarDelegate, NSAnimationDelegate {
    var view: NSView? {
        didSet {
            if view !== oldValue {
                if let resourcesView = oldValue as? SBWebResourcesView {
                    resourcesView.dataSource = nil
                }
                oldValue?.removeFromSuperview()
                if let view = view {
                    view.frame = viewRect
                    if !subviews.isEmpty {
                        addSubview(view, positioned: .Below, relativeTo: subviews[0] as NSView)
                    } else {
                        addSubview(view)
                    }
                }
            }
        }
    }
    
    var drawer: SBDrawer? {
        didSet {
            if drawer !== oldValue {
                oldValue?.removeFromSuperview()
                bottombar.removeFromSuperview()
                if drawer != nil {
                    addSubview(drawer!)
                    drawer!.addSubview(bottombar)
                }
            }
        }
    }
    
    private lazy var _bottombar: SBSideBottombar = {
        let bottombar = SBSideBottombar(frame: self.bottombarRect)
        bottombar.delegate = self
        bottombar.position = self.position
        bottombar.drawerVisibility = self.visibleDrawer
        bottombar.autoresizingMask = .ViewWidthSizable | .ViewMaxYMargin
        return bottombar
    }()
    var bottombar: SBSideBottombar { return _bottombar }
    
    var position: SBSidebarPosition = .Left {
        didSet {
            bottombar.position = position
        }
    }
    
    weak var sidebarDelegate: SBSidebarDelegate?
    
    private var divideAnimation: NSViewAnimation?
    
    var drawerHeight: CGFloat = 0
    
    var visibleDrawer: Bool {
        return drawer &! {$0.frame.size.height > kSBBottombarHeight}
    }
    
    var animating: Bool {
        return divideAnimation != nil
    }
    
    override var description: String {
        return "<\(className): \(self) frame = \(self.frame)>"
    }
    
    // MARK: Construction
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        vertical = false
        dividerStyle = .Thin
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    // MARK: Destruction
    
    deinit {
        destructDividerAnimation()
        sidebarDelegate = nil
    }
    
    func destructDividerAnimation() {
        divideAnimation = nil
    }
    
    // MARK: Rects
    
    var viewRect: NSRect {
        var r = bounds
        r.size.height -= drawerHeight
        return r
    }
    
    var drawerRect: NSRect {
        var r = bounds
        r.size.height = drawerHeight - kSBBottombarHeight
        return r
    }
    
    var bottombarRect: NSRect {
        var r = bounds
        r.size.height = kSBBottombarHeight
        return r
    }
    
    // MARK: Delegate
    
    func downloadsViewDidRemoveAllItems(downloadsView: SBDownloadsView) {
        closeDrawer(nil)
    }
    
    func bottombarDidSelectedOpen(inBottombar: SBSideBottombar) {
        sidebarDelegate?.sidebarShouldOpen?(self)
    }
    
    func bottombarDidSelectedClose(inBottombar: SBSideBottombar) {
        sidebarDelegate?.sidebarShouldClose?(self)
    }
    
    func bottombarDidSelectedDrawerOpen(inBottombar: SBSideBottombar) {
        if !animating {
            openDrawer(nil)
        }
        
        sidebarDelegate?.sidebarDidOpenDrawer?(self)
    }
    
    func bottombarDidSelectedDrawerClose(inBottombar: SBSideBottombar) {
        if !animating {
            closeDrawer(nil)
        }
    }
    
    func bottombar(inBottombar: SBSideBottombar, didChangeSize size: CGFloat) {
        if let view = view as? SBBookmarksView {
            view.cellWidth = size
        }
    }
    
    func animationDidEnd(animation: NSAnimation) {
        if animation == divideAnimation {
            destructDividerAnimation()
            adjustSubviews()
        }
    }
    
    // MARK: SplitView
    
    override var dividerThickness: CGFloat { return 1.0 }
    
    override func drawDividerInRect(rect: NSRect) {
        NSColor(calibratedWhite: 0.0, alpha: 1.0).set()
        NSRectFill(rect)
    }
    
    // MARK: Actions
    
    func setDividerPosition(pos: CGFloat, animate: Bool = false) {
        let subview0 = view!
        let subview1 = drawer!
        var r0 = subview0.frame
        var r1 = subview1.frame
        r0.size.height = pos
        r1.origin.y = r0.size.height
        r1.size.height = bounds.size.height - pos
        if animate {
            let duration: NSTimeInterval = 0.25
            let animations = [[NSViewAnimationTargetKey: subview0,
                               NSViewAnimationEndFrameKey: NSValue(rect: r0)],
                              [NSViewAnimationTargetKey: subview1,
                               NSViewAnimationEndFrameKey: NSValue(rect: r1)]]
            destructDividerAnimation()
            divideAnimation = NSViewAnimation(viewAnimations: animations)
            divideAnimation!.duration = duration
            divideAnimation!.delegate = self
            divideAnimation!.startAnimation()
        } else {
            subview0.frame = r0
            subview1.frame = r1
            adjustSubviews()
        }
    }
    
    func openDrawer(sender: AnyObject?) {
        let pos = bounds.size.height - drawerHeight
        setDividerPosition(pos, animate: true)
        bottombar.drawerVisibility = true
    }
    
    func closeDrawer(sender: AnyObject?) {
        closeDrawer(animatedFlag: true)
    }
    
    @objc(closeDrawerWithAnimatedFlag:)
    func closeDrawer(animatedFlag animated: Bool) {
        let pos = bounds.size.height - kSBBottombarHeight
        setDividerPosition(pos, animate: animated)
        bottombar.drawerVisibility = false
    }
    
    func showBookmarkItemIndexes(indexes: NSIndexSet) {
    }
}


class SBSideBottombar: SBBottombar {
    override var frame: NSRect {
        didSet {
            if frame != oldValue {
                adjustButtons()
            }
        }
    }
    
    var position: SBSidebarPosition? {
        didSet {
            if position != oldValue {
                drawerButton.frame = drawerButtonRect
                newFolderButton.frame = newFolderButtonRect
                sizeSlider.frame = sizeSliderRect
                if position != nil {
                    drawerButton.autoresizingMask = (position! == .Left) ? .ViewMinXMargin : .ViewMaxXMargin
                    newFolderButton.autoresizingMask = drawerButton.autoresizingMask
                }
                adjustButtons()
                needsDisplay = true
            }
        }
    }
    
    private var buttons: [SBButton] = []
    
    private lazy var drawerButton: SBButton = {
        let drawerButton = SBButton(frame: self.drawerButtonRect)
        if self.position == .Left {
            drawerButton.autoresizingMask = .ViewMinXMargin
        }
        drawerButton.target = self
        drawerButton.action = "toggleDrawer"
        return drawerButton
    }()
    
    private lazy var newFolderButton: SBButton = {
        let newFolderButton = SBButton(frame: self.newFolderButtonRect)
        if self.position == .Left {
            newFolderButton.autoresizingMask = .ViewMinXMargin
        }
        newFolderButton.title = NSLocalizedString("New Folder", comment: "")
        newFolderButton.target = self
        newFolderButton.action = "newFolder"
        return newFolderButton
    }()
    
    lazy var sizeSlider: SBBLKGUISlider = {
        let sizeSlider = SBBLKGUISlider(frame: self.sizeSliderRect)
        (sizeSlider.cell() as NSCell).controlSize = .SmallControlSize
        sizeSlider.minValue = kSBBookmarkCellMinWidth
        sizeSlider.maxValue = kSBBookmarkCellMaxWidth
        sizeSlider.floatValue = Float(kSBBookmarkCellMinWidth)
        sizeSlider.target = self
        sizeSlider.action = "slide"
        sizeSlider.autoresizingMask = .ViewMinXMargin
        return sizeSlider
    }()
    
    weak var delegate: SBSideBottombarDelegate?
    
    var drawerVisibility: Bool = false {
        didSet {
            if drawerVisibility != oldValue || drawerButton.image == nil {
                drawerButton.image = NSImage(named: (drawerVisibility ? "ResizerDown.png" : "ResizerUp.png"))
            }
        }
    }
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        drawerVisibility = false
        addSubview(drawerButton)
        buttons.append(drawerButton)
        // addSubview(newFolderButton)
        // buttons.append(newFolderButton)
        addSubview(sizeSlider)
    }
        
    // MARK: Rects
    
    var buttonWidth: CGFloat { return bounds.size.height }
    
    var sliderWidth: CGFloat {
        let width = bounds.size.width - kSBSidebarResizableWidth * 2 - sliderSideMargin * 2
        return SBConstrain(width, max: 120.0)
    }
    
    let sliderSideMargin: CGFloat = 10.0
    
    var resizableRect: NSRect {
        var r = NSZeroRect
        r.size.width = kSBSidebarResizableWidth
        r.size.height = bounds.size.height
        if position == .Left {
            r.origin.x = bounds.size.width - r.size.width
        }
        return r
    }
    
    var drawerButtonRect: NSRect {
        var r = NSZeroRect
        r.size.width = buttonWidth
        r.size.height = buttonWidth
        if position == .Left {
            r.origin.x = bounds.size.width - (r.size.width + kSBSidebarResizableWidth)
        } else if position == .Right {
            r.origin.x = kSBSidebarResizableWidth
        }
        return r
    }
    
    var newFolderButtonRect: NSRect {
        var r = NSZeroRect
        r.size.width = kSBSidebarNewFolderButtonWidth
        r.size.height = buttonWidth
        if position == .Left {
            r.origin.x = drawerButtonRect.maxX - kSBSidebarNewFolderButtonWidth
        } else if position == .Right {
            r.origin.x = drawerButtonRect.maxX
        }
        return r
    }
    
    var sizeSliderRect: NSRect {
        var r = NSZeroRect
        let leftMargin = sliderSideMargin
        let rightMargin = sliderSideMargin + kSBSidebarResizableWidth
        r.size.width = sliderWidth
        r.size.height = 21.0
        if position == .Left {
            r.origin.x = leftMargin
        } else if position == .Right {
            r.origin.x = bounds.size.width - (r.size.width + rightMargin)
        }
        return r
    }
    
    // MARK: Actions
    
    func adjustButtons() {
        var validRect = NSZeroRect
        if position == .Left {
            validRect.origin.x = sizeSliderRect.maxX
            validRect.size.width = bounds.size.width - sizeSliderRect.maxX - kSBSidebarResizableWidth
            validRect.size.height = bounds.size.height
        } else if position == .Right {
            validRect.origin.x = kSBSidebarResizableWidth
            validRect.size.width = sizeSliderRect.origin.x - kSBSidebarResizableWidth
            validRect.size.height = bounds.size.height
        }
        for button in buttons {
            button.hidden = !validRect.contains(button.frame)
        }
        sizeSlider.frame = sizeSliderRect
    }
    
    // MARK: Execute
    
    func open() {
        delegate?.bottombarDidSelectedOpen?(self)
    }
    
    func close() {
        delegate?.bottombarDidSelectedClose?(self)
    }
    
    func toggleDrawer() {
        drawerVisibility = !drawerVisibility
        if drawerVisibility {
            delegate?.bottombarDidSelectedDrawerOpen?(self)
        } else {
            delegate?.bottombarDidSelectedDrawerClose?(self)
        }
    }
    
    func newFolder() {
    }
    
    func slide() {
        if let f: (SBSideBottombar, didChangeSize: CGFloat) -> Void = delegate?.bottombar {
            let value = SBConstrain(sizeSlider.doubleValue, min: kSBBookmarkCellMinWidth, max: kSBBookmarkCellMaxWidth)
            f(self, didChangeSize: CGFloat(value))
            if value != sizeSlider.doubleValue {
                sizeSlider.doubleValue = value
            }
        }
    }
    
    // MARK: Drawing
    
    override func drawRect(rect: NSRect) {
        super.drawRect(rect)
        
        var r = resizableRect
        let resizerImage = NSImage(named: "Resizer.png")!
        resizerImage.drawInRect(r, fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1.0)
        if position == .Left {
            r.origin.x = r.origin.x - 1
            r.size.width = 1
        } else if position == .Right {
            r.origin.x = r.maxX + 1
            r.size.width = 1
        }
        NSColor.blackColor().set()
        NSRectFill(r)
        if position == .Left {
            r.origin.x = r.origin.x + 1
        } else if position == .Right {
            r.origin.x = r.origin.x + 1
        }
        NSColor(deviceWhite: 0.3, alpha: 1.0).set()
        NSRectFill(r)
    }
}