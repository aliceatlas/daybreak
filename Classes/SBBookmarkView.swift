/*
SBBookmarkView.swift

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

class SBBookmarkView: SBView, NSTextFieldDelegate {
    var image: NSImage? {
        didSet {
            if image != oldValue {
                needsDisplay = true
            }
        }
    }
    
    private lazy var messageLabel: NSTextField? = {
        let messageLabel = NSTextField(frame: self.messageLabelRect)
        messageLabel.autoresizingMask = .ViewMinXMargin | .ViewMinYMargin
        messageLabel.editable = false
        messageLabel.bordered = false
        messageLabel.drawsBackground = false
        messageLabel.textColor = NSColor.whiteColor()
        messageLabel.font = NSFont.boldSystemFontOfSize(16)
        messageLabel.alignment = .CenterTextAlignment
        (messageLabel.cell() as NSCell).wraps = true
        return messageLabel
    }()
    
    private lazy var titleLabel: NSTextField = {
        let titleLabel = NSTextField(frame: self.titleLabelRect)
        titleLabel.autoresizingMask = .ViewMinXMargin | .ViewMinYMargin
        titleLabel.editable = false
        titleLabel.bordered = false
        titleLabel.drawsBackground = false
        titleLabel.textColor = NSColor.lightGrayColor()
        titleLabel.font = NSFont.systemFontOfSize(12)
        titleLabel.alignment = .RightTextAlignment
        titleLabel.stringValue = NSLocalizedString("Title", comment: "") + " :"
        return titleLabel
    }()
    
    private lazy var urlLabel: NSTextField = {
        let urlLabel = NSTextField(frame: self.urlLabelRect)
        urlLabel.autoresizingMask = .ViewMinXMargin | .ViewMinYMargin
        urlLabel.editable = false
        urlLabel.bordered = false
        urlLabel.drawsBackground = false
        urlLabel.textColor = NSColor.lightGrayColor()
        urlLabel.font = NSFont.systemFontOfSize(12)
        urlLabel.alignment = .RightTextAlignment
        urlLabel.stringValue = NSLocalizedString("URL", comment: "") + " :"
        return urlLabel
    }()
    
    private lazy var colorLabel: NSTextField = {
        let colorLabel = NSTextField(frame: self.colorLabelRect)
        colorLabel.autoresizingMask = .ViewMinXMargin | .ViewMinYMargin
        colorLabel.editable = false
        colorLabel.bordered = false
        colorLabel.drawsBackground = false
        colorLabel.textColor = NSColor.lightGrayColor()
        colorLabel.font = NSFont.systemFontOfSize(12)
        colorLabel.alignment = .RightTextAlignment
        colorLabel.stringValue = NSLocalizedString("Label", comment: "") + " :"
        return colorLabel
    }()
    
    private lazy var titleField: SBBLKGUITextField = {
        let titleField = SBBLKGUITextField(frame: self.titleFieldRect)
        titleField.autoresizingMask = .ViewMinXMargin | .ViewMinYMargin
        titleField.alignment = .LeftTextAlignment
        return titleField
    }()
    
    private lazy var urlField: SBBLKGUITextField = {
        let urlField = SBBLKGUITextField(frame: self.urlFieldRect)
        urlField.autoresizingMask = .ViewMinXMargin | .ViewMinYMargin
        urlField.delegate = self
        urlField.alignment = .LeftTextAlignment
        return urlField
    }()
    
    private lazy var colorPopup: SBBLKGUIPopUpButton = {
        let colorPopup = SBBLKGUIPopUpButton(frame: self.colorPopupRect)
        colorPopup.autoresizingMask = .ViewMinXMargin | .ViewMinYMargin
        colorPopup.pullsDown = true
        colorPopup.alignment = .LeftTextAlignment
        colorPopup.menu = SBBookmarkLabelColorMenu(true, nil, nil, nil)
        colorPopup.selectItemAtIndex(1)
        return colorPopup
    }()
    
    private lazy var doneButton: SBBLKGUIButton = {
        let doneButton = SBBLKGUIButton(frame: self.doneButtonRect)
        doneButton.title = NSLocalizedString("Add", comment: "")
        doneButton.target = self
        doneButton.action = "done"
        doneButton.keyEquivalent = "\r" // busy if button is added into a view
        doneButton.enabled = false
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
    
    var fillMode = 1
    
    var message: String {
        get { return messageLabel!.stringValue }
        set(message) { messageLabel!.stringValue = message }
    }
    
    var title: String {
        get { return titleField.stringValue }
        set(title) { titleField.stringValue = title }
    }
    
    var urlString: String {
        get { return urlField.stringValue }
        set(urlString) {
            urlField.stringValue = urlString
            doneButton.enabled = !urlString.isEmpty
        }
    }
    
    var itemRepresentation: NSDictionary {
        let data = image!.bitmapImageRep.data
        let labelName = SBBookmarkLabelColorNames[colorPopup.indexOfSelectedItem - 1]
        let offset: String = NSStringFromPoint(NSZeroPoint)
        return SBCreateBookmarkItem(title, urlString, data, NSDate(), labelName, offset)
    }
    
    // MARK: Construction
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        animationDuration = 1.0
        addSubview(messageLabel!)
        addSubview(titleLabel)
        addSubview(urlLabel)
        addSubview(colorLabel)
        addSubview(titleField)
        addSubview(urlField)
        addSubview(colorPopup)
        addSubview(doneButton)
        addSubview(cancelButton)
        makeResponderChain()
        autoresizingMask = .ViewMinXMargin | .ViewMaxXMargin | .ViewMinYMargin | .ViewMaxYMargin
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func makeResponderChain() {
        titleField.nextKeyView = urlField
        urlField.nextKeyView = cancelButton
        cancelButton.nextKeyView = doneButton
        doneButton.nextKeyView = titleField
    }
    
    // MARK: Rects
    
    let margin = NSMakePoint(36.0, 32.0)
    let labelWidth: CGFloat = 85.0
    let buttonSize = NSMakeSize(105.0, 24.0)
    let buttonMargin: CGFloat = 15.0
    
    var imageRect: NSRect {
        var r = NSZeroRect
        var margin = NSZeroPoint
        r.size = SBBookmarkImageMaxSize()
        margin.x = (bounds.size.height - r.size.height) / 2
        margin.y = r.size.height * 0.5
        r.origin = margin
        return r
    }
    
    var messageLabelRect: NSRect {
        var r = NSZeroRect
        r.size.width = bounds.size.width - margin.x * 2
        r.size.height = 36.0
        r.origin.x = margin.x
        r.origin.y = bounds.size.height - imageRect.origin.y / 2 - r.size.height
        return r
    }
    
    var titleLabelRect: NSRect {
        var r = NSZeroRect
        r.origin.x = NSMaxX(imageRect) + 10.0
        r.size.width = labelWidth
        r.size.height = 24.0
        r.origin.y = NSMaxY(imageRect) - r.size.height
        return r
    }
    
    var urlLabelRect: NSRect {
        var r = NSZeroRect
        r.origin.x = titleLabelRect.origin.x
        r.size.width = labelWidth
        r.size.height = 24.0
        r.origin.y = titleLabelRect.origin.y - 10.0 - r.size.height
        return r
    }
    
    var colorLabelRect: NSRect {
        var r = NSZeroRect
        r.origin.x = urlLabelRect.origin.x
        r.size.width = labelWidth
        r.size.height = 24.0
        r.origin.y = urlLabelRect.origin.y - 10.0 - r.size.height
        return r
    }
    
    var titleFieldRect: NSRect {
        var r = NSZeroRect
        r.origin.x = NSMaxX(titleLabelRect) + 10.0
        r.origin.y = titleLabelRect.origin.y
        r.size.width = bounds.size.width - r.origin.x - margin.x
        r.size.height = 24.0
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
    
    var colorPopupRect: NSRect {
        var r = NSZeroRect
        r.origin.x = NSMaxX(colorLabelRect) + 10.0
        r.origin.y = colorLabelRect.origin.y
        r.size.width = 150.0
        r.size.height = 26.0
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
        r.origin.x = (self.bounds.size.width - (r.size.width * 2 + buttonMargin)) / 2
        return r
    }
    
    // MARK: Delegate
    
    override func controlTextDidChange(notification: NSNotification) {
        if notification.object === urlField {
            doneButton.enabled = !urlField.stringValue.isEmpty
        }
    }
    
    // MARK: Actions
    
    func makeFirstResponderToTitleField() {
        window!.makeFirstResponder(titleField)
    }
    
    // MARK: Drawing
    
    override func drawRect(rect: NSRect) {
        let ctx = SBCurrentGraphicsPort
        let count: UInt = 2
        let transform = CATransform3DIdentity
        var path: CGPathRef?
        
        // Background
        let locations: [CGFloat] = [0.0, 0.6]
        let colors: [CGFloat] = [0.4, 0.4, 0.4, 0.9,
                                 0.0, 0.0, 0.0, 0.0]
        let points: [CGPoint] = [CGPointZero, CGPointMake(0.0, bounds.size.height)]
        
        if fillMode == 0 {
            let r = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.width)
            let transform = CATransform3DRotate(transform, CGFloat(-70 * M_PI / 180), 1.0, 0.0, 0.0)
            path = SBEllipsePath3D(r, transform)
        } else {
            let mpath = CGPathCreateMutable()
            var p = CGPointZero
            let behind: CGFloat = 0.7
            CGPathMoveToPoint(mpath, nil, p.x, p.y)
            p.x = bounds.size.width
            CGPathAddLineToPoint(mpath, nil, p.x, p.y)
            p.x = bounds.size.width - ((bounds.size.width * (1.0 - behind)) / 2)
            p.y = bounds.size.height * locations[1]
            CGPathAddLineToPoint(mpath, nil, p.x, p.y)
            p.x = (bounds.size.width * (1.0 - behind)) / 2
            CGPathAddLineToPoint(mpath, nil, p.x, p.y)
            p = CGPointZero
            CGPathAddLineToPoint(mpath, nil, p.x, p.y)
            path = CGPathCreateCopy(mpath)
        }
        CGContextSaveGState(ctx)
        CGContextAddPath(ctx, path)
        CGContextClip(ctx)
        SBDrawGradientInContext(ctx, count, locations, colors, points)
        CGContextRestoreGState(ctx)
        
        if image != nil {
            var imageRect = NSRectToCGRect(self.imageRect)
            image!.drawInRect(NSRectFromCGRect(imageRect), fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 0.85)
            
            imageRect.origin.y -= imageRect.size.height
            imageRect.size.height *= 0.5
            let maskImage = SBBookmarkReflectionMaskImage(imageRect.size)
            CGContextTranslateCTM(ctx, 0.0, 0.0)
            CGContextScaleCTM(ctx, 1.0, -1.0)
            CGContextClipToMask(ctx, imageRect, maskImage)
            image!.drawInRect(NSRectFromCGRect(imageRect), fromRect: NSMakeRect(0, 0, image!.size.width, image!.size.height * 0.5), operation: .CompositeSourceOver, fraction: 1.0)
        }
    }
}

class SBEditBookmarkView: SBBookmarkView {
	var index = NSNotFound
    
    var labelName: String? {
        get {
        	let itemIndex = colorPopup.indexOfSelectedItem - 1
        	if itemIndex < SBBookmarkCountOfLabelColors {
        		return SBBookmarkLabelColorNames[itemIndex]
        	}
        	return nil
        }
        
        set(labelName) {
        	if let itemIndex = SBBookmarkLabelColorNames.firstIndex({$0 == labelName}) {
        		colorPopup.selectItemAtIndex(itemIndex + 1)
        	}
        }
    }
    
    override var message: String {
        get { fatalError("message property not available"); return "" }
        set(message) { fatalError("message property not available") }
    }
    
    override init(frame: NSRect) {
    	super.init(frame: frame)
        
        messageLabel!.removeFromSuperview()
        messageLabel = nil
        
        doneButton.title = NSLocalizedString("Done", comment: "")
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
}