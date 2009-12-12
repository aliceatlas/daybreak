/*

SBDefinitions.m
 
Authoring by Atsushi Jike

Copyright 2009 Atsushi Jike. All rights reserved.

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
NSString *kSBDefaultEncodingName = @"utf-16";

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

// Bookmark Key names
NSString *kSBBookmarkVersion = @"Version";
NSString *kSBBookmarkItems = @"Items";
NSString *kSBBookmarkTitle = @"title";
NSString *kSBBookmarkURL = @"url";
NSString *kSBBookmarkImage = @"image";
NSString *kSBBookmarkDate = @"date";
NSString *kSBBookmarkLabelName = @"label";
NSString *kSBBookmarkOffset = @"offset";

// Updater key names
NSString *kSBUpdaterResult = @"Result";
NSString *kSBUpdaterVersionString = @"VersionString";
NSString *kSBUpdaterErrorDescription = @"ErrorDescription";

// Pasteboard type
NSString *SBTabbarItemPboardType = @"SBTabbarItemPboardType";

// Bookmark color names
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
108.0 / 255.0, 108.0 / 255.0, 108.0 / 255.0, 1.0  // Black
};

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
@"file://"
};

// Notification names
NSString *SBBookmarksDidUpdateNotification = @"SBBookmarksDidUpdateNotification";
NSString *SBUpdaterShouldUpdateNotification = @"SBUpdaterShouldUpdateNotification";
NSString *SBUpdaterNotNeedUpdateNotification = @"SBUpdaterNotNeedUpdateNotification";
NSString *SBUpdaterDidFailCheckingNotification = @"SBUpdaterDidFailCheckingNotification";

// Notification key names
NSString *kSBDownloadsItem = @"Item";

// Pasteboard type names
NSString *SBBookmarkPboardType = @"SBBookmarkPboardType";