/*
SBReportView.swift

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

class SBReportView: SBView, NSTextFieldDelegate {
    private let kSBMinFrameSizeWidth: CGFloat = 600
    private let kSBMaxFrameSizeWidth: CGFloat = 900
    private let kSBMinFrameSizeHeight: CGFloat = 480
    private let kSBMaxFrameSizeHeight: CGFloat = 720
    
    private lazy var iconImageView: NSImageView = {
        let iconImageView = NSImageView(frame: self.iconRect)
        if let image = NSImage(named: "Bug") {
            image.size = iconImageView.frame.size
            iconImageView.image = image
        }
        return iconImageView
    }()
    
    private lazy var titleLabel: NSTextField = {
        let titleLabel = NSTextField(frame: self.titleRect)
        titleLabel.stringValue = NSLocalizedString("Send Bug Report", comment: "")
        titleLabel.bordered = false
        titleLabel.editable = false
        titleLabel.selectable = false
        titleLabel.drawsBackground = false
        titleLabel.font = NSFont.boldSystemFontOfSize(16.0)
        titleLabel.textColor = NSColor.whiteColor()
        titleLabel.autoresizingMask = .ViewWidthSizable
        return titleLabel
    }()
    
    private lazy var summaryLabel: NSTextField = {
        let summaryLabel = NSTextField(frame: self.summaryLabelRect)
        summaryLabel.stringValue = NSLocalizedString("Summary", comment: "")
        summaryLabel.alignment = .RightTextAlignment
        summaryLabel.bordered = false
        summaryLabel.editable = false
        summaryLabel.selectable = false
        summaryLabel.drawsBackground = false
        summaryLabel.font = NSFont.systemFontOfSize(14.0)
        summaryLabel.textColor = NSColor.whiteColor()
        return summaryLabel
    }()
    
    private lazy var summaryField: BLKGUI.TextField = {
        let summaryField = BLKGUI.TextField(frame: self.summaryFieldRect)
        summaryField.alignment = .LeftTextAlignment
        summaryField.font = NSFont.systemFontOfSize(14.0)
        summaryField.textColor = NSColor.whiteColor()
        summaryField.delegate = self
        summaryField.cell!.wraps = true
        return summaryField
    }()
    
    private lazy var userAgentLabel: NSTextField = {
        let userAgentLabel = NSTextField(frame: self.userAgentLabelRect)
        userAgentLabel.stringValue = NSLocalizedString("User Agent", comment: "")
        userAgentLabel.alignment = .RightTextAlignment
        userAgentLabel.bordered = false
        userAgentLabel.editable = false
        userAgentLabel.selectable = false
        userAgentLabel.drawsBackground = false
        userAgentLabel.font = NSFont.systemFontOfSize(14.0)
        userAgentLabel.textColor = NSColor.whiteColor()
        return userAgentLabel
    }()
    
    private lazy var userAgentPopup: BLKGUI.PopUpButton = {
        let userAgentPopup = BLKGUI.PopUpButton(frame: self.userAgentPopupRect)
        let menu = userAgentPopup.menu!
        var names: [String] = []
        let name0: String = SBUserAgentNames[0]
        let name1: String = SBUserAgentNames[1]
        let icon0 = (name0 == "Daybreak") &? NSImage(named: "Application.icns")
        let icon1 = (name1 == "Safari") &? NSImage(contentsOfFile: "/Applications/Safari.app/Contents/Resources/compass.icns")
        icon0?.size = NSMakeSize(24.0, 24.0)
        icon1?.size = NSMakeSize(24.0, 24.0)
        let userAgentName = NSUserDefaults.standardUserDefaults().stringForKey(kSBUserAgentName)
        names.append(name0)
        names.append(name1)
        if userAgentName?.ifNotEmpty &! {$0 != name0 && $0 != name1} {
            names.append(userAgentName!)
        }
        let images = [icon0, icon1]
        menu.addItemWithTitle("", action: nil, keyEquivalent: "")
        for (i, name) in enumerate(names) {
            let item = NSMenuItem(title: name, action: "selectApp:", keyEquivalent: "")
            item.target = self
            if i < 2 {
                item.image = images[i]
            }
            menu.addItem(item)
        }
        userAgentPopup.pullsDown = true
        if let selectedIndex = userAgentName !! userAgentPopup.indexOfItemWithTitle {
            userAgentPopup.selectItemAtIndex(selectedIndex)
        }
        return userAgentPopup
    }()
    
    private lazy var switchLabel: NSTextField = {
        let switchLabel = NSTextField(frame: self.switchLabelRect)
        switchLabel.stringValue = NSLocalizedString("Reproducibility", comment: "")
        switchLabel.alignment = .RightTextAlignment
        switchLabel.bordered = false
        switchLabel.editable = false
        switchLabel.selectable = false
        switchLabel.drawsBackground = false
        switchLabel.font = NSFont.systemFontOfSize(14.0)
        switchLabel.textColor = NSColor.whiteColor()
        return switchLabel
    }()
    
    private lazy var switchMatrix: NSMatrix = {
        let cell = BLKGUI.ButtonCell()
        cell.buttonType = .RadioButton
        let switchMatrix = NSMatrix(frame: self.switchRect, mode: .RadioModeMatrix, prototype: cell, numberOfRows: 1, numberOfColumns: 2)
        switchMatrix.cellSize = NSMakeSize(150.0, 18.0)
        switchMatrix.drawsBackground = false
        (switchMatrix.cellAtRow(0, column: 0) as! NSCell).title = NSLocalizedString("Describe", comment: "")
        (switchMatrix.cellAtRow(0, column: 1) as! NSCell).title = NSLocalizedString("None", comment: "")
        switchMatrix.target = self
        switchMatrix.action = "switchReproducibility:"
        return switchMatrix
    }()
    
    private lazy var wayLabel: NSTextField = {
        let wayLabel = NSTextField(frame: self.wayLabelRect)
        wayLabel.stringValue = NSLocalizedString("A way to reproduce", comment: "")
        wayLabel.alignment = .RightTextAlignment
        wayLabel.bordered = false
        wayLabel.editable = false
        wayLabel.selectable = false
        wayLabel.drawsBackground = false
        wayLabel.font = NSFont.systemFontOfSize(14.0)
        wayLabel.textColor = NSColor.whiteColor()
        return wayLabel
    }()
    
    private lazy var wayField: BLKGUI.TextField = {
        let wayField = BLKGUI.TextField(frame: self.wayFieldRect)
        wayField.alignment = .LeftTextAlignment
        wayField.font = NSFont.systemFontOfSize(14.0)
        wayField.textColor = NSColor.whiteColor()
        wayField.delegate = self
        wayField.cell!.wraps = true
        return wayField
    }()
    
    private lazy var cancelButton: BLKGUI.Button = {
        let cancelButton = BLKGUI.Button(frame: self.cancelRect)
        cancelButton.title = NSLocalizedString("Cancel", comment: "")
        cancelButton.target = self
        cancelButton.action = "cancel"
        cancelButton.keyEquivalent = "\u{1B}"
        return cancelButton
    }()
    
    private lazy var doneButton: BLKGUI.Button = {
        let doneButton = BLKGUI.Button(frame: self.doneRect)
        doneButton.title = NSLocalizedString("Done", comment: "")
        doneButton.target = self
        doneButton.action = "send"
        doneButton.enabled = false
        doneButton.keyEquivalent = "\r"
        return doneButton
    }()
    
    override init(frame: NSRect) {
        var r = frame
        SBConstrain(&r.size.width, min: kSBMinFrameSizeWidth, max: kSBMaxFrameSizeWidth)
        SBConstrain(&r.size.width, min: kSBMinFrameSizeHeight, max: kSBMaxFrameSizeHeight)
        super.init(frame: r)
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(summaryLabel)
        addSubview(summaryField)
        addSubview(userAgentLabel)
        addSubview(userAgentPopup)
        addSubview(switchLabel)
        addSubview(switchMatrix)
        addSubview(wayLabel)
        addSubview(wayField)
        addSubview(cancelButton)
        addSubview(doneButton)
        autoresizingMask = .ViewMinXMargin | .ViewMaxXMargin | .ViewMinYMargin | .ViewMaxYMargin
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    // MARK: Rects
    
    let margin = NSMakePoint(20.0, 20.0)
    let labelWidth: CGFloat = 200.0
    
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
        r.origin.x = iconRect.maxX + 10.0
        r.size.width = bounds.size.width - r.origin.x - margin.x
        r.size.height = 19.0
        r.origin.y = bounds.size.height - margin.y - r.size.height - (32.0 - r.size.height) / 2
        return r
    }
    
    var summaryLabelRect: NSRect {
        var r = NSZeroRect
        r.origin.x = margin.x
        r.size.width = labelWidth - r.origin.x
        r.size.height = 19.0
        r.origin.y = iconRect.origin.y - 20.0 - r.size.height
        return r
    }
    
    var summaryFieldRect: NSRect {
        var r = NSZeroRect
        r.origin.x = summaryLabelRect.maxX + 8.0
        r.size.width = bounds.size.width - r.origin.x - margin.x
        r.size.height = 58.0
        r.origin.y = summaryLabelRect.maxY - r.size.height + 2.0
        return r
    }
    
    var userAgentLabelRect: NSRect {
        var r = NSZeroRect
        r.origin.x = margin.x
        r.size.width = labelWidth - r.origin.x
        r.size.height = 19.0
        r.origin.y = summaryFieldRect.origin.y - 20.0 - r.size.height
        return r
    }
    
    var userAgentPopupRect: NSRect {
        var r = NSZeroRect
        r.origin.x = userAgentLabelRect.maxX + 8.0
        r.size.width = bounds.size.width - r.origin.x - margin.x
        r.size.height = 26.0
        r.origin.y = userAgentLabelRect.maxY - r.size.height + 2.0
        return r
    }
    
    var switchLabelRect: NSRect {
        var r = NSZeroRect
        r.origin.x = margin.x
        r.size.width = labelWidth - r.origin.x
        r.size.height = 19.0
        r.origin.y = userAgentPopupRect.origin.y - 20.0 - r.size.height
        return r
    }
    
    var switchRect: NSRect {
        var r = NSZeroRect
        r.origin.x = switchLabelRect.maxX + 8.0
        r.size.width = bounds.size.width - r.origin.x - margin.x
        r.size.height = 18.0
        r.origin.y = switchLabelRect.maxY - r.size.height
        return r
    }
    
    var wayLabelRect: NSRect {
        var r = NSZeroRect
        r.origin.x = margin.x
        r.size.width = labelWidth - r.origin.x
        r.size.height = 19.0
        r.origin.y = switchRect.origin.y - 20.0 - r.size.height
        return r
    }
    
    var wayFieldRect: NSRect {
        var r = NSZeroRect
        r.origin.x = wayLabelRect.maxX + 8.0
        r.size.width = bounds.size.width - r.origin.x - margin.x
        r.origin.y = (32.0 + margin.y * 2) + 4.0
        r.size.height = wayLabelRect.maxY - r.origin.y
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
    
    // MARK: Delegate

    override func controlTextDidChange(notification: NSNotification) {
        validateDoneButton()
    }
    
    // MARK: Actions
    
    func validateDoneButton() {
        var canDone = !summaryField.stringValue.isEmpty
        if canDone && switchMatrix.selectedColumn == 0 {
            canDone = !wayField.stringValue.isEmpty
        }
        doneButton.enabled = canDone
    }
    
    func selectApp(sender: AnyObject?) {
    }
    
    func switchReproducibility(sender: AnyObject?) {
        wayField.enabled = switchMatrix.selectedColumn == 0
        validateDoneButton()
    }
    
    func sendMailWithMessage(message: String?, subject: String?, to addresses: [String]) -> String? {
        var errorString: String?
        if !addresses.isEmpty {
            var URLString = "mailto:" + ", ".join(addresses)
            subject !! { URLString += "?subject=\($0)" }
            message !! { URLString += (subject !! "&" ?? "?") + "body=\($0)" }
            URLString = URLString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            NSWorkspace.sharedWorkspace().openURL(NSURL(string: URLString)!)
        } else {
            // Error
            errorString = NSLocalizedString("Could not send the report.", comment: "")
        }
        return errorString
    }
    
    func send() {
        // Get properties
        var message = ""
        let summary = summaryField.stringValue
        let userAgent = userAgentPopup.titleOfSelectedItem ?? ""
        let reproducibility = switchMatrix.selectedColumn == 0
        let wayToReproduce = wayField.stringValue
        let osVersion = NSProcessInfo.processInfo().operatingSystemVersionString
        
        var cpuType: cpu_type_t = 0
        let result = SBCPUType(&cpuType)
        var processor: String?
        if result == KERN_SUCCESS {
            if cpuType == 7 /* CPU_TYPE_X86 */ {
                processor = "x86"
            } else if cpuType == 7 | CPU_ARCH_ABI64 /* CPU_TYPE_X86_64 */ {
                processor = "x86_64"
            }
        }
        let applicationVersion = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as! String
        
        // Make message
        summary.ifNotEmpty    !! { message += NSLocalizedString("Summary", comment: "") + " : \n\($0)\n\n" }
        userAgent.ifNotEmpty  !! { message += NSLocalizedString("User Agent", comment: "") + " : \n\($0)\n\n" }
        (reproducibility &? wayToReproduce.ifNotEmpty)
                              !! { message += NSLocalizedString("A way to reproduce", comment: "") + " : \n\($0)\n\n" }
        osVersion.ifNotEmpty  !! { message += NSLocalizedString("OS", comment: "") + " : \($0)\n" }
        processor?.ifNotEmpty !! { message += NSLocalizedString("Processor", comment: "") + " : \($0)\n" }
        applicationVersion.ifNotEmpty
                              !! { message += NSLocalizedString("Application Version", comment: "") + " : \($0)\n" }
        
        // Send message
        let errorDescription = sendMailWithMessage(message, subject: NSLocalizedString("Daybreak Bug Report", comment: ""), to: [kSBBugReportMailAddress])
        if errorDescription == nil {
            done()
        }
    }
}