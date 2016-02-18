/*
SBFindbar.swift

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

@objc protocol SBFindbarTarget {
    func searchFor(_: String, direction forward: Bool, caseSensitive: Bool, wrap: Bool, continuous: Bool) -> Bool
}

class SBFindbar: SBView, NSTextFieldDelegate, NSControlTextEditingDelegate {
    var searchedString: String?
    
    override var frame: NSRect {
        didSet {
            contentView.frame = contentRect
        }
    }
    
    internal lazy var contentView: NSView = {
        return NSView(frame: self.contentRect)
    }()
    
    private lazy var closeButton: SBButton = {
        let r = self.closeRect
        let closeButton = SBButton(frame: r)
        closeButton.autoresizingMask = .ViewMaxXMargin
        closeButton.image = SBIconImage(SBCloseIconImage(), .Exclusive, r.size)
        closeButton.target = self
        closeButton.action = "executeClose"
        return closeButton
    }()
    
    internal lazy var searchField: SBFindSearchField = {
        let string: String? = NSPasteboard(name: NSFindPboard).stringForType(NSStringPboardType)
        let searchField = SBFindSearchField(frame: self.searchRect)
        searchField.autoresizingMask = .ViewWidthSizable
        searchField.delegate = self
        searchField.target = self
        searchField.action = "search:"
        searchField.nextAction = "searchForward:"
        searchField.previousAction = "searchBackward:"
        searchField.cell!.sendsWholeSearchString = true
        searchField.cell!.sendsSearchStringImmediately = false
        string !! { searchField.stringValue = $0 }
        return searchField
    }()
    
    internal lazy var backwardButton: SBButton? = {
        let r = self.backwardRect
        let backwardButton = SBButton(frame: r)
        backwardButton.autoresizingMask = .ViewMinXMargin
        backwardButton.image = SBFindBackwardIconImage(r.size, true)
        backwardButton.disableImage = SBFindBackwardIconImage(r.size, false)
        backwardButton.target = self
        backwardButton.action = "searchBackward:"
        return backwardButton
    }()
    
    internal lazy var forwardButton: SBButton? = {
        let r = self.forwardRect
        let forwardButton = SBButton(frame: r)
        forwardButton.autoresizingMask = .ViewMinXMargin
        forwardButton.image = SBFindForwardIconImage(r.size, true)
        forwardButton.disableImage = SBFindForwardIconImage(r.size, false)
        forwardButton.target = self
        forwardButton.action = "searchForward:"
        forwardButton.keyEquivalent = "g"
        return forwardButton
    }()
    
    internal lazy var caseSensitiveCheck: BLKGUI.Button? = {
        let caseFlag = NSUserDefaults.standardUserDefaults().boolForKey(kSBFindCaseFlag)
        let caseSensitiveCheck = BLKGUI.Button(frame: self.caseSensitiveRect)
        caseSensitiveCheck.autoresizingMask = .ViewMinXMargin
        caseSensitiveCheck.buttonType = .SwitchButton
        caseSensitiveCheck.font = NSFont.systemFontOfSize(10.0)
        caseSensitiveCheck.title = NSLocalizedString("Ignore Case", comment: "")
        caseSensitiveCheck.state = caseFlag ? NSOnState : NSOffState
        caseSensitiveCheck.target = self
        caseSensitiveCheck.action = "checkCaseSensitive:"
        return caseSensitiveCheck
    }()
    
    internal lazy var wrapCheck: BLKGUI.Button? = {
        let wrapFlag = NSUserDefaults.standardUserDefaults().boolForKey(kSBFindWrapFlag)
        let wrapCheck = BLKGUI.Button(frame: self.wrapRect)
        wrapCheck.autoresizingMask = .ViewMinXMargin
        wrapCheck.buttonType = .SwitchButton
        wrapCheck.font = NSFont.systemFontOfSize(10.0)
        wrapCheck.title = NSLocalizedString("Wrap Around", comment: "")
        wrapCheck.state = wrapFlag ? NSOnState : NSOffState
        wrapCheck.target = self
        wrapCheck.action = "checkWrap:"
        return wrapCheck
    }()
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        addSubview(contentView)
        contentView.addSubview(searchField)
        contentView.addSubview(closeButton)
        backwardButton !! contentView.addSubview
        forwardButton !! contentView.addSubview
        caseSensitiveCheck !! contentView.addSubview
        wrapCheck !! contentView.addSubview
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    class var minimumWidth: CGFloat { return 750 }
    class var availableWidth: CGFloat { return 300 }
    
    // MARK: Rects
    
    var contentRect: NSRect {
        var r = bounds
        SBConstrain(&r.size.width, min: self.dynamicType.minimumWidth)
        return r
    }
    
    var closeRect: NSRect {
        return NSMakeRect(0, 0, bounds.size.height, bounds.size.height)
    }
    
    var searchRect: NSRect {
        var r = NSZeroRect
        let marginNextToCase: CGFloat = 150.0;
        r.size.width = caseSensitiveRect.origin.x - closeRect.maxX - marginNextToCase - 24.0 * 2
        r.size.height = 19.0
        r.origin.x = closeRect.maxX
        r.origin.y = (bounds.size.height - r.size.height) / 2
        return r
    }
    
    var backwardRect: NSRect {
        var r = NSZeroRect
        r.size.width = 24.0
        r.size.height = 18.0
        r.origin.y = (bounds.size.height - r.size.height) / 2
        r.origin.x = searchRect.maxX
        return r
    }
    
    var forwardRect: NSRect {
        var r = NSZeroRect
        r.size.width = 24.0
        r.size.height = 18.0
        r.origin.y = (bounds.size.height - r.size.height) / 2
        r.origin.x = backwardRect.maxX
        return r
    }
    
    var caseSensitiveRect: NSRect {
        var r = NSZeroRect
        r.size.width = 150.0
        r.size.height = bounds.size.height
        r.origin.x = wrapRect.origin.x - r.size.width
        return r
    }
    
    var wrapRect: NSRect {
        var r = NSZeroRect
        r.size.width = 150.0
        r.size.height = bounds.size.height
        r.origin.x = contentRect.size.width - r.size.width
        return r
    }
    
    // MARK: Delegate
    
    override func controlTextDidChange(notification: NSNotification) {
        if !searchField.stringValue.isEmpty {
            searchContinuous(nil)
        }
    }
    
    func control(control: NSControl, textView: NSTextView, doCommandBySelector command: Selector) -> Bool {
        if control === searchField &&
           command == "cancelOperation:" &&
           searchField.stringValue.isEmpty {
            executeClose()
            return true
        }
        return false
    }
    
    // MARK: Actions
    
    func selectText(sender: AnyObject?) {
        searchField.selectText(nil)
    }
    
    func searchContinuous(sender: AnyObject?) {
        executeSearch(true, continuous: true)
    }
    
    func search(sender: AnyObject?) {
        if !searchField.stringValue.isEmpty {
            executeSearch(true, continuous: false)
            executeClose()
        }
    }
    
    func searchBackward(sender: AnyObject?) {
        executeSearch(false, continuous: false)
    }

    func searchForward(sender: AnyObject?) {
        executeSearch(true, continuous: false)
    }
    
    func checkCaseSensitive(sender: AnyObject?) {
        let caseFlag = caseSensitiveCheck!.state == NSOnState
        NSUserDefaults.standardUserDefaults().setBool(caseFlag, forKey: kSBFindCaseFlag)
    }

    func checkWrap(sender: AnyObject?) {
        let wrapFlag = wrapCheck!.state == NSOnState
        NSUserDefaults.standardUserDefaults().setBool(wrapFlag, forKey: kSBFindWrapFlag)
    }
    
    func executeClose() {
        if target?.respondsToSelector(doneSelector) ?? false {
            NSApp.sendAction(doneSelector, to: target, from: self)
        }
    }
    
    func executeSearch(forward: Bool, continuous: Bool) -> Bool {
        var r = false
        let string = searchField.stringValue
        let pasteboard = NSPasteboard(name: NSFindPboard)
        pasteboard.declareTypes([NSStringPboardType], owner: self)
        pasteboard.setString(string, forType: NSStringPboardType)
        if let target = target as? SBFindbarTarget {
            let caseFlag = caseSensitiveCheck!.state == NSOnState
            let wrap = wrapCheck!.state == NSOnState
            r = target.searchFor(string, direction: forward, caseSensitive: caseFlag, wrap: wrap, continuous: continuous)
        }
        searchedString = string
        return r
    }
    
    // MARK: Drawing
    
    override func drawRect(rect: NSRect) {
        let lh: CGFloat = 1.0
    
        // Background
        let gradient = NSGradient(startingColor: NSColor.blackColor(),
                                  endingColor: NSColor(deviceWhite: 0.50, alpha: 1.0))!
        gradient.drawInRect(bounds, angle: 90)
        
        // Lines
        NSColor.blackColor().set()
        NSRectFill(NSMakeRect(bounds.origin.x, bounds.maxY - lh, bounds.size.width, lh))
        NSRectFill(NSMakeRect(bounds.origin.x, bounds.origin.y, bounds.size.width, lh))
    }
}


class SBFindSearchField: NSSearchField {
    var nextAction: Selector = nil
    var previousAction: Selector = nil
    
    func performFindNext(sender: AnyObject?) {
        if target?.respondsToSelector(nextAction) ?? false {
            NSApp.sendAction(nextAction, to: target, from: self)
        }
    }
    
    func performFindPrevious(sender: AnyObject?) {
        if target?.respondsToSelector(previousAction) ?? false {
            NSApp.sendAction(previousAction, to: target, from: self)
        }
    }
}