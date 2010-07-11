/*

SBUtil.h
 
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
#import <WebKit/WebKit.h>
#import "SBApplicationDelegate.h"
#import "SBDocument.h"
#import "SBDocumentController.h"
#import "SBFixedSplitView.h"

// Get objects
SBApplicationDelegate *SBGetApplicationDelegate();
SBDocumentController *SBGetDocumentController();
SBDocument *SBGetSelectedDocument();
WebPreferences *SBGetWebPreferences();
NSMenu *SBMenuWithTag(NSInteger tag);
NSMenuItem *SBMenuItemWithTag(NSInteger tag);
// Default values
NSRect SBDefaultDocumentWindowRect();
NSString *SBDefaultHomePage();
NSString *SBDefaultSaveDownloadedFilesToPath();
NSDictionary *SBDefaultBookmarks();
NSData *SBEmptyBookmarkImageData();
// Bookmarks
NSDictionary *SBBookmarksWithItems(NSArray *items);
NSDictionary *SBCreateBookmarkItem(NSString *title, NSString *url, NSData *imageData, NSDate *date, NSString *labelName, NSString *offsetString);
NSMenu *SBBookmarkLabelColorMenu(BOOL pullsDown, id target, SEL action, id representedObject);
NSArray *SBBookmarkItemsFromBookmarkDictionaryList(NSArray *bookmarkDictionaryList);
// Rects
NSSize SBBookmarkImageMaxSize();
// File paths
NSString *SBFilePathInApplicationBundle(NSString *name, NSString *ext);
NSString *SBApplicationSupportDirectory(NSString *subdirectory);
NSString *SBLibraryDirectory(NSString *subdirectory);
NSString *SBSearchFileInDirectory(NSString *filename, NSString *directoryPath);
NSString *SBSearchPath(NSSearchPathDirectory searchPathDirectory, NSString *subdirectory);
NSString *SBBookmarksFilePath();
NSString *SBBookmarksVersion1FilePath();
NSString *SBHistoryFilePath();
// Paths
CGPathRef SBRoundedPath(CGRect rect, CGFloat curve, CGFloat inner, BOOL top, BOOL bottom);
CGPathRef SBLeftButtonPath(CGSize size);
CGPathRef SBCenterButtonPath(CGSize size);
CGPathRef SBRightButtonPath(CGSize size);
CGPathRef SBTrianglePath(CGRect rect, NSInteger direction);
CGPathRef SBEllipsePath3D(CGRect r, CATransform3D transform);
CGPathRef SBRoundedPath3D(CGRect rect, CGFloat curve, CATransform3D transform);
void SBCGPointApplyTransform3D(CGPoint *p, const CATransform3D *t);
// Drawing
void SBDrawGradientInContext(CGContextRef ctx, NSUInteger count, CGFloat locations[], CGFloat colors[], CGPoint points[]);
void SBDrawRadialGradientInContext(CGContextRef ctx, NSUInteger count, CGFloat locations[], CGFloat colors[], CGPoint centers[], CGFloat radiuses[]);
void SBGetAlternateSelectedLightControlColorComponents(CGFloat colors[4]);
void SBGetAlternateSelectedControlColorComponents(CGFloat colors[4]);
void SBGetAlternateSelectedDarkControlColorComponents(CGFloat colors[4]);
// Image
CGImageRef SBBackwardIconImage(CGSize size, BOOL enabled, BOOL backing);
CGImageRef SBForwardIconImage(CGSize size, BOOL enabled, BOOL backing);
CGImageRef SBGoIconImage(CGSize size, BOOL enabled, BOOL backing);
CGImageRef SBZoomOutIconImage(CGSize size);
CGImageRef SBActualSizeIconImage(CGSize size);
CGImageRef SBZoomInIconImage(CGSize size);
CGImageRef SBAddIconImage(CGSize size, BOOL backing);
CGImageRef SBCloseIconImage();
CGImageRef SBIconImageWithName(NSString *imageName, SBButtonShape shape, CGSize size);
CGImageRef SBIconImage(CGImageRef iconImage, SBButtonShape shape, CGSize size);
CGImageRef SBFindBackwardIconImage(CGSize size, BOOL enabled);
CGImageRef SBFindForwardIconImage(CGSize size, BOOL enabled);
CGImageRef SBBookmarkReflectionMaskImage(CGSize size);
// Math
NSInteger SBRemainder(NSInteger value1, NSInteger value2);
BOOL SBRemainderIsZero(NSInteger value1, NSInteger value2);
NSInteger SBGreatestCommonDivisor(NSInteger a, NSInteger b);
// Others
NSMenu *SBEncodingMenu(id target, SEL selector, BOOL showDefault);
NSComparisonResult SBStringEncodingSortFunction(id num1, id num2, void *context);
NSInteger SBUnsignedIntegerSortFunction(id num1, id num2, void *context);
void SBRunAlertWithMessage(NSString *message);
void SBDisembedViewInSplitView(NSView *view, NSSplitView *splitView);
CGFloat SBDistancePoints(NSPoint p1, NSPoint p2);
BOOL SBAllowsDrag(NSPoint downPoint, NSPoint dragPoint);
void SBLocalizeTitlesInMenu(NSMenu *menu);
void SBGetLocalizableTextSet(NSString *path, NSMutableArray **tSet, NSArray **fSet, NSSize *viewSize);
NSData *SBLocalizableStringsData(NSArray *fieldSet);
// Debug
id SBValueForKey(NSString *keyName, NSDictionary *dictionary);
NSDictionary *SBDebugViewStructure(NSView *view);
NSDictionary *SBDebugLayerStructure(CALayer *layer);
NSDictionary *SBDebugDumpMainMenu();
NSArray *SBDebugDumpMenu(NSMenu *menu);
BOOL SBDebugWriteViewStructure(NSView *view, NSString *path);
BOOL SBDebugWriteLayerStructure(CALayer *layer, NSString *path);
BOOL SBDebugWriteMainMenu(NSString *path);