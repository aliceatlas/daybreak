/*
SBBookmarkListItemView.swift

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

class SBBookmarkListItemView: SBView, SBRenderWindowDelegate, SBAnswersIsFirstResponder {
    private lazy var progressIndicator: NSProgressIndicator = {
        var r = NSZeroRect
        r.size.width = 32.0
        r.size.height = r.size.width
        r.origin.x = (self.bounds.size.width - r.size.width) / 2
        r.origin.y = ((self.bounds.size.height - self.titleHeight - self.bytesHeight - self.padding.y) - r.size.height) / 2 + (self.titleHeight + self.bytesHeight + self.padding.y)
        let progressIndicator = NSProgressIndicator(frame: r)
        progressIndicator.style = .SpinningStyle
        progressIndicator.controlSize = .RegularControlSize
        return progressIndicator
    }()
    var mode = SBBookmarkMode.Icon
    var item: NSDictionary
    
    var selected: Bool = false {
        didSet { needsDisplay = true }
    }
    
    var dragged: Bool = false {
        didSet {
            alphaValue = dragged ? 0.5 : 1.0
        }
    }
    
    private lazy var area: NSTrackingArea = {
        NSTrackingArea(rect: self.bounds, options: (.MouseEnteredAndExited | .MouseMoved | .ActiveAlways | .InVisibleRect), owner: self, userInfo: nil)
    }()
    
    var isFirstResponder: Bool {
        return window &! {$0.firstResponder === self.superview}
    }
    
    var visible: Bool {
        return NSIntersectsRect(superview?.visibleRect ?? NSZeroRect, frame)
    }
    
    var titleFont: NSFont {
        return NSFont.boldSystemFontOfSize((mode == .Icon || mode == .List) ? 10.0 : 11.0)
    }
    
    var urlFont: NSFont {
        return NSFont.systemFontOfSize((mode == .Icon || mode == .List) ? 9.0 : 11.0)
    }
    
    var paragraphStyle: NSParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByTruncatingTail
        if mode == .Icon || mode == .List {
            paragraphStyle.alignment = .CenterTextAlignment
        }
        if mode == .List {
            paragraphStyle.alignment = .LeftTextAlignment
        }
        return paragraphStyle.copy() as NSParagraphStyle
    }
    
    init(frame: NSRect, item: NSDictionary) {
        self.item = item
        super.init(frame: frame)
        addTrackingArea(area)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    // MARK: View
    
    // Clicking through
    override func hitTest(point: NSPoint) -> NSView? {
        let view = super.hitTest(point)
        return (view == self) ? nil : view
    }
    
    // MARK: Rects
    
    var padding: NSPoint {
        let padding = bounds.size.width * kSBBookmarkCellPaddingPercentage
        return NSMakePoint(padding, padding)
    }
    
    var heights: CGFloat {
        return titleHeight + bytesHeight
    }
    
    let titleHeight: CGFloat = 15.0
    let bytesHeight: CGFloat = 12.0
    
    var imageRect: NSRect {
        var r = NSZeroRect
        let padding = (mode == .Icon) ? self.padding : NSZeroPoint
        let titleHeight /*: CGFloat */ = (mode == .Icon) ? self.titleHeight : 0.0
        let bytesHeight = (mode == .Icon) ? self.bytesHeight : 0.0
        let imageData = item[kSBBookmarkImage] as? NSData
        let image = imageData !! {NSImage(data: $0)}
        let imageSize = image?.size ?? NSZeroSize
        var p = NSZeroPoint
        var s: CGFloat!
        r.origin.x = padding.x
        r.origin.y = bytesHeight + titleHeight + padding.y * 2
        r.size.width = bounds.size.width - padding.x * 2
        r.size.height = bounds.size.height - r.origin.y - padding.y
        p.x = r.size.width / imageSize.width
        p.y = r.size.height / imageSize.height
        if (mode == .Icon) ? (p.x > p.y) : (p.x < p.y) {
            s = imageSize.width * p.y
            r.origin.x += (r.size.width - s) / 2
            r.size.width = s
        } else {
            s = imageSize.height * p.x
            r.origin.y += (r.size.height - s) / 2
            r.size.height = s
        }
        return r
    }
    
    var titleRect: NSRect {
        return (item[kSBBookmarkTitle] as? NSString) !! {self.titleRect($0)} ?? NSZeroRect
    }
    
    func titleRect(title: String) -> NSRect {
        var drawRect = bounds
        let margin = titleHeight / 2
        let availableWidth = bounds.size.width - titleHeight
        if title.utf16Count > 0 {
            let size = (title as NSString).sizeWithAttributes([NSFontAttributeName: titleFont, 
                                                               NSParagraphStyleAttributeName: paragraphStyle])
            if size.width <= availableWidth {
                drawRect.origin.x = (availableWidth - size.width) / 2
                drawRect.size.width = size.width
            } else {
                drawRect.size.width = availableWidth
            }
        } else {
            drawRect.size.width = availableWidth
        }
        var r = NSZeroRect
        r.size.width = drawRect.size.width
        r.size.height = titleHeight
        r.origin.x = margin + drawRect.origin.x
        r.origin.y = padding.y + bytesHeight
        return r
    }
    
    var bytesRect: NSRect {
        var r = NSZeroRect
        r.size.width = bounds.size.width
        r.size.height = bytesHeight
        r.origin.y = padding.y
        return r
    }
    
    // MARK: Actions
    
    func showProgress() {
        progressIndicator.startAnimation(nil)
        addSubview(progressIndicator)
    }
    
    func hideProgress() {
        progressIndicator.stopAnimation(nil)
        progressIndicator.removeFromSuperview()
    }
    
    func remove() {
        (target as? SBBookmarkListView)?.removeItemView(self)
    }
    
    func edit() {
        (target as? SBBookmarkListView)?.editItemView(self)
    }
    
    func update() {
        let urlString = item[kSBBookmarkURL] as? NSString
        if let url = urlString !! {NSURL(string: $0)} {
            let window = SBRenderWindow.startRenderingWithSize(NSMakeSize(800, 600), delegate: self, url: url)
            window.releasedWhenClosed = false
        }
    }
    
    func hitToPoint(point: NSPoint) -> Bool {
        var r = false
        if mode == .Icon || mode == .Tile {
            r = NSPointInRect(point, imageRect) | NSPointInRect(point, titleRect) | NSPointInRect(point, bytesRect)
        } else if mode == .List {
            r = NSPointInRect(point, bounds)
        }
        return r
    }
    
    func hitToRect(rect: NSRect) -> Bool {
        var r = false
        if mode == .Icon || mode == .Tile {
            r = NSIntersectsRect(rect, imageRect) | NSIntersectsRect(rect, titleRect) | NSIntersectsRect(rect, bytesRect)
        } else if mode == .List {
            r = NSIntersectsRect(rect, bounds)
        }
        return r;
    }
    
    // MARK: Delegate

    func renderWindowDidStartRendering(renderWindow: SBRenderWindow) {
        showProgress()
    }
    
    func renderWindow(renderWindow: SBRenderWindow, didFinishRenderingImage image: NSImage) {
        let data = image.bitmapImageRep.data
        var mItem: [NSObject: AnyObject] = item
        mItem[kSBBookmarkImage as NSString] = data
        SBBookmarks.sharedBookmarks.replaceItem(item, withItem: mItem)
        hideProgress()
        renderWindow.close()
    }
    
    func renderWindow(renderWindow: SBRenderWindow, didFailWithError error: NSError) {
        hideProgress()
        renderWindow.close()
    }
    
    // MARK: Event
    
    override func mouseEntered(event: NSEvent) {
        (superview as SBBookmarkListView).layoutToolsForItem(self)
    }

    override func mouseMoved(event: NSEvent) {
        let location = event.locationInWindow
        let point = convertPoint(location, fromView: nil)
        if NSPointInRect(point, bounds) {
            (superview as SBBookmarkListView).layoutToolsForItem(self)
        }
    }
    
    override func mouseExited(event: NSEvent) {
        (superview as SBBookmarkListView).layoutToolsHidden()
    }
    
    // MARK: Drawing
    
    override func drawRect(rect: NSRect) {
        if visible {
            var r = NSZeroRect
            let imageData = item[kSBBookmarkImage] as? NSData
            let title = item[kSBBookmarkTitle] as? NSString
            let urlString = item[kSBBookmarkURL] as? NSString
            let labelColorName = item[kSBBookmarkLabelName] as? NSString
            let labelColor = labelColorName !! {NSColor(labelColorName: $0)}
            var size = NSZeroSize //???
            
            if mode == .Icon {
                // image
                if let image = imageData !! {NSImage(data: $0)} {
                    r = imageRect
                    
                    // frame
                    if isFirstResponder && selected {
                        let color = SBAlternateSelectedControlColor
                        let fr = CGRectInset(r, -padding.x / 1.5, -padding.y / 1.5)
                        let path = SBRoundedPath(fr, 6.0, 0.0, true, true)
                        SBPreserveGraphicsState {
                            color.colorWithAlphaComponent(0.25).set()
                            path.fill()
                            color.set()
                            path.lineWidth = 1.5
                            path.stroke()
                        }
                    }
                    let path = SBRoundedPath(r, 6.0, 0.0, true, true)
                    let shadow = NSShadow()
                    shadow.shadowColor = NSColor(calibratedWhite: 0.0, alpha: 0.6)
                    shadow.shadowBlurRadius = 5.0
                    shadow.shadowOffset = CGSizeMake(0, -2.0)
                    SBPreserveGraphicsState {
                        shadow.set()
                        NSColor.whiteColor().set()
                        path.fill()
                    }
                    SBPreserveGraphicsState {
                        path.addClip()
                        image.drawInRect(r, fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1.0)
                    }
                }
                // title string
                if let title = title {
                    let margin = titleHeight / 2
                    
                    r = titleRect(title)
                    
                    if labelColor != nil {
                        // Label color
                        var sr = r
                        let tmargin = margin - 1.0
                        sr.origin.x -= tmargin
                        sr.size.width += tmargin * 2
                        //sr = NSInsetRect(sr, 2.0, 2.0)
                        let path = SBRoundedPath(sr, sr.size.height / 2, 0.0, true, true)
                        labelColor!.set()
                        path.fill()
                    }
                    
                    if selected {
                        // Background
                        var sr = r
                        let tmargin = margin - 1.0
                        let color = isFirstResponder ? SBAlternateSelectedControlColor : NSColor(calibratedWhite: 0.8, alpha: 1.0)
                        sr.origin.x -= tmargin
                        sr.size.width += tmargin * 2
                        if labelColor != nil {
                            sr = NSInsetRect(sr, 2.0, 2.0)
                        }
                        let path = SBRoundedPath(sr, sr.size.height / 2, 0.0, true, true)
                        color.set()
                        path.fill()
                    }
                    
                    var attributes = [NSFontAttributeName: titleFont,
                                      NSForegroundColorAttributeName: NSColor.whiteColor(),
                                      NSParagraphStyleAttributeName: paragraphStyle]
                    if labelColor != nil && !selected {
                        let shadow = NSShadow()
                        shadow.shadowOffset = NSMakeSize(0.0, -1.0)
                        shadow.shadowBlurRadius = 2.0
                        shadow.shadowColor = NSColor.blackColor()
                        attributes[NSShadowAttributeName] = shadow
                    }
                    size = title.sizeWithAttributes(attributes)
                    r.origin.y += (r.size.height - size.height) / 2
                    r.size.height = size.height
                    title.drawInRect(r, withAttributes: attributes)
                }
                
                // url string
                if let urlString = urlString {
                    var r = bytesRect
                    let attributes = [NSFontAttributeName: urlFont,
                                      NSForegroundColorAttributeName: NSColor.lightGrayColor(),
                                      NSParagraphStyleAttributeName: paragraphStyle]
                    size = urlString.sizeWithAttributes(attributes)
                    r.origin.y += (r.size.height - size.height) / 2
                    r.size.height = size.height
                    urlString.drawInRect(r, withAttributes: attributes)
                }
            } else if mode == .Tile {
                var path: NSBezierPath!
                
                // image
                if let image = imageData !! {NSImage(data: $0)} {
                    r = imageRect
                    path = SBRoundedPath(r, 0.0, 0.0, false, false)
                    SBPreserveGraphicsState {
                        path.addClip()
                        image.drawInRect(r, fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1.0)
                    }
                }
                
                // Gradient
                path = SBRoundedPath(bounds, 0.0, 0.0, false, false) //???
                let colors = [0.0, 0.65].map { NSColor(calibratedWhite: 0.0, alpha: $0) }
                let center = NSMakePoint(r.size.width/2, r.size.height * 0.8)
                let outerRadius = r.size.width * 1.5
                let gradient = NSGradient(colors: colors, atLocations: [1/6, 1.0], colorSpace: NSColorSpace.genericGrayColorSpace())
                gradient.drawInBezierPath(path, relativeCenterPosition: center)
                
                // Label color
                if labelColor != nil {
                    let shadow = NSShadow()
                    shadow.shadowOffset = NSMakeSize(0.0, -1.0)
                    shadow.shadowBlurRadius = 1.0
                    shadow.shadowColor = NSColor(calibratedWhite: 0.0, alpha: 0.6)
                    SBPreserveGraphicsState {
                        shadow.set()
                        labelColor!.set()
                        NSFrameRectWithWidth(self.bounds, self.bounds.size.width * 0.04)
                    }
                }
                
                // Selected
                if selected {
                    let color = isFirstResponder ? SBAlternateSelectedControlColor : NSColor(calibratedWhite: 0.8, alpha: 1.0)
                    let shadow = NSShadow()
                    shadow.shadowOffset = NSMakeSize(0.0, -1.5)
                    shadow.shadowBlurRadius = 3.0
                    shadow.shadowColor = NSColor(calibratedWhite: 0.0, alpha: 0.6)
                    let lineWidth = bounds.size.width * 0.04
                    SBPreserveGraphicsState {
                        shadow.set()
                        color.set()
                        NSFrameRectWithWidth(NSInsetRect(self.bounds, -lineWidth/2, -lineWidth/2), lineWidth)
                    }
                }
                
                // Frame
                NSColor(calibratedWhite: 0.0, alpha: 0.4).set()
                path = SBRoundedPath(bounds, 1.0, 0.0, false, false) //???
                path.lineWidth = 1.0
                path.stroke()
                
                // Shadow
                NSColor(calibratedWhite: 0.0, alpha: 0.55).set()
                NSRectFill(NSMakeRect(bounds.origin.x + 1.0, bounds.origin.y, bounds.size.width - 1.0 * 2, 1.0))
                
                // Highlight
                NSColor(calibratedWhite: 1.0, alpha: 0.45).set()
                NSRectFill(NSMakeRect(bounds.origin.x + 1.0, NSMaxY(bounds) - 1.0, bounds.size.width - 1.0 * 2, 1.0))
            } else {
                // Rects
                let imageRect = NSMakeRect(0, 0, 60, bounds.size.height)
                var titleRect = NSMakeRect((NSMaxX(imageRect) + padding.x), 0, (bounds.size.width - (NSMaxX(imageRect) + padding.x)) * 0.5, bounds.size.height)
                var urlRect = NSMakeRect((NSMaxX(titleRect) + padding.x), 0, (bounds.size.width - (NSMaxX(titleRect) + padding.x)), bounds.size.height)
                
                // line
                NSColor.darkGrayColor().set()
                NSRectFill(NSMakeRect(bounds.origin.x, NSMaxY(bounds) - 1.0, bounds.size.width, 1.0))
                
                // image
                if imageData != nil {}
                
                // title string
                if let title = title {
                    let margin = bounds.size.height / 2
                    
                    r = bounds
                    if labelColor != nil {
                        // Label color
                        var sr = r
                        let tmargin = margin - 1.0
                        sr.origin.x -= tmargin
                        sr.size.width += tmargin * 2
                        //sr = NSInsetRect(sr, 2.0, 2.0)
                        let path = SBRoundedPath(sr, sr.size.height / 2, 0.0, true, true)
                        labelColor!.set()
                        path.fill()
                    }
                    if selected {
                        // Background
                        var sr = r
                        let tmargin = margin - 1.0
                        let color = isFirstResponder ? SBAlternateSelectedControlColor : NSColor(calibratedWhite: 0.8, alpha: 1.0)
                        sr.origin.x -= tmargin
                        sr.size.width += tmargin * 2
                        if labelColor != nil {
                            sr = CGRectInset(sr, 2.0, 2.0)
                        }
                        let darkerColor = color.shadowWithLevel(0.2)
                        let gradient = NSGradient(startingColor: darkerColor, endingColor: color)
                        gradient.drawInRect(sr, angle: 90)
                    }
                    var attributes = [NSFontAttributeName: titleFont,
                                      NSForegroundColorAttributeName: NSColor.whiteColor(),
                                      NSParagraphStyleAttributeName: paragraphStyle]
                    if labelColor != nil && !selected {
                        let shadow = NSShadow()
                        shadow.shadowOffset = NSMakeSize(0.0, -1.0)
                        shadow.shadowBlurRadius = 2.0
                        shadow.shadowColor = NSColor.blackColor()
                        attributes[NSShadowAttributeName] = shadow
                    }
                    size = title.sizeWithAttributes(attributes)
                    
                    titleRect.origin.y += (titleRect.size.height - size.height) / 2
                    titleRect.size.height = size.height
                    title.drawInRect(titleRect, withAttributes: attributes)
                }
                
                // url string
                if let urlString = urlString {
                    let color = selected ? NSColor.whiteColor() : (labelColor !! NSColor.blackColor() ?? NSColor.lightGrayColor())
                    let attributes = [NSFontAttributeName: urlFont,
                                      NSForegroundColorAttributeName: color,
                                      NSParagraphStyleAttributeName: paragraphStyle]
                    size = urlString.sizeWithAttributes(attributes)
                    urlRect.origin.y += (urlRect.size.height - size.height) / 2
                    urlRect.size.height = size.height
                    urlString.drawInRect(urlRect, withAttributes: attributes)
                }
                NSColor.darkGrayColor().set()
                NSFrameRect(bounds)
            }
        }
    }
}

class SBBookmarkListDirectoryItemView: SBBookmarkListItemView {

}
