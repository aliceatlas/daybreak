/*
SBDownloads.swift

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

private var _sharedDownloads = SBDownloads()

func ==(first: SBDownload, second: SBDownload) -> Bool {
    return first === second
}
extension SBDownload: Equatable {}

class SBDownloads: NSObject, NSURLDownloadDelegate {
    var items: [SBDownload] = []
	var _identifier = 0
    
    class var sharedDownloads: SBDownloads {
        return _sharedDownloads
    }
    
    var downloading: Bool {
        return items.any { $0.downloading }
    }
    
    // MARK: Actions
    
    func addItem(item: SBDownload) {
        items.append(item)
        item.identifier = createdIdentifier()
        // Update views
        executeDidAddItem(item)
    }
    
    func addItemWithURL(url: NSURL) {
        addItem(SBDownload(URL: url))
    }
    
    func removeItem(item: SBDownload) {
        removeItems([item])
    }
    
    func removeItems(inItems: [SBDownload]) {
        if let item = inItems.first({ $0.downloading }) {
            item.stop()
        }
        for item in inItems {
            if item.downloading {
                item.stop()
            }
        }
        // Update views
        executeWillRemoveItem(inItems)
        removeObjects(&items, inItems)
    }
    
    // MARK: Execute
    
    func executeDidAddItem(item: SBDownload) {
        let userInfo = [kSBDownloadsItem: item]
        NSNotificationCenter.defaultCenter().postNotificationName(SBDownloadsDidAddItemNotification, object: self, userInfo: userInfo)
    }
    
    func executeWillRemoveItem(items: [SBDownload]) {
        let userInfo = [kSBDownloadsItems: items]
        NSNotificationCenter.defaultCenter().postNotificationName(SBDownloadsWillRemoveItemNotification, object: self, userInfo: userInfo)
    }
    
    func executeDidUpdateItem(item: SBDownload) {
        let userInfo = [kSBDownloadsItem: item]
        NSNotificationCenter.defaultCenter().postNotificationName(SBDownloadsDidUpdateItemNotification, object: self, userInfo: userInfo)
    }
    
    func executeDidFinishItem(item: SBDownload) {
        let userInfo = [kSBDownloadsItem: item]
        NSNotificationCenter.defaultCenter().postNotificationName(SBDownloadsDidFinishItemNotification, object: self, userInfo: userInfo)
    }
    
    // MARK: NSURLDownload Delegate
    
    func downloadDidBegin(download: NSURLDownload) {
        var downloadItem = items.first { $0.download === download }
        if downloadItem == nil {
            downloadItem = SBDownload(download: download)
            addItem(downloadItem!)
        }
        // Update view
        downloadItem!.status = .Processing
        executeDidUpdateItem(downloadItem!)
    }
    
    func download(download: NSURLDownload, willSendRequest request: NSURLRequest, redirectResponse: NSURLResponse) -> NSURLRequest {
        if let item = items.first({ $0.download === download }) {
            // Update views
            executeDidUpdateItem(item)
        }
        return request
    }
    
    func download(download: NSURLDownload, didReceiveResponse response: NSURLResponse) {
        if let item = items.first({ $0.download === download }) {
            item.expectedLength = max(0, Int(response.expectedContentLength))
            item.bytes = bytesString(item.receivedLength, item.expectedLength)
            // Update views
            executeDidUpdateItem(item)
        }
    }
    
    func download(download: NSURLDownload, decideDestinationWithSuggestedFilename filename: String) {
        if let item = items.first({ $0.download === download }) {
            item.path = SBPreferences.objectForKey(kSBSaveDownloadedFilesTo) as String
            if NSFileManager.defaultManager().fileExistsAtPath(item.path!) {
                item.path = item.path!.stringByAppendingPathComponent(filename)
                item.download?.setDestination(item.path, allowOverwrite: false)
                // Update views
                executeDidUpdateItem(item)
            } else {
                //<# Alert not found path #>
                item.receivedLength = 0
                item.expectedLength = 0
                item.stop()
            }
        }
    }
    
    func download(download: NSURLDownload, didReceiveDataOfLength length: Int) {
        if let item = items.first({ $0.download === download }) {
            // Update the item
            if item.expectedLength > 0 {
                item.receivedLength += length
            }
            item.bytes = bytesString(item.receivedLength, item.expectedLength)
            // Update views
            executeDidUpdateItem(item)
        }
    }
    
    func downloadDidFinish(download: NSURLDownload) {
        if let item = items.first({ $0.download === download }) {
            // Finish the item
            item.status = .Done
            item.downloading = false
            // Update views
            executeDidFinishItem(item)
        }
    }
    
    func download(download: NSURLDownload, didFailWithError error: NSError) {
        if let item = items.first({ $0.download === download }) {
            item.status = .Undone
            item.downloading = false
            item.receivedLength = 0
            item.expectedLength = 0
            // Update views
            executeDidUpdateItem(item)
        }
    }
    
    func download(download: NSURLDownload, shouldDecodeSourceDataOfMIMEType encodingType: String) -> Bool {
        return true
    }
    
    func download(download: NSURLDownload, didCreateDestination path: String!) {
        if let item = items.first({ $0.download === download }) {
            if path.lastPathComponent.utf16Count > 0 {
                item.name = path.lastPathComponent
            }
            item.path = path
        }
    }
    
    // MARK: Function
    
    func createdIdentifier() -> Int {
        return _identifier++
    }
}