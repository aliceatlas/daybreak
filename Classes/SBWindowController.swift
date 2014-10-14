/*
SBWindowController.swift

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

class SBWindowController: NSWindowController {
	var viewSize: NSSize
    
    init(viewSize inViewSize: NSSize) {
        var frameRect = NSZeroRect
        var window: NSWindow?
        let screen = NSScreen.screens()![0] as NSScreen
        let visibleRect = screen.visibleFrame
        viewSize = inViewSize
        frameRect.size.width = viewSize.width + 20 * 2
        frameRect.size.height = viewSize.height < visibleRect.size.height ? viewSize.height : visibleRect.size.height
        frameRect.origin.y = visibleRect.origin.y + (visibleRect.size.height - frameRect.size.height)
        frameRect.origin.x = visibleRect.origin.x
        window = NSWindow(contentRect: frameRect, styleMask: (NSTitledWindowMask | NSClosableWindowMask | NSResizableWindowMask), backing: .Buffered, defer: true)
        super.init(window: window!)
        window!.center()
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
}