/*
SBSectionListView.swift

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

import BLKGUI

private let kSBSectionTitleHeight: CGFloat = 32.0
private let kSBSectionItemHeight: CGFloat = 32.0
private let kSBSectionMarginX: CGFloat = 10.0
private let kSBSectionTopMargin: CGFloat = 10.0
private let kSBSectionBottomMargin: CGFloat = 20.0
private let kSBSectionMarginY: CGFloat = kSBSectionTopMargin + kSBSectionBottomMargin
private let kSBSectionInnerMarginX: CGFloat = 15.0

class SBSectionListView: SBView {
    private lazy var contentView: NSView = { NSView(frame: self.bounds) }()
    
    private var sectionGroupViews: [SBSectionGroupView] = []

    private lazy var scrollView: NSScrollView = {
        let clipView = BLKGUI.ClipView(frame: self.bounds)
        let scrollView = NSScrollView(frame: self.bounds)
        scrollView.contentView = clipView
        scrollView.autoresizingMask = [.ViewWidthSizable, .ViewHeightSizable]
        scrollView.drawsBackground = false
        scrollView.hasHorizontalScroller = false
        scrollView.hasVerticalScroller = true
        scrollView.documentView = self.contentView
        scrollView.autohidesScrollers = true
        return scrollView
    }()
    
    var sections: [SBSectionGroup] = [] {
        didSet {
            if sections != oldValue {
                contentView.frame = contentViewRect
                contentView.scrollRectToVisible(NSMakeRect(0, contentView.frame.maxY, 0, 0))
                constructSectionGroupViews()
            }
        }
    }
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        addSubview(scrollView)
    }

    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    private var contentViewRect: NSRect {
        var r = NSZeroRect
        r.size.width = bounds.size.width - 20.0
        for group in sections {
            r.size.height += CGFloat(group.items.count) * kSBSectionItemHeight + kSBSectionTitleHeight + kSBSectionMarginY
        }
        return r
    }
    
    private func groupViewRectAtIndex(index: Int) -> NSRect {
        var r = NSZeroRect
        let height = contentViewRect.size.height
        r.size.width = bounds.size.width - 20.0
        for (i, group) in enumerate(sections) {
            let h = CGFloat(group.items.count) * kSBSectionItemHeight + kSBSectionTitleHeight + kSBSectionMarginY
            if i < index {
                r.origin.y += h
            } else {
                r.size.height = h
                break
            }
        }
        r.origin.y = height - r.maxY
        return r
    }
    
    private func constructSectionGroupViews() {
        for sectionView in sectionGroupViews {
            sectionView.removeFromSuperview()
        }
        sectionGroupViews = []
        for (i, group) in enumerate(sections) {
            let gr = groupViewRectAtIndex(i)
            let groupView = SBSectionGroupView(frame: gr, group: group)
            groupView.autoresizingMask = .ViewWidthSizable
            for item in group.items {
                let itemView = SBSectionItemView(item: item)
                itemView.autoresizingMask = .ViewWidthSizable
                groupView.addItemView(itemView)
            }
            contentView.addSubview(groupView)
        }
    }
}


class SBSectionGroupView: SBView {
    var itemViews: [SBSectionItemView] = []
    var group: SBSectionGroup
    
    init(frame: NSRect, group: SBSectionGroup) {
        self.group = group
        super.init(frame: frame)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    private func itemViewRectAtIndex(index: Int) -> NSRect {
        var r = NSZeroRect
        r.size.width = bounds.size.width - kSBSectionMarginX * 2
        r.size.height = kSBSectionItemHeight
        r.origin.x = kSBSectionMarginX
        r.origin.y = CGFloat(index) * kSBSectionItemHeight + kSBSectionTitleHeight + kSBSectionTopMargin
        r.origin.y = bounds.size.height - r.maxY
        return r
    }
    
    func addItemView(itemView: SBSectionItemView) {
        itemView.frame = itemViewRectAtIndex(itemViews.count)
        itemView.constructControl()
        itemViews.append(itemView)
        addSubview(itemView)
    }
    
    override func drawRect(rect: NSRect) {
        var r = bounds
        r.origin.x += kSBSectionMarginX
        r.origin.y += kSBSectionBottomMargin
        r.size.width -= kSBSectionMarginX * 2
        r.size.height -= kSBSectionMarginY
    
        // Paths
        // Gray scales
        let path = NSBezierPath(roundedRect: r, xRadius: 8.0, yRadius: 8.0)
        let strokePath = NSBezierPath(roundedRect: NSInsetRect(r, 0.5, 0.5), xRadius: 8.0, yRadius: 8.0)
        let shadowColor = NSColor(calibratedWhite: 0.5, alpha: 1.0)
        let shadow = NSShadow()
        shadow.shadowColor = shadowColor
        shadow.shadowBlurRadius = 5.0
        
        // Fill
        SBPreserveGraphicsState {
            shadow.shadowOffset = NSMakeSize(0.0, -2.0)
            shadow.set()
            NSColor.whiteColor().set()
            path.fill()
        }
        
        // Gradient
        SBPreserveGraphicsState {
            shadow.shadowOffset = NSMakeSize(0.0, 10.0)
            shadow.set()
            let gradient = NSGradient(startingColor: NSColor(deviceWhite: 0.9, alpha: 1.0),
                                      endingColor: NSColor.whiteColor())!
            gradient.drawInBezierPath(path, angle: 90)
        }
        
        // Stroke
        let strokeColor = NSColor(deviceWhite: 0.2, alpha: 1.0)
        strokeColor.set()
        strokePath.lineWidth = 0.5
        strokePath.stroke()
        
        let groupTitle = group.title as NSString
        var attributes: [String: AnyObject]
        var tr = r
        tr.origin.x += kSBSectionInnerMarginX
        tr.size.height = 24.0
        tr.origin.y += r.size.height - tr.size.height - 5.0
        tr.size.width -= kSBSectionInnerMarginX * 2
        attributes = [NSFontAttributeName: NSFont.boldSystemFontOfSize(13.0),
                      NSForegroundColorAttributeName: NSColor(calibratedWhite: 0.65, alpha: 1.0)]
        groupTitle.drawInRect(tr, withAttributes: attributes)
        tr.origin.y -= 1.0
        tr.origin.x += 1.0
        attributes = [NSFontAttributeName: NSFont.boldSystemFontOfSize(13.0),
                      NSForegroundColorAttributeName: NSColor(calibratedWhite: 0.55, alpha: 1.0)]
        groupTitle.drawInRect(tr, withAttributes: attributes)
        tr.origin.x -= 2.0
        attributes = [NSFontAttributeName: NSFont.boldSystemFontOfSize(13.0),
                      NSForegroundColorAttributeName: NSColor(calibratedWhite: 0.55, alpha: 1.0)]
        groupTitle.drawInRect(tr, withAttributes: attributes)
        tr.origin.y -= 2.0
        tr.origin.x += 1.0
        attributes = [NSFontAttributeName: NSFont.boldSystemFontOfSize(13.0),
                      NSForegroundColorAttributeName: NSColor(calibratedWhite: 0.45, alpha: 1.0)]
        groupTitle.drawInRect(tr, withAttributes: attributes)
        tr.origin.y += 2.0
        attributes = [NSFontAttributeName: NSFont.boldSystemFontOfSize(13.0),
                      NSForegroundColorAttributeName: NSColor.whiteColor()]
        groupTitle.drawInRect(tr, withAttributes: attributes)
    }
}

class SBSectionItemView: SBView, NSTextFieldDelegate {
    var item: SBSectionItem
    weak var currentImageView: NSImageView?
    weak var currentField: NSTextField?
    
    init(item: SBSectionItem) {
        self.item = item
        super.init(frame: .zero)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    var titleRect: NSRect {
        var r = bounds
        r.size.width = r.size.width * 0.4
        return r
    }
    
    var valueRect: NSRect {
        var r = bounds
        let margin: CGFloat = 10.0
        r.origin.x = r.size.width * 0.4 + margin
        r.size.width = r.size.width * 0.6 - margin * 2
        return r
    }
    
    func constructControl() {
        var r = valueRect
        if item.controlClass === NSPopUpButton.self {
            let string = SBPreferences.objectForKey(item.keyName) as? String
            r.origin.y = (r.size.height - 26.0) / 2
            r.size.height = 26.0
            let popUp = NSPopUpButton(frame: r, pullsDown: false)
            if let menu = item.context as? NSMenu {
                popUp.target = self
                popUp.action = #selector(select(_:))
                popUp.menu = menu
            }
            if let selectedItem = popUp.menu!.selectItem(representedObject: string) {
                popUp.selectItem(selectedItem)
            }
            addSubview(popUp)
        } else if item.controlClass === NSTextField.self {
            r.origin.y = (r.size.height - 22.0) / 2
            r.size.height = 22.0
            let field = NSTextField(frame: r)
            field.delegate = self
            field.focusRingType = .None
            field.cell!.placeholderString = item.context as? String
            field.stringValue = (SBPreferences.objectForKey(item.keyName) as? String) ?? ""
            addSubview(field)
        } else if item.controlClass === NSOpenPanel.self {
            var fr = r
            var ir = r
            var br = r
            ir.size.width = 22
            br.size.width = 120
            fr.origin.x += ir.size.width
            fr.size.width -= ir.size.width + br.size.width
            br.origin.x += ir.size.width + fr.size.width
            ir.origin.y = (ir.size.height - 22.0) / 2
            ir.size.height = 22.0
            fr.origin.y = (fr.size.height - 22.0) / 2
            fr.size.height = 22.0
            br.origin.y = (br.size.height - 32.0) / 2
            br.size.height = 32.0
            let button = NSButton(frame: br)
            button.target = self
            button.action = #selector(open(_:))
            button.title = NSLocalizedString("Open…", comment: "")
            button.setButtonType(.MomentaryLightButton)
            button.bezelStyle = .RoundedBezelStyle
            
            let imageView = NSImageView(frame: ir)
            let space = NSWorkspace.sharedWorkspace()
            let path = SBPreferences.objectForKey(item.keyName) as? String
            if let image = path !! space.iconForFile {
                image.size = NSMakeSize(16.0, 16.0)
                imageView.image = image
            }
            imageView.imageFrameStyle = .None
            
            let field = NSTextField(frame: fr)
            field.bordered = false
            field.selectable = false
            field.editable = false
            field.drawsBackground = false
            field.cell!.placeholderString = item.context as? String
            field.stringValue = path?.stringByAbbreviatingWithTildeInPath ?? ""
            
            addSubview(imageView)
            addSubview(field)
            addSubview(button)
            currentImageView = imageView
            currentField = field
        } else if item.controlClass === NSButton.self {
            let enabled = SBPreferences.boolForKey(item.keyName)
            r.origin.y = (r.size.height - 18.0) / 2
            r.size.height = 18.0
            let button = NSButton(frame: r)
            button.target = self
            button.action = #selector(check(_:))
            button.setButtonType(.SwitchButton)
            button.title = (item.context as? String) ?? ""
            button.state = enabled ? NSOnState : NSOffState
            addSubview(button)
        }
    }
    
    // MARK: Delegate
    
    override func controlTextDidChange(notification: NSNotification) {
        let field = notification.object as! NSTextField
        let text = field.stringValue
        SBPreferences.setObject(text, forKey: item.keyName)
    }
    
    // MARK: Actions
    
    func select(sender: AnyObject) {
        //kSBOpenURLFromApplications
        //kSBDefaultEncoding
        if let selectedItem = (sender as? NSPopUpButton)?.selectedItem,
               representedObject: AnyObject = selectedItem.representedObject {
            SBPreferences.setObject(representedObject, forKey: item.keyName)
        }
    }
    
    func open(sender: AnyObject) {
        let panel = SBOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.beginSheetModalForWindow(window!) {
            panel.orderOut(nil)
            if $0 == NSFileHandlingPanelOKButton,
               let imageView = self.currentImageView,
                   field = self.currentField {
                let space = NSWorkspace.sharedWorkspace()
                let path = panel.URL!.path!
                let image = space.iconForFile(path)
                image.size = NSMakeSize(16.0, 16.0)
                imageView.image = image
                field.stringValue = path.stringByAbbreviatingWithTildeInPath
                SBPreferences.setObject(path, forKey: self.item.keyName)
            }
        }
    }
    
    func check(sender: AnyObject) {
        let enabled = sender.state == NSOnState
        SBPreferences.setBool(enabled, forKey: item.keyName)
    }
    
    // MARK: Drawing
    
    override func drawRect(rect: NSRect) {
        var r = bounds
        
        // Stroke
        let margin: CGFloat = 10.0
        let path = NSBezierPath()
        path.moveToPoint(NSMakePoint(r.origin.x + margin, r.maxY))
        path.lineToPoint(NSMakePoint(r.maxX - margin * 2, r.maxY))
        path.lineWidth = 0.5
        NSColor(deviceWhite: 0.6, alpha: 1.0).set()
        path.stroke()
        
        let titleString: NSString = item.title + " :"
        var titleRect = self.titleRect
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Right
        let attributes = [NSFontAttributeName: NSFont.boldSystemFontOfSize(12.0),
                          NSForegroundColorAttributeName: NSColor(calibratedWhite: 0.3, alpha: 1.0),
                          NSParagraphStyleAttributeName: paragraphStyle]
        titleRect.size.height = titleString.sizeWithAttributes(attributes).height
        titleRect.origin.y = (bounds.size.height - titleRect.size.height) / 2
        titleString.drawInRect(titleRect, withAttributes: attributes)
    }
}