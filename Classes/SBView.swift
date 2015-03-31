/*
SBView.swift

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

class SBView: NSView {
    var animationDuration: CGFloat = 0.5
    var frameColor: NSColor?
    weak var target: NSObjectProtocol?
    var doneSelector: Selector = nil
    var cancelSelector: Selector = nil
    
    override var alphaValue: CGFloat {
        willSet {
            if newValue == 1.0 {
                if wantsLayer {
                    wantsLayer = false
                }
            } else {
                if !wantsLayer {
                    wantsLayer = true
                }
            }
        }
    }
    
    var subview: NSView? {
        return subviews.get(0)
    }
    
    override var description: String {
        return "\(super.description) \(NSStringFromRect(frame))"
    }
    
    var keyView: Bool = true {
        didSet {
            if keyView != oldValue {
                needsDisplay = true
                let subviews: [NSView] = self.subviews
                if !subviews.isEmpty {
                    for subview in subviews {
                        if let view = subview as? SBView {
                            { view.keyView = self.keyView }()
                        }
                    }
                }
            }
        }
    }
    
    var toolbarVisible: Bool = true {
        didSet {
            if toolbarVisible != oldValue {
                needsDisplay = true
            }
        }
    }
    
    override init(frame: NSRect) {
        super.init(frame: frame)
    }
    
    // MARK: NSCoding Protocol
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        if decoder.allowsKeyedCoding {
            if decoder.containsValueForKey("frameColor") {
                frameColor = (decoder.decodeObjectForKey("frameColor") as! NSColor)
            }
            if decoder.containsValueForKey("animationDuration") {
                animationDuration = CGFloat(decoder.decodeDoubleForKey("animationDuration"))
            }
            if decoder.containsValueForKey("keyView") {
                keyView = decoder.decodeBoolForKey("keyView")
            }
            if decoder.containsValueForKey("toolbarVisible") {
                toolbarVisible = decoder.decodeBoolForKey("toolbarVisible")
            }
        }
    }
    
    override func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
        frameColor !! {coder.encodeObject($0, forKey: "frameColor")}
        coder.encodeDouble(Double(animationDuration), forKey: "animationDuration")
        coder.encodeBool(keyView, forKey: "keyView")
        coder.encodeBool(toolbarVisible, forKey: "toolbarVisible")
    }
    
    // MARK: View
    
    override func acceptsFirstMouse(event: NSEvent) -> Bool {
        return true
    }
    
    // MARK: Setter
    
    func setFrame(frame: NSRect, animate: Bool) {
        if animate {
            let info: [NSObject: AnyObject] = [
                NSViewAnimationTargetKey: self,
                NSViewAnimationStartFrameKey: NSValue(rect: frame),
                NSViewAnimationEndFrameKey: NSValue(rect: frame)]
            let animation = NSViewAnimation(viewAnimations: [info])
            animation.duration = 0.25
            animation.startAnimation()
        } else {
            self.frame = frame
        }
    }
    
    // MARK: Actions
    
    func fadeIn(delegate: NSAnimationDelegate?) {
        let info: [NSObject: AnyObject] = [
            NSViewAnimationTargetKey: self,
            NSViewAnimationEffectKey: NSViewAnimationFadeInEffect]
        let animation = NSViewAnimation(viewAnimations: [info])
        animation.duration = NSTimeInterval(animationDuration)
        animation.delegate = delegate
        animation.startAnimation()
    }
    
    func fadeOut(delegate: NSAnimationDelegate?) {
        let info: [NSObject: AnyObject] = [
            NSViewAnimationTargetKey: self,
            NSViewAnimationEffectKey: NSViewAnimationFadeOutEffect]
        let animation = NSViewAnimation(viewAnimations: [info])
        animation.duration = NSTimeInterval(animationDuration)
        animation.delegate = delegate
        animation.startAnimation()
    }
    
    func done() {
        if target?.respondsToSelector(doneSelector) ?? false {
            NSApp.sendAction(doneSelector, to: target, from: self)
        }
    }
    
    func cancel() {
        if target?.respondsToSelector(cancelSelector) ?? false {
            NSApp.sendAction(cancelSelector, to: target, from: self)
        }
    }
    
    // MARK: Drawing
    
    override func drawRect(rect: NSRect) {
        if frameColor != nil {
            frameColor!.colorWithAlphaComponent(0.5).set()
            NSRectFill(rect) // Transparent
            frameColor!.set()
            NSFrameRect(bounds)
        }
    }
}