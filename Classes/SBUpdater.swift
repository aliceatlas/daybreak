/*
SBUpdater.swift

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

private var _sharedUpdater = SBUpdater()

class SBUpdater: NSObject {
    var raiseResult = false
    var checkSkipVersion = true
    
    class var sharedUpdater: SBUpdater {
        return _sharedUpdater
    }
    
    func check() {
        NSThread.detachNewThreadSelector("checking", toTarget: self, withObject: nil)
    }
    
    func checking() {
        let result = NSComparisonResult.OrderedSame;
        let appVersionString = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String
        let url = NSURL(string: SBVersionFileURL)!
        let request = NSURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: kSBTimeoutInterval)
        var response: NSURLResponse?
        var error: NSError?
        let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)
        let currentThread = NSThread.currentThread()
        let threadDictionary = currentThread.threadDictionary
        
        threadDictionary[kSBUpdaterResult] = result.rawValue
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "threadWillExit:", name: NSThreadWillExitNotification, object: currentThread)
        
        if (data !! appVersionString) != nil {
            // Success for networking
            // Parse data
            if let string = String(UTF8String: UnsafePointer<CChar>(data!.bytes))
                   where !string.isEmpty,
               let range0 = string.rangeOfString("version=\""),
                   range1 = string.rangeOfString("\";", range: range0.endIndex..<string.endIndex),
                   range2 = Optional(range0.endIndex..<range1.startIndex),
                   versionString = Optional(string[range2])
                   where !versionString.isEmpty {
                let comparisonResult = appVersionString!.compareAsVersionString(versionString)
                threadDictionary[kSBUpdaterResult] = comparisonResult.rawValue
                threadDictionary[kSBUpdaterVersionString] = versionString
            }
        } else {
            // Error
            threadDictionary[kSBUpdaterErrorDescription] = NSLocalizedString("Could not check for updates.", comment: "")
        }
    }
    
    func threadWillExit(notification: NSNotification) {
        let currentThread = notification.object as! NSThread
        let threadDictionary = currentThread.threadDictionary
        let userInfo = threadDictionary.copy() as! [NSObject: AnyObject]
        if let errorDescription = threadDictionary[kSBUpdaterErrorDescription] as? String {
            if let result = NSComparisonResult(rawValue: userInfo[kSBUpdaterResult] as! Int) {
                switch result {
                case .OrderedAscending:
                    var shouldSkip = false
                    if checkSkipVersion {
                        let versionString = userInfo[kSBUpdaterVersionString] as! String
                        let skipVersion = NSUserDefaults.standardUserDefaults().stringForKey(kSBUpdaterSkipVersion)
                        shouldSkip = versionString == skipVersion
                    }
                    if !shouldSkip {
                        SBDispatch { self.postShouldUpdateNotification(userInfo) }
                    }
                case .OrderedSame:
                    if raiseResult {
                        SBDispatch { self.postNotNeedUpdateNotification(userInfo) }
                    }
                case .OrderedDescending:
                    if raiseResult {
                        // Error
                        threadDictionary[kSBUpdaterErrorDescription] = NSLocalizedString("Invalid version number.", comment: "")
                        SBDispatch { self.postDidFailCheckingNotification(userInfo) }
                    }
                }
            }
        } else if raiseResult {
            SBDispatch { self.postDidFailCheckingNotification(userInfo) }
        }
    }
    
    func postShouldUpdateNotification(userInfo: NSDictionary) {
        NSNotificationCenter.defaultCenter().postNotificationName(SBUpdaterShouldUpdateNotification, object: self, userInfo: userInfo as [NSObject: AnyObject])
    }
    
    func postNotNeedUpdateNotification(userInfo: NSDictionary) {
        NSNotificationCenter.defaultCenter().postNotificationName(SBUpdaterNotNeedUpdateNotification, object: self, userInfo: userInfo as [NSObject: AnyObject])
    }
    
    func postDidFailCheckingNotification(userInfo: NSDictionary) {
        NSNotificationCenter.defaultCenter().postNotificationName(SBUpdaterDidFailCheckingNotification, object: self, userInfo: userInfo as [NSObject: AnyObject])
    }
}