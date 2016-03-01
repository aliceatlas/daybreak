/*
SBTextInputView.swift

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

class SBTextInputView: SBView, NSTextFieldDelegate {
    lazy var messageLabel: NSTextField = {
        let font = NSFont.boldSystemFontOfSize(16)
        let messageLabel = NSTextField(frame: self.messageLabelRect)
        messageLabel.autoresizingMask = [.ViewMinXMargin, .ViewMinYMargin]
        messageLabel.editable = false
        messageLabel.bordered = false
        messageLabel.drawsBackground = false
        messageLabel.textColor = NSColor.whiteColor()
        messageLabel.font = font
        messageLabel.cell!.wraps = true
        return messageLabel
    }()
    lazy var textLabel: BLKGUI.TextField = {
        let textLabel = BLKGUI.TextField(frame: self.textLabelRect)
        textLabel.alignment = .Left
        textLabel.font = NSFont.systemFontOfSize(14.0)
        textLabel.textColor = NSColor.whiteColor()
        textLabel.delegate = self
        textLabel.cell!.wraps = true
        return textLabel
    }()
    lazy var doneButton: BLKGUI.Button = {
        let doneButton = BLKGUI.Button(frame: self.doneButtonRect)
        doneButton.title = NSLocalizedString("OK", comment: "")
        doneButton.target = self
        doneButton.action = #selector(done)
        doneButton.enabled = true
        doneButton.keyEquivalent = "\r" // busy if button is added into a view
        return doneButton
    }()
    lazy var cancelButton: BLKGUI.Button = {
        let cancelButton = BLKGUI.Button(frame: self.cancelButtonRect)
        cancelButton.title = NSLocalizedString("Cancel", comment: "")
        cancelButton.target = self
        cancelButton.action = #selector(cancel)
        cancelButton.keyEquivalent = "\u{1B}"
        return cancelButton
    }()
    
    var message: String {
        get { return messageLabel.stringValue }
        set(message) {
            let size = message.sizeWithAttributes([NSFontAttributeName: messageLabel.font!])
            messageLabel.alignment = size.width > (messageLabelRect.size.width - 20.0) ? .Left : .Center
            messageLabel.stringValue = message
        }
    }
    
    var text: String {
        get { return textLabel.stringValue }
        set(text) { textLabel.stringValue = text }
    }
    
    init(frame: NSRect, prompt: String) {
        super.init(frame: frame)
        message = prompt
        addSubviews(messageLabel, textLabel, doneButton, cancelButton)
        autoresizingMask = [.ViewMinXMargin, .ViewMaxXMargin, .ViewMinYMargin, .ViewMaxYMargin]
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    // MARK: Rects

    let margin = NSMakePoint(36.0, 32.0)
    let labelWidth = 85.0
    let buttonSize = NSMakeSize(105.0, 24.0)
    let buttonMargin: CGFloat = 15.0
    let textFont = NSFont.systemFontOfSize(16)
    
    var messageLabelRect: NSRect {
        let size = NSSize(width: bounds.size.width - margin.x * 2, height: 36.0)
        let origin = NSPoint(x: margin.x, y: bounds.size.height - size.height - margin.y)
        return NSRect(origin: origin, size: size)
    }
    
    var textLabelRect: NSRect {
        let size = NSSize(
            width: bounds.size.width - margin.x * 2,
            height: (bounds.size.height - messageLabelRect.size.height - buttonSize.height) - margin.y * 4)
        let origin = NSPoint(x: margin.x, y: messageLabelRect.origin.y - size.height)
        return NSRect(origin: origin, size: size)
    }
    
    var doneButtonRect: NSRect {
        let size = buttonSize
        let origin = NSPoint(
            x: ((bounds.size.width - (size.width * 2 + buttonMargin)) / 2) + size.width + buttonMargin,
            y: margin.y)
        return NSRect(origin: origin, size: size)
    }
    
    var cancelButtonRect: NSRect {
        let size = buttonSize
        let origin = NSPoint(
            x: (bounds.size.width - (size.width * 2 + buttonMargin)) / 2,
            y: margin.y)
        return NSRect(origin: origin, size: size)
    }
    
    // MARK: Delegate
    
    override func controlTextDidChange(_: NSNotification) {
        doneButton.enabled = !textLabel.stringValue.isEmpty
    }
}