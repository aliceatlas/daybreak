import Foundation

private var _sharedPreferences = SBPreferences()

class SBPreferences: NSObject {
    class var sharedPreferences: SBPreferences {
        return _sharedPreferences
    }
    
    func registerDefaults() {
        let defaults = NSUserDefaults.standardUserDefaults()
        var info: [String: AnyObject] = [:]
        
        // Common
        info[kSBSidebarWidth] = Float(kSBDefaultSidebarWidth)
        info[kSBSidebarPosition] = SBSidebarPosition.Right.rawValue
        info[kSBSidebarVisibilityFlag] = true
        info[kSBTabbarVisibilityFlag] = true
        info[kSBBookmarkCellWidth] = kSBDefaultBookmarkCellWidth
        info[kSBBookmarkMode] = SBBookmarkMode.Icon.rawValue
        info[kSBUserAgentName] = SBUserAgentNames[0]
        // General
        info[kSBOpenNewWindowsWithHomePage] = true
        info[kSBOpenNewTabsWithHomePage] = true
        if let homepage = SBDefaultHomePage() {
            info[kSBHomePage] = homepage
        }
        if let downloadsPath = SBDefaultSaveDownloadedFilesToPath() {
            info[kSBSaveDownloadedFilesTo] = downloadsPath
        }
        info[kSBOpenURLFromApplications] = "in the current tab"
        info[kSBQuitWhenTheLastWindowIsClosed] = true
        info[kSBConfirmBeforeClosingMultipleTabs] = true
        info[kSBCheckTheNewVersionAfterLaunching] = true
        info[kSBClearsAllCachesAfterLaunching] = true
        // Appearance
        //	kSBAllowsAnimatedImageToLoop
        //	kSBAllowsAnimatedImages
        //	kSBLoadsImagesAutomatically
        //	kSBDefaultEncoding
        //	kSBIncludeBackgroundsWhenPrinting
        // Bookmarks
        info[kSBShowBookmarksWhenWindowOpens] = true
        info[kSBShowAlertWhenRemovingBookmark] = true
        info[kSBUpdatesImageWhenAccessingBookmarkURL] = true
        // Security
        //	kSBEnablePlugIns
        //	kSBEnableJava
        //	kSBEnableJavaScript
        //	kSBBlockPopUpWindows
        info[kSBURLFieldShowsIDNAsASCII] = false
        info[kSBAcceptCookies] = "Only visited sites"
        // History
        info[kSBHistorySaveDays] = SBDefaultHistorySaveSeconds
        // Advanced
        // WebKitDeveloper
        info[kWebKitDeveloperExtras] = true
        info[kSBWhenNewTabOpensMakeActiveFlag] = true
        defaults.registerDefaults(info)
    }
    
    func homepage(isInWindow: Bool) -> String? {
        if let homepage = SBPreferences.objectForKey(kSBHomePage) as? String {
            if SBPreferences.boolForKey(isInWindow ? kSBOpenNewWindowsWithHomePage : kSBOpenNewTabsWithHomePage) {
                return homepage
            }
        }
        return nil
    }
    
    class func boolForKey(keyName: String) -> Bool {
        return objectForKey(keyName) as Bool
    }
    
    class func objectForKey(keyName: String) -> AnyObject? {
        let preferences = SBGetWebPreferences
        switch keyName {
        case kSBAllowsAnimatedImageToLoop:
            return preferences.allowsAnimatedImageLooping
        case kSBAllowsAnimatedImages:
            return preferences.allowsAnimatedImages
        case kSBLoadsImagesAutomatically:
            return preferences.loadsImagesAutomatically
        case kSBDefaultEncoding:
            return preferences.defaultTextEncodingName
        case kSBIncludeBackgroundsWhenPrinting:
            return preferences.shouldPrintBackgrounds
        case kSBEnablePlugIns:
            return preferences.plugInsEnabled
        case kSBEnableJava:
            return preferences.javaEnabled
        case kSBEnableJavaScript:
            return preferences.javaScriptEnabled
        case kSBBlockPopUpWindows:
            return !preferences.javaScriptCanOpenWindowsAutomatically
        default:
            return NSUserDefaults.standardUserDefaults().objectForKey(keyName)
        }
    }
    
    class func setBool(value: Bool, forKey keyName: String) {
        setObject(NSNumber(bool: value), forKey: keyName)
    }
    
    class func setObject(object: AnyObject, forKey keyName: String) {
        let preferences = SBGetWebPreferences
        switch keyName {
        case kSBAllowsAnimatedImageToLoop:
            preferences.allowsAnimatedImageLooping = object.boolValue
        case kSBAllowsAnimatedImages:
            preferences.allowsAnimatedImages = object.boolValue
        case kSBLoadsImagesAutomatically:
            preferences.loadsImagesAutomatically = object.boolValue
        case kSBDefaultEncoding:
            preferences.defaultTextEncodingName = object as String
        case kSBIncludeBackgroundsWhenPrinting:
            preferences.shouldPrintBackgrounds = object.boolValue
        case kSBEnablePlugIns:
            preferences.plugInsEnabled = object.boolValue
        case kSBEnableJava:
            preferences.javaEnabled = object.boolValue
        case kSBEnableJavaScript:
            preferences.javaScriptEnabled = object.boolValue
        case kSBBlockPopUpWindows:
            preferences.javaScriptCanOpenWindowsAutomatically = !object.boolValue
        default:
            NSUserDefaults.standardUserDefaults().setObject(object, forKey: keyName)
        }
    }
}