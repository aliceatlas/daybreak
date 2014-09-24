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
        document = SBGetDocumentController.openUntitledDocumentAndDisplay(true, error: &error) as SBDocument
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
    let items = NSApplication.sharedApplication().mainMenu.itemArray as [NSMenuItem]
    return items.first({ $0.tag == tag })?.submenu
}

func SBMenuItemWithTag(tag: Int) -> NSMenuItem? {
    let items = NSApplication.sharedApplication().mainMenu.itemArray as [NSMenuItem]
    return items.map({ $0.submenu.itemWithTag(tag) }).first({ $0 != nil })
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
        var title = defaultItem[kSBBookmarkTitle] as NSString
        var imageData = defaultItem[kSBBookmarkImage] as NSData
        var URLString = defaultItem[kSBBookmarkURL] as NSString
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
    let rect = NSMakeRect(0, 0, size.width, size.height)
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
    
    return image.bitmapImageRep.data
}

// MARK: Bookmarks

func SBBookmarksWithItems(items: [NSDictionary]) -> [NSObject: AnyObject] {
    return [kSBBookmarkVersion: SBBookmarkVersion,
            kSBBookmarkItems: items as NSArray]
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
            let URIDictionary = dictionary["URIDictionary"] as? NSDictionary
            let title = URIDictionary?["title"] as? NSString
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
            if let items = NSPropertyListSerialization.propertyListWithData(plistData, options: Int(NSPropertyListMutabilityOptions.Immutable.rawValue), format: nil, error: &error) as? NSArray {
                if let plistData = NSPropertyListSerialization.dataWithPropertyList(SBBookmarksWithItems(items as [NSDictionary]), format: .BinaryFormat_v1_0, options: 0, error: &error) {
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

func SBRoundedPath(inRect: CGRect, curve: CGFloat, inner: CGFloat, top: Bool, bottom: Bool) -> NSBezierPath {
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

/*CGPathRef SBLeftButtonPath(CGSize size)
{
    CGPathRef copiedPath = nil;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPoint p = CGPointZero;
    CGPoint cp1 = CGPointZero;
    CGPoint cp2 = CGPointZero;
    CGFloat curve = 4.0;
    
    p.x = size.width;
    p.y = 0.5;
    CGPathMoveToPoint(path, nil, p.x, p.y);
    p.x = curve + 1.0;
    CGPathAddLineToPoint(path, nil, p.x, p.y);
    p.x = 0.5;
    cp1.x = 0.5;
    cp1.y = 0.5 + curve / 2;
    cp2.x = curve / 2 + 0.5;
    cp2.y = 0.5;
    p.y = curve + 0.5;
    CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
    p.y = size.height - curve - 0.5;
    CGPathAddLineToPoint(path, nil, p.x, p.y);
    p.x = curve + 0.5;
    cp2.x = 0.5;
    cp2.y = size.height - curve / 2 - 0.5;
    cp1.x = curve / 2 + 0.5;
    cp1.y = size.height - 0.5;
    p.y = size.height - 0.5;
    CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
    p.x = size.width;
    CGPathAddLineToPoint(path, nil, p.x, p.y);
    p.y = 0.5;
    CGPathAddLineToPoint(path, nil, p.x, p.y);
    
    copiedPath = CGPathCreateCopy(path);
    CGPathRelease(path);
    
    return CFAutorelease(copiedPath);
}

CGPathRef SBCenterButtonPath(CGSize size)
{
    CGPathRef copiedPath = nil;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, CGRectMake(0.5, 0.5, size.width - 1.0, size.height - 1.0));
    
    copiedPath = CGPathCreateCopy(path);
    CGPathRelease(path);
    
    return CFAutorelease(copiedPath);
}

CGPathRef SBRightButtonPath(CGSize size)
{
    CGPathRef copiedPath = nil;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPoint p = CGPointZero;
    CGPoint cp1 = CGPointZero;
    CGPoint cp2 = CGPointZero;
    CGFloat curve = 4.0;
    
    p.x = 0.5;
    p.y = 0.5;
    CGPathMoveToPoint(path, nil, p.x, p.y);
    p.x = size.width - curve - 1.0;
    CGPathAddLineToPoint(path, nil, p.x, p.y);
    p.x = size.width - 1.0;
    cp1.x = size.width - 0.5;
    cp1.y = 0.5 + curve / 2;
    cp2.x = size.width - curve / 2 - 1.0;
    cp2.y = 0.5;
    p.y = curve + 0.5;
    CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
    p.y = size.height - curve - 1.0;
    CGPathAddLineToPoint(path, nil, p.x, p.y);
    p.x = size.width - curve - 1.0;
    cp2.x = size.width - 1.0;
    cp2.y = size.height - curve / 2 - 1.0;
    cp1.x = size.width - curve / 2 - 1.0;
    cp1.y = size.height - 0.5;
    p.y = size.height - 0.5;
    CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
    p.x = 0.5;
    CGPathAddLineToPoint(path, nil, p.x, p.y);
    p.y = 0.5;
    CGPathAddLineToPoint(path, nil, p.x, p.y);
    
    copiedPath = CGPathCreateCopy(path);
    CGPathRelease(path);
    
    return CFAutorelease(copiedPath);
}

// direction: 0 = left, 1 = top, 2 = right, 3 = bottom
CGPathRef SBTrianglePath(CGRect rect, NSInteger direction)
{
    CGPathRef copiedPath = nil;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPoint p = CGPointZero;
    
    if (direction == 0) // Left
    {
        p.x = CGRectGetMaxX(rect);
        p.y = CGRectGetMinY(rect);
        CGPathMoveToPoint(path, nil, p.x, p.y);
        p.y = CGRectGetMaxY(rect);
        CGPathAddLineToPoint(path, nil, p.x, p.y);
        p.x = CGRectGetMinX(rect);
        p.y = CGRectGetMidY(rect);
        CGPathAddLineToPoint(path, nil, p.x, p.y);
        p.x = CGRectGetMaxX(rect);
        p.y = CGRectGetMinY(rect);
        CGPathAddLineToPoint(path, nil, p.x, p.y);
    }
    if (direction == 1) // Top
    {
        p.x = CGRectGetMinX(rect);
        p.y = CGRectGetMaxY(rect);
        CGPathMoveToPoint(path, nil, p.x, p.y);
        p.x = CGRectGetMaxX(rect);
        CGPathAddLineToPoint(path, nil, p.x, p.y);
        p.x = CGRectGetMidX(rect);
        p.y = CGRectGetMinY(rect);
        CGPathAddLineToPoint(path, nil, p.x, p.y);
        p.x = CGRectGetMinX(rect);
        p.y = CGRectGetMaxY(rect);
        CGPathAddLineToPoint(path, nil, p.x, p.y);
    }
    else if (direction == 2)    // Right
    {
        p.x = CGRectGetMinX(rect);
        p.y = CGRectGetMinY(rect);
        CGPathMoveToPoint(path, nil, p.x, p.y);
        p.y = CGRectGetMaxY(rect);
        CGPathAddLineToPoint(path, nil, p.x, p.y);
        p.x = CGRectGetMaxX(rect);
        p.y = CGRectGetMidY(rect);
        CGPathAddLineToPoint(path, nil, p.x, p.y);
        p.x = CGRectGetMinX(rect);
        p.y = CGRectGetMinY(rect);
        CGPathAddLineToPoint(path, nil, p.x, p.y);
    }
    else if (direction == 3)    // Bottom
    {
        p.x = CGRectGetMinX(rect);
        p.y = CGRectGetMinY(rect);
        CGPathMoveToPoint(path, nil, p.x, p.y);
        p.x = CGRectGetMaxX(rect);
        CGPathAddLineToPoint(path, nil, p.x, p.y);
        p.x = CGRectGetMidX(rect);
        p.y = CGRectGetMaxY(rect);
        CGPathAddLineToPoint(path, nil, p.x, p.y);
        p.x = CGRectGetMinX(rect);
        p.y = CGRectGetMinY(rect);
        CGPathAddLineToPoint(path, nil, p.x, p.y);
    }
    
    copiedPath = CGPathCreateCopy(path);
    CGPathRelease(path);
    
    return CFAutorelease(copiedPath);
}

CGPathRef SBEllipsePath3D(CGRect r, CATransform3D transform)
{
    CGPathRef copiedPath = nil;
    CGMutablePathRef path = nil;
    CGPoint p = CGPointZero;
    CGPoint cp1 = CGPointZero;
    CGPoint cp2 = CGPointZero;
    
    path = CGPathCreateMutable();
    p.x = CGRectGetMidX(r);
    p.y = r.origin.y;
    SBCGPointApplyTransform3D(&p, &transform);
    CGPathMoveToPoint(path, nil, p.x, p.y);
    p.x = r.origin.x;
    p.y = CGRectGetMidY(r);
    cp1.x = r.origin.x + r.size.width / 4;
    cp1.y = r.origin.y;
    cp2.x = r.origin.x;
    cp2.y = r.origin.y + r.size.height / 4;
    SBCGPointApplyTransform3D(&p, &transform);
    SBCGPointApplyTransform3D(&cp1, &transform);
    SBCGPointApplyTransform3D(&cp2, &transform);
    CGPathAddCurveToPoint(path, nil, cp1.x, cp1.y, cp2.x, cp2.y, p.x, p.y);
    p.x = CGRectGetMidX(r);
    p.y = CGRectGetMaxY(r);
    cp1.x = r.origin.x;
    cp1.y = r.origin.y + r.size.height / 4 * 3;
    cp2.x = r.origin.x + r.size.width / 4;
    cp2.y = CGRectGetMaxY(r);
    SBCGPointApplyTransform3D(&p, &transform);
    SBCGPointApplyTransform3D(&cp1, &transform);
    SBCGPointApplyTransform3D(&cp2, &transform);
    CGPathAddCurveToPoint(path, nil, cp1.x, cp1.y, cp2.x, cp2.y, p.x, p.y);
    p.x = CGRectGetMaxX(r);
    p.y = CGRectGetMidY(r);
    cp1.x = r.origin.x + r.size.width / 4 * 3;
    cp1.y = CGRectGetMaxY(r);
    cp2.x = CGRectGetMaxX(r);
    cp2.y = r.origin.y + r.size.height / 4 * 3;
    SBCGPointApplyTransform3D(&p, &transform);
    SBCGPointApplyTransform3D(&cp1, &transform);
    SBCGPointApplyTransform3D(&cp2, &transform);
    CGPathAddCurveToPoint(path, nil, cp1.x, cp1.y, cp2.x, cp2.y, p.x, p.y);
    p.x = CGRectGetMidX(r);
    p.y = r.origin.y;
    cp1.x = CGRectGetMaxX(r);
    cp1.y = r.origin.y + r.size.height / 4;
    cp2.x = r.origin.x + r.size.width / 4 * 3;
    cp2.y = r.origin.y;
    SBCGPointApplyTransform3D(&p, &transform);
    SBCGPointApplyTransform3D(&cp1, &transform);
    SBCGPointApplyTransform3D(&cp2, &transform);
    CGPathAddCurveToPoint(path, nil, cp1.x, cp1.y, cp2.x, cp2.y, p.x, p.y);
    
    copiedPath = CGPathCreateCopy(path);
    CGPathRelease(path);
    
    return CFAutorelease(copiedPath);
}

CGPathRef SBRoundedPath3D(CGRect rect, CGFloat curve, CATransform3D transform)
{
    CGPathRef copiedPath = nil;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPoint p = CGPointZero;
    CGPoint cp1 = CGPointZero;
    CGPoint cp2 = CGPointZero;
    CGAffineTransform t = CGAffineTransformIdentity;
    
    // line left-top to right-top
    p.x = (rect.origin.x + curve);
    p.y = rect.origin.y;
    SBCGPointApplyTransform3D(&p, &transform);
    CGPathMoveToPoint(path, &t, p.x,p.y);
    p.x = (rect.origin.x + rect.size.width - curve);
    p.y = rect.origin.y;
    SBCGPointApplyTransform3D(&p, &transform);
    CGPathAddLineToPoint(path, &t, p.x,p.y);
    p.x = (rect.origin.x + rect.size.width);
    cp1.x = (rect.origin.x + rect.size.width);
    cp1.y = rect.origin.y + curve / 2;
    cp2.x = (rect.origin.x + rect.size.width) - curve / 2;
    cp2.y = rect.origin.y;
    p.y = (rect.origin.y + curve);
    SBCGPointApplyTransform3D(&p, &transform);
    SBCGPointApplyTransform3D(&cp1, &transform);
    SBCGPointApplyTransform3D(&cp2, &transform);
    CGPathAddCurveToPoint(path, &t, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
    
    p.x = (rect.origin.x + rect.size.width);
    p.y = (rect.origin.y + rect.size.height - curve);
    SBCGPointApplyTransform3D(&p, &transform);
    CGPathAddLineToPoint(path, &t, p.x,p.y);
    p.x = (rect.origin.x + rect.size.width - curve);
    p.y = (rect.origin.y + rect.size.height);
    cp1.y = (rect.origin.y + rect.size.height);
    cp1.x = (rect.origin.x + rect.size.width) - curve / 2;
    cp2.y = (rect.origin.y + rect.size.height) - curve / 2;
    cp2.x = (rect.origin.x + rect.size.width);
    SBCGPointApplyTransform3D(&p, &transform);
    SBCGPointApplyTransform3D(&cp1, &transform);
    SBCGPointApplyTransform3D(&cp2, &transform);
    CGPathAddCurveToPoint(path, &t, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
    
    p.x = (rect.origin.x + curve);
    p.y = (rect.origin.y + rect.size.height);
    SBCGPointApplyTransform3D(&p, &transform);
    CGPathAddLineToPoint(path, &t, p.x,p.y);
    p.x = rect.origin.x;
    cp1.x = rect.origin.x;
    cp1.y = (rect.origin.y + rect.size.height) - curve / 2;
    cp2.x = rect.origin.x + curve / 2;
    cp2.y = (rect.origin.y + rect.size.height);
    p.y = (rect.origin.y + rect.size.height - curve);
    SBCGPointApplyTransform3D(&p, &transform);
    SBCGPointApplyTransform3D(&cp1, &transform);
    SBCGPointApplyTransform3D(&cp2, &transform);
    CGPathAddCurveToPoint(path, &t, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
    
    p.x = rect.origin.x;
    p.y = (rect.origin.y + curve);
    SBCGPointApplyTransform3D(&p, &transform);
    CGPathAddLineToPoint(path, &t, p.x,p.y);
    p.y = rect.origin.y;
    cp1.y = rect.origin.y;
    cp1.x = rect.origin.x + curve / 2;
    cp2.y = rect.origin.y + curve / 2;
    cp2.x = rect.origin.x;
    p.x = (rect.origin.x + curve);
    SBCGPointApplyTransform3D(&p, &transform);
    SBCGPointApplyTransform3D(&cp1, &transform);
    SBCGPointApplyTransform3D(&cp2, &transform);
    CGPathAddCurveToPoint(path, &t, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
    
    CGPathCloseSubpath(path);
    copiedPath = CGPathCreateCopy(path);
    CGPathRelease(path);
    
    return CFAutorelease(copiedPath);
}

void SBCGPointApplyTransform3D(CGPoint *p, const CATransform3D *t)
{
    double px = p->x;
    double py = p->y, w;
    w  = px * t->m14 + py * t->m24 + t->m44;
    p->x = (px * t->m11 + py * t->m21 + t->m41) / w;
    p->y = (px * t->m12 + py * t->m22 + t->m42) / w;
}*/

func SBCenteredSquare(inRect: NSRect) -> NSRect {
    let side = min(inRect.size.width, inRect.size.height)
    let size = NSMakeSize(side, side)
    let origin = NSMakePoint(NSMidX(inRect) - side / 2, NSMidY(inRect) - side / 2)
    return NSRect(origin: origin, size: size)
}

// MARK: Drawing

/*void SBDrawGradientInContext(CGContextRef ctx, NSUInteger count, const CGFloat locations[], const CGFloat colors[], const CGPoint points[])
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, count);
//  CGFunctionRef gradientFunction = CGGradientGetFunction(gradient);
    CGContextDrawLinearGradient(ctx, gradient, points[0], points[1], kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
//  if (CFGetRetainCount(gradientFunction) > 0)
//      CGFunctionRelease(gradientFunction);
}

void SBDrawRadialGradientInContext(CGContextRef ctx, NSUInteger count, CGFloat locations[], CGFloat colors[], CGPoint centers[], CGFloat radiuses[])
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, count);
    CGContextDrawRadialGradient(ctx, gradient, centers[0], radiuses[0], centers[1], radiuses[1], kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}*/

let SBAlternateSelectedLightControlColor = NSColor.alternateSelectedControlColor().blendedColorWithFraction(0.3, ofColor: NSColor.whiteColor()).colorUsingColorSpace(NSColorSpace.genericRGBColorSpace())

let SBAlternateSelectedControlColor = NSColor.alternateSelectedControlColor().colorUsingColorSpace(NSColorSpace.genericRGBColorSpace())

let SBAlternateSelectedDarkControlColor = NSColor.alternateSelectedControlColor().blendedColorWithFraction(0.3, ofColor: NSColor.blackColor()).colorUsingColorSpace(NSColorSpace.genericRGBColorSpace())

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
    return SBGraphicsPortFromContext(NSGraphicsContext.currentContext())
}

/*#pragma mark Image

CGImageRef SBBackwardIconImage(CGSize size, BOOL enabled, BOOL backing)
{
    CGImageRef image = nil;
    CGContextRef ctx = nil;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGPathRef path = nil;
    CGPathRef tpath = SBTrianglePath(CGRectMake(9.0, 7.0, size.width - 9.0 * 2, size.height - 7.0 * 2), 0);
    NSUInteger count = 2;
    CGFloat locations[count];
    CGFloat colors[count * 4];
    CGPoint points[count];
    CGFloat tgrayScale = enabled ? 0.2 : 0.5;
    
    ctx = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast));
    CGColorSpaceRelease(colorSpace);
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, 0.0, size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    path = SBLeftButtonPath(size);
    
    // Background
    locations[0] = 0.0;
    locations[1] = 1.0;
    colors[0] = colors[1] = colors[2] = backing ? 0.95 : 0.8;
    colors[3] = 1.0;
    colors[4] = colors[5] = colors[6] = backing ? 0.65 : 0.5;
    colors[7] = 1.0;
    points[0] = CGPointZero;
    points[1] = CGPointMake(0.0, size.height);
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, path);
    CGContextClip(ctx);
    SBDrawGradientInContext(ctx, count, locations, colors, points);
    CGContextRestoreGState(ctx);
    
    // Frame
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, path);
    CGContextSetRGBStrokeColor(ctx, 0.2, 0.2, 0.2, 1.0);
    CGContextSetLineWidth(ctx, 0.5);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    
    // Triangle
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, tpath);
    CGContextSetRGBFillColor(ctx, tgrayScale, tgrayScale, tgrayScale, 1.0);
    CGContextSetLineWidth(ctx, 0.5);
    CGContextFillPath(ctx);
    CGContextRestoreGState(ctx);
    
    image = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    return (CGImageRef)CFAutorelease(image);
}

CGImageRef SBForwardIconImage(CGSize size, BOOL enabled, BOOL backing)
{
    CGImageRef image = nil;
    CGContextRef ctx = nil;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGPathRef path = nil;
    CGPathRef tpath = SBTrianglePath(CGRectMake(9.0, 7.0, size.width - 9.0 * 2, size.height - 7.0 * 2), 2);
    NSUInteger count = 2;
    CGFloat locations[count];
    CGFloat colors[count * 4];
    CGPoint points[count];
    CGFloat tgrayScale = enabled ? 0.2 : 0.5;
    
    ctx = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast));
    CGColorSpaceRelease(colorSpace);
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, 0.0, size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    path = SBCenterButtonPath(size);
    
    // Background
    locations[0] = 0.0;
    locations[1] = 1.0;
    colors[0] = colors[1] = colors[2] = backing ? 0.95 : 0.8;
    colors[3] = 1.0;
    colors[4] = colors[5] = colors[6] = backing ? 0.65 : 0.5;
    colors[7] = 1.0;
    points[0] = CGPointZero;
    points[1] = CGPointMake(0.0, size.height);
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, path);
    CGContextClip(ctx);
    SBDrawGradientInContext(ctx, count, locations, colors, points);
    CGContextRestoreGState(ctx);
    
    // Frame
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, path);
    CGContextSetRGBStrokeColor(ctx, 0.2, 0.2, 0.2, 1.0);
    CGContextSetLineWidth(ctx, 0.5);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    
    // Triangle
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, tpath);
    CGContextSetRGBFillColor(ctx, tgrayScale, tgrayScale, tgrayScale, 1.0);
    CGContextSetLineWidth(ctx, 0.5);
    CGContextFillPath(ctx);
    CGContextRestoreGState(ctx);
    
    image = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    return (CGImageRef)CFAutorelease(image);
}

CGImageRef SBGoIconImage(CGSize size, BOOL enabled, BOOL backing)
{
    CGImageRef image = nil;
    CGContextRef ctx = nil;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGPathRef path = nil;
    CGFloat components1[4];
    CGFloat components2[4];
    NSUInteger count = 2;
    CGFloat locations[count];
    CGFloat colors[count * 4];
    CGPoint points[count];
    
    ctx = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast));
    CGColorSpaceRelease(colorSpace);
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, 0.0, size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    path = SBRightButtonPath(size);
    
    // Background
    if (!backing)
    {
        SBGetAlternateSelectedLightControlColorComponents(components1);
        SBGetAlternateSelectedControlColorComponents(components2);
    }
    else {
        components1[0] = components1[1] = components1[2] = 0.95;
        components2[0] = components2[1] = components2[2] = 0.65;
    }
    locations[0] = 0.0;
    locations[1] = 1.0;
    colors[0] = components1[0];
    colors[1] = components1[1];
    colors[2] = components1[2];
    colors[3] = enabled ? 1.0 : 0.5;
    colors[4] = components2[0];
    colors[5] = components2[1];
    colors[6] = components2[2];
    colors[7] = enabled ? 1.0 : 0.5;
    points[0] = CGPointZero;
    points[1] = CGPointMake(0.0, size.height);
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, path);
    CGContextClip(ctx);
    SBDrawGradientInContext(ctx, count, locations, colors, points);
    CGContextRestoreGState(ctx);
    
    // Frame
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, path);
    CGContextSetRGBStrokeColor(ctx, 0.2, 0.2, 0.2, 1.0);
    CGContextSetLineWidth(ctx, 0.5);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    
    image = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    return (CGImageRef)CFAutorelease(image);
}

CGImageRef SBZoomOutIconImage(CGSize size)
{
    CGImageRef image = nil;
    CGContextRef ctx = nil;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSGraphicsContext *bctx = nil;
    NSImage *frameImage = [NSImage imageNamed:@"LeftButton"];
    NSImage *iconImage = [NSImage imageNamed:@"ZoomOut"];
    NSRect r = NSZeroRect;
    
    ctx = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast));
    bctx = [NSGraphicsContext graphicsContextWithGraphicsPort:ctx flipped:NO];
    CGColorSpaceRelease(colorSpace);
    
    [NSGraphicsContext saveGraphicsState];
    NSGraphicsContext.currentContext = bctx;
    
    // Frame
    if (frameImage)
    {
        r.size = frameImage.size;
        r.origin.x = (size.width - r.size.width) / 2;
        r.origin.y = (size.height - r.size.height) / 2;
        [frameImage drawInRect:r fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    }
    
    // Image
    if (iconImage)
    {
        r.size = iconImage.size;
        r.origin.x = (size.width - r.size.width) / 2;
        r.origin.y = (size.height - r.size.height) / 2;
        [iconImage drawInRect:r fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    }
    [NSGraphicsContext restoreGraphicsState];
    
    image = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    return (CGImageRef)CFAutorelease(image);
}

CGImageRef SBActualSizeIconImage(CGSize size)
{
    CGImageRef image = nil;
    CGContextRef ctx = nil;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSGraphicsContext *bctx = nil;
    NSImage *frameImage = [NSImage imageNamed:@"CenterButton"];
    NSImage *iconImage = [NSImage imageNamed:@"ActualSize"];
    NSRect r = NSZeroRect;
    
    ctx = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast));
    bctx = [NSGraphicsContext graphicsContextWithGraphicsPort:ctx flipped:NO];
    CGColorSpaceRelease(colorSpace);
    
    [NSGraphicsContext saveGraphicsState];
    NSGraphicsContext.currentContext = bctx;
    
    // Frame
    if (frameImage)
    {
        r.size = frameImage.size;
        r.origin.x = (size.width - r.size.width) / 2;
        r.origin.y = (size.height - r.size.height) / 2;
        [frameImage drawInRect:r fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    }
    
    // Image
    if (iconImage)
    {
        r.size = iconImage.size;
        r.origin.x = (size.width - r.size.width) / 2;
        r.origin.y = (size.height - r.size.height) / 2;
        [NSGraphicsContext saveGraphicsState];
        NSGraphicsContext.currentContext = bctx;
        [iconImage drawInRect:r fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    }
    [NSGraphicsContext restoreGraphicsState];
    
    image = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    return (CGImageRef)CFAutorelease(image);
}

CGImageRef SBZoomInIconImage(CGSize size)
{
    CGImageRef image = nil;
    CGContextRef ctx = nil;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSGraphicsContext *bctx = nil;
    NSImage *frameImage = [NSImage imageNamed:@"RightButton"];
    NSImage *iconImage = [NSImage imageNamed:@"ZoomIn"];
    NSRect r = NSZeroRect;
    
    ctx = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast));
    bctx = [NSGraphicsContext graphicsContextWithGraphicsPort:ctx flipped:NO];
    CGColorSpaceRelease(colorSpace);
    
    [NSGraphicsContext saveGraphicsState];
    NSGraphicsContext.currentContext = bctx;
    
    // Frame
    if (frameImage)
    {
        r.size = frameImage.size;
        r.origin.x = (size.width - r.size.width) / 2;
        r.origin.y = (size.height - r.size.height) / 2;
        [frameImage drawInRect:r fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    }
    
    // Image
    if (iconImage)
    {
        r.size = iconImage.size;
        r.origin.x = (size.width - r.size.width) / 2;
        r.origin.y = (size.height - r.size.height) / 2;
        [NSGraphicsContext saveGraphicsState];
        NSGraphicsContext.currentContext = bctx;
        [iconImage drawInRect:r fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    }
    [NSGraphicsContext restoreGraphicsState];
    
    image = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    return (CGImageRef)CFAutorelease(image);
}

CGImageRef SBAddIconImage(CGSize size, BOOL backing)
{
    CGImageRef image = nil;
    CGContextRef ctx = nil;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGMutablePathRef path = nil;
    CGPoint p = CGPointZero;
    CGPoint cp1 = CGPointZero;
    CGPoint cp2 = CGPointZero;
    CGFloat curve = 4.0;
    CGFloat margin = 7.0;
    
    ctx = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast));
    CGColorSpaceRelease(colorSpace);
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, 0.0, size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    path = CGPathCreateMutable();
    p.y = 1.0;
    CGPathMoveToPoint(path, nil, p.x, p.y);
    p.x = size.width - curve;
    CGPathAddLineToPoint(path, nil, p.x, p.y);
    p.x = size.width;
    cp1.x = size.width;
    cp1.y = 1.0 + curve / 2;
    cp2.x = size.width - curve / 2;
    cp2.y = 1.0;
    p.y = 1.0 + curve;
    CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
    p.y = size.height;
    CGPathAddLineToPoint(path, nil, p.x, p.y);
    p.x = 0.0;
    CGPathAddLineToPoint(path, nil, p.x, p.y);
    
    if (!backing)
    {
        // Background
        NSUInteger count = 2;
        CGFloat locations[count];
        CGFloat colors[count * 4];
        CGPoint points[count];
        locations[0] = 0.0;
        locations[1] = 1.0;
        colors[0] = colors[1] = colors[2] = 0.6;
        colors[3] = 1.0;
        colors[4] = colors[5] = colors[6] = 0.55;
        colors[7] = 1.0;
        points[0] = CGPointZero;
        points[1] = CGPointMake(0.0, size.height);
        CGContextSaveGState(ctx);
        CGContextAddPath(ctx, path);
        CGContextClip(ctx);
        SBDrawGradientInContext(ctx, count, locations, colors, points);
        CGContextRestoreGState(ctx);
    }
    
    // Frame
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, path);
    CGContextSetRGBStrokeColor(ctx, 0.2, 0.2, 0.2, 1.0);
    CGContextSetLineWidth(ctx, 0.5);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    CGPathRelease(path);
    
    // Cross
    path = CGPathCreateMutable();
    p.x = size.width / 2;
    p.y = margin - 1.0;
    CGPathMoveToPoint(path, nil, p.x, p.y);
    p.y = size.height / 2;
    CGPathAddLineToPoint(path, nil, p.x, p.y);
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, path);
    CGContextSetRGBStrokeColor(ctx, 0.3, 0.3, 0.3, 1.0);
    CGContextSetLineWidth(ctx, 3.0);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    CGPathRelease(path);
    
    path = CGPathCreateMutable();
    p.x = margin - 1.0;
    p.y = size.height / 2 - 1.0;
    CGPathMoveToPoint(path, nil, p.x, p.y);
    p.x = size.width - margin + 1.0;
    CGPathAddLineToPoint(path, nil, p.x, p.y);
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, path);
    CGContextSetRGBStrokeColor(ctx, 0.3, 0.3, 0.3, 1.0);
    CGContextSetLineWidth(ctx, 2.0);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    CGPathRelease(path);
    
    path = CGPathCreateMutable();
    p.x = size.width / 2;
    p.y = size.height / 2;
    CGPathMoveToPoint(path, nil, p.x, p.y);
    p.y = size.height - margin + 1.0;
    CGPathAddLineToPoint(path, nil, p.x, p.y);
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, path);
    CGContextSetRGBStrokeColor(ctx, 0.75, 0.75, 0.75, 1.0);
    CGContextSetLineWidth(ctx, 3.0);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    CGPathRelease(path);
    
    path = CGPathCreateMutable();
    p.x = margin - 1.0;
    p.y = size.height / 2 + 1.0;
    CGPathMoveToPoint(path, nil, p.x, p.y);
    p.x = size.width - margin + 1.0;
    CGPathAddLineToPoint(path, nil, p.x, p.y);
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, path);
    CGContextSetRGBStrokeColor(ctx, 0.75, 0.75, 0.75, 1.0);
    CGContextSetLineWidth(ctx, 2.0);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    CGPathRelease(path);
    
    path = CGPathCreateMutable();
    p.x = size.width / 2;
    p.y = margin;
    CGPathMoveToPoint(path, nil, p.x, p.y);
    p.y = size.height - margin;
    CGPathAddLineToPoint(path, nil, p.x, p.y);
    p.x = margin;
    p.y = size.height / 2;
    CGPathMoveToPoint(path, nil, p.x, p.y);
    p.x = size.width - margin;
    CGPathAddLineToPoint(path, nil, p.x, p.y);
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, path);
    if (backing)
        CGContextSetRGBStrokeColor(ctx, 0.7, 0.7, 0.7, 1.0);
    else
        CGContextSetRGBStrokeColor(ctx, 0.5, 0.5, 0.5, 1.0);
    CGContextSetLineWidth(ctx, 3.0);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    CGPathRelease(path);
    
    image = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    return (CGImageRef)CFAutorelease(image);
}

CGImageRef SBCloseIconImage()
{
    CGImageRef image = nil;
    CGContextRef ctx = nil;
    CGSize size = CGSizeMake(17.0, 17.0);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    ctx = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast));
    CGColorSpaceRelease(colorSpace);
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, 0.0, size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    CGFloat side = size.width;
    CGRect r = CGRectMake((size.width - side) / 2, (size.height - side) / 2, side, side);
    CGMutablePathRef xPath = CGPathCreateMutable();
    CGPoint p = CGPointZero;
    CGFloat across = r.size.width;
    CGFloat length = 11.0;
    CGFloat margin = r.origin.x;
    CGFloat lineWidth = 2;
    CGFloat center = margin + across / 2;
    CGFloat grayScaleUp = 1.0;
    CGAffineTransform t = CGAffineTransformIdentity;
    t = CGAffineTransformTranslate(t, center, center);
    t = CGAffineTransformRotate(t, -45 * M_PI / 180);
    p.x = -length / 2;
    CGPathMoveToPoint(xPath, &t, p.x, p.y);
    p.x = length / 2;
    CGPathAddLineToPoint(xPath, &t, p.x, p.y);
    p.x = 0;
    p.y = -length / 2;
    CGPathMoveToPoint(xPath, &t, p.x, p.y);
    p.y = length / 2;
    CGPathAddLineToPoint(xPath, &t, p.x, p.y);
    
    // Close
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, xPath);
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextSetRGBStrokeColor(ctx, grayScaleUp, grayScaleUp, grayScaleUp, 1.0);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    CGPathRelease(xPath);
    
    image = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    return (CGImageRef)CFAutorelease(image);
}

CGImageRef SBIconImageWithName(NSString *imageName, SBButtonShape shape, CGSize size)
{
    return SBIconImage([NSImage imageNamed:imageName].CGImage, shape, size);
}

CGImageRef SBIconImage(CGImageRef iconImage, SBButtonShape shape, CGSize size)
{
    CGImageRef image = nil;
    CGContextRef ctx = nil;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGSize imageSize = CGSizeMake(CGImageGetWidth(iconImage), CGImageGetHeight(iconImage));
    CGRect imageRect = CGRectMake((size.width - imageSize.width) / 2, (size.height - imageSize.height) / 2, imageSize.width, imageSize.height);
    
    ctx = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast));
    CGColorSpaceRelease(colorSpace);
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, 0.0, size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    // Frame
    {
        CGMutablePathRef path = nil;
        CGRect insetRect = CGRectZero;
        CGColorRef shadowColor = nil;
        CGFloat insetMargin = 3.0;
        CGFloat lineWidth = 2.0;
        path = CGPathCreateMutable();
        insetRect = CGRectMake(0.0, 0.0, size.width, size.height);
        switch (shape)
        {
            case SBButtonShapeExclusive:
                insetMargin = 4.0;
                insetRect = CGRectInset(insetRect, insetMargin, insetMargin);
                CGPathAddEllipseInRect(path, nil, insetRect);
                break;
            case SBButtonShapeLeft:
            {
                CGPoint p = CGPointZero;
                CGPoint cp1 = CGPointZero;
                CGPoint cp2 = CGPointZero;
                CGFloat rad = 0;
                
                insetRect.origin.x += insetMargin;
                insetRect.origin.y += insetMargin;
                insetRect.size.width -= insetMargin;
                insetRect.size.height -= insetMargin * 2;
                rad = insetRect.size.height / 2;
                
                p.x = CGRectGetMaxX(insetRect) + lineWidth / 4;
                p.y = insetRect.origin.y;
                CGPathMoveToPoint(path, nil, p.x, p.y);
                p.x = insetRect.origin.x + rad;
                CGPathAddLineToPoint(path, nil, p.x, p.y);
                
                p.x = insetRect.origin.x;
                cp1.x = insetRect.origin.x;
                cp1.y = insetRect.origin.y + rad / 2;
                cp2.x = insetRect.origin.x + rad / 2;
                cp2.y = insetRect.origin.y;
                p.y = insetRect.origin.y + rad;
                CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
                
                p.x = insetRect.origin.x + rad;
                cp2.x = insetRect.origin.x;
                cp2.y = CGRectGetMaxY(insetRect) - rad / 2;
                cp1.x = insetRect.origin.x + rad / 2;
                cp1.y = CGRectGetMaxY(insetRect);
                p.y = CGRectGetMaxY(insetRect);
                CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
                
                p.x = CGRectGetMaxX(insetRect) + lineWidth / 4;
                CGPathAddLineToPoint(path, nil, p.x, p.y);
                
                CGPathCloseSubpath(path);
                
                imageRect.origin.x += insetMargin;
                break;
            }
            case SBButtonShapeCenter:
            {
                insetRect.origin.y += insetMargin;
                insetRect.size.height -= insetMargin * 2;
                CGPathAddRect(path, nil, insetRect);
                break;
            }
            case SBButtonShapeRight:
            {
                CGPoint p = CGPointZero;
                CGPoint cp1 = CGPointZero;
                CGPoint cp2 = CGPointZero;
                CGFloat rad = 0;
                
                insetRect.origin.y += insetMargin;
                insetRect.size.width -= insetMargin;
                insetRect.size.height -= insetMargin * 2;
                rad = insetRect.size.height / 2;
                
                p.x = insetRect.origin.x - lineWidth / 4;
                p.y = insetRect.origin.y;
                CGPathMoveToPoint(path, nil, p.x, p.y);
                p.x = CGRectGetMaxX(insetRect) - rad;
                CGPathAddLineToPoint(path, nil, p.x, p.y);
                
                p.x = CGRectGetMaxX(insetRect);
                cp1.x = CGRectGetMaxX(insetRect);
                cp1.y = CGRectGetMinY(insetRect) + rad / 2;
                cp2.x = CGRectGetMaxX(insetRect) - rad / 2;
                cp2.y = CGRectGetMinY(insetRect);
                p.y = CGRectGetMinY(insetRect) + rad;
                CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
                
                p.x = CGRectGetMaxX(insetRect) - rad;
                cp2.x = CGRectGetMaxX(insetRect);
                cp2.y = CGRectGetMaxY(insetRect) - rad / 2;
                cp1.x = CGRectGetMaxX(insetRect) - rad / 2;
                cp1.y = CGRectGetMaxY(insetRect);
                p.y = CGRectGetMaxY(insetRect);
                CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
                
                p.x = insetRect.origin.x - lineWidth / 4;
                CGPathAddLineToPoint(path, nil, p.x, p.y);
                
                CGPathCloseSubpath(path);
                
                imageRect.origin.x -= insetMargin / 2;
                break;
            }
        }
        shadowColor = CGColorCreateGenericGray(0.0, 1.0);
        
        // Fill
        CGContextSaveGState(ctx);
        CGContextAddPath(ctx, path);
        CGContextSetShadowWithColor(ctx, CGSizeZero, insetMargin, shadowColor);
        CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 1.0);
        CGContextFillPath(ctx);
        CGContextRestoreGState(ctx);
        CGColorRelease(shadowColor);
        
        // Stroke
        CGContextSaveGState(ctx);
        CGContextAddPath(ctx, path);
        CGContextSetLineWidth(ctx, lineWidth);
        CGContextSetRGBStrokeColor(ctx, 0.9, 0.9, 0.9, 1.0);
        CGContextStrokePath(ctx);
        CGContextRestoreGState(ctx);
        CGPathRelease(path);
    }
    
    // Icon
    if (iconImage)
    {
        CGContextSaveGState(ctx);
        CGContextTranslateCTM(ctx, 0.0, size.height);
        CGContextScaleCTM(ctx, 1.0, -1.0);
        CGContextDrawImage(ctx, imageRect, iconImage);
        CGContextRestoreGState(ctx);
    }
    
    CGContextRestoreGState(ctx);
    image = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    return (CGImageRef)CFAutorelease(image);
}

CGImageRef SBFindBackwardIconImage(CGSize size, BOOL enabled)
{
    CGImageRef image = nil;
    CGContextRef ctx = nil;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGMutablePathRef path = nil;
    CGPathRef tpath = SBTrianglePath(CGRectMake(9.0, 5.0, size.width - 9.0 * 2, size.height - 5.0 * 2), 0);
    CGPoint p = CGPointZero;
    CGPoint cp1 = CGPointZero;
    CGPoint cp2 = CGPointZero;
    CGFloat curve = size.height / 2;
    NSUInteger count = 2;
    CGFloat locations[count];
    CGFloat colors[count * 4];
    CGPoint points[count];
    CGFloat tgrayScale = enabled ? 0.9 : 0.5;
    
    ctx = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast));
    CGColorSpaceRelease(colorSpace);
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, 0.0, size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    path = CGPathCreateMutable();
    p.x = size.width;
    p.y = 0.5;
    CGPathMoveToPoint(path, nil, p.x, p.y);
    p.x = curve + 1.0;
    CGPathAddLineToPoint(path, nil, p.x, p.y);
    p.x = 0.5;
    cp1.x = 0.5;
    cp1.y = 0.5 + curve / 2;
    cp2.x = curve / 2 + 0.5;
    cp2.y = 0.5;
    p.y = curve + 0.5;
    CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
    p.x = curve + 0.5;
    cp2.x = 0.5;
    cp2.y = size.height - curve / 2 - 0.5;
    cp1.x = curve / 2 + 0.5;
    cp1.y = size.height - 0.5;
    p.y = size.height - 0.5;
    CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
    p.x = size.width;
    CGPathAddLineToPoint(path, nil, p.x, p.y);
    p.y = 0.5;
    CGPathAddLineToPoint(path, nil, p.x, p.y);
    
    // Background
    locations[0] = 0.0;
    locations[1] = 1.0;
    colors[0] = colors[1] = colors[2] = 0.5;
    colors[3] = 1.0;
    colors[4] = colors[5] = colors[6] = 0.0;
    colors[7] = 1.0;
    points[0] = CGPointZero;
    points[1] = CGPointMake(0.0, size.height);
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, path);
    CGContextClip(ctx);
    SBDrawGradientInContext(ctx, count, locations, colors, points);
    CGContextRestoreGState(ctx);
    
    // Frame
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, path);
    CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 0.0, 1.0);
    CGContextSetLineWidth(ctx, 0.5);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    CGPathRelease(path);
    
    // Triangle
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, tpath);
    CGContextSetRGBFillColor(ctx, tgrayScale, tgrayScale, tgrayScale, 1.0);
    CGContextSetLineWidth(ctx, 0.5);
    CGContextFillPath(ctx);
    CGContextRestoreGState(ctx);
    
    image = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    return (CGImageRef)CFAutorelease(image);
}

CGImageRef SBFindForwardIconImage(CGSize size, BOOL enabled)
{
    CGImageRef image = nil;
    CGContextRef ctx = nil;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGMutablePathRef path = nil;
    CGPathRef tpath = SBTrianglePath(CGRectMake(9.0, 5.0, size.width - 9.0 * 2, size.height - 5.0 * 2), 2);
    CGPoint p = CGPointZero;
    CGPoint cp1 = CGPointZero;
    CGPoint cp2 = CGPointZero;
    CGFloat curve = size.height / 2;
    NSUInteger count = 2;
    CGFloat locations[count];
    CGFloat colors[count * 4];
    CGPoint points[count];
    CGFloat tgrayScale = enabled ? 0.9 : 0.5;
    
    ctx = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast));
    CGColorSpaceRelease(colorSpace);
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, 0.0, size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    path = CGPathCreateMutable();
    p.x = 0.0;
    p.y = 0.5;
    CGPathMoveToPoint(path, nil, p.x, p.y);
    p.x = size.width - (curve + 1.0);
    CGPathAddLineToPoint(path, nil, p.x, p.y);
    p.x = size.width;
    cp1.x = size.width;
    cp1.y = 0.5 + curve / 2;
    cp2.x = size.width - curve / 2;
    cp2.y = 0.5;
    p.y = curve + 0.5;
    CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
    p.x = size.width - curve;
    cp2.x = size.width;
    cp2.y = size.height - curve / 2 - 0.5;
    cp1.x = size.width - curve / 2;
    cp1.y = size.height - 0.5;
    p.y = size.height - 0.5;
    CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
    p.x = 0.0;
    CGPathAddLineToPoint(path, nil, p.x, p.y);
    p.y = 0.5;
    CGPathAddLineToPoint(path, nil, p.x, p.y);
    
    // Background
    locations[0] = 0.0;
    locations[1] = 1.0;
    colors[0] = colors[1] = colors[2] = 0.5;
    colors[3] = 1.0;
    colors[4] = colors[5] = colors[6] = 0.0;
    colors[7] = 1.0;
    points[0] = CGPointZero;
    points[1] = CGPointMake(0.0, size.height);
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, path);
    CGContextClip(ctx);
    SBDrawGradientInContext(ctx, count, locations, colors, points);
    CGContextRestoreGState(ctx);
    
    // Frame
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, path);
    CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 0.0, 1.0);
    CGContextSetLineWidth(ctx, 0.5);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    CGPathRelease(path);
    
    // Triangle
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, tpath);
    CGContextSetRGBFillColor(ctx, tgrayScale, tgrayScale, tgrayScale, 1.0);
    CGContextSetLineWidth(ctx, 0.5);
    CGContextFillPath(ctx);
    CGContextRestoreGState(ctx);
    
    image = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    return (CGImageRef)CFAutorelease(image);
}

CGImageRef SBBookmarkReflectionMaskImage(CGSize size)
{
    CGImageRef maskImage = nil;
    CGContextRef ctx = nil;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger count = 2;
    CGFloat locations[count];
    CGFloat colors[count * 4];
    CGPoint points[count];
    ctx = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast));
    CGColorSpaceRelease(colorSpace);
    locations[0] = 0.0;
    locations[1] = 1.0;
    colors[0] = colors[1] = colors[2] = 1.0;
    colors[3] = 0.2;
    colors[4] = colors[5] = colors[6] = 1.0;
    colors[7] = 0.0;
    points[0] = CGPointZero;
    points[1] = CGPointMake(0.0, size.height);
    CGContextSaveGState(ctx);
    CGContextAddRect(ctx, CGRectMake(0, 0, size.width, size.height));
    CGContextClip(ctx);
    SBDrawGradientInContext(ctx, count, locations, colors, points);
    CGContextRestoreGState(ctx);
    maskImage = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    return (CGImageRef)CFAutorelease(maskImage);
}

#pragma mark Math

NSInteger SBRemainder(NSInteger value1, NSInteger value2)
{
    return value1 - (value1 / value2) * value2;
}

BOOL SBRemainderIsZero(NSInteger value1, NSInteger value2)
{
    return SBRemainder(value1, value2) == 0;
}

NSInteger SBGreatestCommonDivisor(NSInteger a, NSInteger b)
{
    NSInteger v = 0;
    if (a == 0 || b == 0)
    {
        v = 0;
    }
    else {
        // Euclidean
        while(a != b)
        {
            if (a > b)
            {
                a = a - b;
            }
            else {
                b = b - a;
            }
        }
    }
    return v;
}

#pragma mark Others

id SBValueForKey(NSString *keyName, NSDictionary *dictionary)
{
    id value = nil;
    
    value = dictionary[keyName];
    if (value == nil) {
        for (id object in dictionary.allValues)
        {
            if ([object isKindOfClass:NSDictionary.class]) {
                value = SBValueForKey(keyName, object);
            }
        }
    }
    else if ([value isKindOfClass:NSDictionary.class])
    {
        value = ((NSDictionary *)value).allValues[0];
    }
    return value;
}

NSMenu *SBEncodingMenu(id target, SEL selector, BOOL showDefault)
{
    NSMenu *menu = [[NSMenu alloc] init];
    NSArray *encs = nil;
    NSMutableArray *mencs = [NSMutableArray arrayWithCapacity:0];
#if kSBFlagShowAllStringEncodings
    const NSStringEncoding *encoding = NSString.availableStringEncodings;
    NSData *hint = nil;
    
    // Get available encodings
    while (*encoding)
    {
        [mencs addObject:@(*encoding)];
        encoding++;
    }
    
    // Sort
    hint = [mencs sortedArrayHint];
    encs = [mencs sortedArrayUsingFunction:SBStringEncodingSortFunction context:nil hint:hint];
#else
    const NSStringEncoding *encoding = SBAvailableStringEncodings;
    // Get available encodings
    while (*encoding)   // Continue while encoding is NULL
    {
        [mencs addObject:@(*encoding)];
        encoding++;
    }
    encs = [mencs copy];
#endif
    
    // Create menu items
    for (NSNumber *enc in encs)
    {
        NSStringEncoding stringEncoding = enc.unsignedIntegerValue;
        if (stringEncoding == NSNotFound)
        {
            [menu addItem:NSMenuItem.separatorItem];
        }
        else {
            NSString *encodingName = nil;
            NSString *ianaName = nil;
            encodingName = [NSString localizedNameOfStringEncoding:stringEncoding];
            ianaName = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(enc.unsignedIntegerValue));
            DebugLog(@"%d\t%lu\t%@\t%@\t%@", CFStringIsEncodingAvailable(CFStringConvertNSStringEncodingToEncoding(enc.unsignedIntegerValue)), (unsigned long)stringEncoding, encodingName, (NSString *)CFStringGetNameOfEncoding(CFStringConvertNSStringEncodingToEncoding(enc.unsignedIntegerValue)), ianaName);
            if (encodingName)
            {
                NSMenuItem *item = nil;
                item = [[NSMenuItem alloc] initWithTitle:encodingName action:selector keyEquivalent:@""];
                if (target)
                    item.target = target;
                item.representedObject = ianaName;
                [menu addItem:item];
            }
        }
    }
    if (showDefault)
    {
        NSMenuItem *defaultItem = nil;
        defaultItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Default", nil) action:selector keyEquivalent:@""];
        if (target)
            defaultItem.target = target;
        defaultItem.representedObject = nil;
        [menu insertItem:NSMenuItem.separatorItem atIndex:0];
        [menu insertItem:defaultItem atIndex:0];
    }
    return menu;
}

NSComparisonResult SBStringEncodingSortFunction(id num1, id num2, void *context)
{
    NSComparisonResult r = NSOrderedSame;
    NSString *enc1 = [NSString localizedNameOfStringEncoding:[num1 unsignedIntegerValue]];
    NSString *enc2 = [NSString localizedNameOfStringEncoding:[num2 unsignedIntegerValue]];
    r = [enc1 compare:enc2];
    return r;
}

NSInteger SBUnsignedIntegerSortFunction(id num1, id num2, void *context)
{
    NSInteger r = NSOrderedSame;
    NSUInteger v1 = [num1 unsignedIntegerValue];
    NSUInteger v2 = [num2 unsignedIntegerValue];
    if (v1 < v2)
    {
        r = NSOrderedAscending;
    }
    else if (v1 > v2)
    {
        r = NSOrderedDescending;
    }
    return r;
}

void SBRunAlertWithMessage(NSString *message)
{
    NSRunAlertPanel(NSLocalizedString(@"Error", nil), message, NSLocalizedString(@"OK", nil), nil, nil);
}

void SBDisembedViewInSplitView(NSView *view, NSSplitView *splitView)
{
    NSRect r = splitView.frame;
    id superview = splitView.superview;
    if (superview)
    {
        view.frame = r;
        [view removeFromSuperview];
        [superview addSubview:view];
        [splitView removeFromSuperview];
    }
}

CGFloat SBDistancePoints(NSPoint p1, NSPoint p2)
{
    return sqrtf((p2.x - p1.x) * (p2.x - p1.x) + (p2.y - p1.y) * (p2.y - p1.y));
}

BOOL SBAllowsDrag(NSPoint downPoint, NSPoint dragPoint)
{
    return SBDistancePoints(downPoint, dragPoint) > 10;
}

void SBLocalizeTitlesInMenu(NSMenu *menu)
{
    NSString *mtitle = menu.title;
    NSString *mlocalizedTitle = NSLocalizedString(mtitle, nil);
    if (![mtitle isEqualToString:mlocalizedTitle])
    {
        menu.title = mlocalizedTitle;
    }
    for (NSMenuItem *item in menu.itemArray)
    {
        NSMenu *submenu = item.submenu;
        NSString *title = item.title;
        NSString *localizedTitle = NSLocalizedString(title, nil);
        if (![title isEqualToString:localizedTitle])
        {
            item.title = localizedTitle;
        }
        if (submenu)
        {
            SBLocalizeTitlesInMenu(submenu);
        }
    }
}*/

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

/*NSData *SBLocalizableStringsData(NSArray *fieldSet)
{
    NSData *data = nil;
    NSMutableString *string = [NSMutableString stringWithCapacity:0];
    [string appendString:[NSString string]];
    for (NSArray *fields in fieldSet)
    {
        NSTextField *field0 = nil;
        NSTextField *field1 = nil;
        NSString *text0 = nil;
        NSString *text1 = nil;
        if ([fields count] == 1)
        {
            field0 = fields[0];
            text0 = field0 ? field0.stringValue : nil;
            if (text0)
            {
                [string appendFormat:@"\n%@\n", text0];
            }
        }
        else if ([fields count] == 2)
        {
            field0 = fields[0];
            field1 = fields[1];
            text0 = field0 ? field0.stringValue : nil;
            text1 = field1 ? field1.stringValue : nil;
            if (text0 && text1)
            {
                [string appendFormat:@"\"%@\" = \"%@\";\n", text0, text1];
            }
        }
    }
    if ([string length] > 0)
    {
        data = [string dataUsingEncoding:NSUTF16StringEncoding];
    }
    return data;
}

#pragma mark Debug

NSDictionary *SBDebugViewStructure(NSView *view)
{
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:0];
    NSArray *subviews = view.subviews;
    NSString *description = nil;
    if ([view isKindOfClass:SBView.class])
        description = view.description;
    else
        description = [NSString stringWithFormat:@"%@ %@", view, NSStringFromRect(view.frame)];
    info[@"Description"] = description;
    if (subviews.count > 0)
    {
        NSMutableArray *children = [NSMutableArray arrayWithCapacity:0];
        for (id subview in subviews)
        {
            [children addObject:SBDebugViewStructure(subview)];
        }
        info[@"Children"] = [children copy];
    }
    return [info copy];
}

NSDictionary *SBDebugLayerStructure(CALayer *layer)
{
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:0];
    NSArray *sublayers = layer.sublayers;
    NSString *description = nil;
    description = [NSString stringWithFormat:@"%@ %@", layer, NSStringFromRect(NSRectFromCGRect([layer frame]))];
    info[@"Description"] = description;
    if (sublayers.count > 0)
    {
        NSMutableArray *children = [NSMutableArray arrayWithCapacity:0];
        for (id sublayer in sublayers)
        {
            [children addObject:SBDebugLayerStructure(sublayer)];
        }
        info[@"Children"] = [children copy];
    }
    return [info copy];
}

NSDictionary *SBDebugDumpMainMenu()
{
    return @{@"MenuItems": SBDebugDumpMenu(NSApplication.sharedApplication.mainMenu)};
}

NSArray *SBDebugDumpMenu(NSMenu *menu)
{
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:0];
    for (NSMenuItem *item in menu.itemArray)
    {
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:0];
        NSMenu *submenu = item.submenu;
        NSString *title = item.title;
        id target = item.target;
        SEL action = item.action;
        NSInteger tag = item.tag;
        NSInteger state = item.state;
        NSImage *image = item.image;
        NSString *keyEquivalent = item.keyEquivalent;
        NSUInteger keyEquivalentModifierMask = item.keyEquivalentModifierMask;
        NSString *toolTip = item.toolTip;
        if (title)
            info[@"Title"] = title;
        if (target)
            info[@"Target"] = [NSString stringWithFormat:@"%@", target];
        if (action)
            info[@"Action"] = NSStringFromSelector(action);
        info[@"Tag"] = @(tag);
        info[@"State"] = @(state);
        if (image)
            info[@"Image"] = image.TIFFRepresentation;
        if (keyEquivalent)
            info[@"KeyEquivalent"] = keyEquivalent;
        info[@"KeyEquivalentModifierMask"] = @(keyEquivalentModifierMask);
        if (toolTip)
            info[@"ToolTip"] = toolTip;
        if (submenu)
        {
            info[@"MenuItems"] = SBDebugDumpMenu(submenu);
        }
        [items addObject:[info copy]];
    }
    return [items copy];
}

BOOL SBDebugWriteViewStructure(NSView *view, NSString *path)
{
    BOOL r = NO;
    NSDictionary *info = SBDebugViewStructure(view);
    r = [info writeToFile:path atomically:YES];
    return r;
}

BOOL SBDebugWriteLayerStructure(CALayer *layer, NSString *path)
{
    BOOL r = NO;
    NSDictionary *info = SBDebugLayerStructure(layer);
    r = [info writeToFile:path atomically:YES];
    return r;
}

BOOL SBDebugWriteMainMenu(NSString *path)
{
    BOOL r = NO;
    NSDictionary *info = SBDebugDumpMainMenu();
    r = [info writeToFile:path atomically:YES];
    return r;
}

void SBPerform(id target, SEL action, id object) {
    [target performSelector:action withObject: object];
}

void SBPerformWithModes(id target, SEL action, id object, NSArray *modes) {
    [target performSelector:action withObject:object afterDelay:0 inModes:modes];
}

kern_return_t SBCPUType(cpu_type_t *cpuType) {
    host_basic_info_data_t hostInfo;
    mach_msg_type_number_t infoCount = HOST_BASIC_INFO_COUNT;
    kern_return_t result = host_info(mach_host_self(), HOST_BASIC_INFO, (host_info_t)&hostInfo, &infoCount);
    if (result == KERN_SUCCESS) {
        *cpuType = hostInfo.cpu_type;
    }
    return result;
}
*/

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