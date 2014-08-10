/*
SBDownload.swift

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

import Foundation

class SBDownload: NSObject {
    var identifier: Int = -1
    private var _name: String?
    var name: String? {
        get {
            return _name ?? URL?.absoluteString
        }
        set(name) { _name = name }
    }
    var URL: NSURL? {
        return download?.request.URL
    }
    var download: NSURLDownload?
    var path: String?
    var bytes: String?
	var downloading = false
    var receivedLength: Int = 0
    var expectedLength: Int = 0
    var status: SBStatus = .Processing
    
    convenience init(URL url: NSURL) {
        let download = NSURLDownload(request: NSURLRequest(URL: url), delegate: SBDownloads.sharedDownloads)
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