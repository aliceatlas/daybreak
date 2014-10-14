/*
SBLocalizationWindowController.swift

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

class SBLocalizationWindowController: SBWindowController, NSAnimationDelegate {
    private let kSBLocalizationAvailableSubversionAccess = 0
    
    var contentView: NSView { return window!.contentView as NSView }
    
    private lazy var langField: NSTextField = {
        let contentRect = self.contentView.bounds
        var langFRect = NSZeroRect
        langFRect.size.width = 100.0
        langFRect.size.height = 22.0
        langFRect.origin.x = self.margin
        langFRect.origin.y = (contentRect.size.height - self.topMargin) + (self.topMargin - langFRect.size.height) / 2
        let langField = NSTextField(frame: langFRect)
        langField.autoresizingMask = .ViewMinYMargin
        langField.editable = false
        langField.selectable = false
        langField.bezeled = false
        langField.drawsBackground = false
        langField.font = NSFont.systemFontOfSize(14.0)
        langField.textColor = NSColor.blackColor()
        langField.alignment = .RightTextAlignment
        langField.stringValue = NSLocalizedString("Language", comment: "") + " :"
        return langField
    }()
    
    private lazy var langPopup: NSPopUpButton = {
        let defaults = NSUserDefaults.standardUserDefaults()
        let languages = defaults.objectForKey("AppleLanguages") as [String]
        let menu = NSMenu()
        let langFRect = self.langField.frame
        var langRect = langFRect
        langRect.size.width = 250.0
        langRect.size.height = 22.0
        langRect.origin.x = langFRect.maxX + 8.0
        let langPopup = NSPopUpButton(frame: langRect, pullsDown: false)
        langPopup.autoresizingMask = .ViewMinYMargin
        langPopup.bezelStyle = .TexturedRoundedBezelStyle
        (langPopup.cell() as NSPopUpButtonCell).arrowPosition = .ArrowAtBottom
        for lang in languages {
            let title = NSLocale.systemLocale().displayNameForKey(NSLocaleIdentifier, value: lang)
            menu.addItem(title: title!, representedObject: lang, target: self, action: "selectLanguage:")
        }
        langPopup.menu = menu
        return langPopup
    }()
    
    private lazy var switchButton: NSButton = {
        let contentRect = self.contentView.bounds
        var switchRect = NSZeroRect
        switchRect.size = NSMakeSize(118.0, 25.0)
        switchRect.origin.x = contentRect.size.width - switchRect.size.width - self.margin
        switchRect.origin.y = (contentRect.size.height - self.topMargin) + (self.topMargin - switchRect.size.height) / 2
        let switchButton = NSButton(frame: switchRect)
        switchButton.autoresizingMask = .ViewMinYMargin
        switchButton.setButtonType(.MomentaryPushInButton)
        switchButton.bezelStyle = .TexturedRoundedBezelStyle
        switchButton.target = self
        switchButton.title = NSLocalizedString("Contibute", comment: "")
        switchButton.action = "showContribute"
        return switchButton
    }()
    
    private lazy var editView: NSView = {
        let contentRect = self.contentView.bounds
        var editRect = contentRect
        editRect.size.height -= self.topMargin
        let editView = NSView(frame: editRect)
        editView.autoresizingMask = .ViewWidthSizable | .ViewHeightSizable
        let backgroundColor = CGColorCreateGenericGray(0.8, 1.0)
        self.contentView.layer!.backgroundColor = backgroundColor
        self.editBounds = editView.bounds
        editView.addSubview(self.openButton)
        editView.addSubview(self.cancelButton)
        editView.addSubview(self.createButton)
        return editView
    }()
    
    private var editBounds: NSRect!
    private var editScrollView: NSScrollView?
    private var editContentView: NSView?
    
    var textSet: [[String]] = [] {
        didSet {
            // Apply to fields
            for (i, fields) in enumerate(fieldSet) {
                for (j, field) in enumerate(fields) {
                    if let text = textSet.get(i)?.get(j) {
                        field.stringValue = text
                    }
                }
            }
        }
    }
    
    var fieldSet: [[NSTextField]] = [] {
        didSet {
            editContentView?.removeFromSuperview()
            editContentView = nil
            editScrollView?.removeFromSuperview()
            editScrollView = nil
            
            editContentView = NSView(frame: NSMakeRect(0, 0, viewSize.width, viewSize.height))
            for fields in fieldSet {
                for field in fields {
                    editContentView!.addSubview(field)
                }
            }
            let contentRect = editBounds
            let scrollRect = NSMakeRect(margin, bottomMargin, contentRect.size.width - margin * 2, contentRect.size.height - bottomMargin)
            editScrollView = NSScrollView(frame: scrollRect)
            editScrollView!.autoresizingMask = .ViewWidthSizable | .ViewHeightSizable
            editScrollView!.backgroundColor = NSColor.clearColor()
            editScrollView!.drawsBackground = false
            editScrollView!.hasVerticalScroller = true
            editScrollView!.hasHorizontalScroller = false
            editScrollView!.autohidesScrollers = true
            editView.addSubview(editScrollView!)
            editScrollView!.documentView = editContentView!
            editContentView!.scrollRectToVisible(NSMakeRect(0, viewSize.height, 0, 0))
        }
    }

    private lazy var openButton: NSButton = {
        let doneRect = self.createButton.frame
        var openRect = NSZeroRect
        openRect.size = NSMakeSize(118.0, 25.0)
        openRect.origin.y = doneRect.origin.y
        openRect.origin.x = self.margin
        let openButton = NSButton(frame: openRect)
        openButton.setButtonType(.MomentaryPushInButton)
        openButton.bezelStyle = .TexturedRoundedBezelStyle
        openButton.title = NSLocalizedString("Open…", comment: "")
        openButton.target = self
        openButton.action = "open"
        return openButton
    }()

    private lazy var cancelButton: NSButton = {
        let doneRect = self.createButton.frame
        var cancelRect = NSZeroRect
        cancelRect.size = NSMakeSize(118.0, 25.0)
        cancelRect.origin.y = doneRect.origin.y
        cancelRect.origin.x = doneRect.origin.x - cancelRect.size.width - self.margin
        let cancelButton = NSButton(frame: cancelRect)
        cancelButton.setButtonType(.MomentaryPushInButton)
        cancelButton.bezelStyle = .TexturedRoundedBezelStyle
        cancelButton.title = NSLocalizedString("Cancel", comment: "")
        cancelButton.target = self
        cancelButton.action = "cancel"
        cancelButton.keyEquivalent = "\u{1B}"
        return cancelButton
    }()

    private lazy var createButton: NSButton = {
        let contentRect = self.editBounds
        var doneRect = NSZeroRect
        doneRect.size = NSMakeSize(118.0, 25.0)
        doneRect.origin.y = (self.bottomMargin - doneRect.size.height) / 2
        doneRect.origin.x = contentRect.size.width - doneRect.size.width - self.margin
        let createButton = NSButton(frame: doneRect)
        createButton.title = NSLocalizedString("Create", comment: "")
        createButton.setButtonType(.MomentaryPushInButton)
        createButton.bezelStyle = .TexturedRoundedBezelStyle
        createButton.target = self
        createButton.action = "done"
        createButton.keyEquivalent = "\r"
        return createButton
    }()
    
    private lazy var contributeView: NSView = {
        let contentRect = self.contentView.bounds
        var contributeRect = contentRect
        contributeRect.size.height -= self.topMargin
        let contributeView = NSView(frame: contributeRect)
        contributeView.autoresizingMask = .ViewWidthSizable | .ViewHeightSizable
        contributeView.addSubview(self.iconImageView)
        contributeView.addSubview(self.textField)
        contributeView.addSubview(self.checkoutTitleField)
        contributeView.addSubview(self.checkoutButton)
        contributeView.addSubview(self.commitTitleField)
        contributeView.addSubview(self.commitButton)
        return contributeView
    }()
    
    private lazy var iconImageView: NSImageView = {
        let iconRect = NSMakeRect(50.0, 840.0, 128.0, 128.0)
        let iconImageView = NSImageView(frame: iconRect)
        iconImageView.autoresizingMask = .ViewMinYMargin
        iconImageView.image = NSImage(named: "Icon_Contribute.png")
        return iconImageView
    }()
    
    private lazy var textField: NSTextField = {
        let textRect = NSMakeRect(200.0, 840.0, 490.0, 128.0)
        let textField = NSTextField(frame: textRect)
        textField.autoresizingMask = .ViewMinYMargin
        textField.editable = false
        textField.selectable = false
        textField.bezeled = false
        textField.drawsBackground = false
        textField.font = NSFont.systemFontOfSize(16.0)
        textField.textColor = NSColor.whiteColor()
        textField.alignment = .LeftTextAlignment
        textField.stringValue = NSLocalizedString("You can contribute the translation file for the Sunrise project if you participate in the project on Google Code.", comment: "")
        return textField
    }()
    
    private lazy var checkoutTitleField: NSTextField = {
        let checkoutTitleRect = NSMakeRect(70.0, 775.0, 615.0, 25.0)
        let checkoutTitleField = NSTextField(frame: checkoutTitleRect)
        checkoutTitleField.autoresizingMask = .ViewMinYMargin
        checkoutTitleField.editable = false
        checkoutTitleField.selectable = false
        checkoutTitleField.bezeled = false
        checkoutTitleField.drawsBackground = false
        checkoutTitleField.font = NSFont.boldSystemFontOfSize(16.0)
        checkoutTitleField.textColor = NSColor.whiteColor()
        checkoutTitleField.alignment = .LeftTextAlignment
        checkoutTitleField.stringValue = NSLocalizedString("Check out", comment: "")
        return checkoutTitleField
    }()
    
    private lazy var checkoutButton: NSButton = {
        let checkoutButtonRect = NSMakeRect(70.0, 690.0, 615.0, 80.0)
        let checkoutButton = NSButton(frame: checkoutButtonRect)
        checkoutButton.autoresizingMask = .ViewMinYMargin
        checkoutButton.setButtonType(.MomentaryPushInButton)
        checkoutButton.bezelStyle = .TexturedSquareBezelStyle
        checkoutButton.image = NSImage(named: "Icon_Checkout.png")
        checkoutButton.imagePosition = .ImageLeft
        checkoutButton.title = NSLocalizedString("Check out the translation file from the project on Google Code.", comment: "")
        checkoutButton.target = self
        checkoutButton.action = "openCheckoutDirectory"
        return checkoutButton
    }()
    
    private lazy var commitTitleField: NSTextField = {
        let commitTitleRect = NSMakeRect(70.0, 630.0, 615.0, 25.0)
        let commitTitleField = NSTextField(frame: commitTitleRect)
        commitTitleField.autoresizingMask = .ViewMinYMargin
        commitTitleField.editable = false
        commitTitleField.selectable = false
        commitTitleField.bezeled = false
        commitTitleField.drawsBackground = false
        commitTitleField.font = NSFont.boldSystemFontOfSize(16.0)
        commitTitleField.textColor = NSColor.whiteColor()
        commitTitleField.alignment = .LeftTextAlignment
        commitTitleField.stringValue = NSLocalizedString("Commit", comment: "")
        return commitTitleField
    }()
    
    private lazy var commitButton: NSButton = {
        let commitButtonRect = NSMakeRect(70.0, 545.0, 615.0, 80.0)
        let commitButton = NSButton(frame: commitButtonRect)
        commitButton.autoresizingMask = .ViewMinYMargin
        commitButton.setButtonType(.MomentaryPushInButton)
        commitButton.bezelStyle = .TexturedSquareBezelStyle
        commitButton.image = NSImage(named: "Icon_Commit.png")
        commitButton.imagePosition = .ImageLeft
        commitButton.title = NSLocalizedString("Commit your translation file to the project.", comment: "")
        commitButton.target = self
        commitButton.action = "openCommitDirectory"
        return commitButton
    }()

    private var animating = false
    
    override init(viewSize: NSSize) {
        super.init(viewSize: viewSize)
        if window != nil {
            window!.minSize = NSMakeSize(window!.frame.size.width, 520.0)
            window!.maxSize = NSMakeSize(window!.frame.size.width, viewSize.height + 100)
            window!.title = NSLocalizedString("Localize", comment: "")
            contentView.wantsLayer = true
            contentView.addSubview(langPopup)
            contentView.addSubview(langField)
            #if kSBLocalizationAvailableSubversionAccess
                contentView.addSubview(switchButton)
            #endif
            contentView.addSubview(editView)
        }
    }
    
    required init(coder: NSCoder!) {
        fatalError("NSCoding not supported")
    }
    
    let margin: CGFloat = 20.0
    let topMargin: CGFloat = 40.0
    let bottomMargin: CGFloat = 40.0
        
    func selectLanguage(sender: NSMenuItem) {
        #if kSBLocalizationAvailableSubversionAccess
            var lang = sender.representedObject as String
        #endif
    }
    
    func open() {
        let panel = SBOpenPanel.sbOpenPanel()
        let directoryPath = SBApplicationSupportDirectory(kSBApplicationSupportDirectoryName.stringByAppendingPathComponent(kSBLocalizationsDirectoryName))!
        panel.allowedFileTypes = ["strings"]
        panel.directoryURL = NSURL.fileURLWithPath(directoryPath)
        panel.beginSheet(window!) {
            if $0 == NSFileHandlingPanelOKButton {
                self.mergeFilePath(panel.URL!.path!)
            }
        }
    }
    
    func mergeFilePath(path: String) {
        var vSize: NSSize?
        let lang = path.lastPathComponent.stringByDeletingPathExtension
        
        // Replace text
        if let (tSet, _, _) = SBGetLocalizableTextSet(path) {
            for texts in tSet {
                if texts.count == 2 {
                    let text0 = texts[0]
                    let text1 = texts[1]
                    if let fields = fieldSet.first({ $0.count == 2 && $0[0].stringValue == text0 }) {
                        if fields[1].stringValue != text1 {
                            fields[1].stringValue = text1
                        }
                    }
                }
            }
        }
        
        // Select lang
        langPopup.menu!.selectItem(representedObject: lang)
    }
    
    func showContribute() {
        if !animating {
            changeView(0)
            switchButton.title = NSLocalizedString("Edit", comment: "")
            switchButton.action = "showEdit"
        }
    }
    
    func showEdit() {
        if !animating {
            changeView(1)
            switchButton.title = NSLocalizedString("Contibute", comment: "")
            switchButton.action = "showContribute"
        }
    }

    /* index:
     * 0 - Show the contribute view
     * 1 - Show the edit view
     */
    func changeView(index: Int) {
        var animations: [NSDictionary] = []
        let contentView = window!.contentView as NSView
        let duration: CGFloat = 0.4
        animating = true
        var editRect0 = editView.frame
        var editRect1 = editView.frame
        var contributeRect0 = contributeView.frame
        var contributeRect1 = contributeView.frame
        if index == 0 {
            editRect0.origin.x = 0
            editRect1.origin.x = -editRect1.size.width
            contributeRect0.origin.x = contributeRect0.size.width
            contributeRect1.origin.x = 0
            let height = contentView.bounds.size.height - topMargin
            editRect0.size.height = height
            editRect1.size.height = height
            contributeRect0.size.height = height
            contributeRect1.size.height = height
            contributeView.frame = contributeRect0
            contentView.addSubview(contributeView)
        } else {
            editRect0.origin.x = -editRect1.size.width
            editRect1.origin.x = 0
            contributeRect0.origin.x = 0
            contributeRect1.origin.x = contributeRect0.size.width
            let height = contentView.bounds.size.height - topMargin
            editRect0.size.height = height
            editRect1.size.height = height
            contributeRect0.size.height = height
            contributeRect1.size.height = height
            
            editView.frame = editRect0
            contentView.addSubview(editView)
        }
        animations.append([NSViewAnimationTargetKey: editView,
                           NSViewAnimationStartFrameKey: NSValue(rect: editRect0),
                           NSViewAnimationEndFrameKey: NSValue(rect: editRect1)])
        animations.append([NSViewAnimationTargetKey: contributeView,
                           NSViewAnimationStartFrameKey: NSValue(rect: contributeRect0),
                           NSViewAnimationEndFrameKey: NSValue(rect: contributeRect1)])
        let animation = SBViewAnimation(viewAnimations: animations)
        animation.context = index
        animation.duration = NSTimeInterval(duration)
        animation.delegate = self
        animation.startAnimation()
        
        let backgroundColor = CGColorCreateGenericGray(index == 0 ? 0.5 : 0.8, 1.0)
        CATransaction.begin()
        CATransaction.setValue(duration, forKey: kCATransactionAnimationDuration)
        contentView.layer!.backgroundColor = backgroundColor
        CATransaction.commit()
    }
    
    func animationDidEnd(animation: SBViewAnimation) {
        if let index = animation.context as? Int {
            if index == 0 {
                editView.removeFromSuperview()
            } else {
                contributeView.removeFromSuperview()
            }
        }
        animating = false
    }
    
    func cancel() {
        close()
    }
    
    func done() {
        var success = false
        if let data = SBLocalizableStringsData(fieldSet) {
            let directoryPath = SBApplicationSupportDirectory(kSBApplicationSupportDirectoryName.stringByAppendingPathComponent(kSBLocalizationsDirectoryName))!
            let langCode = langPopup.selectedItem?.representedObject as? NSString
            if let name = langCode?.stringByAppendingPathExtension("strings") {
                // Create strings into application support folder
                let path = directoryPath.stringByAppendingPathComponent(name)
                let url = NSURL.fileURLWithPath(path)!
                if data.writeToURL(url, atomically: true) {
                    // Copy strings into bundle resource
                    let manager = NSFileManager.defaultManager()
                    let directoryPath = NSBundle.mainBundle().resourcePath!.stringByAppendingPathComponent(langCode!).stringByAppendingPathExtension("lproj")!
                    if !manager.fileExistsAtPath(directoryPath) {
                        manager.createDirectoryAtPath(directoryPath, withIntermediateDirectories: true, attributes: nil, error: nil)
                    }
                    let dstPath = directoryPath.stringByAppendingPathComponent("Localizable").stringByAppendingPathExtension("strings")!
                    var error: NSError?
                    if manager.fileExistsAtPath(dstPath) {
                        manager.removeItemAtPath(dstPath, error: &error)
                    }
                    if manager.copyItemAtPath(url.path!, toPath: dstPath, error: &error) {
                        // Complete
                        let alert = NSAlert()
                        alert.messageText = NSLocalizedString("Complete to add new localization. Restart Sunrise.", comment: "")
                        alert.addButtonWithTitle(NSLocalizedString("OK", comment: ""))
                        alert.beginSheetModalForWindow(window!) {
                            (NSModalResponse) -> Void in
                            success = true
                        }
                    }
                }
            }
        }
        if !success {
            // Error
            let alert = NSAlert()
            alert.messageText = NSLocalizedString("Failed to add new localization.", comment: "")
            alert.addButtonWithTitle(NSLocalizedString("OK", comment: ""))
            alert.beginSheetModalForWindow(window!) { (response: NSModalResponse) in return }
        }
    }

    func export() {
        let panel = SBSavePanel.sbSavePanel()
        let langCode = langPopup.selectedItem?.representedObject as? NSString
        let name = langCode?.stringByAppendingPathExtension("strings") ?? ""
        panel.nameFieldStringValue = name
        window!.beginSheet(panel) {
            if $0 == NSFileHandlingPanelOKButton {
                if let data = SBLocalizableStringsData(self.fieldSet) {
                    if data.writeToURL(panel.URL!, atomically: true) {
                        SBDispatch {
                            //self.copyResourceInBundle(url)
                            // hey this was never implemented...
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Contribute

    func openCheckoutDirectory() {
    }

    func openCommitDirectory() {
    }
}



class SBViewAnimation: NSViewAnimation {
    var context: AnyObject?
}