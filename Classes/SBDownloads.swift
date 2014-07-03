//
//  SBDownloads.swift
//  Sunrise
//
//  Created by Alice Atlas on 7/1/14.
//
//

//import "NSString-SBURLAdditions.h"

import Foundation

var _sharedDownloads = SBDownloads()

@infix func ==(first: SBDownload, second: SBDownload) -> Bool {
    return first === second
}
extension SBDownload: Equatable {}

class SBDownloads: NSObject, NSURLDownloadDelegate {
    var items = SBDownload[]()
	var _identifier = 0
    
    class func sharedDownloads() -> SBDownloads {
        return _sharedDownloads
    }
    
    var downloading: Bool {
        return items.any { $0.downloading }
    }
    
    // Actions
    
    func addItem(item: SBDownload) {
        items.append(item)
        item.identifier = self.createdIdentifier()
        // Update views
        self.executeDidAddItem(item)
    }
    
    func addItemWithURL(url: NSURL) {
        self.addItem(SBDownload(URL: url))
    }
    
    func removeItem(item: SBDownload) {
        self.removeItems([item])
    }
    
    func removeItems(inItems: SBDownload[]) {
        if let item = inItems.first({ $0.downloading }) {
            item.stop()
        }
        for item in inItems {
            if item.downloading {
                item.stop()
            }
        }
        // Update views
        self.executeWillRemoveItem(inItems)
        removeObjects(&items, inItems)
    }
    
    // Execute
    
    func executeDidAddItem(item: SBDownload) {
        let userInfo = [kSBDownloadsItem: item]
        NSNotificationCenter.defaultCenter().postNotificationName(SBDownloadsDidAddItemNotification, object: self, userInfo: userInfo)
    }
    
    func executeWillRemoveItem(items: SBDownload[]) {
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
    
    // NSURLDownload Delegate
    
    func downloadDidBegin(download: NSURLDownload) {
        var downloadItem = items.first { $0.download === download }
        if downloadItem == nil {
            downloadItem = SBDownload(download: download)
            self.addItem(downloadItem!)
        }
        // Update view
        downloadItem!.status = .Processing
        self.executeDidUpdateItem(downloadItem!)
    }
    
    func download(download: NSURLDownload, willSendRequest request: NSURLRequest, redirectResponse: NSURLResponse) -> NSURLRequest {
        if let item = items.first({ $0.download === download }) {
            // Update views
            self.executeDidUpdateItem(item)
        }
        return request
    }
    
    func download(download: NSURLDownload, didReceiveResponse response: NSURLResponse) {
        if let item = items.first({ $0.download === download }) {
            item.expectedLength = (Int(response.expectedContentLength) > 0) ? Int(response.expectedContentLength) : 0
            item.bytes = bytesString(item.receivedLength, item.expectedLength)
            // Update views
            self.executeDidUpdateItem(item)
        }
    }
    
    func download(download: NSURLDownload, decideDestinationWithSuggestedFilename filename: String) {
        if let item = items.first({ $0.download === download }) {
            item.path = SBPreferences.objectForKey(kSBSaveDownloadedFilesTo) as String
            if NSFileManager.defaultManager().fileExistsAtPath(item.path) {
                item.path = item.path?.stringByAppendingPathComponent(filename)
                item.download?.setDestination(item.path, allowOverwrite: false)
                // Update views
                self.executeDidUpdateItem(item)
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
            self.executeDidUpdateItem(item)
        }
    }
    
    func downloadDidFinish(download: NSURLDownload) {
        if let item = items.first({ $0.download === download }) {
            // Finish the item
            item.status = .Done
            item.downloading = false
            // Update views
            self.executeDidFinishItem(item)
        }
    }
    
    func download(download: NSURLDownload, didFailWithError error: NSError) {
        if let item = items.first({ $0.download === download }) {
            item.status = .Undone
            item.downloading = false
            item.receivedLength = 0
            item.expectedLength = 0
            // Update views
            self.executeDidUpdateItem(item)
        }
    }
    
    func download(download: NSURLDownload, shouldDecodeSourceDataOfMIMEType encodingType: String) -> Bool {
        return true
    }
    
    func download(download: NSURLDownload, didCreateDestination path: String!) {
        if let item = items.first({ $0.download === download }) {
            if path.lastPathComponent.utf16count > 0 {
                item.name = path.lastPathComponent
            }
            item.path = path
        }
    }
    
    // Function
    
    func createdIdentifier() -> Int {
        return _identifier++
    }
}