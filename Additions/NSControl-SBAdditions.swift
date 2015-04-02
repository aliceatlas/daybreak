/*
NSControl-SBAdditions.swift

Copyright (c) 2015, Alice Atlas
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

extension NSControl {
    @objc(_cell)
    var cell: NSCell? {
        return cell() as? NSCell
    }
}

extension NSButton {
    override var cell: NSButtonCell? { return super.cell as? NSButtonCell }
}

extension NSPopUpButton {
    override var cell: NSPopUpButtonCell? { return super.cell as? NSPopUpButtonCell }
}

extension NSSlider {
    override var cell: NSSliderCell? { return super.cell as? NSSliderCell }
}

extension NSTextField {
    override var cell: NSTextFieldCell? { return super.cell as? NSTextFieldCell }
}

extension NSSearchField {
    override var cell: NSSearchFieldCell? { return super.cell as? NSSearchFieldCell }
}