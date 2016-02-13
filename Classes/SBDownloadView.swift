/*
SBWebView.swift

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

class SBDownloadView: SBView, SBAnswersIsFirstResponder {
    var sbSuperview: SBDownloadsView? { return super.superview as? SBDownloadsView }
    
    unowned var download: SBDownload
    private lazy var progressIndicator: SBCircleProgressIndicator? = {
        let progressIndicator = SBCircleProgressIndicator(frame: self.progressRect)
        progressIndicator.style = .White
        progressIndicator.autoresizingMask = .ViewMinXMargin
        progressIndicator.selected = self.selected
        progressIndicator.alwaysDrawing = true
        progressIndicator.showPercentage = true
        return progressIndicator
    }()
    
    var selected: Bool = false {
        didSet {
            progressIndicator?.highlighted = selected
            if selected != oldValue { needsDisplay = true }
        }
    }
    
    private lazy var area: NSTrackingArea = {
        return NSTrackingArea(rect: self.bounds, options: [.MouseEnteredAndExited, .MouseMoved, .ActiveAlways, .InVisibleRect], owner: self, userInfo: nil)
    }()
    
    init(frame: NSRect, download: SBDownload) {
        self.download = download
        super.init(frame: frame)
        addTrackingArea(area)
        addSubview(progressIndicator!)
    }

    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    // MARK: View
    
    // Clicking through
    override func hitTest(point: NSPoint) -> NSView? {
        let view = super.hitTest(point)
        return (view === self) ? nil : view
    }
    
    // MARK: Getter
    
    var isFirstResponder: Bool {
        return window &! {$0.firstResponder === superview}
    }
    
    var padding: NSPoint {
        return NSMakePoint(bounds.size.width * 0.1, bounds.size.width * 0.1)
    }
    
    var heights: CGFloat {
        return titleHeight + bytesHeight
    }
    
    let titleHeight: CGFloat = 15.0
    let bytesHeight: CGFloat = 12.0
    let nameFont = NSFont.boldSystemFontOfSize(10.0)
    
    var paragraphStyle: NSParagraphStyle {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .CenterTextAlignment
        return paragraph.copy() as! NSParagraphStyle
    }
    
    var progressRect: NSRect {
        var r = NSZeroRect
        let bottomHeight = heights + padding.y
        r.size.width = 48.0
        r.size.height = 48.0
        r.origin.x = (bounds.size.width - r.size.width) / 2
        r.origin.y = bottomHeight + ((bounds.size.height - bottomHeight) - r.size.height) / 2
        return r
    }
    
    func nameRect(title: String) -> NSRect {
        var r = NSZeroRect
        var drawRect = bounds
        let margin: CGFloat = 8.0
        let availableWidth: CGFloat = bounds.size.width - titleHeight
        if let size = title.ifNotEmpty?.sizeWithAttributes([NSFontAttributeName: nameFont,
                                                  NSParagraphStyleAttributeName: paragraphStyle])
           where size.width <= availableWidth {
            drawRect.origin.x = (availableWidth - size.width) / 2
            drawRect.size.width = size.width
        } else {
            drawRect.size.width = availableWidth
        }
        r = NSZeroRect
        r.size.width = drawRect.size.width
        r.size.height = titleHeight
        r.origin.x = margin + drawRect.origin.x
        r.origin.y = padding.y + bytesHeight
        return r
    }
    
    // MARK: Actions
    
    func destructProgressIndicator() {
        progressIndicator?.removeFromSuperview()
        progressIndicator = nil
    }
    
    func update() {
        if download.status == .Done {
            destructProgressIndicator()
        } else {
            progressIndicator!.progress = CGFloat(download.progress)
            progressIndicator!.needsDisplay = true
        }
        needsDisplay = true
    }
    
    func remove() {
        sbSuperview!.layoutToolsHidden()
        SBDownloads.sharedDownloads.removeItem(download)
    }
    
    func finder() {
        if download.path &! {NSFileManager.defaultManager().fileExistsAtPath($0)} {
            NSWorkspace.sharedWorkspace().selectFile(download.path!, inFileViewerRootedAtPath: "")
            sbSuperview!.layoutToolsHidden()
        }
    }
    
    func open() {
        if download.path &! {NSFileManager.defaultManager().fileExistsAtPath($0)} {
            NSWorkspace.sharedWorkspace().openFile(download.path!)
        }
    }
    
    // MARK: Event
    
    override func mouseEntered(event: NSEvent) {
        sbSuperview!.layoutToolsForItem(self)
    }
    
    override func mouseMoved(event: NSEvent) {
        let location = event.locationInWindow
        let point = convertPoint(location, fromView: nil)
        if bounds.contains(point) {
            sbSuperview!.layoutToolsForItem(self)
        }
    }
    
    override func mouseExited(event: NSEvent) {
        sbSuperview!.layoutToolsHidden()
    }
    
    // MARK: Drawing
    
    override func drawRect(rect: NSRect) {
        super.drawRect(rect)
        
        // Icon
        if let path = download.path?.ifNotEmpty {
            let image = NSWorkspace.sharedWorkspace().iconForFile(path)
            var r = NSZeroRect
            var b = bounds
            let size = image.size
            var fraction: CGFloat = 1.0
            r.size.height = bounds.size.height - heights - padding.y * 3
            r.size.width = size.width * (r.size.height / size.height)
            r.origin.x = (bounds.size.width - r.size.width) / 2
            r.origin.y = heights + padding.y * 2
            fraction = (download.status == .Done) ? 1.0 : 0.5
            image.drawInRect(r, fromRect: NSRect(origin: NSZeroPoint, size: size), operation: .CompositeSourceOver, fraction: fraction)
        }
        
        // name string
        if let name: NSString = download.name {
            var r = nameRect(download.name!)
            let margin: CGFloat = 8.0
            
            if selected {
                // Background
                var sr = r
                var color0: NSColor!
                var color1: NSColor!
                if isFirstResponder {
                    color1 = SBAlternateSelectedControlColor
                } else {
                    color1 = NSColor(deviceWhite: 0.8, alpha: 1.0)
                }
                sr.origin.x -= margin
                sr.size.width += margin * 2
                color0 = color1.shadowWithLevel(0.2)
                
                let radius = sr.size.height / 2
                let path = NSBezierPath(roundedRect: sr, xRadius: radius, yRadius: radius)
                let gradient = NSGradient(startingColor: color0, endingColor: color1)
                gradient.drawInBezierPath(path, angle: 90)
                //CGRect sr = NSRectToCGRect(r);
                //CGContextRef ctx = NSGraphicsContext.currentContext.graphicsPort;
                //CGFloat components[4];
                //CGPathRef path = nil;
                //if (self.isFirstResponder)
                //{
                //    SBGetAlternateSelectedControlColorComponents(components);
                //}
                //else {
                //	  components[0] = components[1] = components[2] = 0.8;
                //	  components[3] = 1.0;
                //}
                //sr.origin.x -= margin;
                //sr.size.width += margin * 2;
                //path = SBRoundedPath(sr, sr.size.height / 2, 0.0, YES, YES);
                //CGContextSaveGState(ctx);
                //CGContextAddPath(ctx, path);
                //CGContextSetRGBFillColor(ctx, components[0], components[1], components[2], components[3]);
                //CGContextFillPath(ctx);
                //CGContextRestoreGState(ctx);
                //CGPathRelease(path);
            }
            let attributes = [NSFontAttributeName: nameFont,
                              NSForegroundColorAttributeName: NSColor.whiteColor(),
                              NSParagraphStyleAttributeName: paragraphStyle]
            let size = name.sizeWithAttributes(attributes)
            r.origin.y += (r.size.height - size.height) / 2
            r.size.height = size.height
            name.drawInRect(r, withAttributes: attributes)
        }
        // bytes string
        var description: NSString?
        switch download.status {
            case .Undone:
                description = NSLocalizedString("Undone", comment: "")
            case .Processing:
                description = download.bytes
            case .Done:
                description = NSLocalizedString("Done", comment: "")
            default:
                break
        }
        if description != nil {
            var r = NSZeroRect
            r.size.width = rect.size.width
            r.size.height = bytesHeight
            r.origin.y = padding.y
            let attributes = [NSFontAttributeName: NSFont.systemFontOfSize(9.0),
                              NSForegroundColorAttributeName: NSColor.lightGrayColor(),
                              NSParagraphStyleAttributeName: paragraphStyle]
            let size = description!.sizeWithAttributes(attributes)
            r.origin.y += (r.size.height - size.height) / 2
            r.size.height = size.height
            description!.drawInRect(r, withAttributes: attributes)
        }
    }
}