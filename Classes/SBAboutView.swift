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

import BLKGUI

class SBAboutView: SBView {
    static let sharedView = SBAboutView(frame: NSMakeRect(0, 0, 640, 360))
    
    private lazy var iconImageView: NSImageView = {
        let image = NSImage(named: "Application.icns")!
        let r = self.iconImageRect
        let iconImageView = NSImageView(frame: r)
        iconImageView.imageFrameStyle = .None
        iconImageView.autoresizingMask = [.ViewMinXMargin, .ViewMinYMargin, .ViewMaxYMargin]
        image.size = r.size
        iconImageView.image = image
        iconImageView.imageScaling = .ScaleProportionallyDown
        return iconImageView
    }()
    
    private lazy var nameLabel: NSTextField = {
        let nameLabel = NSTextField()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.editable = false
        nameLabel.bordered = false
        nameLabel.drawsBackground = false
        nameLabel.textColor = NSColor.whiteColor()
        nameLabel.font = NSFont.boldSystemFontOfSize(20)
        nameLabel.alignment = .Left
        let bundle = NSBundle.mainBundle()
        let info = bundle.infoDictionary
        let localizedInfo = bundle.localizedInfoDictionary
        let name = localizedInfo?["CFBundleName"] as? String
        let version = info?["CFBundleVersion"] as? String
        let string = name !! {$0 + (version !! {" \($0)"} ?? "")}
        string !! { nameLabel.stringValue = $0 }
        return nameLabel
    }()
    
    private lazy var identifierLabel: NSTextField = {
        let identifierLabel = NSTextField()
        identifierLabel.translatesAutoresizingMaskIntoConstraints = false
        identifierLabel.editable = false
        identifierLabel.bordered = false
        identifierLabel.drawsBackground = false
        identifierLabel.textColor = NSColor(calibratedWhite: 0.8, alpha: 1.0)
        identifierLabel.font = NSFont.systemFontOfSize(12.0)
        identifierLabel.alignment = .Left
        if let string = NSBundle.mainBundle().infoDictionary?["CFBundleIdentifier"] as? String {
            identifierLabel.stringValue = string
        }
        return identifierLabel
    }()
    
    private lazy var creditScrollView: BLKGUI.ScrollView = {
        let rtfdPath = NSBundle.mainBundle().pathForResource("Credits", ofType: "rtfd")!
        let creditLabel = NSTextView()
        creditLabel.autoresizingMask = [.ViewWidthSizable, .ViewHeightSizable]
        creditLabel.editable = false
        creditLabel.selectable = true
        creditLabel.drawsBackground = false
        creditLabel.readRTFDFromFile(rtfdPath)
        let creditScrollView = BLKGUI.ScrollView()
        creditScrollView.translatesAutoresizingMaskIntoConstraints = false
        creditScrollView.autohidesScrollers = true
        creditScrollView.hasHorizontalScroller = false
        creditScrollView.hasVerticalScroller = true
        creditScrollView.backgroundColor = SBWindowBackColor
        creditScrollView.drawsBackground = false
        creditScrollView.documentView = creditLabel
        return creditScrollView
    }()
    
    private lazy var copyrightLabel: NSTextField = {
        let copyrightLabel = NSTextField()
        copyrightLabel.translatesAutoresizingMaskIntoConstraints = false
        copyrightLabel.editable = false
        copyrightLabel.bordered = false
        copyrightLabel.drawsBackground = false
        copyrightLabel.textColor = NSColor.grayColor()
        copyrightLabel.font = NSFont.systemFontOfSize(12.0)
        copyrightLabel.alignment = .Left
        if let string = NSBundle.mainBundle().localizedInfoDictionary?["NSHumanReadableCopyright"] as? String {
            copyrightLabel.stringValue = string
        }
        return copyrightLabel
    }()
    
    private lazy var backButton: BLKGUI.Button = {
        let backButton = BLKGUI.Button()
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.title = NSLocalizedString("Back", comment: "")
        backButton.target = self
        backButton.action = #selector(cancel)
        backButton.keyEquivalent = "\u{1B}"
        return backButton
    }()
    
    private lazy var rightColumn: NSView = {
        let rightColumn = NSView()
        rightColumn.translatesAutoresizingMaskIntoConstraints = false
        rightColumn.addSubviewsAndConstraintStrings(
            metrics: ["margin": 10],
            views: ["name": self.nameLabel, "identifier": self.identifierLabel, "credits": self.creditScrollView, "copyright": self.copyrightLabel, "back": self.backButton],
            "V:|[name(24)][identifier(16)]-margin-[credits]-margin-[copyright(16)]-40-[back(23)]|",
            "|[name]|",
            "|[identifier]|",
            "|[credits]|",
            "|[copyright]|",
            "[back(105)]|"
        )
        return rightColumn
    }()
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        animationDuration = 2.0
        // addSubview(iconImageView) //???
        addSubviewsAndConstraintStrings(
            metrics: [:],
            views: ["rightColumn": rightColumn],
            "V:|[rightColumn]|",
            "[rightColumn(336)]|"
        )
        autoresizingMask = [.ViewMinXMargin, .ViewMaxXMargin, .ViewMinYMargin, .ViewMaxYMargin]
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
    
    // MARK: Responder
    
    override func performKeyEquivalent(event: NSEvent) -> Bool {
        let character = Int((event.characters! as NSString).characterAtIndex(0))
        if character == NSDeleteCharacter || character == NSCarriageReturnCharacter || character == NSEnterCharacter {
            cancel()
        }
        return super.performKeyEquivalent(event)
    }
    
    // MARK: Drawing
    
    override func drawRect(rect: NSRect) {
        SBWindowBackColor.set()
        NSRectFillUsingOperation(rect, .CompositeSourceOver)
        
        if let image = NSImage(named: "Application.icns") {
            var imageRect = iconImageRect
            image.size = imageRect.size
            image.drawInRect(imageRect, fromRect: .zero, operation: .CompositeSourceOver, fraction: 1.0)
            
            imageRect.origin.y = imageRect.size.height * 1.5 - bounds.size.height
            imageRect.size.height = imageRect.size.height * 0.5
            let maskImage = SBBookmarkReflectionMaskImage(imageRect.size)
            let ctx = SBCurrentGraphicsPort
            CGContextTranslateCTM(ctx, 0.0, imageRect.size.height)
            CGContextScaleCTM(ctx, 1.0, -1.0)
            CGContextClipToMask(ctx, imageRect, maskImage.CGImage)
            image.drawInRect(imageRect, fromRect: NSMakeRect(0, 0, imageRect.size.width, imageRect.size.height), operation: .CompositeSourceOver, fraction: 1.0)
        }
    }
}