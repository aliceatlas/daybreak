/*
SBSegmentedButton.swift

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

class SBSegmentedButton: SBView {
    private var _buttons: [SBButton] = []
    var buttons: [SBButton] {
        get { return _buttons }
        set(buttons) {
            if buttons != _buttons {
                _buttons = buttons
                for button in buttons {
                    self.addSubview(button)
                }
                self.adjustFrame()
            }
        }
    }
    
    override init() {
        super.init()
    }
    
    override init(frame: NSRect) {
        super.init(frame: frame)
    }
    
    // NSCoding Protocol
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
        if decoder.allowsKeyedCoding {
            if decoder.containsValueForKey("buttons") {
                self.buttons = decoder.decodeObjectForKey("buttons") as [SBButton]
            }
        }
    }
    
    override func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
        if !buttons.isEmpty {
            coder.encodeObject(buttons as NSArray, forKey: "buttons")
        }
    }
    
    // Actions
    
    func adjustFrame() {
        self.frame = buttons.map({ $0.frame }).reduce(NSZeroRect, NSUnionRect)
    }
}