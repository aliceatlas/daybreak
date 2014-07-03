//
//  SBUpdater.swift
//  Sunrise
//
//  Created by Alice Atlas on 7/2/14.
//
//

import Foundation

var _sharedUpdater = SBUpdater()

class SBUpdater: NSObject {
    var raiseResult = false
    var checkSkipVersion = true
    
    class func sharedUpdater() -> SBUpdater {
        return _sharedUpdater
    }
    
    func check() {
        NSThread.detachNewThreadSelector("checking", toTarget: self, withObject: nil)
    }
    
    func checking() {
        let result = NSComparisonResult.OrderedSame;
        let appVersionString = NSBundle.mainBundle().infoDictionary["CFBundleVersion"] as? NSString
        let url = NSURL(string: SBVersionFileURL)
        let request = NSURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: kSBTimeoutInterval)
        var response: NSURLResponse?
        var error: NSError?
        let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)
        let currentThread = NSThread.currentThread()
        let threadDictionary = currentThread.threadDictionary
        
        threadDictionary[kSBUpdaterResult] = result.toRaw()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "threadWillExit:", name: NSThreadWillExitNotification, object: currentThread)
        
        if data != nil && appVersionString != nil {
            // Success for networking
            // Parse data
            let string = NSString(data: data, encoding: NSUTF8StringEncoding)
            if string.length > 0 {
                let range0 = string.rangeOfString("version=\"")
                if range0.location != NSNotFound {
                    let range1 = string.rangeOfString("\";", options: NSStringCompareOptions(0), range: NSMakeRange(NSMaxRange(range0), string.length - NSMaxRange(range0)))
                    if range1.location != NSNotFound {
                        let range2 = NSMakeRange(NSMaxRange(range0), range1.location - NSMaxRange(range0))
                        let versionString = string.substringWithRange(range2)
                        if versionString.utf16count > 0 {
                            let comparisonResult = appVersionString!.compareAsVersionString(versionString)
                            threadDictionary[kSBUpdaterResult] = comparisonResult.toRaw()
                            threadDictionary[kSBUpdaterVersionString] = versionString
                        }
                    }
                }
            }
        } else {
            // Error
            threadDictionary[kSBUpdaterErrorDescription] = NSLocalizedString("Could not check for updates.", comment: "")
        }
    }
    
    func threadWillExit(notification: NSNotification) {
        let currentThread = notification.object as NSThread
        let threadDictionary = currentThread.threadDictionary
        let userInfo = threadDictionary.copy() as NSDictionary
        if let errorDescription = threadDictionary[kSBUpdaterErrorDescription] as? String {
            if let result = NSComparisonResult.fromRaw(userInfo[kSBUpdaterResult] as Int) {
                switch result {
                case .OrderedAscending:
                    var shouldSkip = false
                    if checkSkipVersion {
                        let versionString = userInfo[kSBUpdaterVersionString] as String
                        let skipVersion = NSUserDefaults.standardUserDefaults().objectForKey(kSBUpdaterSkipVersion) as String
                        shouldSkip = versionString == skipVersion
                    }
                    if !shouldSkip {
                        NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: "postShouldUpdateNotification:", userInfo: userInfo, repeats: false)
                    }
                case .OrderedSame:
                    if raiseResult {
                        NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: "postNotNeedUpdateNotification:", userInfo: userInfo, repeats: false)
                    }
                case .OrderedDescending:
                    if raiseResult {
                        // Error
                        threadDictionary[kSBUpdaterErrorDescription] = NSLocalizedString("Invalid version number.", comment: "")
                        NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: "postDidFailCheckingNotification:", userInfo: threadDictionary.copy(), repeats: false)
                    }
                }
            }
        } else if raiseResult {
            NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: "postDidFailCheckingNotification:", userInfo: userInfo, repeats: false)
        }
    }
    
    func postShouldUpdateNotification(userInfo: NSDictionary) {
        NSNotificationCenter.defaultCenter().postNotificationName(SBUpdaterShouldUpdateNotification, object: self, userInfo: userInfo)
    }
    
    func postNotNeedUpdateNotification(userInfo: NSDictionary) {
        NSNotificationCenter.defaultCenter().postNotificationName(SBUpdaterNotNeedUpdateNotification, object: self, userInfo: userInfo)
    }
    
    func postDidFailCheckingNotification(userInfo: NSDictionary) {
        NSNotificationCenter.defaultCenter().postNotificationName(SBUpdaterDidFailCheckingNotification, object: self, userInfo: userInfo)
    }
}