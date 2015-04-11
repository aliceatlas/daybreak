/*
ScrollView.swift

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

public class ScrollView: NSScrollView {
    override public var horizontalScroller: NSScroller? {
        get { return super.horizontalScroller }
        set(scroller) {
            super.horizontalScroller = scroller
        }
    }
    override public var verticalScroller: NSScroller? {
        get { return super.verticalScroller }
        set(scroller) {
            super.verticalScroller = scroller
        }
    }

    override public init(frame: NSRect) {
        super.init(frame: frame)
        initialize()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    class func _horizontalScrollerClass() -> AnyClass {
        return Scroller.self
    }
    
    class func _verticalScrollerClass() -> AnyClass {
        return Scroller.self
    }

    func initialize() {
        contentView = ClipView(frame: contentView.frame)
        
        /*
      	hasVerticalScroller = hasVerticalScroller
      	hasHorizontalScroller = hasHorizontalScroller
        if hasVerticalScroller {
      		let scroller = verticalScroller
            let newScroller = Scroller(frame: scroller.frame)
      		newScroller.backgroundColor = backgroundColor
      		newScroller.arrowsPosition = .ScrollerArrowsMaxEnd
      		newScroller.controlSize = scroller.controlSize
      		verticalScroller = newScroller
      	}
      	
        if hasHorizontalScroller {
      		let scroller = horizontalScroller
            let newScroller = Scroller(frame: scroller.frame)
            newScroller.backgroundColor = backgroundColor
            newScroller.arrowsPosition = .ScrollerArrowsMaxEnd
            newScroller.controlSize = scroller.controlSize
            horizontalScroller = newScroller
      	}
        */
    }
    
    /*
    override var backgroundColor: NSColor! {
        get { return super.backgroundColor }
        set(color) {
            super.backgroundColor = color
            /*
            if hasVerticalScroller {
                verticalScroller.backgroundColor = color
            }
            if hasHorizontalScroller {
                horizontalScroller.backgroundColor = color
            }
            */
        }
    }
    
    override var drawsBackground: Bool {
        get { return super.drawsBackground }
        set(drawsBackground) {
            super.drawsBackground = drawsBackground
            /*
            if hasVerticalScroller {
                verticalScroller.drawsBackground = drawsBackground
            }
            if hasHorizontalScroller {
                horizontalScroller.drawsBackground = drawsBackground
            }
            */
        }
    }
    */
    
    override public func drawRect(rect: NSRect) {
        if drawsBackground {
            NSColor(calibratedWhite: 0.0, alpha: 0.85).set()
            NSRectFill(rect)
            NSColor.lightGrayColor().set()
            NSBezierPath(rect: rect).stroke()
        } else {
            super.drawRect(rect)
        }
    }
    
    func _fixHeaderAndCornerViews() -> Bool {
        return false
    }
}

public class Scroller: NSScroller {
    public var drawsBackground: Bool = false {
        didSet {
            if drawsBackground != oldValue {
                needsDisplay = true
            }
        }
    }
    
    public var backgroundColor: NSColor? {
        didSet {
            if backgroundColor != oldValue {
                needsDisplay = true
            }
        }
    }
    
    override public func drawRect(rect: NSRect) {
        if drawsBackground {
            let color = NSColor(calibratedWhite: 0.0, alpha:0.85)
            (backgroundColor ?? color).set()
            NSRectFill(bounds)
        }
        super.drawRect(bounds)
    }
    
    func drawArrow(arrow: NSScrollerArrow, highlightPart part: Int) {
        let color = NSColor(calibratedWhite: 0.0, alpha:0.85)
        var drawRect = NSZeroRect
        var image: NSImage!
        
        let isVertical = bounds.size.width < bounds.size.height
        let arrowRect = bounds
        
        // Fill bounds
        backgroundColor?.set()
        NSRectFill(arrowRect)
        
        // Up
        if isVertical {
            image = NSImage(named: (part == 1) ? "ScrollerArrow-Highlighted-Vertical-Up.png" : "ScrollerArrow-Vertical-Up.png")
            let downImage = NSImage(named: "ScrollerArrow-Vertical-Down.png")!
            drawRect.size = image.size
            drawRect.origin.y = arrowRect.origin.y + (arrowRect.size.height - (image.size.height + downImage.size.height))
        }
        // Right
        else {
            image = NSImage(named: (part == 0) ? "ScrollerArrow-Highlighted-Horizontal-Right.png" : "ScrollerArrow-Horizontal-Right.png")
            drawRect.size = image.size
            drawRect.origin.x = (arrowRect.origin.x + arrowRect.size.width) - drawRect.size.width
        }
        if drawsBackground {
            (backgroundColor ?? color).set()
            NSRectFill(drawRect)
        }
        image.drawInRect(drawRect, operation: .CompositeSourceOver, fraction: 1.0, respectFlipped: true)
        
        // Down
        if isVertical {
            image = NSImage(named: (part == 0) ? "ScrollerArrow-Highlighted-Vertical-Down.png" : "ScrollerArrow-Vertical-Down.png")
            drawRect.size = image.size
            drawRect.origin.y = (arrowRect.origin.y + arrowRect.size.height) - drawRect.size.height
        }
        // Left
        else {
            image = NSImage(named: (part == 1) ? "ScrollerArrow-Highlighted-Horizontal-Left.png" : "ScrollerArrow-Horizontal-Left.png")
            let rightImage = NSImage(named: "ScrollerArrow-Horizontal-Right.png")!
            drawRect.size = image.size
            drawRect.origin.x = (arrowRect.origin.x + arrowRect.size.width) - (drawRect.size.width + rightImage.size.width)
        }
        if drawsBackground {
            (backgroundColor ?? color).set()
            NSRectFill(drawRect)
        }
        image.drawInRect(drawRect, operation: .CompositeSourceOver, fraction: 1.0, respectFlipped: true)
        
        // Stroke bounds
        NSColor.lightGrayColor().set()
        NSFrameRect(bounds)
    }
    
    override public func drawKnobSlotInRect(rect: NSRect, highlight: Bool) {
        let r = rectForPart(.KnobSlot)
        let color = NSColor(calibratedWhite: 0.0, alpha:0.85)
        var drawRect = NSZeroRect
        
        let isVertical = bounds.size.width < bounds.size.height
        
        if drawsBackground {
            (backgroundColor ?? color).set()
        } else {
            NSColor.blackColor().set()
        }
        NSRectFill(r)
        
        // Stroke bounds
        NSColor.lightGrayColor().set()
        NSFrameRect(r)
        
        // Draw top image
        let image = NSImage(named: isVertical ? "ScrollerSlot-Vertical-Top.png" : "ScrollerSlot-Horizontal-Left.png")!
        drawRect.size = image.size
        image.drawInRect(drawRect, operation: .CompositeSourceOver, fraction: 1.0, respectFlipped: true)
    }
    
    override public func drawKnob() {
        var drawRect = NSZeroRect
        var m: CGFloat = 2
        
        let isVertical = bounds.size.width < bounds.size.height
        let knobRect = rectForPart(.Knob)
        
        if isVertical {
            // Bottom
            let bottomImage = NSImage(named: "ScrollerKnob-Vertical-Bottom.png")!
            drawRect.size = bottomImage.size
            drawRect.origin.x = knobRect.origin.x + (knobRect.size.width - drawRect.size.width) / 2
            drawRect.origin.y = (knobRect.origin.y + knobRect.size.height) - bottomImage.size.height - m
            bottomImage.drawInRect(drawRect, operation: .CompositeSourceOver, fraction: 1.0, respectFlipped: true)
            
            // Top
            let topImage = NSImage(named: "ScrollerKnob-Vertical-Top.png")!
            drawRect.size = topImage.size
            drawRect.origin.x = knobRect.origin.x + (knobRect.size.width - drawRect.size.width) / 2
            drawRect.origin.y = knobRect.origin.y + m
            topImage.drawInRect(drawRect, operation: .CompositeSourceOver, fraction: 1.0, respectFlipped: true)
            
            // Middle
            let middleImage = NSImage(named: "ScrollerKnob-Vertical-Middle.png")!
            drawRect.size.width = middleImage.size.width
            drawRect.origin.x = knobRect.origin.x + (knobRect.size.width - drawRect.size.width) / 2
            drawRect.origin.y = knobRect.origin.y + bottomImage.size.height + m
            drawRect.size.height = knobRect.size.height - (bottomImage.size.height + topImage.size.height) - (m * 2)
            middleImage.drawInRect(drawRect, operation: .CompositeSourceOver, fraction: 1.0, respectFlipped: true)
        } else {
            // Left
            let leftImage = NSImage(named: "ScrollerKnob-Horizontal-Left.png")!
            drawRect.size = leftImage.size
            drawRect.origin.x = knobRect.origin.x + m
            drawRect.origin.y = knobRect.origin.y + (knobRect.size.height - drawRect.size.height) / 2
            leftImage.drawInRect(drawRect, operation: .CompositeSourceOver, fraction: 1.0, respectFlipped: true)
            
            // Right
            let rightImage = NSImage(named: "ScrollerKnob-Horizontal-Right.png")!
            drawRect.size = rightImage.size
            drawRect.origin.y = knobRect.origin.y + (knobRect.size.height - drawRect.size.height) / 2
            drawRect.origin.x = knobRect.origin.x + knobRect.size.width - (leftImage.size.width + m)
            rightImage.drawInRect(drawRect, operation: .CompositeSourceOver, fraction: 1.0, respectFlipped: true)
            
            // Center
            let centerImage = NSImage(named: "ScrollerKnob-Horizontal-Center.png")!
            drawRect.size.height = centerImage.size.height
            drawRect.origin.y = knobRect.origin.y + (knobRect.size.height - drawRect.size.height) / 2
            drawRect.origin.x = knobRect.origin.x + leftImage.size.width + m
            drawRect.size.width = knobRect.size.width - (leftImage.size.width + rightImage.size.width + m * 2)
            centerImage.drawInRect(drawRect, operation: .CompositeSourceOver, fraction: 1.0, respectFlipped: true)
        }
    }
}

public class ClipView: NSClipView {
    override public var flipped: Bool {
        return true
    }
}