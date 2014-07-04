/*
SBLoadButton.swift

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

class SBLoadButton: SBButton {
    var _images: NSArray?
    var images: NSArray? {
        get { return _images }
        set(inImages) {
            if _images != inImages {
                _images = inImages
                if _images != nil && _images!.count > 0 {
                    self.image = _images![0] as NSImage
                    self.needsDisplay = true
                }
                on = false
            }
        }
    }
    
    var indicator: NSProgressIndicator?
    
    var _on = false
    var on: Bool {
        get {
            return _on
        }
        set(isOn) {
            if isOn != _on {
                _on = isOn
                if isOn {
                    indicator?.startAnimation(nil)
                } else {
                    indicator?.stopAnimation(nil)
                }
                self.switchImage()
            }
        }
    }
    
    override var frame: NSRect {
        get {
            return super.frame
        }
        set(frame) {
            var r = frame
            r.size.width = r.size.height
            r.origin.x += (frame.size.width - r.size.width) / 2
            super.frame = r
        }
    }

    
    init(frame: NSRect) {
        super.init(frame: frame)
        indicator = constructIndicator()
        self.addSubview(indicator)
    }
    
    // NSCoding Protocol
    
    init(coder decoder: NSCoder) {
        super.init(coder: decoder)
        if decoder.allowsKeyedCoding {
            if decoder.containsValueForKey("images") {
                self.images = decoder.decodeObjectForKey("images") as? NSArray
            }
            if decoder.containsValueForKey("on") {
                self.on = decoder.decodeBoolForKey("on")
            }
        }
    }
    
    override func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
        if images != nil {
            coder.encodeObject(images, forKey: "images")
        }
        coder.encodeBool(on, forKey: "on")
    }
    
    func switchImage() {
        if let images = self.images {
            if images.count == 2 {
                if on {
                    if self.image === images[0] {
                        self.image = images[1] as NSImage
                        self.needsDisplay = true
                    }
                } else {
                    if self.image === images[1] {
                        self.image = images[0] as NSImage
                        self.needsDisplay = true
                    }
                }
            }
        }
    }

    func constructIndicator() -> NSProgressIndicator {
        let indicator = NSProgressIndicator(frame: NSMakeRect((self.bounds.size.width - 16.0) / 2, (self.bounds.size.height - 16.0) / 2, 16.0, 16.0))
        indicator.autoresizingMask = .ViewMaxXMargin | .ViewMinXMargin | .ViewMaxYMargin | .ViewMinYMargin
        indicator.usesThreadedAnimation = true
        indicator.style = .SpinningStyle
        indicator.displayedWhenStopped = false
        indicator.controlSize = .SmallControlSize
        return indicator
    }
    
    // Event
    
    override func mouseUp(event: NSEvent) {
        if enabled {
            let location = event.locationInWindow
            let point = self.convertPoint(location, fromView: nil)
            if NSPointInRect(point, self.bounds) {
                self.pressed = false
                self.on = !on
                self.executeAction()
            }
        }
    }
    
    // Drawing
    
    override func drawRect(rect: NSRect) {
        super.drawRect(self.bounds)
    }
}