/*
SBSourceTextView.swift

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
protocol SBSourceTextViewDelegate: NSTextViewDelegate {
    optional func textViewShouldOpenFindbar(SBSourceTextView)
    optional func textViewShouldCloseFindbar(SBSourceTextView)
}

class SBSourceTextView: NSTextView, SBFindbarTarget {
    var sbDelegate: SBSourceTextViewDelegate? {
        get { return delegate as? SBSourceTextViewDelegate }
        set(sbDelegate) { delegate = sbDelegate }
    }
	var showFindbar = false
    
    func performFind(sender: AnyObject) {
        // performFindPanelAction: of WebView is broken
        if bounds.size.width >= SBFindbar.availableWidth() {
            executeOpenFindbar()
        } else {
            NSBeep()
        }
    }
    
    func performFindNext(sender: AnyObject) {
        let string = NSPasteboard(name: NSFindPboard).stringForType(NSStringPboardType)
        if !string.isEmpty {
            let caseFlag = NSUserDefaults.standardUserDefaults().boolForKey(kSBFindCaseFlag)
            let wrapFlag = NSUserDefaults.standardUserDefaults().boolForKey(kSBFindWrapFlag)
            searchFor(string, direction: true, caseSensitive: caseFlag, wrap: wrapFlag, continuous: false)
        } else {
            performFind(sender)
        }
    }
    
    func performFindPrevious(sender: AnyObject) {
        let string = NSPasteboard(name: NSFindPboard).stringForType(NSStringPboardType)
        if !string.isEmpty {
            let caseFlag = NSUserDefaults.standardUserDefaults().boolForKey(kSBFindCaseFlag)
            let wrapFlag = NSUserDefaults.standardUserDefaults().boolForKey(kSBFindWrapFlag)
            searchFor(string, direction: false, caseSensitive: caseFlag, wrap: wrapFlag, continuous: false)
        } else {
            performFind(sender)
        }
    }
    
    func searchFor(searchString: String, direction forward: Bool, caseSensitive caseFlag: Bool, wrap wrapFlag: Bool, continuous: Bool) -> Bool {
        var r = false
        var selectedRange = self.selectedRange
        let allRange = NSMakeRange(0, string.utf16Count)
        var options: NSStringCompareOptions = nil
        if selectedRange.location == NSNotFound { selectedRange = NSMakeRange(0, 0) }
        let invalidLength = continuous ? selectedRange.location : (selectedRange.location + selectedRange.length)
        if forward { options |= .BackwardsSearch }
        if caseFlag { options |= .CaseInsensitiveSearch }
        var searchRange = forward ? NSMakeRange(invalidLength, allRange.length - invalidLength) : NSMakeRange(0, selectedRange.location)
        var range = (string as NSString).rangeOfString(searchString, options: options, range: searchRange)
        if range.location != NSNotFound {
            selectRange(range)
            r = true
        } else {
            if wrapFlag {
                searchRange = forward ? NSMakeRange(0, selectedRange.location) : NSMakeRange(invalidLength, allRange.length - invalidLength)
                range = (string as NSString).rangeOfString(searchString, options: options, range: searchRange)
                if range.location != NSNotFound {
                    selectRange(range)
                    r = true
                }
            }
        }
        if !r {
            NSBeep()
        }
        return r
    }
    
    func selectRange(range: NSRange) {
        selectedRange = range
        scrollRangeToVisible(range)
        showFindIndicatorForRange(range)
    }
    
    func executeOpenFindbar() {
        if let f = sbDelegate?.textViewShouldOpenFindbar {
            f(self)
            showFindbar = true
        }
    }
    
    func executeCloseFindbar() {
        if let f = sbDelegate?.textViewShouldCloseFindbar {
            f(self)
            showFindbar = false
        }
    }
}