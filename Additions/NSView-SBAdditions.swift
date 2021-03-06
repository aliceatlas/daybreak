/*
NSView-SBAdditions.swift

Copyright (c) 2014, Alice Atlas
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

extension NSView {
    func addConstraintStrings(metrics metrics: [String: Double], views: [String: NSView], constraints constraintStrings: [String]) {
        for constraintString in constraintStrings {
            let layoutConstraints = NSLayoutConstraint.constraintsWithVisualFormat(constraintString, options: [], metrics: metrics, views: views)
            addConstraints(layoutConstraints)
        }
    }
    
    func addConstraintStrings(metrics metrics: [String: Double], views: [String: NSView], _ constraintStrings: String...) {
        addConstraintStrings(metrics: metrics, views: views, constraints: constraintStrings)
    }
    
    func addSubviewsAndConstraintStrings(metrics metrics: [String: Double], views: [String: NSView], constraints constraintStrings: [String]) {
        addSubviews(views.values)
        addConstraintStrings(metrics: metrics, views: views, constraints: constraintStrings)
    }
    
    func addSubviewsAndConstraintStrings(metrics metrics: [String: Double], views: [String: NSView], _ constraintStrings: String...) {
        addSubviewsAndConstraintStrings(metrics: metrics, views: views, constraints: constraintStrings)
    }
    
    func addSubviews <T: SequenceType where T.Generator.Element: NSView> (views: T) {
        views.filter{$0.superview == nil}.forEach(addSubview)
    }
    
    func addSubviews(views: NSView...) {
        addSubviews(views)
    }
}