/*
SBBLKGUISearchField.swift

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

class SBBLKGUISearchField: NSSearchField {
    override class func initialize() {
        SBBLKGUISearchField.setCellClass(SBBLKGUISearchFieldCell.self)
    }
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        setDefaultValues()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setDefaultValues() {
        alignment = .LeftTextAlignment
        drawsBackground = false
        textColor = NSColor.whiteColor()
    }
}

class SBBLKGUISearchFieldCell: NSSearchFieldCell {
    override init() {
        super.init()
    }
    
    @objc(initTextCell:)
    override init(textCell string: String) {
        super.init(textCell: string)
        setDefaultValues()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setDefaultValues() {
        wraps = false
        scrollable = true
        focusRingType = .Exterior
        searchButtonCell!.image = NSImage(named: "Search.png")!
        searchButtonCell!.alternateImage = searchButtonCell!.image

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
        let controlView = inView as? NSControl
        let alpha: CGFloat = (controlView?.enabled ?? true) ? 1.0 : 0.2
        var r = cellFrame
        var radius = r.size.height / 2
        var path = NSBezierPath(roundedRect: r, xRadius: radius, yRadius: radius)
        NSColor(deviceWhite: 0.0, alpha: alpha * 0.1).set()
        path.fill()
        
        r.inset(dx: 0.5, dy: 0.5)
        radius = r.size.height / 2
        path = NSBezierPath(roundedRect: r, xRadius: radius, yRadius: radius)
        path.lineWidth = 0.5
        NSColor(deviceWhite: 1.0, alpha: alpha).set()
        path.stroke()
        
        drawInteriorWithFrame(cellFrame, inView: inView)
    }
}