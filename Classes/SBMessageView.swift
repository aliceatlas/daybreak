/*
SBMessageView.swift

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

import BLKGUI

class SBMessageView: SBView {
    private lazy var textLabel: NSTextField = {
        let textLabel = NSTextField(frame: self.textLabelRect)
        textLabel.editable = false
        textLabel.bordered = false
        textLabel.drawsBackground = false
        textLabel.textColor = NSColor.whiteColor()
        textLabel.font = self.textFont
        textLabel.cell!.wraps = true
        textLabel.stringValue = "JavaScript"
        return textLabel
    }()
    private lazy var messageLabel: NSTextField = {
        let messageLabel = NSTextField(frame: self.messageLabelRect)
        messageLabel.autoresizingMask = [.ViewMinXMargin, .ViewMinYMargin]
        messageLabel.editable = false
        messageLabel.bordered = false
        messageLabel.drawsBackground = false
        messageLabel.textColor = NSColor.whiteColor()
        messageLabel.font = NSFont.boldSystemFontOfSize(16)
        messageLabel.alignment = .Center
        messageLabel.cell!.wraps = true
        return messageLabel
    }()
    private lazy var cancelButton: BLKGUI.Button = {
        let cancelButton = BLKGUI.Button(frame: self.cancelButtonRect)
        cancelButton.title = NSLocalizedString("Cancel", comment: "")
        cancelButton.target = self
        cancelButton.action = "cancel"
        cancelButton.keyEquivalent = "\u{1B}"
        return cancelButton
    }()
    private lazy var doneButton: BLKGUI.Button = {
        let doneButton = BLKGUI.Button(frame: self.doneButtonRect)
        doneButton.title = NSLocalizedString("OK", comment: "")
        doneButton.target = self
        doneButton.action = "done"
        doneButton.enabled = true
        doneButton.keyEquivalent = "\r" // busy if button is added into a view
        return doneButton
    }()
    
    var message: String {
        get { return messageLabel.stringValue }
        set(message) { messageLabel.stringValue = message }
    }
    
    var text: String {
        get { return textLabel.stringValue }
        set(text) {
            textLabel.stringValue = text
            let size = text.sizeWithAttributes([NSFontAttributeName: textFont])
            textLabel.alignment = size.width > (textLabelRect.size.width - 20.0) ? .Left : .Center
        }
    }
    
    override var cancelSelector: Selector {
        didSet {
            if cancelSelector != nil {
                addSubview(cancelButton)
            } else if cancelButton.superview != nil {
                cancelButton.removeFromSuperview()
            }
        }
    }
    
    override var doneSelector: Selector {
        didSet {
            if doneSelector != nil {
                addSubview(doneButton)
            } else if doneButton.superview != nil {
                doneButton.removeFromSuperview()
            }
        }
    }
    
    init(frame: NSRect, text: String) {
        super.init(frame: frame)
        self.text = text
        addSubview(textLabel)
        addSubview(messageLabel)
        let viewsDictionary: [NSObject: AnyObject] = ["textLabel": textLabel, "messageLabel": messageLabel, "cancelButton": cancelButton, "doneButton": doneButton]
        autoresizingMask = [.ViewMinXMargin, .ViewMaxXMargin, .ViewMinYMargin, .ViewMaxYMargin]
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    // MARK: Rects
    
    let margin = NSMakePoint(36.0, 32.0)
    let labelWidth: CGFloat = 85.0
    let buttonSize = NSMakeSize(105.0, 24.0)
    let buttonMargin: CGFloat = 15.0
    let textFont = NSFont.systemFontOfSize(16)
    
    var messageLabelRect: NSRect {
        var r = NSZeroRect
        r.size.width = bounds.size.width - margin.x * 2
        r.size.height = 36.0
        r.origin.x = margin.x
        r.origin.y = bounds.size.height - r.size.height - margin.y
        return r
    }
    
    var textLabelRect: NSRect {
        var r = NSZeroRect
        r.size.width = bounds.size.width - margin.x * 2
        r.size.height = bounds.size.height - margin.y * 2
        r.origin.x = margin.x
        r.origin.y = messageLabelRect.origin.y - r.size.height
        return r
    }
    
    var doneButtonRect: NSRect {
        var r = NSZeroRect
        r.size = buttonSize
        r.origin.y = margin.y
        r.origin.x = cancelButtonRect.origin.x + r.size.width + buttonMargin
        return r
    }
    
    var cancelButtonRect: NSRect {
        var r = NSZeroRect
        r.size = buttonSize
        r.origin.y = margin.y;
        r.origin.x = (bounds.size.width - (r.size.width * 2 + buttonMargin)) / 2
        return r
    }
}