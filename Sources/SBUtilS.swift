/*
SBUtilS.swift

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

import Foundation

func SBGetLocalizableTextSetS(path: String) -> ([[String]], [[NSTextField]], NSSize)? {
    let localizableString = NSString(contentsOfFile: path, encoding: NSUTF16StringEncoding, error: nil)
    if localizableString &! {$0.length > 0} {
        let fieldSize = NSSize(width: 300, height: 22)
        let offset = NSPoint(x: 45, y: 12)
        let margin = CGFloat(20)
        let lines = localizableString!.componentsSeparatedByString("\n") as [String]
        let count = CGFloat(lines.count)
        var size = NSSize(
            width: offset.x + (fieldSize.width * 2) + margin * 2,
            height: (fieldSize.height + offset.y) * count + offset.y + margin * 2)
        
        if count > 1 {
            var textSet: [[String]] = []
            var fieldSet: [[NSTextField]] = []
            for (i, line) in enumerate(lines) {
                var fieldRect = NSRect()
                var texts: [String] = []
                var fields: [NSTextField] = []
                let components = line.componentsSeparatedByString(" = ") as [NSString] as [String]
                
                fieldRect.size = fieldSize
                fieldRect.origin.y = size.height - margin - (fieldSize.height * CGFloat(i + 1)) - (offset.y * CGFloat(i))
                
                for (j, component) in enumerate(components) {
                    if !component.isEmpty {
                        let isMenuItem = !component.hasPrefix("//")
                        let editable = isMenuItem && j == 1
                        var string = component
                        fieldRect.origin.x = CGFloat(j) * (fieldSize.width + offset.x)
                        let field = NSTextField(frame: fieldRect)
                        field.editable = editable
                        field.selectable = isMenuItem
                        field.bordered = isMenuItem
                        field.drawsBackground = isMenuItem
                        field.bezeled = editable
                        (field.cell() as NSCell).scrollable = isMenuItem
                        if isMenuItem {
                            string = (component as NSString).stringByDeletingQuotations
                        }
                        texts.append(string)
                        fields.append(field)
                    }
                }
                if texts.count >= 1 {
                    textSet.append(texts)
                }
                if fields.count >= 1 {
                    fieldSet.append(fields)
                }
            }
            return (textSet, fieldSet, size)
        }
    }
    return nil
}

// Return value for key in "com.apple.internetconfig.plist"
func SBDefaultHomePageS() -> String? {
    if let path = SBSearchFileInDirectory("com.apple.internetconfig", SBLibraryDirectory("Preferences")) {
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            if let internetConfig = NSDictionary(contentsOfFile: path) {
                if internetConfig.count > 0 {
                    return SBValueForKey("WWWHomePage", internetConfig) as? String
                }
            }
        }
    }
    return nil
}

func SBDefaultSaveDownloadedFilesToPathS() -> String? {
    if let path = SBSearchPath(.DownloadsDirectory, nil) {
        return path.stringByExpandingTildeInPath
    }
    return nil
}

func SBGraphicsPortFromContext(context: NSGraphicsContext) -> CGContext {
    let ctxPtr = COpaquePointer(context.graphicsPort)
    return Unmanaged<CGContext>.fromOpaque(ctxPtr).takeUnretainedValue()
}

var SBCurrentGraphicsPort: CGContext {
    return SBGraphicsPortFromContext(NSGraphicsContext.currentContext())
}

func SBDispatch(block: dispatch_block_t) {
    dispatch_async(dispatch_get_main_queue(), block)
}

func SBDispatchDelay(delay: Double, block: dispatch_block_t) {
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * delay))
    let queue = dispatch_get_main_queue()
    dispatch_after(time, queue, block)
}

/*
func SBCreateBookmarkItemS(title: String?, url: String?, imageData: NSData?, date: NSDate?, labelName: String?, offsetString: String?) -> BookmarkItem {
    var item = BookmarkItem()
    if title? {
        item[kSBBookmarkTitle] = title!
    }
    if url? {
        item[kSBBookmarkURL] = url!
    }
    if imageData? {
        item[kSBBookmarkImage] = imageData!
    }
    if date? {
        item[kSBBookmarkDate] = date!
    }
    if labelName? {
        item[kSBBookmarkLabelName] = labelName!
    }
    if offsetString? {
        item[kSBBookmarkOffset] = offsetString!
    }
    return item
}
*/

func SBConstrain<T: Comparable>(value: T, min minValue: T? = nil, max maxValue: T? = nil) -> T {
    var v = value
    minValue !! { v = max(v, $0) }
    maxValue !! { v = min(v, $0) }
    return v
}

func SBConstrain<T: Comparable>(inout value: T, min minValue: T? = nil, max maxValue: T? = nil) {
    value = SBConstrain(value, min: minValue, max: maxValue)
}

infix operator !! {
    associativity right
    precedence 120
}

func !!<T, U>(optional: T?, nonNilValue: @autoclosure () -> U!) -> U? {
    if optional != nil {
        return nonNilValue()
    }
    return nil
}

func !!<T, U>(optional: T?, nonNilValue: @autoclosure () -> U) -> U? {
    if optional != nil {
        return nonNilValue()
    }
    return nil
}

func !!<T, U>(optional: T?, nonNilFunc: T -> U!) -> U? {
    return optional !! nonNilFunc(optional!)
}

func !!<T, U>(optional: T?, nonNilFunc: T -> U) -> U? {
    return optional !! nonNilFunc(optional!)
}

infix operator &! {
    associativity right
    precedence 120
}

func &!<T>(optional: T?, nonNilCond: T -> Bool) -> Bool {
    return optional !! nonNilCond ?? false
}

func &!<T>(optional: T?, nonNilCond: @autoclosure () -> Bool) -> Bool {
    return optional !! nonNilCond ?? false
}

infix operator &? {
    associativity right
    precedence 120
}

func &?<T>(cond: Bool, trueFunc: @autoclosure () -> T?) -> T? {
    return cond ? trueFunc() : nil
}

// MARK: Paths

func SBRoundedPathS(inRect: CGRect, curve: CGFloat, inner: CGFloat, top: Bool, bottom: Bool) -> NSBezierPath {
    let path = NSBezierPath()
    var rect = inRect
    var point = CGPointZero
    var cp1 = CGPointZero
    var cp2 = CGPointZero
    
    rect.origin.x += inner / 2
    rect.origin.y += inner / 2
    rect.size.width -= inner
    rect.size.height -= inner
    
    if top && bottom {
        // Left-top to right
        point.x = rect.origin.x + curve
        point.y = rect.origin.y
        path.moveToPoint(point)
        point.x = rect.origin.x + rect.size.width - curve
        path.lineToPoint(point)
        point.x = rect.origin.x + rect.size.width
        cp1.x = rect.origin.x + rect.size.width
        cp1.y = rect.origin.y + curve / 2
        cp2.x = rect.origin.x + rect.size.width - curve / 2
        cp2.y = rect.origin.y
        point.y = rect.origin.y + curve
        path.curveToPoint(point, controlPoint1: cp2, controlPoint2: cp1)
        // Right-top to bottom
        point.y = rect.origin.y + rect.size.height - curve
        path.lineToPoint(point)
        point.y = rect.origin.y + rect.size.height
        cp1.y = rect.origin.y + rect.size.height
        cp1.x = rect.origin.x + rect.size.width - curve / 2
        cp2.y = rect.origin.y + rect.size.height - curve / 2
        cp2.x = rect.origin.x + rect.size.width
        point.x = rect.origin.x + rect.size.width - curve
        path.curveToPoint(point, controlPoint1: cp2, controlPoint2: cp1)
        // Right-bottom to left
        point.x = rect.origin.x + curve
        path.lineToPoint(point)
        point.x = rect.origin.x
        cp1.x = rect.origin.x
        cp1.y = rect.origin.y + rect.size.height - curve / 2;
        cp2.x = rect.origin.x + curve / 2
        cp2.y = rect.origin.y + rect.size.height
        point.y = rect.origin.y + rect.size.height - curve
        path.curveToPoint(point, controlPoint1: cp2, controlPoint2: cp1)
        // Left-bottom to top
        point.y = rect.origin.y + curve
        path.lineToPoint(point)
        point.y = rect.origin.y
        cp1.y = rect.origin.y
        cp1.x = rect.origin.x + curve / 2
        cp2.y = rect.origin.y + curve / 2
        cp2.x = rect.origin.x
        point.x = rect.origin.x + curve
        path.curveToPoint(point, controlPoint1: cp2, controlPoint2: cp1)
        // add left edge and close
        path.closePath()
    } else if top {
        point = rect.origin
        point.x = rect.origin.x + rect.size.width
        path.moveToPoint(point)
        
        point.y = rect.origin.y + rect.size.height - curve
        path.lineToPoint(point)
        point.y = rect.origin.y + rect.size.height
        cp1.y = rect.origin.y + rect.size.height
        cp1.x = rect.origin.x + rect.size.width - curve / 2
        cp2.y = rect.origin.y + rect.size.height - curve / 2
        cp2.x = rect.origin.x + rect.size.width
        point.x = rect.origin.x + rect.size.width - curve
        path.curveToPoint(point, controlPoint1: cp2, controlPoint2: cp1)
        
        point.x = rect.origin.x + curve
        path.lineToPoint(point)
        point.x = rect.origin.x
        cp1.x = rect.origin.x
        cp1.y = rect.origin.y + rect.size.height - curve / 2
        cp2.x = rect.origin.x + curve / 2
        cp2.y = rect.origin.y + rect.size.height
        point.y = rect.origin.y + rect.size.height - curve
        path.curveToPoint(point, controlPoint1: cp2, controlPoint2: cp1)
        point = rect.origin
        path.lineToPoint(point)
    } else if bottom {
        point.x = rect.origin.x
        point.y = rect.origin.y + rect.size.height
        path.moveToPoint(point)
        
        point.y = rect.origin.y + curve
        path.lineToPoint(point)
        point.y = rect.origin.y
        cp1.y = rect.origin.y
        cp1.x = rect.origin.x + curve / 2
        cp2.y = rect.origin.y + curve / 2
        cp2.x = rect.origin.x
        point.x = rect.origin.x + curve
        path.curveToPoint(point, controlPoint1: cp2, controlPoint2: cp1)
        point.x = rect.origin.x + rect.size.width - curve
        path.lineToPoint(point)
        point.x = rect.origin.x + rect.size.width
        cp1.x = rect.origin.x + rect.size.width
        cp1.y = rect.origin.y + curve / 2
        cp2.x = rect.origin.x + rect.size.width - curve / 2
        cp2.y = rect.origin.y
        point.y = rect.origin.y + curve
        path.curveToPoint(point, controlPoint1: cp2, controlPoint2: cp1)
        point.y = rect.origin.y + rect.size.height
        path.lineToPoint(point)
    } else {
        path.appendBezierPathWithRect(rect)
    }
    
    return path
}

func SBCenteredSquare(inRect: NSRect) -> NSRect {
    let side = min(inRect.size.width, inRect.size.height)
    let size = NSMakeSize(side, side)
    let origin = NSMakePoint(NSMidX(inRect) - side / 2, NSMidY(inRect) - side / 2)
    return NSRect(origin: origin, size: size)
}

// MARK: Drawing

let SBAlternateSelectedLightControlColor = NSColor.alternateSelectedControlColor().blendedColorWithFraction(0.3, ofColor: NSColor.whiteColor()).colorUsingColorSpace(NSColorSpace.genericRGBColorSpace())

let SBAlternateSelectedControlColor = NSColor.alternateSelectedControlColor().colorUsingColorSpace(NSColorSpace.genericRGBColorSpace())

let SBAlternateSelectedDarkControlColor = NSColor.alternateSelectedControlColor().blendedColorWithFraction(0.3, ofColor: NSColor.blackColor()).colorUsingColorSpace(NSColorSpace.genericRGBColorSpace())

func SBPreserveGraphicsState(block: () -> Void) {
    NSGraphicsContext.saveGraphicsState()
    block()
    NSGraphicsContext.restoreGraphicsState()
}