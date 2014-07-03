//
//  SBDownloader.swift
//  Sunrise
//
//  Created by Alice Atlas on 7/1/14.
//
//

import Foundation

class SBDownloader: NSObject {
    var url: NSURL
    var delegate: SBDownloaderDelegate?
    var connection: NSURLConnection?
    var receivedData: NSMutableData?
    
    init(URL url: NSURL) {
        self.url = url
    }
    
    class func downloadWithURL(url: NSURL) -> SBDownloader {
        return SBDownloader(URL: url)
    }
    
    // Delegate
    
    func connection(connection: NSURLConnection, willCacheResponse cachedResponse: NSCachedURLResponse) -> NSCachedURLResponse? {
        return nil
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        var statusCode = 0
        if let resp = response as? NSHTTPURLResponse {
            statusCode = resp.statusCode
        }
        if statusCode != 200 {
            self.executeDidFail(nil)
            self.cancel()
        }
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        if receivedData == nil {
            receivedData = data.mutableCopy() as NSMutableData
        } else {
            receivedData!.appendData(data)
        }
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        if receivedData?.length > 0 {
            self.executeDidFinish()
        } else {
            self.executeDidFail(nil)
        }
        self.destructConnection()
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        self.executeDidFail(error)
        self.destructConnection()
    }
    
    // Execute
    
    func executeDidFinish() {
        delegate?.downloader(self, didFinish: receivedData!.copy() as NSData) // ???(!)
    }
    
    func executeDidFail(error: NSError?) {
        delegate?.downloader?(self, didFail: error)
    }
    
    // Actions
    
    func destructConnection() {
        connection = nil
    }
    
    func destructReceivedData() {
        receivedData = nil
    }
    
    func start() {
        self.destructReceivedData()
        if url != nil {
            let request = NSURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: kSBTimeoutInterval)
            self.destructConnection()
            connection = NSURLConnection(request: request, delegate: self)
        }
    }
    
    func cancel() {
        self.connection?.cancel()
    }
}
