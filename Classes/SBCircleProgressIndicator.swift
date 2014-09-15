/*
SBCircleProgressIndicator.swift

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

@IBDesignable
class SBCircleProgressIndicator: SBView {
    @IBInspectable var style: SBCircleProgressIndicatorStyle = .RegularStyle
    @IBInspectable var backgroundColor: NSColor = NSColor(calibratedWhite: 0.5, alpha: 1.0)
    @IBInspectable var fillColor: NSColor = NSColor(calibratedWhite: 0.85, alpha: 1.0)
    @IBInspectable var alwaysDrawing: Bool = false
    @IBInspectable var showPercentage: Bool = false
    
    @IBInspectable var progress: CGFloat = 0.0 {
        didSet {
            if progress != oldValue {
                needsDisplay = true
                if !alwaysDrawing {
                    if progress >= 1.0 {
                        SBDispatchDelay(0.5, clearProgress)
                    }
                }
            }
        }
    }
    
    @IBInspectable var selected: Bool = false {
        didSet {
            if selected != oldValue {
                needsDisplay = true
            }
        }
    }
    
    @IBInspectable var highlighted: Bool = false {
        didSet {
            if highlighted != oldValue {
                needsDisplay = true
            }
        }
    }
    
    override init(frame: NSRect) {
        super.init(frame: frame)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        if coder.allowsKeyedCoding {
            style = SBCircleProgressIndicatorStyle.fromRaw(coder.decodeIntegerForKey("style")) ?? .RegularStyle
            backgroundColor = coder.decodeObjectForKey("backgroundColor") as NSColor
            fillColor = coder.decodeObjectForKey("fillColor") as NSColor
            progress = CGFloat(coder.decodeDoubleForKey("progress"))
            selected = coder.decodeBoolForKey("selected")
            highlighted = coder.decodeBoolForKey("highlighted")
            alwaysDrawing = coder.decodeBoolForKey("alwaysDrawing")
            showPercentage = coder.decodeBoolForKey("showPercentage")
        }
    }
    
    override func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
        coder.encodeInteger(style.toRaw(), forKey: "style")
        coder.encodeObject(backgroundColor, forKey: "backgroundColor")
        coder.encodeObject(fillColor, forKey: "fillColor")
        coder.encodeDouble(Double(progress), forKey: "progress")
        coder.encodeBool(selected, forKey: "selected")
        coder.encodeBool(alwaysDrawing, forKey: "alwaysDrawing")
        coder.encodeBool(showPercentage, forKey: "showPercentage")
        coder.encodeBool(highlighted, forKey: "highlighted")
    }
    
    // MARK: View
    
    override var opaque: Bool { return true }
    
    // Clicking through
    override func hitTest(point: NSPoint) -> NSView? {
        let view = super.hitTest(point)
        return (view === self) ? nil : view
    }
    
    // MARK: Setter
    
    func clearProgress() {
        progress = -1
        needsDisplay = true
        superview?.needsDisplay = true
    }
    
    // MARK: Drawing
    
    override func drawRect(rect: NSRect) {
        if alwaysDrawing || progress < 1.0 {
            if progress >= 0 {
                let r = bounds
                
                let cp = NSMakePoint(NSMidX(r), NSMidY(r))
                let lw: CGFloat = 1.5
                let square = SBCenteredSquare(r)
                let radius = (square.size.width / 2) - lw
                
                let isFirstResponder = (superview as? SBAnswersIsFirstResponder)?.isFirstResponder ?? false
                
                if selected && keyView {
                    let colors = [NSColor.whiteColor(), NSColor(deviceWhite: 0.15, alpha: 1.0)]
                    let path = NSBezierPath(ovalInRect: NSInsetRect(square, lw, lw))
                    let gradient = NSGradient(startingColor: colors[0], endingColor: colors[1])
                    SBPreserveGraphicsState {
                        path.setClip()
                        gradient.drawInRect(r, angle: 90)
                    }
                }
                
                switch style {
                    case .WhiteStyle:
                        if highlighted && isFirstResponder {
                            SBAlternateSelectedDarkControlColor.set()
                        } else {
                            NSColor(deviceWhite: 1.0, alpha: 0.75).set()
                        }
                        let path = NSBezierPath(ovalInRect: NSInsetRect(square, lw + 1.0, lw + 1.0))
                        path.lineWidth = 1.0
                        path.stroke()
                    case .RegularStyle:
                        backgroundColor.colorWithAlphaComponent((selected && keyView) ? 1.0 : 0.5).set()
                        let path = NSBezierPath(ovalInRect: NSInsetRect(square, lw + 1.0, lw + 1.0))
                        path.fill()
                }
                
                // Percentage(Arc)
                let sa: CGFloat = 0
                let ea: CGFloat = progress * 360
                let startAngle: CGFloat = sa - 270
                let endAngle: CGFloat = -ea - 270
                let path = NSBezierPath()
                path.moveToPoint(cp)
                path.appendBezierPathWithArcWithCenter(cp, radius: radius - 1.0, startAngle: startAngle, endAngle: endAngle, clockwise: true)
                path.closePath()
                var colors: [NSColor] = []
                if highlighted && isFirstResponder {
                    colors = [SBAlternateSelectedDarkControlColor, SBAlternateSelectedControlColor]
                } else {
                    switch style {
                        case .WhiteStyle:
                            colors = [NSColor(deviceWhite: 1.0, alpha: 0.75),
                                      NSColor(deviceWhite: 1.0, alpha: 0.75)]
                        case .RegularStyle:
                            colors = [NSColor(deviceWhite: ((selected && keyView) ? 0.75 : 0.5), alpha: 1.0),
                                      NSColor(deviceWhite: ((selected && keyView) ? 1.0 : 0.75), alpha: 1.0)]
                    }
                }
                let gradient = NSGradient(startingColor: colors[0], endingColor: colors[1])
                gradient.drawInBezierPath(path, angle: 90)
                
                if showPercentage {
                    // Percentage(String)
                    let percentage = NSString(format: "%.1f%%", Double(progress * 100))
                    var tr = NSZeroRect
                    var sr = NSZeroRect
                    let attributes  = [NSFontAttributeName: NSFont.boldSystemFontOfSize(10.0),
                                       NSForegroundColorAttributeName: NSColor.whiteColor()]
                    let sAttributes = [NSFontAttributeName: NSFont.boldSystemFontOfSize(10.0),
                                       NSForegroundColorAttributeName: NSColor(calibratedWhite: 0.0, alpha: 0.75)]
                    tr.size = percentage.sizeWithAttributes(attributes)
                    tr.origin.x = (r.size.width - tr.size.width) / 2
                    tr.origin.y = (r.size.height - tr.size.height) / 2
                    
                    // Draw edge
                    sr = tr
                    sr.origin.y -= 1.0
                    // Bottom
                    percentage.drawInRect(sr, withAttributes: sAttributes)
                    sr = tr
                    sr.origin.y += 1.0
                    // Top
                    percentage.drawInRect(sr, withAttributes: sAttributes)
                    sr = tr
                    sr.origin.x -= 1.0
                    // Left
                    percentage.drawInRect(sr, withAttributes: sAttributes)
                    sr = tr
                    sr.origin.x += 1.0
                    // Right
                    percentage.drawInRect(sr, withAttributes: sAttributes)
                    
                    // Draw text
                    percentage.drawInRect(tr, withAttributes: attributes)
                }
            }
        }
    }
}