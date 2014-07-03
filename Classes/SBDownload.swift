//
//  SBDownload.swift
//  Sunrise
//
//  Created by Alice Atlas on 7/2/14.
//
//

import Foundation

class SBDownload: NSObject {
    var identifier: Int = -1
    var _name: String?
    var name: String? {
    get {
        return (_name == nil) ? URL?.absoluteString : _name
    }
    set(name) {
        _name = name
    }
    }
    var URL: NSURL?
    var download: NSURLDownload?
    var path: String?
    var bytes: String?
	var downloading = false
    var receivedLength: Int = 0
    var expectedLength: Int = 0
    var status: SBStatus = .Processing
    
    convenience init(URL url: NSURL) {
        let download = NSURLDownload(request: NSURLRequest(URL: url), delegate: SBDownloads.sharedDownloads())
        self.init(download: download)
    }
    
    init(download: NSURLDownload) {
        self.download = download
        self.downloading = true
    }
    
    var progress: Float {
        return (status == SBStatus.Done) ? 1.0 : ((expectedLength == 0) ? 0 : Float(receivedLength) / Float(expectedLength))
    }
    
    // Actions
    
    func stop() {
        download?.cancel()
        download = nil
        downloading = false
    }
}