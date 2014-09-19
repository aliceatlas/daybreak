/*
SBURLField.swift

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

let SBURLFieldRowCount = 3
let SBURLFieldMaxRowCount = 20
let SBURLFieldRowHeight: CGFloat = 20
let SBURLFieldRoundedCurve: CGFloat = SBFieldRoundedCurve
let SBURLFieldSheetPadding: CGFloat = 10
let kSBURLFieldSectionHeight: CGFloat = 18.0

@objc protocol SBURLFieldDelegate {
    optional func urlFieldDidSelectBackward(SBURLField)
    optional func urlFieldDidSelectForward(SBURLField)
    optional func urlFieldShouldOpenURL(SBURLField)
    optional func urlFieldShouldOpenURLInNewTab(SBURLField)
    optional func urlFieldShouldDownloadURL(SBURLField)
    optional func urlFieldTextDidChange(SBURLField)
    optional func urlFieldWillResignFirstResponder(SBURLField)
}

@objc protocol SBURLFieldDatasource {
}

class SBURLField: SBView, NSTextFieldDelegate, NSTableViewDelegate, NSTableViewDataSource, SBAnswersIsFirstResponder {
    private lazy var backwardButton: SBButton = {
        let backwardRect = self.backwardRect
        let backwardButton = SBButton(frame: backwardRect)
        backwardButton.image = NSImage(CGImage: SBBackwardIconImage(backwardRect.size, true, false))
        backwardButton.disableImage = NSImage(CGImage: SBBackwardIconImage(backwardRect.size, false, false))
        backwardButton.backImage = NSImage(CGImage: SBBackwardIconImage(backwardRect.size, true, true))
        backwardButton.backDisableImage = NSImage(CGImage: SBBackwardIconImage(backwardRect.size, false, true))
        backwardButton.target = self
        backwardButton.action = "executeDidSelectBackward"
        return backwardButton
    }()
    
    private lazy var forwardButton: SBButton = {
        let forwardRect = self.forwardRect
        let forwardButton = SBButton(frame: forwardRect)
        forwardButton.image = NSImage(CGImage: SBForwardIconImage(forwardRect.size, true, false))
        forwardButton.disableImage = NSImage(CGImage: SBForwardIconImage(forwardRect.size, false, false))
        forwardButton.backImage = NSImage(CGImage: SBForwardIconImage(forwardRect.size, true, true))
        forwardButton.backDisableImage = NSImage(CGImage: SBForwardIconImage(forwardRect.size, false, true))
        forwardButton.target = self
        forwardButton.action = "executeDidSelectForward"
        return forwardButton
    }()
    
    private lazy var imageView: SBURLImageView = {
        let imageView = SBURLImageView(frame: self.imageRect)
        imageView.imageFrameStyle = .None
        return imageView
    }()
    
    private lazy var field: SBURLTextField = {
        let field = SBURLTextField(frame: self.fieldRect)
        field.target = self
        field.action = "executeShouldOpenURL"
        field.commandAction = "executeShouldOpenURLInNewTab"
        field.optionAction = "executeShouldDownloadURL"
        field.bezeled = false
        field.drawsBackground = false
        field.bordered = false
        field.focusRingType = .None
        field.delegate = self
        field.font = NSFont.systemFontOfSize(13.0)
        field.autoresizingMask = .ViewWidthSizable | .ViewHeightSizable
        (field.cell() as NSTextFieldCell).wraps = false
        (field.cell() as NSTextFieldCell).scrollable = true
        field.setRefusesFirstResponder(false)
        return field
    }()
    
    private lazy var goButton: SBButton = {
        let goRect = self.goRect
        let goButton = SBButton(frame: goRect)
        goButton.autoresizingMask = .ViewMinXMargin
        goButton.image = NSImage(CGImage: SBGoIconImage(goRect.size, true, false))
        goButton.disableImage = NSImage(CGImage: SBGoIconImage(goRect.size, false, false))
        goButton.backImage = NSImage(CGImage: SBGoIconImage(goRect.size, true, true))
        goButton.backDisableImage = NSImage(CGImage: SBGoIconImage(goRect.size, false, true))
        goButton.target = self
        goButton.action = "go"
        goButton.enabled = false
        return goButton
    }()
    
    private lazy var sheet: SBURLFieldSheet = {
        let sheet = SBURLFieldSheet(contentRect: self.appearedSheetRect, styleMask:(NSBorderlessWindowMask | NSNonactivatingPanelMask), backing: .Buffered, defer: true)
        sheet.alphaValue = self.window!.alphaValue
        sheet.opaque = false
        sheet.backgroundColor = NSColor.clearColor()
        sheet.hasShadow = false
        sheet.contentView = self.contentView
        return sheet
    }()
    
    private lazy var contentView: SBURLFieldContentView = {
        var contentRect = NSZeroRect
        contentRect.size = self.appearedSheetRect.size
        return SBURLFieldContentView(frame: contentRect)
    }()
    
    var dataSource: SBURLFieldDatasource? {
        didSet {
            contentView.dataSource = dataSource !! self
        }
    }
    
    var delegate: SBURLFieldDelegate? {
        didSet {
            contentView.delegate = delegate !! self
        }
    }
    
    var image: NSImage? {
        get { return imageView.image }
        set(image) { imageView.image = image }
    }
    
    var stringValue: String! {
        get { return field.stringValue }
        set(inStringValue) {
            let stringValue = inStringValue ?? ""
            if stringValue != self.stringValue {
                field.stringValue = stringValue
                // Update go button
                var hasScheme = false
                goButton.enabled = !stringValue.isEmpty
                goButton.title = goButton.enabled &? (stringValue.isURLString(&hasScheme) ? NSLocalizedString("Go", comment: "") : NSLocalizedString("Search", comment: ""))
            }
        }
    }
    
    var URLString: String {
        get { return stringValue }
        set(URLString) {
            let editor = field.currentEditor() ?? window!.fieldEditor(true, forObject: field)!
            var selectedRange = editor.selectedRange
            var range = NSMakeRange(NSNotFound, 0)
            let string = stringValue
            let currentScheme = schemeForURLString(string)
            let scheme = schemeForURLString(URLString)
            if (scheme ?? "").hasPrefix(string) {
                let headRange = (URLString as NSString).rangeOfString(string)
                range.location = headRange.location + headRange.length
                range.length = URLString.utf16Count - range.location
            } else {
                let currentSchemeLength = currentScheme?.utf16Count ?? 0
                let schemeLength = scheme?.utf16Count ?? 0
                
                selectedRange.location -= currentSchemeLength
                selectedRange.length -= currentSchemeLength
                range.location = selectedRange.location + schemeLength
                range.length = URLString.utf16Count - range.location
            }
            self.stringValue = URLString
            editor.selectedRange = range
        }
    }
    
    var gsItems: [NSDictionary] = []
    var bmItems: [NSDictionary] = []
    var hItems: [NSDictionary] = []
    var items: [NSDictionary] = [] {
        didSet {
            //!!! was setURLItems in original and this appears to not have been called anywhere
            reloadData()
            if items.isEmpty {
                disappearSheet()
            } else {
                adjustSheet()
                contentView.deselectRow()
            }
        }
    }
    
    var enabledBackward: Bool {
        get { return backwardButton.enabled }
        set(enabledBackward) { backwardButton.enabled = enabledBackward }
    }
    
    var enabledForward: Bool {
        get { return forwardButton.enabled }
        set(enabledForward) { forwardButton.enabled = enabledForward }
    }
    
    var enabledGo: Bool {
        get { return goButton.enabled }
        set(enabledGo) { goButton.enabled = enabledGo }
    }
    
    var hiddenGo: Bool {
        get { return goButton.hidden }
        set(hiddenGo) {
            goButton.hidden = hidden
            field.frame = fieldRect
        }
    }
    
    private var _isOpenSheet = false
    var isOpenSheet: Bool { return _isOpenSheet }
    
    var editing: Bool { return true }
    
    var isFirstResponder: Bool {
        return window!.firstResponder === field.currentEditor()
    }
    
    var placeholderString: String {
        get { return (field.cell() as NSTextFieldCell).placeholderString }
        set(placeholderString) { (field.cell() as NSTextFieldCell).placeholderString = placeholderString }
    }
    
    var textColor: NSColor {
        get { return field.textColor }
        set(textColor) { field.textColor = textColor }
    }
    
    override var nextKeyView: NSView? {
        get { return field.nextKeyView }
        set(nextKeyView) { field.nextKeyView = nextKeyView }
    }
    
    override init(frame: NSRect) {
        var r = frame
        SBConstrain(&r.size.width, min: minimumSize.width)
        SBConstrain(&r.size.height, min: minimumSize.height)
        super.init(frame: r)
        addSubview(backwardButton)
        addSubview(forwardButton)
        addSubview(imageView)
        addSubview(field)
        addSubview(goButton)
        hiddenGo = true
    }

    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    let minimumSize = NSMakeSize(100.0, 22.0)
    var font: NSFont { return field.font }
    
    var sheetHeight: CGFloat {
        let rowCount = SBConstrain(items.count, max: SBURLFieldMaxRowCount)
        return SBURLFieldRowHeight * CGFloat(rowCount) + SBURLFieldSheetPadding * 2
    }
    
    var appearedSheetRect: NSRect {
        var r = NSZeroRect
        
        r.size.width = bounds.size.width - buttonWidth * 2 - goButtonWidth
        r.size.height = sheetHeight
        let position = (window?.toolbar as? SBToolbar)?.itemRectInScreenForIdentifier(kSBToolbarURLFieldItemIdentifier).origin ?? NSZeroPoint
        r.origin.x = frame.origin.x + position.x
        r.origin.y = frame.origin.y + position.y
        r.origin.x = r.origin.x + buttonWidth * 2
        r.origin.y = r.origin.y - r.size.height + 1
        return r
    }
        
    // MARK: Rects
    
    let buttonWidth: CGFloat = 27.0
    let goButtonWidth: CGFloat = 75.0
    let imageWidth: CGFloat = 20.0
    
    var backwardRect: NSRect {
        var r = NSZeroRect
        r.size.width = buttonWidth
        r.size.height = bounds.size.height
        r.origin = NSZeroPoint
        return r
    }
    
    var forwardRect: NSRect {
        var r = NSZeroRect
        r.size.width = buttonWidth
        r.size.height = bounds.size.height
        r.origin.x = buttonWidth
        r.origin.y = 0.0
        return r
    }
    
    var imageRect: NSRect {
        var r = NSZeroRect
        r.size.width = 16.0
        r.size.height = r.size.width
        r.origin.x = buttonWidth * 2 + (imageWidth - r.size.width) / 2
        r.origin.y = (bounds.size.height - r.size.height) / 2
        return r
    }
    
    var fieldRect: NSRect {
        var r = NSZeroRect
        r.size.width = bounds.size.width - imageWidth - 4.0 - buttonWidth * 2 - (!goButton.hidden ? goButtonWidth : 0)
        r.size.height = bounds.size.height - 2
        r.origin.x = buttonWidth * 2 + imageWidth
        r.origin.y = -2.0
        return r
    }
    
    var goRect: NSRect {
        var r = NSZeroRect
        r.size.width = goButtonWidth
        r.size.height = bounds.size.height
        r.origin.x = bounds.size.width - goButtonWidth
        r.origin.y = 0.0
        return r
    }
    
    // MARK: Construction
    
    func tableViewDidSingleAction(tableView: NSTableView) {
        let rowIndex = tableView.selectedRow
        if rowIndex > -1 && canSelectIndex(rowIndex) {
            contentView.pushSelectedItem()
            disappearSheet()
            SBPerform(field.target, field.action, field)
        }
    }
    
    func canSelectIndex(index: Int) -> Bool {
        var can = false
        var matchIndex = false
        let gsEmpty = gsItems.isEmpty
        let bmEmpty = bmItems.isEmpty
        let hEmpty = hItems.isEmpty
        if gsEmpty && bmEmpty && hEmpty {
        } else if ((!gsEmpty && bmEmpty && hEmpty) ||
                   (gsEmpty && !bmEmpty && hEmpty) ||
                   (gsEmpty && bmEmpty && !hEmpty)) {
            matchIndex = index == 0
        } else if !gsEmpty && !bmEmpty && hEmpty {
            matchIndex = (index == 0) || (index == gsItems.count)
        } else if gsEmpty && !bmEmpty && !hEmpty {
            matchIndex = (index == 0) || (index == bmItems.count)
        } else if !gsEmpty && bmEmpty && !hEmpty {
            matchIndex = (index == 0) || (index == gsItems.count)
        } else if !gsEmpty && !bmEmpty && !hEmpty {
            matchIndex = (index == 0) || (index == gsItems.count) || (index == gsItems.count + bmItems.count)
        }
        return !matchIndex
    }
    
    // MARK: Delegate
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        let rowIndex = (notification.object as NSTableView).selectedRow
        if rowIndex > -1 && canSelectIndex(rowIndex) {
            contentView.pushSelectedItem()
        }
    }
    
    func tableViewSelectionIsChanging(notification: NSNotification) {
        contentView.needsDisplay = true // Keep drawing background
    }
    
    func tableView(tableView: NSTableView, shouldSelectRow rowIndex: Int) -> Bool {
        return canSelectIndex(rowIndex)
    }
    
    func tableView(tableView: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: NSIndexSet) -> NSIndexSet? {
        let index = proposedSelectionIndexes.firstIndex // because single selection
        if canSelectIndex(index) {
            return proposedSelectionIndexes
        }
        return nil
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return kSBURLFieldSectionHeight
    }
    
    override func controlTextDidBeginEditing(notification: NSNotification) {
        // Show go button
        hiddenGo = false
        updateGoTitle(NSApplication.sharedApplication().currentEvent)
    }
    
    override func controlTextDidChange(notification: NSNotification) {
        let currentEvent = NSApplication.sharedApplication().currentEvent
        let characters: NSString = currentEvent.characters
        let character = Int(characters.characterAtIndex(0))
        let stringValue = field.stringValue
        var hasScheme = false
        
        // Update go button
        hiddenGo = false
        goButton.enabled = !stringValue.isEmpty
        goButton.title = goButton.enabled &? (stringValue.isURLString(&hasScheme) ? NSLocalizedString("Go", comment: "") : NSLocalizedString("Search", comment: ""))
        
        if (character == NSDeleteCharacter || 
            character == NSBackspaceCharacter || 
            character == NSLeftArrowFunctionKey || 
            character == NSRightArrowFunctionKey) {
            // Disappear sheet
            if isOpenSheet {
                disappearSheet()
            }
        } else {
            // Get items from Bookmarks and History items
            executeTextDidChange()
            appearSheetIfNeeded(false)
        }
    }
    
    override func controlTextDidEndEditing(notification: NSNotification) {
        // Hide go button
        hiddenGo = true
        
        // Disappear sheet
        if isOpenSheet {
            disappearSheet()
        }
        
        let currentEvent = window!.currentEvent
        if currentEvent.type == .KeyDown {
            let characters: NSString = currentEvent.characters
            let character = Int(characters.characterAtIndex(0))
            if character == NSTabCharacter { // Tab
                // If the user push Tab key, make first responder to next responder
                window!.makeFirstResponder(field.nextKeyView)
            }
        }
    }
    
    func control(control: NSControl, textView: NSTextView, doCommandBySelector commandSelector: Selector) -> Bool {
        if control === field {
            if commandSelector == "insertNewlineIgnoringFieldEditor:" {
                // Ignore new line action
                let center = NSNotificationCenter.defaultCenter()
                center.postNotificationName(NSControlTextDidEndEditingNotification, object: self)
                field.sendAction(field.optionAction, to: field.target)
                return true
            }
        }
        return false
    }
    
    // MARK: DataSource
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return items.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn, row rowIndex: Int) -> AnyObject? {
        if let item = (rowIndex < items.count) &? items[rowIndex] {
            if tableColumn.identifier == kSBURL {
                let type = SBURLFieldItemType(rawValue: (item[kSBType] as? NSNumber) ?? -1)
                if type == nil {
                    return nil
                }
                let title = item[kSBTitle] as? NSString as? String
                switch type! {
                    case .None:
                        return title
                    case .GoogleSuggest:
                        return title
                    case .Bookmark, .History:
                        return title ?? (item[kSBURL] as? NSString)
                }
            }
        }
        return nil
    }
    
    func tableView(tableView: NSTableView, willDisplayCell cell: SBURLFieldDataCell, forTableColumn tableColumn: NSTableColumn, row rowIndex: Int) {
        if tableColumn.identifier != kSBURL { return }
        if let item = (rowIndex < items.count) &? items[rowIndex] {
            let title = item[kSBTitle] as? NSString as? String
            var string: String?
            var image: NSImage?
            var separator = false
            var sectionHeader = false
            var drawsImage = true
            if let type = SBURLFieldItemType(rawValue: (item[kSBType] as? NSNumber) ?? -1) {
                switch type {
                    case .None:
                        if let data = item[kSBImage] as? NSData {
                            image = NSImage(data: data)
                            image!.size = NSMakeSize(16.0, 16.0)
                        }
                        string = title
                        separator = rowIndex > 0
                        sectionHeader = true
                    case .GoogleSuggest:
                        string = title
                        drawsImage = false
                    case .Bookmark, .History:
                        if let data = item[kSBImage] as? NSData {
                            image = NSImage(data: data)
                            image!.size = NSMakeSize(16.0, 16.0)
                        }
                        string = title ?? (item[kSBURL] as? NSString)
                }
            }
            cell.separator = separator
            cell.sectionHeader = sectionHeader
            cell.drawsImage = drawsImage
            cell.image = image
            string !! { cell.objectValue = $0 as NSString }
        }
    }
    
    // MARK: Action
    
    func endEditing() {
        disappearSheet()
        hiddenGo = true
        (field.cell() as NSTextFieldCell).endEditing(window!.fieldEditor(false, forObject: field))
    }
    
    func adjustSheet() {
        let sheetRect = appearedSheetRect
        sheet.setFrame(sheetRect, display: true)
        sheet.alphaValue = window!.alphaValue
        contentView.adjustTable()
    }
    
    func appearSheetIfNeeded(closable: Bool) {
        if !items.isEmpty {
            if !isOpenSheet {
                appearSheet()
            }
            reloadData()
            adjustSheet()
            contentView.deselectRow()
        } else if closable {
            disappearSheet()
        }
    }
    
    func appearSheet() {
        if !sheet.visible {
            adjustSheet()
            window!.addChildWindow(sheet, ordered: .Above)
            contentView.deselectRow()
            sheet.orderFront(nil)
            _isOpenSheet = true
            needsDisplay = true
            contentView.needsDisplay = true
        }
    }
    
    func disappearSheet() {
        if sheet.visible {
            window!.removeChildWindow(sheet)
            needsDisplay = true
            sheet.orderOut(nil)
            _isOpenSheet = false
            needsDisplay = true
        }
    }
    
    func selectRowAbove() {
        var rowIndex = contentView.selectedRowIndex
        do {
            rowIndex--
        } while !canSelectIndex(rowIndex)
        
        if rowIndex < 1 {
            rowIndex = items.count - 1
        }
        contentView.selectRow(rowIndex)
    }
    
    func selectRowBelow() {
        var rowIndex = contentView.selectedRowIndex
        do {
            rowIndex++
        } while !canSelectIndex(rowIndex)
        if rowIndex >= items.count {
            rowIndex = 1
        }
        contentView.selectRow(rowIndex)
    }
    
    func reloadData() {
        adjustSheet()
        contentView.reloadData()
    }
    
    func selectText(sender: AnyObject?) {
        field.selectText(sender)
    }
    
    func updateGoTitle(event: NSEvent?) {
        let modifierFlags: NSEventModifierFlags = event?.modifierFlags ?? nil
        if modifierFlags & .CommandKeyMask != nil {
            goButton.title = NSLocalizedString("Open", comment: "")
        } else if modifierFlags & .AlternateKeyMask != nil {
            goButton.title = NSLocalizedString("Download", comment: "")
        } else {
            var hasScheme = false
            var title: String?
            if !stringValue.isEmpty {
                title = stringValue.isURLString(&hasScheme) ? NSLocalizedString("Go", comment: "") : NSLocalizedString("Search", comment: "")
            }
            goButton.title = title
        }
    }
    
    func go() {
        var f: (() -> Void)?
        let theEvent = NSApplication.sharedApplication().currentEvent
        let modifierFlags: NSEventModifierFlags = theEvent?.modifierFlags ?? nil
        if modifierFlags & .CommandKeyMask != nil {
            f = executeShouldOpenURLInNewTab
        } else if modifierFlags & .AlternateKeyMask != nil {
            f = executeShouldDownloadURL
        } else {
            f = executeShouldOpenURL
        }
        f?()
    }
    
    // MARK: Exec
    
    func executeDidSelectBackward() {
        delegate?.urlFieldDidSelectBackward?(self)
    }
    
    func executeDidSelectForward() {
        delegate?.urlFieldDidSelectForward?(self)
    }
    
    func executeShouldOpenURL() {
        delegate?.urlFieldShouldOpenURL?(self)
    }
    
    func executeShouldOpenURLInNewTab() {
        delegate?.urlFieldShouldOpenURLInNewTab?(self)
    }
    
    func executeShouldDownloadURL() {
        delegate?.urlFieldShouldDownloadURL?(self)
    }
    
    func executeTextDidChange() {
        delegate?.urlFieldTextDidChange?(self)
    }
    
    func executeWillResignFirstResponder() {
        delegate?.urlFieldWillResignFirstResponder?(self)
    }
    
    // MARK: Drawing
    
    override func drawRect(rect: NSRect) {
        var r = bounds
        var path = SBRoundedPathS(r, SBURLFieldRoundedCurve, 0, true, true)
        NSColor.whiteColor().set()
        path.fill()
        
        r.origin.x += 0.5
        r.origin.y += 3.0
        if r.size.width >= 1.0 {
            r.size.width -= 1.0
        }
        if r.size.height >= 4.5 {
            r.size.height -= 4.5
        }
        path = SBRoundedPathS(r, SBURLFieldRoundedCurve, 0, true, false)
        path.lineWidth = 1.0
        NSColor(calibratedWhite: 0.75, alpha: 1.0).set()
        path.stroke()
        
        r = bounds
        r.origin.x += 0.5
        r.origin.y += 0.5
        r.size.width -= 1.0
        r.size.height -= 1.0
        path = SBRoundedPathS(r, SBURLFieldRoundedCurve, 0, true, true)
        path.lineWidth = 0.5
        NSColor.blackColor().set()
        path.stroke()
    }
    
    override func resizeWithOldSuperviewSize(oldBoundsSize: NSSize) {
        if isOpenSheet {
            disappearSheet()
        }
        super.resizeWithOldSuperviewSize(oldBoundsSize)
    }
    
    override func resizeSubviewsWithOldSize(oldBoundsSize: NSSize) {
        if isOpenSheet {
            disappearSheet()
        }
        super.resizeSubviewsWithOldSize(oldBoundsSize)
    }
}

class SBURLImageView: NSImageView, NSDraggingSource {
    var field: SBURLField { return superview as SBURLField }
    var URL: NSURL { return NSURL(string: field.stringValue)! }
    
    var selectedWebViewImageForBookmark: NSImage? {
        return (field.delegate as? SBDocument)?.selectedWebViewImageForBookmark
    }
    
    var selectedWebViewImageDataForBookmark: NSData? {
        return (field.delegate as? SBDocument)?.selectedWebViewImageDataForBookmark
    }
    
    var dragImage: NSImage {
        let urlString: NSString = URL.absoluteString!
        let margin: CGFloat = 5.0
        let attribute: [NSObject: AnyObject] = [NSFontAttributeName: field.font]
        let textSize = urlString.sizeWithAttributes(attribute)
        var size = NSZeroSize
        size.height = bounds.size.height
        size.width = bounds.size.width + textSize.width + margin
        var imageRect = NSZeroRect
        imageRect.size = bounds.size
        imageRect.origin.x = (size.height - imageRect.size.width) / 2
        imageRect.origin.y = (size.height - imageRect.size.height) / 2
        var textRect = NSZeroRect
        textRect.size.height = size.height
        textRect.size.width = textSize.width
        textRect.origin.x = margin + NSMaxX(imageRect)
        
        let image = NSImage(size: size)
        image.lockFocus()
        self.image.drawInRect(imageRect, fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1.0)
        urlString.drawInRect(textRect, withAttributes: attribute)
        image.unlockFocus()
        
        return image
    }
    
    override func mouseDown(event: NSEvent) {
        //!!!@autoreleasepool {
        let point = convertPoint(event.locationInWindow, fromView: nil)
        
        while true {
            let mask: NSEventMask = .LeftMouseDraggedMask | .LeftMouseUpMask
            let newEvent = window!.nextEventMatchingMask(Int(mask.rawValue))
            let newPoint = convertPoint(newEvent.locationInWindow, fromView: nil)
            var isDragging = false
            if NSPointInRect(newPoint, bounds) {
                if newEvent.type == .LeftMouseUp {
                    mouseUpActionWithEvent(event)
                    break
                } else if newEvent.type == .LeftMouseDragged {
                    isDragging = true
                }
            } else {
                if newEvent.type == .LeftMouseDragged {
                    isDragging = true
                }
            }
            
            if isDragging {
                let delta = NSMakePoint(point.x - newPoint.x, point.y - newPoint.y)
                if delta.x >= 5 || delta.x <= -5 || delta.y >= 5 || delta.y <= -5 {
                    mouseDraggedActionWithEvent(event)
                    break
                }
            }
        }
        //}
    }
    
    func mouseDraggedActionWithEvent(event: NSEvent) {
        var item = NSDraggingItem(pasteboardWriter: URL)
        item.setDraggingFrame(bounds, contents: dragImage)
        
        let session = beginDraggingSessionWithItems([item], event: event, source: self)
        session.animatesToStartingPositionsOnCancelOrFail = true
        session.draggingFormation = .None
        //
        window!.title !! { session.draggingPasteboard.setString($0, forType: NSPasteboardTypeString) }
        selectedWebViewImageForBookmark !! { session.draggingPasteboard.setData($0.TIFFRepresentation, forType: NSPasteboardTypeTIFF) }
    }
    
    func draggingSession(session: NSDraggingSession, sourceOperationMaskForDraggingContext context: NSDraggingContext) -> NSDragOperation {
        return .Copy
    }
    
    /*func pasteboard(sender: NSPasteboard, item: NSPasteboardItem, provideDataForType type: String) {
        if type == NSPasteboardTypeTIFF {
            selectedWebViewImageForBookmark !! { sender.setData($0.TIFFRepresentation, forType: NSPasteboardTypeTIFF) }
        } else if type == NSPasteboardTypeString {
            sender.setString(window!.title!, forType: NSPasteboardTypeString)
        }
    }*/
    
    func mouseUpActionWithEvent(event: NSEvent) {
        field.selectText(self)
    }
}


class SBURLTextField: NSTextField {
    var commandAction: Selector = nil
    var optionAction: Selector = nil
    var field: SBURLField { return superview as SBURLField }
    
    // MARK: Responder
    
    override var acceptsFirstResponder: Bool { return true }
    
    override func becomeFirstResponder() -> Bool {
        selectText(nil)
        return true
    }
    
    override func resignFirstResponder() -> Bool {
        field.disappearSheet()
        field.executeWillResignFirstResponder()
        return true
    }
    
    override func selectText(sender: AnyObject?) {
        super.selectText(nil)
        // self through NSControlTextDidBeginEditingNotification
        NSNotificationCenter.defaultCenter().postNotificationName(NSControlTextDidBeginEditingNotification, object: self)
    }
    
    override func flagsChanged(event: NSEvent) {
        field.updateGoTitle(event)
    }
    
    // MARK: Event
    
    override func performKeyEquivalent(event: NSEvent) -> Bool {
        let center = NSNotificationCenter.defaultCenter()
        let character = Int((event.characters as NSString).characterAtIndex(0))
        if character == NSCarriageReturnCharacter || character == NSEnterCharacter {
            let modifierFlags = event.modifierFlags
            if modifierFlags & .CommandKeyMask != nil {
                // Command + Return
                center.postNotificationName(NSControlTextDidEndEditingNotification, object: self)
                sendAction(commandAction, to: target)
                return true
            }
        } else {
            if field.isOpenSheet {
                if event.type == .KeyDown {
                    if character == NSUpArrowFunctionKey {
                        field.selectRowAbove()
                        return true
                    } else if character == NSDownArrowFunctionKey {
                        field.selectRowBelow()
                        return true
                    } else if character == NSLeftArrowFunctionKey {
                        center.postNotificationName(NSControlTextDidChangeNotification, object: self)
                    } else if character == NSRightArrowFunctionKey {
                        center.postNotificationName(NSControlTextDidChangeNotification, object: self)
                    } else if character == 0x1B {
                        field.disappearSheet()
                    }
                }
            }
        }
        return super.performKeyEquivalent(event)
    }
}

class SBURLFieldSheet: NSPanel {
    override var acceptsFirstResponder: Bool { return true }
    override func becomeFirstResponder() -> Bool { return true }
    override func resignFirstResponder() -> Bool { return true }
    //override var acceptsMouseMovedEvents: Bool { return true }
    
    override init(contentRect: NSRect, styleMask windowStyle: Int, backing bufferingType: NSBackingStoreType, defer deferCreation: Bool) {
        super.init(contentRect: contentRect, styleMask: windowStyle, backing: bufferingType, defer: deferCreation)
        acceptsMouseMovedEvents = true
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    /*override func performKeyEquivalent(event: NSEvent) -> Bool {
        return super.performKeyEquivalent(event)
    }*/
}

class SBURLFieldContentView: NSView {
    var dataSource: NSTableViewDataSource? {
        get { return table.dataSource() }
        set(dataSource) { table.setDataSource(dataSource) }
    }

    var delegate: NSTableViewDelegate? {
        get { return table.delegate() }
        set(delegate) { table.setDelegate(delegate) }
    }
    
    var field: SBURLField? {
        if let tableDelegate = table.delegate() as? SBURLField {
            return tableDelegate
        }
        return nil
    }
    
    var selectedRowIndex: Int { return table.selectedRow }
    
    //private var text: NSTextField
    
    private var scrollerRect: NSRect {
        var r = NSZeroRect
        r.origin.x = 1
        r.size.width = bounds.size.width - 2
        r.size.height = SBURLFieldRowHeight * CGFloat(SBURLFieldRowCount)
        r.origin.y = bounds.size.height - r.size.height
        return r
    }
    
    private lazy var scroller: NSScrollView = {
        let scroller = SBBLKGUIScrollView(frame: self.scrollerRect)
        scroller.autoresizingMask = .ViewWidthSizable | .ViewHeightSizable
        scroller.autohidesScrollers = true
        scroller.hasVerticalScroller = true
        scroller.autohidesScrollers = true
        scroller.backgroundColor = SBTableLightGrayCellColor
        scroller.drawsBackground = true
        scroller.documentView = self.table
        return scroller
    }()
    
    private lazy var table: NSTableView = {
        var tableRect = NSZeroRect
        tableRect.size = self.scrollerRect.size
        
        let cell = SBURLFieldDataCell()
        cell.font = NSFont.systemFontOfSize(12.0)
        cell.alignment = .LeftTextAlignment
        
        let column = NSTableColumn(identifier: kSBURL)
        column.dataCell = cell
        column.editable = false
        column.width = self.bounds.size.width
        
        let table = NSTableView(frame: tableRect)
        table.backgroundColor = NSColor.clearColor()
        table.rowHeight = SBURLFieldRowHeight - 2
        table.addTableColumn(column)
        table.allowsMultipleSelection = false
        table.allowsColumnSelection = false
        table.allowsEmptySelection = true
        table.action = "tableViewDidSingleAction:"
        table.columnAutoresizingStyle = .LastColumnOnlyAutoresizingStyle
        table.headerView = nil
        table.cornerView = nil
        table.autoresizingMask = .ViewWidthSizable
        table.intercellSpacing = NSZeroSize
        return table
    }()
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        addSubview(scroller)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    // MARK: Action
    
    func adjustTable() {
        var scrollerRect = scroller.frame
        var tableRect = table.frame
        let numberOfRows = dataSource?.numberOfRowsInTableView?(table) ?? 0
        let rowCount = SBConstrain(numberOfRows, max: SBURLFieldMaxRowCount)
        scrollerRect.size.width = bounds.size.width - 2
        scrollerRect.size.height = SBURLFieldRowHeight * CGFloat(rowCount)
        scrollerRect.origin.y = SBURLFieldSheetPadding
        tableRect.size.width = scrollerRect.size.width
        scroller.frame = scrollerRect
        table.frame = tableRect
    }
    
    func selectRow(rowIndex: Int) -> Bool {
        table.selectRowIndexes(NSIndexSet(index: rowIndex), byExtendingSelection: false)
        table.scrollRowToVisible(rowIndex)
        return pushItemAtIndex(rowIndex)
    }
    
    func deselectRow() {
        table.deselectAll(nil)
        table.scrollRowToVisible(0)
        field!.image = nil
    }
    
    func reloadData() {
        table.reloadData()
    }
    
    func pushSelectedItem() {
        pushItemAtIndex(table.selectedRow)
    }
    
    func pushItemAtIndex(index: Int) -> Bool {
        if let field = field {
            if index < field.items.count {
                let selectedItem = field.items[index]
                let type = SBURLFieldItemType(rawValue: (selectedItem[kSBType] as? NSNumber) ?? -1)
                if type &! {$0 == .GoogleSuggest} {
                    let title: String = selectedItem[kSBTitle]! as NSString
                    field.URLString = title
                    return true
                } else {
                    let URLString: String = selectedItem[kSBURL]! as NSString
                    if URLString != field.stringValue {
                        let data = selectedItem[kSBImage] as NSData
                        let icon = NSImage(data: data)
                        field.URLString = URLString
                        field.image = icon
                        return true
                    }
                }
            }
        }
        return false
    }
    
    // MARK: Drawing
    
    override func drawRect(rect: NSRect) {
        let b = bounds
        var path = SBRoundedPathS(b, SBURLFieldRoundedCurve, 0, false, true)
        let locations: [CGFloat] = [0.0,
                                    SBURLFieldSheetPadding / b.size.height,
                                    (b.size.height - SBURLFieldSheetPadding) / b.size.height,
                                    1.0]
        
        let colors = [SBTableGrayCellColor, SBTableLightGrayCellColor, SBTableLightGrayCellColor, NSColor.whiteColor()]
        
        let gradient = NSGradient(colors: colors, atLocations: locations, colorSpace: NSColorSpace.genericRGBColorSpace()) //!!! device?
        gradient.drawInRect(b, angle: 90)
        
        var r = b
        r.origin.x += 0.5
        r.origin.y += 0.5
        if r.size.width >= 1.0 {
            r.size.width -= 1.0
        }
        path = SBRoundedPathS(r, SBURLFieldRoundedCurve, 0, false, true)
        path.lineWidth = 0.5
        NSColor.blackColor().set()
        path.stroke()
    }
}

class SBURLFieldDataCell: NSCell {
    var separator = false
    var sectionHeader = false
    var drawsImage = true
    
    override init() {
        super.init()
        alignment = .LeftTextAlignment
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    let side: CGFloat = 5.0
    var leftMargin: CGFloat { return sectionHeader ? 0.0 : 15.0 }
    var imageWidth: CGFloat { return drawsImage ? 20.0 : 0.0 }
    
    override func drawWithFrame(cellFrame: NSRect, inView controlView: NSView) {
        drawInteriorWithFrame(cellFrame, inView: controlView)
        drawImageWithFrame(cellFrame, inView: controlView)
        drawTitleWithFrame(cellFrame, inView: controlView)
    }
    
    override func drawInteriorWithFrame(cellFrame: NSRect, inView controlView: NSView) {
        let leftMargin = side + self.leftMargin
        var r = cellFrame
        r.origin.x += leftMargin
        r.size.width -= leftMargin
        let selectedColor = NSColor.alternateSelectedControlColor().colorUsingColorSpace(NSColorSpace.genericRGBColorSpace())
        let backgroundColor = SBBackgroundLightGrayColor
        let cellColor = SBTableLightGrayCellColor
        
        backgroundColor.set()
        NSRectFill(r)
        
        cellColor.set()
        NSRectFill(cellFrame)
        
        if highlighted {
            let r = cellFrame
            let path = SBRoundedPathS(NSInsetRect(r, 1.0, 1.0), (r.size.height - 1.0 * 2) / 2, 0.0, true, true)
            let gradient = NSGradient(startingColor: SBAlternateSelectedLightControlColor,
                                      endingColor:   SBAlternateSelectedControlColor)
            SBPreserveGraphicsState {
                path.addClip()
                gradient.drawInRect(r, angle: 90)
            }
        }
    }
    
    func drawImageWithFrame(cellFrame: NSRect, inView controlView: NSView) {
        if let image = self.image as NSImage? {
            var r = NSZeroRect
            r.size = image.size
            r.origin.x = cellFrame.origin.x + side + leftMargin + (imageWidth - r.size.width) / 2
            r.origin.y = cellFrame.origin.y + (cellFrame.size.height - r.size.height) / 2
            image.drawInRect(r, operation: .CompositeSourceOver, fraction: 1.0, respectFlipped: true)
        }
    }
    
    func drawTitleWithFrame(cellFrame: NSRect, inView controlView: NSView) {
        let title = self.title as String?
        if !(title ?? "").isEmpty {
            let nsTitle: NSString = title!
            let imageWidth = self.imageWidth + side + leftMargin
            let titleRect = NSMakeRect(cellFrame.origin.x + imageWidth, cellFrame.origin.y, cellFrame.size.width - imageWidth, cellFrame.size.height)
            let textColor = (sectionHeader ? SBTableDarkGrayCellColor : NSColor.blackColor()).colorUsingColorSpace(NSColorSpace.genericRGBColorSpace())
            let sTextColor = highlighted ? NSColor.clearColor() : NSColor.whiteColor()
            let color = highlighted ? NSColor.whiteColor() : textColor
            let font = NSFont.systemFontOfSize(sectionHeader ? 11.0 : 12.0)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .ByTruncatingTail
            let attribute = [NSFontAttributeName: font, NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: paragraphStyle]
            let sAttribute = [NSFontAttributeName: font, NSForegroundColorAttributeName: sTextColor, NSParagraphStyleAttributeName: paragraphStyle]
            var size = nsTitle.sizeWithAttributes(attribute)
            SBConstrain(size.width, max: titleRect.size.width - side * 2)
            var r = NSZeroRect
            r.size = size
            switch alignment {
                case .LeftTextAlignment:
                    r.origin.x = titleRect.origin.x + side
                case .RightTextAlignment:
                    r.origin.x = titleRect.origin.x + side + ((titleRect.size.width - side * 2) - size.width)
                case .CenterTextAlignment:
                    r.origin.x = titleRect.origin.x + ((titleRect.size.width - side * 2) - size.width) / 2
                default:
                    break
            }
            r.origin.y = titleRect.origin.y + (titleRect.size.height - r.size.height) / 2
            var sr = r
            sr.origin.y += 1.0
            nsTitle.drawInRect(sr, withAttributes: sAttribute)
            nsTitle.drawInRect(r, withAttributes: attribute)
            if separator {
                let leftMargin = NSMaxX(r) + 10.0
                var separatorRect = NSZeroRect
                separatorRect.origin.x = cellFrame.origin.x + leftMargin
                separatorRect.origin.y = NSMidY(r)
                separatorRect.size.width = cellFrame.size.width - leftMargin
                separatorRect.size.height = 1.0
                NSColor.whiteColor().set()
                NSRectFill(separatorRect)
                separatorRect.origin.y -= 1.0
                SBTableGrayCellColor.set()
                NSRectFill(separatorRect)
            }
        }
    }
}

func schemeForURLString(urlString: NSString) -> String? {
    var range = urlString.rangeOfString("://")
    if range.location != NSNotFound {
        range.length += range.location
        range.location = 0
        return urlString.substringWithRange(range)
    }
    return nil
}