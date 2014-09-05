/*
SBBLKGUITextField.swift

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

class SBBLKGUITextField: NSTextField {
    override class func initialize() {
        SBBLKGUITextField.setCellClass(SBBLKGUITextFieldCell.self)
    }
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        setDefaultValues()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setDefaultValues() {
        alignment = .RightTextAlignment
        drawsBackground = false
        textColor = NSColor.whiteColor()
    }
}

class SBBLKGUITextFieldCell: NSTextFieldCell {
    override init() {
        super.init()
    }
    
    @objc(initTextCell:)
    override init(textCell: String) {
        super.init(textCell: textCell)
        setDefaultValues()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setDefaultValues() {
        wraps = false
        scrollable = true
        focusRingType = .Exterior
    }
    
    override func setUpFieldEditorAttributes(textObj: NSText) -> NSText {
        let text = super.setUpFieldEditorAttributes(textObj)
        if let textView = text as? NSTextView {
            let attributes = [NSForegroundColorAttributeName: NSColor.whiteColor(),
                              NSBackgroundColorAttributeName: NSColor.grayColor()]
            textView.insertionPointColor = NSColor.whiteColor()
            textView.selectedTextAttributes = attributes
        }
        return text
    }
    
    override func drawWithFrame(cellFrame: NSRect, inView: NSView) {
        let ctx = SBCurrentGraphicsPort
        let controlView = inView as? NSControl
        let alpha: CGFloat = (controlView != nil) ? (controlView!.enabled ? 1.0 : 0.2) : 1.0
        
        var r = NSRectToCGRect(cellFrame)
        var path = SBRoundedPath(r, SBFieldRoundedCurve, 0, true, true)
        CGContextSaveGState(ctx)
        CGContextAddPath(ctx, path)
        CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, alpha * 0.1)
        CGContextFillPath(ctx)
        CGContextRestoreGState(ctx)
        
        r.origin.x += 0.5
        r.origin.y += 0.5
        r.size.width -= 1.0
        r.size.height -= 1.0
        path = SBRoundedPath(r, SBFieldRoundedCurve, 0, true, true)
        CGContextSaveGState(ctx)
        CGContextAddPath(ctx, path)
        CGContextSetLineWidth(ctx, 0.5)
        CGContextSetRGBStrokeColor(ctx, 1.0, 1.0, 1.0, alpha)
        CGContextStrokePath(ctx)
        CGContextRestoreGState(ctx)
        
        drawInteriorWithFrame(cellFrame, inView: controlView)
    }
}