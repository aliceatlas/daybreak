/*
SBSavePanel.swift

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

class SBSavePanel: NSSavePanel {
    override class func sbSavePanel() -> SBSavePanel {
        let panel = super.sbSavePanel() as SBSavePanel
        panel.opaque = false
        panel.backgroundColor = NSColor.clearColor()
        panel.showsResizeIndicator = false
        panel.constructBackgroundView()
        panel.switchButtonType()
        return panel
    }
    
    func constructBackgroundView() {
        if let contentView = contentView as? NSView {
            let subviews = contentView.subviews
            if !subviews.isEmpty {
                if let belowView = subviews[0] as? NSView {
                    let savePanelContentView = SBSavePanelContentView(frame: contentView.frame)
                    savePanelContentView.autoresizingMask = .ViewWidthSizable | .ViewHeightSizable
                    contentView.addSubview(savePanelContentView, positioned: .Below, relativeTo: belowView)
                }
            }
        }
    }
    
    func switchButtonType() {
        let subviews = contentView.subviews
        switchButtonTypeInSubViews(subviews)
    }
    
    func switchButtonTypeInSubViews(subviews: [AnyObject]) {
        for subview in subviews {
            if let button = subview as? NSButton {
                if button.bezelStyle == .RoundedBezelStyle {
                    button.bezelStyle = .TexturedRoundedBezelStyle
                }
            } else if let view = subview as? NSView {
                switchButtonTypeInSubViews(view.subviews)
            }
        }
    }
}

class SBOpenPanel: NSOpenPanel {
    override class func sbOpenPanel() -> SBOpenPanel {
        let panel = super.sbOpenPanel() as SBOpenPanel
        panel.opaque = false
        panel.backgroundColor = NSColor.clearColor()
        panel.showsResizeIndicator = false
        panel.constructBackgroundView()
        panel.switchButtonType()
        return panel
    }
    
    func constructBackgroundView() {
        if let contentView = contentView as? NSView {
            let subviews = contentView.subviews
            if !subviews.isEmpty {
                if let belowView = subviews[0] as? NSView {
                    let savePanelContentView = SBSavePanelContentView(frame: contentView.frame)
                    savePanelContentView.autoresizingMask = .ViewWidthSizable | .ViewHeightSizable
                    contentView.addSubview(savePanelContentView, positioned: .Below, relativeTo: belowView)
                }
            }
        }
    }
    
    func switchButtonType() {
        switchButtonTypeInSubViews(contentView.subviews)
    }
    
    func switchButtonTypeInSubViews(subviews: [AnyObject]) {
        for subview in subviews {
            if let button = subview as? NSButton {
                if button.bezelStyle == .RoundedBezelStyle {
                    button.bezelStyle = .TexturedRoundedBezelStyle
                }
            } else if let view = subview as? NSView {
                switchButtonTypeInSubViews(view.subviews)
            }
        }
    }
}

class SBSavePanelContentView: SBView {
    // MARK: Drawing
    
    override func drawRect(rect: NSRect) {
        let extended = bounds.size.height < 350.0
        let colors = (extended ? [NSColor(deviceWhite: 0.6, alpha: 1.0),
                                  NSColor(deviceWhite: 0.9, alpha: 1.0),
                                  NSColor(deviceWhite: 0.75, alpha: 1.0)]
                               : [NSColor(deviceWhite: 0.7, alpha: 1.0),
                                  NSColor(deviceWhite: 0.75, alpha: 1.0),
                                  NSColor(deviceWhite: 0.6, alpha: 1.0)])
        let strokeColor = NSColor(deviceWhite: 0.2, alpha: 1.0)
        
        super.drawRect(rect)
        
        // Paths
        // Gray scales
        let path = SBRoundedPathS(CGRectInset(bounds, 0.0, 0.0), 8.0, 0.0, false, true)
        let strokePath = SBRoundedPathS(CGRectInset(bounds, 0.5, 0.5), 8.0, 0.0, false, true)
        
        // Frame
        let gradient = NSGradient(colors: colors, atLocations: [0.0, 0.95, 1.0], colorSpace: NSColorSpace.deviceRGBColorSpace())
        gradient.drawInRect(bounds, angle: 90)
        
        // Stroke
        strokeColor.set()
        strokePath.lineWidth = 0.5
        strokePath.stroke()
    }
}