/*
SBSnapshotView.swift

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

class SBSnapshotView: SBView, NSTextFieldDelegate {
    // TODO: stop using stringValue workaround when possible
    
    private let kSBMinFrameSizeWidth: CGFloat = 600
    private let kSBMaxFrameSizeWidth: CGFloat = 1200
    private let kSBMinFrameSizeHeight: CGFloat = 480
    private let kSBMaxFrameSizeHeight: CGFloat = 960
    private let kSBMaxImageSizeWidth: CGFloat = 10000
    private let kSBMaxImageSizeHeight: CGFloat = 10000
    
    private lazy var scrollView: SBBLKGUIScrollView = {
        let scrollView = SBBLKGUIScrollView(frame: NSMakeRect(self.margin.x, self.margin.y, self.imageViewSize.width, self.imageViewSize.height))
        scrollView.documentView = self.imageView
        scrollView.autoresizingMask = .ViewWidthSizable | .ViewHeightSizable
        scrollView.hasHorizontalScroller = true
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.backgroundColor = NSColor.blackColor()
        scrollView.drawsBackground = true
        return scrollView
    }()
    
    private lazy var imageView: NSImageView = {
        let imageViewSize = NSMakeSize(self.frame.size.width - self.margin.x - self.toolWidth - 8.0, self.frame.size.height - self.margin.y - 20.0)
        return NSImageView(frame: NSRect(origin: NSZeroPoint, size: imageViewSize))
    }()
    private var imageViewSize: NSSize { return imageView.bounds.size }
    
    private lazy var toolsView: NSView = {
        let toolsView = NSView(frame: NSMakeRect(self.imageViewSize.width + self.margin.x + 8.0, self.margin.y, self.toolWidth, self.imageViewSize.height))
        toolsView.addSubview(self.onlyVisibleButton)
        toolsView.addSubview(self.updateButton)
        toolsView.addSubview(self.sizeLabel)
        toolsView.addSubview(self.widthField)
        toolsView.addSubview(self.heightField)
        toolsView.addSubview(self.scaleLabel)
        toolsView.addSubview(self.scaleField)
        toolsView.addSubview(self.lockButton)
        toolsView.addSubview(self.filetypeLabel)
        toolsView.addSubview(self.filetypePopup)
        toolsView.addSubview(self.optionTabView)
        toolsView.addSubview(self.filesizeLabel)
        toolsView.addSubview(self.filesizeField)
        return toolsView
    }()
    
    private lazy var onlyVisibleButton: SBBLKGUIButton = {
        let onlyVisibleButton = SBBLKGUIButton(frame: NSMakeRect(6, self.imageViewSize.height - 36, 119, 36))
        onlyVisibleButton.buttonType = .SwitchButton
        onlyVisibleButton.state = NSUserDefaults.standardUserDefaults().boolForKey(kSBSnapshotOnlyVisiblePortion) ? NSOnState : NSOffState
        onlyVisibleButton.target = self
        onlyVisibleButton.action = "checkOnlyVisible:"
        onlyVisibleButton.title = NSLocalizedString("Only visible portion", comment: "")
        onlyVisibleButton.font = NSFont.systemFontOfSize(10.0)
        return onlyVisibleButton
    }()
    
    private lazy var updateButton: SBBLKGUIButton = {
        let updateButton = SBBLKGUIButton(frame: NSMakeRect(6, self.imageViewSize.height - 76, 119, 32))
        updateButton.buttonType = .MomentaryPushInButton
        updateButton.target = self
        updateButton.action = "update:"
        updateButton.image = NSImage(named: "Icon_Camera.png")
        updateButton.title = NSLocalizedString("Update", comment: "")
        updateButton.font = NSFont.systemFontOfSize(11.0)
        updateButton.keyEquivalentModifierMask = Int(NSEventModifierFlags.CommandKeyMask.rawValue)
        updateButton.keyEquivalent = "r"
        return updateButton
    }()
    
    private lazy var sizeLabel: NSTextField = {
        let sizeLabel = NSTextField(frame: NSMakeRect(6, self.imageViewSize.height - 98, 120, 14))
        sizeLabel.bordered = false
        sizeLabel.editable = false
        sizeLabel.drawsBackground = false
        sizeLabel.textColor = NSColor.whiteColor()
        sizeLabel.stringValue = NSLocalizedString("Size", comment: "") + " :"
        return sizeLabel
    }()
    
    private lazy var widthField: SBBLKGUITextField = {
        let widthField = SBBLKGUITextField(frame: NSMakeRect(6, self.imageViewSize.height - 130, 67, 24))
        widthField.delegate = self
        widthField.formatter = self.numberFormatter
        return widthField
    }()
    
    private lazy var heightField: SBBLKGUITextField = {
        let heightField = SBBLKGUITextField(frame: NSMakeRect(6, self.imageViewSize.height - 162, 67, 24))
        heightField.delegate = self
        heightField.formatter = self.numberFormatter
        return heightField
    }()
    
    private lazy var scaleLabel: NSTextField = {
        let scaleLabel = NSTextField(frame: NSMakeRect(6, self.imageViewSize.height - 184, 120, 14))
        scaleLabel.bordered = false
        scaleLabel.editable = false
        scaleLabel.drawsBackground = false
        scaleLabel.textColor = NSColor.whiteColor()
        scaleLabel.stringValue = NSLocalizedString("Scale", comment: "") + " :"
        return scaleLabel
    }()
    
    private lazy var scaleField: SBBLKGUITextField = {
        let scaleField = SBBLKGUITextField(frame: NSMakeRect(6, self.imageViewSize.height - 216, 67, 24))
        scaleField.delegate = self
        scaleField.formatter = self.numberFormatter
        return scaleField
    }()
    
    private lazy var lockButton: NSButton = {
        let lockButton = NSButton(frame: NSMakeRect(93, self.imageViewSize.height - 151, 32, 32))
        lockButton.imagePosition = .ImageOnly
        lockButton.setButtonType(.ToggleButton)
        lockButton.image = NSImage(named: "Icon_Lock.png")
        lockButton.alternateImage = NSImage(named: "Icon_Unlock.png")
        (lockButton.cell() as NSButtonCell).imageScaling = .ImageScaleNone
        lockButton.bordered = false
        return lockButton
    }()
    
    private lazy var filetypeLabel: NSTextField = {
        let filetypeLabel = NSTextField(frame: NSMakeRect(6, self.imageViewSize.height - 238, 120, 14))
        filetypeLabel.bordered = false
        filetypeLabel.editable = false
        filetypeLabel.drawsBackground = false
        filetypeLabel.textColor = NSColor.whiteColor()
        filetypeLabel.stringValue = NSLocalizedString("File Type", comment: "")
        return filetypeLabel
    }()
    
    private lazy var filetypePopup: SBBLKGUIPopUpButton = {
        var selectedIndex = 0
        let filetypePopup = SBBLKGUIPopUpButton(frame: NSMakeRect(6, self.imageViewSize.height - 272, 114, 26))
        let menu = filetypePopup.menu
        let fileTypeNames = ["TIFF", "GIF", "JPEG", "PNG"]
        let filetypes = [NSBitmapImageFileType.NSTIFFFileType, NSBitmapImageFileType.NSGIFFileType, NSBitmapImageFileType.NSJPEGFileType, NSBitmapImageFileType.NSPNGFileType]
        menu.addItemWithTitle("", action: nil, keyEquivalent: "")
        for i in 0..<fileTypeNames.count {
            let item = NSMenuItem(title: fileTypeNames[i], action: "selectFiletype:", keyEquivalent: "")
            item.target = self
            item.tag = Int(filetypes[i].rawValue)
            item.state = (self.filetype == filetypes[i]) ? NSOnState : NSOffState
            if self.filetype == filetypes[i] {
                selectedIndex = i + 1
            }
            menu.addItem(item)
        }
        filetypePopup.pullsDown = true
        filetypePopup.selectItemAtIndex(selectedIndex)
        return filetypePopup
    }()
    
    private lazy var optionTabView: NSTabView = {
        let optionTabView = NSTabView(frame: NSMakeRect(6, self.imageViewSize.height - 321, 114, 45))
        optionTabView.tabViewType = .NoTabsNoBorder
        optionTabView.drawsBackground = false
        let tabViewItem0 = NSTabViewItem(identifier: NSString(format: "%d", NSBitmapImageFileType.NSTIFFFileType.rawValue))
        tabViewItem0.view.addSubview(self.tiffOptionLabel)
        tabViewItem0.view.addSubview(self.tiffOptionPopup)
        let tabViewItem1 = NSTabViewItem(identifier: NSString(format: "%d", NSBitmapImageFileType.NSJPEGFileType.rawValue))
        tabViewItem1.view.addSubview(self.jpgOptionLabel)
        tabViewItem1.view.addSubview(self.jpgOptionSlider)
        tabViewItem1.view.addSubview(self.jpgOptionField)
        optionTabView.addTabViewItem(tabViewItem0)
        optionTabView.addTabViewItem(tabViewItem1)
        switch self.filetype {
            case NSBitmapImageFileType.NSTIFFFileType:
                optionTabView.selectTabViewItemWithIdentifier(NSString(format: "%d", NSBitmapImageFileType.NSTIFFFileType.rawValue))
                optionTabView.hidden = false
            case NSBitmapImageFileType.NSJPEGFileType:
                optionTabView.selectTabViewItemWithIdentifier(NSString(format: "%d", NSBitmapImageFileType.NSJPEGFileType.rawValue))
                optionTabView.hidden = false
            default:
                optionTabView.hidden = true
        }
        return optionTabView
    }()
    
    private lazy var tiffOptionLabel: NSTextField = {
        let tiffOptionLabel = NSTextField(frame: NSMakeRect(0, 32, 120, 13))
        tiffOptionLabel.bordered = false
        tiffOptionLabel.editable = false
        tiffOptionLabel.drawsBackground = false
        tiffOptionLabel.textColor = NSColor.whiteColor()
        tiffOptionLabel.stringValue = NSLocalizedString("Compression", comment: "") + " :"
        return tiffOptionLabel
    }()
    
    private lazy var tiffOptionPopup: SBBLKGUIPopUpButton = {
        var selectedIndex = 0
        let tiffOptionPopup = SBBLKGUIPopUpButton(frame: NSMakeRect(12, 0, 100, 26))
        let menu = tiffOptionPopup.menu
        let compressionNames = [NSLocalizedString("None", comment: ""), "LZW", "PackBits"]
        let compressions: [NSTIFFCompression] = [.None, .LZW, .PackBits]
        menu.addItemWithTitle("", action: nil, keyEquivalent: "")
        for i in 0..<compressionNames.count {
            let item = NSMenuItem(title: compressionNames[i], action: "selectTiffOption:", keyEquivalent: "")
            item.tag = Int(compressions[i].rawValue)
            item.state = (self.tiffCompression == compressions[i]) ? NSOnState : NSOffState
            if self.tiffCompression == compressions[i] {
                selectedIndex = i + 1
            }
            menu.addItem(item)
        }
        tiffOptionPopup.pullsDown = true
        tiffOptionPopup.selectItemAtIndex(selectedIndex)
        return tiffOptionPopup
    }()
    
    private lazy var jpgOptionLabel: NSTextField = {
        let jpgOptionLabel = NSTextField(frame: NSMakeRect(0, 32, 120, 13))
        jpgOptionLabel.bordered = false
        jpgOptionLabel.editable = false
        jpgOptionLabel.drawsBackground = false
        jpgOptionLabel.textColor = NSColor.whiteColor()
        jpgOptionLabel.stringValue = NSLocalizedString("Quality", comment: "") + " :"
        return jpgOptionLabel
    }()
    
    private lazy var jpgOptionSlider: SBBLKGUISlider = {
        let jpgOptionSlider = SBBLKGUISlider(frame: NSMakeRect(5, 8, 75, 17))
        (jpgOptionSlider.cell() as SBBLKGUISliderCell).controlSize = .MiniControlSize
        jpgOptionSlider.minValue = 0.0
        jpgOptionSlider.maxValue = 1.0
        jpgOptionSlider.numberOfTickMarks = 11
        jpgOptionSlider.tickMarkPosition = .Below
        jpgOptionSlider.allowsTickMarkValuesOnly = true
        jpgOptionSlider.doubleValue = Double(self.jpgFactor)
        jpgOptionSlider.target = self
        jpgOptionSlider.action = "slideJpgOption:"
        return jpgOptionSlider
    }()
    
    private lazy var jpgOptionField: NSTextField = {
        let jpgOptionField = NSTextField(frame: NSMakeRect(90, 10, 30, 13))
        jpgOptionField.editable = false
        jpgOptionField.selectable = false
        jpgOptionField.bordered = false
        jpgOptionField.drawsBackground = false
        jpgOptionField.textColor = NSColor.whiteColor()
        jpgOptionField.stringValue = NSString(format: "%.1f", Double(self.jpgFactor))
        return jpgOptionField
    }()
    
    private lazy var filesizeLabel: NSTextField = {
        let filesizeLabel = NSTextField(frame: NSMakeRect(3, self.imageViewSize.height - 343, 120, 14))
        filesizeLabel.bordered = false
        filesizeLabel.editable = false
        filesizeLabel.drawsBackground = false
        filesizeLabel.textColor = NSColor.whiteColor()
        filesizeLabel.stringValue = NSLocalizedString("File Size", comment: "") + " :"
        return filesizeLabel
    }()
    
    private lazy var filesizeField: NSTextField = {
        let filesizeField = NSTextField(frame: NSMakeRect(15, self.imageViewSize.height - 368, 108, 17))
        filesizeField.bordered = false
        filesizeField.editable = false
        filesizeField.drawsBackground = false
        filesizeField.textColor = NSColor.whiteColor()
        return filesizeField
    }()
    
    private lazy var cancelButton: SBBLKGUIButton = {
        let cancelButton = SBBLKGUIButton(frame: self.cancelButtonRect)
        cancelButton.title = NSLocalizedString("Cancel", comment: "")
        cancelButton.target = self
        cancelButton.action = "cancel"
        cancelButton.keyEquivalent = "\u{1B}"
        return cancelButton
    }()
    
    private lazy var doneButton: SBBLKGUIButton = {
        let doneButton = SBBLKGUIButton(frame: self.doneButtonRect)
        doneButton.title = NSLocalizedString("Done", comment: "")
        doneButton.target = self
        doneButton.action = "save:"
        doneButton.enabled = false
        doneButton.keyEquivalent = "\r" // busy if button is added into a view
        return doneButton
    }()
    
    private lazy var numberFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .NoStyle
        return formatter
    }()
    
    //private var progressBackgroundView: SBView
    //private var progressField: NSTextField
    //progressField.stringValue = NSLocalizedString("Updating...", comment: "")
    //private var progressIndicator: NSProgressIndicator
    
    private var _visibleRect: NSRect = NSZeroRect
    override var visibleRect: NSRect {
        get { return _visibleRect }
        set(visibleRect) { _visibleRect = visibleRect }
    }
    
    private var image: NSImage?
    
    private lazy var filetype: NSBitmapImageFileType = {
        if let value = NSUserDefaults.standardUserDefaults().objectForKey(kSBSnapshotFileType) as? NSNumber {
            return NSBitmapImageFileType(rawValue: UInt(value.intValue))!
        } else {
            return NSBitmapImageFileType.NSTIFFFileType
        }
    }()
    
    private lazy var tiffCompression: NSTIFFCompression = {
        if let value = NSUserDefaults.standardUserDefaults().objectForKey(kSBSnapshotTIFFCompression) as? NSNumber {
            return NSTIFFCompression(rawValue: UInt(value.intValue))!
        } else {
            return .None
        }
    }()
    
    private lazy var jpgFactor: CGFloat = {
        if let value = NSUserDefaults.standardUserDefaults().objectForKey(kSBSnapshotJPGFactor) as? NSNumber {
            return CGFloat(value.doubleValue)
        } else {
            return 1.0
        }
    }()
    
    private var updateTimer: NSTimer?
    private var successSize: NSSize = NSZeroSize
    private var successScale: CGFloat = 1.0
    var title: String?
    var data: NSData?
    
    var filename: String {
        let untitled: NSString = NSLocalizedString("Untitled", comment: "")
        switch filetype {
            case NSBitmapImageFileType.NSTIFFFileType:
                return title ?? untitled.stringByAppendingPathExtension("tiff")!
            case NSBitmapImageFileType.NSGIFFileType:
                return title ?? untitled.stringByAppendingPathExtension("gif")!
            case NSBitmapImageFileType.NSJPEGFileType:
                return title ?? untitled.stringByAppendingPathExtension("jpg")!
            case NSBitmapImageFileType.NSPNGFileType:
                return title ?? untitled.stringByAppendingPathExtension("png")!
            default:
                return title ?? untitled
        }
    }
    
    override init(frame: NSRect) {
        var r = frame
        SBConstrain(&r.size.width, min: kSBMinFrameSizeWidth, max: kSBMaxFrameSizeWidth)
        SBConstrain(&r.size.height, min: kSBMinFrameSizeHeight, max: kSBMaxFrameSizeHeight)
        super.init(frame: r)
        addSubview(toolsView)
        addSubview(scrollView)
        addSubview(cancelButton)
        addSubview(doneButton)
        autoresizingMask = .ViewMinXMargin | .ViewMaxXMargin | .ViewMinYMargin | .ViewMaxYMargin
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "windowDidResize:", name: NSWindowDidResizeNotification, object: window)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSWindowDidResizeNotification, object: window)
        destruct()
    }
    
    // MARK: Rects
    
    let margin = NSMakePoint(20.0, 52.0)
    let labelWidth: CGFloat = 85.0
    let buttonSize = NSMakeSize(105.0, 24.0)
    let buttonMargin: CGFloat = 15.0
    let toolWidth: CGFloat = 140
    
    var doneButtonRect: NSRect {
        var r = NSZeroRect
        r.size = buttonSize
        r.origin.x = (bounds.size.width - (r.size.width * 2 + buttonMargin)) / 2 + r.size.width + buttonMargin
        return r
    }
    
    var cancelButtonRect: NSRect {
        var r = NSZeroRect
        r.size = buttonSize
        r.origin.x = (bounds.size.width - (r.size.width * 2 + buttonMargin)) / 2
        return r
    }
    
    // MARK: Delegate
    
    func windowDidResize(notification: NSNotification) {
        var imageRect = imageView.frame
        let imageSize = imageView.image.size
        var scrollBounds = NSZeroRect
        scrollBounds.size = scrollView.frame.size
        imageRect.size.width = SBConstrain(imageSize.width, min: scrollBounds.size.width)
        imageRect.size.height = SBConstrain(imageSize.height, min: scrollBounds.size.height)
        imageView.frame = imageRect
    }
    
    override func controlTextDidChange(notification: NSNotification) {
        let field: AnyObject = notification.object!
        destructUpdateTimer()
        if shouldShowSizeWarning(field) {
            let title = NSLocalizedString("The application may not respond if the processing is continued. Are you sure you want to continue?", comment: "")
            let alert = NSAlert()
            alert.messageText = title
            alert.addButtonWithTitle(NSLocalizedString("Continue", comment: ""))
            alert.addButtonWithTitle(NSLocalizedString("Cancel", comment: ""))
            let r = alert.runModal()
            if r == NSOKButton {
                updateTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "updateWithTimer:", userInfo: field, repeats: false)
            } else {
                if field === widthField {
                    widthField.integerValue = Int(successSize.width)
                } else if field === heightField {
                    heightField.integerValue = Int(successSize.height)
                } else if field === scaleField {
                    scaleField.integerValue = Int(successScale * 100)
                }
            }
        } else {
            updateTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "updateWithTimer:", userInfo: field, repeats: false)
        }
    }
    
    override func controlTextDidEndEditing(notification: NSNotification) {
    }
    
    // MARK: Actions (Private)
    
    private func shouldShowSizeWarning(field: AnyObject) -> Bool {
        var r = false
        if field === scaleField {
            let s = CGFloat(scaleField.integerValue) / 100
            if lockButton.state == NSOffState {
                if onlyVisibleButton.state == NSOnState {
                    r = visibleRect.size.width * s >= kSBMaxImageSizeWidth
                    if !r {
                        r = visibleRect.size.height * s >= kSBMaxImageSizeHeight
                    }
                } else {
                    r = image!.size.width * s >= kSBMaxImageSizeWidth
                    if !r {
                        r = image!.size.height * s >= kSBMaxImageSizeHeight
                    }
                }
            }
        } else if field === widthField {
            let w = CGFloat(widthField.integerValue)
            r = w >= kSBMaxImageSizeWidth
            if !r {
                if lockButton.state == NSOffState {
                    if onlyVisibleButton.state == NSOnState {
                        let per = w / visibleRect.size.width
                        r = visibleRect.size.height * per >= kSBMaxImageSizeHeight
                    } else {
                        let per = w / visibleRect.size.width
                        r = image!.size.height * per >= kSBMaxImageSizeHeight
                    }
                }
            }
        } else if field === heightField {
            let h = CGFloat(heightField.integerValue)
            r = h >= kSBMaxImageSizeHeight
            if !r {
                if lockButton.state == NSOffState {
                    var per: CGFloat = 1.0
                    if onlyVisibleButton.state == NSOnState {
                        per = h / visibleRect.size.height
                        r = visibleRect.size.width * per >= kSBMaxImageSizeWidth
                    } else {
                        per = h / visibleRect.size.height
                        r = image!.size.width * per >= kSBMaxImageSizeWidth
                    }
                }
            }
        }
        return r
    }
    
    func setImage(image: NSImage?) -> Bool {
        if let image = image {
            if image.size == NSZeroSize || image.size.width == 0 || image.size.height == 0 {
                return false
            }
            
            var r = NSZeroRect
            var enableVisibility = false
            self.image = image
            if onlyVisibleButton.state == NSOnState {
                r.size = visibleRect.size
            } else {
                r.size = image.size
            }
            enableVisibility = !(visibleRect.size == image.size || visibleRect.size.width == 0 || visibleRect.size.height == 0)
            onlyVisibleButton.enabled = enableVisibility
            if !enableVisibility && onlyVisibleButton.state == NSOnState {
                onlyVisibleButton.state = NSOffState
                r.size = image.size
            } else {
                onlyVisibleButton.state = NSUserDefaults.standardUserDefaults().boolForKey(kSBSnapshotOnlyVisiblePortion) ? NSOnState : NSOffState
            }
            // Set image to image view
            widthField.integerValue = Int(r.size.width)
            heightField.integerValue = Int(r.size.height)
            scaleField.integerValue = 100
            update(forField: nil)
            successScale = 1.0
            
            return true
        }
        return false
    }
    
    func destructUpdateTimer() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    func showProgress() {
        //progressBackgroundView.frame = scrollView.frame
        //progressIndicator.startAnimation(nil)
        //addSubview(progressBackgroundView)
    }
    
    func hideProgress() {
        //progressIndicator.stopAnimation(nil)
        //progressBackgroundView.removeFromSuperview()
    }
    
    @objc(updateWithTimer:)
    func update(#timer: NSTimer) {
        let field: AnyObject? = timer.userInfo
        destructUpdateTimer()
        update(forField: field)
    }
    
    func update(forField field: AnyObject?) {
        // Show Progress
        showProgress()
        // Perform update
        let modes = [NSDefaultRunLoopMode, NSEventTrackingRunLoopMode, NSModalPanelRunLoopMode]
        SBPerformWithModes(self, "updatingForField:", field, modes)
    }
    
    @objc(updatingForField:)
    func updating(forField field: AnyObject) {
        updateFields(forField: field)
        updatePreviewImage()
        // Hide Progress
        hideProgress()
    }
    
    func updatePreviewImage() {
        let width = CGFloat(widthField.integerValue)
        let height = CGFloat(heightField.integerValue)
        data = imageData(filetype, size: NSMakeSize(width, height))
        if let compressedImage = data !! {NSImage(data: $0)} {
            // Set image to image view
            imageView.image = compressedImage
            // Get length of image data
            // Set length as string
            let fileSizeString = NSString.bytesStringForLength(CLongLong(data!.length))
            filesizeField.stringValue = fileSizeString
            doneButton.enabled = true
        } else {
            doneButton.enabled = false
        }
    }
    
    func updateFields(forField field: AnyObject) {
        let locked = lockButton.state == NSOffState
        var newSize = NSZeroSize
        var r = imageView.frame
        var value: CGFloat = 0.0
        var per: CGFloat = 1.0
        if onlyVisibleButton.state == NSOnState {
            newSize = visibleRect.size
        } else {
            newSize = image!.size
        }
        if field === widthField {
            value = SBConstrain(CGFloat(widthField.integerValue), min: 1)
            if locked {
                if onlyVisibleButton.state == NSOnState {
                    per = value / visibleRect.size.width
                    newSize.height = visibleRect.size.height * per
                } else {
                    per = value / image!.size.width
                    newSize.height = image!.size.height * per
                }
                SBConstrain(&newSize.height, min: 1)
                SBConstrain(&per, min: 0.01)
                heightField.integerValue = Int(newSize.height)
                scaleField.integerValue = Int(per * 100)
            }
            newSize.width = value
            widthField.integerValue = Int(newSize.width)
        } else if field === heightField {
            value = CGFloat(heightField.integerValue)
            if value < 1 {
                heightField.integerValue = 1
                value = 1
            }
            if locked {
                if onlyVisibleButton.state == NSOnState {
                    per = value / visibleRect.size.height
                    newSize.width = visibleRect.size.width * per
                } else {
                    per = value / image!.size.height
                    newSize.width = image!.size.width * per
                }
                SBConstrain(&newSize.width, min: 1)
                SBConstrain(&per, min: 0.01)
                widthField.integerValue = Int(newSize.width)
                scaleField.integerValue = Int(per * 100)
            }
            newSize.height = value
            heightField.integerValue = Int(newSize.height)
        } else if field === scaleField {
            if locked {
                per = CGFloat(scaleField.integerValue) / 100
                if per < 0.01 {
                    scaleField.integerValue = 1
                    per = 0.01
                }
                if onlyVisibleButton.state == NSOnState {
                    newSize.width = visibleRect.size.width * per
                    newSize.height = visibleRect.size.height * per
                } else {
                    newSize.width = image!.size.width * per
                    newSize.height = image!.size.height * per
                }
                widthField.integerValue = Int(newSize.width)
                heightField.integerValue = Int(newSize.height)
                scaleField.integerValue = Int(per * 100)
                successScale = per
            }
        } else {
            if locked {
                per = CGFloat(scaleField.integerValue) / 100
            }
            if per < 0.01 {
                scaleField.integerValue = 1
                per = 0.01
            }
            if onlyVisibleButton.state == NSOnState {
                newSize.width = visibleRect.size.width * per
                newSize.height = visibleRect.size.height * per
            } else {
                newSize.width = image!.size.width * per
                newSize.height = image!.size.height * per
            }
            widthField.integerValue = Int(newSize.width)
            heightField.integerValue = Int(newSize.height)
            scaleField.integerValue = Int(per * 100)
        }
        updatePreviewImage()
        r.size = newSize
        SBConstrain(&r.size.width, min: scrollView.frame.size.width)
        SBConstrain(&r.size.height, min: scrollView.frame.size.height)
        imageView.frame = r
        imageView.display()
        imageView.scrollPoint(NSMakePoint(0, r.size.height))
    }
    
    // MARK: Actions
    
    func checkOnlyVisible(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setBool(onlyVisibleButton.state == NSOnState, forKey: kSBSnapshotOnlyVisiblePortion)
        update(forField: nil)
    }
    
    func update(sender: AnyObject) {
        if let target = target as? SBDocument {
            visibleRect = target.visibleRectOfSelectedWebDocumentView
            target.selectedWebViewImage !! { self.image = $0 }
        }
    }
    
    func lock(sender: AnyObject) {
        let locked = lockButton.state == NSOffState
        if locked {
            update(forField: widthField)
        }
        scaleField.enabled = locked
    }
    
    func selectFiletype(sender: NSMenuItem) {
        let tag = sender.tag
        if Int(filetype.rawValue) != tag {
            filetype = NSBitmapImageFileType(rawValue: UInt(tag))!
            for item in filetypePopup.menu.itemArray as [NSMenuItem] {
                item.state = (Int(filetype.rawValue) == item.tag) ? NSOnState : NSOffState
            }
            // Update image
            update(forField: nil)
            // Save to defaults
            NSUserDefaults.standardUserDefaults().setInteger(Int(filetype.rawValue), forKey: kSBSnapshotFileType)
        }
        switch filetype {
            case NSBitmapImageFileType.NSTIFFFileType:
                optionTabView.selectTabViewItemWithIdentifier(NSString(format: "%d", NSBitmapImageFileType.NSTIFFFileType.rawValue))
                optionTabView.hidden = false
            case NSBitmapImageFileType.NSJPEGFileType:
                optionTabView.selectTabViewItemWithIdentifier(NSString(format: "%d", NSBitmapImageFileType.NSJPEGFileType.rawValue))
                optionTabView.hidden = false
            default:
                optionTabView.hidden = true
        }
    }
    
    func selectTiffOption(sender: NSMenuItem) {
        let tag = sender.tag
        if Int(tiffCompression.rawValue) != tag {
            tiffCompression = NSTIFFCompression(rawValue: UInt(tag))!
            for item in tiffOptionPopup.menu.itemArray as [NSMenuItem] {
                item.state = (Int(tiffCompression.rawValue) == item.tag) ? NSOnState : NSOffState
            }
            // Update image
            update(forField: nil)
            // Save to defaults
            NSUserDefaults.standardUserDefaults().setInteger(Int(tiffCompression.rawValue), forKey: kSBSnapshotTIFFCompression)
        }
    }
    
    func slideJpgOption(sender: AnyObject) {
        let value = jpgOptionSlider.doubleValue
        jpgFactor = CGFloat(value)
        jpgOptionField.stringValue = NSString(format: "%.1f", value)
        // Save to defaults
        NSUserDefaults.standardUserDefaults().setDouble(value, forKey: kSBSnapshotJPGFactor)
        // Update image
        destructUpdateTimer()
        updateTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "updateWithTimer:", userInfo: nil, repeats: false)
    }
    
    func save(sender: AnyObject) {
        if data != nil {
            let panel = SBSavePanel()
            panel.canCreateDirectories = true
            panel.nameFieldStringValue = filename
            if panel.runModal() == NSFileHandlingPanelOKButton {
                if data!.writeToURL(panel.URL, atomically: true) {
                    done()
                }
            }
        }
    }
    
    func destruct() {
        destructUpdateTimer()
    }
    
    // MARK: -
    
    func imageData(inFiletype: NSBitmapImageFileType, size: NSSize) -> NSData? {
        var aData: NSData?
        var bitmapImageRep: NSBitmapImageRep!
        var fromRect = NSZeroRect
        
        if image == nil {
            return nil
        }
        
        // Resize
        let anImage = NSImage(size: size)
        if onlyVisibleButton.state == NSOnState {
            fromRect = visibleRect
            fromRect.origin.y = image!.size.height - NSMaxY(visibleRect)
        } else {
            fromRect.size = image!.size
        }
        anImage.lockFocus()
        image!.drawInRect(NSMakeRect(0, 0, size.width, size.height), fromRect: fromRect, operation: .CompositeSourceOver, fraction: 1.0)
        anImage.unlockFocus()
        
        // Change filetype
        aData = anImage.TIFFRepresentation
        switch inFiletype {
            case NSBitmapImageFileType.NSTIFFFileType:
                bitmapImageRep = NSBitmapImageRep(data: aData)
                aData = bitmapImageRep.TIFFRepresentationUsingCompression(tiffCompression, factor: 1.0)
            case NSBitmapImageFileType.NSGIFFileType:
                bitmapImageRep = NSBitmapImageRep(data: aData)
                let properties = [NSImageDitherTransparency: true as NSNumber]
                aData = bitmapImageRep.representationUsingType(NSBitmapImageFileType.NSGIFFileType, properties: properties)
            case NSBitmapImageFileType.NSJPEGFileType:
                bitmapImageRep = NSBitmapImageRep(data: aData)
                let properties = [NSImageCompressionFactor: jpgFactor as NSNumber]
                aData = bitmapImageRep.representationUsingType(NSBitmapImageFileType.NSJPEGFileType, properties: properties)
            case NSBitmapImageFileType.NSPNGFileType:
                bitmapImageRep = NSBitmapImageRep(data: aData)
                aData = bitmapImageRep.representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: nil)
            default:
                break
        }
        if aData != nil {
            successSize = size
        }
        return aData
    }
}