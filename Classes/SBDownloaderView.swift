/*
SBDownloaderView.swift

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

class SBDownloaderView: SBView, NSTextFieldDelegate {
	private lazy var messageLabel: NSTextField = {
        let messageLabel = NSTextField(frame: self.messageLabelRect)
        messageLabel.autoresizingMask = .ViewMinXMargin | .ViewMinYMargin
        messageLabel.editable = false
        messageLabel.bordered = false
        messageLabel.drawsBackground = false
        messageLabel.textColor = NSColor.whiteColor()
        let cell = messageLabel.cell() as NSCell
        cell.font = NSFont.boldSystemFontOfSize(16)
        cell.alignment = .CenterTextAlignment
        cell.wraps = true
        return messageLabel
    }()
    
	private lazy var urlLabel: NSTextField = {
        let urlLabel = NSTextField(frame: self.urlLabelRect)
        urlLabel.autoresizingMask = .ViewMinXMargin | .ViewMinYMargin
        urlLabel.editable = false
        urlLabel.bordered = false
        urlLabel.drawsBackground = false
        urlLabel.textColor = NSColor.lightGrayColor()
        let cell = urlLabel.cell() as NSCell
        cell.font = NSFont.systemFontOfSize(12)
        cell.alignment = .RightTextAlignment
        urlLabel.stringValue = NSLocalizedString("URL", comment: "") + ": "
        return urlLabel
    }()
    
	private lazy var urlField: SBBLKGUITextField = {
        let urlField = SBBLKGUITextField(frame: self.urlFieldRect)
        urlField.delegate = self
        urlField.autoresizingMask = .ViewMinXMargin | .ViewMinYMargin
        (urlField.cell() as NSCell).alignment = .LeftTextAlignment
        return urlField
    }()
    
    private lazy var doneButton: SBBLKGUIButton = {
        let doneButton = SBBLKGUIButton(frame: self.doneButtonRect)
        doneButton.title = NSLocalizedString("Done", comment: "")
        doneButton.target = self
        doneButton.action = "done"
        doneButton.enabled = false
        doneButton.keyEquivalent = "\r" // busy if button is added into a view
        return doneButton
    }()
    
    private lazy var cancelButton: SBBLKGUIButton = {
        let cancelButton = SBBLKGUIButton(frame: self.cancelButtonRect)
        cancelButton.title = NSLocalizedString("Cancel", comment: "")
        cancelButton.target = self
        cancelButton.action = "cancel"
        cancelButton.keyEquivalent = "\u{1B}"
        return cancelButton
    }()
    
    var message: String {
        get { return messageLabel.stringValue }
        set(message) { messageLabel.stringValue = message }
    }
    
    var urlString: String {
        get { return urlField.stringValue }
        set(urlString) { urlField.stringValue = urlString }
    }

    override init(frame: NSRect) {
        super.init(frame: frame)
        addSubview(messageLabel)
        addSubview(urlLabel)
        addSubview(urlField)
        addSubview(doneButton)
        addSubview(cancelButton)
        makeResponderChain()
        self.autoresizingMask = .ViewMinXMargin | .ViewMaxXMargin | .ViewMinYMargin | .ViewMaxYMargin
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    // MARK: Rects
    
    let margin = NSMakePoint(36.0, 32.0)
    let labelWidth: CGFloat = 85.0
    let buttonSize = NSMakeSize(105.0, 24.0)
    let buttonMargin: CGFloat = 15.0
    
    var messageLabelRect: NSRect {
        var r = NSZeroRect
        r.size.width = bounds.size.width - margin.x * 2
        r.size.height = 36.0
        r.origin.x = margin.x
        r.origin.y = bounds.size.height - r.size.height - margin.y
        return r
    }
    
    var urlLabelRect: NSRect {
        var r = NSZeroRect
        r.origin.x = margin.x
        r.size.width = labelWidth
        r.size.height = 24.0
        r.origin.y = messageLabelRect.origin.y - margin.y - r.size.height
        return r
    }
    
    var urlFieldRect: NSRect {
        var r = NSZeroRect
        r.origin.x = NSMaxX(urlLabelRect) + 10.0
        r.origin.y = urlLabelRect.origin.y
        r.size.width = bounds.size.width - r.origin.x - margin.x
        r.size.height = 24.0
        return r
    }
    
    var doneButtonRect: NSRect {
        var r = NSZeroRect
        r.size = buttonSize
        r.origin.y = margin.y
        r.origin.x = (bounds.size.width - (r.size.width * 2 + buttonMargin)) / 2 + r.size.width + buttonMargin
        return r
    }
    
    var cancelButtonRect: NSRect {
        var r = NSZeroRect
        r.size = buttonSize
        r.origin.y = margin.y
        r.origin.x = (bounds.size.width - (r.size.width * 2 + buttonMargin)) / 2
        return r
    }
    
    // MARK: Delegate
    
    override func controlTextDidChange(notification: NSNotification) {
        doneButton.enabled = !urlString.isEmpty
    }
    
    // MARK: Construction
    
    func makeResponderChain() {
        urlField.nextKeyView = cancelButton
        cancelButton.nextKeyView = doneButton
        doneButton.nextKeyView = urlField
    }
    
    // MARK: Actions
    
    func makeFirstResponderToURLField() {
        window!.makeFirstResponder(urlField)
    }
}