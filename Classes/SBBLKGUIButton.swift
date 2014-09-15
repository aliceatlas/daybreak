/*
SBBLKGUIButton.swift

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

class SBBLKGUIButton: NSButton {
    override class func initialize() {
        SBBLKGUIButton.setCellClass(SBBLKGUIButtonCell.self)
    }
    
    convenience override init() {
        self.init(frame: NSZeroRect)
    }
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        buttonType = .MomentaryChangeButton
        bezelStyle = .RoundedBezelStyle
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var buttonType: NSButtonType {
        get {
            return (cell() as SBBLKGUIButtonCell).buttonType
        }
        set(buttonType) {
            (cell() as SBBLKGUIButtonCell).buttonType = buttonType
        }
    }
    
    /*var selected: NSButtonType {
        get {
            return (cell() as SBBLKGUIButtonCell).selected
        }
        set(selected) {
            (cell() as SBBLKGUIButtonCell).selected = selected
        }
    }*/
    
    override var alignmentRectInsets: NSEdgeInsets {
        return NSEdgeInsetsMake(6, 0, 6, 0)
    }
}


class SBBLKGUIButtonCell: NSButtonCell {
    var buttonType: NSButtonType = .MomentaryLightButton {
        didSet {
            super.setButtonType(buttonType)
        }
    }
    
    override init() {
        super.init()
    }
    
    @objc(initTextCell:)
    override init(textCell string: String) {
        super.init(textCell: string)
    }
    
    @objc(initImageCell:)
    override init(imageCell image: NSImage) {
        super.init(imageCell: image)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func drawWithFrame(cellFrame: NSRect, inView: NSView) {
        var image: NSImage?
        let controlView = inView as? NSButton
        let alpha: CGFloat = (controlView != nil) ? (controlView!.enabled ? 1.0 : 0.2) : 1.0
        let isDone = (controlView != nil) ? (controlView!.keyEquivalent == "\r") : false
        if /*NSEqualRects(cellFrame, controlView.bounds)*/ true {
            var leftImage: NSImage?
            var centerImage: NSImage?
            var rightImage: NSImage?
            var r = NSZeroRect
            var offset: CGFloat = 0
            if buttonType == .SwitchButton {
                var imageRect = NSZeroRect
                
                if state == NSOnState {
                    image = NSImage(named: highlighted ? "BLKGUI_CheckBox-Selected-Highlighted.png" : "BLKGUI_CheckBox-Selected.png")
                } else {
                    image = NSImage(named: highlighted ? "BLKGUI_CheckBox-Highlighted.png" : "BLKGUI_CheckBox.png")
                }
                
                imageRect.size = image!.size
                r.size = imageRect.size
                r.origin.y = cellFrame.origin.y + (cellFrame.size.height - r.size.height) / 2
                image!.drawInRect(r, operation: .CompositeSourceOver, fraction: (enabled ? 1.0 : 0.5), respectFlipped: true)
            } else if buttonType == .RadioButton {
                var imageRect = NSZeroRect
                
                if state == NSOnState {
                    image = NSImage(named: highlighted ? "BLKGUI_Radio-Selected-Highlighted.png" : "BLKGUI_Radio-Selected.png")
                }
                else {
                    image = NSImage(named: highlighted ? "BLKGUI_Radio-Highlighted.png" : "BLKGUI_Radio.png")
                }
                
                imageRect.size = image?.size ?? NSZeroSize
                r.size = imageRect.size
                r.origin.x = cellFrame.origin.x
                r.origin.y = cellFrame.origin.y + (cellFrame.size.height - r.size.height) / 2
                image!.drawInRect(r, operation: .CompositeSourceOver, fraction: (enabled ? 1.0 : 0.5), respectFlipped: true)
            } else {
                if isDone {
                    if highlighted {
                        leftImage = NSImage(named: "BLKGUI_Button-Active-Highlighted-Left.png")
                        centerImage = NSImage(named: "BLKGUI_Button-Active-Highlighted-Center.png")
                        rightImage = NSImage(named: "BLKGUI_Button-Active-Highlighted-Right.png")
                    } else {
                        leftImage = NSImage(named: "BLKGUI_Button-Active-Left.png")
                        centerImage = NSImage(named: "BLKGUI_Button-Active-Center.png")
                        rightImage = NSImage(named: "BLKGUI_Button-Active-Right.png")
                    }
                } else {
                    if highlighted {
                        leftImage = NSImage(named: "BLKGUI_Button-Highlighted-Left.png")
                        centerImage = NSImage(named: "BLKGUI_Button-Highlighted-Center.png")
                        rightImage = NSImage(named: "BLKGUI_Button-Highlighted-Right.png")
                    } else {
                        leftImage = NSImage(named: "BLKGUI_Button-Left.png")
                        centerImage = NSImage(named: "BLKGUI_Button-Center.png")
                        rightImage = NSImage(named: "BLKGUI_Button-Right.png")
                    }
                }
                
                if leftImage != nil {
                    r.size = leftImage!.size
                    r.origin.y = (cellFrame.size.height - r.size.height) / 2
                    leftImage!.drawInRect(r, operation: .CompositeSourceOver, fraction: (enabled ? 1.0 : 0.5), respectFlipped: true)
                    offset = NSMaxX(r)
                }
                if centerImage != nil {
                    r.origin.x = leftImage?.size.width ?? 0.0
                    r.size.width = cellFrame.size.width - ((leftImage?.size.width ?? 0) + (rightImage?.size.width ?? 0))
                    r.size.height = centerImage!.size.height
                    r.origin.y = (cellFrame.size.height - r.size.height) / 2
                    centerImage!.drawInRect(r, operation: .CompositeSourceOver, fraction: (enabled ? 1.0 : 0.5), respectFlipped: true)
                    offset = NSMaxX(r)
                }
                if rightImage != nil {
                    r.origin.x = offset
                    r.size = rightImage!.size
                    r.origin.y = (cellFrame.size.height - r.size.height) / 2
                    rightImage!.drawInRect(r, operation: .CompositeSourceOver, fraction: (enabled ? 1.0 : 0.5), respectFlipped: true)
                }
            }
        }
        
        if !(title?.isEmpty ?? true) {
            let title: NSString = self.title
            var size = NSZeroSize
            let frameMargin: CGFloat = 2.0
            let frame = NSMakeRect(cellFrame.origin.x + frameMargin, cellFrame.origin.y, cellFrame.size.width - frameMargin * 2, cellFrame.size.height)
            var r = frame
            var foregroundColor: NSColor!
            if buttonType == .SwitchButton || buttonType == .RadioButton {
                foregroundColor = enabled ? NSColor.whiteColor() : NSColor.grayColor()
            } else {
                foregroundColor = enabled ? (highlighted ? NSColor.grayColor() : NSColor.whiteColor()) : (isDone ? NSColor.grayColor() : NSColor.darkGrayColor())
            }
            let attributes = [NSFontAttributeName: font,
                              NSForegroundColorAttributeName: foregroundColor]
            if buttonType == .SwitchButton || buttonType == .RadioButton {
                var i = 0
                var l = 0
                var h = 1
                size.width = frame.size.width - (image?.size.width ?? 0) + 2
                size.height = font.pointSize + 2.0
                for i = 1; i <= title.length; i++ {
                    let t = title.substringWithRange(NSMakeRange(l, i - l))
                    let s = t.sizeWithAttributes(attributes)
                    if size.width <= s.width {
                        l = i
                        h++
                    }
                }
                size.height = size.height * CGFloat(h)
            } else {
                size = title.sizeWithAttributes(attributes)
            }
            r.size = size
            if buttonType == .SwitchButton || buttonType == .RadioButton {
                r.origin.y = frame.origin.y + (cellFrame.size.height - r.size.height) / 2
                r.origin.x = frame.origin.x + (image?.size.width ?? 0) + 3
            } else {
                r.origin.x = (frame.size.width - r.size.width) / 2
                r.origin.y = (frame.size.height - r.size.height) / 2
                r.origin.y -= 2.0
                if image != nil {
                    let image = self.image
                    var imageRect = NSZeroRect
                    let margin: CGFloat = 3.0
                    imageRect.size = image?.size ?? NSZeroSize
                    if r.origin.x > (imageRect.size.width + margin) {
                        let width = imageRect.size.width + r.size.width + margin
                        imageRect.origin.x = (frame.size.width - width) / 3
                        r.origin.x = imageRect.origin.x + imageRect.size.width + margin
                    } else {
                        imageRect.origin.x = frame.origin.x
                        r.origin.x = NSMaxX(imageRect) + margin
                        size.width = frame.size.width - r.origin.x
                    }
                    imageRect.origin.y = (frame.size.height - imageRect.size.height) / 2 - 1
                    image.drawInRect(imageRect, operation: .CompositeSourceOver, fraction: (enabled ? (highlighted ? 0.5 : 1.0) : 0.5), respectFlipped: true)
                }
            }
            title.drawInRect(r, withAttributes: attributes)
        }
    }
}