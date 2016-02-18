/*
SBUpdateView.swift

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

class SBUpdateView: SBView, SBDownloaderDelegate, WebFrameLoadDelegate, WebUIDelegate {
    private let kSBMinFrameSizeWidth: CGFloat = 600
    private let kSBMaxFrameSizeWidth: CGFloat = 900
    private let kSBMinFrameSizeHeight: CGFloat = 480
    private let kSBMaxFrameSizeHeight: CGFloat = 720
    
	private lazy var imageView: NSImageView = {
        let imageView = NSImageView(frame: self.imageRect)
        if let image = NSImage(named: "Application.icns") {
            image.size = imageView.frame.size
            imageView.image = image
        }
        return imageView
    }()
	private lazy var titleLabel: NSTextField = {
        let titleLabel = NSTextField(frame: self.titleRect)
        titleLabel.bordered = false
        titleLabel.editable = false
        titleLabel.selectable = false
        titleLabel.drawsBackground = false
        titleLabel.font = NSFont.boldSystemFontOfSize(16.0)
        titleLabel.textColor = NSColor.whiteColor()
        titleLabel.autoresizingMask = .ViewWidthSizable
        return titleLabel
    }()
	private lazy var textLabel: NSTextField = {
        let textLabel = NSTextField(frame: self.titleRect)
        textLabel.bordered = false
        textLabel.editable = false
        textLabel.selectable = false
        textLabel.drawsBackground = false
        textLabel.font = NSFont.systemFontOfSize(13.0)
        textLabel.textColor = NSColor.lightGrayColor()
        textLabel.autoresizingMask = .ViewWidthSizable
        return textLabel
    }()
	private lazy var webView: WebView = {
        let webView = WebView(frame: self.webRect, frameName: nil, groupName: nil)
        webView.autoresizingMask = [.ViewWidthSizable, .ViewHeightSizable]
        webView.frameLoadDelegate = self
        webView.UIDelegate = self
        webView.hidden = true
        webView.drawsBackground = false
        // webView.mainFrame.loadRequest(NSURLRequest(URL: NSURL(string: "https://www.google.com/")))
        return webView
    }()
	private lazy var indicator: NSProgressIndicator = {
        let indicator = NSProgressIndicator(frame: self.indicatorRect)
        indicator.controlSize = .RegularControlSize
        indicator.style = .SpinningStyle
        indicator.displayedWhenStopped = false
        return indicator
    }()
	private lazy var skipButton: BLKGUI.Button = {
        let skipButton = BLKGUI.Button(frame: self.skipButtonRect)
        skipButton.autoresizingMask = [.ViewMaxXMargin, .ViewMinYMargin]
        skipButton.target = self
        skipButton.action = "skip"
        skipButton.setButtonType(.MomentaryPushInButton)
        skipButton.title = NSLocalizedString("Skip This Version", comment: "")
        skipButton.font = NSFont.systemFontOfSize(11.0)
        return skipButton
    }()
	private lazy var cancelButton: BLKGUI.Button = {
        let cancelButton = BLKGUI.Button(frame: self.skipButtonRect)
        cancelButton.autoresizingMask = [.ViewMaxXMargin, .ViewMinYMargin]
        cancelButton.target = self
        cancelButton.action = "cancel"
        cancelButton.setButtonType(.MomentaryPushInButton)
        cancelButton.title = NSLocalizedString("Not Now", comment: "")
        cancelButton.font = NSFont.systemFontOfSize(11.0)
        cancelButton.keyEquivalent = "\u{1B}"
        return cancelButton
    }()
	private lazy var doneButton: BLKGUI.Button = {
        let doneButton = BLKGUI.Button(frame: self.skipButtonRect)
        doneButton.autoresizingMask = [.ViewMaxXMargin, .ViewMinYMargin]
        doneButton.target = self
        doneButton.action = "done"
        doneButton.setButtonType(.MomentaryPushInButton)
        doneButton.title = NSLocalizedString("Download", comment: "")
        doneButton.font = NSFont.systemFontOfSize(11.0)
        doneButton.keyEquivalent = "\u{1B}"
        return doneButton
    }()
    
    var title: String {
        get { return titleLabel.stringValue }
        set(title) { titleLabel.stringValue = title }
    }
    
    var text: String {
        get { return textLabel.stringValue }
        set(title) { textLabel.stringValue = title }
    }
    
    var versionString: String?
    
    override init(frame: NSRect) {
        var r = frame
        SBConstrain(&r.size.width, min: kSBMinFrameSizeWidth, max: kSBMaxFrameSizeWidth)
        SBConstrain(&r.size.height, min: kSBMinFrameSizeHeight, max: kSBMaxFrameSizeHeight)
        super.init(frame: r)
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(textLabel)
        addSubview(webView)
        addSubview(indicator)
        addSubview(skipButton)
        addSubview(cancelButton)
        addSubview(doneButton)
        autoresizingMask = [.ViewMinXMargin, .ViewMaxXMargin, .ViewMinYMargin, .ViewMaxYMargin]
    }

    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    // MARK: Rect
    
    let margin = NSMakePoint(20.0, 20.0)
    let bottomMargin: CGFloat = 50.0
    
    var imageRect: NSRect {
        var r = NSZeroRect
        r.size.width = 64.0
        r.size.height = 64.0
        r.origin.x = margin.x
        r.origin.y = bounds.size.height - (margin.y + r.size.height)
        return r
    }
    
    var titleRect: NSRect {
        var r = NSZeroRect
        r.size.height = 19.0
        r.origin.x = imageRect.maxX + 10
        r.origin.y = imageRect.origin.y + 34
        r.size.width = bounds.size.width - r.origin.x - margin.x
        return r
    }
    
    var textRect: NSRect {
        var r = NSZeroRect
        r.size.height = 19.0
        r.origin.x = imageRect.maxX + 10
        r.origin.y = imageRect.origin.y + 10
        r.size.width = bounds.size.width - r.origin.x - margin.x
        return r
    }
    
    var webRect: NSRect {
        var r = NSZeroRect
        r.origin.x = imageRect.origin.x
        r.origin.y = bottomMargin
        r.size.width = bounds.size.width - r.origin.x - margin.x
        r.size.height = bounds.size.height - (imageRect.size.height + margin.y + 8.0 + bottomMargin)
        return r
    }
    
    var indicatorRect: NSRect {
        var r = NSZeroRect
        r.size.width = 32.0
        r.size.height = 32.0
        r.origin.x = webRect.midX - r.size.width / 2
        r.origin.y = webRect.midY - r.size.height / 2
        return r
    }
    
    var skipButtonRect: NSRect {
        var r = NSZeroRect
        r.size.height = 32.0
        r.origin.x = webRect.origin.x
        r.origin.y = (bottomMargin - r.size.height) / 2
        r.size.width = 165.0
        return r
    }
    
    var cancelButtonRect: NSRect {
        var r = skipButtonRect
        r.origin.x = bounds.size.width - 273.0
        r.size.width = 131.0
        return r
    }
    
    var doneButtonRect: NSRect {
        var r = skipButtonRect
        r.origin.x = bounds.size.width - 134.0
        r.size.width = 114.0
        return r
    }
    
    // MARK: Delegate
    
    func downloader(downloader: SBDownloader, didFinish data: NSData) {
        let baseURL = NSBundle.mainBundle().URLForResource("Releasenotes", withExtension: "html")!
        let htmlString = self.htmlString(baseURL: baseURL, releaseNotesData: data)!
        indicator.stopAnimation(nil)
        webView.mainFrame.loadHTMLString(htmlString, baseURL: baseURL)
        doneButton.enabled = true
    }
    
    func downloader(downloader: SBDownloader, didFail error: NSError?) {
        indicator.stopAnimation(nil)
    }
    
    func webView(sender: WebView, didStartProvisionalLoadForFrame frame: WebFrame) {
        indicator.startAnimation(nil)
    }

    func webView(sender: WebView, didFinishLoadForFrame frame: WebFrame) {
        webView.hidden = false
        indicator.stopAnimation(nil)
        doneButton.enabled = true
    }
    
    func webView(sender: WebView, didFailLoadWithError error: NSError, forFrame frame: WebFrame) {
        indicator.stopAnimation(nil)
    }

    func webView(sender: WebView, didFailProvisionalLoadWithError error: NSError, forFrame frame: WebFrame) {
        indicator.stopAnimation(nil)
    }
    
    // MARK: Actions
    
    func loadRequest(URL: NSURL) {
        let downloader = SBDownloader(URL: URL)
        downloader.delegate = self
        downloader.start()
        indicator.startAnimation(nil)
    }
    
    func skip() {
        versionString !! { NSUserDefaults.standardUserDefaults().setObject($0, forKey: kSBUpdaterSkipVersion) }
        cancel()
    }
    
    // MARK: Functions
    
    func htmlString(baseURL baseURL: NSURL, releaseNotesData data: NSData?) -> String? {
        if let data = data, baseHTML = String(contentsOfURL: baseURL, encoding: NSUTF8StringEncoding, error: nil) {
            let releaseNotes = String(UTF8String: UnsafePointer<CChar>(data.bytes))
            return baseHTML.format(releaseNotes ?? NSLocalizedString("No data", comment: ""))
        }
        return nil
    }
}