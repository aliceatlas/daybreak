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

import BLKGUI

class SBUserAgentView: SBView, NSTextFieldDelegate {
    private lazy var iconImageView: NSImageView = {
        let image = NSImage(named: "UserAgent")!
        let iconImageView = NSImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        image.size = iconImageView.frame.size
        iconImageView.image = image
        return iconImageView
    }()
    
    private lazy var titleLabel: NSTextField = {
        let titleLabel = NSTextField()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
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
    
    private lazy var popup: BLKGUI.PopUpButton = {
        let popup = BLKGUI.PopUpButton()
        popup.translatesAutoresizingMaskIntoConstraints = false
        let count = SBUserAgentNames.count
        let userAgentName = NSUserDefaults.standardUserDefaults().stringForKey(kSBUserAgentName)!
        var selectedIndex: Int!
        if let index = SBUserAgentNames.firstIndex({$0 == userAgentName}) {
            selectedIndex = index + 1
        } else {
            selectedIndex = count
            self.field.stringValue = userAgentName
            self.field.hidden = false
        }
        let icon0 = (SBUserAgentNames[0] == "Daybreak") &? NSImage(named: "Application.icns")
        let icon1 = (SBUserAgentNames[1] == "Safari") &? NSImage(contentsOfFile: "/Applications/Safari.app/Contents/Resources/compass.icns")
        icon0?.size = NSMakeSize(24.0, 24.0)
        icon1?.size = NSMakeSize(24.0, 24.0)
        let images = [icon0, icon1]
        popup.menu!.addItemWithTitle("", action: nil, keyEquivalent: "")
        for i in 0..<count {
            let item = NSMenuItem(title: NSLocalizedString(SBUserAgentNames[i], comment: ""), action: "selectApp:", keyEquivalent: "")
            item.target = self
            if i < 2 {
                item.image = images[i]
            }
            item.tag = i
            popup.menu!.addItem(item)
        }
        popup.pullsDown = true
        popup.selectItemAtIndex(selectedIndex)
        return popup
    }()
    
    private lazy var field: BLKGUI.TextField = {
        let field = BLKGUI.TextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.alignment = .LeftTextAlignment
        field.font = NSFont.systemFontOfSize(14.0)
        field.textColor = NSColor.whiteColor()
        field.delegate = self
        field.cell!.wraps = true
        field.hidden = true
        return field
    }()
    
    private lazy var cancelButton: BLKGUI.Button = {
        let cancelButton = BLKGUI.Button()
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.title = NSLocalizedString("Cancel", comment: "")
        cancelButton.target = self
        cancelButton.action = "cancel"
        cancelButton.keyEquivalent = "\u{1B}"
        return cancelButton
    }()
    
    private lazy var doneButton: BLKGUI.Button = {
        let doneButton = BLKGUI.Button()
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.title = NSLocalizedString("Done", comment: "")
        doneButton.target = self
        doneButton.enabled = !self.userAgentName.isEmpty
        doneButton.action = "done"
        doneButton.keyEquivalent = "\r"
        return doneButton
    }()
    
    var userAgentName: String {
        let selectedIndex = popup.indexOfSelectedItem
        if selectedIndex == SBUserAgentNames.count {
            return field.stringValue
        }
        return SBUserAgentNames[selectedIndex - 1]
    }
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        
        addSubviewsAndConstraintStrings(
            metrics: ["margin": 20.0, "submargin": 10.0],
            views: ["done": doneButton, "cancel": cancelButton, "popup": popup, "icon": iconImageView, "title": titleLabel, "field": field],
            "[cancel(124)]-8-[done(124)]-margin-|",
            "V:[cancel(23)]-margin-|",
            "V:[done(23)]-margin-|",
            "|-margin-[popup]-margin-|",
            "|-margin-[field]-margin-|",
            "|-margin-[icon(32)]-submargin-[title]-margin-|",
            "V:|-margin-[icon(32)]-margin-[popup(26)]-submargin-[field]-margin-[done]",
            "V:|-\(20+7)-[title(19)]"
        )
        
        autoresizingMask = [.ViewMinXMargin, .ViewMaxXMargin, .ViewMinYMargin, .ViewMaxYMargin]
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
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