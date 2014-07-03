//
//  SBRenderWindow.swift
//  Sunrise
//
//  Created by Alice Atlas on 7/3/14.
//
//

@objc protocol SBRenderWindowDelegate: NSWindowDelegate {
    @optional func renderWindowDidStartRendering(renderWindow: SBRenderWindow)
    @optional func renderWindow(renderWindow: SBRenderWindow, didFinishRenderingImage: NSImage)
    @optional func renderWindow(renderWindow: SBRenderWindow, didFailWithError: NSError)
}

class SBRenderWindow: NSWindow {
    var webView: WebView?
    //var delegate: SBRenderWindowDelegate!
    
    class func startRenderingWithSize(size: NSSize, delegate: SBRenderWindowDelegate?, url: NSURL) -> SBRenderWindow {
        let r = NSRect(origin: NSZeroPoint, size: size)
        let window = SBRenderWindow(contentRect: r)
        window.delegate = delegate
        window.webView!.mainFrame.loadRequest(NSURLRequest(URL: url))
        if kSBFlagShowRenderWindow != 0 {
            window.orderFront(nil)
        }
        return window
    }
    
    init(contentRect: NSRect) {
        let styleMask = NSBorderlessWindowMask
        let bufferingType = NSBackingStoreType.Buffered
        let deferCreation = true
        super.init(contentRect: contentRect, styleMask: styleMask, backing: bufferingType, defer: deferCreation)
        
        var r = contentRect
        r.origin = NSZeroPoint
        webView = WebView(frame: r, frameName: nil, groupName: nil)
        webView!.frameLoadDelegate = self
        webView!.preferences = SBGetWebPreferences()
        webView!.hostWindow = self
        self.contentView.addSubview(webView)
        self.releasedWhenClosed = true
    }
    
    func destruct() {
        self.destructWebView()
        self.close()
    }
    
    func destructWebView() {
        if let webView = self.webView {
            if webView.loading {
                webView.stopLoading(nil)
            }
            //???
            webView.hostWindow = nil
            webView.frameLoadDelegate = nil
            webView.removeFromSuperview()
            self.webView = nil
        }
    }
    
    // Delegate
    
    override func webView(sender: WebView, didStartProvisionalLoadForFrame frame: WebFrame) {
        if let delegate = self.delegate as? SBRenderWindowDelegate {
            delegate.renderWindowDidStartRendering?(self)
        }
    }
    
    override func webView(sender: WebView, didFinishLoadForFrame frame: WebFrame) {
        if let delegate = self.delegate as? SBRenderWindowDelegate {
            if delegate.respondsToSelector("renderWindow:didFinishRenderingImage:") {
                let webDocumentView = sender.mainFrame.frameView.documentView
                let intersectRect = webDocumentView.bounds
                if webDocumentView != nil {
                    let image = NSImage(view: webDocumentView).insetWithSize(SBBookmarkImageMaxSize(), intersectRect: intersectRect, offset: NSZeroPoint)
                    delegate.renderWindow!(self, didFinishRenderingImage: image)
                }
            }
        }
        self.destruct()
    }
    
    override func webView(sender: WebView, didFailProvisionalLoadWithError error: NSError, forFrame frame: WebFrame) {
        if let delegate = self.delegate as? SBRenderWindowDelegate {
            delegate.renderWindow?(self, didFailWithError: error)
        }
    }
    
    override func webView(sender: WebView, didFailLoadWithError error: NSError, forFrame frame: WebFrame) {
        if let delegate = self.delegate as? SBRenderWindowDelegate {
            delegate.renderWindow?(self, didFailWithError: error)
        }
    }
}