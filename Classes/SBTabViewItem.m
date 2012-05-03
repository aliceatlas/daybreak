/*

SBTabViewItem.m
 
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

#import "SBTabViewItem.h"
#import "SBBLKGUI.h"
#import "SBDownloads.h"
#import "SBDrawer.h"
#import "SBFindbar.h"
#import "SBFixedSplitView.h"
#import "SBSavePanel.h"
#import "SBTabbarItem.h"
#import "SBTabView.h"
#import "SBUtil.h"
#import "SBWebView.h"

@implementation SBTabViewItem

@dynamic view;
@synthesize splitView;
@synthesize tabbarItem;
@dynamic tabView;
@synthesize URL;
@synthesize webView;
@synthesize resourceIdentifiers;
@synthesize showSource;
@dynamic selected;
@dynamic canBackward;
@dynamic canForward;
@dynamic mainFrameURLString;
@dynamic pageTitle;
@dynamic requestURLString;
@dynamic documentSource;

- (id)initWithIdentifier:(id)identifier
{
	if (self = [super initWithIdentifier:identifier])
	{
		resourceIdentifiers = nil;
		[self constructSplitView];
	}
	return self;
}

- (void)dealloc
{
	tabbarItem = nil;
	[URL release];
	[splitView release];
	[sourceView release];
	[self destructWebView];
	[sourceTextView release];
	[webSplitView release];
	[sourceSplitView release];
	[sourceSaveButton release];
	[sourceCloseButton release];
	[super dealloc];
}

#pragma mark Getter

- (CGFloat)sourceBottomMargin
{
	return 48.0;
}

- (NSView *)view
{
	return (NSView *)[super view];
}

- (SBTabView *)tabView
{
	return (SBTabView *)[super tabView];
}

- (NSString *)URLString
{
	return [URL absoluteString];
}

- (BOOL)selected
{
	return [[self.tabView selectedTabViewItem] isEqual:self];
}

- (BOOL)canBackward
{
	return webView ? [webView canGoBack] : NO;
}

- (BOOL)canForward
{
	return webView ? [webView canGoForward] : NO;
}

- (NSString *)mainFrameURLString
{
	return [webView mainFrameURL];
}

- (NSString *)pageTitle
{
	NSString *pageTitle = nil;
	WebDataSource *dataSource = nil;
	dataSource = [[webView mainFrame] dataSource];
	pageTitle = [dataSource pageTitle];
	return pageTitle ? pageTitle : nil;
}

- (NSString *)requestURLString
{
	WebDataSource *dataSource = nil;
	NSString *urlString = nil;
	dataSource = [[webView mainFrame] dataSource];
	urlString = [[[dataSource request] URL] absoluteString];
	return urlString ? urlString : nil;
}

- (NSString *)documentSource
{
	WebDataSource *dataSource = nil;
	id<WebDocumentRepresentation> documentRep;
	NSString *documentSource = nil;
	dataSource = [[webView mainFrame] dataSource];
	if (dataSource)
	{
		documentRep = [dataSource representation];
		documentSource = [documentRep documentSource];
	}
	return documentSource;
}

- (NSMutableArray *)webFramesInFrame:(WebFrame *)frame
{
	NSMutableArray *frames = nil;
	frames = [NSMutableArray arrayWithCapacity:0];
	for (WebFrame *childFrame in [frame childFrames])
	{
		[frames addObject:childFrame];
		if ([[childFrame childFrames] count] > 0)
		{
			[frames addObjectsFromArray:[self webFramesInFrame:childFrame]];
		}
	}
	return frames;
}

#pragma mark Setter

- (void)setSelected:(BOOL)selected
{
	if (!self.selected)
	{
		[self.tabView selectTabViewItem:self];
	}
}

- (void)setView:(NSView *)view
{
	[super setView:(id)view];
}

- (void)setURL:(NSURL *)inURL
{
	if (URL != inURL)
	{
		if (URL)
		{
			[URL release];
			URL = nil;
		}
		URL = [inURL retain];
	}
	[self constructWebView];
}

- (void)setURLString:(NSString *)URLString
{
	if (URLString)
	{
		NSString *encodedString = [URLString URLEncodedString];
		[self setURL:[NSURL URLWithString:encodedString]];
	}
}

- (void)toggleShowSource
{
	[self setShowSource:!showSource];
}

- (void)hideShowSource
{
	[self setShowSource:NO];
}

- (void)setShowSource:(BOOL)inShowSource
{
	if (showSource != inShowSource)
	{
		showSource = inShowSource;
		if (showSource)
		{
			SBBLKGUIScrollView *scrollView = nil;
#if 1
			SBBLKGUIScroller *horizontalScroller = nil;
			SBBLKGUIScroller *verticalScroller = nil;
#endif
			SBBLKGUIButton *openButton = nil;
			NSRect r = [self.view bounds];
			NSRect tr = [self.view bounds];
			NSRect br = [self.view bounds];
			NSRect openRect = NSZeroRect;
			NSRect saveRect = NSZeroRect;
			NSRect closeRect = NSZeroRect;
			NSRect wr = [self.view bounds];
			NSString *sourcecode = nil;
			wr.size.height *= 0.6;
			r.size.height *= 0.4;
			br.size.height = [self sourceBottomMargin];
			tr.size.height = r.size.height - br.size.height;
			tr.origin.y = br.size.height;
			saveRect.size.width = 105.0;
			saveRect.size.height = 24.0;
			saveRect.origin.x = r.size.width - saveRect.size.width - 10.0;
			saveRect.origin.y = br.origin.y + (br.size.height - saveRect.size.height) / 2;
			openRect.size.width = 210.0;
			openRect.size.height = 24.0;
			openRect.origin.y = saveRect.origin.y;
			openRect.origin.x = saveRect.origin.x - openRect.size.width - 10.0;
			closeRect.size.width = 105.0;
			closeRect.size.height = 24.0;
			closeRect.origin.y = saveRect.origin.y;
			closeRect.origin.x = 10.0;
			sourceView = [[SBDrawer alloc] initWithFrame:r];
			scrollView = [[SBBLKGUIScrollView alloc] initWithFrame:tr];
			openButton = [[SBBLKGUIButton alloc] initWithFrame:openRect];
			sourceSaveButton = [[SBBLKGUIButton alloc] initWithFrame:saveRect];
			sourceCloseButton = [[SBBLKGUIButton alloc] initWithFrame:closeRect];
#if 1
			horizontalScroller = [scrollView horizontalScroller];
			verticalScroller = [scrollView verticalScroller];
			r.size.width = r.size.width - verticalScroller.frame.size.width;
#endif
			sourceTextView = [[SBSourceTextView alloc] initWithFrame:tr];
			[scrollView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
			[scrollView setAutohidesScrollers:YES];
			[scrollView setHasHorizontalScroller:NO];
			[scrollView setHasVerticalScroller:YES];
			[scrollView setBackgroundColor:[NSColor colorWithCalibratedRed:SBBackgroundColors[0] green:SBBackgroundColors[1] blue:SBBackgroundColors[2] alpha:SBBackgroundColors[3]]];
			[scrollView setDrawsBackground:YES];
#if 1
			horizontalScroller.drawsBackground = YES;
			verticalScroller.drawsBackground = YES;
			horizontalScroller.backgroundColor = [NSColor colorWithCalibratedWhite:0.35 alpha:1.0];
			verticalScroller.backgroundColor = [NSColor colorWithCalibratedWhite:0.35 alpha:1.0];
#endif
			sourceTextView.delegate = self;
			[sourceTextView setMinSize:NSMakeSize(0.0, r.size.height)];
			[sourceTextView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
			[sourceTextView setVerticallyResizable:YES];
			[sourceTextView setHorizontallyResizable:NO];
			[sourceTextView setUsesFindPanel:YES];
			[sourceTextView setEditable:NO];
			[sourceTextView setAutoresizingMask:NSViewWidthSizable];
			[[sourceTextView textContainer] setContainerSize:NSMakeSize(r.size.width, FLT_MAX)];
			[[sourceTextView textContainer] setWidthTracksTextView:YES];
			sourcecode = self.documentSource;
			if (sourcecode)
				sourceTextView.string = sourcecode;
			[sourceTextView setSelectedRange:NSMakeRange(0, 0)];
			[scrollView setDocumentView:sourceTextView];
			[openButton setAutoresizingMask:(NSViewMinXMargin)];
			[openButton setTitle:NSLocalizedString(@"Open in other application…", nil)];
			[openButton setTarget:self];
			[openButton setAction:@selector(openDocumentSource:)];
			[sourceSaveButton setAutoresizingMask:(NSViewMinXMargin)];
			[sourceSaveButton setTitle:NSLocalizedString(@"Save", nil)];
			[sourceSaveButton setTarget:self];
			[sourceSaveButton setAction:@selector(saveDocumentSource:)];
			[sourceSaveButton setKeyEquivalent:@"\r"];
			[sourceCloseButton setAutoresizingMask:(NSViewMaxXMargin)];
			[sourceCloseButton setTitle:NSLocalizedString(@"Close", nil)];
			[sourceCloseButton setTarget:self];
			[sourceCloseButton setAction:@selector(hideShowSource)];
			[sourceCloseButton setKeyEquivalent:@"\e"];
			[sourceView addSubview:scrollView];
			[sourceView addSubview:openButton];
			[sourceView addSubview:sourceSaveButton];
			[sourceView addSubview:sourceCloseButton];
			[openButton release];
			if (webSplitView)
			{
				[webSplitView setFrame:wr];
				[splitView addSubview:webSplitView];
			}
			else {
				[webView setFrame:wr];
				[splitView addSubview:webView];
			}
			[splitView addSubview:sourceView];
			[scrollView release];
			splitView.dividerThickness = 5.0;
			[[webView window] makeFirstResponder:sourceTextView];
		}
		else {
			[sourceTextView removeFromSuperview];
			if (sourceSplitView)
				[sourceSplitView removeFromSuperview];
			[sourceView removeFromSuperview];
			[sourceTextView release];
			if (sourceSplitView)
				[sourceSplitView release];
			[sourceView release];
			sourceTextView = nil;
			if (sourceSplitView)
				sourceSplitView = nil;
			sourceView = nil;
			splitView.dividerThickness = 0.0;
			[[webView window] makeFirstResponder:webView];
		}
		[splitView adjustSubviews];
	}
}

- (BOOL)setShowFindbarInWebView:(BOOL)showFindbar
{
	BOOL r = NO;
	if (showFindbar)
	{
		if (!webSplitView)
		{
			SBFindbar *findbar = nil;
			findbar = [[SBFindbar alloc] initWithFrame:NSMakeRect(0, 0, webView.frame.size.width, 24.0)];
			findbar.target = webView;
			findbar.doneSelector = @selector(executeCloseFindbar);
			if (splitView)
			{
				if (sourceSplitView)
				{
					[sourceSplitView removeFromSuperview];
					[sourceSplitView retain];
				}
				else if (sourceView)
				{
					[sourceView removeFromSuperview];
					[sourceView retain];
				}
			}
			webSplitView = [[SBFixedSplitView splitViewWithEmbedViews:[NSArray arrayWithObjects:findbar, webView, nil] frameRect:webView.frame] retain];
			if (splitView)
			{
				if (sourceSplitView)
				{
					[splitView addSubview:sourceSplitView];
					[sourceSplitView release];
				}
				else if (sourceView)
				{
					[splitView addSubview:sourceView];
					[sourceView release];
				}
			}
			[findbar selectText:nil];
			[findbar release];
			r = YES;
		}
	}
	else {
		if (webSplitView)
		{
			if (splitView)
			{
				if (sourceSplitView)
				{
					[sourceSplitView removeFromSuperview];
					[sourceSplitView retain];
				}
				else if (sourceView)
				{
					[sourceView removeFromSuperview];
					[sourceView retain];
				}
			}
			SBDisembedViewInSplitView(webView, webSplitView);
			if (splitView)
			{
				if (sourceSplitView)
				{
					[splitView addSubview:sourceSplitView];
					[sourceSplitView release];
				}
				else if (sourceView)
				{
					[splitView addSubview:sourceView];
					[sourceView release];
				}
			}
			[webSplitView release];
			webSplitView = nil;
			[[webView window] makeFirstResponder:webView];
			r = YES;
		}
	}
	return r;
}

- (void)setShowFindbarInSource:(BOOL)showFindbar
{
	if (showFindbar)
	{
		if (!sourceSplitView)
		{
			SBFindbar *findbar = nil;
			findbar = [[SBFindbar alloc] initWithFrame:NSMakeRect(0, 0, sourceView.frame.size.width, 24.0)];
			findbar.target = sourceTextView;
			findbar.doneSelector = @selector(executeCloseFindbar);
			[sourceSaveButton setKeyEquivalent:[NSString string]];
			[sourceCloseButton setKeyEquivalent:[NSString string]];
			sourceSplitView = [[SBFixedSplitView splitViewWithEmbedViews:[NSArray arrayWithObjects:findbar, sourceView, nil] frameRect:sourceView.frame] retain];
			[findbar selectText:nil];
			[findbar release];
		}
	}
	else {
		[sourceSaveButton setKeyEquivalent:@"\r"];
		[sourceCloseButton setKeyEquivalent:@"\e"];
		SBDisembedViewInSplitView(sourceView, sourceSplitView);
		[sourceSplitView release];
		sourceSplitView = nil;
		[[sourceTextView window] makeFirstResponder:sourceTextView];
	}
}

- (void)hideFinderbarInWebView
{
	[self setShowFindbarInWebView:NO];
}

- (void)hideFinderbarInSource
{
	[self setShowFindbarInSource:NO];
}

#pragma mark Destruction

- (void)destructWebView
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center removeObserver:self name:WebViewProgressStartedNotification object:webView];
	[center removeObserver:self name:WebViewProgressEstimateChangedNotification object:webView];
	[center removeObserver:self name:WebViewProgressFinishedNotification object:webView];
	if (webView)
	{
		if ([webView isLoading])
		{
			[webView stopLoading:nil];
		}
		[webView setHostWindow:nil];
		[webView setFrameLoadDelegate:nil];
		[webView setResourceLoadDelegate:nil];
		[webView setUIDelegate:nil];
		[webView setPolicyDelegate:nil];
		[webView setDownloadDelegate:nil];
		[webView removeFromSuperview];
		[webView release];
		webView = nil;
	}
}

#pragma mark Construction

- (void)constructSplitView
{
	NSRect r = self.tabView.bounds;
	NSView *view = [[NSView alloc] initWithFrame:r];
	splitView = [[SBTabSplitView alloc] initWithFrame:r];
	splitView.delegate = self;
	[splitView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
	[self setView:view];
	[self.view addSubview:splitView];
	[view release];
}

- (void)constructWebView
{
	NSRect r = NSZeroRect;
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	r = self.tabView.bounds;
	if (!webView)
	{
		NSString *textEncodingName = nil;
		webView = [[SBWebView alloc] initWithFrame:r frameName:nil groupName:nil];
		// Set properties
		[webView setDrawsBackground:YES];
		[webView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
		webView.delegate = self;
		[webView setHostWindow:[self.tabView window]];
		[webView setFrameLoadDelegate:self];
		[webView setResourceLoadDelegate:self];
		[webView setUIDelegate:self];
		[webView setPolicyDelegate:self];
		[webView setDownloadDelegate:[SBDownloads sharedDownloads]];
		[webView setPreferences:SBGetWebPreferences()];
		textEncodingName = [[webView preferences] defaultTextEncodingName];
		webView.textEncodingName = textEncodingName;
		
		// Set user agent
		[self setUserAgent];
		
		// Add observer
		[center addObserver:self selector:@selector(webViewProgressStarted:) name:WebViewProgressStartedNotification object:webView];
		[center addObserver:self selector:@selector(webViewProgressEstimateChanged:) name:WebViewProgressEstimateChangedNotification object:webView];
		[center addObserver:self selector:@selector(webViewProgressFinished:) name:WebViewProgressFinishedNotification object:webView];
		
		splitView.dividerThickness = 0.0;
		[splitView addSubview:webView];
	}
	if (URL)
	{
		[[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:kSBTimeoutInterval]];
	}
}

- (void)setUserAgent
{
	NSBundle *bundle = nil;
	NSDictionary *infoDictionary = nil;
	NSDictionary *localizedInfoDictionary = nil;
	NSString *applicationName = nil;
	NSString *version = nil;
	NSString *safariVersion = nil;
	NSString *userAgentName = [[NSUserDefaults standardUserDefaults] objectForKey:kSBUserAgentName];
	// Set custom user agent
	if ([userAgentName isEqualToString:SBUserAgentNames[0]])
	{
		bundle = [NSBundle mainBundle];
		infoDictionary = [bundle infoDictionary];
		localizedInfoDictionary = [bundle localizedInfoDictionary];
		applicationName = [localizedInfoDictionary objectForKey:@"CFBundleName"];
		if (!applicationName) applicationName = [infoDictionary objectForKey:@"CFBundleName"];
		version = [infoDictionary objectForKey:@"CFBundleVersion"];
		if (version) version = [version stringByDeletingSpaces];
		safariVersion = [[[NSBundle bundleWithPath:@"/Applications/Safari.app"] infoDictionary] objectForKey:@"CFBundleVersion"];
		if (safariVersion)
			safariVersion = [safariVersion substringFromIndex:1];
		else
			safariVersion = @"0";
		if (applicationName)
			[webView setApplicationNameForUserAgent:applicationName];
		if (applicationName && version)
			[webView setApplicationNameForUserAgent:[NSString stringWithFormat:@"%@/%@", applicationName, version]];
		if (applicationName && version && safariVersion)
			[webView setApplicationNameForUserAgent:[NSString stringWithFormat:@"%@/%@ Safari/%@", applicationName, version, safariVersion]];
	}
	else if ([userAgentName isEqualToString:SBUserAgentNames[1]])
	{
		applicationName = SBUserAgentNames[1];
		bundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"/Applications/%@.app", applicationName]];
		infoDictionary = [bundle infoDictionary];
		version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
		if (!version) version = [infoDictionary objectForKey:@"CFBundleVersion"];
		safariVersion = [[[NSBundle bundleWithPath:@"/Applications/Safari.app"] infoDictionary] objectForKey:@"CFBundleVersion"];
		if (safariVersion)
			safariVersion = [safariVersion substringFromIndex:1];
		else
			safariVersion = @"0";
		if (applicationName && version && safariVersion)
			[webView setApplicationNameForUserAgent:[NSString stringWithFormat:@"Version/%@ %@/%@", version, applicationName, safariVersion]];
	}
	else {
		[webView setCustomUserAgent:userAgentName];
	}
}

#pragma mark SplitView Delegate

- (BOOL)splitView:(NSSplitView *)aSplitView canCollapseSubview:(NSView *)aSubview
{
	BOOL r = YES;
	if (aSplitView == splitView)
	{
		if (aSubview == webView)
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
	return r;
}

- (BOOL)splitView:(NSSplitView *)aSplitView shouldCollapseSubview:(NSView *)aSubview forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex
{
	BOOL r = YES;
	if (aSplitView == splitView)
	{
	}
	return r;
}

- (CGFloat)splitView:(NSSplitView *)aSplitView constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)offset
{
	CGFloat pos = proposedPosition;
	if (aSplitView == splitView)
	{
		
	}
	return pos;
}

- (CGFloat)splitView:(NSSplitView *)aSplitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)offset
{
	CGFloat maxHeight = proposedMax;
	if (aSplitView == splitView)
	{
		maxHeight = splitView.bounds.size.height - (10 + [self sourceBottomMargin]);
	}
	return maxHeight;
}

- (CGFloat)splitView:(NSSplitView *)aSplitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)offset
{
	CGFloat minHeight = proposedMin;
	if (aSplitView == splitView)
	{
		minHeight = 10;
	}
	return minHeight;
}

#pragma mark TextView Delegate

- (void)textViewShouldOpenFindbar:(SBSourceTextView *)aTextView
{
	if (sourceSplitView)
	{
		[self setShowFindbarInSource:NO];
	}
	[self setShowFindbarInSource:YES];
}

- (void)textViewShouldCloseFindbar:(SBSourceTextView *)aTextView
{
	if (sourceSplitView)
	{
		[self setShowFindbarInSource:NO];
	}
}

#pragma mark WebView Delegate

- (void)webViewShouldOpenFindbar:(SBWebView *)aWebView
{
	if (webSplitView)
	{
		[self setShowFindbarInWebView:NO];
	}
	[self setShowFindbarInWebView:YES];
}

- (BOOL)webViewShouldCloseFindbar:(SBWebView *)aWebView
{
	BOOL r = NO;
	if (webSplitView)
	{
		r = [self setShowFindbarInWebView:NO];
	}
	return r;
}

#pragma mark WebView Notification

- (void)webViewProgressStarted:(NSNotification *)aNotification
{
	if ([[aNotification object] isEqual:webView])
	{
		tabbarItem.progress = 0.0;
	}
}

- (void)webViewProgressEstimateChanged:(NSNotification *)aNotification
{
	if ([[aNotification object] isEqual:webView])
	{
		tabbarItem.progress = webView.estimatedProgress;
	}
}

- (void)webViewProgressFinished:(NSNotification *)aNotification
{
	if ([[aNotification object] isEqual:webView])
	{
		tabbarItem.progress = 1.0;
	}
}

#pragma mark WebFrameLoadDelegate

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{
	if ([[sender mainFrame] isEqual:frame])
	{
		[self removeAllResourceIdentifiers];
	}
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
	if ([[sender mainFrame] isEqual:frame])
	{
		if (self.selected)
		{
			[self.tabView executeSelectedItemDidFinishLoading:self];
		}
		if (showSource)
		{
			sourceTextView.string = self.documentSource;
		}
	}
}

- (void)webView:(WebView *)sender didCommitLoadForFrame:(WebFrame *)frame
{
	if ([[sender mainFrame] isEqual:frame])
	{
		if (self.selected)
		{
			[self.tabView executeSelectedItemDidStartLoading:self];
		}
	}
}

- (void)webView:(WebView *)sender willCloseFrame:(WebFrame *)frame
{
	if ([[sender mainFrame] isEqual:frame])
	{
		
	}
}

- (void)webView:(WebView *)sender didChangeLocationWithinPageForFrame:(WebFrame *)frame
{
	if ([[sender mainFrame] isEqual:frame])
	{
		
	}
}

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
	if ([[sender mainFrame] isEqual:frame])
	{
		tabbarItem.title = title;
		if (self.selected)
		{
			[self.tabView executeSelectedItemDidReceiveTitle:self];
		}
	}
}

- (void)webView:(WebView *)sender didReceiveIcon:(NSImage *)image forFrame:(WebFrame *)frame
{
	if ([[sender mainFrame] isEqual:frame])
	{
		tabbarItem.image = image;
		if (self.selected)
		{
			[self.tabView executeSelectedItemDidReceiveIcon:self];
		}
	}
}

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
//	if ([[sender mainFrame] isEqual:frame])
	{
		DebugLog(@"%s %@", __func__, [error localizedDescription]);
		if (error)
		{
			NSDictionary *userInfo = [error userInfo];
			if (userInfo != nil)
			{
				NSInteger errorCode = [error code];
				NSString *urlString = [userInfo objectForKey:NSErrorFailingURLStringKey];
				NSString *title = nil;
				switch (errorCode)
				{
					case NSURLErrorCancelled:
						title = NSLocalizedString(@"Cancelled", nil);
						break;
					case NSURLErrorBadURL:
						title = NSLocalizedString(@"Bad URL", nil);
						break;
					case NSURLErrorTimedOut:
						title = NSLocalizedString(@"Timed Out", nil);
						break;
					case NSURLErrorUnsupportedURL:
						title = NSLocalizedString(@"Unsupported URL", nil);
						break;
					case NSURLErrorCannotFindHost:
						title = NSLocalizedString(@"Cannot Find Host", nil);
						break;
					case NSURLErrorCannotConnectToHost:
						title = NSLocalizedString(@"Cannot Connect to Host", nil);
						break;
					case NSURLErrorNetworkConnectionLost:
						title = NSLocalizedString(@"Network Connection Lost", nil);
						break;
					case NSURLErrorDNSLookupFailed:
						title = NSLocalizedString(@"DNS Lookup Failed", nil);
						break;
					case NSURLErrorHTTPTooManyRedirects:
						title = NSLocalizedString(@"Too Many Redirects", nil);
						break;
					case NSURLErrorResourceUnavailable:
						title = NSLocalizedString(@"Resource Unavailable", nil);
						break;
					case NSURLErrorNotConnectedToInternet:
						title = NSLocalizedString(@"Not Connected to Internet", nil);
						break;
					case NSURLErrorRedirectToNonExistentLocation:
						title = NSLocalizedString(@"Redirect to Non Existent Location", nil);
						break;
					case NSURLErrorBadServerResponse:
						title = NSLocalizedString(@"Bad Server Response", nil);
						break;
					case NSURLErrorUserCancelledAuthentication:
						title = NSLocalizedString(@"User Cancelled Authentication", nil);
						break;
					case NSURLErrorUserAuthenticationRequired:
						title = NSLocalizedString(@"User Authentication Required", nil);
						break;
					case NSURLErrorZeroByteResource:
						title = NSLocalizedString(@"Zero Byte Resource", nil);
						break;
					case NSURLErrorCannotDecodeRawData:
						title = NSLocalizedString(@"Cannot Decode Raw Data", nil);
						break;
					case NSURLErrorCannotDecodeContentData:
						title = NSLocalizedString(@"Cannot Decode Content Data", nil);
						break;
					case NSURLErrorCannotParseResponse:
						title = NSLocalizedString(@"Cannot Parse Response", nil);
						break;
					case NSURLErrorFileDoesNotExist:
						title = NSLocalizedString(@"File Does Not Exist", nil);
						break;
					case NSURLErrorFileIsDirectory:
					{
						NSURL *url = [NSURL URLWithString:urlString];
						if (url)
						{
							// Try to opening with other application
							if (![[NSWorkspace sharedWorkspace] openURL:url])
							{
								title = NSLocalizedString(@"File is Directory", nil);
							}
						}
						break;
					}
					case NSURLErrorNoPermissionsToReadFile:
						title = NSLocalizedString(@"No Permissions to ReadFile", nil);
						break;
					case NSURLErrorDataLengthExceedsMaximum:
						title = NSLocalizedString(@"Data Length Exceeds Maximum", nil);
						break;
					case NSURLErrorSecureConnectionFailed:
						title = NSLocalizedString(@"Secure Connection Failed", nil);
						break;
					case NSURLErrorServerCertificateHasBadDate:
						title = NSLocalizedString(@"Server Certificate Has BadDate", nil);
						break;
					case NSURLErrorServerCertificateUntrusted:
					{
//						title = NSLocalizedString(@"Server Certificate Untrusted", nil);
						NSURL *url = nil;
						NSString *aTitle = nil;
						NSString *message = nil;
						NSDictionary *info = nil;
						url = [NSURL URLWithString:urlString];
						aTitle = NSLocalizedString(@"Server Certificate Untrusted", nil);
						message = [NSString stringWithFormat:NSLocalizedString(@"The certificate for this website is invalid. You might be connecting to a website that is pretending to be \"%@\", which could put your confidential information at risk. Would you like to connect to the website anyway?", nil), [url host]];
						info = [NSDictionary dictionaryWithObjectsAndKeys:
								frame, WebElementFrameKey, 
								url, WebElementLinkURLKey, 
								aTitle, WebElementLinkTitleKey, nil];
						[info retain];
						NSBeginAlertSheet(aTitle, NSLocalizedString(@"Continue", nil), NSLocalizedString(@"Cancel", nil), nil, [sender window], self, @selector(serverCertificateUntrustedSheetDidEnd:returnCode:contextInfo:), nil, info, message);
						break;
					}
					case NSURLErrorServerCertificateHasUnknownRoot:
						title = NSLocalizedString(@"Server Certificate Has UnknownRoot", nil);
						break;
					case NSURLErrorServerCertificateNotYetValid:
						title = NSLocalizedString(@"Server Certificate Not Yet Valid", nil);
						break;
					case NSURLErrorClientCertificateRejected:
						title = NSLocalizedString(@"Client Certificate Rejected", nil);
						break;
					case NSURLErrorCannotLoadFromNetwork:
						title = NSLocalizedString(@"Cannot Load from Network", nil);
						break;
					default:
						break;
				}
				if (title)
				{
					[self showErrorPageWithTitle:title urlString:urlString frame:frame];
				}
			}
		}
	}
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
	if ([[sender mainFrame] isEqual:frame])
	{
		DebugLog(@"%s %@", __func__, [error localizedDescription]);
		if (self.selected)
		{
			[self.tabView executeSelectedItemDidFailLoading:self];
		}
	}
}

- (void)webView:(WebView *)sender didReceiveServerRedirectForProvisionalLoadForFrame:(WebFrame *)frame
{
	if ([[sender mainFrame] isEqual:frame])
	{
		if (self.selected)
		{
			[self.tabView executeSelectedItemDidReceiveServerRedirect:self];
		}
	}
}

#pragma mark WebResourceLoadDelegate

- (id)webView:(WebView *)sender identifierForInitialRequest:(NSURLRequest *)request fromDataSource:(WebDataSource *)dataSource
{
	id identifier = nil;
	identifier = (id)[SBWebResourceIdentifier identifierWithURLRequest:request];
	if ([self addResourceIdentifier:(SBWebResourceIdentifier *)identifier])
	{
		if (self.selected)
		{
			[self.tabView executeSelectedItemDidAddResourceID:(SBWebResourceIdentifier *)identifier];
		}
	}
	return identifier;
}

- (NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource
{
	return request;
}

- (void)webView:(WebView *)sender resource:(id)identifier didReceiveResponse:(NSURLResponse *)response fromDataSource:(WebDataSource *)dataSource
{
	long long length = [response expectedContentLength];
	if (identifier && length > 0)
	{
		SBWebResourceIdentifier *resourceID = (SBWebResourceIdentifier *)identifier;
		resourceID.length = length;
		if (self.selected)
		{
			[self.tabView executeSelectedItemDidReceiveExpectedContentLengthOfResourceID:resourceID];
		}
	}
}

- (void)webView:(WebView *)sender resource:(id)identifier didFailLoadingWithError:(NSError *)error fromDataSource:(WebDataSource *)dataSource
{
	if (identifier)
	{
		SBWebResourceIdentifier *resourceID = (SBWebResourceIdentifier *)identifier;
		resourceID.flag = NO;
	}
}

- (void)webView:(WebView *)sender resource:(id)identifier didReceiveContentLength:(NSInteger)length fromDataSource:(WebDataSource *)dataSource
{
	if (identifier && length > 0)
	{
		SBWebResourceIdentifier *resourceID = (SBWebResourceIdentifier *)identifier;
		resourceID.received += length;
		if (self.selected)
		{
			[self.tabView executeSelectedItemDidReceiveContentLengthOfResourceID:resourceID];
		}
	}
}

- (void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource
{
	if (identifier)
	{
		SBWebResourceIdentifier *resourceID = (SBWebResourceIdentifier *)identifier;
		NSCachedURLResponse *response = nil;
		if ((response = [[NSURLCache sharedURLCache] cachedResponseForRequest:resourceID.request]))
		{
			// Loaded from cache
			long long length = [response data] ? [[response data] length] : 0;
			if (length > 0)
			{
				resourceID.length = length;
				resourceID.received = length;
			}
		}
		if (self.selected)
		{
			[self.tabView executeSelectedItemDidReceiveFinishLoadingOfResourceID:resourceID];
		}
	}
}

#pragma mark WebUIDelegate

- (void)webViewShow:(WebView *)sender
{
	SBDocument *document = (SBDocument *)[[sender window] delegate];
	if (document)
	{
		[document showWindows];
	}
}

- (void)webView:(WebView *)sender setToolbarsVisible:(BOOL)visible
{
	SBDocumentWindow *window = (SBDocumentWindow *)[sender window];
	SBToolbar *toolbar = (SBToolbar *)[window toolbar];
	if (toolbar)
	{
		[toolbar setAutosavesConfiguration:NO];
		[toolbar setVisible:visible];
	}
	if (visible)
	{
		if (!window.tabbarVisivility)
		{
			[window showTabbar];
		}
	}
	else {
		if (window.tabbarVisivility)
		{
			[window hideTabbar];
		}
	}
}

- (WebView *)webView:(WebView *)sender createWebViewModalDialogWithRequest:(NSURLRequest *)request
{
	return webView;
}

- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request
{
	NSError *error = nil;
	SBDocument *document = [SBGetDocumentController() openUntitledDocumentAndDisplay:NO sidebarVisibility:NO initialURL:[request URL] error:&error];
	WebView *selectedWebView = document ? [document selectedWebView] : nil;
	return selectedWebView;
}

- (BOOL)webView:(WebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame
{
	return [self.tabView executeShouldConfirmMessage:message];
}

- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame
{
	[self.tabView executeShouldShowMessage:message];
}

- (void)webView:(WebView *)sender runOpenPanelForFileButtonWithResultListener:(id < WebOpenPanelResultListener >)resultListener
{
	SBOpenPanel *panel = [SBOpenPanel openPanel];
	NSWindow *window = [self.tabView window];
	[resultListener retain];
	[panel beginSheetForDirectory:nil file:nil modalForWindow:window modalDelegate:self didEndSelector:@selector(webOpenPanelDidEnd:returnCode:contextInfo:) contextInfo:resultListener];
}

- (NSString *)webView:(WebView *)sender runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WebFrame *)frame
{
	return [self.tabView executeShouldTextInput:prompt];
}

- (void)webOpenPanelDidEnd:(SBOpenPanel *)panel returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	id <WebOpenPanelResultListener> resultListener = (id <WebOpenPanelResultListener>)contextInfo;
	if (returnCode == NSOKButton)
	{
		[resultListener chooseFilename:[[panel filenames] objectAtIndex:0]];
	}
	[resultListener release];
	[panel orderOut:nil];
}

- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems
{
	NSMutableArray *menuItems = nil;
	NSString *selectedString =  nil;
	NSString *applicationPath = nil;
	NSString *applicationBundleIdentifier = nil;
	NSString *appName = nil;
	NSURL *linkURL = nil;
	WebFrame *frame = nil;
	NSURL *frameURL = nil;
	NSUInteger index = 0;
	
	menuItems = [NSMutableArray arrayWithCapacity:0];
	selectedString = [(id <WebDocumentText>)[[[sender mainFrame] frameView] documentView] selectedString];
	if ([selectedString length] == 0)
	{
		NSMutableArray *childFrames = nil;
		childFrames = [self webFramesInFrame:[sender mainFrame]];
		for (WebFrame *frame in childFrames)
		{
			selectedString = [(id <WebDocumentText>)[[frame frameView] documentView] selectedString];
			if ([selectedString length] > 0)
			{
				break;
			}
		}
	}
	linkURL = [element objectForKey:WebElementLinkURLKey];
	frame = [element objectForKey:WebElementFrameKey];
	frameURL = [[[frame dataSource] request] URL];
	applicationBundleIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:kSBOpenApplicationBundleIdentifier];
	applicationPath = applicationBundleIdentifier ? [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:applicationBundleIdentifier] : nil;
	if (applicationPath)
	{
		NSBundle *bundle = nil;
		bundle = [NSBundle bundleWithPath:applicationPath];
		appName = [[bundle localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
		if (!appName)
			appName = [[bundle infoDictionary] objectForKey:@"CFBundleName"];
	}
	
	[menuItems addObjectsFromArray:defaultMenuItems];
	
	if (linkURL == nil && [selectedString length] == 0)
	{
		if (frameURL)
		{
			/* Add Open in items */
			NSMenuItem *newItem1 = nil;
			NSMenuItem *newItem2 = nil;
			newItem1 = [[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Open in Application...", nil) action:@selector(openURLInSelectedApplicationFromMenu:) keyEquivalent:@""] autorelease];
			[newItem1 setTarget:self];
			[newItem1 setRepresentedObject:frameURL];
			if (appName)
			{
				newItem2 = [[[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Open in %@", nil), appName] action:@selector(openURLInApplicationFromMenu:) keyEquivalent:@""] autorelease];
				[newItem2 setTarget:self];
				[newItem2 setRepresentedObject:frameURL];
			}
			[menuItems insertObject:[NSMenuItem separatorItem] atIndex:index];
			if (newItem2)
			{
				[menuItems insertObject:newItem2 atIndex:index];
			}
			[menuItems insertObject:newItem1 atIndex:index];
		}
	}
	if (linkURL)
	{
		index = [menuItems count] - 1;
		for (NSMenuItem *item in [menuItems reverseObjectEnumerator])
		{
			NSInteger tag = [item tag];
			if (tag == 1)
			{
				/* Add Open link in items */
				NSMenuItem *newItem0 = nil;
				NSMenuItem *newItem1 = nil;
				NSMenuItem *newItem2 = nil;
				newItem0 = [[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Open Link in New Tab", nil) action:@selector(openURLInNewTabFromMenu:) keyEquivalent:@""] autorelease];
				[newItem0 setTarget:self];
				[newItem0 setRepresentedObject:linkURL];
				newItem1 = [[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Open Link in Application...", nil) action:@selector(openURLInSelectedApplicationFromMenu:) keyEquivalent:@""] autorelease];
				[newItem1 setTarget:self];
				[newItem1 setRepresentedObject:linkURL];
				if (appName)
				{
					newItem2 = [[[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Open Link in %@", nil), appName] action:@selector(openURLInApplicationFromMenu:) keyEquivalent:@""] autorelease];
					[newItem2 setTarget:self];
					[newItem2 setRepresentedObject:linkURL];
				}
				if (newItem2)
				{
					[menuItems insertObject:newItem2 atIndex:index];
				}
				[menuItems insertObject:newItem1 atIndex:index];
				[menuItems insertObject:newItem0 atIndex:index];
				break;
			}
			index--;
		}
	}
	if ([selectedString length] > 0)
	{
		NSMenuItem *newItem0 = nil;
		NSMenuItem *newItem1 = nil;
		BOOL replaced = NO;
		// Create items
		newItem0 = [[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Search in Google", nil) action:@selector(searchStringFromMenu:) keyEquivalent:@""] autorelease];
		[newItem0 setTarget:self];
		[newItem0 setRepresentedObject:selectedString];
		newItem1 = [[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Open Google Search Results in New Tab", nil) action:@selector(searchStringInNewTabFromMenu:) keyEquivalent:@""] autorelease];
		[newItem1 setTarget:self];
		[newItem1 setRepresentedObject:selectedString];
		// Find an item
		index = [menuItems count] - 1;
		for (NSMenuItem *item in [menuItems reverseObjectEnumerator])
		{
			NSInteger tag = [item tag];
			if (tag == 21)
			{
				[menuItems replaceObjectAtIndex:index withObject:newItem0];
				[menuItems insertObject:newItem1 atIndex:index + 1];
				replaced = YES;
			}
			index--;
		}
		if (!replaced)
		{
			[menuItems insertObject:[NSMenuItem separatorItem] atIndex:0];
			[menuItems insertObject:newItem0 atIndex:0];
			[menuItems insertObject:newItem1 atIndex:1];
		}
	}
	if (frame != [sender mainFrame])
	{
		NSMenuItem *newItem0 = [[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Open Frame in Current Frame", nil) action:@selector(openFrameInCurrentFrameFromMenu:) keyEquivalent:@""] autorelease];
		NSMenuItem *newItem1 = [[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Open Frame in New Tab", nil) action:@selector(openURLInNewTabFromMenu:) keyEquivalent:@""] autorelease];
		[newItem0 setTarget:self];
		[newItem1 setTarget:self];
		[newItem0 setRepresentedObject:frameURL];
		[newItem1 setRepresentedObject:frameURL];
		[menuItems addObject:newItem0];
		[menuItems addObject:newItem1];
	}
	return menuItems;
}

#pragma mark WebPolicyDelegate

- (void)webView:(WebView *)webView decidePolicyForMIMEType:(NSString *)type request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id < WebPolicyDecisionListener >)listener
{
	if ([WebView canShowMIMETypeAsHTML:type])
	{
		[listener use];
	}
	else {
		[listener download];
	}
}

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id < WebPolicyDecisionListener >)listener
{
	NSURL *url = [request URL];
	NSUInteger modifierFlags = 0;
	NSUInteger navigationType = 0;
	
	modifierFlags = [[actionInformation objectForKey:WebActionModifierFlagsKey] unsignedIntegerValue];
	navigationType = [[actionInformation objectForKey:WebActionNavigationTypeKey] unsignedIntegerValue];
	
	switch (navigationType)
	{
		case WebNavigationTypeLinkClicked:
		{
			if ([url hasWebScheme])		// 'http', 'https', 'file'
			{
				if (modifierFlags & NSCommandKeyMask)	// Command
				{
					BOOL selection = YES;
					BOOL makeActiveFlag = [[NSUserDefaults standardUserDefaults] boolForKey:kSBWhenNewTabOpensMakeActiveFlag];
					// Make it active flag and Shift key mask
					if (makeActiveFlag)
					{
						if (modifierFlags & NSShiftKeyMask)
						{
							selection = NO;
						}
					}
					else {
						if (modifierFlags & NSShiftKeyMask)
						{
						}
						else {
							selection = NO;
						}
					}
					[self.tabView executeShouldAddNewItemForURL:url selection:selection];
					[listener ignore];
				}
				else if (modifierFlags & NSAlternateKeyMask)	// Option	
				{
					[listener download];
				}
				else {
					[listener use];
				}
			}
			else {
				// Open URL in other application. 
				if ([[NSWorkspace sharedWorkspace] openURL:url])
				{
					[listener ignore];
				}
				else {
					[listener use];
				}
			}
			break;
		}
		case WebNavigationTypeFormSubmitted:
			[listener use];
			break;
		case WebNavigationTypeBackForward:
			[listener use];
			break;
		case WebNavigationTypeReload:
			[listener use];
			break;
		case WebNavigationTypeFormResubmitted:
			[listener use];
			break;
		case WebNavigationTypeOther:
			[listener use];
			break;
		default:
			[listener use];
			break;
	}
}

- (void)webView:(WebView *)webView decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id < WebPolicyDecisionListener >)listener
{
	// open link in new tab
	NSURL *url = [request URL];
	[self.tabView executeShouldAddNewItemForURL:url selection:YES];
}

- (void)webView:(WebView *)webView unableToImplementPolicyWithError:(NSError *)error frame:(WebFrame *)frame
{
	NSString *string = nil;
	NSDictionary *userInfo = [error userInfo];
	string = [userInfo objectForKey:@"NSErrorFailingURLStringKey"];
	if (string)
	{
		NSURL *url = nil;
		url = [NSURL URLWithString:string];
		if ([url hasWebScheme])		// 'http', 'https', 'file'
		{
			// Error
		}
		else {
			// open URL with other applications
			if (![[NSWorkspace sharedWorkspace] openURL:url])
			{
				// Error
			}
		}
	}
}

#pragma mark Actions

- (BOOL)addResourceIdentifier:(SBWebResourceIdentifier *)identifier
{
	BOOL r = NO;
	BOOL contains = NO;
	if (!resourceIdentifiers)
		resourceIdentifiers = [[NSMutableArray alloc] initWithCapacity:0];
	for (SBWebResourceIdentifier *anIdentifier in resourceIdentifiers)
	{
		if ([anIdentifier.request isEqualTo:identifier.request])
		{
			DebugLog(@"%s contains request %@", __func__, anIdentifier.request);
			contains = YES;
			break;
		}
	}
	if (!contains)
	{
		[resourceIdentifiers addObject:identifier];
		r = YES;
	}
	return r;
}

- (void)removeAllResourceIdentifiers
{
	if (resourceIdentifiers)
	{
		[resourceIdentifiers removeAllObjects];
	}
}

- (void)backward:(id)sender
{
	if ([webView canGoBack])
	{
		[webView goBack:nil];
	}
}

- (void)forward:(id)sender
{
	if ([webView canGoForward])
	{
		[webView goForward:nil];
	}
}

- (void)openDocumentSource:(id)sender
{
	SBOpenPanel *openPanel = [SBOpenPanel openPanel];
	[openPanel setCanChooseDirectories:NO];
	if ([openPanel runModalForTypes:[NSArray arrayWithObject:@"app"]] == NSOKButton)
	{
		NSString *name = nil;
		NSString *filePath = nil;
		NSString *documentSource = self.documentSource;
		NSString *encodingName = webView.textEncodingName;
		NSStringEncoding encoding;
		NSError *error = nil;
		name = self.pageTitle;
		name = [[name length] > 0 ? name : NSLocalizedString(@"Untitled", nil) stringByAppendingPathExtension:@"html"];
		filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:name];
		encoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)([encodingName length] > 0 ? encodingName : kSBDefaultEncodingName)));
		if (![documentSource writeToFile:filePath atomically:YES encoding:encoding error:&error])
		{
			SBRunAlertWithMessage([error localizedDescription]);
		}
		else {
			NSString *appPath = [openPanel filename];
			if (![[NSWorkspace sharedWorkspace] openFile:filePath withApplication:appPath])
			{
				SBRunAlertWithMessage([NSString stringWithFormat:NSLocalizedString(@"Could not open in %@.", nil), appPath]);
			}
		}
	}
}

- (void)saveDocumentSource:(id)sender
{
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	NSString *name = self.pageTitle;
	NSString *encodingName = webView.textEncodingName;
	NSStringEncoding encoding;
	name = [[name length] > 0 ? name : NSLocalizedString(@"Untitled", nil) stringByAppendingPathExtension:@"html"];
	encoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)([encodingName length] > 0 ? encodingName : kSBDefaultEncodingName)));
	[savePanel setCanCreateDirectories:YES];
	if ([savePanel runModalForDirectory:nil file:name] == NSOKButton)
	{
		NSString *documentSource = self.documentSource;
		NSError *error = nil;
		if (![documentSource writeToFile:[savePanel filename] atomically:YES encoding:encoding error:&error])
		{
			SBRunAlertWithMessage([error localizedDescription]);
		}
	}
}

- (void)removeFromTabView
{
	[self destructWebView];
	[self.tabView removeTabViewItem:self];
}

- (void)serverCertificateUntrustedSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	NSDictionary *info = (NSDictionary *)contextInfo;
	WebFrame *frame = nil;
	NSURL *url = nil;
	NSString *title = nil;
	
	frame = [info objectForKey:WebElementFrameKey];
	url = [info objectForKey:WebElementLinkURLKey];
	title = [info objectForKey:WebElementLinkTitleKey];
	
	if (frame && url)
	{
		if (returnCode == NSOKButton)
		{
			[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
			[frame loadRequest:[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:kSBTimeoutInterval]];
			[self webView:self.webView didStartProvisionalLoadForFrame:frame];
		}
		else {
			[self showErrorPageWithTitle:title urlString:[url absoluteString] frame:frame];
		}
	}
	if (contextInfo)
	{
		[(id)contextInfo release];
	}
}

- (void)showErrorPageWithTitle:(NSString *)title urlString:(NSString *)urlString frame:(WebFrame *)frame
{
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *message = nil;
	NSString *searchURLString = nil;
	NSString *path = nil;
	title = [@"<img src=\"Application.icns\" style=\"width:76px;height:76px;margin-right:10px;vertical-align:middle;\" alt=\"\">" stringByAppendingString:title];
	searchURLString = [NSString stringWithFormat:@"http://www.google.com/search?hl=ja&q=%@", urlString];
	message = [NSString stringWithFormat:NSLocalizedString(@"Sunrise can’t open the page “%@”", nil), urlString];
	message = [message stringByAppendingFormat:@"<br /><br />%@<br /><a href=\"%@\">%@</a>", 
			   NSLocalizedString(@"You can search the web for this URL.", nil), 
			   searchURLString, urlString];
	path = [bundle pathForResource:@"Error" ofType:@"html"];
	if ([[NSFileManager defaultManager] fileExistsAtPath:path])
	{
		NSString *htmlString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
		htmlString = [NSString stringWithFormat:htmlString, title, message];
		// Load
		[frame loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:path]];
	}
}

#pragma mark Menu Actions

- (void)searchStringFromMenu:(NSMenuItem *)menuItem
{
	NSString *searchString = [menuItem representedObject];
	if (searchString)
	{
		[self.tabView executeShouldSearchString:searchString newTab:NO];
	}
}

- (void)searchStringInNewTabFromMenu:(NSMenuItem *)menuItem
{
	NSString *searchString = [menuItem representedObject];
	if (searchString)
	{
		[self.tabView executeShouldSearchString:searchString newTab:YES];
	}
}

- (void)openURLInApplicationFromMenu:(NSMenuItem *)menuItem
{
	NSURL *url = [menuItem representedObject];
    if (url)
    {
		NSString *savedBundleIdentifier = nil;
		savedBundleIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:kSBOpenApplicationBundleIdentifier];
		if (savedBundleIdentifier)
		{
        	[self openURL:url inBundleIdentifier:savedBundleIdentifier];
		}
	}
}

- (void)openURLInSelectedApplicationFromMenu:(NSMenuItem *)menuItem
{
	NSURL *url = [menuItem representedObject];
    if (url)
    {
		NSString *bundleIdentifier = nil;
		NSOpenPanel *panel = nil;
		panel = [NSOpenPanel openPanel];
		[panel setCanChooseFiles:YES];
		[panel setCanChooseDirectories:NO];
		[panel setAllowedFileTypes:[NSArray arrayWithObject:@"app"]];
		[panel setAllowsMultipleSelection:NO];
		[panel setDirectory:@"/Applications"];
		if ([panel runModal] == NSOKButton)
		{
			NSString *filename = nil;
			NSBundle *bundle = nil;
			filename = [panel filename];
			bundle  = [NSBundle bundleWithPath:filename];
			bundleIdentifier = [bundle bundleIdentifier];
		}
		if (bundleIdentifier)
		{
        	if ([self openURL:url inBundleIdentifier:bundleIdentifier])
			{
				[[NSUserDefaults standardUserDefaults] setObject:bundleIdentifier forKey:kSBOpenApplicationBundleIdentifier];
			}
		}
    }
}

- (BOOL)openURL:(NSURL *)url inBundleIdentifier:(NSString *)bundleIdentifier
{
	BOOL r = NO;
    if (url && bundleIdentifier)
    {
        r = [[NSWorkspace sharedWorkspace] openURLs:[NSArray arrayWithObject:url] withAppBundleIdentifier:bundleIdentifier options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:nil launchIdentifiers:nil];
    }
	return r;
}

- (void)openFrameInCurrentFrameFromMenu:(NSMenuItem *)menuItem
{
	NSURL *url = [menuItem representedObject];
	if (url)
	{
		self.URL = url;
	}
}

- (void)openURLInNewTabFromMenu:(NSMenuItem *)menuItem
{
	NSURL *url = [menuItem representedObject];
	if (url)
	{
		[self.tabView executeShouldAddNewItemForURL:url selection:YES];
	}
}

@end

@implementation SBTabSplitView

@synthesize dividerThickness;

- (CGFloat)dividerThickness
{
	return 5.0;//dividerThickness;
}

- (NSColor *)dividerColor
{
	return [NSColor colorWithCalibratedRed:SBWindowBackColors[0] green:SBWindowBackColors[1] blue:SBWindowBackColors[2] alpha:SBWindowBackColors[3]];
}

@end