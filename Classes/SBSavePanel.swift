/*
SBSavePanel.swift

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

class SBSavePanel: NSSavePanel {
    override class func sbSavePanel() -> SBSavePanel {
        let panel = super.sbSavePanel() as SBSavePanel
        panel.opaque = false
        panel.backgroundColor = NSColor.clearColor()
        panel.showsResizeIndicator = false
        panel.constructBackgroundView()
        panel.switchButtonType()
        return panel
    }
    
    func constructBackgroundView() {
        if let contentView = self.contentView as? NSView {
            let subviews = contentView.subviews
            if !subviews.isEmpty {
                if let belowView = subviews[0] as? NSView {
                    let savePanelContentView = SBSavePanelContentView(frame: contentView.frame)
                    savePanelContentView.autoresizingMask = .ViewWidthSizable | .ViewHeightSizable
                    contentView.addSubview(savePanelContentView, positioned: .Below, relativeTo: belowView)
                }
            }
        }
    }
    
    func switchButtonType() {
        let subviews = self.contentView.subviews
        self.switchButtonTypeInSubViews(subviews)
    }
    
    func switchButtonTypeInSubViews(subviews: [AnyObject]) {
        for subview in subviews {
            if let button = subview as? NSButton {
                if button.bezelStyle == .RoundedBezelStyle {
                    button.bezelStyle = .TexturedRoundedBezelStyle
                }
            } else if let view = subview as? NSView {
                self.switchButtonTypeInSubViews(view.subviews)
            }
        }
    }
}

class SBOpenPanel: NSOpenPanel {
    override class func sbOpenPanel() -> SBOpenPanel {
        let panel = super.sbOpenPanel() as SBOpenPanel
        panel.opaque = false
        panel.backgroundColor = NSColor.clearColor()
        panel.showsResizeIndicator = false
        panel.constructBackgroundView()
        panel.switchButtonType()
        return panel
    }
    
    func constructBackgroundView() {
        if let contentView = self.contentView as? NSView {
            let subviews = contentView.subviews
            if !subviews.isEmpty {
                if let belowView = subviews[0] as? NSView {
                    let savePanelContentView = SBSavePanelContentView(frame: contentView.frame)
                    savePanelContentView.autoresizingMask = .ViewWidthSizable | .ViewHeightSizable
                    contentView.addSubview(savePanelContentView, positioned: .Below, relativeTo: belowView)
                }
            }
        }
    }
    
    func switchButtonType() {
        let subviews = self.contentView.subviews
        self.switchButtonTypeInSubViews(subviews)
    }
    
    func switchButtonTypeInSubViews(subviews: [AnyObject]) {
        for subview in subviews {
            if let button = subview as? NSButton {
                if button.bezelStyle == .RoundedBezelStyle {
                    button.bezelStyle = .TexturedRoundedBezelStyle
                }
            } else if let view = subview as? NSView {
                self.switchButtonTypeInSubViews(view.subviews)
            }
        }
    }
}

class SBSavePanelContentView: SBView {
    // MARK: Drawing
    
    override func drawRect(rect: NSRect) {
        let ctx = SBCurrentGraphicsPort
        let r = NSRectToCGRect(self.bounds)
        let count: UInt = 3
        let locations: [CGFloat] = [0.0, 0.95, 1.0]
        let extended = r.size.height < 350.0
        let colors: [CGFloat] = (extended ? [0.6,  0.6,  0.6,  1.0,
                                             0.9,  0.9,  0.9,  1.0,
                                             0.75, 0.75, 0.75, 1.0]
                                          : [0.7,  0.7,  0.7,  1.0,
                                             0.75, 0.75, 0.75, 1.0,
                                             0.6,  0.6,  0.6,  1.0])
        let strokeColor: [CGFloat] = [0.2, 0.2, 0.2, 1.0]
        let points: [CGPoint] = [CGPointZero, CGPointMake(0.0, r.size.height * 0.95), CGPointMake(0.0, r.size.height)]
        
        super.drawRect(rect)
        
        // Paths
        // Gray scales
        let path = SBRoundedPath(CGRectInset(r, 0.0, 0.0), 8.0, 0.0, false, true)
        let strokePath = SBRoundedPath(CGRectInset(r, 0.5, 0.5), 8.0, 0.0, false, true)
        // Frame
        CGContextSaveGState(ctx)
        CGContextAddPath(ctx, path.takeUnretainedValue())
        CGContextClip(ctx)
        SBDrawGradientInContext(ctx, count, UnsafePointer<CGFloat>(locations), UnsafePointer<CGFloat>(colors), UnsafePointer<CGPoint>(points))
        CGContextRestoreGState(ctx)
        
        // Stroke
        CGContextSaveGState(ctx)
        CGContextAddPath(ctx, strokePath.takeUnretainedValue())
        CGContextSetLineWidth(ctx, 0.5)
        CGContextSetRGBStrokeColor(ctx, strokeColor[0], strokeColor[1], strokeColor[2], strokeColor[3])
        CGContextStrokePath(ctx)
        CGContextRestoreGState(ctx)
    }
}