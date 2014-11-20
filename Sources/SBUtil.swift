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

// MARK: Get objects

var SBGetApplicationDelegate: SBApplicationDelegate {
    return NSApplication.sharedApplication().delegate as SBApplicationDelegate
}

var SBGetDocumentController: SBDocumentController {
    return SBDocumentController.sharedDocumentController() as SBDocumentController
}

var SBGetSelectedDocument: SBDocument? {
    var document: SBDocument?
    let documents = NSApplication.sharedApplication().orderedDocuments as [NSDocument]
    if documents.isEmpty {
        var error: NSError?
        document = SBGetDocumentController.openUntitledDocumentAndDisplay(true, error: &error) as? SBDocument
    } else {
        if let sbDocument = documents[0] as? SBDocument {
            document = sbDocument
        }
    }
    return document
}

var SBGetWebPreferences: WebPreferences {
    let preferences = WebPreferences(identifier: kSBWebPreferencesIdentifier)
    preferences.autosaves = true
    return preferences
}

func SBMenuWithTag(tag: Int) -> NSMenu? {
    let items = NSApplication.sharedApplication().mainMenu!.itemArray as [NSMenuItem]
    return items.first({ $0.tag == tag })?.submenu
}

func SBMenuItemWithTag(tag: Int) -> NSMenuItem? {
    let items = NSApplication.sharedApplication().mainMenu!.itemArray as [NSMenuItem]
    return items.map({ $0.submenu!.itemWithTag(tag) }).first({ $0 != nil }) !! {$0}
}

// MARK: Default values

var SBDefaultDocumentWindowRect: NSRect {
    let screens = NSScreen.screens() as [NSScreen]
    return screens.get(0)?.visibleFrame ?? NSZeroRect
}

// Return value for key in "com.apple.internetconfig.plist"
func SBDefaultHomePage() -> String? {
    if let path = SBLibraryDirectory("Preferences") !! {SBSearchFileInDirectory("com.apple.internetconfig", $0)} {
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

func SBDefaultSaveDownloadedFilesToPath() -> String? {
    return SBSearchPath(.DownloadsDirectory, nil)?.stringByExpandingTildeInPath
}

var SBDefaultBookmarks: NSDictionary? {
    let path = NSBundle.mainBundle().pathForResource("DefaultBookmark", ofType: "plist")
    if let defaultItem = path !! {NSDictionary(contentsOfFile: $0)} {
        var title = defaultItem[kSBBookmarkTitle] as? String
        var imageData = defaultItem[kSBBookmarkImage] as? NSData
        var URLString = defaultItem[kSBBookmarkURL] as? String
        title = title ?? NSLocalizedString("Untitled", comment: "")
        URLString = URLString ?? NSLocalizedString("http://www.example.com/", comment: "")
        imageData = imageData ?? SBEmptyBookmarkImageData
        let items = [SBCreateBookmarkItem(title, URLString, imageData, NSDate(), nil, NSStringFromPoint(NSZeroPoint))]
        return SBBookmarksWithItems(items)
    }
    return nil
}

var SBEmptyBookmarkImageData: NSData {
    let size = SBBookmarkImageMaxSize
    let rect = NSRect(origin: NSZeroPoint, size: size)
    let image = NSImage(size: size)

    image.withFocus {
        // Background
        var color0: NSColor!
        var color1: NSColor!
        var gradient: NSGradient!
        
        color0 = NSColor.blackColor()
        color1 = NSColor(deviceWhite: 0.75, alpha: 1.0)
        gradient = NSGradient(startingColor: color0, endingColor: color1)
        gradient.drawInRect(rect, angle: 90)
    
        color0 = NSColor(deviceWhite: 0.1, alpha: 1.0)
        color1 = NSColor(deviceWhite: 0.25, alpha: 1.0)
        gradient = NSGradient(colors: [color0, color1], atLocations: [0.5, 1.0], colorSpace: NSColorSpace.deviceGrayColorSpace())
        SBPreserveGraphicsState {
            NSRectClip(NSInsetRect(rect, 0.5, 0.5))
            gradient.drawInRect(rect, angle: 90)
        }
    
        if let paledImage = NSImage(named: "PaledApplicationIcon") {
            var r = NSZeroRect
            r.size = paledImage.size
            r.origin.x = (size.width - r.size.width) / 2
            r.origin.y = (size.height - r.size.height) / 2
            paledImage.drawInRect(r)
        }
    }
    
    return image.bitmapImageRep!.data!
}

// MARK: Bookmarks

func SBBookmarksWithItems(items: [NSDictionary]) -> [NSObject: AnyObject] {
    return [kSBBookmarkVersion: SBBookmarkVersion,
            kSBBookmarkItems: items]
}

func SBCreateBookmarkItem(title: String?, URL: String?, imageData: NSData?, date: NSDate?, labelName: String?, offsetString: String?) -> BookmarkItem {
    var item: [String: AnyObject] = [:]
    title !! { item[kSBBookmarkTitle] = $0 }
    URL !! { item[kSBBookmarkURL] = $0 }
    imageData !! { item[kSBBookmarkImage] = $0 }
    date !! { item[kSBBookmarkDate] = $0 }
    labelName !! { item[kSBBookmarkLabelName] = $0 }
    offsetString !! { item[kSBBookmarkOffset] = $0 }
    return item
}

func SBBookmarkLabelColorMenu(pullsDown: Bool, target: AnyObject?, action: Selector, representedObject: AnyObject?) -> NSMenu {
    let menu = NSMenu()
    if pullsDown {
        menu.addItemWithTitle("", action: nil, keyEquivalent: "")
    }
    for labelName in SBBookmarkLabelColorNames {
        let image = NSImage.colorImage(NSMakeSize(24.0, 16.0), colorName: labelName)
        let item = NSMenuItem(title: NSLocalizedString(labelName, comment: ""), action: action, keyEquivalent: "")
        target !! { item.target = $0 }
        representedObject !! { item.representedObject = $0 }
        item.image = image
        menu.addItem(item)
    }
    return menu
}

func SBBookmarkItemsFromBookmarkDictionaryList(bookmarkDictionaryList: [NSDictionary]) -> [NSDictionary] {
    var items: [NSDictionary] = []
    if !bookmarkDictionaryList.isEmpty {
        let emptyImageData = SBEmptyBookmarkImageData
        for dictionary in bookmarkDictionaryList {
            let type = dictionary["WebBookmarkType"] as String
            var URLString = dictionary["URLString"] as String
            let URIDictionary = dictionary["URIDictionary"] as? [NSObject: AnyObject]
            let title = URIDictionary?["title"] as? String
            var hasScheme = false
            if type == "WebBookmarkTypeLeaf" && URLString.isURLString(&hasScheme) {
                var item: [NSString: AnyObject] = [:]
                if !hasScheme { // !!!
                    URLString = "http://" + URLString.stringByDeletingScheme!
                }
                title !! { item[kSBBookmarkTitle] = $0 }
                emptyImageData !! { item[kSBBookmarkImage] = $0 }
                item[kSBBookmarkURL] = URLString
                items.append(item)
            }
        }
    }
    return items
}

// MARK: Rects

var SBBookmarkImageMaxSize: NSSize {
    let maxWidth = CGFloat(kSBBookmarkCellMaxWidth)
    return NSMakeSize(maxWidth, maxWidth / kSBBookmarkFactorForImageWidth * kSBBookmarkFactorForImageHeight)
}

// MARK: File paths

func SBFilePathInApplicationBundle(name: String, ext: String) -> String? {
    let path = NSBundle.mainBundle().pathForResource(name, ofType: ext)
    if path &! {NSFileManager.defaultManager().fileExistsAtPath($0)} {
        return path
    }
    return nil
}

func SBApplicationSupportDirectory(subdirectory: String?) -> String? {
    return SBSearchPath(.ApplicationSupportDirectory, subdirectory)
}

func SBLibraryDirectory(subdirectory: String?) -> String? {
    return SBSearchPath(.LibraryDirectory, subdirectory)
}

func SBSearchFileInDirectory(filename: String, directoryPath: String) -> String? {
    let manager = NSFileManager.defaultManager()
    let contents = manager.contentsOfDirectoryAtPath(directoryPath, error: nil) as [String]

    if let findFileName = contents.first({ $0.hasPrefix(filename) }) {
        return directoryPath.stringByAppendingPathComponent(findFileName)
    }
    return nil
}

func SBSearchPath(searchPathDirectory: NSSearchPathDirectory, subdirectory: String?) -> String? {
    let manager = NSFileManager.defaultManager()
    let paths = NSSearchPathForDirectoriesInDomains(searchPathDirectory, .UserDomainMask, true) as [NSString] as [String]
    var path = paths.get(0)
    if path &! manager.fileExistsAtPath {
        if subdirectory != nil {
            path = path!.stringByAppendingPathComponent(subdirectory!)
            if manager.fileExistsAtPath(path!) {
            } else if manager.createDirectoryAtPath(path!, withIntermediateDirectories: true, attributes: nil, error: nil) {
            } else {
                path = nil
            }
        }
    } else {
        path = nil
    }
    return path
}

var SBBookmarksFilePath: String? {
    let manager = NSFileManager.defaultManager()
    var path: String? = SBApplicationSupportDirectory(kSBApplicationSupportDirectoryName)!.stringByAppendingPathComponent(kSBBookmarksFileName)
    if manager.fileExistsAtPath(path!) {
        // Exist current bookmarks
    } else {
        var error: NSError?
        let version1Path = SBBookmarksVersion1FilePath
        
        if manager.fileExistsAtPath(version1Path) {
            // Exist version1 bookmarks
            let plistData = NSData(contentsOfFile: version1Path)!
            if let items = NSPropertyListSerialization.propertyListWithData(plistData, options: Int(NSPropertyListMutabilityOptions.Immutable.rawValue), format: nil, error: &error) as? [NSDictionary] {
                if let plistData = NSPropertyListSerialization.dataWithPropertyList(SBBookmarksWithItems(items), format: .BinaryFormat_v1_0, options: 0, error: &error) {
                    if plistData.writeToFile(path!, atomically: true) {
                    } else {
                        path = nil
                    }
                } else {
                    path = nil
                }
            }
        } else {
            // Create default bookmarks
            if let plistData = NSPropertyListSerialization.dataWithPropertyList(SBDefaultBookmarks!, format: .BinaryFormat_v1_0, options: 0, error: &error) {
                if plistData.writeToFile(path!, atomically: true) {
                } else {
                    path = nil
                }
            } else {
                path = nil
            }
            DebugLogS("\(__FUNCTION__) error = \(error)")
        }
    }
    return path
}

var SBBookmarksVersion1FilePath: String {
    let manager = NSFileManager.defaultManager()
    let path = SBApplicationSupportDirectory(kSBApplicationSupportDirectoryName_Version1)!.stringByAppendingPathComponent(kSBBookmarksFileName)
    if manager.fileExistsAtPath(path) {
        // Exist current bookmarks
    }
    return path
}

var SBHistoryFilePath: String {
    return SBApplicationSupportDirectory(kSBApplicationSupportDirectoryName)!.stringByAppendingPathComponent(kSBHistoryFileName)
}

// MARK: Paths

func SBRoundedPath(inRect: CGRect, curve: CGFloat, inner: CGFloat, top: Bool, bottom: Bool, close: Bool = false) -> NSBezierPath {
    let rect = NSInsetRect(inRect, inner / 2, inner / 2)
    
    if top && bottom {
        return NSBezierPath(roundedRect: rect, xRadius: curve, yRadius: curve)
    }
    
    let path = NSBezierPath()
    let innerRect = NSInsetRect(rect, curve, curve)
    
    if top {
        path.moveToPoint(NSMakePoint(rect.maxX, rect.minY))
        path.lineToPoint(NSMakePoint(rect.maxX, innerRect.maxY))
        path.appendBezierPathWithArcWithCenter(NSMakePoint(innerRect.maxX, innerRect.maxY), radius: curve, startAngle: 0, endAngle: 90)
        path.appendBezierPathWithArcWithCenter(NSMakePoint(innerRect.minX, innerRect.maxY), radius: curve, startAngle: 90, endAngle: 180)
        path.lineToPoint(NSMakePoint(rect.minX, rect.minY))
        if close {
            path.closePath()
        }
    } else if bottom {
        path.moveToPoint(NSMakePoint(rect.minX, rect.maxY))
        path.lineToPoint(NSMakePoint(rect.minX, innerRect.minY))
        path.appendBezierPathWithArcWithCenter(NSMakePoint(innerRect.minX, innerRect.minY), radius: curve, startAngle: 180, endAngle: 270)
        path.appendBezierPathWithArcWithCenter(NSMakePoint(innerRect.maxX, innerRect.minY), radius: curve, startAngle: 270, endAngle: 360)
        path.lineToPoint(NSMakePoint(rect.maxX, rect.maxY))
        if close {
            path.closePath()
        }
    } else {
        path.appendBezierPathWithRect(rect)
    }
    
    return path
}

func SBLeftButtonPath(size: NSSize) -> NSBezierPath {
    let path = NSBezierPath()
    var p = NSZeroPoint
    var cp1 = NSZeroPoint
    var cp2 = NSZeroPoint
    let curve: CGFloat = 4.0
    
    p.x = size.width
    p.y = 0.5
    path.moveToPoint(p)
    p.x = curve + 1.0
    path.lineToPoint(p)
    p.x = 0.5
    cp1.x = 0.5
    cp1.y = 0.5 + curve / 2
    cp2.x = curve / 2 + 0.5
    cp2.y = 0.5
    p.y = curve + 0.5
    path.curveToPoint(p, controlPoint1: cp2, controlPoint2: cp1)
    p.y = size.height - curve - 0.5
    path.lineToPoint(p)
    p.x = curve + 0.5
    cp2.x = 0.5
    cp2.y = size.height - curve / 2 - 0.5
    cp1.x = curve / 2 + 0.5
    cp1.y = size.height - 0.5
    p.y = size.height - 0.5
    path.curveToPoint(p, controlPoint1: cp2, controlPoint2: cp1)
    p.x = size.width
    path.lineToPoint(p)
    p.y = 0.5
    path.lineToPoint(p)
    
    return path
}

func SBCenterButtonPath(size: NSSize) -> NSBezierPath {
    return NSBezierPath(rect: NSInsetRect(NSRect(origin: NSZeroPoint, size: size), 0.5, 0.5))
}

func SBRightButtonPath(size: NSSize) -> NSBezierPath {
    let path = NSBezierPath()
    var p = NSZeroPoint
    var cp1 = NSZeroPoint
    var cp2 = NSZeroPoint
    let curve: CGFloat = 4.0
    
    p.x = 0.5
    p.y = 0.5
    path.moveToPoint(p)
    p.x = size.width - curve - 1.0
    path.lineToPoint(p)
    p.x = size.width - 1.0
    cp1.x = size.width - 0.5
    cp1.y = 0.5 + curve / 2
    cp2.x = size.width - curve / 2 - 1.0
    cp2.y = 0.5
    p.y = curve + 0.5
    path.curveToPoint(p, controlPoint1: cp2, controlPoint2: cp1)
    p.y = size.height - curve - 1.0
    path.lineToPoint(p)
    p.x = size.width - curve - 1.0
    cp2.x = size.width - 1.0
    cp2.y = size.height - curve / 2 - 1.0
    cp1.x = size.width - curve / 2 - 1.0
    cp1.y = size.height - 0.5
    p.y = size.height - 0.5
    path.curveToPoint(p, controlPoint1: cp2, controlPoint2: cp1)
    p.x = 0.5
    path.lineToPoint(p)
    p.y = 0.5
    path.lineToPoint(p)
    
    return path
}

enum SBTriangleDirection {
    case Left, Top, Right, Bottom
}

func SBTrianglePath(rect: NSRect, direction: SBTriangleDirection) -> NSBezierPath {
    let path = NSBezierPath()
    var p = NSZeroPoint
    
    switch direction {
        case .Left:
            p.x = rect.maxX
            p.y = rect.minY
            path.moveToPoint(p)
            p.y = rect.maxY
            path.lineToPoint(p)
            p.x = rect.minX
            p.y = rect.midY
            path.lineToPoint(p)
            p.x = rect.maxX
            p.y = rect.minY
            path.lineToPoint(p)
        case .Top:
            p.x = rect.minX
            p.y = rect.maxY
            path.moveToPoint(p)
            p.x = rect.maxX
            path.lineToPoint(p)
            p.x = rect.midX
            p.y = rect.minY
            path.lineToPoint(p)
            p.x = rect.minX
            p.y = rect.maxY
            path.lineToPoint(p)
        case .Right:
            p.x = rect.minX
            p.y = rect.minY
            path.moveToPoint(p)
            p.y = rect.maxY
            path.lineToPoint(p)
            p.x = rect.maxX
            p.y = rect.midY
            path.lineToPoint(p)
            p.x = rect.minX
            p.y = rect.minY
            path.lineToPoint(p)
        case .Bottom:
            p.x = rect.minX
            p.y = rect.minY
            path.moveToPoint(p)
            p.x = rect.maxX
            path.lineToPoint(p)
            p.x = rect.midX
            p.y = rect.maxY
            path.lineToPoint(p)
            p.x = rect.minX
            p.y = rect.minY
            path.lineToPoint(p)
    }
    
    return path
}

func SBEllipsePath3D(r: NSRect, transform: CATransform3D) -> NSBezierPath {
    let path = NSBezierPath()
    var p = NSZeroPoint
    var cp1 = NSZeroPoint
    var cp2 = NSZeroPoint
    
    p.x = r.midX
    p.y = r.origin.y
    SBCGPointApplyTransform3D(&p, transform)
    path.moveToPoint(p)
    p.x = r.origin.x
    p.y = r.midY
    cp1.x = r.origin.x + r.size.width / 4
    cp1.y = r.origin.y
    cp2.x = r.origin.x
    cp2.y = r.origin.y + r.size.height / 4
    SBCGPointApplyTransform3D(&p, transform)
    SBCGPointApplyTransform3D(&cp1, transform)
    SBCGPointApplyTransform3D(&cp1, transform)
    path.curveToPoint(p, controlPoint1: cp1, controlPoint2: cp2)
    p.x = r.midX
    p.y = r.maxY
    cp1.x = r.origin.x
    cp1.y = r.origin.y + r.size.height / 4 * 3
    cp2.x = r.origin.x + r.size.width / 4
    cp2.y = r.maxY
    SBCGPointApplyTransform3D(&p, transform)
    SBCGPointApplyTransform3D(&cp1, transform)
    SBCGPointApplyTransform3D(&cp1, transform)
    path.curveToPoint(p, controlPoint1: cp1, controlPoint2: cp2)
    p.x = r.maxX
    p.y = r.midY
    cp1.x = r.origin.x + r.size.width / 4 * 3
    cp1.y = r.maxY
    cp2.x = r.maxX
    cp2.y = r.origin.y + r.size.height / 4 * 3
    SBCGPointApplyTransform3D(&p, transform)
    SBCGPointApplyTransform3D(&cp1, transform)
    SBCGPointApplyTransform3D(&cp1, transform)
    path.curveToPoint(p, controlPoint1: cp1, controlPoint2: cp2)
    p.x = r.midX
    p.y = r.origin.y
    cp1.x = r.maxX
    cp1.y = r.origin.y + r.size.height / 4
    cp2.x = r.origin.x + r.size.width / 4 * 3
    cp2.y = r.origin.y
    SBCGPointApplyTransform3D(&p, transform)
    SBCGPointApplyTransform3D(&cp1, transform)
    SBCGPointApplyTransform3D(&cp1, transform)
    path.curveToPoint(p, controlPoint1: cp1, controlPoint2: cp2)
    
    return path
}

func SBRoundedPath3D(rect: NSRect, curve: CGFloat, transform: CATransform3D) -> NSBezierPath {
    let path = NSBezierPath()
    var p = NSZeroPoint
    var cp1 = NSZeroPoint
    var cp2 = NSZeroPoint
    
    // line left-top to right-top
    p.x = rect.origin.x + curve
    p.y = rect.origin.y;
    SBCGPointApplyTransform3D(&p, transform)
    path.moveToPoint(p)
    p.x = (rect.origin.x + rect.size.width - curve)
    p.y = rect.origin.y
    SBCGPointApplyTransform3D(&p, transform)
    path.lineToPoint(p)
    p.x = rect.origin.x + rect.size.width
    cp1.x = rect.origin.x + rect.size.width
    cp1.y = rect.origin.y + curve / 2
    cp2.x = (rect.origin.x + rect.size.width) - curve / 2
    cp2.y = rect.origin.y
    p.y = rect.origin.y + curve
    SBCGPointApplyTransform3D(&p, transform)
    SBCGPointApplyTransform3D(&cp1, transform)
    SBCGPointApplyTransform3D(&cp2, transform)
    path.curveToPoint(p, controlPoint1: cp2, controlPoint2: cp1)
    
    p.x = rect.origin.x + rect.size.width
    p.y = rect.origin.y + rect.size.height - curve
    SBCGPointApplyTransform3D(&p, transform)
    path.lineToPoint(p)
    p.x = rect.origin.x + rect.size.width - curve
    p.y = rect.origin.y + rect.size.height
    cp1.y = rect.origin.y + rect.size.height
    cp1.x = (rect.origin.x + rect.size.width) - curve / 2
    cp2.y = (rect.origin.y + rect.size.height) - curve / 2
    cp2.x = rect.origin.x + rect.size.width
    SBCGPointApplyTransform3D(&p, transform)
    SBCGPointApplyTransform3D(&cp1, transform)
    SBCGPointApplyTransform3D(&cp2, transform)
    path.curveToPoint(p, controlPoint1: cp2, controlPoint2: cp1)
    
    p.x = rect.origin.x + curve
    p.y = rect.origin.y + rect.size.height
    SBCGPointApplyTransform3D(&p, transform)
    path.lineToPoint(p)
    p.x = rect.origin.x
    cp1.x = rect.origin.x
    cp1.y = (rect.origin.y + rect.size.height) - curve / 2
    cp2.x = rect.origin.x + curve / 2
    cp2.y = (rect.origin.y + rect.size.height)
    p.y = rect.origin.y + rect.size.height - curve
    SBCGPointApplyTransform3D(&p, transform)
    SBCGPointApplyTransform3D(&cp1, transform)
    SBCGPointApplyTransform3D(&cp2, transform)
    path.curveToPoint(p, controlPoint1: cp2, controlPoint2: cp1)
    
    p.x = rect.origin.x
    p.y = rect.origin.y + curve
    SBCGPointApplyTransform3D(&p, transform)
    path.lineToPoint(p)
    p.y = rect.origin.y
    cp1.y = rect.origin.y
    cp1.x = rect.origin.x + curve / 2
    cp2.y = rect.origin.y + curve / 2
    cp2.x = rect.origin.x
    p.x = rect.origin.x + curve
    SBCGPointApplyTransform3D(&p, transform)
    SBCGPointApplyTransform3D(&cp1, transform)
    SBCGPointApplyTransform3D(&cp2, transform)
    path.curveToPoint(p, controlPoint1: cp2, controlPoint2: cp1)
    
    return path
}

func SBCGPointApplyTransform3D(inout p: NSPoint, t: CATransform3D) {
    let px = p.x
    let py = p.y
    let w = px * t.m14 + py * t.m24 + t.m44
    p.x = (px * t.m11 + py * t.m21 + t.m41) / w
    p.y = (px * t.m12 + py * t.m22 + t.m42) / w
}

func SBCenteredSquare(inRect: NSRect) -> NSRect {
    let side = min(inRect.size.width, inRect.size.height)
    let size = NSMakeSize(side, side)
    let origin = NSMakePoint(inRect.midX - side / 2, inRect.midY - side / 2)
    return NSRect(origin: origin, size: size)
}

// MARK: Drawing

let SBAlternateSelectedLightControlColor = NSColor.alternateSelectedControlColor().blendedColorWithFraction(0.3, ofColor: NSColor.whiteColor())!.colorUsingColorSpace(NSColorSpace.genericRGBColorSpace())!

let SBAlternateSelectedControlColor = NSColor.alternateSelectedControlColor().colorUsingColorSpace(NSColorSpace.genericRGBColorSpace())!

let SBAlternateSelectedDarkControlColor = NSColor.alternateSelectedControlColor().blendedColorWithFraction(0.3, ofColor: NSColor.blackColor())!.colorUsingColorSpace(NSColorSpace.genericRGBColorSpace())!

func SBPreserveGraphicsState(block: () -> Void) {
    NSGraphicsContext.saveGraphicsState()
    block()
    NSGraphicsContext.restoreGraphicsState()
}

func SBGraphicsPortFromContext(context: NSGraphicsContext) -> CGContext {
    let ctxPtr = COpaquePointer(context.graphicsPort)
    return Unmanaged<CGContext>.fromOpaque(ctxPtr).takeUnretainedValue()
}

var SBCurrentGraphicsPort: CGContext {
    return SBGraphicsPortFromContext(NSGraphicsContext.currentContext()!)
}

// MARK: Image

func SBBackwardIconImage(size: NSSize, enabled: Bool, backing: Bool) -> NSImage {
    let tPath = SBTrianglePath(NSMakeRect(9.0, 7.0, size.width - 9.0 * 2, size.height - 7.0 * 2), .Left)
    let tGray: CGFloat = enabled ? 0.2 : 0.5
    let rect = NSRect(origin: NSZeroPoint, size: size)
    
    let image = NSImage(size: size)
    image.withFocus {
        let transform = NSAffineTransform()
        transform.translateXBy(0.0, yBy: size.height)
        transform.scaleXBy(1.0, yBy: -1.0)
        transform.concat()
        
        let path = SBLeftButtonPath(size)
        
        // Background
        let color0 = NSColor(deviceWhite: backing ? 0.95 : 0.8, alpha: 1.0)
        let color1 = NSColor(deviceWhite: backing ? 0.65 : 0.5, alpha: 1.0)
        let gradient = NSGradient(startingColor: color0, endingColor: color1)
        SBPreserveGraphicsState {
            path.addClip()
            gradient.drawInRect(rect, angle: 90)
        }
        
        // Frame
        NSColor(deviceWhite: 0.2, alpha: 1.0).set()
        path.lineWidth = 0.5
        path.stroke()
        
        // Triangle
        NSColor(deviceWhite: tGray, alpha: 1.0).set()
        tPath.fill()
    }
    
    return image
}

func SBForwardIconImage(size: NSSize, enabled: Bool, backing: Bool) -> NSImage {
    let tPath = SBTrianglePath(NSMakeRect(9.0, 7.0, size.width - 9.0 * 2, size.height - 7.0 * 2), .Right)
    let tGray: CGFloat = enabled ? 0.2 : 0.5
    let rect = NSRect(origin: NSZeroPoint, size: size)
    
    let image = NSImage(size: size)
    image.withFocus {
        let transform = NSAffineTransform()
        transform.translateXBy(0.0, yBy: size.height)
        transform.scaleXBy(1.0, yBy: -1.0)
        transform.concat()
        
        let path = SBCenterButtonPath(size)
        
        // Background
        let color0 = NSColor(deviceWhite: backing ? 0.95 : 0.8, alpha: 1.0)
        let color1 = NSColor(deviceWhite: backing ? 0.65 : 0.5, alpha: 1.0)
        let gradient = NSGradient(startingColor: color0, endingColor: color1)
        SBPreserveGraphicsState {
            path.addClip()
            gradient.drawInRect(rect, angle: 90)
        }
        
        // Frame
        NSColor(deviceWhite: 0.2, alpha: 1.0).set()
        path.lineWidth = 0.5
        path.stroke()
        
        // Triangle
        NSColor(deviceWhite: tGray, alpha: 1.0).set()
        tPath.fill()
    }
    
    return image
}

func SBGoIconImage(size: NSSize, enabled: Bool, backing: Bool) -> NSImage {
    let rect = NSRect(origin: NSZeroPoint, size: size)
    
    let image = NSImage(size: size)
    image.withFocus {
        let transform = NSAffineTransform()
        transform.translateXBy(0.0, yBy: size.height)
        transform.scaleXBy(1.0, yBy: -1.0)
        transform.concat()
        
        let path = SBRightButtonPath(size)
        
        // Background
        var colors = (backing
                     ? [NSColor(deviceWhite: 0.95, alpha: 1.0), NSColor(deviceWhite: 0.65, alpha: 1.0)]
                     : [SBAlternateSelectedLightControlColor, SBAlternateSelectedControlColor])
        if !enabled {
            colors = colors.map { $0.colorWithAlphaComponent(0.5) }
        }
        
        let gradient = NSGradient(startingColor: colors[0], endingColor: colors[1])
        SBPreserveGraphicsState {
            path.addClip()
            gradient.drawInRect(rect, angle: 90)
        }
        
        // Frame
        NSColor(deviceWhite: 0.2, alpha: 1.0).set()
        path.lineWidth = 0.5
        path.stroke()
    }
    
    return image
}

func SBZoomOutIconImage(size: NSSize) -> NSImage {
    let image = NSImage(size: size)
    image.withFocus {
        var r = NSZeroRect
        
        // Frame
        if let frameImage = NSImage(named: "LeftButton") {
            r.size = frameImage.size
            r.origin.x = (size.width - r.size.width) / 2
            r.origin.y = (size.height - r.size.height) / 2
            frameImage.drawInRect(r, fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1.0)
        }
        
        // Image
        if let iconImage = NSImage(named: "ZoomOut") {
            r.size = iconImage.size
            r.origin.x = (size.width - r.size.width) / 2
            r.origin.y = (size.height - r.size.height) / 2
            iconImage.drawInRect(r, fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1.0)
        }
    }
    
    return image
}

func SBActualSizeIconImage(size: NSSize) -> NSImage {
    let image = NSImage(size: size)
    image.withFocus {
        var r = NSZeroRect
        
        // Frame
        if let frameImage = NSImage(named: "CenterButton") {
            r.size = frameImage.size
            r.origin.x = (size.width - r.size.width) / 2
            r.origin.y = (size.height - r.size.height) / 2
            frameImage.drawInRect(r, fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1.0)
        }
        
        // Image
        if let iconImage = NSImage(named: "ActualSize") {
            r.size = iconImage.size
            r.origin.x = (size.width - r.size.width) / 2
            r.origin.y = (size.height - r.size.height) / 2
            iconImage.drawInRect(r, fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1.0)
        }
    }
    
    return image
}

func SBZoomInIconImage(size: NSSize) -> NSImage {
    let image = NSImage(size: size)
    image.withFocus {
        var r = NSZeroRect
        
        // Frame
        if let frameImage = NSImage(named: "RightButton") {
            r.size = frameImage.size
            r.origin.x = (size.width - r.size.width) / 2
            r.origin.y = (size.height - r.size.height) / 2
            frameImage.drawInRect(r, fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1.0)
        }
        
        // Image
        if let iconImage = NSImage(named: "ZoomIn") {
            r.size = iconImage.size
            r.origin.x = (size.width - r.size.width) / 2
            r.origin.y = (size.height - r.size.height) / 2
            iconImage.drawInRect(r, fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1.0)
        }
    }
    
    return image
}

func SBAddIconImage(size: NSSize, backing: Bool) -> NSImage {
    let rect = NSRect(origin: NSZeroPoint, size: size)
    var p = CGPointZero
    var cp1 = CGPointZero
    var cp2 = CGPointZero
    let curve: CGFloat = 4.0
    let margin: CGFloat = 7.0
    
    let image = NSImage(size: size)
    image.withFocus {
        let transform = NSAffineTransform()
        transform.translateXBy(0.0, yBy: size.height)
        transform.scaleXBy(1.0, yBy: -1.0)
        transform.concat()
        
        var path = NSBezierPath()
        p.y = 1.0
        path.moveToPoint(p)
        p.x = size.width - curve
        path.lineToPoint(p)
        p.x = size.width
        cp1.x = size.width
        cp1.y = 1.0 + curve / 2
        cp2.x = size.width - curve / 2
        cp2.y = 1.0
        p.y = 1.0 + curve
        path.curveToPoint(p, controlPoint1: cp2, controlPoint2: cp1)
        p.y = size.height
        path.lineToPoint(p)
        p.x = 0.0
        path.lineToPoint(p)
        
        if !backing {
            // Background
            let color0 = NSColor(deviceWhite: 0.6, alpha: 1.0)
            let color1 = NSColor(deviceWhite: 0.55, alpha: 1.0)
            let gradient = NSGradient(startingColor: color0, endingColor: color1)
            SBPreserveGraphicsState {
                path.addClip()
                gradient.drawInRect(rect, angle: 90)
            }
        }
        
        // Frame
        NSColor(deviceWhite: 0.2, alpha: 1.0).set()
        path.lineWidth = 0.5
        path.stroke()
        
        // Cross
        NSColor(deviceWhite: 0.3, alpha: 1.0).set()
        
        path = NSBezierPath()
        p.x = size.width / 2
        p.y = margin - 1.0
        path.moveToPoint(p)
        p.y = size.height / 2
        path.lineToPoint(p)
        path.lineWidth = 3.0
        path.stroke()
        
        path = NSBezierPath()
        p.x = margin - 1.0
        p.y = size.height / 2 - 1.0
        path.moveToPoint(p)
        p.x = size.width - margin + 1.0
        path.lineToPoint(p)
        path.lineWidth = 2.0
        path.stroke()
        
        NSColor(deviceWhite: 0.75, alpha: 1.0).set()
        
        path = NSBezierPath()
        p.x = size.width / 2
        p.y = size.height / 2
        path.moveToPoint(p)
        p.y = size.height - margin + 1.0
        path.lineToPoint(p)
        path.lineWidth = 3.0
        path.stroke()
        
        path = NSBezierPath()
        p.x = margin - 1.0
        p.y = size.height / 2 + 1.0
        path.moveToPoint(p)
        p.x = size.width - margin + 1.0
        path.lineToPoint(p)
        path.lineWidth = 2.0
        path.stroke()
        
        NSColor(deviceWhite: backing ? 0.7 : 0.5, alpha: 1.0).set()
        
        path = NSBezierPath()
        p.x = size.width / 2
        p.y = margin
        path.moveToPoint(p)
        p.y = size.height - margin
        path.lineToPoint(p)
        p.x = margin
        p.y = size.height / 2
        path.moveToPoint(p)
        p.x = size.width - margin
        path.lineToPoint(p)
        path.lineWidth = 3.0
        path.stroke()
    }
    
    return image
}

func SBCloseIconImage() -> NSImage {
    let size = NSMakeSize(17.0, 17.0)
    
    let image = NSImage(size: size)
    image.withFocus {
        var transform = NSAffineTransform()
        transform.translateXBy(0.0, yBy: size.height)
        transform.scaleXBy(1.0, yBy: -1.0)
        transform.concat()
        
        let side = size.width
        let r = NSMakeRect((size.width - side) / 2, (size.height - side) / 2, side, side)
        let xPath = NSBezierPath()
        var p = NSZeroPoint
        var across = r.size.width
        var length: CGFloat = 11.0
        var margin = r.origin.x
        var lineWidth: CGFloat = 2
        var center = margin + across / 2
        var grayScaleUp: CGFloat = 1.0
        
        transform = NSAffineTransform()
        transform.translateXBy(center, yBy: center)
        transform.rotateByDegrees(-45)
        p.x = -length / 2
        xPath.moveToPoint(transform.transformPoint(p))
        p.x = length / 2
        xPath.lineToPoint(transform.transformPoint(p))
        p.x = 0
        p.y = -length / 2
        xPath.moveToPoint(transform.transformPoint(p))
        p.y = length / 2
        xPath.lineToPoint(transform.transformPoint(p))
        
        // Close
        NSColor(deviceWhite: grayScaleUp, alpha: 1.0).set()
        xPath.lineWidth = lineWidth
        xPath.stroke()
    }
    
    return image
}

func SBIconImageWithName(imageName: String, shape: SBButtonShape, size: NSSize) -> NSImage {
    return SBIconImage(NSImage(named: imageName), shape, size)
}

func SBIconImage(iconImage: NSImage?, shape: SBButtonShape, size: NSSize) -> NSImage {
    let imageSize = iconImage?.size ?? NSZeroSize
    var imageRect = NSMakeRect((size.width - imageSize.width) / 2, (size.height - imageSize.height) / 2, imageSize.width, imageSize.height)
    
    let image = NSImage(size: size)
    image.withFocus {
        let transform = NSAffineTransform()
        transform.translateXBy(0.0, yBy: size.height)
        transform.scaleXBy(1.0, yBy: -1.0)
        transform.concat()
        
        // Frame
        //{
            var insetMargin: CGFloat = 3.0
            let lineWidth: CGFloat = 2.0
            let path = NSBezierPath()
            var insetRect = NSRect(origin: NSZeroPoint, size: size)
            
            switch shape {
                case .Exclusive:
                    insetMargin = 4.0
                    insetRect = NSInsetRect(insetRect, insetMargin, insetMargin)
                    path.appendBezierPathWithOvalInRect(insetRect)
                case .Left:
                    var p = NSZeroPoint
                    var cp1 = NSZeroPoint
                    var cp2 = NSZeroPoint
                    var rad: CGFloat = 0
                    
                    insetRect.origin.x += insetMargin
                    insetRect.origin.y += insetMargin
                    insetRect.size.width -= insetMargin
                    insetRect.size.height -= insetMargin * 2
                    rad = insetRect.size.height / 2
                    
                    p.x = insetRect.maxX + lineWidth / 4
                    p.y = insetRect.origin.y
                    path.moveToPoint(p)
                    p.x = insetRect.origin.x + rad
                    path.lineToPoint(p)
                    
                    p.x = insetRect.origin.x
                    cp1.x = insetRect.origin.x
                    cp1.y = insetRect.origin.y + rad / 2
                    cp2.x = insetRect.origin.x + rad / 2
                    cp2.y = insetRect.origin.y
                    p.y = insetRect.origin.y + rad
                    path.curveToPoint(p, controlPoint1: cp2, controlPoint2: cp1)
                    
                    p.x = insetRect.origin.x + rad
                    cp2.x = insetRect.origin.x
                    cp2.y = insetRect.maxY - rad / 2
                    cp1.x = insetRect.origin.x + rad / 2
                    cp1.y = insetRect.maxY
                    p.y = insetRect.maxY
                    path.curveToPoint(p, controlPoint1: cp2, controlPoint2: cp1)
                    
                    p.x = insetRect.maxX + lineWidth / 4
                    path.lineToPoint(p)
                    
                    path.closePath()
                    
                    imageRect.origin.x += insetMargin
                case .Center:
                    insetRect.origin.y += insetMargin
                    insetRect.size.height -= insetMargin * 2
                    path.appendBezierPathWithRect(insetRect)
                case .Right:
                    var p = NSZeroPoint
                    var cp1 = NSZeroPoint
                    var cp2 = NSZeroPoint
                    var rad: CGFloat = 0
                    
                    insetRect.origin.y += insetMargin
                    insetRect.size.width -= insetMargin
                    insetRect.size.height -= insetMargin * 2
                    rad = insetRect.size.height / 2
                    
                    p.x = insetRect.origin.x - lineWidth / 4
                    p.y = insetRect.origin.y
                    path.moveToPoint(p)
                    p.x = insetRect.maxX - rad
                    path.lineToPoint(p)
                    
                    p.x = insetRect.maxX
                    cp1.x = insetRect.maxX
                    cp1.y = insetRect.minY + rad / 2
                    cp2.x = insetRect.maxX - rad / 2
                    cp2.y = insetRect.minY
                    p.y = insetRect.minY + rad
                    path.curveToPoint(p, controlPoint1: cp2, controlPoint2: cp1)
                    
                    p.x = insetRect.maxX - rad
                    cp2.x = insetRect.maxX
                    cp2.y = insetRect.maxY - rad / 2
                    cp1.x = insetRect.maxX - rad / 2
                    cp1.y = insetRect.maxY
                    p.y = insetRect.maxY
                    path.curveToPoint(p, controlPoint1: cp2, controlPoint2: cp1)
                    
                    p.x = insetRect.origin.x - lineWidth / 4
                    path.lineToPoint(p)
                    
                    path.closePath()
                    
                    imageRect.origin.x -= insetMargin / 2
            }
            let shadowColor = NSColor.blackColor()
            
            // Fill
            let shadow = NSShadow()
            shadow.shadowColor = shadowColor
            shadow.shadowBlurRadius = insetMargin
            shadow.shadowOffset = NSZeroSize
            SBPreserveGraphicsState {
                shadow.set()
                NSColor.blackColor().set()
                path.fill()
            }
            
            // Stroke
            NSColor(deviceWhite: 0.9, alpha: 1.0).set()
            path.lineWidth = lineWidth
            path.stroke()
        //}
        
        // Icon
        if iconImage != nil {
            SBPreserveGraphicsState {
                let transform = NSAffineTransform()
                transform.translateXBy(0.0, yBy: size.height)
                transform.scaleXBy(1.0, yBy: -1.0)
                transform.concat()
                iconImage!.drawInRect(imageRect)
            }
        }
    }
    
    return image
}

func SBFindBackwardIconImage(size: NSSize, enabled: Bool) -> NSImage {
    let rect = NSRect(origin: NSZeroPoint, size: size)
    let tPath = SBTrianglePath(NSMakeRect(9.0, 5.0, size.width - 9.0 * 2, size.height - 5.0 * 2), .Left)
    var p = NSZeroPoint
    var cp1 = NSZeroPoint
    var cp2 = NSZeroPoint
    let curve = size.height / 2
    let tGray: CGFloat = enabled ? 0.9 : 0.5
    
    let image = NSImage(size: size)
    image.withFocus {
        let transform = NSAffineTransform()
        transform.translateXBy(0.0, yBy: size.height)
        transform.scaleXBy(1.0, yBy: -1.0)
        transform.concat()
        
        let path = NSBezierPath()
        p.x = size.width
        p.y = 0.5
        path.moveToPoint(p)
        p.x = curve + 1.0
        path.lineToPoint(p)
        p.x = 0.5
        cp1.x = 0.5
        cp1.y = 0.5 + curve / 2
        cp2.x = curve / 2 + 0.5
        cp2.y = 0.5
        p.y = curve + 0.5
        path.curveToPoint(p, controlPoint1: cp2, controlPoint2: cp1)
        p.x = curve + 0.5
        cp2.x = 0.5
        cp2.y = size.height - curve / 2 - 0.5
        cp1.x = curve / 2 + 0.5
        cp1.y = size.height - 0.5
        p.y = size.height - 0.5
        path.curveToPoint(p, controlPoint1: cp2, controlPoint2: cp1)
        p.x = size.width
        path.lineToPoint(p)
        p.y = 0.5
        path.lineToPoint(p)
        
        // Background
        let colors = [NSColor(deviceWhite: 0.5, alpha: 1.0), NSColor.blackColor()]
        let gradient = NSGradient(startingColor: colors[0], endingColor: colors[1])
        SBPreserveGraphicsState {
            path.addClip()
            gradient.drawInRect(rect, angle: 90)
        }
        
        // Frame
        NSColor.blackColor().set()
        path.lineWidth = 0.5
        path.stroke()
        
        // Triangle
        NSColor(deviceWhite: tGray, alpha: 1.0).set()
        tPath.lineWidth = 0.5
        tPath.fill()
    }
    
    return image
}

func SBFindForwardIconImage(size: NSSize, enabled: Bool) -> NSImage {
    let rect = NSRect(origin: NSZeroPoint, size: size)
    let tPath = SBTrianglePath(NSMakeRect(9.0, 5.0, size.width - 9.0 * 2, size.height - 5.0 * 2), .Right)
    var p = NSZeroPoint
    var cp1 = NSZeroPoint
    var cp2 = NSZeroPoint
    let curve = size.height / 2
    let tGray: CGFloat = enabled ? 0.9 : 0.5
    
    let image = NSImage(size: size)
    image.withFocus {
        let transform = NSAffineTransform()
        transform.translateXBy(0.0, yBy: size.height)
        transform.scaleXBy(1.0, yBy: -1.0)
        transform.concat()
        
        let path = NSBezierPath()
        p.x = 0.0
        p.y = 0.5
        path.moveToPoint(p)
        p.x = size.width - (curve + 1.0)
        path.lineToPoint(p)
        p.x = size.width
        cp1.x = size.width
        cp1.y = 0.5 + curve / 2
        cp2.x = size.width - curve / 2
        cp2.y = 0.5
        p.y = curve + 0.5
        path.curveToPoint(p, controlPoint1: cp2, controlPoint2: cp1)
        p.x = size.width - curve
        cp2.x = size.width
        cp2.y = size.height - curve / 2 - 0.5
        cp1.x = size.width - curve / 2
        cp1.y = size.height - 0.5
        p.y = size.height - 0.5
        path.curveToPoint(p, controlPoint1: cp2, controlPoint2: cp1)
        p.x = 0.0
        path.lineToPoint(p)
        p.y = 0.5
        path.lineToPoint(p)
        
        // Background
        let colors = [NSColor(deviceWhite: 0.5, alpha: 1.0), NSColor.blackColor()]
        let gradient = NSGradient(startingColor: colors[0], endingColor: colors[1])
        SBPreserveGraphicsState {
            path.addClip()
            gradient.drawInRect(rect, angle: 90)
        }
        
        // Frame
        NSColor.blackColor().set()
        path.lineWidth = 0.5
        path.stroke()
        
        // Triangle
        NSColor(deviceWhite: tGray, alpha: 1.0).set()
        tPath.lineWidth = 0.5
        tPath.fill()
    }
    
    return image
}

func SBBookmarkReflectionMaskImage(size: NSSize) -> NSImage {
    let rect = NSRect(origin: NSZeroPoint, size: size)
    let image = NSImage(size: size)
    image.withFocus {
        let colors = [NSColor(deviceWhite: 1.0, alpha: 0.2), NSColor(deviceWhite: 1.0, alpha: 0.0)]
        let gradient = NSGradient(startingColor: colors[0], endingColor: colors[1])
        gradient.drawInRect(rect, angle: 90)
    }
    return image
}

// MARK: Math

func SBRemainder(value1: Int, value2: Int) -> Int {
    return value1 - (value1 / value2) * value2
}

func SBRemainderIsZero(value1: Int, value2: Int) -> Bool {
    return SBRemainder(value1, value2) == 0
}

func SBGreatestCommonDivisor(a: Int, b: Int) -> Int {
    //!!!
    var v = 0
    if a == 0 || b == 0 {
        v = 0
    } else {
        // Euclidean
        var (x, y) = (a, b)
        while x != y {
            if x > y {
                x -= y
            } else {
                y -= x
            }
        }
    }
    return v
}

// MARK: Others

func SBValueForKey(keyName: String, dictionary: [NSObject: AnyObject]) -> AnyObject? {
    var value: AnyObject? = dictionary[keyName]
    if value == nil  {
        for object in dictionary.values {
            if let object = object as? [NSObject: AnyObject] {
                value = SBValueForKey(keyName, object)
            }
        }
    } else if let dict = value as? [NSObject: AnyObject] {
        value = dict.values.first
    }
    return value
}

func SBEncodingMenu(target: AnyObject?, selector: Selector, showDefault: Bool) -> NSMenu {
    let menu = NSMenu()
    var encs: [NSStringEncoding?]!
    if kSBFlagShowAllStringEncodings {
        let encPtr = NSString.availableStringEncodings()
        var mEncs: [NSStringEncoding] = []
        for var enc = encPtr; enc.memory != 0; enc = enc.successor() {
            mEncs.append(enc.memory)
        }
        mEncs.sort(SBStringEncodingSortFunction)
        encs = mEncs.map { $0 }
    } else {
        encs = SBAvailableStringEncodings
    }
    
    // Create menu items
    for enc in encs {
        if let enc = enc {
            let encodingName = NSString.localizedNameOfStringEncoding(enc)
            let cfEncoding = CFStringConvertNSStringEncodingToEncoding(enc)
            let ianaName = CFStringConvertEncodingToIANACharSetName(cfEncoding) as NSString
            let available = CFStringIsEncodingAvailable(cfEncoding)
            let cfEncodingName = CFStringGetNameOfEncoding(cfEncoding)
            DebugLogS("\(available)\t\(enc)\t\(encodingName)\t\(cfEncodingName)\t\(ianaName)")
            if encodingName != "" {
                let item = NSMenuItem(title: encodingName, action: selector, keyEquivalent: "")
                target !! { item.target = $0 }
                item.representedObject = ianaName
                menu.addItem(item)
            }
        } else {
            menu.addItem(NSMenuItem.separatorItem())
        }
    }
    
    if showDefault {
        let defaultItem = NSMenuItem(title: NSLocalizedString("Default", comment: ""), action: selector, keyEquivalent: "")
        target !! { defaultItem.target = $0 }
        defaultItem.representedObject = nil
        menu.insertItem(NSMenuItem.separatorItem(), atIndex: 0)
        menu.insertItem(defaultItem, atIndex: 0)
    }
    
    return menu
}

func SBStringEncodingSortFunction(num1: NSStringEncoding, num2: NSStringEncoding) -> Bool {
    let enc1 = NSString.localizedNameOfStringEncoding(num1)
    let enc2 = NSString.localizedNameOfStringEncoding(num2)
    return enc1 < enc2
}

func SBRunAlertWithMessage(message: String) {
    let alert = NSAlert()
    alert.messageText = NSLocalizedString("Error", comment: "")
    alert.informativeText = message
    alert.addButtonWithTitle(NSLocalizedString("OK", comment: ""))
    alert.runModal()
}

func SBDisembedViewInSplitView(view: NSView, splitView: NSSplitView) {
    let r = splitView.frame
    if let superview = splitView.superview {
        view.frame = r
        view.removeFromSuperview()
        superview.addSubview(view)
        splitView.removeFromSuperview()
    }
}

func SBDistancePoints(p1: NSPoint, p2: NSPoint) -> CGFloat {
    return sqrt((p2.x - p1.x) * (p2.x - p1.x) + (p2.y - p1.y) * (p2.y - p1.y))
}

func SBAllowsDrag(downPoint: NSPoint, dragPoint: NSPoint) -> Bool {
    return SBDistancePoints(downPoint, dragPoint) > 10
}

func SBLocalizeTitlesInMenu(menu: NSMenu) {
    menu.title = NSLocalizedString(menu.title, comment: "")
    for item in menu.itemArray as [NSMenuItem] {
        item.title = NSLocalizedString(item.title, comment: "")
        item.submenu !! {SBLocalizeTitlesInMenu($0)}
    }
}

func SBGetLocalizableTextSet(path: String) -> ([[String]], [[NSTextField]], NSSize)? {
    let localizableString = NSString(contentsOfFile: path, encoding: NSUTF16StringEncoding, error: nil)
    if localizableString &! {$0.length > 0} {
        let fieldSize = NSSize(width: 300, height: 22)
        let offset = NSPoint(x: 45, y: 12)
        let margin = CGFloat(20)
        //let lines = split(elements: Array(localizableString), isSeparator: {$0 as String == "\n"})
        //<S : Sliceable, R : BooleanType>(elements: S, isSeparator: {} -> R, maxSplit: Int = default, allowEmptySlices: Bool = default) -> [S.SubSlice]
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

func SBLocalizableStringsData(fieldSet: [[NSTextField]]) -> NSData? {
    var string = ""
    for fields in fieldSet {
        if fields.count == 1 {
            let text = fields[0].stringValue
            string += "\n\(text)\n"
        } else if fields.count == 2 {
            let text0 = fields[0].stringValue
            let text1 = fields[1].stringValue
            string += "\"\(text0)\" = \"\(text1)\";\n"
        }
    }
    if !string.isEmpty {
        return string.dataUsingEncoding(NSUTF16StringEncoding)
    }
    return nil
}

func SBDispatch(block: dispatch_block_t) {
    dispatch_async(dispatch_get_main_queue(), block)
}

func SBDispatchDelay(delay: Double, block: dispatch_block_t) {
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * delay))
    let queue = dispatch_get_main_queue()
    dispatch_after(time, queue, block)
}

func SBConstrain<T: Comparable>(value: T, min minValue: T? = nil, max maxValue: T? = nil) -> T {
    var v = value
    minValue !! { v = max(v, $0) }
    maxValue !! { v = min(v, $0) }
    return v
}

func SBConstrain<T: Comparable>(inout value: T, min minValue: T? = nil, max maxValue: T? = nil) {
    value = SBConstrain(value, min: minValue, max: maxValue)
}

// MARK: Debug

func SBDebugViewStructure(view: NSView) -> [NSObject: AnyObject] {
    var info: [NSObject: AnyObject] = [:]
    let subviews = view.subviews as [NSView]
    var description: String!
    if let view = view as? SBView {
        description = view.description
    } else {
        description = "\(view) \(NSStringFromRect(view.frame))"
    }
    info["Description"] = description
    if !subviews.isEmpty {
        let children = subviews.map(SBDebugViewStructure)
        info["Children"] = children
    }
    return info
}

func SBDebugLayerStructure(layer: CALayer) -> [NSObject: AnyObject] {
    var info: [NSObject: AnyObject] = [:]
    let sublayers = (layer.sublayers ?? []) as [CALayer]
    let description = "\(layer) \(NSStringFromRect(layer.frame))"
    info["Description"] = description
    if !sublayers.isEmpty {
        let children = sublayers.map(SBDebugLayerStructure)
        info["Children"] = children
    }
    return info
}

func SBDebugDumpMainMenu() -> [NSObject: AnyObject] {
    return ["MenuItems": SBDebugDumpMenu(NSApplication.sharedApplication().mainMenu!)]
}

func SBDebugDumpMenu(menu: NSMenu) -> [[NSObject: AnyObject]] {
    var items: [[NSObject: AnyObject]] = []
    for item in menu.itemArray as [NSMenuItem] {
        var info: [NSObject: AnyObject] = [:]
        let submenu = item.submenu
        let title = item.title
        let target: AnyObject? = item.target
        let action = item.action
        let tag = item.tag
        let state = item.state
        let image = item.image
        let keyEquivalent = item.keyEquivalent
        let keyEquivalentModifierMask = item.keyEquivalentModifierMask
        let toolTip = item.toolTip
        info["Title"] = title
        target !! { info["Target"] = "\($0)" }
        action !! { info["Action"] = NSStringFromSelector($0) }
        info["Tag"] = tag
        info["State"] = state
        image !! { info["Image"] = $0.TIFFRepresentation }
        info["KeyEquivalent"] = keyEquivalent
        info["KeyEquivalentModifierMask"] = keyEquivalentModifierMask
        toolTip !! { info["ToolTip"] = $0 }
        submenu !! { info["MenuItems"] = SBDebugDumpMenu($0) }
        items.append(info)
    }
    return items
}

func SBDebugWriteViewStructure(view: NSView, path: String) -> Bool {
    let info = SBDebugViewStructure(view) as NSDictionary
    return info.writeToFile(path, atomically: true)
}

func SBDebugWriteLayerStructure(layer: CALayer, path: String) -> Bool {
    let info = SBDebugLayerStructure(layer) as NSDictionary
    return info.writeToFile(path, atomically: true)
}

func SBDebugWriteMainMenu(path: String) -> Bool {
    let info = SBDebugDumpMainMenu() as NSDictionary
    return info.writeToFile(path, atomically: true)
}