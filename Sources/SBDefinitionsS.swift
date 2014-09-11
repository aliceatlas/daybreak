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
let DebugLogS = NSLog
#else
func DebugLogS(format: String, args: AnyObject...) {}
#endif

let SBDownloadsDidAddItemNotification = "SBDownloadsDidAddItemNotification"
let SBDownloadsWillRemoveItemNotification = "SBDownloadsWillRemoveItemNotification"
let SBDownloadsDidUpdateItemNotification = "SBDownloadsDidUpdateItemNotification"
let SBDownloadsDidFinishItemNotification = "SBDownloadsDidFinishItemNotification"
let SBDownloadsDidFailItemNotification = "SBDownloadsDidFailItemNotification"

/*
// Versions
NSString *SBBookmarkVersion = @"1.0";
NSString *SBVersionFileURL = @"http://www.sunrisebrowser.com/script.js";

// Identifiers
NSString *kSBDocumentToolbarIdentifier = @"Document";
NSString *kSBToolbarURLFieldItemIdentifier = @"URLField";
NSString *kSBToolbarLoadItemIdentifier = @"Load";
NSString *kSBToolbarBookmarksItemIdentifier = @"Bookmarks";
NSString *kSBToolbarBookmarkItemIdentifier = @"Bookmark";
NSString *kSBToolbarHistoryItemIdentifier = @"History";
NSString *kSBToolbarSnapshotItemIdentifier = @"Snapshot";
NSString *kSBToolbarTextEncodingItemIdentifier = @"TextEncoding";
NSString *kSBToolbarMediaVolumeItemIdentifier = @"MediaVolume";
NSString *kSBToolbarHomeItemIdentifier = @"Home";
NSString *kSBToolbarBugsItemIdentifier = @"Bugs";
NSString *kSBToolbarUserAgentItemIdentifier = @"UserAgent";
NSString *kSBToolbarZoomItemIdentifier = @"Zoom";
NSString *kSBToolbarSourceItemIdentifier = @"Source";
NSString *kSBWebPreferencesIdentifier = @"Sunrise";

// Document type names
NSString *kSBDocumentTypeName = @"HTML Document Type";
NSString *kSBStringsDocumentTypeName = @"Strings Document Type";

// URLs
NSString *kSBUpdaterNewVersionURL = @"http://www.sunrisebrowser.com/Sunrise%@.dmg";
NSString *kSBGoogleSuggestURL = @"http://google.com/complete/search?output=toolbar&q=%@";

// Mail Addresses
NSString *kSBFeedbackMailAddress = @"feedback@sunrisebrowser.com";
NSString *kSBBugReportMailAddress = @"bugreport@sunrisebrowser.com";

// Path components
NSString *kSBApplicationSupportDirectoryName = @"Sunrise3";
NSString *kSBApplicationSupportDirectoryName_Version1 = @"Sunrise";
NSString *kSBBookmarksFileName = @"Bookmarks.plist";
NSString *kSBHistoryFileName = @"History.plist";
NSString *kSBLocalizationsDirectoryName = @"Localizations";

// Default values
*/
let kSBDefaultEncodingName = "utf-8"
/*const NSStringEncoding SBAvailableStringEncodings[] = {
	-2147481087,	// Japanese (Shift JIS)
	21,				// Japanese (ISO 2022-JP)
	3,				// Japanese (EUC)
	-2147482072,	// Japanese (Shift JIS X0213)
	NSNotFound,	
	4,				// Unicode (UTF-8)
	NSNotFound,	
	5,				// Western (ISO Latin 1)
	30,				// Western (Mac OS Roman)
	NSNotFound,	
	-2147481085,	// Traditional Chinese (Big 5)
	-2147481082,	// Traditional Chinese (Big 5 HKSCS)
	-2147482589,	// Traditional Chinese (Windows, DOS)
	NSNotFound,	
	-2147481536,	// Korean (ISO 2022-KR)
	-2147483645,	// Korean (Mac OS)
	-2147482590,	// Korean (Windows, DOS)
	NSNotFound,	
	-2147483130,	// Arabic (ISO 8859-6)
	-2147482362,	// Arabic (Windows)
	NSNotFound,	
	-2147483128,	// Hebrew (ISO 8859-8)
	-2147482363,	// Hebrew (Windows)
	NSNotFound, 
	-2147483129,	// Greek (ISO 8859-7)
	13,				// Greek (Windows)
	NSNotFound, 
	-2147483131,	// Cyrillic (ISO 8859-5)
	-2147483641,	// Cyrillic (Mac OS)
	-2147481086,	// Cyrillic (KOI8-R)
	11,				// Cyrillic (Windows)
	-2147481080,	// Ukrainian (KOI8-U)
	NSNotFound,	
	-2147482595,	// Thai (Windows, DOS)
	NSNotFound,	
	-2147481296,	// Simplified Chinese (GB 2312)
	-2147481083,	// Simplified Chinese (HZ GB 2312)
	-2147482062,	// Chinese (GB 18030)
	NSNotFound, 
	9,				// Central European (ISO Latin 2)
	-2147483619,	// Central European (Mac OS)
	15,				// Central European (Windows Latin 2)
	NSNotFound, 
	-2147482360,	// Vietnamese (Windows)
	NSNotFound, 
	-2147483127,	// Turkish (ISO Latin 5)
	14,				// Turkish (Windows Latin 5)
	NSNotFound, 
	-2147483132,	// Central European (ISO Latin 4)
	-2147482361,	// Baltic (Windows)
	0
};

// UserDefault keys
NSString *kSBDocumentWindowAutosaveName = @"Document";
NSString *kSBSidebarPosition = @"SidebarPosition";
NSString *kSBSidebarWidth = @"SidebarWidth";
NSString *kSBSidebarVisibilityFlag = @"SidebarVisibilityFlag";
NSString *kSBTabbarVisibilityFlag = @"TabbarVisibilityFlag";
NSString *kSBBookmarkCellWidth = @"BookmarkCellWidth";
NSString *kSBBookmarkMode = @"BookmarkMode";
NSString *kSBUpdaterSkipVersion = @"SkipVersion";
NSString *kSBFindCaseFlag = @"FindCaseFlag";
NSString *kSBFindWrapFlag = @"FindWrapFlag";
NSString *kSBSnapshotOnlyVisiblePortion = @"SnapshotOnlyVisiblePortion";
NSString *kSBSnapshotFileType = @"SnapshotFileType";
NSString *kSBSnapshotTIFFCompression = @"SnapshotTIFFCompression";
NSString *kSBSnapshotJPGFactor = @"SnapshotJPGFactor";
NSString *kSBUserAgentName = @"UserAgent";
NSString *kSBOpenApplicationBundleIdentifier = @"OpenApplicationBundleIdentifier";
// General
NSString *kSBOpenNewWindowsWithHomePage = @"OpenNewWindowsWithHomePage";
NSString *kSBOpenNewTabsWithHomePage = @"OpenNewTabsWithHomePage";
NSString *kSBHomePage = @"HomePage";
NSString *kSBSaveDownloadedFilesTo = @"SaveDownloadedFilesTo";
NSString *kSBOpenURLFromApplications = @"OpenURLFromApplications";
NSString *kSBQuitWhenTheLastWindowIsClosed = @"QuitWhenTheLastWindowIsClosed";
NSString *kSBConfirmBeforeClosingMultipleTabs = @"ConfirmBeforeClosingMultipleTabs";
NSString *kSBCheckTheNewVersionAfterLaunching = @"CheckTheNewVersionAfterLaunching";
NSString *kSBClearsAllCachesAfterLaunching = @"ClearsAllCachesAfterLaunching";
// Appearance
NSString *kSBAllowsAnimatedImageToLoop = @"AllowsAnimatedImageToLoop";
NSString *kSBAllowsAnimatedImages = @"AllowsAnimatedImages";
NSString *kSBLoadsImagesAutomatically = @"LoadsImagesAutomatically";
NSString *kSBDefaultEncoding = @"DefaultEncoding";
NSString *kSBIncludeBackgroundsWhenPrinting = @"IncludeBackgroundsWhenPrinting";
// Bookmarks
NSString *kSBShowBookmarksWhenWindowOpens = @"ShowBookmarksWhenWindowOpens";
NSString *kSBShowAlertWhenRemovingBookmark = @"ShowAlertWhenRemovingBookmark";
NSString *kSBUpdatesImageWhenAccessingBookmarkURL = @"UpdatesImageWhenAccessingBookmarkURL";
// Security
NSString *kSBEnablePlugIns = @"EnablePlugIns";
NSString *kSBEnableJava = @"EnableJava";
NSString *kSBEnableJavaScript = @"EnableJavaScript";
NSString *kSBBlockPopUpWindows = @"BlockPopUpWindows";
NSString *kSBURLFieldShowsIDNAsASCII = @"URLFieldShowsIDNAsASCII";
NSString *kSBAcceptCookies = @"AcceptCookies";
// History
NSString *kSBHistorySaveDays = @"HistorySaveDays";
// Advanced
// WebKitDeveloper
NSString *kWebKitDeveloperExtras = @"WebKitDeveloperExtras";
NSString *kSBWhenNewTabOpensMakeActiveFlag = @"WhenNewTabOpensMakeActive";
*/

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

/*
// Key names
NSString *kSBTitle = @"title";
NSString *kSBURL = @"url";
NSString *kSBDate = @"date";
NSString *kSBImage = @"image";
NSString *kSBType = @"type";

// Bookmark Key names
NSString *kSBBookmarkVersion = @"Version";
NSString *kSBBookmarkItems = @"Items";
NSString *kSBBookmarkTitle = @"title";
NSString *kSBBookmarkURL = @"url";
NSString *kSBBookmarkImage = @"image";
NSString *kSBBookmarkDate = @"date";
NSString *kSBBookmarkLabelName = @"label";
NSString *kSBBookmarkOffset = @"offset";
NSString *kSBBookmarkIsDirectory = @"isDirectory";

// Updater key names
NSString *kSBUpdaterResult = @"Result";
NSString *kSBUpdaterVersionString = @"VersionString";
NSString *kSBUpdaterErrorDescription = @"ErrorDescription";

// Pasteboard type
NSString *SBTabbarItemPboardType = @"SBTabbarItemPboardType";
NSString *SBSafariBookmarkDictionaryListPboardType = @"BookmarkDictionaryListPboardType";
*/

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
    "Sunrise",
    "Safari",
    "Other"
]

// Web schemes
let SBCountOfSchemes = 3
let SBSchemes = [
    "http://",
    "https://",
    "file://",
    "feed://"
]

/*
// Tags
#define SBApplicationMenuTag 0
#define SBFileMenuTag 1
#define SBEditMenuTag 2
#define SBViewMenuTag 3
#define SBHistoryMenuTag 4
#define SBBookmarksMenuTag 5
#define SBWindowMenuTag 6
#define SBHelpMenuTag 7

// Values
#define kSBTimeoutInterval 60.0
#define kSBTabbarItemClosableInterval 0.2
#define kSBBookmarkItemImageCompressionFactor 0.1
#define kSBBookmarkLayoutInterval 0.7
#define kSBBookmarkToolsInterval 0.7
#define kSBDownloadsToolsInterval 0.7
*/

// Sizes
let kSBDocumentWindowMinimumSizeWidth: CGFloat = 400.0
let kSBDocumentWindowMinimumSizeHeight: CGFloat = 300.0
let kSBTabbarHeight: CGFloat = 24.0
/*
#define kSBTabbarItemMaximumWidth 200.0
#define kSBTabbarItemMinimumWidth 100.0
*/
let kSBBottombarHeight: CGFloat = 24.0
let kSBSidebarResizableWidth: CGFloat = 24.0
let kSBSidebarNewFolderButtonWidth: CGFloat = 100.0
let kSBSidebarClosedWidth: CGFloat = 1.0
let kSBSidebarMinimumWidth: CGFloat = 144.0
let kSBDownloadItemSize: CGFloat = 128.0
let kSBDefaultSidebarWidth: CGFloat = 550
/*
#define kSBDefaultBookmarkCellWidth 168
#define kSBBookmarkFactorForImageWidth 4.0
#define kSBBookmarkFactorForImageHeight 3.0
*/
let kSBBookmarkCellPaddingPercentage: CGFloat = 0.1
let kSBBookmarkCellMinWidth: Double = 60
let kSBBookmarkCellMaxWidth = Double(256 * (1.0 + (kSBBookmarkCellPaddingPercentage * 2)))
let SBFieldRoundedCurve: CGFloat = 4

/*
// Counts
#define kSBDocumentWarningNumberOfBookmarksForOpening 15

// Notification names
NSString *SBBookmarksDidUpdateNotification = @"SBBookmarksDidUpdateNotification";
NSString *SBUpdaterShouldUpdateNotification = @"SBUpdaterShouldUpdateNotification";
NSString *SBUpdaterNotNeedUpdateNotification = @"SBUpdaterNotNeedUpdateNotification";
NSString *SBUpdaterDidFailCheckingNotification = @"SBUpdaterDidFailCheckingNotification";

// Notification key names
NSString *kSBDownloadsItem = @"Item";
NSString *kSBDownloadsItems = @"Items";

// Pasteboard type names
NSString *SBBookmarkPboardType = @"SBBookmarkPboardType";
*/

@objc
protocol SBAnswersIsFirstResponder {
    var isFirstResponder: Bool { get }
}