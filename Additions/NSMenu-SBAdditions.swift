/*
NSMenu-SBAdditions.swift

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

extension NSMenu {
    var selectedItem: NSMenuItem? {
        return itemArray.first { $0.state == NSOnState }
    }
    
    func selectItem(menuItem: NSMenuItem) {
        for item in itemArray {
            item.state = (item === menuItem) ? NSOnState : NSOffState
        }
    }
    
    func selectItem(#representedObject: AnyObject?) -> NSMenuItem? {
        var selectedItem: NSMenuItem?
        for item in itemArray {
            let repObject: AnyObject? = item.representedObject
            let equal = repObject === representedObject
            item.state = equal ? (selectedItem !! NSOffState ?? NSOnState) : NSOffState
            if equal && selectedItem == nil {
                selectedItem = item
            }
        }
        return selectedItem
    }
    
    func deselectItem() {
        itemArray.forEach { $0.state = NSOffState }
    }
    
    func addItem(#title: String, target: AnyObject?, action: Selector, tag: Int) -> NSMenuItem {
        let item = NSMenuItem()
        item.title = title
        item.target = target
        item.action = action
        item.tag = tag
        addItem(item)
        return item
    }
    
    func addItem(#title: String, representedObject: AnyObject?, target: AnyObject?, action: Selector) -> NSMenuItem {
        let item = NSMenuItem()
        item.title = title
        item.target = target
        item.action = action
        item.representedObject = representedObject
        addItem(item)
        return item
    }
}