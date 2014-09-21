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

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import <WebKit/WebKit.h>

// Flags for Debug
#define kSBFlagCreateTabItemWhenLaunched 1
#define kSBURLFieldShowsGoogleSuggest 1
#define kSBFlagShowAllStringEncodings 0

#define SBDownloadsDidAddItemNotification @"SBDownloadsDidAddItemNotification"
#define SBDownloadsWillRemoveItemNotification @"SBDownloadsWillRemoveItemNotification"
#define SBDownloadsDidUpdateItemNotification @"SBDownloadsDidUpdateItemNotification"
#define SBDownloadsDidFinishItemNotification @"SBDownloadsDidFinishItemNotification"
#define SBDownloadsDidFailItemNotification @"SBDownloadsDidFailItemNotification"

// Versions
extern NSString *SBBookmarkVersion;

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

// URLs
extern NSString *kSBGoogleSuggestURL;

// Path components
extern NSString *kSBApplicationSupportDirectoryName;
extern NSString *kSBApplicationSupportDirectoryName_Version1;
extern NSString *kSBBookmarksFileName;
extern NSString *kSBHistoryFileName;

// Default values
extern const NSStringEncoding SBAvailableStringEncodings[];

// UserDefault keys
extern NSString *kSBDocumentWindowAutosaveName;			// String
extern NSString *kSBSidebarPosition;					// Integer
extern NSString *kSBSidebarWidth;						// Float
extern NSString *kSBTabbarVisibilityFlag;				// BOOL
extern NSString *kSBBookmarkMode;						// Integer
// General
extern NSString *kSBHomePage;							// String (URL)
// Advanced
// WebKitDeveloper
extern NSString *kWebKitDeveloperExtras;			// BOOL

// Key names
extern NSString *kSBTitle;
extern NSString *kSBURL;
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

// Pasteboard type
extern NSString *SBSafariBookmarkDictionaryListPboardType;

// Bookmark color names
extern NSInteger SBBookmarkCountOfLabelColors;
extern NSString *SBBookmarkLabelColorNames[];

// Type definitions for an URL field completion list item
typedef NS_ENUM(NSInteger, SBURLFieldItemType) {
	SBURLFieldItemTypeNone = 0,
	SBURLFieldItemTypeBookmark = 1,
	SBURLFieldItemTypeHistory = 2,
	SBURLFieldItemTypeGoogleSuggest = 3
};

// Button shapes
typedef NS_ENUM(NSInteger, SBButtonShape) {
	SBButtonShapeExclusive,
	SBButtonShapeLeft,
	SBButtonShapeCenter,
	SBButtonShapeRight
};

// Sidebar positions
typedef NS_ENUM(NSInteger, SBSidebarPosition) {
	SBSidebarPositionLeft,
	SBSidebarPositionRight
};

// Bookmark display modes
typedef NS_ENUM(NSInteger, SBBookmarkMode) {
	SBBookmarkModeIcon,
	SBBookmarkModeList,
	SBBookmarkModeTile
};

// Status code
typedef NS_ENUM(NSInteger, SBStatus) {
	SBStatusUndone,
	SBStatusProcessing,
	SBStatusDone
};

// Tags
#define SBViewMenuTag 3

// Values
#define kSBTabbarItemClosableInterval 0.2
#define kSBBookmarkToolsInterval 0.7

// Sizes
#define kSBTabbarItemMaximumWidth 200.0
#define kSBTabbarItemMinimumWidth 100.0
#define kSBBottombarHeight 24.0
#define kSBSidebarMinimumWidth 144.0
#define kSBDownloadItemSize 128.0
#define kSBBookmarkFactorForImageWidth 4.0
#define kSBBookmarkFactorForImageHeight 3.0
#define kSBBookmarkCellPaddingPercentage 0.1
#define kSBBookmarkCellMaxWidth 256 * (1.0 + (kSBBookmarkCellPaddingPercentage * 2))

// Counts
#define kSBDocumentWarningNumberOfBookmarksForOpening 15

// Notification names
extern NSString *SBBookmarksDidUpdateNotification;

// Notification key names
extern NSString *kSBDownloadsItem;
extern NSString *kSBDownloadsItems;

// Pasteboard type names
extern NSString *SBBookmarkPboardType;

// Un-documented methods
@interface NSURL (WebNSURLExtras)
+ (NSURL *)_web_URLWithUserTypedString:(NSString *)string;
- (NSString *)_web_userVisibleString;
@end

@interface WebInspector: NSObject
- (void)show:(id)sender;
- (void)showConsole:(id)sender;
@end

@class DOMRange;
typedef NSUInteger WebFindOptions;
@interface WebView (WebPendingPublic)
@property (readonly) BOOL canZoomPageIn;
@property (readonly) BOOL canZoomPageOut;
@property (readonly) BOOL canResetPageZoom;
@property (readonly) WebInspector *inspector;

- (NSUInteger)markAllMatchesForText:(NSString *)string caseSensitive:(BOOL)caseFlag highlight:(BOOL)highlight limit:(NSUInteger)limit;
- (NSUInteger)countMatchesForText:(NSString *)string options:(WebFindOptions)options highlight:(BOOL)highlight limit:(NSUInteger)limit markMatches:(BOOL)markMatches;
- (NSUInteger)countMatchesForText:(NSString *)string inDOMRange:(DOMRange *)range options:(WebFindOptions)options highlight:(BOOL)highlight limit:(NSUInteger)limit markMatches:(BOOL)markMatches;
- (void)unmarkAllTextMatches;
- (IBAction)zoomPageIn:(id)sender;
- (IBAction)zoomPageOut:(id)sender;
- (IBAction)resetPageZoom:(id)sender;
// WebInspector
- (void)show:(id)arg1;
- (void)showConsole:(id)arg1;
@end