/*

SBDefinitions.m
 
Authoring by Atsushi Jike

Copyright 2010 Atsushi Jike. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer 
in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "SBDefinitions.h"

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
NSString *kSBApplicationSupportDirectoryName = @"Sunrise2";
NSString *kSBApplicationSupportDirectoryName_Version1 = @"Sunrise";
NSString *kSBBookmarksFileName = @"Bookmarks.plist";
NSString *kSBHistoryFileName = @"History.plist";
NSString *kSBLocalizationsDirectoryName = @"Localizations";

// Default values
NSString *kSBDefaultEncodingName = @"utf-8";
const NSStringEncoding SBAvailableStringEncodings[] = {
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

// Method values
NSInteger SBCountOfOpenMethods = 3;
NSString *SBOpenMethods[] = {
@"in a new window", 
@"in a new tab", 
@"in the current tab"
};
NSInteger SBCountOfCookieMethods = 3;
NSString *SBCookieMethods[] = {
@"Always", 
@"Never", 
@"Only visited sites"
};

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

// Window
CGFloat SBWindowBackColors[4] = {0.2, 0.22, 0.24, 1.0};

// Bookmark color names
CGFloat SBBackgroundColors[4] = {0.2, 0.22, 0.24, 1.0};
CGFloat SBBackgroundLightGrayColors[4] = {0.86, 0.87, 0.88, 1.0};
NSInteger SBBookmarkCountOfLabelColors = 10;
NSString *SBBookmarkLabelColorNames[] = {
@"None",
@"Red",
@"Orange",
@"Yellow",
@"Green",
@"Blue",
@"Purple",
@"Magenta",
@"Gray",
@"Black"
};
CGFloat SBBookmarkLabelColorRGBA[] = {
0.0, 0.0, 0.0, 0.0, // None
255.0 / 255.0, 120.0 / 255.0, 111.0 / 255.0, 1.0, // Red
250.0 / 255.0, 183.0 / 255.0,  90.0 / 255.0, 1.0, // Orange
244.0 / 255.0, 227.0 / 255.0, 107.0 / 255.0, 1.0, // Yellow
193.0 / 255.0, 223.0 / 255.0, 101.0 / 255.0, 1.0, // Green
112.0 / 255.0, 182.0 / 255.0, 255.0 / 255.0, 1.0, // Blue
208.0 / 255.0, 166.0 / 255.0, 225.0 / 255.0, 1.0, // Purple
246.0 / 255.0, 173.0 / 255.0, 228.0 / 255.0, 1.0, // Magenta
148.0 / 255.0, 148.0 / 255.0, 148.0 / 255.0, 1.0, // Gray
50.0 / 255.0, 50.0 / 255.0, 50.0 / 255.0, 1.0  // Black
};

// Bottombar
CGFloat SBBottombarColors[8] = {0.17, 0.19, 0.22, 1.0, 0.27, 0.3, 0.33, 1.0};

// WebResourcesView
CGFloat SBTableCellColors[4] = {0.29, 0.31, 0.33, 1.0};
CGFloat SBTableGrayCellColors[4] = {0.64, 0.67, 0.7, 1.0};
CGFloat SBTableLightGrayCellColors[4] = {0.86, 0.87, 0.88, 1.0};
CGFloat SBTableDarkGrayCellColors[4] = {0.48, 0.5, 0.52, 1.0};
CGFloat SBSidebarSelectedCellColors[4] = {0.49, 0.51, 0.53, 1.0};
CGFloat SBSidebarTextColors[4] = {0.66, 0.67, 0.68, 1.0};

// User agent names
NSInteger SBCountOfUserAgentNames = 3;
NSString *SBUserAgentNames[] = {
@"Sunrise", 
@"Safari", 
@"Other"
};

// Web schemes
NSInteger SBCountOfSchemes = 3;
NSString *SBSchemes[] = {
@"http://", 
@"https://", 
@"file://", 
@"feed://"
};

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