/*
 
 SBRenderWindow.m
 
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

#import "SBRenderWindow.h"
#import "SBUtil.h"

@implementation SBRenderWindow

@synthesize webView;
@synthesize delegate;

+ (id)startRenderingWithSize:(NSSize)size delegate:(id)delegate url:(NSURL *)url
{
	NSRect r = NSMakeRectFromPointAndSize(NSZeroPoint, size);
	SBRenderWindow *window = [[[SBRenderWindow alloc] initWithContentRect:r] autorelease];
	window.delegate = delegate;
	[[window.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:url]];
#if kSBFlagShowRenderWindow
	[window orderFront:nil];
#else
#endif
	return window;
}

- (id)initWithContentRect:(NSRect)contentRect
{
	NSUInteger styleMask = (NSBorderlessWindowMask);
	NSBackingStoreType bufferingType = NSBackingStoreBuffered;
	BOOL deferCreation = YES;
	if (self = [super initWithContentRect:contentRect styleMask:styleMask backing:bufferingType defer:deferCreation])
	{
		NSRect r = contentRect;
		r.origin = NSZeroPoint;
		webView = [[WebView alloc] initWithFrame:r frameName:nil groupName:nil];
		[webView setFrameLoadDelegate:self];
		[webView setPreferences:SBGetWebPreferences()];
		[webView setHostWindow:self];
		[[self contentView] addSubview:webView];
		[self setReleasedWhenClosed:YES];
	}
	return self;
}

- (void)dealloc
{
	[webView release];
	delegate = nil;
	[super dealloc];
}

- (void)destruct
{
	[self destructWebView];
	[self close];
}

- (void)destructWebView
{
	if (webView)
	{
		if ([webView isLoading])
		{
			[webView stopLoading:nil];
		}
		[webView setHostWindow:nil];
		[webView setFrameLoadDelegate:nil];
		[webView removeFromSuperview];
		[webView release];
		webView = nil;
	}
}

#pragma mark Delegate

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(renderWindowDidStartRendering:)])
		{
			[delegate renderWindowDidStartRendering:self];
		}
	}
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(renderWindow:didFinishRenderingImage:)])
		{
			id webDocumentView = [[[sender mainFrame] frameView] documentView];
			NSRect intersectRect = [webDocumentView bounds];
			NSImage *image = nil;
			if (webDocumentView)
			{
				image = [[NSImage imageWithView:webDocumentView] insetWithSize:SBBookmarkImageMaxSize() intersectRect:intersectRect offset:NSZeroPoint];
			}
			if (image)
			{
				[delegate renderWindow:self didFinishRenderingImage:image];
			}
		}
	}
	[self destruct];
}

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(renderWindow:didFailWithError:)])
		{
			[delegate renderWindow:self didFailWithError:error];
		}
	}
	[self destruct];
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(renderWindow:didFailWithError:)])
		{
			[delegate renderWindow:self didFailWithError:error];
		}
	}
	[self destruct];
}

@end
