/*
Slider.swift

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

public class Slider: NSSlider {
    override public class func initialize() {
        Slider.setCellClass(SliderCell.self)
    }
}

private class SliderCell: NSSliderCell {
    override func drawKnob(knobRect: NSRect) {
        var r = NSInsetRect(knobRect, 2, 2)
        r.origin.y += 1
        let path = NSBezierPath(ovalInRect: r)
        let gradient = NSGradient(startingColor: NSColor(deviceWhite: 0.45, alpha: 1.0),
                                  endingColor: NSColor(deviceWhite: 0.05, alpha: 1.0))!
        gradient.drawInBezierPath(path, angle: 90)
        
        path.lineWidth = 0.5
        NSColor(deviceWhite: 0.75, alpha: 1.0).set()
        path.stroke()
    }
    
    /*override func drawWithFrame(cellFrame: NSRect, inView controlView: NSView) {
    	super.drawWithFrame(cellFrame, inView: controlView)
        
    	super.drawBarInside(cellFrame, flipped: controlView.flipped)
    	drawKnob()
    }*/
}