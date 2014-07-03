//
//  SBCoverWindow.swift
//  Sunrise
//
//  Created by Alice Atlas on 7/2/14.
//
//

import Cocoa

class SBCoverWindow: NSWindow {
    init(parentWindow: NSWindow, size: NSSize) {
        var frame = parentWindow.frame
        let styleMask = NSBorderlessWindowMask
        frame.size = size
        super.init(contentRect: frame, styleMask: styleMask, backing: .Buffered, defer: true)
        
        self.minSize = size
        self.releasedWhenClosed = true
        self.showsToolbarButton = false
        self.oneShot = false
        self.acceptsMouseMovedEvents = false
        self.opaque = false
        self.backgroundColor = NSColor(calibratedWhite:0.0, alpha:0.8)
        self.hasShadow = false
    }
    
    override func animationResizeTime(newWindowFrame: NSRect) -> NSTimeInterval {
        return 0
    }
    
    func canBecomeKeyWindow() -> Bool {
        return true
    }
}