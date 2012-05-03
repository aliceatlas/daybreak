/*

SBDocument.m
 
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

#import "SBDocument.h"
#import "SBAboutView.h"
#import "SBBookmarks.h"
#import "SBBookmarkListView.h"
#import "SBBookmarkView.h"
#import "SBDownloader.h"
#import "SBDownloaderView.h"
#import "SBDownloads.h"
#import "SBDownloadsView.h"
#import "SBDrawer.h"
#import "SBGoogleSuggestParser.h"
#import "SBHistory.h"
#import "SBHistoryView.h"
#import "SBInnerView.h"
#import "SBLoadButton.h"
#import "SBMessageView.h"
#import "SBPreferences.h"
#import "SBReportView.h"
#import "SBSavePanel.h"
#import "SBSegmentedButton.h"
#import "SBSidebar.h"
#import "SBSnapshotView.h"
#import "SBTabbar.h"
#import "SBTabbarItem.h"
#import "SBTabView.h"
#import "SBTabViewItem.h"
#import "SBTextInputView.h"
#import "SBUserAgentView.h"
#import "SBURLField.h"
#import "SBUtil.h"
#import "SBWebView.h"

@implementation SBDocument

@synthesize window;
@synthesize windowController;
@synthesize toolbar;
@synthesize urlField;
@synthesize tabbar;
@synthesize splitView;
@synthesize initialURL;
@synthesize sidebarVisibility;
@dynamic selectedTabViewItem;
@dynamic selectedWebView;
@dynamic selectedWebDocumentView;
@dynamic selectedWebDataSource;
@dynamic selectedWebViewImageForBookmark;
@dynamic selectedWebViewImageDataForBookmark;

- (id)init
{
	if (self = [super init])
	{
		initialURL = nil;
		sidebarVisibility = YES;
		_identifier = 0;
	}
	return self;
}

- (void)dealloc
{
	[self removeObserverNotifications];
	[self destructURLField];
	[self destructLoadButton];
	[self destructToolbar];
	[self destructTabbar];
	[self destructSplitView];
	[self destructTabView];
	[self destructSidebar];
	[self destructBookmarkView];
	[self destructEditBookmarkView];
	[self destructDownloaderView];
	[self destructSnapshotView];
	[self destructReportView];
	[self destructUserAgentView];
	[self destructHistoryView];
	[self destructMessageView];
	[self destructTextInputView];
	[self destructWindow];
	[self destructWindowController];
	[super dealloc];
}

#pragma mark Document

- (void)makeWindowControllers
{
	[self constructWindow];
    [self constructWindowController];
	[self constructURLField];
	[self constructLoadButton];
	[self constructEncodingButton];
	[self constructZoomButton];
	[self constructToolbar];
	[self constructTabbar];
	[self constructSplitView];
#if kSBFlagCreateTabItemWhenLaunched
	[self constructNewTabWithString:[self.initialURL absoluteString] selection:YES];
#endif
    [self addWindowController:windowController];
	[self addObserverNotifications];
	tabbar.keyView = [self.window isKeyWindow];
	urlField.keyView = [self.window isKeyWindow];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
	// Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.
	
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
	
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.
	
    if (outError)
	{
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:nil];
	}
	return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.
	
	// You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
	
	// For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
	
	if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return YES;
}

- (void)updateChangeCount:(NSDocumentChangeType)changeType
{
	// Ignore
}

#pragma mark Getter

- (NSNumber *)createdIdentifier
{
	_identifier++;
	return [NSNumber numberWithUnsignedInteger:_identifier];
}

- (NSInteger)tabCount
{
	return [tabbar.items count];
}

- (SBTabViewItem *)selectedTabViewItem
{
	return tabView.selectedTabViewItem;
}

- (SBWebView *)selectedWebView
{
	return self.selectedTabViewItem.webView;
}

- (id)selectedWebDocumentView
{
	return (id)[[[self.selectedWebView mainFrame] frameView] documentView];
}

- (WebDataSource *)selectedWebDataSource
{
	return [[self.selectedWebView mainFrame] dataSource];
}

- (NSRect)visibleRectOfSelectedWebDocumentView
{
	return [(NSView *)[self selectedWebDocumentView] visibleRect];
}

- (NSImage *)selectedWebViewImage:(NSSize)size
{
	NSImage *image = nil;
	id webDocumentView = nil;
	NSRect intersectRect = NSZeroRect;
	webDocumentView = self.selectedWebDocumentView;
	intersectRect = [webDocumentView bounds];
	if (webDocumentView)
	{
		if (!NSEqualSizes(size, NSZeroSize) && !NSEqualSizes(size, intersectRect.size))
		{
			image = [[NSImage imageWithView:webDocumentView] insetWithSize:size intersectRect:intersectRect offset:NSZeroPoint];
		}
		else {
			image = [NSImage imageWithView:webDocumentView];
		}
	}
	return image;
}

- (NSImage *)selectedWebViewImage
{
	return [self selectedWebViewImage:NSZeroSize];
}

- (NSImage *)selectedWebViewImageForBookmark
{
	return [self selectedWebViewImage:SBBookmarkImageMaxSize()];
}

- (NSData *)selectedWebViewImageDataForBookmark
{
	NSData *data = nil;
	NSImage *image = [self selectedWebViewImageForBookmark];
	if (image)
		data = [[image bitmapImageRep] data];
	return data;
}

- (SBWebResourcesView *)resourcesView
{
	return [sidebar.view isKindOfClass:[SBWebResourcesView class]] ? (SBWebResourcesView *)sidebar.view : nil;
}

- (CGFloat)minimumDownloadsDrawerHeight
{
	return 1 + kSBDownloadItemSize + kSBBottombarHeight;
}

- (CGFloat)adjustedSplitPositon:(CGFloat)proposedPosition
{
	CGFloat pos = proposedPosition;
	SBBookmarksView *bookmarksView = [sidebar.view isKindOfClass:[SBBookmarksView class]] ? (SBBookmarksView *)sidebar.view : nil;
	CGFloat proposedWidth = 0.0;
	CGFloat maxWidth = 0.0;
	CGFloat width = 0;
	maxWidth = splitView.bounds.size.width;
	if (splitView.sidebarPosition == SBSidebarRightPosition)
	{
		proposedWidth = maxWidth - pos;
	}
	else {
		proposedWidth = pos;
	}
	width = [bookmarksView splitWidth:proposedWidth];
	if (splitView.sidebarPosition == SBSidebarRightPosition)
	{
		pos = maxWidth - width;
	}
	else {
		pos = width;
	}
	return pos;
}

#pragma mark Destruction

- (void)destructWindow
{
	if (window)
	{
//		[window close];
//		[window release];
		window = nil;
	}
}

- (void)destructWindowController
{
	if (windowController)
	{
//		[windowController close];
//		[windowController release];
		windowController = nil;
	}
}

- (void)destructToolbar
{
	if (toolbar)
	{
		[toolbar release];
		toolbar = nil;
	}
}

- (void)destructURLField
{
	if (urlField)
	{
		[urlField removeFromSuperview];
		[urlField release];
		urlField = nil;
	}
	if (urlView)
	{
		[urlView removeFromSuperview];
		[urlView release];
		urlView = nil;
	}
}

- (void)destructLoadButton
{
	if (loadButton)
	{
		[loadButton removeFromSuperview];
		[loadButton release];
		loadButton = nil;
	}
	if (loadView)
	{
		[loadView removeFromSuperview];
		[loadView release];
		loadView = nil;
	}
}

- (void)destructEncodingButton
{
	if (encodingButton)
	{
		[encodingButton removeFromSuperview];
		[encodingButton release];
		encodingButton = nil;
	}
	if (encodingView)
	{
		[encodingView removeFromSuperview];
		[encodingView release];
		encodingView = nil;
	}
}

- (void)destructZoomButton
{
	if (zoomButton)
	{
		[zoomButton removeFromSuperview];
		[zoomButton release];
		zoomButton = nil;
	}
	if (zoomView)
	{
		[zoomView removeFromSuperview];
		[zoomView release];
		zoomView = nil;
	}
}

- (void)destructTabbar
{
	if (tabbar)
	{
		[tabbar removeFromSuperview];
		[tabbar release];
		tabbar = nil;
	}
}

- (void)destructSplitView
{
	if (splitView)
	{
		[splitView removeFromSuperview];
		[splitView release];
		splitView = nil;
	}
}

- (void)destructTabView
{
	if (tabView)
	{
		tabView.delegate = nil;
		[tabView removeFromSuperview];
		[tabView release];
		tabView = nil;
	}
}

- (void)destructSidebar
{
	if (sidebar)
	{
		[sidebar removeFromSuperview];
		[sidebar release];
		sidebar = nil;
	}
}

- (void)destructBookmarkView
{
	if (bookmarkView)
	{
		[bookmarkView removeFromSuperview];
		[bookmarkView release];
		bookmarkView = nil;
	}
}

- (void)destructEditBookmarkView
{
	if (editBookmarkView)
	{
		[editBookmarkView removeFromSuperview];
		[editBookmarkView release];
		editBookmarkView = nil;
	}
}

- (void)destructDownloaderView
{
	if (downloaderView)
	{
		[downloaderView removeFromSuperview];
		[downloaderView release];
		downloaderView = nil;
	}
}

- (void)destructSnapshotView
{
	if (snapshotView)
	{
		[snapshotView removeFromSuperview];
		[snapshotView release];
		snapshotView = nil;
	}
}

- (void)destructReportView
{
	if (reportView)
	{
		[reportView removeFromSuperview];
		[reportView release];
		reportView = nil;
	}
}

- (void)destructUserAgentView
{
	if (userAgentView)
	{
		[userAgentView removeFromSuperview];
		[userAgentView release];
		userAgentView = nil;
	}
}

- (void)destructHistoryView
{
	if (historyView)
	{
		[historyView removeFromSuperview];
		[historyView release];
		historyView = nil;
	}
}

- (void)destructMessageView
{
	if (messageView)
	{
		[messageView removeFromSuperview];
		[messageView release];
		messageView = nil;
	}
}

- (void)destructTextInputView
{
	if (textInputView)
	{
		[textInputView removeFromSuperview];
		[textInputView release];
		textInputView = nil;
	}
}

#pragma mark Construction

- (void)constructWindow
{
	NSString *savedFrameString = [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"NSWindow Frame %@", kSBDocumentWindowAutosaveName]];
	NSRect defaultFrame = SBDefaultDocumentWindowRect();
	NSRect r = savedFrameString ? NSRectFromString(savedFrameString) : defaultFrame;
	[self destructWindow];
	window = [[[SBDocumentWindow alloc] initWithFrame:r delegate:self tabbarVisivility:YES] autorelease];
	if (window)
	{
		NSButton *button = nil;
		button = [window standardWindowButton:NSWindowCloseButton];
		[button setTarget:self];
		[button setAction:@selector(performCloseFromButton:)];
	}
}

- (void)constructWindowController
{
	[self destructWindowController];
	if (window)
	{
		windowController = [[[NSWindowController alloc] initWithWindow:window] autorelease];
		[windowController setWindowFrameAutosaveName:kSBDocumentWindowAutosaveName];
	}
}

- (void)constructToolbar
{
	[self destructToolbar];
	if (window)
	{
		toolbar = [[SBToolbar alloc] initWithIdentifier:kSBDocumentToolbarIdentifier];
		[toolbar setSizeMode:NSToolbarSizeModeSmall];
		[toolbar setDisplayMode:NSToolbarDisplayModeIconOnly];
		[toolbar setAllowsUserCustomization:YES];
		[toolbar setAutosavesConfiguration:YES];
		[toolbar setShowsBaselineSeparator:NO];
		[toolbar setDelegate:self];
		[window setToolbar:toolbar];
	}
}

- (void)constructURLField
{
	NSRect r = NSMakeRect(0, 0, 320.0, 24.0);
	[self destructURLField];
	urlView = [[NSView alloc] initWithFrame:r];
	[urlView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
	urlField = [[SBURLField alloc] initWithFrame:urlView.bounds];
	[urlField constructViews];
	[urlField setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
	urlField.delegate = self;
	urlField.dataSource = self;
	[urlView addSubview:urlField];
}

- (void)constructLoadButton
{
	NSRect r = NSMakeRect(0, 0, 24.0, 24.0);
	[self destructLoadButton];
	loadView = [[NSView alloc] initWithFrame:r];
	[loadView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
	loadButton = [[SBLoadButton alloc] initWithFrame:loadView.bounds];
	[loadButton setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
	loadButton.images = [NSArray arrayWithObjects:[NSImage imageNamed:@"Reload.png"], [NSImage imageNamed:@"Stop.png"], nil];
	loadButton.target = self;
	loadButton.action = @selector(load:);
	[loadView addSubview:loadButton];
}

- (void)constructEncodingButton
{
	NSRect r = NSMakeRect(0, 0, 250.0, 24.0);
	NSImage *image = nil;
	NSString *encodingName = [SBGetWebPreferences() defaultTextEncodingName];
	[self destructEncodingButton];
	encodingView = [[NSView alloc] initWithFrame:r];
	[encodingView setAutoresizingMask:(NSViewMaxXMargin | NSViewMinXMargin | NSViewMaxYMargin | NSViewMinYMargin)];
	encodingButton = [[SBPopUpButton alloc] initWithFrame:encodingView.bounds];
	image = [[NSImage imageNamed:@"Plain.png"] stretchableImageWithSize:r.size sideCapWidth:7.0];
	encodingButton.backgroundImage = image;
	[encodingButton setMenu:SBEncodingMenu(nil, nil, YES)];
	encodingButton.target = self;
	encodingButton.action = @selector(changeEncodingFromMenuItem:);
	[encodingView addSubview:encodingButton];
	[encodingButton selectItemWithRepresentedObject:encodingName];
}

- (void)constructZoomButton
{
	NSRect r = NSMakeRect(0, 0, 72.0, 24.0);
	NSRect r0 = NSMakeRect(0, 0, 24.0, 24.0);
	NSRect r1 = NSMakeRect(24.0, 0, 24.0, 24.0);
	NSRect r2 = NSMakeRect(48.0, 0, 24.0, 24.0);
	SBButton *zoomButton0 = nil;
	SBButton *zoomButton1 = nil;
	SBButton *zoomButton2 = nil;
	[self destructZoomButton];
	zoomView = [[NSView alloc] initWithFrame:r];
	[zoomView setAutoresizingMask:(NSViewMaxXMargin | NSViewMinXMargin | NSViewMaxYMargin | NSViewMinYMargin)];
	zoomButton = [[SBSegmentedButton alloc] init];
	zoomButton0 = [[[SBButton alloc] initWithFrame:r0] autorelease];
	zoomButton1 = [[[SBButton alloc] initWithFrame:r1] autorelease];
	zoomButton2 = [[[SBButton alloc] initWithFrame:r2] autorelease];
	zoomButton0.target = self;
	zoomButton1.target = self;
	zoomButton2.target = self;
	zoomButton0.action = @selector(zoomOutView:);
	zoomButton1.action = @selector(scaleToActualSizeForView:);
	zoomButton2.action = @selector(zoomInView:);
	zoomButton0.image = [NSImage imageWithCGImage:SBZoomOutIconImage(NSSizeToCGSize(r0.size))];
	zoomButton1.image = [NSImage imageWithCGImage:SBActualSizeIconImage(NSSizeToCGSize(r1.size))];
	zoomButton2.image = [NSImage imageWithCGImage:SBZoomInIconImage(NSSizeToCGSize(r2.size))];
	zoomButton.buttons = [NSArray arrayWithObjects:zoomButton0, zoomButton1, zoomButton2, nil];
	[zoomView addSubview:zoomButton];
}

- (void)constructTabbar
{
	[self destructTabbar];
	if (window)
	{
		BOOL tabbarVisivility = NO;
		tabbar = [[SBTabbar alloc] init];
		tabbar.toolbarVisible = [toolbar isVisible];
		tabbar.delegate = self;
		[window setTabbar:tabbar];
		[tabbar constructAddButton];	// Create add button after resizing
		// Set visibility
		tabbarVisivility = [[NSUserDefaults standardUserDefaults] boolForKey:kSBTabbarVisibilityFlag];
		if (!tabbarVisivility)
			[self hideTabbar];
	}
}

- (void)constructSplitView
{
	[self destructSplitView];
	if (window)
	{
		SBSidebarPosition position = [[NSUserDefaults standardUserDefaults] integerForKey:kSBSidebarPosition];
		splitView = [[SBSplitView alloc] initWithFrame:[window splitViewRect]];
		splitView.delegate = self;
		splitView.sidebarPosition = position;
		if (position == SBSidebarLeftPosition)
		{
			[self constructSidebar];
			[self constructTabView];
		}
		else if (position == SBSidebarRightPosition)
		{
			[self constructTabView];
			[self constructSidebar];
		}
		[window setSplitView:splitView];
	}
}

- (void)constructTabView
{
	[self destructTabView];
	if (splitView)
	{
		tabView = [[SBTabView alloc] initWithFrame:[splitView viewRect]];
		tabView.delegate = self;
		[tabView setTabViewType:NSNoTabsNoBorder];
		[tabView setDrawsBackground:NO];
		splitView.view = (NSView *)tabView;
	}
}

- (void)constructSidebar
{
	[self destructSidebar];
	if (sidebarVisibility)
	{
		SBBookmarksView *bookmarksView = nil;
		SBDrawer *drawer = nil;
		
		sidebar = [[SBSidebar alloc] initWithFrame:[splitView sidebarRect]];
		sidebar.delegate = self;
		sidebar.siderbarDelegate = splitView;
		sidebar.position = splitView.sidebarPosition;
		sidebar.drawerHeight = [self minimumDownloadsDrawerHeight];	// Set to default height
		splitView.sidebar = sidebar;
		if ((bookmarksView = [self constructBookmarksView]))
		{
			sidebar.view = bookmarksView;
		}
		if ((drawer = [[[SBDrawer alloc] initWithFrame:[sidebar drawerRect]] autorelease]))
		{
			sidebar.drawer = drawer;
		}
		[sidebar constructBottombar];
		[sidebar.bottombar.sizeSlider setFloatValue:bookmarksView.cellWidth];
		[sidebar closeDrawerWithAnimatedFlag:NO];
	}
}

- (SBBookmarksView *)constructBookmarksView
{
	SBBookmarksView *bookmarksView = nil;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	bookmarksView = [[[SBBookmarksView alloc] initWithFrame:[sidebar viewRect]] autorelease];
	[bookmarksView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
	bookmarksView.delegate = self;
	[bookmarksView constructListView:[defaults integerForKey:kSBBookmarkMode]];
	return bookmarksView;
}

- (void)constructNewTabWithString:(NSString *)string selection:(BOOL)selection
{
	NSString *requestURLString = [string length] > 0 ? [string requestURLString] : nil;
	NSURL *URL = [requestURLString length] > 0 ? [NSURL URLWithString:requestURLString] : nil;
	[self constructNewTabWithURL:URL selection:selection];
}

- (void)constructNewTabWithURL:(NSURL *)URL selection:(BOOL)selection
{
	SBTabbarItem *tabbarItem = nil;
	SBTabViewItem *tabViewItem = nil;
	NSNumber *identifier = nil;
	identifier = [self createdIdentifier];
	tabbarItem = [self constructTabbarItemWithIdentifier:identifier];
	tabbarItem.title = [self displayName];
	tabbarItem.progress = -1;
	tabViewItem = [self constructTabViewItemWithIdentifier:identifier];
	tabViewItem.tabbarItem = tabbarItem;
	if (selection)
	{
		[tabView selectTabViewItem:tabViewItem];
		[tabbar selectItem:tabbarItem];
	}
	// request URL after selecting
	tabViewItem.URL = URL;
	if (selection)
	{
		if (URL)
		{
			[self.window makeFirstResponder:[tabViewItem webView]];
		}
		else {
			if ([self.window.toolbar isVisible])
			{
				[self selectURLField];
			}
		}
	}
}

- (SBTabbarItem *)constructTabbarItemWithIdentifier:(NSNumber *)identifier
{
	SBTabbarItem *tabbarItem = nil;
	tabbarItem = [tabbar addItemWithIdentifier:identifier];
	return tabbarItem;
}

- (SBTabViewItem *)constructTabViewItemWithIdentifier:(NSNumber *)identifier
{
	SBTabViewItem *tabViewItem = nil;
	tabViewItem = [tabView addItemWithIdentifier:identifier];
	return tabViewItem;
}

- (SBDownloadsView *)constructDownloadsViewInSidebar
{
	NSRect availableRect = [sidebar.drawer availableRect];
	SBDownloadsView *downloadsView = nil;
	availableRect.origin = NSZeroPoint;
	downloadsView = [[[SBDownloadsView alloc] initWithFrame:availableRect] autorelease];
	downloadsView.delegate = sidebar;
	sidebar.drawer.view = downloadsView;
	[downloadsView constructDownloadViews];
	return downloadsView;
}

- (void)addObserverNotifications
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(bookmarksDidUpdate:) name:SBBookmarksDidUpdateNotification object:[SBBookmarks sharedBookmarks]];
	[center addObserver:self selector:@selector(downloadsDidAddItem:) name:SBDownloadsDidAddItemNotification object:nil];
	[center addObserver:self selector:@selector(downloadsWillRemoveItem:) name:SBDownloadsWillRemoveItemNotification object:nil];
	[center addObserver:self selector:@selector(downloadsDidUpdateItem:) name:SBDownloadsDidUpdateItemNotification object:nil];
	[center addObserver:self selector:@selector(downloadsDidFinishItem:) name:SBDownloadsDidFinishItemNotification object:nil];
	[center addObserver:self selector:@selector(downloadsDidFailItem:) name:SBDownloadsDidFailItemNotification object:nil];
}

- (void)removeObserverNotifications
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center removeObserver:self name:SBBookmarksDidUpdateNotification object:nil];
	[center removeObserver:self name:SBDownloadsDidAddItemNotification object:nil];
	[center removeObserver:self name:SBDownloadsWillRemoveItemNotification object:nil];
	[center removeObserver:self name:SBDownloadsDidUpdateItemNotification object:nil];
	[center removeObserver:self name:SBDownloadsDidFinishItemNotification object:nil];
	[center removeObserver:self name:SBDownloadsDidFailItemNotification object:nil];
}

#pragma mark Toolbar

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)aToolbar
{
	NSArray *identifiers = nil;
	identifiers = [NSArray arrayWithObjects:
				   kSBToolbarURLFieldItemIdentifier, 
				   kSBToolbarLoadItemIdentifier, 
				   kSBToolbarBookmarkItemIdentifier, 
				   kSBToolbarHistoryItemIdentifier, 
				   kSBToolbarHomeItemIdentifier, 
				   kSBToolbarTextEncodingItemIdentifier, 
				   kSBToolbarBookmarksItemIdentifier, 
				   kSBToolbarSnapshotItemIdentifier, 
				   kSBToolbarBugsItemIdentifier, 
				   kSBToolbarUserAgentItemIdentifier, 
				   kSBToolbarSourceItemIdentifier, 
				   kSBToolbarZoomItemIdentifier, 
				   NSToolbarSpaceItemIdentifier, 
				   NSToolbarFlexibleSpaceItemIdentifier, 
				   NSToolbarPrintItemIdentifier, nil];
	return identifiers;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)aToolbar
{
	NSArray *identifiers = nil;
	identifiers = [NSArray arrayWithObjects:
				   kSBToolbarURLFieldItemIdentifier, 
				   kSBToolbarLoadItemIdentifier, 
				   kSBToolbarBookmarkItemIdentifier, 
				   kSBToolbarHistoryItemIdentifier, 
				   kSBToolbarHomeItemIdentifier, 
				   kSBToolbarTextEncodingItemIdentifier, 
				   kSBToolbarBookmarksItemIdentifier, 
				   kSBToolbarSnapshotItemIdentifier, 
				   kSBToolbarBugsItemIdentifier, 
				   kSBToolbarUserAgentItemIdentifier, 
				   kSBToolbarSourceItemIdentifier, 
				   kSBToolbarZoomItemIdentifier, 
				   nil];
	return identifiers;
}

- (NSToolbarItem *)toolbar:(NSToolbar *)aToolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
	NSToolbarItem *item = nil;
	item = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier] autorelease];
	if ([itemIdentifier isEqualToString:kSBToolbarURLFieldItemIdentifier])
	{
		[item setView:urlView];
		[item setLabel:NSLocalizedString(@"URL Field", nil)];
		[item setPaletteLabel:NSLocalizedString(@"URL Field", nil)];
		[item setToolTip:NSLocalizedString(@"URL Field", nil)];
		[item setMaxSize:NSMakeSize(window.frame.size.width, 24.0)];
		[item setMinSize:NSMakeSize(320.0, 24.0)];
	}
	else if ([itemIdentifier isEqualToString:kSBToolbarLoadItemIdentifier])
	{
		[item setView:loadView];
		[item setLabel:NSLocalizedString(@"Load", nil)];
		[item setPaletteLabel:NSLocalizedString(@"Load", nil)];
		[item setToolTip:NSLocalizedString(@"Reload / Stop", nil)];
		[item setMaxSize:NSMakeSize(32.0, 32.0)];
		[item setMinSize:NSMakeSize(24.0, 24.0)];
	}
	else if ([itemIdentifier isEqualToString:kSBToolbarBookmarkItemIdentifier])
	{
		[item setLabel:NSLocalizedString(@"Add Bookmark", nil)];
		[item setPaletteLabel:NSLocalizedString(@"Add Bookmark", nil)];
		[item setToolTip:NSLocalizedString(@"Add Bookmark", nil)];
		[item setImage:[NSImage imageNamed:@"Bookmark"]];
		[item setAction:@selector(bookmark:)];
	}
	else if ([itemIdentifier isEqualToString:kSBToolbarHistoryItemIdentifier])
	{
		[item setLabel:NSLocalizedString(@"History", nil)];
		[item setPaletteLabel:NSLocalizedString(@"History", nil)];
		[item setToolTip:NSLocalizedString(@"History", nil)];
		[item setImage:[NSImage imageNamed:@"History"]];
		[item setAction:@selector(showHistory:)];
	}
	else if ([itemIdentifier isEqualToString:kSBToolbarHomeItemIdentifier])
	{
		[item setLabel:NSLocalizedString(@"Go Home", nil)];
		[item setPaletteLabel:NSLocalizedString(@"Go Home", nil)];
		[item setToolTip:NSLocalizedString(@"Go Home Page", nil)];
		[item setImage:[NSImage imageNamed:@"Home"]];
		[item setAction:@selector(openHome:)];
	}
	else if ([itemIdentifier isEqualToString:kSBToolbarTextEncodingItemIdentifier])
	{
		[item setView:encodingView];
		[item setLabel:NSLocalizedString(@"Text Encoding", nil)];
		[item setPaletteLabel:NSLocalizedString(@"Text Encoding", nil)];
		[item setToolTip:NSLocalizedString(@"Text Encoding", nil)];
		[item setMaxSize:NSMakeSize(250.0, 24.0)];
		[item setMinSize:NSMakeSize(250.0, 24.0)];
	}
	else if ([itemIdentifier isEqualToString:kSBToolbarBookmarksItemIdentifier])
	{
		[item setLabel:NSLocalizedString(@"Bookmarks", nil)];
		[item setPaletteLabel:NSLocalizedString(@"Bookmarks", nil)];
		[item setToolTip:NSLocalizedString(@"Bookmarks", nil)];
		[item setImage:[NSImage imageNamed:@"Bookmarks-Icon"]];
		[item setAction:@selector(bookmarks:)];
	}
	else if ([itemIdentifier isEqualToString:kSBToolbarSnapshotItemIdentifier])
	{
		[item setLabel:NSLocalizedString(@"Snapshot", nil)];
		[item setPaletteLabel:NSLocalizedString(@"Snapshot", nil)];
		[item setToolTip:NSLocalizedString(@"Snapshot Current Page", nil)];
		[item setImage:[NSImage imageNamed:@"Snapshot"]];
		[item setAction:@selector(snapshot:)];
	}
	else if ([itemIdentifier isEqualToString:kSBToolbarBugsItemIdentifier])
	{
		[item setLabel:NSLocalizedString(@"Bug Report", nil)];
		[item setPaletteLabel:NSLocalizedString(@"Bug Report", nil)];
		[item setToolTip:NSLocalizedString(@"Send Bug Report", nil)];
		[item setImage:[NSImage imageNamed:@"Bug"]];
		[item setAction:@selector(bugReport:)];
	}
	else if ([itemIdentifier isEqualToString:kSBToolbarUserAgentItemIdentifier])
	{
		[item setLabel:NSLocalizedString(@"User Agent", nil)];
		[item setPaletteLabel:NSLocalizedString(@"User Agent", nil)];
		[item setToolTip:NSLocalizedString(@"Select User Agent", nil)];
		[item setImage:[NSImage imageNamed:@"UserAgent"]];
		[item setAction:@selector(selectUserAgent:)];
	}
	else if ([itemIdentifier isEqualToString:kSBToolbarZoomItemIdentifier])
	{
		[item setView:zoomView];
		[item setLabel:NSLocalizedString(@"Zoom", nil)];
		[item setPaletteLabel:NSLocalizedString(@"Zoom", nil)];
		[item setToolTip:NSLocalizedString(@"Zoom", nil)];
		[item setMaxSize:NSMakeSize(72.0, 24.0)];
		[item setMinSize:NSMakeSize(72.0, 24.0)];
	}
	else if ([itemIdentifier isEqualToString:kSBToolbarSourceItemIdentifier])
	{
		[item setLabel:NSLocalizedString(@"Source", nil)];
		[item setPaletteLabel:NSLocalizedString(@"Source", nil)];
		[item setToolTip:NSLocalizedString(@"Source", nil)];
		[item setImage:[NSImage imageNamed:@"Source"]];
		[item setAction:@selector(source:)];
	}
	return item;
}

#pragma mark Window Delegate

- (void)windowDidBecomeMain:(NSNotification *)notification
{
	window.keyView = YES;
	urlField.keyView = YES;
	tabbar.keyView = YES;
}

- (void)windowDidResignMain:(NSNotification *)notification
{
	window.keyView = NO;
	urlField.keyView = NO;
	tabbar.keyView = NO;
	[urlField disappearSheet];
}

- (void)windowDidResignKey:(NSNotification *)notification
{
	[urlField disappearSheet];
}

- (void)windowDidResize:(NSNotification *)notification
{
	[tabbar updateItems];
}

- (NSRect)window:(NSWindow *)aWindow willPositionSheet:(NSWindow *)sheet usingRect:(NSRect)defaultSheetRect
{
	NSRect r = defaultSheetRect;
	r.origin.y = [window sheetPosition];
	return r;
}

- (BOOL)window:(SBDocumentWindow *)aWindow shouldClose:(id)sender
{
	return [self shouldCloseDocument];
}

- (BOOL)window:(SBDocumentWindow *)aWindow shouldHandleKeyEvent:(NSEvent *)theEvent
{
	BOOL r = NO;
	NSString *characters = [theEvent characters];
	if ([theEvent modifierFlags] & NSCommandKeyMask && 
		[theEvent modifierFlags] & NSShiftKeyMask && 
		[characters isEqualToString:@"b"])
	{
		[self toggleAllbarsAndSidebar];
		r = YES;
	}
	else if ([theEvent modifierFlags] & NSCommandKeyMask && 
			 [theEvent modifierFlags] & NSShiftKeyMask && 
			 [characters isEqualToString:@"e"])
	{
		[self toggleEditableForSelectedWebView];
		r = YES;
	}
	else if ([theEvent modifierFlags] & NSCommandKeyMask && 
			 [theEvent modifierFlags] & NSShiftKeyMask && 
			 [characters isEqualToString:@"f"])
	{
		[self toggleFlip];
		r = YES;
	}
	else if ([theEvent modifierFlags] & NSCommandKeyMask && 
			 [theEvent modifierFlags] & NSShiftKeyMask && 
			 [characters isEqualToString:@"i"])
	{
		WebView *webView = [self selectedWebView];
		id inspector = [webView respondsToSelector:@selector(inspector)] ? [webView inspector] : nil;
		if (inspector) if ([inspector respondsToSelector:@selector(show:)]) [inspector show:nil];
		r = YES;
	}
	else if ([theEvent modifierFlags] & NSCommandKeyMask && 
			 [theEvent modifierFlags] & NSShiftKeyMask && 
			 [characters isEqualToString:@"c"])
	{
		WebView *webView = [self selectedWebView];
		id inspector = [webView respondsToSelector:@selector(inspector)] ? [webView inspector] : nil;
		if (inspector) if ([inspector respondsToSelector:@selector(show:)]) [inspector show:nil];
		if (inspector) if ([inspector respondsToSelector:@selector(showConsole:)]) [inspector showConsole:nil];
		r = YES;
	}
	return r;
}

- (void)windowDidFinishFlipping:(SBDocumentWindow *)aWindow
{
	
}

#pragma mark Toolbar Delegate

- (void)toolbarDidVisible:(SBToolbar *)aToolbar
{
	tabbar.toolbarVisible = YES;
}

- (void)toolbarDidInvisible:(SBToolbar *)aToolbar
{
	tabbar.toolbarVisible = NO;
}

#pragma mark Tabbar Delegate

- (void)tabbar:(SBTabbar *)aTabbar shouldAddNewItemForURLs:(NSArray *)urls
{
	if ([urls count] > 0)
	{
		NSInteger i = 0;
		for (NSURL *url in urls)
		{
			[self constructNewTabWithURL:url selection:(i == ([urls count] - 1))];
			i++;
		}
	}
	else {
		[self createNewTab:nil];
	}
}

- (void)tabbar:(SBTabbar *)aTabbar shouldOpenURLs:(NSArray *)urls startInItem:(SBTabbarItem *)aTabbarItem
{
	if ([urls count] > 0)
	{
		[self openAndConstructTabWithURLs:urls startInTabbarItem:aTabbarItem];
	}
}

- (void)tabbar:(SBTabbar *)aTabbar shouldReload:(SBTabbarItem *)aTabbarItem
{
	SBTabViewItem *tabViewItem = nil;
	tabViewItem = [tabView tabViewItemWithIdentifier:aTabbarItem.identifier];
	[tabViewItem.webView reload:nil];
}

- (void)tabbar:(SBTabbar *)aTabbar didChangeSelection:(SBTabbarItem *)aTabbarItem
{
	SBTabViewItem *tabViewItem = nil;
	// Select tab
	tabViewItem = [tabView selectTabViewItemWithItemIdentifier:aTabbarItem.identifier];
	
	// Change window values
	self.window.title = tabViewItem.tabbarItem.title;
	// Change URL field values
	urlField.enabledBackward = tabViewItem.canBackward;
	urlField.enabledForward = tabViewItem.canForward;
	urlField.stringValue = [tabViewItem.mainFrameURLString URLDencodedString];
	urlField.image = tabViewItem.tabbarItem.image;
	// Change state of the load button
	loadButton.on = [[tabViewItem webView] isLoading];
	// Change resources
	[self updateResourcesViewIfNeeded];
}

- (void)tabbar:(SBTabbar *)aTabbar didReselection:(SBTabbarItem *)aTabbarItem
{
	NSView *documentView = [self selectedWebDocumentView];
	[documentView scrollRectToVisible:NSZeroRect];
}

- (void)tabbar:(SBTabbar *)aTabbar didRemoveItem:(NSString *)identifier
{
	NSInteger index = [tabView indexOfTabViewItemWithIdentifier:identifier];
	SBTabViewItem *tabViewItem = (SBTabViewItem *)[tabView tabViewItemAtIndex:index];
	if (tabViewItem)
	{
		[tabViewItem removeFromTabView];
	}
}

#pragma mark URL Field Delegate

- (void)urlFieldDidSelectBackward:(SBURLField *)aUrlField
{
	[self backward:urlField];
}

- (void)urlFieldDidSelectForward:(SBURLField *)aUrlField
{
	[self forward:urlField];
}

- (void)urlFieldShouldOpenURL:(SBURLField *)aUrlField
{
	[self openURLFromField:urlField];
	[self.window makeFirstResponder:[self selectedWebView]];
}

- (void)urlFieldShouldOpenURLInNewTab:(SBURLField *)aUrlField
{
	[self openURLInNewTabFromField:urlField];
	[self.window makeFirstResponder:[self selectedWebView]];
}

- (void)urlFieldShouldDownloadURL:(SBURLField *)aUrlField
{
	NSString *stringValue = urlField.stringValue;
	if (stringValue)
	{
		[self.window makeFirstResponder:nil];
		[self startDownloadingForURL:[NSURL URLWithString:stringValue]];
	}
}

- (void)urlFieldTextDidChange:(SBURLField *)aUrlField
{
	[self updateURLFieldCompletionList];
#if kSBURLFieldShowsGoogleSuggest
	[self updateURLFieldGoogleSuggest];
#endif
}

- (void)urlFieldWillResignFirstResponder:(SBURLField *)aUrlField
{
	urlField.hiddenGo = YES;
}

#pragma mark SBDownloaderDelegate

- (void)downloader:(SBDownloader *)downloader didFinish:(NSData *)data
{
	[self updateURLFieldGoogleSuggestDidEnd:data];
}

- (void)downloader:(SBDownloader *)downloader didFail:(NSError *)error
{
	[self updateURLFieldGoogleSuggestDidEnd:nil];
}

#pragma mark SplitView Delegate

- (BOOL)splitView:(NSSplitView *)aSplitView canCollapseSubview:(NSView *)aSubview
{
	BOOL r = YES;
	if (aSplitView == splitView)
	{
		r = NO;
	}
	else if (aSplitView == sidebar)
	{
		if (aSubview == sidebar.drawer)
		{
			r = NO;
		}
	}
	return r;
}

- (BOOL)splitView:(NSSplitView *)aSplitView shouldHideDividerAtIndex:(NSInteger)dividerIndex
{
	BOOL r = NO;
	if (aSplitView == splitView)
	{
	}
	else if (aSplitView == sidebar)
	{
	}
	return r;
}

- (BOOL)splitView:(NSSplitView *)aSplitView shouldCollapseSubview:(NSView *)aSubview forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex
{
	BOOL r = YES;
	if (aSplitView == splitView)
	{
		if (aSubview == splitView.view)
		{
			r = NO;
		}
	}
	else if (aSplitView == sidebar)
	{
		if (aSubview == sidebar.view)
		{
			r = NO;
		}
	}
	return r;
}

- (NSRect)splitView:(NSSplitView *)aSplitView additionalEffectiveRectOfDividerAtIndex:(NSInteger)dividerIndex
{
	NSRect r = NSZeroRect;
	if (aSplitView == splitView)
	{
		NSPoint center = NSZeroPoint;
		center.y = splitView.bounds.size.height - kSBBottombarHeight;
		if (splitView.sidebarPosition == SBSidebarRightPosition)
		{
			center.x = splitView.bounds.size.width - splitView.sidebarWidth;
		}
		else {
			center.x = splitView.sidebarWidth - kSBBottombarHeight;
		}
		r = NSMakeRect(center.x, center.y, kSBBottombarHeight, kSBBottombarHeight);
	}
	else if (aSplitView == sidebar)
	{
		
	}
	return r;
}

- (CGFloat)splitView:(NSSplitView *)aSplitView constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)offset
{
	CGFloat pos = proposedPosition;
	if (aSplitView == splitView)
	{
		pos = [self adjustedSplitPositon:proposedPosition];
	}
	else if (aSplitView == sidebar)
	{
		if (offset == 0)
		{
			if (proposedPosition >= sidebar.frame.size.height - kSBBottombarHeight)
			{
				pos = sidebar.frame.size.height - kSBBottombarHeight;
			}
			if (!sidebar.bottombar.drawerVisibility)
				sidebar.bottombar.drawerVisibility = YES;
		}
	}
	return pos;
}

- (CGFloat)splitView:(NSSplitView *)aSplitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)offset
{
	CGFloat maxWidth = proposedMax;
	if (aSplitView == splitView)
	{
		if (splitView.sidebarPosition == SBSidebarRightPosition)
		{
			maxWidth = splitView.bounds.size.width - kSBSidebarMinimumWidth;
		}
	}
	else if (aSplitView == sidebar)
	{
		maxWidth = sidebar.bounds.size.height - [self minimumDownloadsDrawerHeight];
	}
	return maxWidth;
}

- (CGFloat)splitView:(NSSplitView *)aSplitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)offset
{
	CGFloat minWidth = proposedMin;
	if (aSplitView == splitView)
	{
		if (splitView.sidebarPosition == SBSidebarLeftPosition)
		{
			minWidth = kSBSidebarMinimumWidth;
		}
	}
	return minWidth;
}

- (void)splitViewDidResizeSubviews:(NSNotification *)aNotification
{
	NSSplitView *aSplitView = [aNotification object];
	if (aSplitView == splitView)
	{
		if (!splitView.animating && splitView.visibleSidebar)
		{
			CGFloat width = splitView.sidebar.frame.size.width;
			splitView.sidebarWidth = width;
			if (width < kSBSidebarMinimumWidth)
				width = kSBSidebarMinimumWidth;
			[[NSUserDefaults standardUserDefaults] setFloat:width forKey:kSBSidebarWidth];
		}
	}
	else if (aSplitView == sidebar)
	{
		if (!sidebar.animating)
		{
			CGFloat height = sidebar.drawer.frame.size.height;
			if (height > kSBBottombarHeight)
			{
				sidebar.drawerHeight = height;
			}
		}
	}
}

- (void)splitViewDidOpenDrawer:(SBSplitView *)aSplitView
{
	SBDownloadsView *downloadsView = (SBDownloadsView *)sidebar.drawer.view;
	if (!downloadsView)
	{
		[self constructDownloadsViewInSidebar];
	}
}

#pragma mark 10.6 only

- (BOOL)splitView:(NSSplitView *)aSplitView shouldAdjustSizeOfSubview:(NSView *)aSubview
{
	BOOL r = YES;
	if (aSplitView == splitView)
	{
		if (aSubview == splitView.sidebar)
		{
			r = NO;
		}
	}
	else if (aSplitView == sidebar)
	{
		if (aSubview == sidebar.drawer)
		{
			r = NO;
		}
	}
	return r;
}

#pragma mark TabView Delegate

- (void)tabView:(SBTabView *)aTabView didSelectTabViewItem:(SBTabViewItem *)aTabViewItem
{
	NSString *encodingName = nil;
	// Change encoding pop-up
	encodingName = [[aTabViewItem webView] customTextEncodingName];
	[encodingButton selectItemWithRepresentedObject:encodingName];
}

- (void)tabView:(SBTabView *)aTabView selectedItemDidStartLoading:(SBTabViewItem *)aTabViewItem
{
	if (![urlField isFirstResponder] || [urlField.stringValue length] == 0)
		urlField.stringValue = [aTabViewItem.mainFrameURLString URLDencodedString];
	[self updateMenuWithTag:SBViewMenuTag];
	[self updateResourcesViewIfNeeded];
	loadButton.on = YES;
}

- (void)tabView:(SBTabView *)aTabView selectedItemDidFinishLoading:(SBTabViewItem *)aTabViewItem
{
//	WebView *webView = [self selectedWebView];
	urlField.enabledBackward = aTabViewItem.canBackward;
	urlField.enabledForward = aTabViewItem.canForward;
	if (![urlField isFirstResponder] || [urlField.stringValue length] == 0)
		urlField.stringValue = [aTabViewItem.mainFrameURLString URLDencodedString];
//	if (![urlField isFirstResponder] && webView)
//	{
//		[self.window makeFirstResponder:webView];
//	}
	[self updateMenuWithTag:SBViewMenuTag];
	[self updateResourcesViewIfNeeded];
	loadButton.on = NO;
}

- (void)tabView:(SBTabView *)aTabView selectedItemDidFailLoading:(SBTabViewItem *)aTabViewItem
{
	urlField.enabledBackward = aTabViewItem.canBackward;
	urlField.enabledForward = aTabViewItem.canForward;
	if (![urlField isFirstResponder] || [urlField.stringValue length] == 0)
		urlField.stringValue = [aTabViewItem.mainFrameURLString URLDencodedString];
	[self updateMenuWithTag:SBViewMenuTag];
	[self updateResourcesViewIfNeeded];
	loadButton.on = NO;
}

- (void)tabView:(SBTabView *)aTabView selectedItemDidReceiveTitle:(SBTabViewItem *)aTabViewItem
{
	NSString *title = aTabViewItem.tabbarItem.title;
	NSString *URLString = aTabViewItem.mainFrameURLString;
	self.window.title = aTabViewItem.tabbarItem.title;
	[[SBHistory sharedHistory] addNewItemWithURLString:URLString title:title];
}

- (void)tabView:(SBTabView *)aTabView selectedItemDidReceiveIcon:(SBTabViewItem *)aTabViewItem
{
	urlField.image = aTabViewItem.tabbarItem.image;
}

- (void)tabView:(SBTabView *)aTabView selectedItemDidReceiveServerRedirect:(SBTabViewItem *)aTabViewItem
{
	if (![urlField isFirstResponder] || [urlField.stringValue length] == 0)
		urlField.stringValue = [aTabViewItem.mainFrameURLString URLDencodedString];
}

- (void)tabView:(SBTabView *)aTabView shouldAddNewItemForURL:(NSURL *)url selection:(BOOL)selection
{
	[self constructNewTabWithURL:url selection:selection];
	if (selection)
		[self updateResourcesViewIfNeeded];
}

- (void)tabView:(SBTabView *)aTabView shouldSearchString:(NSString *)string newTab:(BOOL)newTab
{
	[self searchString:string newTab:newTab];
}

- (BOOL)tabView:(SBTabView *)aTabView shouldConfirmWithMessage:(NSString *)message
{
	return [self confirmMessage:message];
}

- (void)tabView:(SBTabView *)aTabView shouldShowMessage:(NSString *)message
{
	[self showMessage:message];
}

- (NSString *)tabView:(SBTabView *)aTabView shouldTextInput:(NSString *)prompt
{
	return [self textInput:prompt];
}

- (void)tabView:(SBTabView *)aTabView didAddResourceID:(SBWebResourceIdentifier *)resourceID
{
	[self updateResourcesViewIfNeeded];
}

- (void)tabView:(SBTabView *)aTabView didReceiveExpectedContentLengthOfResourceID:(SBWebResourceIdentifier *)resourceID
{
	[self updateResourcesViewIfNeeded];
}

- (void)tabView:(SBTabView *)aTabView didReceiveContentLengthOfResourceID:(SBWebResourceIdentifier *)resourceID
{
	[self updateResourcesViewIfNeeded];
}

- (void)tabView:(SBTabView *)aTabView didReceiveFinishLoadingOfResourceID:(SBWebResourceIdentifier *)resourceID
{
	[self updateResourcesViewIfNeeded];
}

#pragma mark SBWebResourcesViewDataSource

- (NSInteger)numberOfRowsInWebResourcesView:(SBWebResourcesView *)aWebResourcesView
{
	NSUInteger count = 0;
	SBTabViewItem *tabViewItem = nil;
	if ((tabViewItem = self.selectedTabViewItem))
	{
		NSMutableArray *resourceIdentifiers = nil;
		if ((resourceIdentifiers = tabViewItem.resourceIdentifiers))
		{
			count = [resourceIdentifiers count];
		}
	}
	return count;
}

- (id)webResourcesView:(SBWebResourcesView *)aWebResourcesView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	NSString *object = nil;
	SBTabViewItem *tabViewItem = nil;
	if ((tabViewItem = self.selectedTabViewItem))
	{
		NSMutableArray *resourceIdentifiers = nil;
		if ((resourceIdentifiers = tabViewItem.resourceIdentifiers))
		{
			SBWebResourceIdentifier *resourceIdentifier = nil;
			NSString *identifier = [aTableColumn identifier];
			resourceIdentifier = rowIndex < [resourceIdentifiers count] ? [resourceIdentifiers objectAtIndex:rowIndex] : nil;
			if (resourceIdentifier)
			{
				if ([identifier isEqual:kSBURL])
				{
					object = [resourceIdentifier.URL absoluteString];
				}
				else if ([identifier isEqual:@"Length"])
				{
					NSString *expected = [NSString bytesStringForLength:resourceIdentifier.length];
					if (resourceIdentifier.received > 0 && resourceIdentifier.length > 0)
					{
						if (resourceIdentifier.received == resourceIdentifier.length)
						{
							// Completed
							object = [NSString stringWithFormat:@"%@", expected];
						}
						else {
							// Processing
							BOOL sameUnit = [[NSString unitStringForLength:resourceIdentifier.received] isEqualToString:[NSString unitStringForLength:resourceIdentifier.length]];
							NSString *received = nil;
							if (sameUnit)
							{
								received = [NSString bytesStringForLength:resourceIdentifier.received unit:NO];
								object = [NSString stringWithFormat:@"%@/%@", received, expected];
							}
							else {
								received = [NSString bytesStringForLength:resourceIdentifier.received];
								object = [NSString stringWithFormat:@"%@/%@", received, expected];
							}
						}
					}
					else if (resourceIdentifier.received > 0)
					{
						// Completed
						NSString *received = [NSString bytesStringForLength:resourceIdentifier.received];
						object = [NSString stringWithFormat:@"%@", received];
					}
					else if (resourceIdentifier.length > 0)
					{
						// Unloaded
						object = [NSString stringWithFormat:@"?/%@", expected];
					}
					else {
						object = @"?";
					}
				}
				else if ([identifier isEqual:@"Action"])
				{
					
				}
			}
		}
	}
	return object;
}

- (void)webResourcesView:(SBWebResourcesView *)aWebResourcesView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	SBTabViewItem *tabViewItem = nil;
	if ((tabViewItem = self.selectedTabViewItem))
	{
		NSMutableArray *resourceIdentifiers = nil;
		if ((resourceIdentifiers = tabViewItem.resourceIdentifiers))
		{
			SBWebResourceIdentifier *resourceIdentifier = nil;
			NSString *identifier = [aTableColumn identifier];
			resourceIdentifier = rowIndex < [resourceIdentifiers count] ? [resourceIdentifiers objectAtIndex:rowIndex] : nil;
			if (resourceIdentifier)
			{
				if ([identifier isEqual:kSBURL])
				{
					[aCell setTitle:[resourceIdentifier.URL absoluteString]];
				}
				else if ([identifier isEqual:@"Length"])
				{
					NSString *title = nil;
					NSString *expected = [NSString bytesStringForLength:resourceIdentifier.length];
					if (resourceIdentifier.received > 0 && resourceIdentifier.length > 0)
					{
						if (resourceIdentifier.received == resourceIdentifier.length)
						{
							// Completed
							title = [NSString stringWithFormat:@"%@", expected];
						}
						else {
							// Processing
							BOOL sameUnit = [[NSString unitStringForLength:resourceIdentifier.received] isEqualToString:[NSString unitStringForLength:resourceIdentifier.length]];
							NSString *received = nil;
							if (sameUnit)
							{
								received = [NSString bytesStringForLength:resourceIdentifier.received unit:NO];
								title = [NSString stringWithFormat:@"%@/%@", received, expected];
							}
							else {
								received = [NSString bytesStringForLength:resourceIdentifier.received];
								title = [NSString stringWithFormat:@"%@/%@", received, expected];
							}
						}
					}
					else if (resourceIdentifier.received > 0)
					{
						// Completed
						NSString *received = [NSString bytesStringForLength:resourceIdentifier.received];
						title = [NSString stringWithFormat:@"%@", received];
					}
					else if (resourceIdentifier.length > 0)
					{
						// Unloaded
						title = [NSString stringWithFormat:@"?/%@", expected];
					}
					else {
						title = @"?";
					}
					[aCell setTitle:title];
				}
				else if ([identifier isEqual:@"Cached"])
				{
					NSData *data = nil;
					NSCachedURLResponse *response = nil;
					response = [[NSURLCache sharedURLCache] cachedResponseForRequest:resourceIdentifier.request];
					data = response ? [response data] : nil;
					BOOL enable = data != nil;
					[(NSButtonCell *)aCell setEnabled:enable];
					[(NSButtonCell *)aCell setImage:enable ? [NSImage imageNamed:@"Cached.png"] : nil];
				}
				else if ([identifier isEqual:@"Action"])
				{
					[(NSButtonCell *)aCell setImage:[NSImage imageNamed:@"Download.png"]];
				}
			}
		}
	}
}

#pragma mark SBWebResourcesViewDelegate

- (void)webResourcesView:(SBWebResourcesView *)aWebResourcesView shouldSaveAtRow:(NSInteger)rowIndex
{
	SBTabViewItem *tabViewItem = nil;
	if ((tabViewItem = self.selectedTabViewItem))
	{
		NSMutableArray *resourceIdentifiers = nil;
		if ((resourceIdentifiers = tabViewItem.resourceIdentifiers))
		{
			SBWebResourceIdentifier *resourceIdentifier = nil;
			resourceIdentifier = rowIndex < [resourceIdentifiers count] ? [resourceIdentifiers objectAtIndex:rowIndex] : nil;
			if (resourceIdentifier)
			{
				if (resourceIdentifier.request)
				{
					NSData *data = nil;
					NSCachedURLResponse *response = nil;
					response = [[NSURLCache sharedURLCache] cachedResponseForRequest:resourceIdentifier.request];
					data = response ? [response data] : nil;
					if (data)
					{
						NSString *filename = resourceIdentifier.URL ? [[resourceIdentifier.URL absoluteString] lastPathComponent] : @"UntitledData";
						SBSavePanel *panel = [SBSavePanel savePanel];
						[data retain];
						[panel beginSheetForDirectory:nil file:filename modalForWindow:self.window modalDelegate:self didEndSelector:@selector(webResourceCachedDataSaveDidEnd:returnCode:contextInfo:) contextInfo:data];
					}
				}
			}
		}
	}
}

- (void)webResourceCachedDataSaveDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (contextInfo != nil)
	{
		if (returnCode == NSOKButton)
		{
			NSData *data = (NSData *)contextInfo;
			if ([data writeToFile:[sheet filename] atomically:YES])
			{
				
			}
		}
		[(id)contextInfo release];
	}
}

- (void)webResourcesView:(SBWebResourcesView *)aWebResourcesView shouldDownloadAtRow:(NSInteger)rowIndex
{
	SBTabViewItem *tabViewItem = nil;
	if ((tabViewItem = self.selectedTabViewItem))
	{
		NSMutableArray *resourceIdentifiers = nil;
		if ((resourceIdentifiers = tabViewItem.resourceIdentifiers))
		{
			SBWebResourceIdentifier *resourceIdentifier = nil;
			resourceIdentifier = rowIndex < [resourceIdentifiers count] ? [resourceIdentifiers objectAtIndex:rowIndex] : nil;
			if (resourceIdentifier)
			{
				if (resourceIdentifier.URL)
				{
					[self startDownloadingForURL:resourceIdentifier.URL];
				}
			}
		}
	}
}

#pragma mark Bookmarks Notifications

- (void)bookmarksDidUpdate:(NSNotification *)aNotification
{
	SBBookmarksView *bookmarksView = [sidebar.view isKindOfClass:[SBBookmarksView class]] ? (SBBookmarksView *)sidebar.view : nil;
	if ([aNotification object] != bookmarksView)
	{
		// Update items in other windows
		[bookmarksView reload];
	}
}

#pragma mark BookmarksView Delegate

- (void)bookmarksView:(SBBookmarksView *)aBookmarksView didChangeMode:(SBBookmarkMode)mode
{
	[self.window.toolbar validateVisibleItems];
}

- (void)bookmarksView:(SBBookmarksView *)aBookmarksView shouldEditItemAtIndex:(NSUInteger)index
{
	[self editBookmarkItemAtIndex:index];
}

- (void)bookmarksView:(SBBookmarksView *)aBookmarksView didChangeCellWidth:(CGFloat)cellWidth
{
	[self adjustSplitViewIfNeeded];
}

#pragma mark Downloads Notifications

- (void)downloadsDidAddItem:(NSNotification *)aNotification
{
	SBDownload *item = [[aNotification userInfo] objectForKey:kSBDownloadsItem];
	SBDownloadsView *downloadsView = nil;
	if (!splitView.visibleSidebar)
	{
		[self showSidebar];
	}
	if (!sidebar.visibleDrawer)
	{
		[self showDrawer];
	}
	downloadsView = (SBDownloadsView *)sidebar.drawer.view;
	if (!downloadsView)
	{
		downloadsView = [self constructDownloadsViewInSidebar];
	}
	if (item)
	{
		[downloadsView addForItem:item];
	}
}

- (void)downloadsWillRemoveItem:(NSNotification *)aNotification
{
	NSArray *items = [[aNotification userInfo] objectForKey:kSBDownloadsItems];
	SBDownloadsView *downloadsView = (SBDownloadsView *)sidebar.drawer.view;
	if (downloadsView)
	{
		for (SBDownload *item in items)
		{
			[downloadsView removeForItem:item];
		}
	}
}

- (void)downloadsDidUpdateItem:(NSNotification *)aNotification
{
	SBDownload *item = [[aNotification userInfo] objectForKey:kSBDownloadsItem];
	SBDownloadsView *downloadsView = (SBDownloadsView *)sidebar.drawer.view;
	if (downloadsView)
	{
		if (item)
		{
			[downloadsView updateForItem:item];
		}
	}
}

- (void)downloadsDidFinishItem:(NSNotification *)aNotification
{
	SBDownload *item = [[aNotification userInfo] objectForKey:kSBDownloadsItem];
	SBDownloadsView *downloadsView = (SBDownloadsView *)sidebar.drawer.view;
	if (downloadsView)
	{
		if (item)
		{
			[downloadsView finishForItem:item];
		}
	}
}

- (void)downloadsDidFailItem:(NSNotification *)aNotification
{
	SBDownload *item = [[aNotification userInfo] objectForKey:kSBDownloadsItem];
	SBDownloadsView *downloadsView = (SBDownloadsView *)sidebar.drawer.view;
	if (downloadsView)
	{
		if (item)
		{
			[downloadsView failForItem:item];
		}
	}
}

#pragma mark Menu Validation

// <# Coding #>
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	BOOL r = YES;
	SEL selector = [menuItem action];
	if (selector == @selector(about:))
	{
		r = !window.coverWindow;
	}
	else if (selector == @selector(bugReport:))
	{
		r = !window.coverWindow;
	}
	else if (selector == @selector(createNewTab:))
	{
		
	}
	else if (selector == @selector(saveDocumentAs:))
	{
		r = self.selectedWebDataSource != nil;
	}
	else if (selector == @selector(downloadFromURL:))
	{
		r = !window.coverWindow;
	}
	else if (selector == @selector(toggleAllbars:))
	{
		BOOL toolbarVisibility = [window.toolbar isVisible];
		BOOL tabbarVisibility = window.tabbarVisivility;
		BOOL shouldShow = !(toolbarVisibility && tabbarVisibility);
		[menuItem setTitle:shouldShow ? NSLocalizedString(@"Show All Bars", nil) : NSLocalizedString(@"Hide All Bars", nil)];
		r = !window.coverWindow;
	}
	else if (selector == @selector(toggleTabbar:))
	{
		[menuItem setTitle:window.tabbarVisivility ? NSLocalizedString(@"Hide Tabbar", nil) : NSLocalizedString(@"Show Tabbar", nil)];
		r = !window.coverWindow;
	}
	else if (selector == @selector(sidebarPositionToLeft:))
	{
		[menuItem setState:splitView.sidebarPosition == SBSidebarLeftPosition ? NSOnState : NSOffState];
	}
	else if (selector == @selector(sidebarPositionToRight:))
	{
		[menuItem setState:splitView.sidebarPosition == SBSidebarRightPosition ? NSOnState : NSOffState];
	}
	else if (selector == @selector(reload:))
	{
		
	}
	else if (selector == @selector(stopLoading:))
	{
		r = [[self selectedWebView] isLoading];
	}
	else if (selector == @selector(selectUserAgent:))
	{
		r = !window.coverWindow;
	}
	else if (selector == @selector(scaleToActualSizeForView:))
	{
		WebView *webView = [self selectedWebView];
		if ([webView respondsToSelector:@selector(canResetPageZoom)])
		{
			r = [webView canResetPageZoom];
		}
		else {
			r = NO;
		}
	}
	else if (selector == @selector(showHistory:))
	{
		r = !window.coverWindow;
	}
	else if (selector == @selector(zoomInView:))
	{
		WebView *webView = [self selectedWebView];
		if ([webView respondsToSelector:@selector(canZoomPageIn)])
		{
			r = [webView canZoomPageIn];
		}
		else {
			r = NO;
		}
	}
	else if (selector == @selector(zoomOutView:))
	{
		WebView *webView = [self selectedWebView];
		if ([webView respondsToSelector:@selector(canZoomPageOut)])
		{
			r = [webView canZoomPageOut];
		}
		else {
			r = NO;
		}
	}
	else if (selector == @selector(scaleToActualSizeForText:))
	{
		WebView *webView = [self selectedWebView];
		if (webView)
		{
			r = [webView canMakeTextStandardSize];
		}
		else {
			r = NO;
		}
	}
	else if (selector == @selector(zoomInText:))
	{
		WebView *webView = [self selectedWebView];
		if (webView)
		{
			r = [webView canMakeTextLarger];
		}
		else {
			r = NO;
		}
	}
	else if (selector == @selector(zoomOutText:))
	{
		WebView *webView = [self selectedWebView];
		if (webView)
		{
			r = [webView canMakeTextSmaller];
		}
		else {
			r = NO;
		}
	}
	else if (selector == @selector(source:))
	{
		[menuItem setTitle:self.selectedTabViewItem.showSource ? NSLocalizedString(@"Hide Source", nil) : NSLocalizedString(@"Show Source", nil)];
	}
	else if (selector == @selector(resources:))
	{
		SBWebResourcesView *resourcesView = self.resourcesView;
		[menuItem setTitle:(splitView.visibleSidebar && resourcesView) ? NSLocalizedString(@"Hide Resources", nil) : NSLocalizedString(@"Show Resources", nil)];
	}
	else if (selector == @selector(showWebInspector:))
	{
		r = [[NSUserDefaults standardUserDefaults] boolForKey:kWebKitDeveloperExtras] && ![[self selectedWebView] isEmpty];
	}
	else if (selector == @selector(showConsole:))
	{
		r = [[NSUserDefaults standardUserDefaults] boolForKey:kWebKitDeveloperExtras] && ![[self selectedWebView] isEmpty];
	}
	else if (selector == @selector(backward:))
	{
		WebView *webView = [self selectedWebView];
		if (webView)
		{
			r = [webView canGoBack];
		}
		else {
			r = NO;
		}
	}
	else if (selector == @selector(forward:))
	{
		WebView *webView = [self selectedWebView];
		if (webView)
		{
			r = [webView canGoForward];
		}
		else {
			r = NO;
		}
	}
	else if (selector == @selector(bookmarks:))
	{
		SBBookmarksView *bookmarksView = [sidebar.view isKindOfClass:[SBBookmarksView class]] ? (SBBookmarksView *)sidebar.view : nil;
		[menuItem setTitle:(splitView.visibleSidebar && bookmarksView) ? NSLocalizedString(@"Hide All Bookmarks", nil) : NSLocalizedString(@"Show All Bookmarks", nil)];
		r = !window.coverWindow;
	}
	else if (selector == @selector(bookmark:))
	{
		r = ![[self selectedWebView] isEmpty] && !window.coverWindow;
	}
	else if (selector == @selector(searchInBookmarks:))
	{
		SBBookmarksView *bookmarksView = [sidebar.view isKindOfClass:[SBBookmarksView class]] ? (SBBookmarksView *)sidebar.view : nil;
		r = (bookmarksView != nil);
	}
	else if (selector == @selector(switchToIconMode:))
	{
		SBBookmarksView *bookmarksView = [sidebar.view isKindOfClass:[SBBookmarksView class]] ? (SBBookmarksView *)sidebar.view : nil;
		r = splitView.visibleSidebar && sidebar && bookmarksView;
		[menuItem setState:bookmarksView.mode == SBBookmarkIconMode ? NSOnState : NSOffState];
	}
	else if (selector == @selector(switchToListMode:))
	{
		SBBookmarksView *bookmarksView = [sidebar.view isKindOfClass:[SBBookmarksView class]] ? (SBBookmarksView *)sidebar.view : nil;
		r = splitView.visibleSidebar && sidebar && bookmarksView;
		[menuItem setState:bookmarksView.mode == SBBookmarkListMode ? NSOnState : NSOffState];
	}
	else if (selector == @selector(switchToTileMode:))
	{
		SBBookmarksView *bookmarksView = [sidebar.view isKindOfClass:[SBBookmarksView class]] ? (SBBookmarksView *)sidebar.view : nil;
		r = splitView.visibleSidebar && sidebar && bookmarksView;
		[menuItem setState:bookmarksView.mode == SBBookmarkTileMode ? NSOnState : NSOffState];
	}
	else if (selector == @selector(selectPreviousTab:))
	{
		
	}
	else if (selector == @selector(selectNextTab:))
	{
		
	}
	return r;
}

#pragma mark Toolbar Validation

- (BOOL)validateToolbarItem:(NSToolbarItem *)item
{
	BOOL r = YES;
	NSString *itemIdentifier = [item itemIdentifier];
	if ([itemIdentifier isEqualToString:kSBToolbarURLFieldItemIdentifier])
	{
		
	}
	else if ([itemIdentifier isEqualToString:kSBToolbarLoadItemIdentifier])
	{
		
	}
	else if ([itemIdentifier isEqualToString:kSBToolbarBookmarkItemIdentifier])
	{
		r = ![[self selectedWebView] isEmpty];
	}
	else if ([itemIdentifier isEqualToString:kSBToolbarBookmarksItemIdentifier])
	{
		SBBookmarksView *bookmarksView = [sidebar.view isKindOfClass:[SBBookmarksView class]] ? (SBBookmarksView *)sidebar.view : nil;
		SBBookmarkMode mode = bookmarksView ? bookmarksView.mode : SBBookmarkIconMode;
		[item setImage:[NSImage imageNamed:mode == SBBookmarkIconMode || mode == SBBookmarkTileMode ? @"Bookmarks-Icon" : @"Bookmarks-List"]];
	}
	else if ([itemIdentifier isEqualToString:kSBToolbarSnapshotItemIdentifier])
	{
		r = ![[self selectedWebView] isEmpty];
	}
	else if ([itemIdentifier isEqualToString:kSBToolbarHomeItemIdentifier])
	{
		NSString *homepage = [[NSUserDefaults standardUserDefaults] objectForKey:kSBHomePage];
		r = [homepage length] > 0;
	}
	else if ([itemIdentifier isEqualToString:kSBToolbarSourceItemIdentifier])
	{
		
	}
	else if ([itemIdentifier isEqualToString:kSBToolbarBugsItemIdentifier])
	{
		
	}
	else if ([itemIdentifier isEqualToString:kSBToolbarUserAgentItemIdentifier])
	{
		
	}
	return r;
}

#pragma mark Update

- (void)updateMenuWithTag:(NSInteger)tag
{
	NSMenu *menu = SBMenuWithTag(tag);
	if (menu)
		[menu update];
}

- (void)updateResourcesViewIfNeeded
{
	SBWebResourcesView *resourcesView = nil;
	if ((resourcesView = self.resourcesView))
	{
		[resourcesView reload];
	}
}

- (void)updateURLFieldGoogleSuggest
{
	NSString *string = [urlField stringValue];
	NSString *URLString = [string length] > 0 ? [[NSString stringWithFormat:kSBGoogleSuggestURL, string] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] : nil;
	NSURL *url = URLString ? [NSURL URLWithString:URLString] : nil;
	SBDownloader *downloader = [SBDownloader downloadWithURL:url];
	downloader.delegate = self;
	[downloader start];
}

- (void)updateURLFieldGoogleSuggestDidEnd:(NSData *)data
{
	if (data && [urlField isFirstResponder])
	{
		SBGoogleSuggestParser *parser = [SBGoogleSuggestParser parser];
		NSError *error = [parser parseData:data];
		NSMutableArray *items = !error ? [[parser.items mutableCopy] autorelease] : nil;
		// Parse XML
		if ([items count] > 0)
		{
			urlField.gsItems = items;
			if ([urlField.gsItems count] > 0)
			{
				[urlField.gsItems insertObject:[NSDictionary dictionaryWithObjectsAndKeys:
												[[NSImage imageNamed:@"Icon_G.png"] TIFFRepresentation], kSBImage, 
												NSLocalizedString(@"Suggestions", nil), kSBTitle, 
												[NSNumber numberWithInteger:kSBURLFieldItemNoneType], kSBType, nil] atIndex:0];
			}
			urlField.items = [NSMutableArray mutableArrayWithArrays:[NSArray arrayWithObjects:urlField.gsItems, urlField.bmItems, urlField.hItems, nil]];
		}
		else {
			urlField.gsItems = nil;
		}
		
		[urlField appearSheetIfNeeded:YES];
	}
}

- (void)updateURLFieldCompletionList
{
	NSMutableArray *bmItems = [NSMutableArray arrayWithCapacity:0];
	NSMutableArray *hItems = [NSMutableArray arrayWithCapacity:0];
	NSMutableArray *urlStrings = [NSMutableArray arrayWithCapacity:0];
	NSString *string = [urlField stringValue];
	SBBookmarks *bookmarks = [SBBookmarks sharedBookmarks];
	SBHistory *history = [SBHistory sharedHistory];
	
	// Search in bookmarks
	for (NSDictionary *bookmarkItem in bookmarks.items)
	{
		NSString *urlString = nil;
		if ((urlString = [bookmarkItem objectForKey:kSBBookmarkURL]))
		{
			NSString *title = [bookmarkItem objectForKey:kSBBookmarkTitle];
			NSString *SchemelessUrlString = [urlString stringByDeletingScheme];
			NSRange range = [title rangeOfString:string options:NSCaseInsensitiveSearch];
			BOOL matchWithTitle = NO;
			if (range.location == NSNotFound)
			{
				range = [urlString rangeOfString:string];
			}
			else {
				// Match with title
				matchWithTitle = title != nil;
			}
			if (range.location == NSNotFound)
			{
				range = [SchemelessUrlString rangeOfString:string];
			}
			if (range.location != NSNotFound)
			{
				NSMutableDictionary *item = [NSMutableDictionary dictionaryWithCapacity:0];
				if (matchWithTitle)
					[item setObject:title forKey:kSBTitle];
				[item setObject:urlString forKey:kSBURL];
				if ([bookmarkItem objectForKey:kSBBookmarkImage])
				{
					[item setObject:[bookmarkItem objectForKey:kSBBookmarkImage] forKey:kSBImage];
				}
				[item setObject:[NSNumber numberWithInteger:kSBURLFieldItemBookmarkType] forKey:kSBType];
				[bmItems addObject:[[item copy] autorelease]];
				[urlStrings addObject:urlString];
			}
		}
	}
	
	// Search in history
	for (WebHistoryItem *historyItem in history.items)
	{
		NSString *urlString = nil;
		if ((urlString = [historyItem URLString]))
		{
			if (![urlStrings containsObject:urlString])
			{
				NSString *SchemelessUrlString = [urlString stringByDeletingScheme];
				NSRange range = [urlString rangeOfString:string];
				if (range.location == NSNotFound)
				{
					range = [SchemelessUrlString rangeOfString:string];
				}
				if (range.location != NSNotFound)
				{
					NSMutableDictionary *item = [NSMutableDictionary dictionaryWithCapacity:0];
					NSData *iconData = [historyItem icon] ? [[historyItem icon] TIFFRepresentation] : nil;
					[item setObject:urlString forKey:kSBURL];
					if (iconData)
					{
						[item setObject:iconData forKey:kSBImage];
					}
					[item setObject:[NSNumber numberWithInteger:kSBURLFieldItemHistoryType] forKey:kSBType];
					[hItems addObject:[[item copy] autorelease]];
				}
			}
		}
	}
	
	urlField.bmItems = bmItems;
	urlField.hItems = hItems;
	if ([urlField.bmItems count] > 0)
	{
		[urlField.bmItems insertObject:[NSDictionary dictionaryWithObjectsAndKeys:
										[[NSImage imageNamed:@"Icon_Bookmarks.png"] TIFFRepresentation], kSBImage, 
										NSLocalizedString(@"Bookmarks", nil), kSBTitle, 
										[NSNumber numberWithInteger:kSBURLFieldItemNoneType], kSBType, nil] atIndex:0];
	}
	if ([urlField.hItems count] > 0)
	{
		[urlField.hItems insertObject:[NSDictionary dictionaryWithObjectsAndKeys:
									   [[NSImage imageNamed:@"Icon_History.png"] TIFFRepresentation], kSBImage, 
										NSLocalizedString(@"History", nil), kSBTitle, 
										[NSNumber numberWithInteger:kSBURLFieldItemNoneType], kSBType, nil] atIndex:0];
	}
	urlField.items = [NSMutableArray mutableArrayWithArrays:[NSArray arrayWithObjects:urlField.bmItems, urlField.hItems, nil]];
}

#pragma mark Actions

- (void)performCloseFromButton:(id)sender
{
	tabView.delegate = nil;
	[tabView closeAllTabViewItem];	// For destructing flash in the webViews
	[self close];
}

- (void)performClose:(id)sender
{
	BOOL should = [self shouldCloseDocument];
	if (should)
	{
		[self close];
	}
}

- (BOOL)shouldCloseDocument
{
	BOOL should = YES;
	if ([self tabCount] <= 1)
	{
	}
	else {
		[tabbar closeSelectedItem];
		should = NO;
	}
	if (should)
	{
		tabView.delegate = nil;
		[tabView closeAllTabViewItem];	// For destructing flash in the webViews
	}
	return should;
}

- (void)openAndConstructTabWithURLs:(NSArray *)urls startInTabbarItem:(SBTabbarItem *)aTabbarItem
{
	NSInteger i = 0;
	SBTabViewItem *tabViewItem = [tabView tabViewItemWithIdentifier:[aTabbarItem identifier]];
	if ([urlField isFirstResponder])
	{
		[self.window makeFirstResponder:[self selectedWebView]];
	}
	for (NSURL *url in urls)
	{
		if (i == 0 && tabViewItem)
		{
			[tabbar selectItem:aTabbarItem];
			[tabViewItem setURL:url];
			[tabView selectTabViewItem:tabViewItem];
		}
		else {
			[self constructNewTabWithURL:url selection:NO];
		}
		i++;
	}
}

- (void)openAndConstructTabWithBookmarkItems:(NSArray *)items
{
	NSInteger i = 0;
	NSInteger count = [items count];
	if (count > kSBDocumentWarningNumberOfBookmarksForOpening)
	{
		NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to open %d items?", nil), count];
		NSAlert *alert = [NSAlert alertWithMessageText:nil defaultButton:NSLocalizedString(@"OK", nil) alternateButton:NSLocalizedString(@"Cancel", nil) otherButton:nil informativeTextWithFormat:message, nil];
		if ([alert runModal] == NSAlertAlternateReturn)
		{
			return;
		}
	}
	if ([urlField isFirstResponder])
	{
		[self.window makeFirstResponder:[self selectedWebView]];
	}
	for (i = 0; i < count; i++)
	{
		NSDictionary *item = [items objectAtIndex:i];
		NSString *URLString = [item objectForKey:kSBBookmarkURL];
		if (URLString)
		{
			if (i == 0)
			{
				[self openURLStringInSelectedTabViewItem:URLString];
			}
			else {
				[self constructNewTabWithURL:[NSURL URLWithString:URLString] selection:NO];
			}
		}
	}
}

- (void)adjustSplitViewIfNeeded
{
	SBBookmarksView *bookmarksView = [sidebar.view isKindOfClass:[SBBookmarksView class]] ? (SBBookmarksView *)sidebar.view : nil;
	if (bookmarksView.mode == SBBookmarkTileMode)
	{
		NSRect viewRect = splitView.view.frame;
		CGFloat pos = [self adjustedSplitPositon:viewRect.size.width];
		[splitView setPosition:pos ofDividerAtIndex:0];
	}
}

#pragma mark Menu Actions

- (void)printDocument:(id)sender
{
	WebView *webView = [[self selectedTabViewItem] webView];
	if (webView)
	{
		NSPrintOperation *printOperation;
		NSView *view = [[[webView mainFrame] frameView] documentView];
		printOperation = [NSPrintOperation printOperationWithView:view];
		[printOperation setShowsPrintPanel:YES];
		[printOperation runOperation];
	}
}

#pragma mark Application menu

- (void)about:(id)sender
{
	if (!window.coverWindow && !window.backWindow)
	{
		SBAboutView *aboutView = [SBAboutView sharedView];
		aboutView.target = self;
		aboutView.cancelSelector = @selector(doneAbout);
		[window flip:aboutView];
	}
	else {
		[window.backWindow makeKeyWindow];
	}
}

- (void)doneAbout
{
	[window doneFlip];
}

// File menu

- (void)createNewTab:(id)sender
{
	NSString *homepage = [[SBPreferences sharedPreferences] homepage:NO];
	if (!self.window.tabbarVisivility && [tabbar.items count] > 0)
		[self showTabbar];
	[self constructNewTabWithString:homepage selection:YES];
}

- (void)openLocation:(id)sender
{
	[self selectURLField];
}

- (void)saveDocumentAs:(id)sender
{
	SBSavePanel *panel = [SBSavePanel savePanel];
	NSString *title = self.selectedWebDataSource.pageTitle;
	NSString *name = [title ? title : NSLocalizedString(@"Untitled", nil) stringByAppendingPathExtension:@"webarchive"];
	[panel beginSheetForDirectory:nil file:name modalForWindow:self.window modalDelegate:self didEndSelector:@selector(saveDocumentAsDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)saveDocumentAsDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSOKButton)
	{
		WebDataSource *dataSource = self.selectedWebDataSource;
		WebArchive *archive = dataSource ? dataSource.webArchive : nil;
		NSData *data = archive ? [archive data] : nil;
		if (data)
		{
			if ([data writeToFile:[sheet filename] atomically:YES])
			{
				
			}
		}
	}
}

- (void)downloadFromURL:(id)sender
{
	if (!window.coverWindow)
	{
		[self destructDownloaderView];
		downloaderView = [[SBDownloaderView alloc] initWithFrame:NSMakeRect(0, 0, 800, 240)];
		downloaderView.message = NSLocalizedString(@"Download any file from typed URL.", nil);
		downloaderView.target = self;
		downloaderView.doneSelector = @selector(doneDownloader);
		downloaderView.cancelSelector = @selector(cancelDownloader);
		[window showCoverWindow:downloaderView];
		[downloaderView makeFirstResponderToURLField];
	}
	else {
		[window.coverWindow makeKeyWindow];
	}
}

- (void)doneDownloader
{
	NSString *urlString = [downloaderView urlString];
	NSURL *url = [urlString length] > 0 ? [NSURL URLWithString:urlString] : nil;
	if (url)
	{
		[self startDownloadingForURL:url];
	}
	else {
		// Error
	}
	[window hideCoverWindow];
	[self destructDownloaderView];
}

- (void)cancelDownloader
{
	[window hideCoverWindow];
	[self destructDownloaderView];
}

- (void)snapshot:(id)sender
{
	if (!window.coverWindow)
	{
		NSImage *image = [self selectedWebViewImage];
		NSRect visibleRect = [self visibleRectOfSelectedWebDocumentView];
		[self destructSnapshotView];
		snapshotView = [[SBSnapshotView alloc] initWithFrame:[window splitViewRect]];
		[snapshotView setVisibleRect:visibleRect];
		snapshotView.title = self.selectedTabViewItem.pageTitle;
		if ([snapshotView setImage:image])
		{
			snapshotView.target = self;
			snapshotView.doneSelector = @selector(doneSnapshot);
			snapshotView.cancelSelector = @selector(cancelSnapshot);
			[window showCoverWindow:snapshotView];
		}
	}
	else {
		[window.coverWindow makeKeyWindow];
	}
}

- (void)doneSnapshot
{
	[window hideCoverWindow];
	[self destructSnapshotView];
}

- (void)cancelSnapshot
{
	[window hideCoverWindow];
	[self destructSnapshotView];
}

// View menu

- (void)toggleAllbars:(id)sender
{
	BOOL toolbarVisibility = [window.toolbar isVisible];
	BOOL tabbarVisibility = window.tabbarVisivility;
	BOOL shouldShow = !(toolbarVisibility && tabbarVisibility);
	if (shouldShow)
	{
		[self showAllbars];
	}
	else {
		[self hideAllbars];
	}
}

- (void)toggleTabbar:(id)sender
{
	NSMenuItem *menuItem = (NSMenuItem *)sender;
	[self toggleTabbar];
	[menuItem setTitle:self.window.tabbarVisivility ? NSLocalizedString(@"Hide Tabbar", nil) : NSLocalizedString(@"Show Tabbar", nil)];
	[[NSUserDefaults standardUserDefaults] setBool:self.window.tabbarVisivility forKey:kSBTabbarVisibilityFlag];
}

- (void)sidebarPositionToLeft:(id)sender
{
	SBSidebarPosition position = SBSidebarLeftPosition;
	if (splitView.sidebarPosition != position)
	{
		splitView.sidebarPosition = position;
		[[NSUserDefaults standardUserDefaults] setInteger:position forKey:kSBSidebarPosition];
	}
}

- (void)sidebarPositionToRight:(id)sender
{
	SBSidebarPosition position = SBSidebarRightPosition;
	if (splitView.sidebarPosition != position)
	{
		splitView.sidebarPosition = position;
		[[NSUserDefaults standardUserDefaults] setInteger:position forKey:kSBSidebarPosition];
	}
}

- (void)reload:(id)sender
{
	SBWebView *webView = nil;
	if ((webView = [self selectedWebView]))
	{
		if ([webView isLoading])
			[webView stopLoading:nil];
		[webView reload:nil];
	}
}

- (void)stopLoading:(id)sender
{
	SBWebView *webView = nil;
	if ((webView = [self selectedWebView]))
		[webView stopLoading:nil];
}

- (void)scaleToActualSizeForView:(id)sender
{
	WebView *webView = [self selectedWebView];
	if ([webView respondsToSelector:@selector(resetPageZoom:)])
	{
		[webView resetPageZoom:nil];
	}
}

- (void)zoomInView:(id)sender
{
	WebView *webView = [self selectedWebView];
	if ([webView respondsToSelector:@selector(zoomPageIn:)])
	{
		[webView zoomPageIn:nil];
	}
}

- (void)zoomOutView:(id)sender
{
	WebView *webView = [self selectedWebView];
	if ([webView respondsToSelector:@selector(zoomPageOut:)])
	{
		[webView zoomPageOut:nil];
	}
}

- (void)scaleToActualSizeForText:(id)sender
{
	SBWebView *webView = nil;
	if ((webView = [self selectedWebView]))
		[webView makeTextStandardSize:nil];
}

- (void)zoomInText:(id)sender
{
	SBWebView *webView = nil;
	if ((webView = [self selectedWebView]))
		[webView makeTextLarger:nil];
}

- (void)zoomOutText:(id)sender
{
	SBWebView *webView = nil;
	if ((webView = [self selectedWebView]))
		[webView makeTextSmaller:nil];
}

- (void)source:(id)sender
{
	[self.selectedTabViewItem toggleShowSource];
}

- (void)resources:(id)sender
{
	SBWebResourcesView *resourcesView = self.resourcesView;
	if (splitView.visibleSidebar && sidebar)
	{
		if (resourcesView)
		{
			[self hideSidebar];
		}
		else {
			resourcesView = [[[SBWebResourcesView alloc] initWithFrame:[sidebar viewRect]] autorelease];
			resourcesView.dataSource = self;
			resourcesView.delegate = self;
			sidebar.view = resourcesView;
		}
	}
	else {
		[self showSidebar];
		resourcesView = [[[SBWebResourcesView alloc] initWithFrame:[sidebar viewRect]] autorelease];
		resourcesView.dataSource = self;
		resourcesView.delegate = self;
		sidebar.view = resourcesView;
	}
}

- (void)showWebInspector:(id)sender
{
	SBWebView *webView = nil;
	if ((webView = [self selectedWebView]))
		[webView showWebInspector:nil];
}

- (void)showConsole:(id)sender
{
	SBWebView *webView = nil;
	if ((webView = [self selectedWebView]))
	{
		[webView showConsole:nil];
	}
}

// History menu

- (void)backward:(id)sender
{
	SBTabViewItem *tabViewItem = nil;
	if ((tabViewItem = [tabView selectedTabViewItem]))
	{
		[tabViewItem backward:nil];
	}
}

- (void)forward:(id)sender
{
	SBTabViewItem *tabViewItem = nil;
	if ((tabViewItem = [tabView selectedTabViewItem]))
	{
		[tabViewItem forward:nil];
	}
}

- (void)showHistory:(id)sender
{
	if (!window.coverWindow)
	{
		[self destructHistoryView];
		historyView = [[SBHistoryView alloc] initWithFrame:[window splitViewRect]];
		historyView.message = NSLocalizedString(@"History", nil);
		historyView.target = self;
		historyView.doneSelector = @selector(doneHistory:);
		historyView.cancelSelector = @selector(cancelHistory);
		[window showCoverWindow:historyView];
	}
	else {
		[window.coverWindow makeKeyWindow];
	}
}

- (void)doneHistory:(NSArray *)urls
{
	if ([urls count] > 0)
	{
		[self openAndConstructTabWithURLs:urls startInTabbarItem:tabbar.selectedTabbarItem];
	}
	[window hideCoverWindow];
	[self destructHistoryView];
}

- (void)cancelHistory
{
	[window hideCoverWindow];
	[self destructHistoryView];
}

- (void)openHome:(id)sender
{
	NSString *homepage = [[NSUserDefaults standardUserDefaults] objectForKey:kSBHomePage];
	homepage = [homepage length] > 0 ? [homepage requestURLString] : nil;
	if (homepage)
	{
		if ([urlField isFirstResponder])
		{
			[self.window makeFirstResponder:[self selectedWebView]];
		}
		[self openURLStringInSelectedTabViewItem:homepage];
	}
}

// Bookmarks menu

- (void)bookmarks:(id)sender
{
	if (splitView.visibleSidebar && sidebar)
	{
		SBBookmarksView *bookmarksView = [sidebar.view isKindOfClass:[SBBookmarksView class]] ? (SBBookmarksView *)sidebar.view : nil;
		if (bookmarksView)
		{
			[self hideSidebar];
		}
		else {
			if ((bookmarksView = [self constructBookmarksView]))
			{
				sidebar.view = bookmarksView;
			}
		}
	}
	else {
		[self showSidebar];
	}
}

- (void)bookmark:(id)sender
{
	if (!window.coverWindow)
	{
		NSImage *image = self.selectedWebViewImageForBookmark;
		NSString *urlString = [self.selectedTabViewItem mainFrameURLString];
		if (image && urlString)
		{
			SBBookmarks *bookmarks = [SBBookmarks sharedBookmarks];
			BOOL containsURL = [bookmarks containsURL:urlString];
			[self destructBookmarkView];
			bookmarkView = [[SBBookmarkView alloc] initWithFrame:NSMakeRect(0, 0, 880, 480)];
			bookmarkView.image = image;
			bookmarkView.message = containsURL ? NSLocalizedString(@"This page is already added to bookmarks. \nAre you sure you want to update it?", nil) : NSLocalizedString(@"Are you sure you want to bookmark this page?", nil);
			bookmarkView.title = window.title;
			bookmarkView.urlString = urlString;
			bookmarkView.target = self;
			bookmarkView.doneSelector = @selector(doneBookmark);
			bookmarkView.cancelSelector = @selector(cancelBookmark);
			[window showCoverWindow:bookmarkView];
			[bookmarkView makeFirstResponderToTitleField];
		}
	}
	else {
		[window.coverWindow makeKeyWindow];
	}
}

- (void)doneBookmark
{
	SBBookmarks *bookmarks = [SBBookmarks sharedBookmarks];
	NSDictionary *item = [bookmarkView itemRepresentation];
	[bookmarks addItem:item];
	[self destructBookmarkView];
	[window hideCoverWindow];
	SBBookmarksView *bookmarksView = [sidebar.view isKindOfClass:[SBBookmarksView class]] ? (SBBookmarksView *)sidebar.view : nil;
	if (bookmarksView)
	{
		[bookmarksView addForBookmarkItem:item];
		[(SBBookmarksView *)sidebar.view scrollToItem:item];
	}
}

- (void)cancelBookmark
{
	[window hideCoverWindow];
	[self destructBookmarkView];
}

- (void)editBookmarkItemAtIndex:(NSUInteger)index
{
	if (!window.coverWindow)
	{
		SBBookmarks *bookmarks = [SBBookmarks sharedBookmarks];
		NSDictionary *item = [bookmarks itemAtIndex:index];
		if (item)
		{
			NSData *imageData = nil;
			NSImage *image = nil;
			NSString *title = nil;
			NSString *urlString = nil;
			NSString *labelName = nil;
			[self destructEditBookmarkView];
			editBookmarkView = [[SBEditBookmarkView alloc] initWithFrame:NSMakeRect(0, 0, 880, 480)];
			imageData = [item objectForKey:kSBBookmarkImage];
			image = imageData ? [[[NSImage alloc] initWithData:imageData] autorelease] : nil;
			title = [item objectForKey:kSBBookmarkTitle];
			urlString = [item objectForKey:kSBBookmarkURL];
			labelName = [item objectForKey:kSBBookmarkLabelName];
			editBookmarkView.index = index;
			editBookmarkView.image = image;
			editBookmarkView.title = title;
			editBookmarkView.urlString = urlString;
			editBookmarkView.labelName = labelName;
			editBookmarkView.target = self;
			editBookmarkView.doneSelector = @selector(doneEditBookmark);
			editBookmarkView.cancelSelector = @selector(cancelEditBookmark);
			[window showCoverWindow:editBookmarkView];
			[editBookmarkView makeFirstResponderToTitleField];
		}
	}
	else {
		[window.coverWindow makeKeyWindow];
	}
}

- (void)doneEditBookmark
{
	SBBookmarks *bookmarks = [SBBookmarks sharedBookmarks];
	NSDictionary *item = [editBookmarkView itemRepresentation];
	NSUInteger index = editBookmarkView.index;
	[bookmarks replaceItem:item atIndex:index];
	[self destructEditBookmarkView];
	[window hideCoverWindow];
}

- (void)cancelEditBookmark
{
	[window hideCoverWindow];
	[self destructEditBookmarkView];
}

- (void)searchInBookmarks:(id)sender
{
	SBBookmarksView *bookmarksView = [sidebar.view isKindOfClass:[SBBookmarksView class]] ? (SBBookmarksView *)sidebar.view : nil;
	if (bookmarksView)
	{
		[bookmarksView setShowSearchbar:YES];
	}
}

- (void)switchToIconMode:(id)sender
{
	SBBookmarksView *bookmarksView = [sidebar.view isKindOfClass:[SBBookmarksView class]] ? (SBBookmarksView *)sidebar.view : nil;
	if (bookmarksView)
	{
		bookmarksView.mode = SBBookmarkIconMode;
	}
}

- (void)switchToListMode:(id)sender
{
	SBBookmarksView *bookmarksView = [sidebar.view isKindOfClass:[SBBookmarksView class]] ? (SBBookmarksView *)sidebar.view : nil;
	if (bookmarksView)
	{
		bookmarksView.mode = SBBookmarkListMode;
	}
}

- (void)switchToTileMode:(id)sender
{
	SBBookmarksView *bookmarksView = [sidebar.view isKindOfClass:[SBBookmarksView class]] ? (SBBookmarksView *)sidebar.view : nil;
	if (bookmarksView)
	{
		bookmarksView.mode = SBBookmarkTileMode;
		[self adjustSplitViewIfNeeded];
	}
}

// Window menu

- (void)selectPreviousTab:(id)sender
{
	[tabbar selectPreviousItem];
}

- (void)selectNextTab:(id)sender
{
	[tabbar selectNextItem];
}

- (void)downloads:(id)sender
{
	SBDownloadsView *downloadsView = (SBDownloadsView *)sidebar.drawer.view;
	
	if (!splitView.visibleSidebar)
	{
		[self showSidebar];
	}
	if (!sidebar.visibleDrawer)
	{
		[self showDrawer];
	}
	if (downloadsView)
	{
		
	}
	else {
		[self constructDownloadsViewInSidebar];
	}
}

#pragma mark Toolbar Actions

- (void)openURLFromField:(id)sender
{
	[self openString:[urlField stringValue] newTab:NO];
}

- (void)openURLInNewTabFromField:(id)sender
{
	[self openString:[urlField stringValue] newTab:YES];
}

- (void)openString:(NSString *)stringValue newTab:(BOOL)newer
{
	if (stringValue)
	{
		NSString *requestURLString = [stringValue requestURLString];
		if (newer)
		{
			NSURL *URL = [requestURLString length] > 0 ? [NSURL URLWithString:requestURLString] : nil;
			[self constructNewTabWithURL:URL selection:YES];
		}
		else {
			[self openURLStringInSelectedTabViewItem:requestURLString];
		}
	}
}

- (void)searchString:(NSString *)stringValue newTab:(BOOL)newer
{
	if (stringValue)
	{
		NSString *searchURLString = [stringValue searchURLString];
		if (newer)
		{
			NSURL *URL = [searchURLString length] > 0 ? [NSURL URLWithString:searchURLString] : nil;
			[self constructNewTabWithURL:URL selection:YES];
		}
		else {
			[self openURLStringInSelectedTabViewItem:searchURLString];
		}
	}
}

- (void)changeEncodingFromMenuItem:(id)sender
{
	NSMenuItem *item = (NSMenuItem *)sender;
	NSString *ianaName = (NSString *)[item representedObject];
	SBWebView *webView = [self selectedWebView];
	[webView setCustomTextEncodingName:ianaName];
}

- (void)load:(id)sender
{
	WebView *webView = [self selectedWebView];
	BOOL loading = [webView isLoading];
	if (loading)
	{
		[webView stopLoading:nil];
	}
	else {
		[webView reload:nil];
	}
}

- (void)bugReport:(id)sender
{
	if (!window.coverWindow)
	{
		[self destructReportView];
		reportView = [[SBReportView alloc] initWithFrame:[window splitViewRect]];
		reportView.target = self;
		reportView.doneSelector = @selector(doneReport);
		reportView.cancelSelector = @selector(cancelReport);
		[window showCoverWindow:reportView];
	}
	else {
		[window.coverWindow makeKeyWindow];
	}
}

- (void)doneReport
{
	[window hideCoverWindow];
	[self destructReportView];
}

- (void)cancelReport
{
	[window hideCoverWindow];
	[self destructReportView];
}

- (void)selectUserAgent:(id)sender
{
	if (!window.coverWindow && !window.backWindow)
	{
		[self destructUserAgentView];
		userAgentView = [[SBUserAgentView alloc] initWithFrame:NSMakeRect(0, 0, 800, 240)];
		userAgentView.target = self;
		userAgentView.doneSelector = @selector(doneUserAgent);
		userAgentView.cancelSelector = @selector(cancelUserAgent);
		[window flip:userAgentView];
	}
	else {
		[window.backWindow makeKeyWindow];
	}
}

- (void)doneUserAgent
{
	[window doneFlip];
	[self destructUserAgentView];
	[self.selectedTabViewItem setUserAgent];
	[self.selectedWebView reload:nil];
}

- (void)cancelUserAgent
{
	[window doneFlip];
	[self destructUserAgentView];
}

#pragma mark Actions

- (void)openURLStringInSelectedTabViewItem:(NSString *)stringValue
{
	[tabView openURLInSelectedTabViewItem:stringValue];
}

- (void)selectURLField
{
	if (![self.window.toolbar isVisible])
	{
		[self.window showToolbar];
	}
	[urlField selectText:nil];
}

- (void)startDownloadingForURL:(NSURL *)URL
{
	if (URL)
	{
		SBDownloads *downloads = nil;
		downloads = [SBDownloads sharedDownloads];
		[downloads addItemWithURL:URL];
	}
}

- (void)toggleAllbarsAndSidebar
{
	BOOL visibleToolbar = [window.toolbar isVisible];
	BOOL visibleTabbar = window.tabbarVisivility;
	BOOL visibleSidebar = splitView.visibleSidebar && sidebar;
	if (visibleToolbar && visibleTabbar && visibleSidebar)
	{
		[self hideAllbars];
		[self hideSidebar];
	}
	else {
		[self showAllbars];
		[self showSidebar];
	}
}

- (void)hideAllbars
{
	[self hideTabbar];
	[self hideToolbar];
}

- (void)showAllbars
{
	[self showTabbar];
	[self showToolbar];
}

- (void)hideToolbar
{
	[self.window hideToolbar];
}

- (void)showToolbar
{
	[self.window showToolbar];
}

- (void)toggleTabbar
{
	if (self.window.tabbarVisivility)
	{
		[self hideTabbar];
	}
	else {
		[self showTabbar];
	}
}

- (void)hideTabbar
{
	[self.window hideTabbar];
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSBTabbarVisibilityFlag];
}

- (void)showTabbar
{
	[self.window showTabbar];
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSBTabbarVisibilityFlag];
}

- (void)hideSidebar
{
	[splitView closeSidebar:nil];
}

- (void)showSidebar
{
	if (!sidebar)
	{
		sidebarVisibility = YES;
		[self constructSidebar];
	}
	[splitView openSidebar:nil];
}

- (void)hideDrawer
{
	[sidebar closeDrawer:nil];
}

- (void)showDrawer
{
	[sidebar openDrawer:nil];
}

- (void)showMessage:(NSString *)message
{
	if (!window.coverWindow)
	{
		[self destructMessageView];
		messageView = [[SBMessageView alloc] initWithFrame:NSMakeRect(0, 0, 800, 240) text:message];
		messageView.target = self;
		messageView.doneSelector = @selector(doneShowMessageView);
		[window showCoverWindow:messageView];
	}
	else {
		[window.coverWindow makeKeyWindow];
	}
}

- (void)doneShowMessageView
{
	[window hideCoverWindow];
	[self destructMessageView];
}

- (BOOL)confirmMessage:(NSString *)message
{
	BOOL r = NO;
	if (!window.coverWindow)
	{
		confirmed = -1;
		[self destructMessageView];
		messageView = [[SBMessageView alloc] initWithFrame:NSMakeRect(0, 0, 800, 240) text:message];
		messageView.target = self;
		messageView.doneSelector = @selector(doneConfirmMessageView);
		messageView.cancelSelector = @selector(cancelConfirmMessageView);
		[window showCoverWindow:messageView];
		while (confirmed == -1)
		{
			// Wait event...
			NSAutoreleasePool *pool= [[NSAutoreleasePool alloc] init];
			NSEvent *event = nil;
			event = [NSApp nextEventMatchingMask:NSAnyEventMask untilDate:[NSDate distantFuture] inMode:NSDefaultRunLoopMode dequeue:YES];
			[NSApp sendEvent:event];
			[pool release];
		}
		r = confirmed == 1;
	}
	else {
		[window.coverWindow makeKeyWindow];
	}
	return r;
}

- (void)doneConfirmMessageView
{
	confirmed = 1;
	[window hideCoverWindow];
	[self destructMessageView];
}

- (void)cancelConfirmMessageView
{
	confirmed = 0;
	[window hideCoverWindow];
	[self destructMessageView];
}

- (NSString *)textInput:(NSString *)prompt
{
	NSString *text = nil;
	if (!window.coverWindow)
	{
		confirmed = -1;
		[self destructTextInputView];
		textInputView = [[SBTextInputView alloc] initWithFrame:NSMakeRect(0, 0, 800, 320) prompt:prompt];
		textInputView.target = self;
		textInputView.doneSelector = @selector(doneTextInputView);
		textInputView.cancelSelector = @selector(cancelTextInputView);
		[window showCoverWindow:textInputView];
		while (confirmed == -1)
		{
			// Wait event...
			NSAutoreleasePool *pool= [[NSAutoreleasePool alloc] init];
			NSEvent *event = nil;
			event = [NSApp nextEventMatchingMask:NSAnyEventMask untilDate:[NSDate distantFuture] inMode:NSDefaultRunLoopMode dequeue:YES];
			[NSApp sendEvent:event];
			[pool release];
		}
		if (confirmed == 1)
		{
			text = textInputView.text;
		}
		[self destructTextInputView];
	}
	else {
		[window.coverWindow makeKeyWindow];
	}
	return text;
}

- (void)doneTextInputView
{
	confirmed = 1;
	[window hideCoverWindow];
}

- (void)cancelTextInputView
{
	confirmed = 0;
	[window hideCoverWindow];
}

- (void)toggleEditableForSelectedWebView
{
	BOOL editable = ![self.selectedWebView isEditable];
	if (editable)
	{
//		DOMCSSStyleDeclaration *style = nil;
//		DOMHTMLElement *frameElement = [[self.selectedWebView mainFrame] frameElement];
//		style = [frameElement style];
//		[style setBorderWidth:@"2px"];
//		[style setBorderStyle:@"solid"];
//		[style setBorderColor:@"red"];
//		[frameElement setstyle = style;
	}
	[self.selectedWebView setEditable:editable];
}

- (void)toggleFlip
{
	[self.window flip];
}

#pragma mark Debug

- (void)debug:(NSNumber *)value
{
	SBInnerView *innerView = self.window.innerView;
	CAKeyframeAnimation *tanimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
	NSMutableArray *tvalues = [NSMutableArray arrayWithCapacity:0];
	CATransform3D finalTransform = CATransform3DIdentity;
	CATransform3D midTransform = CATransform3DIdentity;
	CGFloat width = self.window.frame.size.width;
	finalTransform.m34 = 1.0 / - (width * 2);
	midTransform.m34 = 1.0 / - (width * 2);
	finalTransform = CATransform3DRotate(midTransform, 180 * M_PI / 180, 1.0, 0.0, 0.0);
	midTransform = CATransform3DRotate(midTransform, 90 * M_PI / 180, 1.0, 0.0, 0.0);
	if ([value boolValue])
	{
		[tvalues addObject:[NSValue valueWithCATransform3D:CATransform3DIdentity]];
		[tvalues addObject:[NSValue valueWithCATransform3D:midTransform]];
		[tvalues addObject:[NSValue valueWithCATransform3D:finalTransform]];
	}
	else {
		[tvalues addObject:[NSValue valueWithCATransform3D:finalTransform]];
		[tvalues addObject:[NSValue valueWithCATransform3D:midTransform]];
		[tvalues addObject:[NSValue valueWithCATransform3D:CATransform3DIdentity]];
	}
	tanimation.values = tvalues;
	tanimation.duration = 1.0;
//	tanimation.removedOnCompletion = NO;
//	tanimation.fillMode = kCAFillModeForwards;
	[innerView.layer removeAllAnimations];
	[innerView.layer addAnimation:tanimation forKey:@"transform"];
}

- (void)debugAddDummyDownloads:(id)sender
{
	SBDownloads *downloads = [SBDownloads sharedDownloads];
	NSArray *names = [NSArray arrayWithObjects:
					  @"Long Long File Name", 
					  @"Long File Name", 
					  @"Longfilename", 
					  @"File Name", 
					  @"Filename",  
					  @"File", 
					  @"F", nil];
	for (NSUInteger index = 0; index < [names count]; index++)
	{
		SBDownload *item = [SBDownload itemWithURL:[NSURL URLWithString:@"http://localhost/dummy"]];
		item.name = [names objectAtIndex:index];
		item.path = @"/unknown";
		[downloads addItem:item];
	}
	[self performSelector:@selector(debugAddDummyDownloadsDidEnd:) withObject:names afterDelay:0.5];
}

- (void)debugAddDummyDownloadsDidEnd:(NSArray *)names
{
	SBDownloads *downloads = [SBDownloads sharedDownloads];
	SBDownloadsView *downloadsView = (SBDownloadsView *)sidebar.drawer.view;
	for (NSUInteger index = 0; index < [names count]; index++)
	{
		SBDownload *item = [[downloads items] objectAtIndex:index];
		if (index == 0)
		{
			item.status = SBStatusUndone;
		}
		else if (index > 0)
		{
			item.expectedLength = 10000000;
			item.receivedLength = (item.expectedLength * ((CGFloat)index / (CGFloat)[names count]));
			item.status = SBStatusProcessing;
		}
		else if (index >= 1)
		{
			item.receivedLength = item.expectedLength = 10000000;
			item.status = SBStatusDone;
		}
		item.bytes = [NSString bytesString:item.receivedLength expectedLength:item.expectedLength];
		[downloadsView updateForItem:item];
	}
}

@end
