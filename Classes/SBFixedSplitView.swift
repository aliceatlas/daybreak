/*
SBFixedSplitView.swift

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

class SBFixedSplitView: NSSplitView {
    init(embedViews: [NSView], frameRect: NSRect) {
        let view1 = embedViews.get(0)
        let view2 = embedViews.get(1)
        let superview = view1?.superview ?? view2?.superview
        super.init(frame: frameRect)
        if superview != nil {
            superview!.addSubview(self)
            if view1 != nil {
                view1!.removeFromSuperview()
                addSubview(view1!)
            }
            if view2 != nil {
                view2!.removeFromSuperview()
                addSubview(view2!)
            }
        }
    }

    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override var dividerThickness: CGFloat { return 0 }
    
    @objc(resizeSubviewsWithOldSize:)
    func resizeSubviews(#oldSize: NSSize) {
        if !vertical {
            let subviews = self.subviews as [NSView]
            let subview1 = subviews.get(0)
            let subview2 = subviews.get(1)
            if subview1 != nil && subview2 != nil {
                var r1 = subview1!.frame
                var r2 = subview2!.frame
                r1.size.width = bounds.size.width
                r2.size.width = bounds.size.width;
                r2.size.height = bounds.size.height - r1.size.height
                r2.origin.y = r1.size.height
                subview1!.frame = r1
                subview2!.frame = r2
            }
        } else {
            super.resizeSubviewsWithOldSize(oldSize)
        }
    }
}