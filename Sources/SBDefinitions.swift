/*
SBDefinitionsS.swift

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

#if __debug__
let DebugLog = NSLog
#else
func DebugLog(format: String, args: AnyObject...) {}
#endif

// Flags for Debug
let kSBFlagCreateTabItemWhenLaunched = true
let kSBFlagShowRenderWindow = false
let kSBCountOfDebugBookmarks = 0 // If more than 0, the bookmarks creates bookmark items for the count.
let kSBURLFieldShowsGoogleSuggest = true
let kSBFlagShowAllStringEncodings = false

let SBDownloadsDidAddItemNotification = "SBDownloadsDidAddItemNotification"
let SBDownloadsWillRemoveItemNotification = "SBDownloadsWillRemoveItemNotification"
let SBDownloadsDidUpdateItemNotification = "SBDownloadsDidUpdateItemNotification"
let SBDownloadsDidFinishItemNotification = "SBDownloadsDidFinishItemNotification"
let SBDownloadsDidFailItemNotification = "SBDownloadsDidFailItemNotification"

// Versions
let SBBookmarkVersion = "1.0"
let SBVersionFileURL = "http://www.sunrisebrowser.com/script.js"

// Identifiers
let kSBDocumentToolbarIdentifier = "Document"
let kSBToolbarURLFieldItemIdentifier = "URLField"
let kSBToolbarLoadItemIdentifier = "Load"
let kSBToolbarBookmarksItemIdentifier = "Bookmarks"
let kSBToolbarBookmarkItemIdentifier = "Bookmark"
let kSBToolbarHistoryItemIdentifier = "History"
let kSBToolbarSnapshotItemIdentifier = "Snapshot"
let kSBToolbarTextEncodingItemIdentifier = "TextEncoding"
let kSBToolbarMediaVolumeItemIdentifier = "MediaVolume"
let kSBToolbarHomeItemIdentifier = "Home"
let kSBToolbarBugsItemIdentifier = "Bugs"
let kSBToolbarUserAgentItemIdentifier = "UserAgent"
let kSBToolbarZoomItemIdentifier = "Zoom"
let kSBToolbarSourceItemIdentifier = "Source"
let kSBWebPreferencesIdentifier = "Daybreak"

// Document type names
let kSBDocumentTypeName = "HTML document"
let kSBStringsDocumentTypeName = "Strings document"

// URLs
let kSBUpdaterNewVersionURL = "http://www.sunrisebrowser.com/Sunrise%@.dmg"
let kSBGoogleSuggestURL = "https://www.google.com/complete/search?output=toolbar&q=%@"

// Mail Addresses
let kSBFeedbackMailAddress = "feedback@sunrisebrowser.com"
let kSBBugReportMailAddress = "bugreport@sunrisebrowser.com"

// Path components
let kSBApplicationSupportDirectoryName = "Daybreak"
let kSBApplicationSupportDirectoryName_Version1 = "Sunrise"
let kSBBookmarksFileName = "Bookmarks.plist"
let kSBHistoryFileName = "History.plist"
let kSBLocalizationsDirectoryName = "Localizations"

// Default values
let kSBDefaultEncodingName = "utf-8"
let SBDefaultHistorySaveSeconds = 604800


// Bookmark display modes
@objc enum SBBookmarkMode: Int {
    case Icon, List, Tile
}

let SBAvailableStringEncodings: [NSStringEncoding?] = [
    CFStringEncodings.ShiftJIS,                    // Japanese (Shift JIS)
    CFStringEncodings.ISO_2022_JP,                 // Japanese (ISO 2022-JP)
    CFStringEncodings.EUC_JP,                      // Japanese (EUC)
    CFStringEncodings.ShiftJIS_X0213,              // Japanese (Shift JIS X0213)
    nil,
    CFStringBuiltInEncodings.UTF8,                 // Unicode (UTF-8)
    nil,
    CFStringBuiltInEncodings.ISOLatin1,            // Western (ISO Latin 1)
    CFStringBuiltInEncodings.MacRoman,             // Western (Mac OS Roman)
    nil,
    CFStringEncodings.Big5,                        // Traditional Chinese (Big 5)
    CFStringEncodings.Big5_HKSCS_1999,             // Traditional Chinese (Big 5 HKSCS)
    CFStringEncodings.DOSChineseTrad,              // Traditional Chinese (Windows, DOS)
    nil,
    CFStringEncodings.ISO_2022_KR,                 // Korean (ISO 2022-KR)
    CFStringEncodings.MacKorean,                   // Korean (Mac OS)
    CFStringEncodings.DOSKorean,                   // Korean (Windows, DOS)
    nil,
    CFStringEncodings.ISOLatinArabic,              // Arabic (ISO 8859-6)
    CFStringEncodings.WindowsArabic,               // Arabic (Windows)
    nil,
    CFStringEncodings.ISOLatinHebrew,              // Hebrew (ISO 8859-8)
    CFStringEncodings.WindowsHebrew,               // Hebrew (Windows)
    nil,
    CFStringEncodings.ISOLatinGreek,               // Greek (ISO 8859-7)
    CFStringEncodings.WindowsGreek,                // Greek (Windows)
    nil,
    CFStringEncodings.ISOLatinCyrillic,            // Cyrillic (ISO 8859-5)
    CFStringEncodings.MacCyrillic,                 // Cyrillic (Mac OS)
    CFStringEncodings.KOI8_R,                      // Cyrillic (KOI8-R)
    CFStringEncodings.WindowsCyrillic,             // Cyrillic (Windows)
    CFStringEncodings.KOI8_U,                      // Ukrainian (KOI8-U)
    nil,
    CFStringEncodings.DOSThai,                     // Thai (Windows, DOS)
    nil,
    CFStringEncodings.GB_2312_80,                  // Simplified Chinese (GB 2312)
    CFStringEncodings.HZ_GB_2312,                  // Simplified Chinese (HZ GB 2312)
    CFStringEncodings.GB_18030_2000,               // Chinese (GB 18030)
    nil,
    CFStringEncodings.ISOLatin2,                   // Central European (ISO Latin 2)
    CFStringEncodings.MacCentralEurRoman,          // Central European (Mac OS)
    CFStringEncodings.WindowsLatin2,               // Central European (Windows Latin 2)
    nil,
    CFStringEncodings.WindowsVietnamese,           // Vietnamese (Windows)
    nil,
    CFStringEncodings.ISOLatin5,                   // Turkish (ISO Latin 5)
    CFStringEncodings.WindowsLatin5,               // Turkish (Windows Latin 5)
    nil,
    CFStringEncodings.ISOLatin4,                   // Central European (ISO Latin 4)
    CFStringEncodings.WindowsBalticRim             // Baltic (Windows)
].map {
    (inEnc: Any?) in
    var cfEnc: CFStringEncoding?
    if let enc = inEnc as? CFStringEncodings {
        cfEnc = CFStringEncoding(enc.rawValue)
    } else if let enc = inEnc as? CFStringBuiltInEncodings {
        cfEnc = enc.rawValue
    }
    return cfEnc !! { NSStringEncoding(CFStringConvertEncodingToNSStringEncoding($0)) }
}

// UserDefault keys
let kSBDocumentWindowAutosaveName = "Document"                             // String
let kSBSidebarPosition = "SidebarPosition"                                 // Integer
let kSBSidebarWidth = "SidebarWidth"                                       // Float
let kSBSidebarVisibilityFlag = "SidebarVisibilityFlag"                     // Bool
let kSBTabbarVisibilityFlag = "TabbarVisibilityFlag"                       // Int
let kSBBookmarkCellWidth = "BookmarkCellWidth"                             // Int
let kSBBookmarkMode = "BookmarkMode"                                       // String
let kSBUpdaterSkipVersion = "SkipVersion"                                  // Bool
let kSBFindCaseFlag = "FindCaseFlag"                                       // Bool
let kSBFindWrapFlag = "FindWrapFlag"                                       // Bool
let kSBSnapshotOnlyVisiblePortion = "SnapshotOnlyVisiblePortion"           // Int
let kSBSnapshotFileType = "SnapshotFileType"                               // Int
let kSBSnapshotTIFFCompression = "SnapshotTIFFCompression"                 // Float
let kSBSnapshotJPGFactor = "SnapshotJPGFactor"                             // String
let kSBUserAgentName = "UserAgent"                                         // String
let kSBOpenApplicationBundleIdentifier = "OpenApplicationBundleIdentifier" // String
// General
let kSBOpenNewWindowsWithHomePage = "OpenNewWindowsWithHomePage"             // Bool
let kSBOpenNewTabsWithHomePage = "OpenNewTabsWithHomePage"                   // Bool
let kSBHomePage = "HomePage"                                                 // String (URL)
let kSBSaveDownloadedFilesTo = "SaveDownloadedFilesTo"                       // String (Path)
let kSBOpenURLFromApplications = "OpenURLFromApplications"                   // String (SBOpenMethod)
let kSBQuitWhenTheLastWindowIsClosed = "QuitWhenTheLastWindowIsClosed"       // Bool
let kSBConfirmBeforeClosingMultipleTabs = "ConfirmBeforeClosingMultipleTabs" // Bool
let kSBCheckTheNewVersionAfterLaunching = "CheckTheNewVersionAfterLaunching" // Bool
let kSBClearsAllCachesAfterLaunching = "ClearsAllCachesAfterLaunching"       // Bool
// Appearance
let kSBAllowsAnimatedImageToLoop = "AllowsAnimatedImageToLoop"           // Bool
let kSBAllowsAnimatedImages = "AllowsAnimatedImages"                     // Bool
let kSBLoadsImagesAutomatically = "LoadsImagesAutomatically"             // Bool
let kSBDefaultEncoding = "DefaultEncoding"                               // String (iana name)
let kSBIncludeBackgroundsWhenPrinting = "IncludeBackgroundsWhenPrinting" // Bool
// Bookmarks
let kSBShowBookmarksWhenWindowOpens = "ShowBookmarksWhenWindowOpens"                 // Bool
let kSBShowAlertWhenRemovingBookmark = "ShowAlertWhenRemovingBookmark"               // Bool
let kSBUpdatesImageWhenAccessingBookmarkURL = "UpdatesImageWhenAccessingBookmarkURL" // Bool
// Security
let kSBEnablePlugIns = "EnablePlugIns"                     // Bool
let kSBEnableJava = "EnableJava"                           // Bool
let kSBEnableJavaScript = "EnableJavaScript"               // Bool
let kSBBlockPopUpWindows = "BlockPopUpWindows"             // Bool
let kSBURLFieldShowsIDNAsASCII = "URLFieldShowsIDNAsASCII" // Bool
let kSBAcceptCookies = "AcceptCookies"                     // String (SBCookieMethod)
// History
let kSBHistorySaveDays = "HistorySaveDays" // Double (seconds)
// Advanced
// WebKitDeveloper
let kWebKitDeveloperExtras = "WebKitDeveloperExtras"               // Bool
let kSBWhenNewTabOpensMakeActiveFlag = "WhenNewTabOpensMakeActive" // Bool

// Method values
let SBOpenMethods = [
    "in a new window",
    "in a new tab",
    "in the current tab"
]
let SBCookieMethods = [
    "Always",
    "Never",
    "Only visited sites"
]

// Key names
let kSBTitle = "title"
let kSBURL = "url"
let kSBDate = "date"
let kSBImage = "image"
let kSBType = "type"

// Bookmark Key names
let kSBBookmarkVersion = "Version"
let kSBBookmarkItems = "Items"
let kSBBookmarkTitle = "title"              // String
let kSBBookmarkURL = "url"                  // String
let kSBBookmarkImage = "image"              // Data
let kSBBookmarkDate = "date"                // Data
let kSBBookmarkLabelName = "label"          // String
let kSBBookmarkOffset = "offset"            // Point
let kSBBookmarkIsDirectory = "isDirectory"  // Bool

// Button shapes
enum SBButtonShape {
    case Exclusive, Left, Center, Right
}

// Updater key names
let kSBUpdaterResult = "Result"                     // Int (NSComparisonResult)
let kSBUpdaterVersionString = "VersionString"       // String
let kSBUpdaterErrorDescription = "ErrorDescription" // String

// Pasteboard type
let SBTabbarItemPboardType = "SBTabbarItemPboardType"
let SBSafariBookmarkDictionaryListPboardType = "BookmarkDictionaryListPboardType"

// Window
let SBWindowBackColor = NSColor(calibratedRed: 0.2, green: 0.22, blue: 0.24, alpha: 1.0)

// Bookmark color names
let SBBackgroundColor = NSColor(calibratedRed: 0.2, green: 0.22, blue: 0.24, alpha: 1.0)
let SBBackgroundLightGrayColor = NSColor(calibratedRed: 0.86, green: 0.87, blue: 0.88, alpha: 1.0)
let SBBookmarkLabelColorNames = [
    "None",
    "Red",
    "Orange",
    "Yellow",
    "Green",
    "Blue",
    "Purple",
    "Magenta",
    "Gray",
    "Black"
]

let SBBookmarkLabelColorRGB: [String: (CGFloat, CGFloat, CGFloat, CGFloat)] = [
    "None": (0.0, 0.0, 0.0, 0.0),
    "Red": (255.0, 120.0, 111.0, 255.0),
    "Orange": (250.0, 183.0, 90.0, 255.0),
    "Yellow": (244.0, 227.0, 107.0, 255.0),
    "Green": (193.0, 223.0, 101.0, 255.0),
    "Blue": (112.0, 182.0, 255.0, 255.0),
    "Purple": (208.0, 166.0, 225.0, 255.0),
    "Magenta": (246.0, 173.0, 228.0, 255.0),
    "Gray": (148.0, 148.0, 148.0, 255.0),
    "Black": (50.0, 50.0, 50.0, 255.00)
]

// Bottombar
var SBBottombarColors = [NSColor(deviceRed: 0.17, green: 0.19, blue: 0.22, alpha: 1.0),
                         NSColor(deviceRed: 0.27, green: 0.3, blue: 0.33, alpha: 1.0)]

// WebResourcesView
let SBTableCellColor = NSColor(calibratedRed: 0.29, green: 0.31, blue: 0.33, alpha: 1.0)
let SBTableGrayCellColor = NSColor(calibratedRed: 0.64, green: 0.67, blue: 0.7, alpha: 1.0)
let SBTableLightGrayCellColor = NSColor(calibratedRed: 0.86, green: 0.87, blue: 0.88, alpha: 1.0)
let SBTableDarkGrayCellColor = NSColor(calibratedRed: 0.48, green: 0.5, blue: 0.52, alpha: 1.0)
let SBSidebarSelectedCellColor = NSColor(calibratedRed: 0.49, green: 0.51, blue: 0.53, alpha: 1.0)
let SBSidebarTextColor = NSColor(calibratedRed: 0.66, green: 0.67, blue: 0.68, alpha: 1.0)

// User agent names
let SBUserAgentNames = [
    "Daybreak",
    "Safari",
    "Other"
]

// Web schemes
let SBSchemes = [
    "http://",
    "https://",
    "file://"
    //"feed://"
]

// Tags
let SBApplicationMenuTag = 0
let SBFileMenuTag = 1
let SBEditMenuTag = 2
let SBViewMenuTag = 3
let SBHistoryMenuTag = 4
let SBBookmarksMenuTag = 5
let SBWindowMenuTag = 6
let SBHelpMenuTag = 7

// Values
let kSBTimeoutInterval = 60.0
let kSBTabbarItemClosableInterval = 0.2
let kSBBookmarkItemImageCompressionFactor = 0.1
let kSBBookmarkLayoutInterval = 0.7
let kSBBookmarkToolsInterval = 0.7
let kSBDownloadsToolsInterval = 0.7

// Sizes
let kSBDocumentWindowMinimumSizeWidth: CGFloat = 400.0
let kSBDocumentWindowMinimumSizeHeight: CGFloat = 300.0
let kSBTabbarHeight: CGFloat = 24.0
let kSBTabbarItemMaximumWidth: CGFloat = 200.0
let kSBTabbarItemMinimumWidth: CGFloat = 100.0
let kSBBottombarHeight: CGFloat = 24.0
let kSBSidebarResizableWidth: CGFloat = 24.0
let kSBSidebarNewFolderButtonWidth: CGFloat = 100.0
let kSBSidebarClosedWidth: CGFloat = 1.0
let kSBSidebarMinimumWidth: CGFloat = 144.0
let kSBDownloadItemSize: CGFloat = 128.0
let kSBDefaultSidebarWidth: CGFloat = 550
let kSBDefaultBookmarkCellWidth: Int = 168
let kSBBookmarkFactorForImageWidth: CGFloat = 4.0
let kSBBookmarkFactorForImageHeight: CGFloat = 3.0
let kSBBookmarkCellPaddingPercentage: CGFloat = 0.1
let kSBBookmarkCellMinWidth: Double = 60
let kSBBookmarkCellMaxWidth = Double(256 * (1.0 + (kSBBookmarkCellPaddingPercentage * 2)))
let SBFieldRoundedCurve: CGFloat = 4

// Counts
let kSBDocumentWarningNumberOfBookmarksForOpening = 15

// Notification names
let SBBookmarksDidUpdateNotification = "SBBookmarksDidUpdateNotification"
let SBUpdaterShouldUpdateNotification = "SBUpdaterShouldUpdateNotification"
let SBUpdaterNotNeedUpdateNotification = "SBUpdaterNotNeedUpdateNotification"
let SBUpdaterDidFailCheckingNotification = "SBUpdaterDidFailCheckingNotification"

// Notification key names
let kSBDownloadsItem = "Item"
let kSBDownloadsItems = "Items"

// Pasteboard type names
let SBBookmarkPboardType = "SBBookmarkPboardType"

@objc protocol SBAnswersIsFirstResponder {
    var isFirstResponder: Bool { get }
}