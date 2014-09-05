/*
SBBLKGUISlider.swift

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

class SBBLKGUISlider: NSSlider {
    override class func initialize() {
        SBBLKGUISlider.setCellClass(SBBLKGUISliderCell.self)
    }
}

class SBBLKGUISliderCell: NSSliderCell {
    override func drawKnob(knobRect: NSRect) {
        let ctx = SBCurrentGraphicsPort
        let count: UInt = 2
        var r = CGRectInset(NSRectToCGRect(knobRect), 2, 2)
        r.origin.y += 1
        
        let locations: [CGFloat] = [0.0, 1.0]
        let colors: [CGFloat] = [0.45, 0.45, 0.45, 1.0,
                                 0.05, 0.05, 0.05, 1.0]
        let points = [CGPointMake(0.0, r.origin.y), CGPointMake(0.0, CGRectGetMaxY(r))]
        let path = CGPathCreateMutable()
        CGContextSaveGState(ctx)
        CGPathAddEllipseInRect(path, nil, r)
        CGContextAddPath(ctx, path)
        CGContextClip(ctx)
        SBDrawGradientInContext(ctx, count, UnsafeMutablePointer<CGFloat>(locations), UnsafeMutablePointer<CGFloat>(colors), UnsafeMutablePointer<CGPoint>(points))
        CGContextRestoreGState(ctx)
        
        CGContextSaveGState(ctx)
        CGContextAddPath(ctx, path)
        CGContextSetRGBStrokeColor(ctx, 0.75, 0.75, 0.75, 1.0)
        CGContextSetLineWidth(ctx, 0.5)
        CGContextStrokePath(ctx)
        CGContextRestoreGState(ctx)
    }
    
    /*override func drawWithFrame(cellFrame: NSRect, inView controlView: NSView) {
    	super.drawWithFrame(cellFrame, inView: controlView)
        
    	super.drawBarInside(cellFrame, flipped: controlView.flipped)
    	drawKnob()
    }*/
}