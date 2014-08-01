import Cocoa

@objc
protocol SBToolbarDelegate: NSToolbarDelegate {
    func toolbarDidVisible(toolbar: SBToolbar)
    func toolbarDidInvisible(toolbar: SBToolbar)
}

class SBToolbar: NSToolbar {
    override var visible: Bool {
        get { return super.visible }
        set(shown) {
            if shown != super.visible {
                super.visible = shown
                if shown {
                    self.executeDidVisible()
                } else {
                    self.executeDidInvisible()
                }
            }
        }
    }
    
    func executeDidVisible() {
        if let delegate = self.delegate as? SBToolbarDelegate {
            delegate.toolbarDidVisible(self)
        }
    }
    
    func executeDidInvisible() {
        if let delegate = self.delegate as? SBToolbarDelegate {
            delegate.toolbarDidInvisible(self)
        }
    }
    
    // Returns whether the main toolbar contains item from item identifier
    func visibleItemForItemIdentifier(itemIdentifier: String) -> NSToolbarItem? {
        return (items as [NSToolbarItem]).first { $0.itemIdentifier == itemIdentifier }
    }
    
    func itemRectInWindowForIdentifier(identifier: String) -> NSRect {
        var r = NSZeroRect
        var delta = NSZeroPoint
        var theItem: NSToolbarItem?
        for item in visibleItems as [NSToolbarItem] {
            if item.itemIdentifier == identifier {
                var view: NSView? = item.view
                while true {
                    view = view!.superview
                    if !view {
                        break
                    }
                    delta.x += view!.frame.origin.x
                    delta.y += view!.frame.origin.y
                    if view! === self._toolbarView() {
                        break
                    }
                }
                theItem = item
                break
            }
        }
        if theItem {
            if theItem!.view {
                r = theItem!.view.frame
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
