//
//  SBPreferencesWindowController.swift
//  Sunrise
//
//  Created by Alice Atlas on 7/3/14.
//
//

import Cocoa

class SBPreferencesWindowController: SBWindowController {
    var sections: SBSectionGroupe[] = []
    var sectionListView: SBSectionListView?
    
    init(viewSize: NSSize) {
        super.init(viewSize: viewSize)
        let window = self.window
        let r = window.frame
        window.maxSize = NSMakeSize(r.size.width, CGFloat.infinity)
        window.minSize = NSMakeSize(r.size.width, 100.0)
    }
    
    init(window: NSWindow) {
        super.init(window: window)
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
        let groupe0 = SBSectionGroupe(title: NSLocalizedString("General", comment: ""))
        groupe0.addItem(SBSectionItem(title: NSLocalizedString("Open new windows with home page", comment: ""), keyName: kSBOpenNewWindowsWithHomePage, controlClass: NSButton.self, context: nil))
        groupe0.addItem(SBSectionItem(title: NSLocalizedString("Open new tabs with home page", comment: ""), keyName: kSBOpenNewTabsWithHomePage, controlClass: NSButton.self, context: nil))
        groupe0.addItem(SBSectionItem(title: NSLocalizedString("Home page", comment: ""), keyName: kSBHomePage, controlClass: NSTextField.self, context: "http://www.homepage.com"))
        groupe0.addItem(SBSectionItem(title: NSLocalizedString("Save downloaded files to", comment: ""), keyName: kSBSaveDownloadedFilesTo, controlClass: NSOpenPanel.self, context: "~/Downloads"))
        let menu0 = NSMenu()
        for method in SBOpenMethods {
            menu0.addItemWithTitle(NSLocalizedString(method, comment: ""), representedObject: method, target: nil, action: nil)
        }
        groupe0.addItem(SBSectionItem(title: NSLocalizedString("Open URL from applications", comment: ""), keyName: kSBOpenURLFromApplications, controlClass: NSPopUpButton.self, context: menu0))
        groupe0.addItem(SBSectionItem(title: NSLocalizedString("Quit when the last window is closed", comment: ""), keyName: kSBQuitWhenTheLastWindowIsClosed, controlClass: NSButton.self, context: nil))
        //groupe0.addItem(SBSectionItem(title: NSLocalizedString("Confirm before closing multiple tabs", comment: ""), keyName: kSBConfirmBeforeClosingMultipleTabs, controlClass: NSButton, context: nil))
        groupe0.addItem(SBSectionItem(title: NSLocalizedString("Check the new version after launching", comment: ""), keyName: kSBCheckTheNewVersionAfterLaunching, controlClass: NSButton.self, context: nil))
        //groupe0.addItem(SBSectionItem(title: NSLocalizedString("Clears all caches after launching", comment: ""), keyName: kSBClearsAllCachesAfterLaunching, controlClass: NSButton, context: nil))
        sections.append(groupe0)
        
        let groupe1 = SBSectionGroupe(title: NSLocalizedString("Appearance", comment: ""))
        groupe1.addItem(SBSectionItem(title: NSLocalizedString("Allows animated image to loop", comment: ""), keyName: kSBAllowsAnimatedImageToLoop, controlClass: NSButton.self, context: nil))
        groupe1.addItem(SBSectionItem(title: NSLocalizedString("Allows animated images", comment: ""), keyName: kSBAllowsAnimatedImages, controlClass: NSButton.self, context: nil))
        groupe1.addItem(SBSectionItem(title: NSLocalizedString("Loads images automatically", comment: ""), keyName: kSBLoadsImagesAutomatically, controlClass: NSButton.self, context: nil))
        let menu1 = SBEncodingMenu(nil, nil, false)
        groupe1.addItem(SBSectionItem(title: NSLocalizedString("Default encoding", comment: ""), keyName: kSBDefaultEncoding, controlClass: NSPopUpButton.self, context: menu1))
        groupe1.addItem(SBSectionItem(title: NSLocalizedString("Include backgrounds when printing", comment: ""), keyName: kSBIncludeBackgroundsWhenPrinting, controlClass: NSButton.self, context: nil))
        sections.append(groupe1)
        
        /*
        let groupe2 = SBSectionGroupe(title: NSLocalizedString("Bookmarks", comment: ""))
        groupe2.addItem(SBSectionItem(title: NSLocalizedString("Show bookmarks when window opens", comment: ""), keyName: kSBShowBookmarksWhenWindowOpens, controlClass: NSButton.self, context: nil))
        groupe2.addItem(SBSectionItem(title: NSLocalizedString("Show alert when removing bookmark", comment: ""), keyName: kSBShowAlertWhenRemovingBookmark, controlClass: NSButton.self, context: nil))
        groupe2.addItem(SBSectionItem(title: NSLocalizedString("Updates image when accessing bookmark URL", comment: ""), keyName: kSBUpdatesImageWhenAccessingBookmarkURL, controlClass: NSButton.self, context: nil))
        sections.append(groupe2)
        */
        
        let groupe3 = SBSectionGroupe(title: NSLocalizedString("Security", comment: ""))
        groupe3.addItem(SBSectionItem(title: NSLocalizedString("Enable plug-ins", comment: ""), keyName: kSBEnablePlugIns, controlClass: NSButton.self, context: nil))
        groupe3.addItem(SBSectionItem(title: NSLocalizedString("Enable Java", comment: ""), keyName: kSBEnableJava, controlClass: NSButton.self, context: nil))
        groupe3.addItem(SBSectionItem(title: NSLocalizedString("Enable JavaScript", comment: ""), keyName: kSBEnableJavaScript, controlClass: NSButton.self, context: nil))
        groupe3.addItem(SBSectionItem(title: NSLocalizedString("Block pop-up windows", comment: ""), keyName: kSBBlockPopUpWindows, controlClass: NSButton.self, context: nil))
        groupe3.addItem(SBSectionItem(title: NSLocalizedString("URL field shows IDN as ASCII", comment: ""), keyName: kSBURLFieldShowsIDNAsASCII, controlClass: NSButton.self, context: nil))
        /*
        let menu2 = NSMenu()
        for method in SBCookieMethods {
            menu2.addItemWithTitle(NSLocalizedString(method, comment: ""), representedObject: method, target: nil, action: nil)
        }
        */
        sections.append(groupe3)
        
        /*
        let groupe4 = SBSectionGroupe(title: NSLocalizedString("History", comment: ""))
        groupe4.addItem(SBSectionItem(title: NSLocalizedString("Save history for", comment: ""), keyName: kSBHistorySaveDays, controlClass: NSButton.self, context: nil))
        sections.append(groupe4)
        */
        
        let groupe5 = SBSectionGroupe(title: NSLocalizedString("Advanced", comment: ""))
        groupe5.addItem(SBSectionItem(title: NSLocalizedString("Enable Web Inspector", comment: ""), keyName: kWebKitDeveloperExtras, controlClass: NSButton.self, context: nil))
        groupe5.addItem(SBSectionItem(title: NSLocalizedString("When a new tab opens, make it active", comment: ""), keyName: kSBWhenNewTabOpensMakeActiveFlag, controlClass: NSButton.self, context: nil))
        sections.append(groupe5)
    }
    
    func constructSectionListView() {
        let r = self.sectionListViewRect
        sectionListView = SBSectionListView(frame: r)
        sectionListView!.autoresizingMask = .ViewWidthSizable | .ViewHeightSizable
        sectionListView!.sections = NSMutableArray(array: sections)
        self.window.contentView.addSubview(sectionListView)
    }
}