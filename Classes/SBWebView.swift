/*
SBWebView.swift

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

@objc protocol SBWebViewDelegate {
    optional func webViewShouldOpenFindbar(SBWebView)
    optional func webViewShouldCloseFindbar(SBWebView) -> Bool
}

class SBWebView: WebView, SBFindbarTarget {
    weak var delegate: SBWebViewDelegate?
    var showFindbar = false
	private var magnified = false
    
    var _textEncodingName: String?
    var textEncodingName: String {
        get { return _textEncodingName ?? preferences.defaultTextEncodingName }
        set(textEncodingName) { _textEncodingName = textEncodingName }
    }
    
    var documentString: String {
        return (mainFrame.frameView.documentView as WebDocumentText).string()
    }
    
    var isEmpty: Bool {
        let URLString = mainFrame.dataSource?.request.URL?.absoluteString
        return (URLString ?? "") == ""
    }
    
    // MARK: Menu Actions
    
    func performFind(sender: AnyObject) {
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
        if continuous {
            let range = rangeOfStringInWebDocument(searchString, caseSensitive: caseFlag) // Flip case flag
            r = range.location != NSNotFound
        } else {
            r = searchFor(searchString, direction: forward, caseSensitive: !caseFlag, wrap: wrapFlag)
        }
        if respondsToSelector("unmarkAllTextMatches") {
            unmarkAllTextMatches()
        }
        if r {
            if respondsToSelector("markAllMatchesForText:caseSensitive:highlight:limit:") {
                markAllMatchesForText(searchString, caseSensitive: !caseFlag, highlight: true, limit: 0)
            }
        } else {
            NSBeep()
        }
        return r
    }
    
    func executeOpenFindbar() {
        if let f = delegate?.webViewShouldOpenFindbar {
            f(self)
            showFindbar = true
        }
    }
    
    func executeCloseFindbar() -> Bool {
        if let f = delegate?.webViewShouldCloseFindbar {
            let r = f(self)
            showFindbar = false
            return r
        }
        return false
    }
    
    // Return range of string in web document
    func rangeOfStringInWebDocument(string: String, caseSensitive caseFlag: Bool) -> NSRange {
        if !documentString.isEmpty {
            return (documentString as NSString).rangeOfString(string, options:(caseFlag ? .CaseInsensitiveSearch : nil))
        }
        return NSMakeRange(NSNotFound, 0)
    }
    
    override func keyDown(event: NSEvent) {
        let character = (event.characters as NSString).characterAtIndex(0)
        if character == 0x1B {
            if !executeCloseFindbar() {
                super.keyDown(event)
            }
        } else {
            super.keyDown(event)
        }
    }
    
    // MARK: Gesture
    
    override func beginGestureWithEvent(event: NSEvent) {
        magnified = false
    }
    
    override func endGestureWithEvent(event: NSEvent) {
        magnified = true
    }
    
    override func magnifyWithEvent(event: NSEvent) {
        if !magnified {
            let magnification = event.magnification
            if magnification > 0 {
                zoomPageIn(nil)
                magnified = true
            } else if magnification < 0 {
                zoomPageOut(nil)
                magnified = true
            }
        }
    }
    
    override func swipeWithEvent(event: NSEvent) {
        let deltaX = event.deltaX
        if deltaX > 0 { // Left
            if canGoBack {
                if loading {
                    stopLoading(nil)
                }
                goBack(nil)
            } else {
                NSBeep()
            }
        } else if deltaX < 0 { // Right
            if canGoForward {
                if loading {
                    stopLoading(nil)
                }
                goForward(nil)
            } else {
                NSBeep()
            }
        }
    }
    
    // MARK: Private API
    
    func showWebInspector(sender: AnyObject) {
        inspector().show(nil)
    }
    
    override func showConsole(sender: AnyObject) {
        let inspector = self.inspector()
        inspector.show(nil)
        func showConsole() {
            inspector.showConsole(nil)
        }
        SBDispatchDelay(0.25, showConsole)
    }
}