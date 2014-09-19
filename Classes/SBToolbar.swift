/*
SBToolbar.swift

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

import Cocoa

@objc
protocol SBToolbarDelegate: NSToolbarDelegate {
    func toolbarDidVisible(toolbar: SBToolbar)
    func toolbarDidInvisible(toolbar: SBToolbar)
}

class SBToolbar: NSToolbar {
    override var visible: Bool {
        didSet {
            if visible != oldValue {
                if visible {
                    executeDidVisible()
                } else {
                    executeDidInvisible()
                }
            }
        }
    }
    
    var sbDelegate: SBToolbarDelegate? {
        get { return delegate as? SBToolbarDelegate }
        set(sbDelegate) { delegate = sbDelegate }
    }
    
    override init(identifier: String) {
        super.init(identifier: identifier)
    }
    
    func executeDidVisible() {
        sbDelegate?.toolbarDidVisible(self)
    }
    
    func executeDidInvisible() {
        sbDelegate?.toolbarDidInvisible(self)
    }
    
    // Returns whether the main toolbar contains item from item identifier
    func visibleItemForItemIdentifier(itemIdentifier: String) -> NSToolbarItem? {
        return (items as [NSToolbarItem]).first { $0.itemIdentifier == itemIdentifier }
    }
    
    func itemRectInWindowForIdentifier(identifier: String) -> NSRect {
        var r = NSZeroRect
        var delta = NSZeroPoint
        if let item = (visibleItems as [NSToolbarItem]).first({ $0.itemIdentifier == identifier })
        {
            var view: NSView! = item.view
            while true {
                view = view.superview
                if view == nil {
                    break
                }
                delta.x += view.frame.origin.x
                delta.y += view.frame.origin.y
                if view === _toolbarView() {
                    break
                }
            }
            if item.view != nil {
                r = item.view!.frame
                r.origin.x += delta.x
                r.origin.y += delta.y
            }
        }
        return r
    }
    
    func itemRectInScreenForIdentifier(identifier: String) -> NSRect {
        return window.convertRectToScreen(itemRectInWindowForIdentifier(identifier))
    }
    
    var window: NSWindow {
        return ((NSApp.windows as [NSWindow]).first { $0.toolbar === self })!
    }
}
