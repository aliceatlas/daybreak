/*
SBAboutView.swift

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

private var _sharedAboutView = SBAboutView(frame: NSMakeRect(0, 0, 640, 360))

class SBAboutView: SBView {
    private lazy var iconImageView: NSImageView = {
        let image = NSImage(named: "Application.icns")
        let r = self.iconImageRect
        let iconImageView = NSImageView(frame: r)
        iconImageView.imageFrameStyle = .None
        iconImageView.autoresizingMask = .ViewMinXMargin | .ViewMinYMargin | .ViewMaxYMargin
        image.size = r.size
        iconImageView.image = image
        iconImageView.imageScaling = .ImageScaleProportionallyDown
        return iconImageView
    }()
    
    private lazy var nameLabel: NSTextField? = {
        let bundle = NSBundle.mainBundle()
        let info = bundle.infoDictionary
        let localizedInfo = bundle.localizedInfoDictionary
        let name: String? = localizedInfo["CFBundleName"] as? NSString
        let version: String? = info["CFBundleVersion"] as? NSString
        let string: String? = (name != nil) ? ((version != nil) ? "\(name) \(version)" : name) : nil
        if string != nil {
            let nameLabel = NSTextField(frame: self.nameLabelRect)
            nameLabel.autoresizingMask = .ViewMinXMargin | .ViewMinYMargin
            nameLabel.editable = false
            nameLabel.bordered = false
            nameLabel.drawsBackground = false
            nameLabel.textColor = NSColor.whiteColor()
            nameLabel.font = NSFont.boldSystemFontOfSize(20)
            nameLabel.alignment = .LeftTextAlignment
            nameLabel.stringValue = string!
            return nameLabel
        }
        return nil
    }()
    
    private lazy var identifierLabel: NSTextField? = {
        if let string: String = NSBundle.mainBundle().infoDictionary["CFBundleIdentifier"] as? NSString {
            let identifierLabel = NSTextField(frame: self.identifierLabelRect)
            identifierLabel.autoresizingMask = .ViewMinXMargin | .ViewMinYMargin
            identifierLabel.editable = false
            identifierLabel.bordered = false
            identifierLabel.drawsBackground = false
            identifierLabel.textColor = NSColor(calibratedWhite: 0.8, alpha: 1.0)
            identifierLabel.font = NSFont.systemFontOfSize(12.0)
            identifierLabel.alignment = .LeftTextAlignment
            identifierLabel.stringValue = string
            return identifierLabel
        }
        return nil
    }()
    
    private lazy var creditScrollView: SBBLKGUIScrollView = {
        let r = self.creditLabelRect
        let rtfdPath = NSBundle.mainBundle().pathForResource("Credits", ofType: "rtfd")
        let creditLabel = NSTextView(frame: r)
        creditLabel.autoresizingMask = .ViewMinXMargin | .ViewMinYMargin
        creditLabel.editable = false
        creditLabel.selectable = true
        creditLabel.drawsBackground = false
        creditLabel.readRTFDFromFile(rtfdPath)
        let creditScrollView = SBBLKGUIScrollView(frame: r)
        creditScrollView.autohidesScrollers = true
        creditScrollView.hasHorizontalScroller = false
        creditScrollView.hasVerticalScroller = true
        creditScrollView.backgroundColor = SBWindowBackColor
        creditScrollView.drawsBackground = false
        creditScrollView.documentView = creditLabel
        return creditScrollView
    }()
    
    private lazy var copyrightLabel: NSTextField? = {
        if let string: String = NSBundle.mainBundle().localizedInfoDictionary["NSHumanReadableCopyright"] as? NSString {
            let copyrightLabel = NSTextField(frame: self.copyrightLabelRect)
            copyrightLabel.autoresizingMask = .ViewMinXMargin | .ViewMinYMargin
            copyrightLabel.editable = false
            copyrightLabel.bordered = false
            copyrightLabel.drawsBackground = false
            copyrightLabel.textColor = NSColor.grayColor()
            copyrightLabel.font = NSFont.systemFontOfSize(12.0)
            copyrightLabel.alignment = .LeftTextAlignment
            copyrightLabel.stringValue = string
            return copyrightLabel
        }
        return nil
    }()
    
    private lazy var backButton: SBBLKGUIButton = {
        let backButton = SBBLKGUIButton(frame: self.backButtonRect)
        backButton.title = NSLocalizedString("Back", comment: "")
        backButton.target = self
        backButton.action = "cancel"
        backButton.keyEquivalent = "\u{1B}"
        return backButton
    }()
    
    class var sharedView: SBAboutView {
        return _sharedAboutView
    }
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        animationDuration = 2.0
        // addSubview(iconImageView) //???
        if nameLabel != nil {
            addSubview(nameLabel!)
        }
        if identifierLabel != nil {
            addSubview(identifierLabel!)
        }
        addSubview(creditScrollView)
        if copyrightLabel != nil {
            addSubview(copyrightLabel!)
        }
        addSubview(backButton)
        autoresizingMask = .ViewMinXMargin | .ViewMaxXMargin | .ViewMinYMargin | .ViewMaxYMargin
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    // MARK: Rects
    
    var iconImageRect: NSRect {
        var r = NSZeroRect
        r.size.width = bounds.size.height / 1.5
        r.size.height = r.size.width
        r.origin.x = 32.0
        r.origin.y = bounds.size.height - r.size.height
        return r
    }
    
    var nameLabelRect: NSRect {
        var r = NSZeroRect
        r.size.width = 240.0
        r.size.height = 24.0
        r.origin.x = NSMaxX(iconImageRect) + iconImageRect.origin.x
        r.origin.y = NSMaxY(iconImageRect) - r.size.height
        return r
    }
    
    var identifierLabelRect: NSRect {
        var r = NSZeroRect
        r.origin.x = nameLabelRect.origin.x
        r.size.width = bounds.size.width - r.origin.x
        r.size.height = 16.0
        r.origin.y = nameLabelRect.origin.y - r.size.height
        return r
    }
    
    var creditLabelRect: NSRect {
        var r = NSZeroRect
        r.origin.x = identifierLabelRect.origin.x
        r.size.width = bounds.size.width - r.origin.x
        r.origin.y = NSMaxY(copyrightLabelRect) + 10.0
        r.size.height = identifierLabelRect.origin.y - (r.origin.y + 10.0)
        return r
    }
    
    var copyrightLabelRect: NSRect {
        var r = NSZeroRect
        r.origin.x = NSMaxX(iconImageRect) + iconImageRect.origin.x
        r.size.width = bounds.size.width - r.origin.x
        r.size.height = 16.0
        r.origin.y = 64.0
        return r
    }
    
    var backButtonRect: NSRect {
        var r = NSZeroRect
        r.size.width = 105.0
        r.size.height = 24.0
        r.origin.x = bounds.size.width - r.size.width
        return r
    }
    
    // MARK: Responder
    
    override func performKeyEquivalent(event: NSEvent) -> Bool {
        let character = Int((event.characters as NSString).characterAtIndex(0))
        if character == NSDeleteCharacter || character == NSCarriageReturnCharacter || character == NSEnterCharacter {
            cancel()
        }
        return super.performKeyEquivalent(event)
    }
    
    // MARK: Drawing
    
    override func drawRect(rect: NSRect) {
        let image: NSImage? = NSImage(named: "Application.icns")
        let ctx = SBCurrentGraphicsPort
        SBWindowBackColor.set()
        NSRectFillUsingOperation(rect, .CompositeSourceOver)
        
        if image != nil {
            var imageRect = iconImageRect
            image!.size = imageRect.size
            image!.drawInRect(imageRect, fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1.0)
            
            imageRect.origin.y = imageRect.size.height * 1.5 - bounds.size.height
            imageRect.size.height = imageRect.size.height * 0.5
            let maskImage = SBBookmarkReflectionMaskImage(imageRect.size)
            CGContextTranslateCTM(ctx, 0.0, imageRect.size.height)
            CGContextScaleCTM(ctx, 1.0, -1.0)
            CGContextClipToMask(ctx, imageRect, maskImage)
            image!.drawInRect(imageRect, fromRect: NSMakeRect(0, 0, imageRect.size.width, imageRect.size.height), operation: .CompositeSourceOver, fraction: 1.0)
        }
    }
}