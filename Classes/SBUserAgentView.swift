/*
SBUserAgentView.swift

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

class SBUserAgentView: SBView, NSTextFieldDelegate {
    private lazy var iconImageView: NSImageView = {
        let iconImageView = NSImageView(frame: self.iconRect)
        let image = NSImage(named: "UserAgent")
        image.size = iconImageView.frame.size
        iconImageView.image = image
        return iconImageView
    }()
    private lazy var titleLabel: NSTextField = {
        let titleLabel = NSTextField(frame: self.titleRect)
        titleLabel.stringValue = NSLocalizedString("Select User Agent", comment: "")
        titleLabel.bordered = false
        titleLabel.editable = false
        titleLabel.selectable = false
        titleLabel.drawsBackground = false
        titleLabel.font = NSFont.boldSystemFontOfSize(16.0)
        titleLabel.textColor = NSColor.whiteColor()
        titleLabel.autoresizingMask = .ViewWidthSizable
        return titleLabel
    }()
    private lazy var popup: SBBLKGUIPopUpButton = {
        var selectedIndex: Int?
        let popup = SBBLKGUIPopUpButton(frame: self.popupRect)
        let count = SBUserAgentNames.count
        if let userAgentName = NSUserDefaults.standardUserDefaults().objectForKey(kSBUserAgentName) as? String {
            if let index = SBUserAgentNames.firstIndex({ $0 == userAgentName }) {
                selectedIndex = index + 1
            }
        }
        if selectedIndex == nil {
            selectedIndex = count
            self.field.stringValue = self.userAgentName
            self.field.hidden = false
        }
        let icon0: NSImage? = (SBUserAgentNames[0] == "Sunrise") ? NSImage(named: "Application.icns") : nil
        let icon1: NSImage? = (SBUserAgentNames[1] == "Safari") ? NSImage(contentsOfFile: "/Applications/Safari.app/Contents/Resources/compass.icns") : nil
        icon0?.size = NSMakeSize(24.0, 24.0)
        icon1?.size = NSMakeSize(24.0, 24.0)
        let images = [icon0, icon1]
        popup.menu.addItemWithTitle("", action: nil, keyEquivalent: "")
        for i in 0..<count {
            let item = NSMenuItem(title: NSLocalizedString(SBUserAgentNames[i], comment: ""), action: "selectApp:", keyEquivalent: "")
            item.target = self
            if i < 2 {
                item.image = images[i]
            }
            item.tag = i
            popup.menu.addItem(item)
        }
        popup.pullsDown = true
        popup.selectItemAtIndex(selectedIndex!)
        return popup
    }()
    private lazy var field: SBBLKGUITextField = {
        let field = SBBLKGUITextField(frame: self.fieldRect)
        field.alignment = .LeftTextAlignment
        field.font = NSFont.systemFontOfSize(14.0)
        field.textColor = NSColor.whiteColor()
        field.delegate = self
        (field.cell() as NSCell).wraps = true
        field.hidden = true
        return field
    }()
    private lazy var cancelButton: SBBLKGUIButton = {
        let cancelButton = SBBLKGUIButton(frame: self.cancelRect)
        cancelButton.title = NSLocalizedString("Cancel", comment: "")
        cancelButton.target = self
        cancelButton.action = "cancel"
        cancelButton.keyEquivalent = "\u{1B}"
        return cancelButton
    }()
    private lazy var doneButton: SBBLKGUIButton = {
        let doneButton = SBBLKGUIButton(frame: self.doneRect)
        doneButton.title = NSLocalizedString("Done", comment: "")
        doneButton.target = self
        doneButton.enabled = !self.userAgentName.isEmpty
        doneButton.action = "done"
        doneButton.keyEquivalent = "\r"
        return doneButton
    }()

    override init(frame: NSRect) {
        super.init(frame: frame)
        addSubview(cancelButton)
        addSubview(doneButton)
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(popup)
        addSubview(field)
        autoresizingMask = .ViewMinXMargin | .ViewMaxXMargin | .ViewMinYMargin | .ViewMaxYMargin
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    // MARK: Rects
    
    let margin = NSMakePoint(20.0, 20.0);
    let labelWidth: CGFloat = 60.0
    var iconRect: NSRect {
        var r = NSZeroRect
        r.size.width = 32.0
        r.origin.x = labelWidth - r.size.width
        r.size.height = 32.0
        r.origin.y = bounds.size.height - margin.y - r.size.height
        return r
    }
    
    var titleRect: NSRect {
        var r = NSZeroRect
        r.origin.x = NSMaxX(iconRect) + 10.0;
        r.size.width = bounds.size.width - r.origin.x - margin.x
        r.size.height = 19.0
        r.origin.y = bounds.size.height - margin.y - r.size.height - (32.0 - r.size.height) / 2
        return r
    }
    
    var popupRect: NSRect {
        var r = NSZeroRect
        r.origin.x = iconRect.origin.x
        r.size.width = bounds.size.width - r.origin.x - margin.x
        r.size.height = 26;
        r.origin.y = iconRect.origin.y - 20.0 - r.size.height
        return r
    }
    
    var fieldRect: NSRect {
        var r = NSZeroRect
        r.origin.x = popupRect.origin.x
        r.size.width = bounds.size.width - r.origin.x - margin.x
        r.size.height = 58.0
        r.origin.y = popupRect.origin.y - 20.0 - r.size.height
        return r
    }
    
    var cancelRect: NSRect {
        var r = NSZeroRect
        r.size.width = 124.0
        r.size.height = 32.0
        r.origin.x = bounds.size.width - (margin.x + r.size.width * 2 + 8.0)
        r.origin.y = margin.y
        return r
    }
    
    var doneRect: NSRect {
        var r = NSZeroRect
        r.size.width = 124.0
        r.size.height = 32.0
        r.origin.x = bounds.size.width - (margin.x + r.size.width)
        r.origin.y = margin.y
        return r
    }
    
    var userAgentName: String {
        let selectedIndex = popup.indexOfSelectedItem
        if selectedIndex == SBCountOfUserAgentNames {
            return field.stringValue
        }
        return SBUserAgentNames[selectedIndex - 1]
    }
    
    // MARK: Delegate
    
    override func controlTextDidChange(notification: NSNotification) {
        doneButton.enabled = !userAgentName.isEmpty
    }
    
    // MARK: Actions
    
    func selectApp(sender: AnyObject) {
        let selectedIndex = popup.indexOfSelectedItem
        if selectedIndex == SBUserAgentNames.count {
            field.hidden = false
            field.selectText(nil)
        } else {
            field.hidden = true
        }
        doneButton.enabled = !userAgentName.isEmpty
    }
    
    override func done() {
        NSUserDefaults.standardUserDefaults().setObject(userAgentName, forKey: kSBUserAgentName)
        super.done()
    }
}