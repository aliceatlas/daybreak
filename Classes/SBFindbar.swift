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

@objc
protocol SBFindbarTarget {
    func searchFor(String, direction forward: Bool, caseSensitive: Bool, wrap: Bool, continuous: Bool) -> Bool
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
    	closeButton.image = NSImage(CGImage: SBIconImage(SBCloseIconImage(), .Exclusive, r.size))
    	closeButton.target = self
    	closeButton.action = "executeClose"
        return closeButton
    }()
    
    internal lazy var searchField: SBFindSearchField = {
    	let string = NSPasteboard(name: NSFindPboard).stringForType(NSStringPboardType)
    	let searchField = SBFindSearchField(frame: self.searchRect)
        searchField.autoresizingMask = .ViewWidthSizable
        searchField.delegate = self
        searchField.target = self
        searchField.action = "search:"
        searchField.nextAction = "searchForward:"
        searchField.previousAction = "searchBackward:"
        let cell = searchField.cell() as NSSearchFieldCell
        cell.sendsWholeSearchString = true
        cell.sendsSearchStringImmediately = false
        string !! { searchField.stringValue = $0 }
        return searchField
    }()
    
    internal lazy var backwardButton: SBButton? = {
        let r = self.backwardRect
    	let backwardButton = SBButton(frame: r)
        backwardButton.autoresizingMask = .ViewMinXMargin
    	backwardButton.image = NSImage(CGImage: SBFindBackwardIconImage(r.size, true))
    	backwardButton.disableImage = NSImage(CGImage: SBFindBackwardIconImage(r.size, false))
    	backwardButton.target = self
    	backwardButton.action = "searchBackward:"
        return backwardButton
    }()
    
    internal lazy var forwardButton: SBButton? = {
        let r = self.forwardRect
    	let forwardButton = SBButton(frame: r)
        forwardButton.autoresizingMask = .ViewMinXMargin
    	forwardButton.image = NSImage(CGImage: SBFindForwardIconImage(r.size, true))
    	forwardButton.disableImage = NSImage(CGImage: SBFindForwardIconImage(r.size, false))
    	forwardButton.target = self
    	forwardButton.action = "searchForward:"
    	forwardButton.keyEquivalent = "g"
        return forwardButton
    }()
    
    internal lazy var caseSensitiveCheck: SBBLKGUIButton? = {
    	let caseFlag = NSUserDefaults.standardUserDefaults().boolForKey(kSBFindCaseFlag)
    	let caseSensitiveCheck = SBBLKGUIButton(frame: self.caseSensitiveRect)
        caseSensitiveCheck.autoresizingMask = .ViewMinXMargin
        caseSensitiveCheck.buttonType = .SwitchButton
        caseSensitiveCheck.font = NSFont.systemFontOfSize(10.0)
        caseSensitiveCheck.title = NSLocalizedString("Ignore Case", comment: "")
        caseSensitiveCheck.state = caseFlag ? NSOnState : NSOffState
        caseSensitiveCheck.target = self
        caseSensitiveCheck.action = "checkCaseSensitive:"
        return caseSensitiveCheck
    }()
    
    internal lazy var wrapCheck: SBBLKGUIButton? = {
    	let wrapFlag = NSUserDefaults.standardUserDefaults().boolForKey(kSBFindWrapFlag)
    	let wrapCheck = SBBLKGUIButton(frame: self.wrapRect)
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
    
    class func minimumWidth() -> CGFloat { return 750 }
    class func availableWidth() -> CGFloat { return 300 }
    func minimumWidth() -> CGFloat { return SBFindbar.minimumWidth() }
    func availableWidth() -> CGFloat { return SBFindbar.availableWidth() }
    
    // MARK: Rects
    
    var contentRect: NSRect {
        var r = bounds
        SBConstrain(&r.size.width, min: minimumWidth())
        return r
    }
    
    var closeRect: NSRect {
    	var r = NSZeroRect
    	r.size.width = bounds.size.height
        r.size.height = bounds.size.height
    	return r
    }
    
    var searchRect: NSRect {
    	var r = NSZeroRect
    	let marginNextToCase: CGFloat = 150.0;
    	r.size.width = caseSensitiveRect.origin.x - NSMaxX(closeRect) - marginNextToCase - 24.0 * 2
    	r.size.height = 19.0
    	r.origin.x = NSMaxX(closeRect)
    	r.origin.y = (bounds.size.height - r.size.height) / 2
    	return r
    }
    
    var backwardRect: NSRect {
    	var r = NSZeroRect
    	r.size.width = 24.0
    	r.size.height = 18.0
    	r.origin.y = (bounds.size.height - r.size.height) / 2
    	r.origin.x = NSMaxX(searchRect)
    	return r
    }
    
    var forwardRect: NSRect {
    	var r = NSZeroRect
    	r.size.width = 24.0
    	r.size.height = 18.0
    	r.origin.y = (bounds.size.height - r.size.height) / 2
    	r.origin.x = NSMaxX(backwardRect)
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
    	let string = searchField.stringValue
    	if !string.isEmpty {
    		searchContinuous(nil)
    	}
    }
    
    func control(control: NSControl, textView: NSTextView, doCommandBySelector command: Selector) -> Bool {
    	if control === searchField {
    		if command == "cancelOperation:" {
    			if searchField.stringValue.isEmpty {
    				executeClose()
    				return true
    			}
    		}
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
        if (target !! doneSelector) != nil {
            if target.respondsToSelector(doneSelector) {
                SBPerform(target, doneSelector, self)
            }
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
                                  endingColor: NSColor(deviceWhite: 0.50, alpha: 1.0))
        gradient.drawInRect(bounds, angle: 90)
	    
    	// Lines
    	NSColor.blackColor().set()
    	NSRectFill(NSMakeRect(bounds.origin.x, NSMaxY(bounds) - lh, bounds.size.width, lh))
    	NSRectFill(NSMakeRect(bounds.origin.x, bounds.origin.y, bounds.size.width, lh))
    }
}


class SBFindSearchField: NSSearchField {
    var nextAction: Selector?
    var previousAction: Selector?
    
    func performFindNext(sender: AnyObject?) {
        if (target !! nextAction) != nil {
            if target.respondsToSelector(nextAction!) {
                SBPerform(target, nextAction!, self)
            }
        }
    }
    
    func performFindPrevious(sender: AnyObject?) {
        if (target !! previousAction) != nil {
            if target.respondsToSelector(previousAction!) {
                SBPerform(target, previousAction!, self)
            }
        }
    }
}