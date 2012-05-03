/*

SBDocument.h
 
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
#import "SBBookmarksView.h"
#import "SBButton.h"
#import "SBPopUpButton.h"
#import "SBDocumentWindow.h"
#import "SBSplitView.h"
#import "SBToolbar.h"
#import "SBWebResourcesView.h"

@class SBBookmarkView;
@class SBDocumentWindow;
@class SBDownloaderView;
@class SBDownloadsView;
@class SBEditBookmarkView;
@class SBHistoryView;
@class SBLoadButton;
@class SBMessageView;
@class SBTextInputView;
@class SBPopUpButton;
@class SBReportView;
@class SBSegmentedButton;
@class SBSidebar;
@class SBSnapshotView;
@class SBTabbar;
@class SBTabView;
@class SBTabbarItem;
@class SBTabViewItem;
@class SBUserAgentView;
@class SBURLField;
@class SBWebView;
@protocol SBSplitViewDelegate;
@protocol SBTabbarDelegate;
@interface SBDocument : NSDocument <SBTabbarDelegate, SBURLFieldDatasource, SBURLFieldDelegate, SBSplitViewDelegate, SBTabViewDelegate, SBWebResourcesViewDataSource, SBWebResourcesViewDelegate, SBToolbarDelegate, SBSplitViewDelegate>
{
	SBDocumentWindow *window;
	NSWindowController *windowController;
	SBToolbar *toolbar;
	NSView *urlView;
	SBURLField *urlField;
	NSView *loadView;
	NSView *encodingView;
	NSView *zoomView;
	SBLoadButton *loadButton;
	SBPopUpButton *encodingButton;
	SBSegmentedButton *zoomButton;
	SBTabbar *tabbar;
	SBSplitView *splitView;
	SBTabView *tabView;
	SBSidebar *sidebar;
	SBBookmarkView *bookmarkView;
	SBEditBookmarkView *editBookmarkView;
	SBDownloaderView *downloaderView;
	SBSnapshotView *snapshotView;
	SBReportView *reportView;
	SBUserAgentView *userAgentView;
	SBHistoryView *historyView;
	SBMessageView *messageView;
	SBTextInputView *textInputView;
	NSURL *initialURL;
	BOOL sidebarVisibility;
	NSUInteger _identifier;
	NSInteger confirmed;
}
@property (nonatomic, assign) SBDocumentWindow *window;
@property (nonatomic, assign) NSWindowController *windowController;
@property (nonatomic, retain) NSToolbar *toolbar;
@property (nonatomic, retain) SBURLField *urlField;
@property (nonatomic, retain) SBTabbar *tabbar;
@property (nonatomic, retain) SBSplitView *splitView;
@property (nonatomic, retain) NSURL *initialURL;
@property (nonatomic) BOOL sidebarVisibility;
@property (nonatomic, readonly) SBTabViewItem *selectedTabViewItem;
@property (nonatomic, readonly) SBWebView *selectedWebView;
@property (nonatomic, readonly) id selectedWebDocumentView;
@property (nonatomic, readonly) WebDataSource *selectedWebDataSource;
@property (nonatomic, readonly) NSImage *selectedWebViewImageForBookmark;
@property (nonatomic, readonly) NSData *selectedWebViewImageDataForBookmark;
@property (nonatomic, readonly) SBWebResourcesView *resourcesView;

// Getter
- (NSNumber *)createdIdentifier;
- (NSInteger)tabCount;
- (NSRect)visibleRectOfSelectedWebDocumentView;
- (NSImage *)selectedWebViewImage:(NSSize)size;
- (NSImage *)selectedWebViewImage;
- (CGFloat)minimumDownloadsDrawerHeight;
- (CGFloat)adjustedSplitPositon:(CGFloat)proposedPosition;
// Destruction
- (void)destructWindow;
- (void)destructWindowController;
- (void)destructToolbar;
- (void)destructURLField;
- (void)destructLoadButton;
- (void)destructEncodingButton;
- (void)destructZoomButton;
- (void)destructTabbar;
- (void)destructSplitView;
- (void)destructTabView;
- (void)destructSidebar;
- (SBBookmarksView *)constructBookmarksView;
- (void)destructBookmarkView;
- (void)destructEditBookmarkView;
- (void)destructDownloaderView;
- (void)destructSnapshotView;
- (void)destructReportView;
- (void)destructUserAgentView;
- (void)destructHistoryView;
- (void)destructMessageView;
- (void)destructTextInputView;
// Construction
- (void)constructWindow;
- (void)constructWindowController;
- (void)constructToolbar;
- (void)constructURLField;
- (void)constructLoadButton;
- (void)constructEncodingButton;
- (void)constructZoomButton;
- (void)constructTabbar;
- (void)constructSplitView;
- (void)constructTabView;
- (void)constructSidebar;
- (void)constructNewTabWithString:(NSString *)string selection:(BOOL)selection;
- (void)constructNewTabWithURL:(NSURL *)URL selection:(BOOL)selection;
- (SBTabbarItem *)constructTabbarItemWithIdentifier:(NSNumber *)identifier;
- (SBTabViewItem *)constructTabViewItemWithIdentifier:(NSNumber *)identifier;
- (SBDownloadsView *)constructDownloadsViewInSidebar;
- (void)addObserverNotifications;
- (void)removeObserverNotifications;
// // Update
- (void)updateMenuWithTag:(NSInteger)tag;
- (void)updateResourcesViewIfNeeded;
- (void)updateURLFieldGoogleSuggest;
- (void)updateURLFieldGoogleSuggestDidEnd:(NSData *)data;
- (void)updateURLFieldCompletionList;
// Actions
- (void)performCloseFromButton:(id)sender;
- (void)performClose:(id)sender;
- (BOOL)shouldCloseDocument;
- (void)openAndConstructTabWithURLs:(NSArray *)urls startInTabbarItem:(SBTabbarItem *)aTabbarItem;
- (void)openAndConstructTabWithBookmarkItems:(NSArray *)items;
- (void)adjustSplitViewIfNeeded;
// Menu Actions
// Application menu
- (void)about:(id)sender;
// File menu
- (void)createNewTab:(id)sender;
- (void)openLocation:(id)sender;
- (void)saveDocumentAs:(id)sender;
- (void)saveDocumentAsDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void)downloadFromURL:(id)sender;
- (void)doneDownloader;
- (void)cancelDownloader;
- (void)snapshot:(id)sender;
- (void)doneSnapshot;
- (void)cancelSnapshot;
// View menu
- (void)toggleAllbars:(id)sender;
- (void)toggleTabbar:(id)sender;
- (void)sidebarPositionToLeft:(id)sender;
- (void)sidebarPositionToRight:(id)sender;
- (void)reload:(id)sender;
- (void)stopLoading:(id)sender;
- (void)scaleToActualSizeForView:(id)sender;
- (void)zoomInView:(id)sender;
- (void)zoomOutView:(id)sender;
- (void)scaleToActualSizeForText:(id)sender;
- (void)zoomInText:(id)sender;
- (void)zoomOutText:(id)sender;
- (void)source:(id)sender;
- (void)resources:(id)sender;
- (void)showWebInspector:(id)sender;
- (void)showConsole:(id)sender;
// History menu
- (void)backward:(id)sender;
- (void)forward:(id)sender;
- (void)showHistory:(id)sender;
- (void)doneHistory:(NSArray *)urls;
- (void)cancelHistory;
- (void)openHome:(id)sender;
// Bookmarks menu
- (void)bookmarks:(id)sender;
- (void)bookmark:(id)sender;
- (void)doneBookmark;
- (void)cancelBookmark;
- (void)editBookmarkItemAtIndex:(NSUInteger)index;
- (void)doneEditBookmark;
- (void)cancelEditBookmark;
- (void)searchInBookmarks:(id)sender;
- (void)switchToIconMode:(id)sender;
- (void)switchToListMode:(id)sender;
- (void)switchToTileMode:(id)sender;
// Window menu
- (void)selectPreviousTab:(id)sender;
- (void)selectNextTab:(id)sender;
- (void)downloads:(id)sender;
// Toolbar Actions
- (void)openURLStringInSelectedTabViewItem:(NSString *)stringValue;
- (void)openURLFromField:(id)sender;
- (void)openURLInNewTabFromField:(id)sender;
- (void)openString:(NSString *)stringValue newTab:(BOOL)newer;
- (void)searchString:(NSString *)stringValue newTab:(BOOL)newer;
- (void)changeEncodingFromMenuItem:(id)sender;
- (void)load:(id)sender;
- (void)bugReport:(id)sender;
- (void)doneReport;
- (void)cancelReport;
- (void)selectUserAgent:(id)sender;
- (void)doneUserAgent;
- (void)cancelUserAgent;
- (void)snapshot:(id)sender;
// Actions
- (void)selectURLField;
- (void)startDownloadingForURL:(NSURL *)URL;
- (void)toggleAllbarsAndSidebar;
- (void)hideAllbars;
- (void)showAllbars;
- (void)hideToolbar;
- (void)showToolbar;
- (void)toggleTabbar;
- (void)hideTabbar;
- (void)showTabbar;
- (void)hideSidebar;
- (void)showSidebar;
- (void)hideDrawer;
- (void)showDrawer;
- (void)showMessage:(NSString *)message;
- (void)doneShowMessageView;
- (BOOL)confirmMessage:(NSString *)message;
- (void)doneConfirmMessageView;
- (void)cancelConfirmMessageView;
- (NSString *)textInput:(NSString *)prompt;
- (void)doneTextInputView;
- (void)cancelTextInputView;
- (void)toggleEditableForSelectedWebView;
- (void)toggleFlip;
// Debug
- (void)debug:(NSNumber *)value;
- (void)debugAddDummyDownloads:(id)sender;

@end
