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

// Versions
extern NSString *SBBookmarkVersion;

// Identifiers
extern NSString *kSBWebPreferencesIdentifier;

// Path components
extern NSString *kSBApplicationSupportDirectoryName;
extern NSString *kSBApplicationSupportDirectoryName_Version1;
extern NSString *kSBBookmarksFileName;
extern NSString *kSBHistoryFileName;

// Default values
extern const NSStringEncoding SBAvailableStringEncodings[];

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

// Button shapes
typedef NS_ENUM(NSInteger, SBButtonShape) {
	SBButtonShapeExclusive,
	SBButtonShapeLeft,
	SBButtonShapeCenter,
	SBButtonShapeRight
};

// Bookmark display modes
typedef NS_ENUM(NSInteger, SBBookmarkMode) {
	SBBookmarkModeIcon,
	SBBookmarkModeList,
	SBBookmarkModeTile
};

// Values
#define kSBTabbarItemClosableInterval 0.2
#define kSBBookmarkToolsInterval 0.7

// Sizes
#define kSBTabbarItemMaximumWidth 200.0
#define kSBTabbarItemMinimumWidth 100.0
#define kSBBookmarkFactorForImageWidth 4.0
#define kSBBookmarkFactorForImageHeight 3.0
#define kSBBookmarkCellPaddingPercentage 0.1
#define kSBBookmarkCellMaxWidth 256 * (1.0 + (kSBBookmarkCellPaddingPercentage * 2))

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