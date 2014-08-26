/*
SBApplicationDelegate.swift

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

class SBApplicationDelegate: NSObject, NSApplicationDelegate {
    var localizationWindowController: SBLocalizationWindowController?
    var preferencesWindowController: SBPreferencesWindowController?
    var updateView: SBUpdateView?
    
    deinit {
        destructUpdateView()
        destructLocalizeWindowController()
        destructPreferencesWindowController()
    }
    
    func applicationWillFinishLaunching(aNotification: NSNotification) {
        #if __debug__
        constructDebugMenu()
        #endif
        // Handle AppleScript (Open URL from other application)
        NSAppleEventManager.sharedAppleEventManager().setEventHandler(self, andSelector: "openURL:withReplyEvent:", forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
        // Localize menu
        SBLocalizeTitlesInMenu(NSApp.mainMenu)
        // Register defaults
        SBPreferences.sharedPreferences.registerDefaults()
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let center = NSNotificationCenter.defaultCenter()
        let updater = SBUpdater.sharedUpdater
        // Add observe notifications
        center.addObserver(self, selector: "updaterShouldUpdate:", name: SBUpdaterShouldUpdateNotification, object: updater)
        center.addObserver(self, selector: "updaterNotNeedUpdate:", name: SBUpdaterNotNeedUpdateNotification, object: updater)
        center.addObserver(self, selector: "updaterDidFailChecking:", name: SBUpdaterDidFailCheckingNotification, object: updater)
        // Read bookmarks
        SBBookmarks.sharedBookmarks
        // Create History instance
        SBHistory.sharedHistory
        SBDispatch {
            self.applicationHasFinishLaunching(aNotification.object as NSApplication)
        }
    }
    
    func applicationHasFinishLaunching(application: NSApplication) {
        if SBPreferences.boolForKey(kSBCheckTheNewVersionAfterLaunching) {
            // Check new version
            SBUpdater.sharedUpdater.check()
        }
    }

    func application(sender: NSApplication, openFiles filenames: [String]) {
        var index = 0
        let documentController = SBDocumentController.sharedDocumentController()! as SBDocumentController
        
        if let document = SBGetSelectedDocument() {
            for filename in filenames {
                var error: NSError?
                let url = NSURL.fileURLWithPath(filename)!
                if let type = documentController.typeForContentsOfURL(url, error: &error) {
                    if type == kSBStringsDocumentTypeName {
                        let path = NSBundle.mainBundle().pathForResource("Localizable", ofType:"strings")
                        openStrings(path: path!, anotherPath:url.path!)
                    } else if type == kSBDocumentTypeName {
                        document.constructNewTabWithURL(url, selection: (index == filenames.count - 1))
                        index++
                    }
                }
            }
        }
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        let center = NSNotificationCenter.defaultCenter()
        // Add observe notifications
        center.removeObserver(self, name: SBUpdaterShouldUpdateNotification, object: nil)
        center.removeObserver(self, name: SBUpdaterNotNeedUpdateNotification, object: nil)
        center.removeObserver(self, name: SBUpdaterDidFailCheckingNotification, object: nil)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(theApplication: NSApplication) -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(kSBQuitWhenTheLastWindowIsClosed)
    }
    
    func applicationShouldTerminate(sender: NSApplication) -> NSApplicationTerminateReply {
        // Is downloading
        if !SBDownloads.sharedDownloads.downloading {
            return .TerminateNow
        }
        
        let title = NSLocalizedString("Are you sure you want to quit? Sunrise is currently downloading some files. If you quit now, it will not finish downloading these files.", comment: "")
        let message = ""
        let okTitle = NSLocalizedString("Quit", comment: "")
        let otherTitle = NSLocalizedString("Don't Quit", comment: "")
        let doc = SBGetSelectedDocument()
        let window = doc?.window
        let alert = NSAlert()
        alert.messageText = title
        alert.addButtonWithTitle(okTitle)
        alert.addButtonWithTitle(otherTitle)
        //alert.informativeText = ""
        alert.beginSheetModalForWindow(window) {
            NSApp.replyToApplicationShouldTerminate($0 != NSAlertOtherReturn)
        }
        return .TerminateLater
    }
    
    func applicationShouldHandleReopen(theApplication: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        return flag
    }
    
    // MARK: Apple Events
    
    func openURL(event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
        if let URLString = event.paramDescriptorForKeyword(AEKeyword(keyDirectObject))?.stringValue {
            if let method = NSUserDefaults.standardUserDefaults().objectForKey(kSBOpenURLFromApplications) as? NSString {
                switch method {
                    case "in a new window":
                    var error: NSError?
                    if let document = SBGetDocumentController().openUntitledDocumentAndDisplay(true, error: &error) as? SBDocument {
                        document.openURLStringInSelectedTabViewItem(URLString)
                    }

                    case "in a new tab":
                    if let document = SBGetSelectedDocument() {
                        document.constructNewTabWithURL(NSURL(string: URLString), selection: true)
                    }

                    case "in the current tab":
                    if let document = SBGetSelectedDocument() {
                        document.openURLStringInSelectedTabViewItem(URLString)
                    }
                    
                    default:
                    assert(false)
                }
            }
        }
    }
    
    // MARK: Notifications
    
    func updaterShouldUpdate(notification: NSNotification) {
        update(notification.userInfo![kSBUpdaterVersionString as NSString] as NSString)
    }
    
    func updaterNotNeedUpdate(notification: NSNotification) {
        let versionString = notification.userInfo![kSBUpdaterVersionString as NSString] as NSString
        let title = NSString(format: NSLocalizedString("Sunrise %@ is currently the newest version available.", comment: ""), versionString)
        let alert = NSAlert()
        alert.messageText = title
        alert.addButtonWithTitle(NSLocalizedString("OK", comment: ""))
        alert.runModal()
    }
    
    func updaterDidFailChecking(notification: NSNotification) {
        let errorDescription = notification.userInfo![kSBUpdaterErrorDescription as NSString] as NSString
        let alert = NSAlert()
        alert.messageText = errorDescription
        alert.addButtonWithTitle(NSLocalizedString("OK", comment: ""))
        alert.runModal()
    }

    // MARK: Actions
    
    func destructUpdateView() {
        if updateView != nil {
            updateView!.removeFromSuperview()
            updateView = nil
        }
    }
    
    func destructLocalizeWindowController() {
        if localizationWindowController != nil {
            localizationWindowController!.close()
            localizationWindowController = nil
        }
    }
    
    func destructPreferencesWindowController() {
        if preferencesWindowController != nil {
            preferencesWindowController!.close()
            preferencesWindowController = nil
        }
    }
    
    func update(versionString: String) {
        let window = SBGetSelectedDocument().window
        let info = NSBundle.mainBundle().localizedInfoDictionary
        let urlString: String = info["SBReleaseNotesURL"] as NSString
        destructUpdateView()
        updateView = SBUpdateView(frame: window.splitViewRect)
        updateView!.title = NSString(format: NSLocalizedString("A new version of Sunrise %@ is available.", comment: ""), versionString)
        updateView!.text = NSLocalizedString("If you click the \"Download\" button, the download of the disk image file will begin. ", comment: "")
        updateView!.versionString = versionString
        updateView!.target = self
        updateView!.doneSelector = "doneUpdate"
        updateView!.cancelSelector = "cancelUpdate"
        updateView!.loadRequest(NSURL(string: urlString))
        window.showCoverWindow(updateView)
    }
    
    func doneUpdate() {
        let document = SBGetSelectedDocument()
        let window = document.window
        var versionString: NSString = updateView!.versionString
        let mutableVString = versionString.mutableCopy() as NSMutableString
        var r: NSRange
        do {
            r = mutableVString.rangeOfString(" ")
            if r.location != NSNotFound && r.length > 0 {
                mutableVString.deleteCharactersInRange(r)
            }
        } while r.location != NSNotFound && r.length > 0
        if versionString.length != mutableVString.length {
            versionString = mutableVString.copy() as NSString
        }
        let url = NSURL(string: NSString(format: kSBUpdaterNewVersionURL, versionString))
        window.hideCoverWindow()
        destructUpdateView()
        document.startDownloadingForURL(url)
    }
    
    func cancelUpdate() {
        SBGetSelectedDocument().window.hideCoverWindow()
    }
    
    func openStrings(#path: String, anotherPath: String? = nil) {
        let (textSet, fieldSet, viewSize) = SBGetLocalizableTextSetS(path)
        if textSet != nil && !(textSet!.isEmpty) {
            destructLocalizeWindowController()
            localizationWindowController = SBLocalizationWindowController(viewSize: viewSize!)
            localizationWindowController!.fieldSet = fieldSet!
            localizationWindowController!.textSet = NSMutableArray(array: textSet!)
            if anotherPath != nil {
                localizationWindowController!.mergeFilePath(anotherPath)
            }
            localizationWindowController!.showWindow(nil)
            
            /*if (floor(NSAppKitVersionNumber) < 1038)	// Resize window frame for auto-resizing (Call for 10.5. Strange bugs of Mac)
            {
                NSWindow *window = [localizationWindowController window];
                NSRect r = [window frame];
                [window setFrame:NSMakeRect(r.origin.x, r.origin.y, r.size.width, r.size.height - 1) display:YES];
                [window setFrame:r display:YES];
            }*/
        }
    }
    
    // MARK: Menu
    
    // MARK: Application
    
    @IBAction func provideFeedback(AnyObject) {
        let title = NSLocalizedString("Sunrise Feedback", comment: "")
        if kSBFeedbackMailAddress.length > 0 {
            var urlString: NSString = "mailto:\(kSBFeedbackMailAddress)?subject=\(title)"
            urlString = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            NSWorkspace.sharedWorkspace().openURL(NSURL(string: urlString))
        }
    }
    
    func checkForUpdates(AnyObject) {
        let updater = SBUpdater.sharedUpdater
        updater.raiseResult = true
        updater.checkSkipVersion = false
        // Check new version
        updater.check()
    }
    
    func preferences(AnyObject) {
        let viewSize = NSSize(width: 800, height: 700)
        destructPreferencesWindowController()
        preferencesWindowController = SBPreferencesWindowController(viewSize: viewSize)
        preferencesWindowController!.showWindow(nil)
    }
    
    func emptyAllCaches(AnyObject) {
        let cache = NSURLCache.sharedURLCache()
        let title = NSLocalizedString("Are you sure you want to empty the cache?", comment: "")
        var message = NSLocalizedString("Sunrise saves the contents of webpages you open, and stores them in a cache, so the pages load faster when you visit them again.", comment: "")
        if cache.diskCapacity > 0 && cache.memoryCapacity > 0 {
            let diskCapacityDescription = bytesString(cache.currentDiskUsage, cache.diskCapacity)
            let memoryCapacityDescription = bytesString(cache.currentMemoryUsage, cache.memoryCapacity)
            let onDisk = NSLocalizedString("On disk", comment: "")
            let inMemory = NSLocalizedString("In memory", comment: "")
            message = message + "\n\n\(onDisk): \(diskCapacityDescription)\n\(inMemory): \(memoryCapacityDescription)"
        }
        let defaultTitle = NSLocalizedString("Empty", comment: "")
        let alternateTitle = NSLocalizedString("Cancel", comment: "")
        let alert = NSAlert()
        alert.messageText = title
        alert.addButtonWithTitle(defaultTitle)
        alert.addButtonWithTitle(alternateTitle)
        let returnCode = alert.runModal()
        if returnCode == NSOKButton {
            NSURLCache.sharedURLCache().removeAllCachedResponses()
        }
    }
    
    // MARK: File
    
    func newDocument(AnyObject) {
        var error: NSError?
        SBGetDocumentController().openUntitledDocumentAndDisplay(true, error: &error)
        if error != nil {
            DebugLogS("\(__FUNCTION__) \(error)")
        }
    }
    
    func openDocument(AnyObject) {
        let panel = SBOpenPanel.sbOpenPanel()
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = true
        let result = panel.runModal()
        if result == NSOKButton {
            if let document = SBGetSelectedDocument() {
                let urls = panel.URLs as [NSURL]
                for (index, file) in enumerate(urls) {
                    document.constructNewTabWithURL(file, selection:(index == urls.count - 1))
                }
            }
        }
    }
    
    // MARK: Help
    
    func localize(sender: AnyObject) {
        /*if localizationWindowController!.window.isVisible() {
            localizationWindowController!.showWindow(nil)
        } else {
            let path = NSBundle.mainBundle().pathForResource("Localizable", ofType:"strings")
            openStrings(path: path)
        }*/
    }
    
    func plugins(sender: AnyObject) {
        if let path = SBFilePathInApplicationBundle("Plug-ins", "html") {
            if let document = SBGetSelectedDocument() {
                document.constructNewTabWithURL(NSURL.fileURLWithPath(path), selection: true)
            }
        }
    }
    
    func sunrisepage(sender: AnyObject) {
        let info = NSBundle.mainBundle().localizedInfoDictionary
        if let string: String = info["SBHomePageURL"] as? NSString {
            if let document = SBGetSelectedDocument() {
                if document.selectedWebDataSource != nil {
                    document.constructNewTabWithURL(NSURL(string: string), selection: true)
                } else {
                    document.openURLStringInSelectedTabViewItem(string)
                }
            }
        }
    }

    #if __debug__
    // MARK: Debug
    
    func constructDebugMenu() {
        let mainMenu = NSApp.mainMenu
        let debugMenuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        let debugMenu = NSMenu(title: "Debug")
        let writeViewStructure = NSMenuItem(title: "Export View Structure...", action: "writeViewStructure:", keyEquivalent: "")
    
        let writeMainMenu = NSMenuItem(title: "Export Menu as plist...", action: "writeMainMenu:", keyEquivalent: "")
        let validateStrings = NSMenuItem(title: "Validate strings file...", action: "validateStrings:", keyEquivalent: "")
        let debugUI = NSMenuItem(title: "Debug UI...", action: "debugAddDummyDownloads:", keyEquivalent: "")
        for item in [writeViewStructure, writeMainMenu, validateStrings, debugUI] {
            debugMenu.addItem(item)
        }
        debugMenuItem.submenu = debugMenu
        mainMenu!.addItem(debugMenuItem)
    }
    
    func writeViewStructure(AnyObject) {
        let document = SBGetSelectedDocument()
        if let view = document.window.contentView {
            let panel = NSSavePanel()
            panel.nameFieldStringValue = "ViewStructure.plist"
            if panel.runModal() == NSFileHandlingPanelOKButton {
                SBDebugWriteViewStructure(view, panel.URL.path!)
            }
        }
    }
    
    func writeMainMenu(AnyObject) {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "Menu.plist"
        if panel.runModal() == NSFileHandlingPanelOKButton {
            SBDebugWriteMainMenu(panel.URL.path!)
        }
    }
    
    func validateStrings(AnyObject) {
        let panel = SBOpenPanel.sbOpenPanel()
        panel.allowedFileTypes = ["strings"]
        panel.directoryURL = NSBundle.mainBundle().resourceURL
        if panel.runModal() == NSFileHandlingPanelOKButton {
            let (textSet, _, _) = SBGetLocalizableTextSetS(panel.URL.path!)
            if textSet != nil {
                for (index, texts) in enumerate(textSet!) {
                    let text0 = texts[0]
                    for (i, ts) in enumerate(textSet!) {
                        let t0 = ts[0]
                        if text0 == t0 && index != i {
                            NSLog("Same keys \(i): \(t0)")
                        }
                    }
                }
            }
        }
    }

    #endif
}