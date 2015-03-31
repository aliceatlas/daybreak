/*
SBTabViewItem.swift

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

class SBTabViewItem: NSTabViewItem, NSSplitViewDelegate, SBWebViewDelegate, SBSourceTextViewDelegate {
    unowned var tabbarItem: SBTabbarItem
    override var tabView: SBTabView! {
        return super.tabView as? SBTabView
    }
    var URL: NSURL? {
        didSet {
            URL !! { self.webView.mainFrame.loadRequest(NSURLRequest(URL: $0, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: kSBTimeoutInterval)) }
        }
    }
    lazy var splitView: SBTabSplitView = {
        let splitView = SBTabSplitView(frame: NSZeroRect)
        splitView.delegate = self
        splitView.autoresizingMask = .ViewWidthSizable | .ViewHeightSizable
        return splitView
    }()
    var sourceView: SBDrawer?
    var madeWebView = false
    lazy var webView: SBWebView = {
        let center = NSNotificationCenter.defaultCenter()
        let view = SBWebView(frame: self.tabView!.bounds, frameName: nil, groupName: nil)
        // Set properties
        view.drawsBackground = true
        view.autoresizingMask = .ViewWidthSizable | .ViewHeightSizable
        view.delegate = self
        view.hostWindow = self.tabView!.window
        view.frameLoadDelegate = self
        view.resourceLoadDelegate = self
        view.UIDelegate = self
        view.policyDelegate = self
        view.downloadDelegate = SBDownloads.sharedDownloads
        view.preferences = SBGetWebPreferences
        view.textEncodingName = view.preferences.defaultTextEncodingName
        self.setUserAgent(view)
        
        // Add observer
        center.addObserver(self, selector: "webViewProgressStarted:", name: WebViewProgressStartedNotification, object: view)
        center.addObserver(self, selector: "webViewProgressEstimateChanged:", name: WebViewProgressEstimateChangedNotification, object: view)
        center.addObserver(self, selector: "webViewProgressFinished:", name: WebViewProgressFinishedNotification, object: view)
        
        self.splitView.invisibleDivider = true
        self.splitView.addSubview(view)
        
        self.madeWebView = true
        return view
    }()
    var sourceTextView: SBSourceTextView?
    var webSplitView: SBFixedSplitView?
    var sourceSplitView: SBFixedSplitView?
    var sourceSaveButton: SBBLKGUIButton?
    var sourceCloseButton: SBBLKGUIButton?
    var resourceIdentifiers: [SBWebResourceIdentifier] = []
    //var showSource = false
    private let sourceBottomMargin: CGFloat = 48.0
    var URLString: String? {
        get { return URL?.absoluteString }
        set(URLString) {
            URL = URLString !! {NSURL(string: $0.URLEncodedString)}
        }
    }
    var selected: Bool {
        get { return tabView.selectedTabViewItem! === self }
        set(selected) { tabView.selectTabViewItem(self) }
    }
    var canBackward: Bool { return webView.canGoBack }
    var canForward: Bool { return webView.canGoForward }
    var mainFrameURLString: String? { return webView.mainFrameURL }
    var pageTitle: String? { return webView.mainFrame.dataSource?.pageTitle }
    var requestURLString: String? { return webView.mainFrame?.dataSource?.request.URL?.absoluteString }
    var documentSource: String? { return webView.mainFrame?.dataSource?.representation?.documentSource() }
    
    init(identifier: Int, tabbarItem: SBTabbarItem) {
        self.tabbarItem = tabbarItem
        super.init(identifier: identifier)
        view = NSView(frame: NSZeroRect)
        view!.addSubview(splitView)
    }
    
    deinit {
        destructWebView()
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    // MARK: Getter
    
    func webFramesInFrame(frame: WebFrame) -> [WebFrame] {
        var frames: [WebFrame] = []
        for childFrame in frame.childFrames as! [WebFrame] {
            frames.append(childFrame)
            if !childFrame.childFrames.isEmpty {
                frames += webFramesInFrame(childFrame)
            }
        }
        return frames
    }
    
    // MARK: Setter
    
    func toggleShowSource() {
        showSource = !showSource
    }
    
    func hideShowSource() {
        showSource = false
    }
    
    var showSource: Bool = false {
        didSet {
            if showSource != oldValue {
                if showSource {
                    var r = view!.bounds
                    var tr = view!.bounds
                    var br = view!.bounds
                    var openRect = NSZeroRect
                    var saveRect = NSZeroRect
                    var closeRect = NSZeroRect
                    var wr = view!.bounds
                    wr.size.height *= 0.6
                    r.size.height *= 0.4
                    br.size.height = sourceBottomMargin
                    tr.size.height = r.size.height - br.size.height
                    tr.origin.y = br.size.height
                    saveRect.size.width = 105.0
                    saveRect.size.height = 24.0
                    saveRect.origin.x = r.size.width - saveRect.size.width - 10.0
                    saveRect.origin.y = br.origin.y + (br.size.height - saveRect.size.height) / 2
                    openRect.size.width = 210.0
                    openRect.size.height = 24.0
                    openRect.origin.y = saveRect.origin.y
                    openRect.origin.x = saveRect.origin.x - openRect.size.width - 10.0
                    closeRect.size.width = 105.0
                    closeRect.size.height = 24.0
                    closeRect.origin.y = saveRect.origin.y
                    closeRect.origin.x = 10.0
                    sourceView = SBDrawer(frame: r)
                    let scrollView = SBBLKGUIScrollView(frame: tr)
                    let openButton = SBBLKGUIButton(frame: openRect)
                    sourceSaveButton = SBBLKGUIButton(frame: saveRect)
                    sourceCloseButton = SBBLKGUIButton(frame: closeRect)
        #if true
                    let horizontalScroller = scrollView.horizontalScroller as? SBBLKGUIScroller
                    let verticalScroller = scrollView.verticalScroller as? SBBLKGUIScroller
                    verticalScroller !! { r.size.width = r.size.width - $0.frame.size.width }
        #endif
                    sourceTextView = SBSourceTextView(frame: tr)
                    scrollView.autoresizingMask = .ViewWidthSizable | .ViewHeightSizable
                    scrollView.autohidesScrollers = true
                    scrollView.hasHorizontalScroller = false
                    scrollView.hasVerticalScroller = true
                    scrollView.backgroundColor = SBBackgroundColor
                    scrollView.drawsBackground = true
        #if true
                    horizontalScroller?.drawsBackground = true
                    horizontalScroller?.backgroundColor = NSColor(calibratedWhite: 0.35, alpha: 1.0)
                    verticalScroller?.drawsBackground = true
                    verticalScroller?.backgroundColor = NSColor(calibratedWhite: 0.35, alpha: 1.0)
        #endif
                    sourceTextView!.delegate = self
                    sourceTextView!.minSize = NSMakeSize(0.0, r.size.height)
                    sourceTextView!.maxSize = NSMakeSize(CGFloat(FLT_MAX), CGFloat(FLT_MAX))
                    sourceTextView!.verticallyResizable = true
                    sourceTextView!.horizontallyResizable = false
                    sourceTextView!.usesFindPanel = true
                    sourceTextView!.editable = false
                    sourceTextView!.autoresizingMask = .ViewWidthSizable
                    sourceTextView!.textContainer!.containerSize = NSMakeSize(r.size.width, CGFloat(FLT_MAX))
                    sourceTextView!.textContainer!.widthTracksTextView = true
                    sourceTextView!.string = (documentSource ?? "")!
                    sourceTextView!.selectedRange = NSMakeRange(0, 0)
                    scrollView.documentView = sourceTextView
                    openButton.autoresizingMask = .ViewMinXMargin
                    openButton.title = NSLocalizedString("Open in other application…", comment: "")
                    openButton.target = self
                    openButton.action = "openDocumentSource:"
                    sourceSaveButton!.autoresizingMask = .ViewMinXMargin
                    sourceSaveButton!.title = NSLocalizedString("Save", comment: "")
                    sourceSaveButton!.target = self
                    sourceSaveButton!.action = "saveDocumentSource:"
                    sourceSaveButton!.keyEquivalent = "\r"
                    sourceCloseButton!.autoresizingMask = .ViewMinXMargin
                    sourceCloseButton!.title = NSLocalizedString("Close", comment: "")
                    sourceCloseButton!.target = self
                    sourceCloseButton!.action = "hideShowSource"
                    sourceCloseButton!.keyEquivalent = "\u{1B}"
                    sourceView!.addSubview(scrollView)
                    sourceView!.addSubview(openButton)
                    sourceView!.addSubview(sourceSaveButton!)
                    sourceView!.addSubview(sourceCloseButton!)
                    if webSplitView != nil {
                        webSplitView!.frame = wr
                        splitView.addSubview(webSplitView!)
                    } else {
                        webView.frame = wr
                        splitView.addSubview(webView)
                    }
                    splitView.addSubview(sourceView!)
                    splitView.invisibleDivider = false
                    webView.window!.makeFirstResponder(sourceTextView)
                } else {
                    sourceTextView!.removeFromSuperview()
                    sourceSplitView?.removeFromSuperview()
                    sourceView!.removeFromSuperview()
                    sourceTextView = nil
                    sourceSplitView = nil
                    sourceView = nil
                    splitView.invisibleDivider = true
                    webView.window!.makeFirstResponder(webView)
                }
                splitView.adjustSubviews()
            }
        }
    }
    
    func setShowFindbarInWebView(showFindbar: Bool) -> Bool {
        var r = false
        if showFindbar {
            if webSplitView == nil {
                let findbar = SBFindbar(frame: NSMakeRect(0, 0, webView.frame.size.width, 24.0))
                findbar.target = webView
                findbar.doneSelector = "executeCloseFindbar"
                if sourceSplitView != nil {
                    sourceSplitView!.removeFromSuperview()
                } else if sourceView != nil {
                    sourceView!.removeFromSuperview()
                }
                webSplitView = SBFixedSplitView(embedViews: [findbar, webView], frameRect: webView.frame)
                if sourceSplitView != nil {
                    splitView.addSubview(sourceSplitView!)
                } else if sourceView != nil {
                    splitView.addSubview(sourceView!)
                }
                findbar.selectText(nil)
                r = true
            }
        } else {
            if webSplitView != nil {
                if sourceSplitView != nil {
                    sourceSplitView!.removeFromSuperview()
                } else if sourceView != nil {
                    sourceView!.removeFromSuperview()
                }
                SBDisembedViewInSplitView(webView, webSplitView!)
                if sourceSplitView != nil {
                    splitView.addSubview(sourceSplitView!)
                } else if sourceView != nil {
                    splitView.addSubview(sourceView!)
                }
                webSplitView = nil
                webView.window!.makeFirstResponder(webView)
                r = true
            }
        }
        return r
    }
    
    func setShowFindbarInSource(showFindbar: Bool) {
        if showFindbar {
            if sourceSplitView == nil {
                let findbar = SBFindbar(frame: NSMakeRect(0, 0, sourceView!.frame.size.width, 24.0))
                findbar.target = sourceTextView
                findbar.doneSelector = "executeCloseFindbar"
                sourceSaveButton!.keyEquivalent = ""
                sourceCloseButton!.keyEquivalent = ""
                sourceSplitView = SBFixedSplitView(embedViews: [findbar, sourceView!], frameRect: sourceView!.frame)
                findbar.selectText(nil)
            }
        } else {
            sourceSaveButton!.keyEquivalent = "\r"
            sourceCloseButton!.keyEquivalent = "\u{1B}"
            SBDisembedViewInSplitView(sourceView!, sourceSplitView!)
            sourceSplitView = nil
            sourceTextView!.window!.makeFirstResponder(sourceTextView)
        }
    }
    
    func hideFinderbarInWebView() {
        setShowFindbarInWebView(false)
    }
    
    func hideFinderbarInSource() {
        setShowFindbarInSource(false)
    }
    
    // MARK: Destruction
    
    func destructWebView() {
        if madeWebView {
            let center = NSNotificationCenter.defaultCenter()
            center.removeObserver(self, name: WebViewProgressStartedNotification, object: webView)
            center.removeObserver(self, name: WebViewProgressEstimateChangedNotification, object: webView)
            center.removeObserver(self, name: WebViewProgressFinishedNotification, object: webView)
            if webView.loading {
                webView.stopLoading(nil)
            }
            webView.hostWindow = nil
            webView.frameLoadDelegate = nil
            webView.resourceLoadDelegate = nil
            webView.UIDelegate = nil
            webView.policyDelegate = nil
            webView.downloadDelegate = nil
            webView.removeFromSuperview()
        }
    }
    
    // MARK: Construction
    
    func setUserAgent() {
        setUserAgent(nil)
    }
    
    private func setUserAgent(inView: SBWebView?) {
        let webView = inView ?? self.webView
        var userAgentName = NSUserDefaults.standardUserDefaults().stringForKey(kSBUserAgentName)
        // Set custom user agent
        if userAgentName == SBUserAgentNames[0] {
            let bundle = NSBundle.mainBundle()
            let infoDictionary = bundle.infoDictionary
            let localizedInfoDictionary = bundle.localizedInfoDictionary
            let applicationName = (localizedInfoDictionary?["CFBundleName"] ?? infoDictionary?["CFBundleName"]) as? String
            let version = (infoDictionary?["CFBundleVersion"] as? String)?.stringByDeletingSpaces
            var safariVersion = NSBundle(path: "/Applications/Safari.app")?.infoDictionary?["CFBundleVersion"] as? String
            safariVersion = safariVersion !! {suffix($0, count($0.utf16) - 1)} ?? "0"
            if applicationName != nil {
                webView.applicationNameForUserAgent = applicationName!
                version !! { webView.applicationNameForUserAgent = "\(webView.applicationNameForUserAgent)/\($0) Safari/\(safariVersion!)" }
                webView.customUserAgent = nil
            }
        } else if userAgentName == SBUserAgentNames[1] {
            let applicationName = SBUserAgentNames[1]
            let bundle = NSBundle(path: "/Applications/\(applicationName).app")
            let infoDictionary = bundle?.infoDictionary
            let version = (infoDictionary?["CFBundleShortVersionString"] ?? infoDictionary?["CFBundleVersion"]) as? String
            var safariVersion = NSBundle(path: "/Applications/Safari.app")?.infoDictionary?["CFBundleVersion"] as? String
            safariVersion = safariVersion !! {suffix($0, count($0.utf16) - 1)} ?? "0"
            if (version !! safariVersion) != nil {
                webView.applicationNameForUserAgent = "Version/\(version!) \(applicationName)/\(safariVersion!)"
                webView.customUserAgent = nil
            }
        } else {
            webView.customUserAgent = userAgentName
        }
    }

    // MARK: SplitView Delegate

    func splitView(aSplitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
        return aSplitView !== splitView || subview !== webView
    }

    func splitView(aSplitView: NSSplitView, shouldHideDividerAtIndex dividerIndex: Int) -> Bool {
        return false
    }

    func splitView(aSplitView: NSSplitView, shouldCollapseSubview subview: NSView, forDoubleClickOnDividerAtIndex dividerIndex: Int) -> Bool {
        return true
    }

    func splitView(aSplitView: NSSplitView, constrainSplitPosition proposedPosition: CGFloat, ofSubviewAt offset: Int) -> CGFloat {
        return proposedPosition
    }

    func splitView(aSplitView: NSSplitView, constrainMaxCoordinate proposedMax: CGFloat, ofSubviewAt offset: Int) -> CGFloat {
        if aSplitView === splitView {
            return splitView.bounds.size.height - 10 - sourceBottomMargin
        }
        return proposedMax
    }

    func splitView(aSplitView: NSSplitView, constrainMinCoordinate proposedMin: CGFloat, ofSubviewAt offset: Int) -> CGFloat {
        if aSplitView === splitView {
            return 10
        }
        return proposedMin
    }

    // MARK: TextView Delegate
    
    func textViewShouldOpenFindbar(textView: SBSourceTextView) {
        if sourceSplitView != nil {
            setShowFindbarInSource(false)
        }
        setShowFindbarInSource(true)
    }
    
    func textViewShouldCloseFindbar(textView: SBSourceTextView) {
        if sourceSplitView != nil {
            setShowFindbarInSource(false)
        }
    }
    
    // MARK: WebView Delegate
    
    func webViewShouldOpenFindbar(webView: SBWebView) {
        if webSplitView != nil {
            setShowFindbarInWebView(false)
        }
        setShowFindbarInWebView(true)
    }
    
    func webViewShouldCloseFindbar(webView: SBWebView) -> Bool {
        if webSplitView != nil {
            return setShowFindbarInWebView(false)
        }
        return false
    }
    
    // MARK: WebView Notification
    
    func webViewProgressStarted(notification: NSNotification) {
        if notification.object === webView {
            tabbarItem.progress = 0.0
        }
    }
    
    func webViewProgressEstimateChanged(notification: NSNotification) {
        if notification.object === webView {
            tabbarItem.progress = CGFloat(webView.estimatedProgress)
        }
    }
    
    func webViewProgressFinished(notification: NSNotification) {
        if notification.object === webView {
            tabbarItem.progress = 1.0
        }
    }
    
    // MARK: WebFrameLoadDelegate
    
    override func webView(sender: WebView, didStartProvisionalLoadForFrame frame: WebFrame) {
        if sender.mainFrame === frame {
            removeAllResourceIdentifiers()
        }
    }
    
    override func webView(sender: WebView, didFinishLoadForFrame frame: WebFrame) {
        if sender.mainFrame === frame {
            if selected {
                tabView.executeSelectedItemDidFinishLoading(self)
            }
            if showSource {
                sourceTextView!.string = documentSource
            }
        }
    }
    
    override func webView(sender: WebView, didCommitLoadForFrame frame: WebFrame) {
        if sender.mainFrame === frame && selected {
            tabView.executeSelectedItemDidStartLoading(self)
        }
    }
    
    override func webView(sender: WebView, willCloseFrame frame: WebFrame) {
        if sender.mainFrame === frame {
        }
    }

    override func webView(sender: WebView, didChangeLocationWithinPageForFrame frame: WebFrame) {
        if sender.mainFrame === frame {
        }
    }

    override func webView(sender: WebView, didReceiveTitle title: String, forFrame frame: WebFrame) {
        if sender.mainFrame === frame {
            tabbarItem.title = title
            if selected {
                tabView.executeSelectedItemDidReceiveTitle(self)
            }
        }
    }
    
    override func webView(sender: WebView, didReceiveIcon image: NSImage, forFrame frame: WebFrame) {
        if sender.mainFrame === frame {
            tabbarItem.image = image
            if selected {
                tabView.executeSelectedItemDidReceiveIcon(self)
            }
        }
    }
    
    override func webView(sender: WebView, didFailProvisionalLoadWithError error: NSError?, forFrame frame: WebFrame) {
        // if ([[sender mainFrame] isEqual:frame]) {
        if error != nil {
            DebugLog("%@, %@", __FUNCTION__, error!.localizedDescription)
            if let userInfo = error!.userInfo {
                let URLString = userInfo[NSURLErrorFailingURLStringErrorKey] as! String
                var title: String?
                switch error!.code {
                    case NSURLErrorCancelled:
                        title = NSLocalizedString("Cancelled", comment: "")
                    case NSURLErrorBadURL:
                        title = NSLocalizedString("Bad URL", comment: "")
                    case NSURLErrorTimedOut:
                        title = NSLocalizedString("Timed Out", comment: "")
                    case NSURLErrorUnsupportedURL:
                        title = NSLocalizedString("Unsupported URL", comment: "")
                    case NSURLErrorCannotFindHost:
                        title = NSLocalizedString("Cannot Find Host", comment: "")
                    case NSURLErrorCannotConnectToHost:
                        title = NSLocalizedString("Cannot Connect to Host", comment: "")
                    case NSURLErrorNetworkConnectionLost:
                        title = NSLocalizedString("Network Connection Lost", comment: "")
                    case NSURLErrorDNSLookupFailed:
                        title = NSLocalizedString("DNS Lookup Failed", comment: "")
                    case NSURLErrorHTTPTooManyRedirects:
                        title = NSLocalizedString("Too Many Redirects", comment: "")
                    case NSURLErrorResourceUnavailable:
                        title = NSLocalizedString("Resource Unavailable", comment: "")
                    case NSURLErrorNotConnectedToInternet:
                        title = NSLocalizedString("Not Connected to Internet", comment: "")
                    case NSURLErrorRedirectToNonExistentLocation:
                        title = NSLocalizedString("Redirect to Non Existent Location", comment: "")
                    case NSURLErrorBadServerResponse:
                        title = NSLocalizedString("Bad Server Response", comment: "")
                    case NSURLErrorUserCancelledAuthentication:
                        title = NSLocalizedString("User Cancelled Authentication", comment: "")
                    case NSURLErrorUserAuthenticationRequired:
                        title = NSLocalizedString("User Authentication Required", comment: "")
                    case NSURLErrorZeroByteResource:
                        title = NSLocalizedString("Zero Byte Resource", comment: "")
                    case NSURLErrorCannotDecodeRawData:
                        title = NSLocalizedString("Cannot Decode Raw Data", comment: "")
                    case NSURLErrorCannotDecodeContentData:
                        title = NSLocalizedString("Cannot Decode Content Data", comment: "")
                    case NSURLErrorCannotParseResponse:
                        title = NSLocalizedString("Cannot Parse Response", comment: "")
                    case NSURLErrorFileDoesNotExist:
                        title = NSLocalizedString("File Does Not Exist", comment: "")
                    case NSURLErrorFileIsDirectory:
                        if let url = NSURL(string: URLString) {
                            // Try to opening with other application
                            if !NSWorkspace.sharedWorkspace().openURL(url) {
                                title = NSLocalizedString("File is Directory", comment: "")
                            }
                        }
                    case NSURLErrorNoPermissionsToReadFile:
                        title = NSLocalizedString("No Permissions to ReadFile", comment: "")
                    case NSURLErrorDataLengthExceedsMaximum:
                        title = NSLocalizedString("Data Length Exceeds Maximum", comment: "")
                    case NSURLErrorSecureConnectionFailed:
                        title = NSLocalizedString("Secure Connection Failed", comment: "")
                    case NSURLErrorServerCertificateHasBadDate:
                        title = NSLocalizedString("Server Certificate Has BadDate", comment: "")
                    case NSURLErrorServerCertificateUntrusted:
                        let url = NSURL(string: URLString)!
                        let aTitle = NSLocalizedString("Server Certificate Untrusted", comment: "")
                        var alert = NSAlert()
                        alert.messageText = aTitle
                        alert.addButtonWithTitle(NSLocalizedString("Continue", comment: ""))
                        alert.addButtonWithTitle(NSLocalizedString("Cancel", comment: ""))
                        alert.informativeText = NSLocalizedString("The certificate for this website is invalid. You might be connecting to a website that is pretending to be \"%@\", which could put your confidential information at risk. Would you like to connect to the website anyway?", comment: "").format(url.host!)
                        alert.beginSheetModalForWindow(sender.window!) {
                            if $0 == NSAlertFirstButtonReturn {
                                NSURLRequest.setAllowsAnyHTTPSCertificate(true, forHost: url.host)
                                frame.loadRequest(NSURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: kSBTimeoutInterval))
                                self.webView(self.webView, didStartProvisionalLoadForFrame: frame)
                            } else {
                                self.showErrorPageWithTitle(aTitle, urlString: url.absoluteString!, frame: frame)
                            }
                        }
                    case NSURLErrorServerCertificateHasUnknownRoot:
                        title = NSLocalizedString("Server Certificate Has UnknownRoot", comment: "")
                    case NSURLErrorServerCertificateNotYetValid:
                        title = NSLocalizedString("Server Certificate Not Yet Valid", comment: "")
                    case NSURLErrorClientCertificateRejected:
                        title = NSLocalizedString("Client Certificate Rejected", comment: "")
                    case NSURLErrorCannotLoadFromNetwork:
                        title = NSLocalizedString("Cannot Load from Network", comment: "")
                    default:
                        break
                }
                title !! { self.showErrorPageWithTitle($0, urlString: URLString, frame: frame) }
            }
        }
    }
    
    override func webView(sender: WebView, didFailLoadWithError error: NSError, forFrame frame: WebFrame) {
        if sender.mainFrame === frame {
            DebugLog("%@, %@", __FUNCTION__, error.localizedDescription)
            if selected {
                tabView.executeSelectedItemDidFailLoading(self)
            }
        }
    }
    
    override func webView(sender: WebView, didReceiveServerRedirectForProvisionalLoadForFrame frame: WebFrame) {
        if sender.mainFrame === frame {
            if selected {
                tabView.executeSelectedItemDidReceiveServerRedirect(self)
            }
        }
    }
    
    // MARK: WebResourceLoadDelegate
    
    override func webView(sender: WebView, identifierForInitialRequest request: NSURLRequest, fromDataSource dataSource: WebDataSource) -> AnyObject {
        let identifier = SBWebResourceIdentifier(URLRequest: request)
        if addResourceIdentifier(identifier) && selected {
            tabView.executeSelectedItemDidAddResourceID(identifier)
        }
        return identifier
    }
    
    override func webView(sender: WebView, resource identifier: AnyObject?, willSendRequest request: NSURLRequest, redirectResponse: NSURLResponse, fromDataSource dataSource: WebDataSource) -> NSURLRequest {
        return request
    }
    
    override func webView(sender: WebView, resource identifier: AnyObject?, didReceiveResponse response: NSURLResponse, fromDataSource dataSource: WebDataSource) {
        let length = response.expectedContentLength
        if length > 0 {
            if let resourceID = identifier as? SBWebResourceIdentifier {
                resourceID.length = length
                if selected {
                    tabView.executeSelectedItemDidReceiveExpectedContentLengthOfResourceID(resourceID)
                }
            }
        }
    }
    
    override func webView(sender: WebView, resource identifier: AnyObject?, didFailLoadingWithError error: NSError, fromDataSource dataSource: WebDataSource) {
        if let resourceID = identifier as? SBWebResourceIdentifier {
            resourceID.flag = false
        }
    }
    
    override func webView(sender: WebView, resource identifier: AnyObject?, didReceiveContentLength length: Int, fromDataSource dataSource: WebDataSource) {
        if length > 0 {
            if let resourceID = identifier as? SBWebResourceIdentifier {
                resourceID.received += length
                if selected {
                    tabView.executeSelectedItemDidReceiveContentLengthOfResourceID(resourceID)
                }
            }
        }
    }
    
    override func webView(sender: WebView, resource identifier: AnyObject?, didFinishLoadingFromDataSource dataSource: WebDataSource) {
        if let resourceID = identifier as? SBWebResourceIdentifier {
            if let response = NSURLCache.sharedURLCache().cachedResponseForRequest(resourceID.request) {
                // Loaded from cache
                let length = response.data.length
                if length > 0 {
                    resourceID.length = CLongLong(length)
                    resourceID.received = CLongLong(length)
                }
            }
            if selected {
                tabView.executeSelectedItemDidReceiveFinishLoadingOfResourceID(resourceID)
            }
        }
    }
    
    // MARK: WebUIDelegate
    
    override func webViewShow(sender: WebView) {
        if let document = sender.window!.delegate as? SBDocument {
            document.showWindows()
        }
    }
    
    override func webView(sender: WebView, setToolbarsVisible visible: Bool) {
        let window = sender.window as! SBDocumentWindow
        let toolbar = window.sbToolbar!
        toolbar.autosavesConfiguration = false
        toolbar.visible = visible
        if visible {
            if !window.tabbarVisibility {
                window.showTabbar()
            }
        } else {
            if !window.tabbarVisibility {
                window.hideTabbar()
            }
        }
    }
    
    override func webView(sender: WebView, createWebViewModalDialogWithRequest request: NSURLRequest) -> WebView {
        return webView
    }
    
    override func webView(sender: WebView, createWebViewWithRequest request: NSURLRequest) -> WebView {
        var error: NSError?
        let document = SBGetDocumentController.openUntitledDocumentAndDisplay(false, sidebarVisibility: false, initialURL: request.URL, error: &error) as! SBDocument
        return document.selectedWebView!
    }
    
    override func webView(sender: WebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WebFrame) -> Bool {
        return tabView.executeShouldConfirmMessage(message)
    }
    
    override func webView(sender: WebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WebFrame) {
        tabView.executeShouldShowMessage(message)
    }
    
    override func webView(sender: WebView, runOpenPanelForFileButtonWithResultListener resultListener: WebOpenPanelResultListener) {
        let panel = SBOpenPanel()
        let window = tabView!.window!
        panel.beginSheetModalForWindow(window) {
            if $0 == NSFileHandlingPanelOKButton {
                resultListener.chooseFilename(panel.URLs[0].path)
            }
            panel.orderOut(nil)
        }
    }
    
    override func webView(sender: WebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String, initiatedByFrame frame: WebFrame) -> String? {
        return tabView.executeShouldTextInput(prompt)
    }
    
    override func webView(sender: WebView, contextMenuItemsForElement element: [NSObject: AnyObject], defaultMenuItems: [AnyObject]) -> [AnyObject] {
        var menuItems: [NSMenuItem] = []
        var selectedString = (sender.mainFrame.frameView.documentView as! WebDocumentText).selectedString()
        if !selectedString.isEmpty {
            for frame in webFramesInFrame(sender.mainFrame) {
                selectedString = (frame.frameView.documentView as! WebDocumentText).selectedString()
                if !selectedString.isEmpty {
                    break
                }
            }
        }
        let linkURL = element[WebElementLinkURLKey] as? NSURL
        let frame = element[WebElementFrameKey] as! WebFrame
        let frameURL = frame.dataSource?.request.URL
        let applicationBundleIdentifier = NSUserDefaults.standardUserDefaults().stringForKey(kSBOpenApplicationBundleIdentifier)
        var appName: String?
        if let applicationPath = applicationBundleIdentifier !! {NSWorkspace.sharedWorkspace().absolutePathForAppBundleWithIdentifier($0)} {
            if let bundle = NSBundle(path: applicationPath) {
                appName = (bundle.localizedInfoDictionary?["CFBundleDisplayName"] ?? bundle.infoDictionary?["CFBundleName"]) as? String
            }
        }
        
        menuItems.extend(defaultMenuItems as! [NSMenuItem])
        
        if linkURL == nil && selectedString.isEmpty {
            if frameURL != nil {
                // Add Open in items
                let newItem1 = NSMenuItem(title: NSLocalizedString("Open in Application...", comment: ""), action:"openURLInSelectedApplicationFromMenu:", keyEquivalent: "")
                newItem1.target = self
                newItem1.representedObject = frameURL
                var newItem2: NSMenuItem?
                if appName != nil {
                    newItem2 = NSMenuItem(title: NSLocalizedString("Open in %@", comment: "").format(appName!), action: "openURLInApplicationFromMenu:", keyEquivalent: "")
                    newItem2!.target = self
                    newItem2!.representedObject = frameURL
                }
                menuItems.insert(NSMenuItem.separatorItem(), atIndex: 0)
                if newItem2 != nil {
                    menuItems.insert(newItem2!, atIndex: 0)
                }
                menuItems.insert(newItem1, atIndex: 0)
            }
        }
        if linkURL != nil {
            for (index, item) in reverse(Array(enumerate(menuItems))) {
                let tag = item.tag
                if tag == 1 {
                    // Add Open link in items
                    let newItem0 = NSMenuItem(title: NSLocalizedString("Open Link in New Tab", comment: ""), action: "openURLInNewTabFromMenu:", keyEquivalent: "")
                    newItem0.target = self
                    newItem0.representedObject = frameURL
                    let newItem1 = NSMenuItem(title: NSLocalizedString("Open Link in Application...", comment: ""), action: "openURLInSelectedApplicationFromMenu:", keyEquivalent: "")
                    newItem1.target = self
                    newItem1.representedObject = frameURL
                    var newItem2: NSMenuItem?
                    if appName != nil {
                        let newItem2 = NSMenuItem(title: NSLocalizedString("Open Link in %@", comment: "").format(appName!), action: "openURLInApplicationFromMenu:", keyEquivalent: "")
                        newItem2.target = self
                        newItem2.representedObject = frameURL
                    }
                    if newItem2 != nil {
                        menuItems.insert(newItem2!, atIndex: index)
                    }
                    menuItems.insert(newItem1, atIndex: index)
                    menuItems.insert(newItem0, atIndex: index)
                    break
                }
            }
        }
        if !selectedString.isEmpty {
            var replaced = false
            // Create items
            let newItem0 = NSMenuItem(title: NSLocalizedString("Search in Google", comment: ""), action: "searchStringFromMenu:", keyEquivalent: "")
            newItem0.target = self
            newItem0.representedObject = selectedString
            let newItem1 = NSMenuItem(title: NSLocalizedString("Open Google Search Results in New Tab", comment: ""), action: "searchStringInNewTabFromMenu:", keyEquivalent: "")
            newItem1.target = self
            newItem1.representedObject = selectedString
            // Find an item
            for (index, item) in reverse(Array(enumerate(menuItems))) {
                if item.tag == 21 {
                    menuItems[index] = newItem0
                    menuItems.insert(newItem1, atIndex: index + 1)
                    replaced = true
                }
            }
            if !replaced {
                menuItems.insert(NSMenuItem.separatorItem(), atIndex: 0)
                menuItems.insert(newItem0, atIndex: 0)
                menuItems.insert(newItem1, atIndex: 1)
            }
        }
        if frame !== sender.mainFrame {
            let newItem0 = NSMenuItem(title: NSLocalizedString("Open Frame in Current Frame", comment: ""), action: "openFrameInCurrentFrameFromMenu:", keyEquivalent: "")
            let newItem1 = NSMenuItem(title: NSLocalizedString("Open Frame in New Tab", comment: ""), action: "openURLInNewTabFromMenu:", keyEquivalent: "")
            newItem0.target = self
            newItem1.target = self
            newItem0.representedObject = frameURL
            newItem1.representedObject = frameURL
            menuItems.append(newItem0)
            menuItems.append(newItem1)
        }
        return menuItems
    }
    
    // MARK: WebPolicyDelegate
    
    override func webView(webView: WebView, decidePolicyForMIMEType type: String, request: NSURLRequest, frame: WebFrame, decisionListener listener: WebPolicyDecisionListener) {
        if WebView.canShowMIMETypeAsHTML(type) {
            listener.use()
        } else {
            listener.download()
        }
    }

    override func webView(webView: WebView, decidePolicyForNavigationAction actionInformation: [NSObject: AnyObject], request: NSURLRequest, frame: WebFrame, decisionListener listener: WebPolicyDecisionListener) {
        let url = request.URL!
        let modifierFlags = NSEventModifierFlags(rawValue: actionInformation[WebActionModifierFlagsKey] as! UInt)
        let navigationType = WebNavigationType(rawValue: actionInformation[WebActionNavigationTypeKey] as! Int)!
        switch navigationType {
            case .LinkClicked:
                if url.hasWebScheme { // 'http', 'https', 'file'
                    if modifierFlags & .CommandKeyMask != nil { // Command
                        var selection = true
                        let makeActiveFlag = NSUserDefaults.standardUserDefaults().boolForKey(kSBWhenNewTabOpensMakeActiveFlag)
                        // Make it active flag and Shift key mask
                        if makeActiveFlag {
                            if modifierFlags & .ShiftKeyMask != nil {
                                selection = false
                            }
                        } else {
                            if modifierFlags & .ShiftKeyMask != nil {
                            } else {
                                selection = false
                            }
                        }
                        tabView.executeShouldAddNewItemForURL(url, selection: selection)
                        listener.ignore()
                    } else if modifierFlags & .AlternateKeyMask != nil { // Option
                        listener.download()
                    } else {
                        listener.use()
                    }
                } else {
                    // Open URL in other application. 
                    if NSWorkspace.sharedWorkspace().openURL(url) {
                        listener.ignore()
                    } else {
                        listener.use()
                    }
                }
            case .FormSubmitted, .BackForward, .Reload, .FormResubmitted, .Other:
                listener.use()
            default:
                listener.use()
        }
    }
    
    override func webView(webView: WebView, decidePolicyForNewWindowAction actionInformation: [NSObject: AnyObject], request: NSURLRequest, newFrameName: String, decisionListener listener: WebPolicyDecisionListener) {
        // open link in new tab
        tabView.executeShouldAddNewItemForURL(request.URL!, selection: true)
    }
    
    override func webView(webView: WebView, unableToImplementPolicyWithError error: NSError, frame: WebFrame) {
        if let string = error.userInfo?["NSErrorFailingURLStringKey"] as? String {
            if let URL = NSURL(string: string) {
                if URL.hasWebScheme { // 'http', 'https', 'file'
                    // Error
                } else {
                    // open URL with other applications
                    if !NSWorkspace.sharedWorkspace().openURL(URL) {
                        // Error
                    }
                }
            }
        }
    }
    
    // MARK: Actions
    
    func addResourceIdentifier(identifier: SBWebResourceIdentifier) -> Bool {
        let anIdentifier = resourceIdentifiers.first { $0.request == identifier.request }
        if anIdentifier == nil {
            resourceIdentifiers.append(identifier)
            return true
        }
        DebugLog("%@ contains request %@", __FUNCTION__, anIdentifier!.request)
        return false
    }
    
    func removeAllResourceIdentifiers() {
        resourceIdentifiers.removeAll()
    }
    
    func backward(sender: AnyObject?) {
        if webView.canGoBack {
            webView.goBack(nil)
        }
    }
    
    func forward(sender: AnyObject?) {
        if webView.canGoForward {
            webView.goForward(nil)
        }
    }
    
    func openDocumentSource(sender: AnyObject?) {
        let openPanel = SBOpenPanel()
        openPanel.canChooseDirectories = false
        openPanel.allowedFileTypes = ["app"]
        if openPanel.runModal() == NSFileHandlingPanelOKButton {
            let encodingName = webView.textEncodingName
            var error: NSError?
            var name = (pageTitle != "") &? pageTitle
            name = (name ?? NSLocalizedString("Untitled", comment: "")).stringByAppendingPathExtension("html")
            let filePath = NSTemporaryDirectory().stringByAppendingPathComponent(name!)
            let encoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding(!encodingName.isEmpty ? encodingName : kSBDefaultEncodingName))
            if !(documentSource! as NSString).writeToFile(filePath, atomically: true, encoding: encoding, error: &error) {
                SBRunAlertWithMessage(error!.localizedDescription)
            } else {
                let appPath = openPanel.URL!.path!
                if !NSWorkspace.sharedWorkspace().openFile(filePath, withApplication: appPath) {
                    SBRunAlertWithMessage(NSLocalizedString("Could not open in %@.", comment: "").format(appPath))
                }
            }
        }
    }
    
    func saveDocumentSource(sender: AnyObject?) {
        let encodingName = webView.textEncodingName
        var name = (((pageTitle != "") &? pageTitle) ?? NSLocalizedString("Untitled", comment: "")).stringByAppendingPathExtension("html")!
        let encoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding(!encodingName.isEmpty ? encodingName : kSBDefaultEncodingName))
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.nameFieldStringValue = name
        if savePanel.runModal() == NSFileHandlingPanelOKButton {
            var error: NSError?
            if !(documentSource! as NSString).writeToFile(savePanel.URL!.path!, atomically: true, encoding: encoding, error: &error) {
                SBRunAlertWithMessage(error!.localizedDescription)
            }
        }
    }
    
    func removeFromTabView() {
        destructWebView()
        tabView!.removeTabViewItem(self)
    }
    
    func showErrorPageWithTitle(title: String, urlString: String, frame: WebFrame) {
        let bundle = NSBundle.mainBundle()
        let title = "<img src=\"Application.icns\" style=\"width:76px;height:76px;margin-right:10px;vertical-align:middle;\" alt=\"\">" + title
        let searchURLString = "https://www.google.com/search?hl=ja&q=" + urlString
        let searchMessage = NSLocalizedString("You can search the web for this URL.", comment: "")
        var message = NSLocalizedString("Daybreak can’t open the page “%@”", comment: "").format(urlString)
        message = "\(message)<br /><br />\(searchMessage)<br /><a href=\"\(searchURLString)\">\(urlString)</a>"
        let path = bundle.pathForResource("Error", ofType: "html")!
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            if let htmlString = String(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil) {
                let formattedHTML = htmlString.format(title, message)
                // Load
                frame.loadHTMLString(formattedHTML, baseURL: NSURL.fileURLWithPath(path))
            }
        }
    }
    
    // MARK: Menu Actions
    
    func searchStringFromMenu(menuItem: NSMenuItem) {
        if let searchString: String = menuItem.representedObject as? String {
            tabView.executeShouldSearchString(searchString, newTab: false)
        }
    }

    func searchStringInNewTabFromMenu(menuItem: NSMenuItem) {
        if let searchString: String = menuItem.representedObject as? String {
            tabView.executeShouldSearchString(searchString, newTab: true)
        }
    }
    
    func openURLInApplicationFromMenu(menuItem: NSMenuItem) {
        if let url = menuItem.representedObject as? NSURL {
            if let savedBundleIdentifier = NSUserDefaults.standardUserDefaults().stringForKey(kSBOpenApplicationBundleIdentifier) {
                openURL(url, inBundleIdentifier: savedBundleIdentifier)
            }
        }
    }
    
    func openURLInSelectedApplicationFromMenu(menuItem: NSMenuItem) {
        if let url = menuItem.representedObject as? NSURL {
            var bundleIdentifier: String?
            let panel = NSOpenPanel()
            panel.canChooseFiles = true
            panel.canChooseDirectories = false
            panel.allowedFileTypes = ["app"]
            panel.allowsMultipleSelection = false
            panel.directoryURL = NSURL.fileURLWithPath("/Applications")
            if panel.runModal() == NSFileHandlingPanelOKButton {
                if let bundle = NSBundle(URL: panel.URL!) {
                    bundleIdentifier = bundle.bundleIdentifier
                }
            }
            if bundleIdentifier != nil {
                if openURL(url, inBundleIdentifier: bundleIdentifier!) {
                    NSUserDefaults.standardUserDefaults().setObject(bundleIdentifier!, forKey: kSBOpenApplicationBundleIdentifier)
                }
            }
        }
    }
    
    func openURL(URL: NSURL?, inBundleIdentifier bundleIdentifier: String?) -> Bool {
        if (URL !! bundleIdentifier) != nil {
            return NSWorkspace.sharedWorkspace().openURLs([URL!], withAppBundleIdentifier: bundleIdentifier!, options: .Default, additionalEventParamDescriptor:nil, launchIdentifiers: nil)
        }
        return false
    }
    
    func openFrameInCurrentFrameFromMenu(menuItem: NSMenuItem) {
        if let URL = menuItem.representedObject as? NSURL {
            self.URL = URL
        }
    }
    
    func openURLInNewTabFromMenu(menuItem: NSMenuItem) {
        if let url = menuItem.representedObject as? NSURL {
            tabView.executeShouldAddNewItemForURL(url, selection: true)
        }
    }

}


class SBTabSplitView: NSSplitView {
    var invisibleDivider = false
    override var dividerThickness: CGFloat {
        return invisibleDivider ? 0.0 : 5.0
    }
    override var dividerColor: NSColor {
        return SBWindowBackColor
    }
}
