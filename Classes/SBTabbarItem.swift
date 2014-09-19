/*
SBTabbarItem.swift

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

class SBTabbarItem: SBView {
    unowned var tabbar: SBTabbar
    private var _tag: Int = -1
    override var tag: Int {
        get { return _tag }
        set(tag) { _tag = tag }
    }
    var image: NSImage?
    var closeSelector: Selector = nil
    var selectSelector: Selector = nil
    private var downInClose = false
    private var dragInClose = false
    private var area: NSTrackingArea!
    
    lazy var progressIndicator: SBCircleProgressIndicator = {
        let progressIndicator = SBCircleProgressIndicator(frame: self.progressRect)
        progressIndicator.autoresizingMask = .ViewMinXMargin
        return progressIndicator
    }()
    
    var progress: CGFloat {
        get { return progressIndicator.progress }
        set(progress) { progressIndicator.progress = progress }
    }
    
    override var keyView: Bool {
        willSet {
            progressIndicator.keyView = newValue
        }
    }
    
    override var toolbarVisible: Bool {
        didSet {
            if toolbarVisible != oldValue {
                progressIndicator.toolbarVisible = toolbarVisible
                needsDisplay = true
            }
        }
    }
    
    var title: String = "" {
        didSet {
            if title != oldValue {
                needsDisplay = true
            }
        }
    }
    
    var selected: Bool = false {
        didSet {
            if selected != oldValue {
                progressIndicator.selected = selected
                needsDisplay = true
            }
        }
    }
    
    var closable: Bool = false {
        didSet {
            if closable != oldValue {
                needsDisplay = true
            }
        }
    }
    
    init(frame: NSRect, tabbar: SBTabbar) {
        self.tabbar = tabbar
        super.init(frame: frame)
        area = NSTrackingArea(rect: bounds, options: (.MouseEnteredAndExited | .MouseMoved | .ActiveAlways | .InVisibleRect), owner: self, userInfo: nil)
        addSubview(progressIndicator)
        addTrackingArea(area)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    // MARK: Rects
    
    var closableRect: CGRect {
        let across: CGFloat = 12.0;
        let margin: CGFloat = (bounds.size.height - across) / 2
        return CGRectMake(margin, margin, across, across)
    }
    
    var progressRect: CGRect {
        let across: CGFloat = 18.0
        let margin: CGFloat = (bounds.size.height - across) / 2
        return CGRectMake(bounds.size.width - margin - across, margin, across, across)
    }
    
    // MARK: Exec
    
    func executeShouldClose() {
        if (target !! closeSelector) != nil {
            if target.respondsToSelector(closeSelector) {
                SBPerform(target, closeSelector, self)
            }
        }
    }
    
    func executeShouldSelect() {
        if (target !! selectSelector) != nil {
            if target.respondsToSelector(selectSelector) {
                SBPerform(target, selectSelector, self)
            }
        }
    }
    
    // MARK: Event
    
    override func mouseDown(event: NSEvent) {
        let location = event.locationInWindow
        let point = convertPoint(location, fromView: nil)
        dragInClose = false
        if closable {
            downInClose = CGRectContainsPoint(closableRect, point)
            if downInClose {
                // Close
                dragInClose = true
                needsDisplay = true
            }
        }
        if !dragInClose {
            superview!.mouseDown(event)
            if !selected {
                executeShouldSelect()
            } else {
                tabbar.executeShouldReselect(self)
            }
        }
    }
    
    override func mouseDragged(event: NSEvent) {
        let location = event.locationInWindow
        let point = convertPoint(location, fromView: nil)
        if downInClose {
            // Close
            let close =  CGRectContainsPoint(closableRect, point)
            if dragInClose != close {
                dragInClose = close
                needsDisplay = true
            }
        } else {
            superview!.mouseDragged(event)
        }
    }
    
    override func mouseMoved(event: NSEvent) {
        if tabbar.canClosable {
            let location = event.locationInWindow
            let point = convertPoint(location, fromView: nil)
            superview!.mouseMoved(event)
            if CGRectContainsPoint(bounds, point) {
                tabbar.constructClosableTimerForItem(self)
            } else {
                tabbar.applyDisclosableAllItem()
            }
        }
    }
    
    override func mouseEntered(event: NSEvent) {
        superview!.mouseEntered(event)
    }
    
    override func mouseExited(event: NSEvent) {
        superview!.mouseExited(event)
        if tabbar.canClosable {
            tabbar.applyDisclosableAllItem()
        }
    }
    
    override func mouseUp(event: NSEvent) {
        let location = event.locationInWindow
        let point = convertPoint(location, fromView: nil)
        if downInClose {
            // Close
            if closable {
                if CGRectContainsPoint(closableRect, point) {
                    executeShouldClose()
                }
            }
        } else {
            superview!.mouseUp(event)
        }
        dragInClose = false
        downInClose = false
        needsDisplay = true
    }
    
    override func menuForEvent(event: NSEvent) -> NSMenu {
        return tabbar.menuForItem(self)
    }

    // MARK: Drawing

    override func drawRect(rect: NSRect) {
        var path: NSBezierPath!
        var strokePath: NSBezierPath!
        var grayScaleDown: CGFloat!
        var grayScaleUp: CGFloat!
        var strokeGrayScale: CGFloat!
        var titleLeftMargin: CGFloat = 10.0
        let titleRightMargin = bounds.size.width - progressRect.origin.x
        
        // Paths
        // Gray scales
        if selected {
            path = SBRoundedPathS(CGRectInset(bounds, 0.0, 0.0), 4.0, 0.0, false, true)
            strokePath = SBRoundedPathS(CGRectInset(bounds, 0.5, 0.5), 4.0, 0.0, false, true)
            grayScaleDown = CGFloat(keyView ? 140 : 207) / CGFloat(255.0)
            grayScaleUp = CGFloat(keyView ? 175 : 222) / CGFloat(255.0)
            strokeGrayScale = 0.2
        } else {
            path = SBRoundedPathS(CGRectInset(bounds, 0.0, 1.0), 4.0, 0.0, true, false)
            strokePath = SBRoundedPathS(CGRectInset(bounds, 0.5, 1.0), 4.0, 0.0, true, false)
            grayScaleDown = (keyView ? 130 : 207) / CGFloat(255.0)
            grayScaleUp = (keyView ? 140 : 207) / CGFloat(255.0)
            strokeGrayScale = 0.4
        }
        
        // Frame
        let strokeColor = NSColor(deviceWhite: strokeGrayScale, alpha: 1.0)
        let gradient = NSGradient(startingColor: NSColor(deviceWhite: grayScaleDown, alpha: 1.0),
                                  endingColor: NSColor(deviceWhite: grayScaleUp, alpha: 1.0))
        gradient.drawInBezierPath(path, angle: 90)
        
        // Stroke
        strokeColor.set()
        strokePath.lineWidth = 0.5
        strokePath.stroke()
        
        if closable {
            // Close button
            var p = CGPointZero
            let across = closableRect.size.width
            let length: CGFloat = 10.0
            let margin = closableRect.origin.x
            let lineWidth: CGFloat = 2
            let center = margin + across / 2
            let closeGrayScale: CGFloat = dragInClose ? 0.2 : 0.4
            let xPath = NSBezierPath()
            let t = NSAffineTransform()
            t.translateXBy(center, yBy: center)
            t.rotateByDegrees(-45)
            p.x = -length / 2
            xPath.moveToPoint(t.transformPoint(p))
            p.x = length / 2
            xPath.lineToPoint(t.transformPoint(p))
            p.x = 0
            p.y = -length / 2
            xPath.moveToPoint(t.transformPoint(p))
            p.y = length / 2
            xPath.lineToPoint(t.transformPoint(p))
            
            // Ellipse
            NSColor(deviceWhite: closeGrayScale, alpha: 1.0).set()
            path = NSBezierPath(ovalInRect: closableRect)
            path.lineWidth = lineWidth
            path.fill()
            
            // Close
            NSColor(deviceWhite: grayScaleUp, alpha: 1.0).set()
            xPath.lineWidth = lineWidth
            xPath.stroke()
            
            titleLeftMargin = across + margin * 2
        }
        
        if !title.isEmpty {
            // Title
            var size = NSZeroSize
            var r = NSZeroRect
            let width = bounds.size.width - titleLeftMargin - titleRightMargin
            let shadow = NSShadow()
            let paragraphStyle = NSMutableParagraphStyle()
            shadow.shadowColor = NSColor(calibratedWhite: 1.0, alpha: 1.0)
            shadow.shadowOffset = NSMakeSize(0, -0.5)
            shadow.shadowBlurRadius = 0.5
            paragraphStyle.lineBreakMode = .ByTruncatingTail
            let attributes = [
                NSFontAttributeName: NSFont.boldSystemFontOfSize(12.0),
                NSForegroundColorAttributeName: NSColor(calibratedWhite: 0.1, alpha: 1.0),
                NSShadowAttributeName: shadow,
                NSParagraphStyleAttributeName: paragraphStyle]
            size = title.sizeWithAttributes(attributes)
            r.size = size
            if size.width > width {
                r.size.width = width
            }
            r.origin.x = titleLeftMargin + (width - r.size.width) / 2
            r.origin.y = (bounds.size.height - r.size.height) / 2
            title.drawInRect(r, withAttributes: attributes)
        }
    }
}