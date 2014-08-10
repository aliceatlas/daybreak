/*
SBDrawer.swift

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

class SBDrawer: SBView {
    lazy var scrollView: SBBLKGUIScrollView = {
        var scrollView = SBBLKGUIScrollView(frame: self.availableRect)
        scrollView.autoresizingMask = .ViewWidthSizable | .ViewHeightSizable
        scrollView.autohidesScrollers = true
        scrollView.hasHorizontalScroller = false
        scrollView.hasVerticalScroller = true
        let (red, green, blue, alpha) = SBBackgroundColors
        scrollView.backgroundColor = NSColor(calibratedRed: red, green: green, blue: blue, alpha: alpha)
        scrollView.drawsBackground = true
        self.addSubview(scrollView)
        return scrollView
    }()
    var view: NSView? {
        didSet {
            scrollView.documentView = view
            scrollView.contentView.copiesOnScroll = true
        }
    }
    
    var availableRect: NSRect {
        var r = self.bounds
        if let subview = self.subview {
            var sr = subview.frame
            r.size.height -= NSMaxY(sr)
            r.origin.y = NSMaxY(sr)
        }
        return r
    }
    
    override func resizeSubviewsWithOldSize(oldBoundsSize: NSSize) {
        super.resizeSubviewsWithOldSize(oldBoundsSize)
        if let view = view as? SBDownloadsView {
            view.layoutItems(false)
        }
    }
    
    // Drawing
    
    override func drawRect(rect: NSRect) {
        let ctx = SBCurrentGraphicsPort
        
        // Background
        let (red, green, blue, alpha) = SBWindowBackColors
        NSColor(calibratedRed: red, green: green, blue: blue, alpha: alpha).set()
        NSRectFill(rect)
        
        // Bottom
        let locations: [CGFloat] = [0.0, 1.0]
        let points: [CGPoint] = [CGPointZero, CGPointMake(0.0, CGFloat(kSBBottombarHeight))]
        SBDrawGradientInContext(ctx, 2, UnsafeMutablePointer<CGFloat>(locations), UnsafeMutablePointer<CGFloat>(SBBottombarColors), UnsafeMutablePointer<CGPoint>(points))
        
        // Line
        NSColor(calibratedWhite: 1.0, alpha: 0.3).set()
        NSRectFill(NSMakeRect(bounds.origin.x, 0.0, bounds.size.width, 1.0))
    }
}