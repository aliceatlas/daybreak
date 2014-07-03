//
//  SBTextInputView.swift
//  Sunrise
//
//  Created by Alice Atlas on 7/2/14.
//
//

class SBTextInputView: SBView, NSTextFieldDelegate {
    var messageLabel: NSTextField!
    var textLabel: SBBLKGUITextField!
    var cancelButton: SBBLKGUIButton?
    var doneButton: SBBLKGUIButton?
    
    var message: String {
        get {
            return messageLabel.stringValue
        }
        set(message) {
            messageLabel.stringValue = message
        }
    }
    
    var text: String {
        get {
            return textLabel.stringValue
        }
        set(text) {
            textLabel.stringValue = text
        }
    }
    
    init(frame: NSRect, prompt: NSString) {
        super.init(frame: frame)
        self.constructMessageLabel(prompt)
        self.constructTextLabel()
        self.autoresizingMask = .ViewMinXMargin | .ViewMaxXMargin | .ViewMinYMargin | .ViewMaxYMargin
    }
    
    // Rects

    let margin = NSMakePoint(36.0, 32.0)
    let labelWidth = 85.0
    let buttonSize = NSMakeSize(105.0, 24.0)
    let buttonMargin = 15.0
    let textFont = NSFont.systemFontOfSize(16)
    
    var messageLabelRect: NSRect {
        let size = NSSize(width: self.bounds.size.width - margin.x * 2, height: 36.0)
        let origin = NSPoint(x: margin.x, y: self.bounds.size.height - size.height - margin.y)
        return NSRect(origin: origin, size: size)
    }
    
    var textLabelRect: NSRect {
        let size = NSSize(
            width: self.bounds.size.width - margin.x * 2,
            height: (self.bounds.size.height - messageLabelRect.size.height - buttonSize.height) - margin.y * 4)
        let origin = NSPoint(x: margin.x, y: messageLabelRect.origin.y - size.height)
        return NSRect(origin: origin, size: size)
    }
    
    var doneButtonRect: NSRect {
        let size = buttonSize
        let origin = NSPoint(x: (self.bounds.size.width - (size.width * 2 + buttonMargin)) / 2 + size.width + buttonMargin,
            y: margin.y)
        return NSRect(origin: origin, size: size)
    }
    
    var cancelButtonRect: NSRect {
        let size = buttonSize
        let origin = NSPoint(x: (self.bounds.size.width - (size.width * 2 + buttonMargin)) / 2,
            y: margin.y)
        return NSRect(origin: origin, size: size)
    }
    
    // Construction
    
    func constructMessageLabel(inMessage: String) {
        let r = messageLabelRect
        let font = NSFont.boldSystemFontOfSize(16)
        let size = NSString(string: inMessage).sizeWithAttributes([NSFontAttributeName: font])
        messageLabel = NSTextField(frame: r)
        messageLabel.autoresizingMask = .ViewMinXMargin | .ViewMinYMargin
        messageLabel.editable = false
        messageLabel.bordered = false
        messageLabel.drawsBackground = false
        messageLabel.textColor = NSColor.whiteColor()
        let cell = messageLabel.cell() as NSTextFieldCell
        cell.font = font
        cell.alignment = size.width > (r.size.width - 20.0) ? .LeftTextAlignment : .CenterTextAlignment
        (messageLabel.cell() as NSTextFieldCell).wraps = true
        messageLabel.stringValue = inMessage
        self.addSubview(messageLabel)
    }
    
    func constructTextLabel() {
        let r = textLabelRect
        textLabel = SBBLKGUITextField(frame: r)
        textLabel.alignment = .LeftTextAlignment
        textLabel.font = NSFont.systemFontOfSize(14.0)
        textLabel.textColor = NSColor.whiteColor()
        textLabel.delegate = self
        (textLabel.cell() as NSTextFieldCell).wraps = true
        self.addSubview(textLabel)
    }
    
    func constructDoneButton() {
        let r = doneButtonRect
        doneButton = SBBLKGUIButton(frame: r)
        doneButton!.title = NSLocalizedString("OK", comment: "")
        doneButton!.target = self
        doneButton!.action = "done"
        doneButton!.enabled = true
        doneButton!.keyEquivalent = "\r" // busy if button is added into a view
        self.addSubview(doneButton!)
    }
    
    func constructCancelButton() {
        let r = cancelButtonRect
        cancelButton = SBBLKGUIButton(frame: r)
        cancelButton!.title = NSLocalizedString("Cancel", comment: "")
        cancelButton!.target = self
        cancelButton!.action = "cancel"
        cancelButton!.keyEquivalent = "\x1B" // busy if button is added into a view
        self.addSubview(cancelButton!)
    }
    
    // Delegate
    
    override func controlTextDidChange(_: NSNotification) {
        if doneButton != nil {
            doneButton!.enabled = textLabel.stringValue.utf16count > 0
        }
    }
    
    // Setter
    
    override var doneSelector: Selector {
        didSet {
            if doneSelector != nil && doneButton == nil {
                self.constructDoneButton()
            }
        }
    }
    
    override var cancelSelector: Selector {
        didSet {
            if cancelSelector != nil && cancelButton == nil {
                self.constructCancelButton()
            }
        }
    }
}