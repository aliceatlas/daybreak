import Foundation

private var _sharedPreferences = SBPreferences()

class SBPreferences: NSObject {
    class var sharedPreferences: SBPreferences {
        return _sharedPreferences;
    }
    
    func registerDefaults() {
        let defaults = NSUserDefaults.standardUserDefaults()
        var info: [String: AnyObject] = [:]
        
        // Common
        info[kSBSidebarWidth] = NSNumber(float: Float(kSBDefaultSidebarWidth))
        info[kSBSidebarPosition] = SBSidebarPosition.Right.rawValue as NSNumber
        info[kSBSidebarVisibilityFlag] = true as NSNumber
        info[kSBTabbarVisibilityFlag] = true as NSNumber
        info[kSBBookmarkCellWidth] = kSBDefaultBookmarkCellWidth as NSNumber
        info[kSBBookmarkMode] = SBBookmarkMode.Icon.rawValue as NSNumber
        info[kSBUserAgentName] = SBUserAgentNames[0]
        // General
        info[kSBOpenNewWindowsWithHomePage] = true as NSNumber
        info[kSBOpenNewTabsWithHomePage] = true as NSNumber
        if let homepage = SBDefaultHomePage() {
            info[kSBHomePage] = homepage
        }
        if let downloadsPath = SBDefaultSaveDownloadedFilesToPath() {
            info[kSBSaveDownloadedFilesTo] = downloadsPath
        }
        info[kSBOpenURLFromApplications] = "in the current tab"
        info[kSBQuitWhenTheLastWindowIsClosed] = true as NSNumber
        info[kSBConfirmBeforeClosingMultipleTabs] = true as NSNumber
        info[kSBCheckTheNewVersionAfterLaunching] = true as NSNumber
        info[kSBClearsAllCachesAfterLaunching] = true as NSNumber
        // Appearance
        //	kSBAllowsAnimatedImageToLoop
        //	kSBAllowsAnimatedImages
        //	kSBLoadsImagesAutomatically
        //	kSBDefaultEncoding
        //	kSBIncludeBackgroundsWhenPrinting
        // Bookmarks
        info[kSBShowBookmarksWhenWindowOpens] = true as NSNumber
        info[kSBShowAlertWhenRemovingBookmark] = true as NSNumber
        info[kSBUpdatesImageWhenAccessingBookmarkURL] = true as NSNumber
        // Security
        //	kSBEnablePlugIns
        //	kSBEnableJava
        //	kSBEnableJavaScript
        //	kSBBlockPopUpWindows
        info[kSBURLFieldShowsIDNAsASCII] = false as NSNumber
        info[kSBAcceptCookies] = "Only visited sites"
        // History
        info[kSBHistorySaveDays] = SBDefaultHistorySaveSeconds as NSNumber
        // Advanced
        // WebKitDeveloper
        info[kWebKitDeveloperExtras] = true as NSNumber
        info[kSBWhenNewTabOpensMakeActiveFlag] = true as NSNumber
        defaults.registerDefaults(info)
    }
    
    func homepage(isInWindow: Bool) -> String? {
        if let homepage = SBPreferences.objectForKey(kSBHomePage) as? NSString {
            if isInWindow {
                if SBPreferences.boolForKey(kSBOpenNewWindowsWithHomePage) {
                    return homepage
                }
            } else {
                if SBPreferences.boolForKey(kSBOpenNewTabsWithHomePage) {
                    return homepage
                }
            }
        }
        return nil
    }
    
    class func boolForKey(keyName: String) -> Bool {
        return (objectForKey(keyName) as NSNumber).boolValue
    }
    
    class func objectForKey(keyName: String) -> AnyObject? {
        let preferences = SBGetWebPreferences()
        switch keyName {
        case kSBAllowsAnimatedImageToLoop:
            return NSNumber(bool: preferences.allowsAnimatedImageLooping)
        case kSBAllowsAnimatedImages:
            return NSNumber(bool: preferences.allowsAnimatedImages)
        case kSBLoadsImagesAutomatically:
            return NSNumber(bool: preferences.loadsImagesAutomatically)
        case kSBDefaultEncoding:
            return preferences.defaultTextEncodingName
        case kSBIncludeBackgroundsWhenPrinting:
            return NSNumber(bool: preferences.shouldPrintBackgrounds)
        case kSBEnablePlugIns:
            return NSNumber(bool: preferences.plugInsEnabled)
        case kSBEnableJava:
            return NSNumber(bool: preferences.javaEnabled)
        case kSBEnableJavaScript:
            return NSNumber(bool: preferences.javaScriptEnabled)
        case kSBBlockPopUpWindows:
            return NSNumber(bool: !preferences.javaScriptCanOpenWindowsAutomatically)
        default:
            return NSUserDefaults.standardUserDefaults().objectForKey(keyName)
        }
    }
    
    class func setBool(value: Bool, forKey keyName: String) {
        setObject(NSNumber(bool: value), forKey: keyName)
    }
    
    class func setObject(object: AnyObject, forKey keyName: String) {
        let preferences = SBGetWebPreferences()
        switch keyName {
        case kSBAllowsAnimatedImageToLoop:
            preferences.allowsAnimatedImageLooping = object.boolValue
        case kSBAllowsAnimatedImages:
            preferences.allowsAnimatedImages = object.boolValue
        case kSBLoadsImagesAutomatically:
            preferences.loadsImagesAutomatically = object.boolValue
        case kSBDefaultEncoding:
            preferences.defaultTextEncodingName = object as NSString
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