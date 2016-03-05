/*
SBDocument.swift

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

enum SBStatus {
    case Undone, Processing, Done
}

class SBDocument: NSDocument, SBTabbarDelegate, SBDownloaderDelegate, SBURLFieldDatasource, SBURLFieldDelegate, SBSplitViewDelegate, SBTabViewDelegate, SBBookmarksViewDelegate, SBWebResourcesViewDataSource, SBWebResourcesViewDelegate, SBToolbarDelegate, SBDocumentWindowDelegate {
    weak var window: SBDocumentWindow! {
        didSet {
            if window != nil {
                window.toolbar = toolbar
                window.tabbar = tabbar
                splitView.frame = window.splitViewRect
                window.splitView = splitView
                sidebar?.closeDrawer(animatedFlag: false)
                tabbar.constructAddButton()    // Create add button after resizing
                // Set visibility
                let tabbarVisibility = NSUserDefaults.standardUserDefaults().boolForKey(kSBTabbarVisibilityFlag)
                if !tabbarVisibility {
                    hideTabbar()
                }
            }
        }
    }
    weak var windowController: NSWindowController!
    
    lazy var toolbar: NSToolbar = {
        let toolbar = SBToolbar(identifier: kSBDocumentToolbarIdentifier)
        toolbar.sizeMode = .Small
        toolbar.displayMode = .IconOnly
        toolbar.allowsUserCustomization = true
        toolbar.autosavesConfiguration = true
        toolbar.showsBaselineSeparator = false
        toolbar.sbDelegate = self
        return toolbar
    }()
    
    private let URLViewBounds = NSMakeRect(0, 0, 320.0, 24.0)
    private lazy var URLView: NSView = {
        let URLView = NSView(frame: self.URLViewBounds)
        URLView.autoresizingMask = [.ViewWidthSizable, .ViewHeightSizable]
        URLView.addSubview(self.URLField)
        return URLView
    }()
    lazy var URLField: SBURLField = {
        let URLField = SBURLField(frame: self.URLViewBounds)
        URLField.autoresizingMask = [.ViewWidthSizable, .ViewHeightSizable]
        URLField.delegate = self
        URLField.dataSource = self
        return URLField
    }()
    
    private let loadViewBounds = NSMakeRect(0, 0, 24.0, 24.0)
    private lazy var loadView: NSView = {
        let loadView = NSView(frame: self.loadViewBounds)
        loadView.autoresizingMask = [.ViewWidthSizable, .ViewHeightSizable]
        loadView.addSubview(self.loadButton)
        return loadView
    }()
    
    private let encodingViewBounds = NSMakeRect(0, 0, 250.0, 24.0)
    private lazy var encodingView: NSView = {
        let encodingView = NSView(frame: self.encodingViewBounds)
        encodingView.autoresizingMask = [.ViewMaxXMargin, .ViewMinXMargin, .ViewMaxYMargin, .ViewMinYMargin]
        encodingView.addSubview(self.encodingButton)
        return encodingView
    }()
    
    private lazy var zoomView: NSView = {
        let zoomView = NSView(frame: NSMakeRect(0, 0, 72.0, 24.0))
        zoomView.autoresizingMask = [.ViewMaxXMargin, .ViewMinXMargin, .ViewMaxYMargin, .ViewMinYMargin]
        zoomView.addSubview(self.zoomButton)
        return zoomView
    }()
    
    private lazy var loadButton: SBLoadButton = {
        let loadButton = SBLoadButton(frame: self.loadViewBounds)
        loadButton.autoresizingMask = [.ViewWidthSizable, .ViewHeightSizable]
        loadButton.images = ["Reload.png", "Stop.png"].map {NSImage(named: $0)!}
        loadButton.target = self
        loadButton.action = #selector(load(_:))
        return loadButton
    }()
    
    private lazy var encodingButton: SBPopUpButton = {
        let encodingButton = SBPopUpButton(frame: self.encodingViewBounds)
        let image = NSImage(named: "Plain.png")?.stretchableImage(size: self.encodingViewBounds.size, sideCapWidth: 7.0)
        encodingButton.backgroundImage = image
        encodingButton.menu = SBEncodingMenu(nil, nil, true)
        encodingButton.operation = { [unowned self] (item: NSMenuItem) in
            self.changeEncodingFromMenuItem(item)
        }
        let encodingName = SBGetWebPreferences.defaultTextEncodingName
        encodingButton.selectItem(representedObject: encodingName)
        return encodingButton
    }()
    
    private lazy var zoomButton: SBSegmentedButton = {
        let r0 = NSMakeRect(0, 0, 24.0, 24.0)
        let r1 = NSMakeRect(24.0, 0, 24.0, 24.0)
        let r2 = NSMakeRect(48.0, 0, 24.0, 24.0)
        let zoomButton = SBSegmentedButton()
        let zoomButton0 = SBButton(frame: r0)
        let zoomButton1 = SBButton(frame: r1)
        let zoomButton2 = SBButton(frame: r2)
        zoomButton0.target = self
        zoomButton1.target = self
        zoomButton2.target = self
        zoomButton0.action = #selector(zoomOutView(_:))
        zoomButton1.action = #selector(scaleToActualSizeForView(_:))
        zoomButton2.action = #selector(zoomInView(_:))
        zoomButton0.image = SBZoomOutIconImage(r0.size)
        zoomButton1.image = SBActualSizeIconImage(r1.size)
        zoomButton2.image = SBZoomInIconImage(r2.size)
        zoomButton.buttons = [zoomButton0, zoomButton1, zoomButton2]
        return zoomButton
    }()
    
    lazy var tabbar: SBTabbar = {
        let tabbar = SBTabbar()
        tabbar.toolbarVisible = self.toolbar.visible
        tabbar.delegate = self
        return tabbar
    }()
    
    lazy var splitView: SBSplitView = {
        let splitView = SBSplitView(frame: NSZeroRect)
        splitView.sbDelegate = self
        return splitView
    }()
    
    private lazy var tabView: SBTabView = {
        let tabView = SBTabView(frame: NSZeroRect)
        tabView.sbDelegate = self
        tabView.tabViewType = .NoTabsNoBorder
        tabView.drawsBackground = false
        return tabView
    }()
    
    private var bookmarkView: SBBookmarkView? {
        didSet {
            oldValue?.removeFromSuperview()
        }
    }
    
    private var editBookmarkView: SBEditBookmarkView? {
        didSet {
            oldValue?.removeFromSuperview()
        }
    }
    
    private var downloaderView: SBDownloaderView? {
        didSet {
            oldValue?.removeFromSuperview()
        }
    }
    
    private var snapshotView: SBSnapshotView? {
        didSet {
            oldValue?.removeFromSuperview()
        }
    }
    
    private var reportView: SBReportView? {
        didSet {
            oldValue?.removeFromSuperview()
        }
    }
    
    private var userAgentView: SBUserAgentView? {
        didSet {
            oldValue?.removeFromSuperview()
        }
    }
    
    private var historyView: SBHistoryView? {
        didSet {
            oldValue?.removeFromSuperview()
        }
    }
    
    private var messageView: SBMessageView? {
        didSet {
            oldValue?.removeFromSuperview()
        }
    }
    
    private var textInputView: SBTextInputView? {
        didSet {
            oldValue?.removeFromSuperview()
        }
    }
    
    /*private var sidebar: SBSidebar? {
        didSet {
            oldValue?.removeFromSuperview()
            splitView.sidebar = sidebar
        }
    }*/
    // didSet is not called when assigning to sidebar from init
    private var _sidebar: SBSidebar?
    private var sidebar: SBSidebar? {
        get { return _sidebar }
        set(sidebar) {
            _sidebar?.removeFromSuperview()
            _sidebar = sidebar
            splitView.sidebar = sidebar
        }
    }
    
    func constructSidebar() -> SBSidebar? {
        if sidebarVisibility {
            let sidebar = SBSidebar(frame: splitView.sidebarRect)
            sidebar.delegate = self
            sidebar.sidebarDelegate = splitView
            sidebar.position = splitView.sidebarPosition
            sidebar.drawerHeight = minimumDownloadsDrawerHeight // Set to default height
            let bookmarksView = constructBookmarksView(sidebar: sidebar)
            let drawer = SBDrawer(frame: sidebar.drawerRect)
            sidebar.view = bookmarksView
            sidebar.drawer = drawer
            sidebar.bottombar.sizeSlider.floatValue = Float(bookmarksView.cellWidth)
            return sidebar
        }
        return nil
    }
    
    func constructBookmarksView(sidebar aSidebar: SBSidebar? = nil) -> SBBookmarksView {
        let sidebar = aSidebar ?? self.sidebar!
        let defaults = NSUserDefaults.standardUserDefaults()
        let bookmarksView = SBBookmarksView(frame: sidebar.viewRect)
        bookmarksView.autoresizingMask = [.ViewWidthSizable, .ViewHeightSizable]
        bookmarksView.delegate = self
        bookmarksView.constructListView(SBBookmarkMode(rawValue: defaults.integerForKey(kSBBookmarkMode))!)
        return bookmarksView
    }
    
    var initialURL: NSURL?
    var sidebarVisibility = true
    private var identifier = 0
    private var confirmed: Int!
    
    var selectedTabViewItem: SBTabViewItem? {
        return tabView.selectedTabViewItem
    }
    var selectedWebView: SBWebView? {
        return selectedTabViewItem?.webView
    }
    var selectedWebDocumentView: NSView? {
        return selectedWebView?.mainFrame.frameView.documentView
    }
    var selectedWebDataSource: WebDataSource? {
        return selectedWebView?.mainFrame.dataSource
    }
    var selectedWebViewImageForBookmark: NSImage? {
        return selectedWebViewImage(size: SBBookmarkImageMaxSize)
    }
    var selectedWebViewImageDataForBookmark: NSData? {
        return selectedWebViewImageForBookmark?.bitmapImageRep?.data
    }
    var resourcesView: SBWebResourcesView? {
        return sidebar?.view as? SBWebResourcesView
    }
    var tabCount: Int {
        return tabbar.items.count
    }
    var visibleRectOfSelectedWebDocumentView: NSRect {
        return selectedWebDocumentView!.visibleRect
    }
    var minimumDownloadsDrawerHeight: CGFloat {
        return 1 + kSBDownloadItemSize + kSBBottombarHeight
    }
    
    func selectedWebViewImage(size: NSSize = .zero) -> NSImage? {
        guard let webDocumentView = selectedWebDocumentView else { return nil }
        let intersectRect = webDocumentView.bounds
        var img = NSImage(view: webDocumentView)
        if size != .zero && size != intersectRect.size {
            img = img?.inset(size: size, intersectRect: intersectRect, offset: .zero)
        }
        return img
    }
    
    func adjustedSplitPositon(proposedPosition: CGFloat) -> CGFloat {
        var pos = proposedPosition
        let bookmarksView = sidebar!.view as! SBBookmarksView
        var proposedWidth: CGFloat!
        let maxWidth = splitView.bounds.size.width
        if splitView.sidebarPosition == .Right {
            proposedWidth = maxWidth - pos
        } else {
            proposedWidth = pos
        }
        let width = bookmarksView.splitWidth(proposedWidth)
        if splitView.sidebarPosition == .Right {
            pos = maxWidth - width
        } else {
            pos = width
        }
        return pos
    }
    
    override init() {
        super.init()
        switch splitView.sidebarPosition {
            case .Left:
                sidebar = constructSidebar()
                splitView.view = tabView
                tabView.frame = splitView.viewRect
            case .Right:
                splitView.view = tabView
                sidebar = constructSidebar()
        }
    }
    
    deinit {
        removeObserverNotifications()
    }
    
    func createdTag() -> Int {
        return ++identifier
    }
    
    // MARK: Document
    
    override func makeWindowControllers() {
        let newWindow = constructWindow()
        let newWindowController = constructWindowController(newWindow)
        window = newWindow
        windowController = newWindowController
        if kSBFlagCreateTabItemWhenLaunched {
            constructNewTab(string: initialURL?.absoluteString, selection: true)
        }
        addWindowController(windowController)
        addObserverNotifications()
        tabbar.keyView = window.keyWindow
        URLField.keyView = window.keyWindow
    }
    
    override func dataOfType(typeName: String) throws -> NSData {
        // Insert code here to write your document to data of the specified type.
        
        // You can also choose to override -fileWrapperOfType:, -writeToURL:ofType:, or -writeToURL:ofType:forSaveOperation:originalContentsURL: instead.
        
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    override func readFromData(data: NSData, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type.
        
        // You can also choose to override -readFromFileWrapper:ofType: or -readFromURL:ofType: instead.
        
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }
    
    override func updateChangeCount(changeType: NSDocumentChangeType) {
        // Ignore
    }
    
    // MARK: Construction
    
    func constructWindow() -> SBDocumentWindow {
        let savedFrameString = NSUserDefaults.standardUserDefaults().stringForKey("NSWindow Frame " + kSBDocumentWindowAutosaveName)
        let defaultFrame = SBDefaultDocumentWindowRect
        let r: NSRect = savedFrameString !! { NSRectFromString($0) } ?? defaultFrame
        let newWindow = SBDocumentWindow(frame: r, delegate: self, tabbarVisibility: true)
        let button = newWindow.standardWindowButton(.CloseButton)!
        button.target = self
        button.action = #selector(performCloseFromButton(_:))
        return newWindow
    }
    
    func constructWindowController(newWindow: SBDocumentWindow) -> NSWindowController {
        let newWindowController = NSWindowController(window: newWindow)
        newWindowController.windowFrameAutosaveName = kSBDocumentWindowAutosaveName
        return newWindowController
    }
    
    func constructNewTab(string string: String?, selection: Bool) {
        let requestURLString = string?.ifNotEmpty?.requestURLString
        let URL = requestURLString?.ifNotEmpty !! {NSURL(string: $0)}
        constructNewTab(URL: URL, selection: selection)
    }
    
    func constructNewTab(URL URL: NSURL?, selection: Bool) {
        let tag = createdTag()
        let tabbarItem = constructTabbarItem(tag: tag)
        tabbarItem.title = displayName
        tabbarItem.progress = -1
        let tabViewItem = constructTabViewItem(identifier: tag, tabbarItem: tabbarItem)
        if selection {
            tabView.selectTabViewItem(tabViewItem)
            tabbar.selectItem(tabbarItem)
        }
        // request URL after selecting
        tabViewItem.URL = URL
        if selection {
            if URL != nil {
                window.makeFirstResponder(tabViewItem.webView)
            } else if window.toolbar!.visible {
                selectURLField()
            }
        }
    }
    
    func constructTabbarItem(tag tag: Int) -> SBTabbarItem {
        return tabbar.addItemWithTag(tag)
    }
    
    func constructTabViewItem(identifier identifier: NSNumber, tabbarItem: SBTabbarItem) -> SBTabViewItem {
        return tabView.addItem(identifier: identifier as Int, tabbarItem: tabbarItem)
    }
    
    func constructDownloadsViewInSidebar() -> SBDownloadsView {
        var availableRect = sidebar!.drawer!.availableRect
        availableRect.origin = .zero
        let downloadsView = SBDownloadsView(frame: availableRect)
        downloadsView.delegate = sidebar
        sidebar!.drawer!.view = downloadsView
        downloadsView.constructDownloadViews()
        return downloadsView
    }
    
    func addObserverNotifications() {
        let center = NSNotificationCenter.defaultCenter()
        let notifications: [(Selector, String, AnyObject?)] = [
            (#selector(bookmarksDidUpdate(_:)), SBBookmarksDidUpdateNotification, SBBookmarks.sharedBookmarks),
            (#selector(downloadsDidAddItem(_:)), SBDownloadsDidAddItemNotification, nil),
            (#selector(downloadsWillRemoveItem(_:)), SBDownloadsWillRemoveItemNotification, nil),
            (#selector(downloadsDidUpdateItem(_:)), SBDownloadsDidUpdateItemNotification, nil),
            (#selector(downloadsDidFinishItem(_:)), SBDownloadsDidFinishItemNotification, nil),
            (#selector(downloadsDidFailItem(_:)), SBDownloadsDidFailItemNotification, nil)]
        for (selector, name, object) in notifications {
            center.addObserver(self, selector: selector, name: name, object: object)
        }
    }
    
    func removeObserverNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Toolbar
    
    func toolbarAllowedItemIdentifiers(toolbar: NSToolbar) -> [String] {
        return [kSBToolbarURLFieldItemIdentifier, 
                kSBToolbarLoadItemIdentifier,
                kSBToolbarBookmarkItemIdentifier,
                kSBToolbarHistoryItemIdentifier,
                kSBToolbarHomeItemIdentifier,
                kSBToolbarTextEncodingItemIdentifier,
                kSBToolbarBookmarksItemIdentifier,
                kSBToolbarSnapshotItemIdentifier,
                kSBToolbarBugsItemIdentifier,
                kSBToolbarUserAgentItemIdentifier,
                kSBToolbarSourceItemIdentifier,
                kSBToolbarZoomItemIdentifier,
                NSToolbarSpaceItemIdentifier,
                NSToolbarFlexibleSpaceItemIdentifier,
                NSToolbarPrintItemIdentifier]
    }
    
    func toolbarDefaultItemIdentifiers(toolbar: NSToolbar) -> [String] {
        return [kSBToolbarURLFieldItemIdentifier, 
                kSBToolbarLoadItemIdentifier,
                kSBToolbarBookmarkItemIdentifier,
                kSBToolbarHistoryItemIdentifier,
                kSBToolbarHomeItemIdentifier,
                kSBToolbarTextEncodingItemIdentifier,
                kSBToolbarBookmarksItemIdentifier,
                kSBToolbarSnapshotItemIdentifier,
                kSBToolbarBugsItemIdentifier,
                kSBToolbarUserAgentItemIdentifier,
                kSBToolbarSourceItemIdentifier,
                kSBToolbarZoomItemIdentifier]
    }
    
    func toolbar(toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: String, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        let item = NSToolbarItem(itemIdentifier: itemIdentifier)
        switch itemIdentifier {
            case kSBToolbarURLFieldItemIdentifier:
                item.view = URLView
                item.label = NSLocalizedString("URL Field", comment: "")
                item.paletteLabel = NSLocalizedString("URL Field", comment: "")
                item.toolTip = NSLocalizedString("URL Field", comment: "")
                item.maxSize = NSMakeSize(window.frame.size.width, 24.0)
                item.minSize = NSMakeSize(320.0, 24.0)
            case kSBToolbarLoadItemIdentifier:
                item.view = loadView
                item.label = NSLocalizedString("Load", comment: "")
                item.paletteLabel = NSLocalizedString("Load", comment: "")
                item.toolTip = NSLocalizedString("Reload / Stop", comment: "")
                item.maxSize = NSMakeSize(32.0, 32.0)
                item.minSize = NSMakeSize(24.0, 24.0)
            case kSBToolbarBookmarkItemIdentifier:
                item.label = NSLocalizedString("Add Bookmark", comment: "")
                item.paletteLabel = NSLocalizedString("Add Bookmark", comment: "")
                item.toolTip = NSLocalizedString("Add Bookmark", comment: "")
                item.image = NSImage(named: "Bookmark")
                item.action = #selector(bookmark(_:))
            case kSBToolbarHistoryItemIdentifier:
                item.label = NSLocalizedString("History", comment: "")
                item.paletteLabel = NSLocalizedString("History", comment: "")
                item.toolTip = NSLocalizedString("History", comment: "")
                item.image = NSImage(named: "History")
                item.action = #selector(showHistory(_:))
            case kSBToolbarHomeItemIdentifier:
                item.label = NSLocalizedString("Go Home", comment: "")
                item.paletteLabel = NSLocalizedString("Go Home", comment: "")
                item.toolTip = NSLocalizedString("Go Home Page", comment: "")
                item.image = NSImage(named: "Home")
                item.action = #selector(openHome(_:))
            case kSBToolbarTextEncodingItemIdentifier:
                item.view = encodingView
                item.label = NSLocalizedString("Text Encoding", comment: "")
                item.paletteLabel = NSLocalizedString("Text Encoding", comment: "")
                item.toolTip = NSLocalizedString("Text Encoding", comment: "")
                item.maxSize = NSMakeSize(250.0, 24.0)
                item.minSize = NSMakeSize(250.0, 24.0)
            case kSBToolbarBookmarksItemIdentifier:
                item.label = NSLocalizedString("Bookmarks", comment: "")
                item.paletteLabel = NSLocalizedString("Bookmarks", comment: "")
                item.toolTip = NSLocalizedString("Bookmarks", comment: "")
                item.image = NSImage(named: "Bookmarks-Icon")
                item.action = #selector(bookmarks(_:))
            case kSBToolbarSnapshotItemIdentifier:
                item.label = NSLocalizedString("Snapshot", comment: "")
                item.paletteLabel = NSLocalizedString("Snapshot", comment: "")
                item.toolTip = NSLocalizedString("Snapshot Current Page", comment: "")
                item.image = NSImage(named: "Snapshot")
                item.action = #selector(snapshot(_:))
            case kSBToolbarBugsItemIdentifier:
                item.label = NSLocalizedString("Bug Report", comment: "")
                item.paletteLabel = NSLocalizedString("Bug Report", comment: "")
                item.toolTip = NSLocalizedString("Send Bug Report", comment: "")
                item.image = NSImage(named: "Bug")
                item.action = #selector(bugReport(_:))
            case kSBToolbarUserAgentItemIdentifier:
                item.label = NSLocalizedString("User Agent", comment: "")
                item.paletteLabel = NSLocalizedString("User Agent", comment: "")
                item.toolTip = NSLocalizedString("Select User Agent", comment: "")
                item.image = NSImage(named: "UserAgent")
                item.action = #selector(selectUserAgent(_:))
            case kSBToolbarZoomItemIdentifier:
                item.view = zoomView
                item.label = NSLocalizedString("Zoom", comment: "")
                item.paletteLabel = NSLocalizedString("Zoom", comment: "")
                item.toolTip = NSLocalizedString("Zoom", comment: "")
                item.maxSize = NSMakeSize(72.0, 24.0)
                item.minSize = NSMakeSize(72.0, 24.0)
            case kSBToolbarSourceItemIdentifier:
                item.label = NSLocalizedString("Source", comment: "")
                item.paletteLabel = NSLocalizedString("Source", comment: "")
                item.toolTip = NSLocalizedString("Source", comment: "")
                item.image = NSImage(named: "Source")
                item.action = #selector(source(_:))
            default:
                break
        }
        return item
    }
    
    // MARK: Window Delegate
    
    func windowDidBecomeMain(notification: NSNotification) {
        window.keyView = true
        URLField.keyView = true
        tabbar.keyView = true
    }
    
    func windowDidResignMain(notification: NSNotification) {
        window.keyView = false
        URLField.keyView = false
        tabbar.keyView = false
        URLField.disappearSheet()
    }
    
    func windowDidResignKey(notification: NSNotification) {
        URLField.disappearSheet()
    }
    
    func windowDidResize(notification: NSNotification) {
        tabbar.updateItems()
    }
    
    func window(aWindow: NSWindow, willPositionSheet sheet: NSWindow, usingRect defaultSheetRect: NSRect) -> NSRect {
        var r = defaultSheetRect
        r.origin.y = window.sheetPosition
        return r
    }
    
    func window(aWindow: SBDocumentWindow, shouldClose sender: AnyObject?) -> Bool {
        return shouldCloseDocument()
    }
    
    func window(aWindow: SBDocumentWindow, shouldHandleKeyEvent event: NSEvent) -> Bool {
        let characters = event.characters
        let command = event.modifierFlags.contains(.CommandKeyMask)
        let shift = event.modifierFlags.contains(.ShiftKeyMask)
        if command && shift && characters != nil {
            switch characters! {
                case "b":
                    toggleAllbarsAndSidebar()
                    return true
                case "e":
                    toggleEditableForSelectedWebView()
                    return true
                case "f":
                    toggleFlip()
                    return true
                case "i":
                    if let inspector = selectedWebView!.inspector {
                        inspector.show(nil)
                    }
                    return true
                case "c":
                    if let inspector = selectedWebView!.inspector {
                        inspector.show(nil)
                        inspector.showConsole(nil)
                    }
                    return true
                default:
                    break
            }
        }
        return false
    }

    func windowDidFinishFlipping(aWindow: SBDocumentWindow) {
    }
    
    // MARK: Toolbar Delegate
    
    func toolbarDidVisible(aToolbar: SBToolbar) {
        tabbar.toolbarVisible = true
    }
    
    func toolbarDidInvisible(aToolbar: SBToolbar) {
        tabbar.toolbarVisible = false
    }
    
    // MARK: Tabbar Delegate
    
    func tabbar(tabbar: SBTabbar, shouldAddNewItemForURLs URLs: [NSURL]?) {
        if let URLs = URLs {
            for (i, URL) in enumerate(URLs) {
                constructNewTab(URL: URL, selection:(i == (URLs.count - 1)))
            }
        } else {
            createNewTab(nil)
        }
    }
    
    func tabbar(aTabbar: SBTabbar, shouldOpenURLs URLs: [NSURL], startInItem aTabbarItem: SBTabbarItem) {
        URLs.ifNotEmpty !! { openAndConstructTab(URLs: $0, startInTabbarItem: aTabbarItem) }
    }
    
    func tabbar(aTabbar: SBTabbar, shouldReload aTabbarItem: SBTabbarItem) {
        let tabViewItem = tabView.tabViewItem(identifier: aTabbarItem.tag)!
        tabViewItem.webView.reload(nil)
    }
    
    func tabbar(aTabbar: SBTabbar, didChangeSelection aTabbarItem: SBTabbarItem) {
        // Select tab
        let tabViewItem = tabView.selectTabViewItem(intIdentifier: aTabbarItem.tag)!
        
        // Change window values
        window.title = tabViewItem.tabbarItem.title
        // Change URL field values
        URLField.enabledBackward = tabViewItem.canBackward
        URLField.enabledForward = tabViewItem.canForward
        URLField.stringValue = tabViewItem.mainFrameURLString?.URLDecodedString
        URLField.image = tabViewItem.tabbarItem.image
        // Change state of the load button
        loadButton.on = tabViewItem.webView.loading
        // Change resources
        updateResourcesViewIfNeeded()
    }
    
    func tabbar(aTabbar: SBTabbar, didReselection aTabbarItem: SBTabbarItem) {
        selectedWebDocumentView!.scrollRectToVisible(.zero)
    }
    
    func tabbar(aTabbar: SBTabbar, didRemoveItem tag: Int) {
        let index = tabView.indexOfTabViewItemWithIdentifier(tag)
        if let tabViewItem = tabView.tabViewItemAtIndex(index) as? SBTabViewItem {
            tabViewItem.removeFromTabView()
        }
    }
    
    // MARK: URL Field Delegate
    
    func URLFieldDidSelectBackward(aURLField: SBURLField) {
        backward(URLField)
    }
    
    func URLFieldDidSelectForward(aURLField: SBURLField) {
        forward(URLField)
    }
    
    func URLFieldShouldOpenURL(aURLField: SBURLField) {
        openURLFromField(URLField)
        window.makeFirstResponder(selectedWebView)
    }
    
    func URLFieldShouldOpenURLInNewTab(aURLField: SBURLField) {
        openURLInNewTabFromField(URLField)
        window.makeFirstResponder(selectedWebView)
    }
    
    func URLFieldShouldDownloadURL(aURLField: SBURLField) {
        if let stringValue = URLField.stringValue {
            window.makeFirstResponder(nil)
            startDownloading(forURL: NSURL(string: stringValue))
        }
    }
    
    func URLFieldTextDidChange(aURLField: SBURLField) {
        updateURLFieldCompletionList()
        if kSBURLFieldShowsGoogleSuggest {
            updateURLFieldGoogleSuggest()
        }
    }
    
    func URLFieldWillResignFirstResponder(aURLField: SBURLField) {
        URLField.hiddenGo = true
    }
    
    // MARK: SBDownloaderDelegate
    
    func downloader(downloader: SBDownloader, didFinish data: NSData) {
        updateURLFieldGoogleSuggestDidEnd(data)
    }
    
    func downloader(downloader: SBDownloader, didFail error: NSError?) {
        updateURLFieldGoogleSuggestDidEnd(nil)
    }
    
    // MARK: SplitView Delegate
    
    func splitView(aSplitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
        if aSplitView === splitView {
            return false
        } else if aSplitView === sidebar {
            if subview === sidebar!.drawer {
                return false
            }
        }
        return true
    }
    
    func splitView(aSplitView: NSSplitView, shouldHideDividerAtIndex dividerIndex: Int) -> Bool {
        if aSplitView === splitView {
        } else if aSplitView === sidebar {
        }
        return false
    }
    
    func splitView(aSplitView: NSSplitView, shouldCollapseSubview subview: NSView, forDoubleClickOnDividerAtIndex dividerIndex: Int) -> Bool {
        if aSplitView === splitView {
            if subview === splitView.view {
                return false
            }
        } else if aSplitView === sidebar {
            if subview === sidebar!.view {
                return false
            }
        }
        return true
    }
    
    func splitView(aSplitView: NSSplitView, additionalEffectiveRectOfDividerAtIndex dividerIndex: Int) -> NSRect {
        if aSplitView === splitView {
            var center = NSZeroPoint
            center.y = splitView.bounds.size.height - kSBBottombarHeight
            if splitView.sidebarPosition == .Right {
                center.x = splitView.bounds.size.width - splitView.sidebarWidth
            } else {
                center.x = splitView.sidebarWidth - kSBBottombarHeight
            }
            return NSMakeRect(center.x, center.y, kSBBottombarHeight, kSBBottombarHeight)
        } else if aSplitView === sidebar {
        }
        return .zero
    }
    
    func splitView(aSplitView: NSSplitView, constrainSplitPosition proposedPosition: CGFloat, ofSubviewAt offset: Int) -> CGFloat {
        var pos = proposedPosition
        if aSplitView === splitView {
            pos = adjustedSplitPositon(proposedPosition)
        } else if aSplitView === sidebar {
            if offset == 0 {
                if proposedPosition >= sidebar!.frame.size.height - kSBBottombarHeight {
                    pos = sidebar!.frame.size.height - kSBBottombarHeight
                }
                if !(sidebar!.bottombar.drawerVisibility) {
                    sidebar!.bottombar.drawerVisibility = true
                }
            }
        }
        return pos
    }
    
    func splitView(aSplitView: NSSplitView, constrainMaxCoordinate proposedMax: CGFloat, ofSubviewAt offset: Int) -> CGFloat {
        if aSplitView === splitView {
            if splitView.sidebarPosition == .Right {
                return splitView.bounds.size.width - kSBSidebarMinimumWidth
            }
        } else if aSplitView === sidebar {
            return sidebar!.bounds.size.height - minimumDownloadsDrawerHeight
        }
        return proposedMax
    }
    
    func splitView(aSplitView: NSSplitView, constrainMinCoordinate proposedMin: CGFloat, ofSubviewAt offset: Int) -> CGFloat {
        if aSplitView === splitView {
            if splitView.sidebarPosition == .Left {
                return kSBSidebarMinimumWidth
            }
        }
        return proposedMin
    }
    
    func splitViewDidResizeSubviews(notification: NSNotification) {
        let aSplitView = notification.object as! NSSplitView
        if aSplitView === splitView {
            if !splitView.animating && splitView.visibleSidebar {
                var width = splitView.sidebar.frame.size.width
                splitView.sidebarWidth = width
                width.constrain(min: kSBSidebarMinimumWidth)
                NSUserDefaults.standardUserDefaults().setDouble(Double(width), forKey: kSBSidebarWidth)
            }
        } else if aSplitView === sidebar {
            if !(sidebar!.animating) {
                let height = sidebar!.drawer!.frame.size.height
                if height > kSBBottombarHeight {
                    sidebar!.drawerHeight = height
                }
            }
        }
    }
    
    func splitViewDidOpenDrawer(splitView: SBSplitView) {
        let downloadsView = sidebar!.drawer!.view as? SBDownloadsView
        if downloadsView == nil {
            constructDownloadsViewInSidebar()
        }
    }
    
    func splitView(aSplitView: NSSplitView, shouldAdjustSizeOfSubview subview: NSView) -> Bool {
        if aSplitView === splitView {
            if subview === splitView.sidebar {
                return false
            }
        } else if aSplitView === sidebar {
            if subview === sidebar!.drawer {
                return false
            }
        }
        return true
    }
    
    // MARK: TabView Delegate
    
    func tabView(aTabView: NSTabView, didSelectTabViewItem tabViewItem: NSTabViewItem?) {
        if let tabViewItem = tabViewItem as? SBTabViewItem {
            // Change encoding pop-up
            let encodingName = tabViewItem.webView.customTextEncodingName
            encodingButton.selectItem(representedObject: encodingName)
        }
    }
    
    func tabView(aTabView: SBTabView, selectedItemDidStartLoading tabViewItem: SBTabViewItem) {
        if !URLField.isFirstResponder || URLField.stringValue.isEmpty {
            URLField.stringValue = tabViewItem.mainFrameURLString?.URLDecodedString
        }
        updateMenu(tag: SBViewMenuTag)
        updateResourcesViewIfNeeded()
        loadButton.on = true
    }
    
    func tabView(aTabView: SBTabView, selectedItemDidFinishLoading tabViewItem: SBTabViewItem) {
        // let webView = self.selectedWebView
        URLField.enabledBackward = tabViewItem.canBackward
        URLField.enabledForward = tabViewItem.canForward
        if !URLField.isFirstResponder || URLField.stringValue.isEmpty {
            URLField.stringValue = tabViewItem.mainFrameURLString?.URLDecodedString
        }
        // if !URLField.isFirstResponder && webView != nil {
        //     window.makeFirstResponder(webView)
        // }
        updateMenu(tag: SBViewMenuTag)
        updateResourcesViewIfNeeded()
        loadButton.on = false
    }

    func tabView(aTabView: SBTabView, selectedItemDidFailLoading tabViewItem: SBTabViewItem) {
        URLField.enabledBackward = tabViewItem.canBackward
        URLField.enabledForward = tabViewItem.canForward
        if !URLField.isFirstResponder || URLField.stringValue.isEmpty {
            URLField.stringValue = tabViewItem.mainFrameURLString?.URLDecodedString
        }
        updateMenu(tag: SBViewMenuTag)
        updateResourcesViewIfNeeded()
        loadButton.on = false
    }

    func tabView(aTabView: SBTabView, selectedItemDidReceiveTitle tabViewItem: SBTabViewItem) {
        let title = tabViewItem.tabbarItem.title
        let URLString = tabViewItem.mainFrameURLString!
        window.title = title
        SBHistory.sharedHistory.addNewItem(URLString: URLString, title: title)
    }
    
    func tabView(aTabView: SBTabView, selectedItemDidReceiveIcon tabViewItem: SBTabViewItem) {
        URLField.image = tabViewItem.tabbarItem.image
    }
    
    func tabView(aTabView: SBTabView, selectedItemDidReceiveServerRedirect tabViewItem: SBTabViewItem) {
        if !URLField.isFirstResponder || URLField.stringValue.isEmpty {
            URLField.stringValue = tabViewItem.mainFrameURLString?.URLDecodedString
        }
    }

    func tabView(aTabView: SBTabView, shouldAddNewItemForURL URL: NSURL, selection: Bool) {
        constructNewTab(URL: URL, selection: selection)
        if selection {
            updateResourcesViewIfNeeded()
        }
    }

    func tabView(aTabView: SBTabView, shouldSearchString string: String, newTab: Bool) {
        searchString(string, newTab: newTab)
    }

    func tabView(aTabView: SBTabView, shouldConfirmWithMessage message: String) -> Bool {
        return confirmMessage(message)
    }

    func tabView(aTabView: SBTabView, shouldShowMessage message: String) {
        showMessage(message)
    }

    func tabView(aTabView: SBTabView, shouldTextInput prompt: String) -> String {
        return textInput(prompt)!
    }

    func tabView(aTabView: SBTabView, didAddResourceID resourceID: SBWebResourceIdentifier) {
        updateResourcesViewIfNeeded()
    }

    func tabView(aTabView: SBTabView, didReceiveExpectedContentLengthOfResourceID resourceID: SBWebResourceIdentifier) {
        updateResourcesViewIfNeeded()
    }

    func tabView(aTabView: SBTabView, didReceiveContentLengthOfResourceID resourceID: SBWebResourceIdentifier) {
        updateResourcesViewIfNeeded()
    }

    func tabView(aTabView: SBTabView, didReceiveFinishLoadingOfResourceID resourceID: SBWebResourceIdentifier) {
        updateResourcesViewIfNeeded()
    }
    
    // MARK: SBWebResourcesViewDataSource
    
    func numberOfRowsInWebResourcesView(webResourcesView: SBWebResourcesView) -> Int {
        return selectedTabViewItem?.resourceIdentifiers.count ?? 0
    }
    
    func webResourcesView(webResourcesView: SBWebResourcesView, objectValueForTableColumn tableColumn: NSTableColumn, row rowIndex: Int) -> AnyObject? {
        var object: String?
        if let resourceIdentifiers = selectedTabViewItem?.resourceIdentifiers,
               resourceIdentifier = resourceIdentifiers.get(rowIndex) {
            let identifier = tableColumn.identifier
            if identifier == kSBURL {
                object = resourceIdentifier.URL.absoluteString
            } else if identifier == "Length" {
                let expected = String.bytesStringForLength(resourceIdentifier.length)
                if resourceIdentifier.received > 0 && resourceIdentifier.length > 0 {
                    if resourceIdentifier.received == resourceIdentifier.length {
                        // Completed
                        object = expected
                    } else {
                        // Processing
                        let sameUnit = String.unitStringForLength(resourceIdentifier.received) == String.unitStringForLength(resourceIdentifier.length)
                        let received = String.bytesStringForLength(resourceIdentifier.received, unit: !sameUnit)
                        object = "\(received)/\(expected)"
                    }
                } else if resourceIdentifier.received > 0 {
                    // Completed
                    let received = String.bytesStringForLength(resourceIdentifier.received)
                    object = received
                } else if resourceIdentifier.length > 0 {
                    // Unloaded
                    object = "?/\(expected)"
                } else {
                    object = "?"
                }
            } else if identifier == "Action" {
            }
        }
        return object
    }
    
    func webResourcesView(webResourcesView: SBWebResourcesView, willDisplayCell aCell: AnyObject?, forTableColumn tableColumn: NSTableColumn, row rowIndex: Int) {
        let cell = aCell as! NSCell
        if let resourceIdentifiers = selectedTabViewItem?.resourceIdentifiers,
               resourceIdentifier = resourceIdentifiers.get(rowIndex) {
            let identifier = tableColumn.identifier
            if identifier == kSBURL {
                cell.title = resourceIdentifier.URL.absoluteString
            } else if identifier == "Length" {
                var title: String!
                let expected = String.bytesStringForLength(resourceIdentifier.length)
                if resourceIdentifier.received > 0 && resourceIdentifier.length > 0 {
                    if resourceIdentifier.received == resourceIdentifier.length {
                        // Completed
                        title = expected
                    } else {
                        // Processing
                        let sameUnit = String.unitStringForLength(resourceIdentifier.received) == String.unitStringForLength(resourceIdentifier.length)
                        let received = String.bytesStringForLength(resourceIdentifier.received, unit: !sameUnit)
                        title = "\(received)/\(expected)"
                    }
                } else if resourceIdentifier.received > 0 {
                    // Completed
                    let received = String.bytesStringForLength(resourceIdentifier.received)
                    title = received
                } else if resourceIdentifier.length > 0 {
                    // Unloaded
                    title = "?/\(expected)"
                } else {
                    title = "?"
                }
                cell.title = title
            } else if identifier == "Cached", let cell = cell as? NSButtonCell {
                let response = NSURLCache.sharedURLCache().cachedResponseForRequest(resourceIdentifier.request)
                let data = response?.data
                cell.enabled = data != nil
                cell.image = data !! NSImage(named: "Cached.png")
            } else if identifier == "Action" {
                (cell as! NSButtonCell).image = NSImage(named: "Download.png")
            }
        }
    }
    
    // MARK: SBWebResourcesViewDelegate
    
    func webResourcesView(webResourcesView: SBWebResourcesView, shouldSaveAtRow rowIndex: Int) {
        if let resourceIdentifiers = selectedTabViewItem?.resourceIdentifiers,
               resourceIdentifier = resourceIdentifiers.get(rowIndex),
               response = NSURLCache.sharedURLCache().cachedResponseForRequest(resourceIdentifier.request) {
            let data = response.data
            let filename = resourceIdentifier.URL.absoluteString?.lastPathComponent ?? "UntitledData"
            let panel = SBSavePanel()
            panel.nameFieldStringValue = filename
            window.beginSheet(panel) {
                if $0 == NSFileHandlingPanelOKButton {
                    if data.writeToURL(panel.URL!, atomically: true) {
                    }
                }
            }
        }
    }
    
    func webResourcesView(webResourcesView: SBWebResourcesView, shouldDownloadAtRow rowIndex: Int) {
        if let resourceIdentifiers = selectedTabViewItem?.resourceIdentifiers,
               resourceIdentifier = resourceIdentifiers.get(rowIndex) {
            startDownloading(forURL: resourceIdentifier.URL)
        }
    }
    
    // MARK: Bookmarks Notifications
    
    func bookmarksDidUpdate(notification: NSNotification) {
        let bookmarksView = sidebar?.view as? SBBookmarksView
        if notification.object !== bookmarksView {
            // Update items in other windows
            bookmarksView!.reload()
        }
    }
    
    // MARK: BookmarksView Delegate
    
    func bookmarksView(bookmarksView: SBBookmarksView, didChangeMode mode: SBBookmarkMode) {
        window.toolbar!.validateVisibleItems()
    }
    
    func bookmarksView(bookmarksView: SBBookmarksView, shouldEditItemAtIndex index: Int) {
        editBookmarkItemAtIndex(index)
    }

    func bookmarksView(bookmarksView: SBBookmarksView, didChangeCellWidth cellWidth: CGFloat) {
        adjustSplitViewIfNeeded()
    }
    
    // MARK: Downloads Notifications
    
    func downloadsDidAddItem(notification: NSNotification) {
        if !splitView.visibleSidebar {
            showSidebar()
        }
        if !(sidebar!.visibleDrawer) {
            showDrawer()
        }
        let item = notification.userInfo![kSBDownloadsItem] as? SBDownload
        let downloadsView = (sidebar!.drawer!.view as? SBDownloadsView) ?? constructDownloadsViewInSidebar()
        item !! downloadsView.addForItem
    }
    
    func downloadsWillRemoveItem(notification: NSNotification) {
        if let downloadsView = sidebar!.drawer!.view as? SBDownloadsView {
            let items = notification.userInfo![kSBDownloadsItems] as! [SBDownload]
            items.forEach { downloadsView.removeForItem($0) }
        }
    }
    
    func downloadsDidUpdateItem(notification: NSNotification) {
        if let downloadsView = sidebar!.drawer!.view as? SBDownloadsView {
            let item = notification.userInfo![kSBDownloadsItem] as! SBDownload
            downloadsView.updateForItem(item)
        }
    }
    
    func downloadsDidFinishItem(notification: NSNotification) {
        if let downloadsView = sidebar!.drawer!.view as? SBDownloadsView {
            let item = notification.userInfo![kSBDownloadsItem] as! SBDownload
            downloadsView.finishForItem(item)
        }
    }
    
    func downloadsDidFailItem(notification: NSNotification) {
        if let downloadsView = sidebar!.drawer!.view as? SBDownloadsView {
            let item = notification.userInfo![kSBDownloadsItem] as! SBDownload
            downloadsView.failForItem(item)
        }
    }
    
    // MARK: Menu Validation
    
    // <# Coding #>
    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        var r = true
        switch menuItem.action {
            case #selector(about(_:)):
                r = window.coverWindow == nil
            case #selector(bugReport(_:)):
                r = window.coverWindow == nil
            case #selector(createNewTab(_:)):
                break
            case #selector(saveDocumentAs(_:)):
                r = selectedWebDataSource != nil
            case #selector(downloadFromURL(_:)):
                r = window.coverWindow == nil
            case #selector(toggleAllbars(_:)):
                let shouldShow = !(window.toolbar!.visible && window.tabbarVisibility)
                menuItem.title = shouldShow ? NSLocalizedString("Show All Bars", comment: "") : NSLocalizedString("Hide All Bars", comment: "")
                r = window.coverWindow == nil
            case #selector(toggleTabbar(_:)):
                menuItem.title = window.tabbarVisibility ? NSLocalizedString("Hide Tabbar", comment: "") : NSLocalizedString("Show Tabbar", comment: "")
                r = window.coverWindow == nil
            case #selector(sidebarPositionToLeft(_:)):
                menuItem.state = splitView.sidebarPosition == .Left ? NSOnState : NSOffState
            case #selector(sidebarPositionToRight(_:)):
                menuItem.state = splitView.sidebarPosition == .Right ? NSOnState : NSOffState
            case #selector(reload(_:)):
                break
            case #selector(stopLoading(_:)):
                r = selectedWebView!.loading
            case #selector(selectUserAgent(_:)):
                r = window.coverWindow == nil
            case #selector(scaleToActualSizeForView(_:)):
                let webView = selectedWebView!
                if webView.respondsToSelector(Selector("canResetPageZoom")) {
                    r = webView.canResetPageZoom
                } else {
                    r = false
                }
            case #selector(showHistory(_:)):
                r = window.coverWindow == nil
            case #selector(zoomInView(_:)):
                let webView = selectedWebView!
                if webView.respondsToSelector(Selector("canZoomPageIn")) {
                    r = webView.canZoomPageIn
                } else {
                    r = false
                }
            case #selector(zoomOutView(_:)):
                let webView = selectedWebView!
                if webView.respondsToSelector(Selector("canZoomPageOut")) {
                    r = webView.canZoomPageOut
                } else {
                    r = false
                }
            case #selector(scaleToActualSizeForText(_:)):
                r = selectedWebView!.canMakeTextStandardSize
            case #selector(zoomInText(_:)):
                r = selectedWebView!.canMakeTextLarger
            case #selector(zoomOutText(_:)):
                r = selectedWebView!.canMakeTextSmaller
            case #selector(source(_:)):
                menuItem.title = selectedTabViewItem!.showSource ? NSLocalizedString("Hide Source", comment: "") : NSLocalizedString("Show Source", comment: "")
            case #selector(resources(_:)):
                menuItem.title = (splitView.visibleSidebar && resourcesView != nil) ? NSLocalizedString("Hide Resources", comment: "") : NSLocalizedString("Show Resources", comment: "")
            case #selector(showWebInspector(_:)):
                r = NSUserDefaults.standardUserDefaults().boolForKey(kWebKitDeveloperExtras) && !(selectedWebView!.isEmpty)
            case #selector(showConsole(_:)):
                r = NSUserDefaults.standardUserDefaults().boolForKey(kWebKitDeveloperExtras) && !(selectedWebView!.isEmpty)
            case #selector(backward(_:)):
                r = selectedWebView?.canGoBack ?? false
            case #selector(forward(_:)):
                r = selectedWebView?.canGoForward ?? false
            case #selector(bookmarks(_:)):
                let bookmarksView = sidebar?.view as? SBBookmarksView
                menuItem.title = (splitView.visibleSidebar && bookmarksView != nil) ? NSLocalizedString("Hide All Bookmarks", comment: "") : NSLocalizedString("Show All Bookmarks", comment: "")
                r = window.coverWindow == nil
            case #selector(bookmark(_:)):
                r = !(selectedWebView!.isEmpty) && window.coverWindow == nil
            case #selector(searchInBookmarks(_:)):
                let bookmarksView = sidebar?.view as? SBBookmarksView
                r = bookmarksView != nil
            case #selector(switchToIconMode(_:)):
                let bookmarksView = sidebar?.view as? SBBookmarksView
                r = splitView.visibleSidebar && sidebar != nil && bookmarksView != nil
                menuItem.state = (bookmarksView &! {$0.mode == .Icon}) ? NSOnState : NSOffState
            case #selector(switchToListMode(_:)):
                let bookmarksView = sidebar?.view as? SBBookmarksView
                r = splitView.visibleSidebar && sidebar != nil && bookmarksView != nil
                menuItem.state = (bookmarksView &! {$0.mode == .List}) ? NSOnState : NSOffState
            case #selector(switchToTileMode(_:)):
                let bookmarksView = sidebar?.view as? SBBookmarksView
                r = splitView.visibleSidebar && sidebar != nil && bookmarksView != nil
                menuItem.state = (bookmarksView &! {$0.mode == .Tile}) ? NSOnState : NSOffState
            case #selector(selectPreviousTab(_:)):
                break
            case #selector(selectNextTab(_:)):
                break
            default:
                break
        }
        return r
    }
    
    // MARK: Toolbar Validation
    
    override func validateToolbarItem(item: NSToolbarItem) -> Bool {
        var r = true
        let itemIdentifier = item.itemIdentifier
        switch itemIdentifier {
            case kSBToolbarURLFieldItemIdentifier:
                break
            case kSBToolbarLoadItemIdentifier:
                break
            case kSBToolbarBookmarkItemIdentifier:
                r = !(selectedWebView?.isEmpty ?? true)
            case kSBToolbarBookmarksItemIdentifier:
                let bookmarksView = sidebar?.view as? SBBookmarksView
                let mode = bookmarksView?.mode ?? .Icon
                item.image = NSImage(named: (mode == .Icon || mode == .Tile) ? "Bookmarks-Icon" : "Bookmarks-List")
            case kSBToolbarSnapshotItemIdentifier:
                r = !(selectedWebView?.isEmpty ?? true)
            case kSBToolbarHomeItemIdentifier:
                let homepage = NSUserDefaults.standardUserDefaults().stringForKey(kSBHomePage) ?? ""
                r = !homepage.isEmpty
            case kSBToolbarSourceItemIdentifier:
                break
            case kSBToolbarBugsItemIdentifier:
                break
            case kSBToolbarUserAgentItemIdentifier:
                break
            default:
                break
        }
        return r
    }
    
    // MARK: Update
    
    func updateMenu(tag tag: Int) {
        if let menu = SBMenuWithTag(tag) {
            menu.update()
        }
    }
    
    func updateResourcesViewIfNeeded() {
        resourcesView !! { $0.reload() }
    }

    func updateURLFieldGoogleSuggest() {
        let string = URLField.stringValue
        let URLString = string.ifNotEmpty !! {kSBGoogleSuggestURL.format($0).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)}
        let URL = URLString !! {NSURL(string: $0)}
        let downloader = SBDownloader(URL: URL)
        downloader.delegate = self
        downloader.start()
    }
    
    func updateURLFieldGoogleSuggestDidEnd(data: NSData?) {
        if data != nil && URLField.isFirstResponder {
            // Parse XML
            if var items = (try? SBParseGoogleSuggestData(data!))?.ifNotEmpty {
                let item = SBURLFieldItem.None(title: NSLocalizedString("Suggestions", comment: ""),
                                               image: NSImage(named: "Icon_G.png")!.TIFFRepresentation!)
                items.insert(item, atIndex: 0)
                URLField.gsItems = items
                URLField.items = URLField.gsItems + URLField.bmItems + URLField.hItems
            } else {
                URLField.gsItems = []
            }
            URLField.appearSheetIfNeeded(true)
        }
    }
    
    func updateURLFieldCompletionList() {
        var bmItems: [SBURLFieldItem] = []
        var hItems: [SBURLFieldItem] = []
        var URLStrings: [String] = []
        let string = URLField.stringValue
        let bookmarks = SBBookmarks.sharedBookmarks
        let history = SBHistory.sharedHistory
        
        // Search in bookmarks
        for bookmarkItem in bookmarks.items {
            if let URLString = bookmarkItem[kSBBookmarkURL] as? String {
                let title = bookmarkItem[kSBBookmarkTitle] as? String
                let schemelessURLString = URLString.stringByDeletingScheme
                var range = title?.rangeOfString(string, options: .CaseInsensitiveSearch)
                var matchWithTitle = false
                if range == nil {
                    range = URLString.rangeOfString(string)
                } else {
                    // Match with title
                    matchWithTitle = title != nil
                }
                if range == nil {
                    range = schemelessURLString!.rangeOfString(string)
                }
                if range != nil {
                    let item = SBURLFieldItem.Bookmark(title: matchWithTitle &? (title! as String), URL: URLString, image: bookmarkItem[kSBBookmarkImage] as? NSData)
                    bmItems.append(item)
                    URLStrings.append(URLString)
                }
            }
        }
        
        // Search in history
        for historyItem in history.items {
            if let URLString = historyItem.URLString
                   where !contains(URLStrings, URLString),
               let schemelessURLString = URLString.stringByDeletingScheme,
                   range = URLString.rangeOfString(string) ?? schemelessURLString.rangeOfString(string) {
                let item = SBURLFieldItem.History(URL: URLString, image: historyItem.icon?.TIFFRepresentation)
                hItems.append(item)
            }
        }
        
        if !bmItems.isEmpty {
            bmItems.insert(SBURLFieldItem.None(title: NSLocalizedString("Bookmarks", comment: ""),
                                               image: NSImage(named: "Icon_Bookmarks.png")!.TIFFRepresentation!),
                           atIndex: 0)
        }
        if !hItems.isEmpty {
            hItems.insert(SBURLFieldItem.None(title: NSLocalizedString("History", comment: ""),
                                              image: NSImage(named: "Icon_History.png")!.TIFFRepresentation!),
                          atIndex: 0)
        }
        URLField.bmItems = bmItems
        URLField.hItems = hItems
        URLField.items = bmItems + hItems
    }
    
    // MARK: Actions
    
    func performCloseFromButton(sender: AnyObject?) {
        tabView.sbDelegate = nil
        tabView.closeAllTabViewItems() // For destructing flash in the webViews
        close()
    }
    
    func performClose(sender: AnyObject?) {
        if shouldCloseDocument() {
            close()
        }
    }
    
    func shouldCloseDocument() -> Bool {
        var should = true
        if tabCount <= 1 {
        } else {
            tabbar.closeSelectedItem()
            should = false
        }
        if should {
            tabView.sbDelegate = nil
            tabView.closeAllTabViewItems() // For destructing flash in the webViews
        }
        return should
    }
    
    func openAndConstructTab(URLs URLs: [NSURL], startInTabbarItem aTabbarItem: SBTabbarItem) {
        let tabViewItem = tabView.tabViewItem(identifier: aTabbarItem.tag)
        if URLField.isFirstResponder {
            window.makeFirstResponder(selectedWebView)
        }
        for (i, URL) in enumerate(URLs) {
            if i == 0 && tabViewItem != nil {
                tabbar.selectItem(aTabbarItem)
                tabViewItem!.URL = URL
                tabView.selectTabViewItem(tabViewItem!)
            } else {
                constructNewTab(URL: URL, selection: false)
            }
        }
    }
    
    func openAndConstructTab(bookmarkItems items: [NSDictionary]) {
        let count = items.count
        if count > kSBDocumentWarningNumberOfBookmarksForOpening {
            let message = NSLocalizedString("Are you sure you want to open %d items?", comment: "").format(count)
            let alert = NSAlert()
            alert.messageText = message
            alert.addButtonWithTitle(NSLocalizedString("OK", comment: ""))
            alert.addButtonWithTitle(NSLocalizedString("Cancel", comment: ""))
            
            if alert.runModal() == NSAlertSecondButtonReturn {
                return
            }
        }
        if URLField.isFirstResponder {
            window.makeFirstResponder(selectedWebView)
        }
        for (i, item) in enumerate(items) {
            if let URLString = item[kSBBookmarkURL] as? String {
                if i == 0 {
                    openURLStringInSelectedTabViewItem(URLString)
                } else {
                    constructNewTab(URL: NSURL(string: URLString), selection: false)
                }
            }
        }
    }
    
    func adjustSplitViewIfNeeded() {
        let bookmarksView = sidebar?.view as? SBBookmarksView
        if bookmarksView &! {$0.mode == .Tile} {
            let viewRect = splitView.view.frame
            let pos = adjustedSplitPositon(viewRect.size.width)
            splitView.setPosition(pos, ofDividerAtIndex: 0)
        }
    }
    
    // MARK: Menu Actions
    
    override func printDocument(sender: AnyObject?) {
        let printOperation = NSPrintOperation(view: selectedWebDocumentView!)
        printOperation.showsPrintPanel = true
        printOperation.runOperation()
    }
    
    // MARK: Application menu
    
    func about(sender: AnyObject?) {
        if (window.coverWindow ?? window.backWindow) == nil {
            let aboutView = SBAboutView.sharedView
            aboutView.target = self
            aboutView.cancelSelector = #selector(doneAbout)
            window.flip(aboutView)
        } else {
            window.backWindow!.makeKeyWindow()
        }
    }
    
    func doneAbout() {
        window.doneFlip()
    }
    
    // File menu
    
    func createNewTab(sender: AnyObject?) {
        let homepage = SBPreferences.sharedPreferences.homepage(false)
        if !window.tabbarVisibility && tabbar.items.count > 0 {
            showTabbar()
        }
        constructNewTab(string: homepage, selection: true)
    }
    
    func openLocation(sender: AnyObject?) {
        selectURLField()
    }
    
    override func saveDocumentAs(sender: AnyObject?) {
        let panel = SBSavePanel()
        let title = selectedWebDataSource?.pageTitle
        let name = (title ?? NSLocalizedString("Untitled", comment: "")).stringByAppendingPathExtension("webarchive")!
        panel.nameFieldStringValue = name
        window.beginSheet(panel) {
            if $0 == NSFileHandlingPanelOKButton {
                let dataSource = self.selectedWebDataSource
                let archive = dataSource?.webArchive
                if let data = archive?.data {
                    if data.writeToURL(panel.URL!, atomically: true) {
                    }
                }
            }
        }
    }
    
    func downloadFromURL(sender: AnyObject?) {
        if window.coverWindow == nil {
            downloaderView = SBDownloaderView(frame: NSMakeRect(0, 0, 800, 240))
            downloaderView!.message = NSLocalizedString("Download any file from typed URL.", comment: "")
            downloaderView!.target = self
            downloaderView!.doneSelector = #selector(doneDownloader)
            downloaderView!.cancelSelector = #selector(cancelDownloader)
            window.showCoverWindow(downloaderView!)
            downloaderView!.makeFirstResponderToURLField()
        } else {
            window.coverWindow!.makeKeyWindow()
        }
    }
    
    func doneDownloader() {
        if let URL = downloaderView!.URLString.ifNotEmpty !! {NSURL(string: $0)} {
            startDownloading(forURL: URL)
        } else {
            // Error
        }
        window.hideCoverWindow()
        downloaderView = nil
    }
    
    func cancelDownloader() {
        window.hideCoverWindow()
        downloaderView = nil
    }
    
    func snapshot(sender: AnyObject?) {
        if window.coverWindow == nil {
            let image = selectedWebViewImage()
            let visibleRect = visibleRectOfSelectedWebDocumentView
            snapshotView = SBSnapshotView(frame: window.splitViewRect)
            snapshotView!.visibleRect = visibleRect
            snapshotView!.title = selectedTabViewItem!.pageTitle
            if snapshotView!.setImage(image) {
                snapshotView!.target = self
                snapshotView!.doneSelector = #selector(doneSnapshot)
                snapshotView!.cancelSelector = #selector(cancelSnapshot)
                window.showCoverWindow(snapshotView!)
            }
        } else {
            window.coverWindow!.makeKeyWindow()
        }
    }
    
    func doneSnapshot() {
        window.hideCoverWindow()
        snapshotView = nil
    }

    func cancelSnapshot() {
        window.hideCoverWindow()
        snapshotView = nil
    }
    
    // View menu
    
    func toggleAllbars(sender: AnyObject?) {
        let shouldShow = !(window.toolbar!.visible && window.tabbarVisibility)
        if shouldShow {
            showAllbars()
        } else {
            hideAllbars()
        }
    }
    
    func toggleTabbar(sender: NSMenuItem) {
        toggleTabbar()
        sender.title = window.tabbarVisibility ? NSLocalizedString("Hide Tabbar", comment: "") : NSLocalizedString("Show Tabbar", comment: "")
        NSUserDefaults.standardUserDefaults().setBool(window.tabbarVisibility, forKey: kSBTabbarVisibilityFlag)
    }
    
    func sidebarPositionToLeft(sender: AnyObject?) {
        sidebarToPosition(.Left)
    }

    func sidebarPositionToRight(sender: AnyObject?) {
        sidebarToPosition(.Right)
    }
    
    func sidebarToPosition(position: SBSidebarPosition) {
        if splitView.sidebarPosition != position {
            splitView.sidebarPosition = position
            NSUserDefaults.standardUserDefaults().setInteger(position.rawValue, forKey: kSBSidebarPosition)
        }
    }
    
    func reload(sender: AnyObject?) {
        if let webView = selectedWebView {
            if webView.loading {
                webView.stopLoading(nil)
            }
            webView.reload(nil)
        }
    }
    
    func stopLoading(sender: AnyObject?) {
        selectedWebView?.stopLoading(nil)
    }
    
    func scaleToActualSizeForView(sender: AnyObject?) {
        selectedWebView?.resetPageZoom(nil)
    }
    
    func zoomInView(sender: AnyObject?) {
        selectedWebView?.zoomPageIn(nil)
    }
    
    func zoomOutView(sender: AnyObject?) {
        selectedWebView?.zoomPageOut(nil)
    }
    
    func scaleToActualSizeForText(sender: AnyObject?) {
        selectedWebView?.makeTextStandardSize(nil)
    }
    
    func zoomInText(sender: AnyObject?) {
        selectedWebView?.makeTextLarger(nil)
    }
    
    func zoomOutText(sender: AnyObject?) {
        selectedWebView?.makeTextSmaller(nil)
    }
    
    func source(sender: AnyObject?) {
        selectedTabViewItem!.toggleShowSource()
    }
    
    func resources(sender: AnyObject?) {
        if splitView.visibleSidebar && sidebar != nil {
            if resourcesView != nil {
                hideSidebar()
            } else {
                let resourcesView = SBWebResourcesView(frame: sidebar!.viewRect)
                resourcesView.dataSource = self
                resourcesView.delegate = self
                sidebar!.view = resourcesView
            }
        } else {
            showSidebar()
            let resourcesView = SBWebResourcesView(frame: sidebar!.viewRect)
            resourcesView.dataSource = self
            resourcesView.delegate = self
            sidebar!.view = resourcesView
        }
    }
    
    func showWebInspector(sender: AnyObject?) {
        selectedWebView?.showWebInspector(nil)
    }

    func showConsole(sender: AnyObject?) {
        selectedWebView?.showConsole(nil)
    }

    // History menu
    
    func backward(sender: AnyObject?) {
        selectedTabViewItem?.backward(nil)
    }
    
    func forward(sender: AnyObject?) {
        selectedTabViewItem?.forward(nil)
    }
    
    func showHistory(sender: AnyObject?) {
        if window.coverWindow == nil {
            historyView = SBHistoryView(frame: window.splitViewRect)
            historyView!.message = NSLocalizedString("History", comment: "")
            historyView!.target = self
            historyView!.doneSelector = #selector(doneHistory(_:))
            historyView!.cancelSelector = #selector(cancelHistory)
            window.showCoverWindow(historyView!)
        } else {
            window.coverWindow!.makeKeyWindow()
        }
    }
    
    func doneHistory(URLs: NSArray) {
        if URLs.count > 0 {
            openAndConstructTab(URLs: URLs as! [NSURL], startInTabbarItem: tabbar.selectedTabbarItem!)
        }
        window.hideCoverWindow()
        historyView = nil
    }

    func cancelHistory() {
        window.hideCoverWindow()
        historyView = nil
    }

    func openHome(sender: AnyObject?) {
        if let homepage = NSUserDefaults.standardUserDefaults().stringForKey(kSBHomePage)?.ifNotEmpty?.requestURLString {
            if URLField.isFirstResponder {
                window.makeFirstResponder(selectedWebView)
            }
            openURLStringInSelectedTabViewItem(homepage)
        }
    }
    
    // Bookmarks menu
    
    func bookmarks(sender: AnyObject?) {
        if splitView.visibleSidebar && sidebar != nil {
            if sidebar!.view is SBBookmarksView {
                hideSidebar()
            } else {
                sidebar!.view = constructBookmarksView()
            }
        } else {
            showSidebar()
        }
    }
    
    func bookmark(sender: AnyObject?) {
        if window.coverWindow == nil {
            if let image = selectedWebViewImageForBookmark,
                   URLString = selectedTabViewItem!.mainFrameURLString {
                let bookmarks = SBBookmarks.sharedBookmarks
                let containsURL = bookmarks.containsURL(URLString)
                bookmarkView = SBBookmarkView(frame: NSMakeRect(0, 0, 880, 480))
                bookmarkView!.image = image
                bookmarkView!.message = containsURL ? NSLocalizedString("This page is already added to bookmarks. \nAre you sure you want to update it?", comment: "") : NSLocalizedString("Are you sure you want to bookmark this page?", comment: "")
                bookmarkView!.title = window.title
                bookmarkView!.URLString = URLString
                bookmarkView!.target = self
                bookmarkView!.doneSelector = #selector(doneBookmark)
                bookmarkView!.cancelSelector = #selector(cancelBookmark)
                window.showCoverWindow(bookmarkView!)
                bookmarkView!.makeFirstResponderToTitleField()
            }
        } else {
            window.coverWindow!.makeKeyWindow()
        }
    }
    
    func doneBookmark() {
        let bookmarks = SBBookmarks.sharedBookmarks
        let item = bookmarkView!.itemRepresentation
        bookmarks.addItem(item)
        bookmarkView = nil
        window.hideCoverWindow()
        if let bookmarksView = sidebar?.view as? SBBookmarksView {
            bookmarksView.addForBookmarkItem(item)
            bookmarksView.scrollToItem(item)
        }
    }
    
    func cancelBookmark() {
        window.hideCoverWindow()
        bookmarkView = nil
    }
    
    func editBookmarkItemAtIndex(index: Int) {
        if window.coverWindow == nil {
            let bookmarks = SBBookmarks.sharedBookmarks
            if let item = bookmarks.itemAtIndex(index) {
                let imageData = item[kSBBookmarkImage] as? NSData
                let image = imageData !! {NSImage(data: $0)}
                let title = item[kSBBookmarkTitle] as? String
                let URLString = item[kSBBookmarkURL] as? String
                let labelName = item[kSBBookmarkLabelName] as? String
                editBookmarkView = SBEditBookmarkView(frame: NSMakeRect(0, 0, 880, 480))
                editBookmarkView!.index = index
                editBookmarkView!.image = image
                editBookmarkView!.title = title!
                editBookmarkView!.URLString = URLString!
                editBookmarkView!.labelName = labelName
                editBookmarkView!.target = self
                editBookmarkView!.doneSelector = #selector(doneEditBookmark)
                editBookmarkView!.cancelSelector = #selector(cancelEditBookmark)
                window.showCoverWindow(editBookmarkView!)
                editBookmarkView!.makeFirstResponderToTitleField()
            }
        } else {
            window.coverWindow!.makeKeyWindow()
        }
    }
    
    func doneEditBookmark() {
        let bookmarks = SBBookmarks.sharedBookmarks
        let item = editBookmarkView!.itemRepresentation
        let index = editBookmarkView!.index
        bookmarks.replaceItem(item, atIndex: index)
        editBookmarkView = nil
        window.hideCoverWindow()
    }
    
    func cancelEditBookmark() {
        window.hideCoverWindow()
        editBookmarkView = nil
    }
    
    func searchInBookmarks(sender: AnyObject?) {
        (sidebar?.view as? SBBookmarksView)?.setShowSearchbar(true)
    }
    
    func switchToIconMode(sender: AnyObject?) {
        (sidebar?.view as? SBBookmarksView)?.mode = .Icon
    }
    
    func switchToListMode(sender: AnyObject?) {
        (sidebar?.view as? SBBookmarksView)?.mode = .List
    }
    
    func switchToTileMode(sender: AnyObject?) {
        if let bookmarksView = sidebar?.view as? SBBookmarksView {
            bookmarksView.mode = .Tile
            adjustSplitViewIfNeeded()
        }
    }
    
    // Window menu
    
    func selectPreviousTab(sender: AnyObject?) {
        tabbar.selectPreviousItem()
    }

    func selectNextTab(sender: AnyObject?) {
        tabbar.selectNextItem()
    }
    
    func downloads(sender: AnyObject?) {
        if !splitView.visibleSidebar {
            showSidebar()
        }
        if !(sidebar!.visibleDrawer) {
            showDrawer()
        }
        if !(sidebar!.drawer!.view is SBDownloadsView) {
            constructDownloadsViewInSidebar()
        }
    }
    
    // MARK: Toolbar Actions
    
    func openURLFromField(sender: AnyObject?) {
        openString(URLField.stringValue, newTab: false)
    }
    
    func openURLInNewTabFromField(sender: AnyObject?) {
        openString(URLField.stringValue, newTab: true)
    }
    
    func openString(stringValue: String?, newTab newer: Bool) {
        if let requestURLString = stringValue?.requestURLString {
            if newer {
                let URL = requestURLString.ifNotEmpty !! {NSURL(string: $0)}
                constructNewTab(URL: URL, selection: true)
            } else {
                openURLStringInSelectedTabViewItem(requestURLString)
            }
        }
    }
    
    func searchString(stringValue: String?, newTab newer: Bool) {
        if let searchURLString = stringValue?.searchURLString {
            if newer {
                let URL = searchURLString.ifNotEmpty !! {NSURL(string: $0)}
                constructNewTab(URL: URL, selection: true)
            } else {
                openURLStringInSelectedTabViewItem(searchURLString)
            }
        }
    }
    
    func changeEncodingFromMenuItem(sender: NSMenuItem) {
        let IANAName = sender.representedObject as? String
        selectedWebView!.customTextEncodingName = IANAName
    }
    
    func load(sender: AnyObject?) {
        let webView = selectedWebView!
        if webView.loading {
            webView.stopLoading(nil)
        } else {
            webView.reload(nil)
        }
    }
    
    func bugReport(sender: AnyObject?) {
        if window.coverWindow == nil {
            reportView = SBReportView(frame: window.splitViewRect)
            reportView!.target = self
            reportView!.doneSelector = #selector(doneReport)
            reportView!.cancelSelector = #selector(cancelReport)
            window.showCoverWindow(reportView!)
        } else {
            window.coverWindow!.makeKeyWindow()
        }
    }
    
    func doneReport() {
        window.hideCoverWindow()
        reportView = nil
    }

    func cancelReport() {
        window.hideCoverWindow()
        reportView = nil
    }
    
    func selectUserAgent(sender: AnyObject?) {
        if (window.coverWindow ?? window.backWindow) == nil {
            userAgentView = SBUserAgentView(frame: NSMakeRect(0, 0, 800, 240))
            userAgentView!.target = self
            userAgentView!.doneSelector = #selector(doneUserAgent)
            userAgentView!.cancelSelector = #selector(cancelUserAgent)
            window.flip(userAgentView!)
        } else {
            window.backWindow!.makeKeyWindow()
        }
    }
    
    func doneUserAgent() {
        window.doneFlip()
        userAgentView = nil
        selectedTabViewItem!.setUserAgent()
        selectedWebView!.reload(nil)
    }
    
    func cancelUserAgent() {
        window.doneFlip()
        userAgentView = nil
    }
    
    // MARK: Actions
    
    func openURLStringInSelectedTabViewItem(stringValue: String) {
        tabView.openURLInSelectedTabViewItem(stringValue)
    }
    
    func selectURLField() {
        if !window.toolbar!.visible {
            window.showToolbar()
        }
        URLField.selectText(nil)
    }
    
    func startDownloading(forURL URL: NSURL?) {
        URL !! SBDownloads.sharedDownloads.addItem
    }
    
    func toggleAllbarsAndSidebar() {
        let visibleToolbar = window.toolbar!.visible
        let visibleTabbar = window.tabbarVisibility
        let visibleSidebar = splitView.visibleSidebar && sidebar != nil
        if visibleToolbar && visibleTabbar && visibleSidebar {
            hideAllbars()
            hideSidebar()
        } else {
            showAllbars()
            showSidebar()
        }
    }
    
    func hideAllbars() {
        hideTabbar()
        hideToolbar()
    }
    
    func showAllbars() {
        showTabbar()
        showToolbar()
    }
    
    func hideToolbar() {
        window.hideToolbar()
    }
    
    func showToolbar() {
        window.showToolbar()
    }
    
    func toggleTabbar() {
        if window.tabbarVisibility {
            hideTabbar()
        } else {
            showTabbar()
        }
    }
    
    func hideTabbar() {
        window.hideTabbar()
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: kSBTabbarVisibilityFlag)
    }

    func showTabbar() {
        window.showTabbar()
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: kSBTabbarVisibilityFlag)
    }
    
    func hideSidebar() {
        splitView.closeSidebar(nil)
    }
    
    func showSidebar() {
        if sidebar == nil {
            sidebarVisibility = true
            sidebar = constructSidebar()
        }
        splitView.openSidebar(nil)
    }
    
    func hideDrawer() {
        sidebar!.closeDrawer(nil)
    }
    
    func showDrawer() {
        sidebar!.openDrawer(nil)
    }
    
    func showMessage(message: String) {
        if window.coverWindow == nil {
            messageView = SBMessageView(frame: NSMakeRect(0, 0, 800, 240), text: message)
            messageView!.target = self
            messageView!.doneSelector = #selector(doneShowMessageView)
            window.showCoverWindow(messageView!)
        } else {
            window.coverWindow!.makeKeyWindow()
        }
    }
    
    func doneShowMessageView() {
        window.hideCoverWindow()
        messageView = nil
    }
    
    func confirmMessage(message: String) -> Bool {
        var r = false
        if window.coverWindow == nil {
            confirmed = -1
            messageView = SBMessageView(frame: NSMakeRect(0, 0, 800, 240), text: message)
            messageView!.target = self
            messageView!.doneSelector = #selector(doneConfirmMessageView)
            messageView!.cancelSelector = #selector(cancelConfirmMessageView)
            window.showCoverWindow(messageView!)
            while confirmed == -1 {
                // Wait event...
                autoreleasepool {
                    let event = NSApp.nextEventMatchingMask(Int(truncatingBitPattern: NSEventMask.AnyEventMask.rawValue), untilDate: NSDate.distantFuture(), inMode: NSDefaultRunLoopMode, dequeue: true)!
                    NSApp.sendEvent(event)
                }
            }
            r = confirmed == 1
        }
        else {
            window.coverWindow!.makeKeyWindow()
        }
        return r
    }

    func doneConfirmMessageView() {
        confirmed = 1
        window.hideCoverWindow()
        messageView = nil
    }

    func cancelConfirmMessageView() {
        confirmed = 0
        window.hideCoverWindow()
        messageView = nil
    }
    
    func textInput(prompt: String) -> String? {
        var text: String?
        if window.coverWindow == nil {
            confirmed = -1
            textInputView = SBTextInputView(frame: NSMakeRect(0, 0, 800, 320), prompt: prompt)
            textInputView!.target = self
            textInputView!.doneSelector = #selector(doneTextInputView)
            textInputView!.cancelSelector = #selector(cancelTextInputView)
            window.showCoverWindow(textInputView!)
            while confirmed == -1 {
                // Wait event...
                autoreleasepool {
                    let event = NSApp.nextEventMatchingMask(Int(truncatingBitPattern: NSEventMask.AnyEventMask.rawValue), untilDate: NSDate.distantFuture(), inMode: NSDefaultRunLoopMode, dequeue: true)!
                    NSApp.sendEvent(event)
                }
            }
            if confirmed == 1 {
                text = textInputView!.text
            }
            textInputView = nil
        } else {
            window.coverWindow!.makeKeyWindow()
        }
        return text
    }

    func doneTextInputView() {
        confirmed = 1
        window.hideCoverWindow()
    }

    func cancelTextInputView() {
        confirmed = 0
        window.hideCoverWindow()
    }
    
    func toggleEditableForSelectedWebView() {
        let editable = !(selectedWebView!.editable)
        if editable {
            // let frameElement = selectedWebView.mainFrame.frameElement
            // let style = frameElement.style
            // style.borderWidth = "2px"
            // style.borderStyle = "solid"
            // style.borderColor = "red"
            // frameElement.style = style
        }
        selectedWebView!.editable = editable
    }
    
    func toggleFlip() {
        window.flip()
    }
    
    // MARK: Debug
    
    func debug(value: Bool) {
        let innerView = window.innerView
        let tAnimation = CAKeyframeAnimation(keyPath: "transform")
        var tvalues: [NSValue] = []
        var finalTransform = CATransform3DIdentity
        var midTransform = CATransform3DIdentity
        let width = window.frame.size.width
        finalTransform.m34 = 1.0 / -(width * 2)
        midTransform.m34 = 1.0 / -(width * 2)
        finalTransform = CATransform3DRotate(midTransform, 180 * CGFloat(M_PI) / 180, 1.0, 0.0, 0.0)
        midTransform = CATransform3DRotate(midTransform, 90 * CGFloat(M_PI) / 180, 1.0, 0.0, 0.0)
        if value.boolValue {
            tvalues.append(NSValue(CATransform3D: CATransform3DIdentity))
            tvalues.append(NSValue(CATransform3D: midTransform))
            tvalues.append(NSValue(CATransform3D: finalTransform))
        } else {
            tvalues.append(NSValue(CATransform3D: finalTransform))
            tvalues.append(NSValue(CATransform3D: midTransform))
            tvalues.append(NSValue(CATransform3D: CATransform3DIdentity))
        }
        tAnimation.values = tvalues
        tAnimation.duration = 1.0
        // tAnimation.removedOnCompletion = false
        // tAnimation.fillMode = kCAFillModeForwards
        innerView.layer!.removeAllAnimations()
        innerView.layer!.addAnimation(tAnimation, forKey: "transform")
    }
    
    func debugAddDummyDownloads(sender: AnyObject?) {
        let downloads = SBDownloads.sharedDownloads
        let names = ["Long Long File Name", 
                     "Long File Name",
                     "Longfilename",
                     "File Name",
                     "Filename",
                     "File",
                     "F"]
        for name in names {
            let item = SBDownload(URL: NSURL(string: "http://localhost/dummy")!)
            item.name = name
            item.path = "/unknown"
            downloads.addItem(item)
        }
        SBDispatchDelay(0.5) {
            self.debugAddDummyDownloadsDidEnd(names)
        }
    }
    
    func debugAddDummyDownloadsDidEnd(names: [String]) {
        let downloads = SBDownloads.sharedDownloads
        let downloadsView = sidebar!.drawer!.view as! SBDownloadsView
        for index in 0..<names.count {
            let item = downloads.items[index]
            if index == 0 {
                item.status = .Undone
            } else if index > 0 {
                item.expectedLength = 10000000
                item.receivedLength = Int(CGFloat(item.expectedLength) * (CGFloat(index) / CGFloat(names.count)))
                item.status = .Processing
            } else if index >= 1 {
                item.receivedLength = 10000000
                item.expectedLength = item.receivedLength
                item.status = .Done
            }
            item.bytes = String.bytesString(CLongLong(item.receivedLength), expectedLength: CLongLong(item.expectedLength))
            downloadsView.updateForItem(item)
        }
    }
}