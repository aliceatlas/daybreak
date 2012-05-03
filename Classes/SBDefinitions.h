/*

SBDefinitions.h
 
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

#ifdef __debug__
#define DebugLog(format, ...)  NSLog(format, __VA_ARGS__)
#else
#define DebugLog(format, ...)
#endif

#define kSBFlagIsSnowLepard NSAppKitVersionNumber >= 1038

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import <WebKit/WebKit.h>
#import "SBAdditions.h"

// Flags for Debug
#define kSBFlagCreateTabItemWhenLaunched 1
#define kSBFlagShowRenderWindow 0
#define kSBCountOfDebugBookmarks 0	/* If more than 0, the bookmarks creates bookmark items for the count. */
#define kSBURLFieldShowsGoogleSuggest 1
#define kSBFlagShowAllStringEncodings 0

// Versions
extern NSString *SBBookmarkVersion;
extern NSString *SBVersionFileURL;

// Identifiers
extern NSString *kSBDocumentToolbarIdentifier;
extern NSString *kSBToolbarURLFieldItemIdentifier;
extern NSString *kSBToolbarLoadItemIdentifier;
extern NSString *kSBToolbarBookmarksItemIdentifier;
extern NSString *kSBToolbarBookmarkItemIdentifier;
extern NSString *kSBToolbarHistoryItemIdentifier;
extern NSString *kSBToolbarSnapshotItemIdentifier;
extern NSString *kSBToolbarTextEncodingItemIdentifier;
extern NSString *kSBToolbarHomeItemIdentifier;
extern NSString *kSBToolbarBugsItemIdentifier;
extern NSString *kSBToolbarUserAgentItemIdentifier;
extern NSString *kSBToolbarZoomItemIdentifier;
extern NSString *kSBToolbarSourceItemIdentifier;
extern NSString *kSBWebPreferencesIdentifier;

// Document type names
extern NSString *kSBDocumentTypeName;
extern NSString *kSBStringsDocumentTypeName;

// URLs
extern NSString *kSBUpdaterNewVersionURL;
extern NSString *kSBGoogleSuggestURL;

// Mail Addresses
extern NSString *kSBFeedbackMailAddress;
extern NSString *kSBBugReportMailAddress;

// Path components
extern NSString *kSBApplicationSupportDirectoryName;
extern NSString *kSBApplicationSupportDirectoryName_Version1;
extern NSString *kSBBookmarksFileName;
extern NSString *kSBHistoryFileName;
extern NSString *kSBLocalizationsDirectoryName;

// Default values
extern NSString *kSBDefaultEncodingName;
#define SBDefaultHistorySaveSeconds 604800
extern const NSStringEncoding SBAvailableStringEncodings[];

// UserDefault keys
extern NSString *kSBDocumentWindowAutosaveName;			// String
extern NSString *kSBSidebarPosition;					// Integer
extern NSString *kSBSidebarWidth;						// Float
extern NSString *kSBSidebarVisibilityFlag;				// BOOL
extern NSString *kSBTabbarVisibilityFlag;				// BOOL
extern NSString *kSBBookmarkCellWidth;					// Integer
extern NSString *kSBBookmarkMode;						// Integer
extern NSString *kSBUpdaterSkipVersion;					// String
extern NSString *kSBFindCaseFlag;						// BOOL
extern NSString *kSBFindWrapFlag;						// BOOL
extern NSString *kSBSnapshotOnlyVisiblePortion;			// BOOL
extern NSString *kSBSnapshotFileType;					// Integer
extern NSString *kSBSnapshotTIFFCompression;			// Integer
extern NSString *kSBSnapshotJPGFactor;					// Float
extern NSString *kSBUserAgentName;						// String
extern NSString *kSBOpenApplicationBundleIdentifier;	// String
// General
extern NSString *kSBOpenNewWindowsWithHomePage;			// BOOL
extern NSString *kSBOpenNewTabsWithHomePage;			// BOOL
extern NSString *kSBHomePage;							// String (URL)
extern NSString *kSBSaveDownloadedFilesTo;				// String (Path)
extern NSString *kSBOpenURLFromApplications;			// String (SBOpenMethod)
extern NSString *kSBQuitWhenTheLastWindowIsClosed;		// BOOL
extern NSString *kSBConfirmBeforeClosingMultipleTabs;	// BOOL
extern NSString *kSBCheckTheNewVersionAfterLaunching;	// BOOL
extern NSString *kSBClearsAllCachesAfterLaunching;		// BOOL
// Appearance
extern NSString *kSBAllowsAnimatedImageToLoop;		// BOOL
extern NSString *kSBAllowsAnimatedImages;			// BOOL
extern NSString *kSBLoadsImagesAutomatically;		// BOOL
extern NSString *kSBDefaultEncoding;				// String (iana name)
extern NSString *kSBIncludeBackgroundsWhenPrinting;	// BOOL
// Bookmarks
extern NSString *kSBShowBookmarksWhenWindowOpens;			// BOOL
extern NSString *kSBShowAlertWhenRemovingBookmark;			// BOOL
extern NSString *kSBUpdatesImageWhenAccessingBookmarkURL;	// BOOL
// Security
extern NSString *kSBEnablePlugIns;			// BOOL
extern NSString *kSBEnableJava;				// BOOL
extern NSString *kSBEnableJavaScript;		// BOOL
extern NSString *kSBBlockPopUpWindows;		// BOOL
extern NSString *kSBURLFieldShowsIDNAsASCII;// BOOL
extern NSString *kSBAcceptCookies;			// String (SBCookieMethod)
// History
extern NSString *kSBHistorySaveDays;	// Double (seconds)
// Advanced
// WebKitDeveloper
extern NSString *kWebKitDeveloperExtras;			// BOOL
extern NSString *kSBWhenNewTabOpensMakeActiveFlag;	// BOOL

// Method values
extern NSInteger SBCountOfOpenMethods;
extern NSString *SBOpenMethods[];
extern NSInteger SBCountOfCookieMethods;
extern NSString *SBCookieMethods[];

// Key names
extern NSString *kSBTitle;
extern NSString *kSBURL;
extern NSString *kSBDate;
extern NSString *kSBImage;
extern NSString *kSBType;

// Bookmark Key names
extern NSString *kSBBookmarkVersion;
extern NSString *kSBBookmarkItems;
extern NSString *kSBBookmarkTitle;		// String
extern NSString *kSBBookmarkURL;		// String
extern NSString *kSBBookmarkImage;		// Data
extern NSString *kSBBookmarkDate;		// Date
extern NSString *kSBBookmarkLabelName;	// String
extern NSString *kSBBookmarkOffset;		// Point
extern NSString *kSBBookmarkIsDirectory;// BOOL

// Updater key names
extern NSString *kSBUpdaterResult;			// Integer (NSComparisonResult)
extern NSString *kSBUpdaterVersionString;	// String
extern NSString *kSBUpdaterErrorDescription;// String

// Pasteboard type
extern NSString *SBTabbarItemPboardType;
extern NSString *SBSafariBookmarkDictionaryListPboardType;

// Window
extern CGFloat SBWindowBackColors[4];

// Bookmark color names
extern CGFloat SBBackgroundColors[4];
extern CGFloat SBBackgroundLightGrayColors[4];
extern NSInteger SBBookmarkCountOfLabelColors;
extern NSString *SBBookmarkLabelColorNames[];
extern CGFloat SBBookmarkLabelColorRGBA[];

// Bottombar
extern CGFloat SBBottombarColors[8];

// WebResourcesView
extern CGFloat SBTableCellColors[4];
extern CGFloat SBTableGrayCellColors[4];
extern CGFloat SBTableLightGrayCellColors[4];
extern CGFloat SBTableDarkGrayCellColors[4];
extern CGFloat SBSidebarSelectedCellColors[4];
extern CGFloat SBSidebarTextColors[4];

// User agent names
extern NSInteger SBCountOfUserAgentNames;
extern NSString *SBUserAgentNames[];

// Web schemes
extern NSInteger SBCountOfSchemes;
extern NSString *SBSchemes[];

// Type definitions for an URL field completion list item
enum {
	kSBURLFieldItemNoneType = 0, 
	kSBURLFieldItemBookmarkType = 1, 
	kSBURLFieldItemHistoryType = 2, 
	kSBURLFieldItemGoogleSuggestType = 3
};

// Button shapes
typedef enum {
	SBButtonExclusiveShape, 
	SBButtonLeftShape, 
	SBButtonCenterShape, 
	SBButtonRightShape
}SBButtonShape;

// Sidebar positions
typedef enum {
	SBSidebarLeftPosition, 
	SBSidebarRightPosition
}SBSidebarPosition;

// Bookmark display modes
typedef enum {
	SBBookmarkIconMode, 
	SBBookmarkListMode, 
	SBBookmarkTileMode
}SBBookmarkMode;

// Circle progress styles
typedef enum {
	SBCircleProgressIndicatorRegulerStyle, 
	SBCircleProgressIndicatorWhiteStyle
}SBCircleProgressIndicatorStyle;

// Status code
typedef enum {
	SBStatusUndone, 
	SBStatusProcessing, 
	SBStatusDone
}SBStatus;

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

// Sizes
#define kSBDocumentWindowMinimumSizeWidth 400.0
#define kSBDocumentWindowMinimumSizeHeight 300.0
#define kSBTabbarHeight 24.0
#define kSBTabbarItemMaximumWidth 200.0
#define kSBTabbarItemMinimumWidth 100.0
#define kSBBottombarHeight 24.0
#define kSBSidebarResizableWidth 24.0
#define kSBSidebarNewFolderButtonWidth 100.0
#define kSBSidebarClosedWidth 1.0
#define kSBSidebarMinimumWidth 144.0
#define kSBDownloadItemSize 128.0
#define kSBDefaultSidebarWidth 550
#define kSBDefaultBookmarkCellWidth 168
#define kSBBookmarkFactorForImageWidth 4.0
#define kSBBookmarkFactorForImageHeight 3.0
#define kSBBookmarkCellPaddingPercentage 0.1
#define kSBBookmarkCellMinWidth 60
#define kSBBookmarkCellMaxWidth 256 * (1.0 + (kSBBookmarkCellPaddingPercentage * 2))
#define SBFieldRoundedCurve 4

// Counts
#define kSBDocumentWarningNumberOfBookmarksForOpening 15

// Notification names
extern NSString *SBBookmarksDidUpdateNotification;
extern NSString *SBUpdaterShouldUpdateNotification;
extern NSString *SBUpdaterNotNeedUpdateNotification;
extern NSString *SBUpdaterDidFailCheckingNotification;

// Notification key names
extern NSString *kSBDownloadsItem;
extern NSString *kSBDownloadsItems;

// Pasteboard type names
extern NSString *SBBookmarkPboardType;

// Delegates
@class SBDocumentWindow;
@protocol SBDocumentWindowDelegate <NSObject>
- (BOOL)window:(SBDocumentWindow *)aWindow shouldClose:(id)sender;
- (BOOL)window:(SBDocumentWindow *)aWindow shouldHandleKeyEvent:(NSEvent *)theEvent;
- (void)windowDidFinishFlipping:(SBDocumentWindow *)aWindow;
@end

@class SBTabbar;
@class SBTabbarItem;
@protocol SBTabbarDelegate <NSObject>
- (void)tabbar:(SBTabbar *)aTabbar didChangeSelection:(SBTabbarItem *)aTabbarItem;
- (void)tabbar:(SBTabbar *)aTabbar didReselection:(SBTabbarItem *)aTabbarItem;
- (void)tabbar:(SBTabbar *)aTabbar shouldAddNewItemForURLs:(NSArray *)urls;
- (void)tabbar:(SBTabbar *)aTabbar shouldOpenURLs:(NSArray *)urls startInItem:(SBTabbarItem *)aTabbarItem;
- (void)tabbar:(SBTabbar *)aTabbar shouldReload:(SBTabbarItem *)aTabbarItem;
- (void)tabbar:(SBTabbar *)aTabbar didRemoveItem:(NSString *)identifier;
@end

@class SBURLField;
@protocol SBURLFieldDelegate <NSObject>
@optional
- (void)urlFieldDidSelectBackward:(SBURLField *)aUrlField;
- (void)urlFieldDidSelectForward:(SBURLField *)aUrlField;
- (void)urlFieldShouldOpenURL:(SBURLField *)aUrlField;
- (void)urlFieldShouldOpenURLInNewTab:(SBURLField *)aUrlField;
- (void)urlFieldShouldDownloadURL:(SBURLField *)aUrlField;
- (void)urlFieldTextDidChange:(SBURLField *)aUrlField;
- (void)urlFieldWillResignFirstResponder:(SBURLField *)aUrlField;
@end
@protocol SBURLFieldDatasource <NSObject>
@end

@class SBTabView;
@class SBTabViewItem;
@class SBWebResourceIdentifier;
@protocol SBTabViewDelegate <NSObject>
- (void)tabView:(SBTabView *)aTabView selectedItemDidStartLoading:(SBTabViewItem *)aTabViewItem;
- (void)tabView:(SBTabView *)aTabView selectedItemDidFinishLoading:(SBTabViewItem *)aTabViewItem;
- (void)tabView:(SBTabView *)aTabView selectedItemDidFailLoading:(SBTabViewItem *)aTabViewItem;
- (void)tabView:(SBTabView *)aTabView selectedItemDidReceiveTitle:(SBTabViewItem *)aTabViewItem;
- (void)tabView:(SBTabView *)aTabView selectedItemDidReceiveIcon:(SBTabViewItem *)aTabViewItem;
- (void)tabView:(SBTabView *)aTabView selectedItemDidReceiveServerRedirect:(SBTabViewItem *)aTabViewItem;
- (void)tabView:(SBTabView *)aTabView shouldAddNewItemForURL:(NSURL *)url selection:(BOOL)selection;
- (void)tabView:(SBTabView *)aTabView shouldSearchString:(NSString *)string newTab:(BOOL)newTab;
- (BOOL)tabView:(SBTabView *)aTabView shouldConfirmWithMessage:(NSString *)message;
- (void)tabView:(SBTabView *)aTabView shouldShowMessage:(NSString *)message;
- (NSString *)tabView:(SBTabView *)aTabView shouldTextInput:(NSString *)prompt;
- (void)tabView:(SBTabView *)aTabView didAddResourceID:(SBWebResourceIdentifier *)resourceID;
- (void)tabView:(SBTabView *)aTabView didReceiveExpectedContentLengthOfResourceID:(SBWebResourceIdentifier *)resourceID;
- (void)tabView:(SBTabView *)aTabView didReceiveContentLengthOfResourceID:(SBWebResourceIdentifier *)resourceID;
- (void)tabView:(SBTabView *)aTabView didReceiveFinishLoadingOfResourceID:(SBWebResourceIdentifier *)resourceID;
- (void)tabView:(SBTabView *)aTabView didSelectTabViewItem:(SBTabViewItem *)aTabViewItem;
@end

@class SBSplitView;
@protocol SBSplitViewDelegate <NSSplitViewDelegate>
- (void)splitViewDidOpenDrawer:(SBSplitView *)aSplitView;
@end

@class SBBookmarksView;
@protocol SBBookmarksViewDelegate <NSObject>
@optional
- (void)bookmarksView:(SBBookmarksView *)aBookmarksView didChangeMode:(SBBookmarkMode)mode;
- (void)bookmarksView:(SBBookmarksView *)aBookmarksView shouldEditItemAtIndex:(NSUInteger)index;
- (void)bookmarksView:(SBBookmarksView *)aBookmarksView didChangeCellWidth:(CGFloat)cellWidth;
@end

@class SBDownloadsView;
@protocol SBDownloadsViewDelegate <NSObject>
@optional
- (void)downloadsViewDidRemoveAllItems:(SBDownloadsView *)aDownloadsView;
@end

@class SBRenderWindow;
@protocol SBRenderWindowDelegate <NSObject>
@optional
- (void)renderWindowDidStartRendering:(SBRenderWindow *)renderWindow;
- (void)renderWindow:(SBRenderWindow *)renderWindow didFinishRenderingImage:(NSImage *)image;
- (void)renderWindow:(SBRenderWindow *)renderWindow didFailWithError:(NSError *)error;
@end

@class SBDownloader;
@protocol SBDownloaderDelegate
- (void)downloader:(SBDownloader *)downloader didFinish:(NSData *)data;
@optional
- (void)downloader:(SBDownloader *)downloader didFail:(NSError *)error;
@end


// Un-documented methods
@interface NSURL (WebNSURLExtras)
+ (id)_web_URLWithUserTypedString:(id)sender;
- (id)_web_userVisibleString;
@end

@interface WebView (WebPendingPublic)
- (NSUInteger)markAllMatchesForText:(id)text caseSensitive:(BOOL)caseFlag highlight:(BOOL)highlightFlag limit:(NSUInteger)limit;
- (void)unmarkAllTextMatches;
- (BOOL)canZoomPageIn;
- (void)zoomPageIn:(id)sender;
- (BOOL)canZoomPageOut;
- (void)zoomPageOut:(id)sender;
- (BOOL)canResetPageZoom;
- (void)resetPageZoom:(id)sender;
- (id)inspector;
// WebInspector
- (void)show:(id)arg1;
- (void)showConsole:(id)arg1;
@end

// Methods for Snow Leopard 10.6
@interface NSEvent (SBSnowLeopardAddition)

- (CGFloat)magnification;

@end