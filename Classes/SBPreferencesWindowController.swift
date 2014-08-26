/*
SBPreferencesWindowController.swift

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

import Cocoa

class SBPreferencesWindowController: SBWindowController {
    var sections: [SBSectionGroup] = []
    var sectionListView: SBSectionListView?
    
    override init(viewSize: NSSize) {
        super.init(viewSize: viewSize)
        let window = self.window
        let r = window.frame
        window.maxSize = NSMakeSize(r.size.width, CGFloat.infinity)
        window.minSize = NSMakeSize(r.size.width, 100.0)
    }
    
    override init(window: NSWindow) {
        super.init(window: window)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    var sectionListViewRect: NSRect {
        let window = self.window
        var r = window.contentRectForFrameRect(window.frame)
        r.origin = NSZeroPoint
        // r.origin.x = 20;
        // r.origin.y = 20;
        // r.size.width -= r.origin.x * 2
        // r.size.height -= r.origin.y * 2
        return r
    }
    
    func prepare() {
        self.constructSections()
        self.constructSectionListView()
    }
    
    func constructSections() {
        sections.removeAll(keepCapacity: false)
        let group0 = SBSectionGroup(title: NSLocalizedString("General", comment: ""))
        group0.addItem(SBSectionItem(title: NSLocalizedString("Open new windows with home page", comment: ""), keyName: kSBOpenNewWindowsWithHomePage, controlClass: NSButton.self, context: nil))
        group0.addItem(SBSectionItem(title: NSLocalizedString("Open new tabs with home page", comment: ""), keyName: kSBOpenNewTabsWithHomePage, controlClass: NSButton.self, context: nil))
        group0.addItem(SBSectionItem(title: NSLocalizedString("Home page", comment: ""), keyName: kSBHomePage, controlClass: NSTextField.self, context: "http://www.homepage.com"))
        group0.addItem(SBSectionItem(title: NSLocalizedString("Save downloaded files to", comment: ""), keyName: kSBSaveDownloadedFilesTo, controlClass: NSOpenPanel.self, context: "~/Downloads"))
        let menu0 = NSMenu()
        for method in SBOpenMethods {
            menu0.addItemWithTitle(NSLocalizedString(method, comment: ""), representedObject: method, target: nil, action: nil)
        }
        group0.addItem(SBSectionItem(title: NSLocalizedString("Open URL from applications", comment: ""), keyName: kSBOpenURLFromApplications, controlClass: NSPopUpButton.self, context: menu0))
        group0.addItem(SBSectionItem(title: NSLocalizedString("Quit when the last window is closed", comment: ""), keyName: kSBQuitWhenTheLastWindowIsClosed, controlClass: NSButton.self, context: nil))
        //group0.addItem(SBSectionItem(title: NSLocalizedString("Confirm before closing multiple tabs", comment: ""), keyName: kSBConfirmBeforeClosingMultipleTabs, controlClass: NSButton, context: nil))
        group0.addItem(SBSectionItem(title: NSLocalizedString("Check the new version after launching", comment: ""), keyName: kSBCheckTheNewVersionAfterLaunching, controlClass: NSButton.self, context: nil))
        //group0.addItem(SBSectionItem(title: NSLocalizedString("Clears all caches after launching", comment: ""), keyName: kSBClearsAllCachesAfterLaunching, controlClass: NSButton, context: nil))
        sections.append(group0)
        
        let group1 = SBSectionGroup(title: NSLocalizedString("Appearance", comment: ""))
        group1.addItem(SBSectionItem(title: NSLocalizedString("Allows animated image to loop", comment: ""), keyName: kSBAllowsAnimatedImageToLoop, controlClass: NSButton.self, context: nil))
        group1.addItem(SBSectionItem(title: NSLocalizedString("Allows animated images", comment: ""), keyName: kSBAllowsAnimatedImages, controlClass: NSButton.self, context: nil))
        group1.addItem(SBSectionItem(title: NSLocalizedString("Loads images automatically", comment: ""), keyName: kSBLoadsImagesAutomatically, controlClass: NSButton.self, context: nil))
        let menu1 = SBEncodingMenu(nil, nil, false)
        group1.addItem(SBSectionItem(title: NSLocalizedString("Default encoding", comment: ""), keyName: kSBDefaultEncoding, controlClass: NSPopUpButton.self, context: menu1))
        group1.addItem(SBSectionItem(title: NSLocalizedString("Include backgrounds when printing", comment: ""), keyName: kSBIncludeBackgroundsWhenPrinting, controlClass: NSButton.self, context: nil))
        sections.append(group1)
        
        /*
        let group2 = SBSectionGroup(title: NSLocalizedString("Bookmarks", comment: ""))
        group2.addItem(SBSectionItem(title: NSLocalizedString("Show bookmarks when window opens", comment: ""), keyName: kSBShowBookmarksWhenWindowOpens, controlClass: NSButton.self, context: nil))
        group2.addItem(SBSectionItem(title: NSLocalizedString("Show alert when removing bookmark", comment: ""), keyName: kSBShowAlertWhenRemovingBookmark, controlClass: NSButton.self, context: nil))
        group2.addItem(SBSectionItem(title: NSLocalizedString("Updates image when accessing bookmark URL", comment: ""), keyName: kSBUpdatesImageWhenAccessingBookmarkURL, controlClass: NSButton.self, context: nil))
        sections.append(group2)
        */
        
        let group3 = SBSectionGroup(title: NSLocalizedString("Security", comment: ""))
        group3.addItem(SBSectionItem(title: NSLocalizedString("Enable plug-ins", comment: ""), keyName: kSBEnablePlugIns, controlClass: NSButton.self, context: nil))
        group3.addItem(SBSectionItem(title: NSLocalizedString("Enable Java", comment: ""), keyName: kSBEnableJava, controlClass: NSButton.self, context: nil))
        group3.addItem(SBSectionItem(title: NSLocalizedString("Enable JavaScript", comment: ""), keyName: kSBEnableJavaScript, controlClass: NSButton.self, context: nil))
        group3.addItem(SBSectionItem(title: NSLocalizedString("Block pop-up windows", comment: ""), keyName: kSBBlockPopUpWindows, controlClass: NSButton.self, context: nil))
        group3.addItem(SBSectionItem(title: NSLocalizedString("URL field shows IDN as ASCII", comment: ""), keyName: kSBURLFieldShowsIDNAsASCII, controlClass: NSButton.self, context: nil))
        /*
        let menu2 = NSMenu()
        for method in SBCookieMethods {
            menu2.addItemWithTitle(NSLocalizedString(method, comment: ""), representedObject: method, target: nil, action: nil)
        }
        */
        sections.append(group3)
        
        /*
        let group4 = SBSectionGroup(title: NSLocalizedString("History", comment: ""))
        group4.addItem(SBSectionItem(title: NSLocalizedString("Save history for", comment: ""), keyName: kSBHistorySaveDays, controlClass: NSButton.self, context: nil))
        sections.append(group4)
        */
        
        let group5 = SBSectionGroup(title: NSLocalizedString("Advanced", comment: ""))
        group5.addItem(SBSectionItem(title: NSLocalizedString("Enable Web Inspector", comment: ""), keyName: kWebKitDeveloperExtras, controlClass: NSButton.self, context: nil))
        group5.addItem(SBSectionItem(title: NSLocalizedString("When a new tab opens, make it active", comment: ""), keyName: kSBWhenNewTabOpensMakeActiveFlag, controlClass: NSButton.self, context: nil))
        sections.append(group5)
    }
    
    func constructSectionListView() {
        let r = self.sectionListViewRect
        sectionListView = SBSectionListView(frame: r)
        sectionListView!.autoresizingMask = .ViewWidthSizable | .ViewHeightSizable
        sectionListView!.sections = NSMutableArray(array: sections)
        self.window.contentView.addSubview(sectionListView!)
    }
}