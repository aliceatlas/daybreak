/*

SBDocumentWindow.m
 
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

#import "SBDocumentWindow.h"
#import "SBAboutView.h"
#import "SBBLKGUI.h"
#import "SBCoverWindow.h"
#import "SBDefinitions.h"
#import "SBInnerView.h"
#import "SBSplitView.h"
#import "SBTabbar.h"
#import "SBUtil.h"

#define kSBFlipAnimationDuration 0.8
#define kSBFlipAnimationRectMargin 100
#define kSBBackWindowFrameWidth 800.0
#define kSBBackWindowFrameHeight 600.0

@implementation SBDocumentWindow

@dynamic innerRect;
@synthesize keyView;
@dynamic title;
@dynamic toolbar;
@dynamic contentView;
@synthesize innerView;
@synthesize coverWindow;
@synthesize tabbar;
@synthesize splitView;
@synthesize backWindow;
@synthesize tabbarVisivility;

- (id)initWithFrame:(NSRect)frame delegate:(id)delegate tabbarVisivility:(BOOL)inTabbarVisivility
{
	NSUInteger styleMask = (NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask);
	if (self = [super initWithContentRect:frame styleMask:styleMask backing:NSBackingStoreBuffered defer:YES])
	{
		[self constructInnerView];
		[self setMinSize:NSMakeSize(kSBDocumentWindowMinimumSizeWidth, kSBDocumentWindowMinimumSizeHeight)];
		[self setDelegate:delegate];
		[self setReleasedWhenClosed:YES];
		[self setShowsToolbarButton:YES];
		[self setOneShot:YES];
		[self setAcceptsMouseMovedEvents:YES];
		if (floor(NSAppKitVersionNumber) > 1038)
		{
			/* Lion only */
			/* NSWindowCollectionBehaviorFullScreenPrimary */
			/* NSWindowCollectionBehaviorFullScreenAuxiliary */
			[self setCollectionBehavior:(1 << 7 | 1 << 8)];
			/* NSWindowAnimationBehaviorNone */
			[self setAnimationBehavior:2];
		}
		tabbarVisivility = inTabbarVisivility;
	}
	return self;
}

- (void)dealloc
{
	[self setDelegate:nil];
	[innerView release];
	[self destructCoverWindow];
	[tabbar release];
	[splitView release];
	[super dealloc];
}

- (BOOL)isCovering
{
	NSWindow *keyWindow = [NSApp keyWindow];
	return keyWindow ? keyWindow == coverWindow : NO;
}

- (BOOL)canBecomeKeyWindow
{
	BOOL r = [self isCovering] ? NO : [super canBecomeKeyWindow];
	return r;
}

- (void)becomeKeyWindow
{
	[super becomeKeyWindow];
	if (coverWindow)
	{
		[coverWindow makeKeyWindow];
	}
}

#pragma mark Getter

- (NSString *)title
{
	return [super title];
}

- (SBToolbar *)toolbar
{
	return (SBToolbar *)[super toolbar];
}

- (NSView *)contentView
{
	return [super contentView];
}

#pragma mark Rects

- (NSRect)innerRect
{
	return self.contentView.bounds;
}

- (CGFloat)tabbarHeight
{
	return kSBTabbarHeight;
}

- (NSRect)tabbarRect
{
	NSRect r = NSZeroRect;
	NSRect innerRect = [self innerRect];
	r.size.width = innerRect.size.width;
	r.size.height = [self tabbarHeight];
	r.origin.y = tabbarVisivility ? innerRect.size.height - r.size.height : innerRect.size.height;
	return r;
}

- (NSRect)splitViewRect
{
	NSRect r = NSZeroRect;
	NSRect innerRect = [self innerRect];
	r.size.width = innerRect.size.width;
	r.size.height = tabbarVisivility ? innerRect.size.height - [self tabbarHeight] : innerRect.size.height;
	return r;
}

- (CGFloat)sheetPosition
{
	CGFloat position = [self splitViewRect].size.height;
	return position;
}

#pragma mark Responding

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent
{
	BOOL r = NO;
	if ([self delegate])
	{
		if ([[self delegate] respondsToSelector:@selector(window:shouldHandleKeyEvent:)])
		{
			r = [(id<SBDocumentWindowDelegate>)[self delegate] window:self shouldHandleKeyEvent:theEvent];
		}
	}
	if (!r)
	{
		r = [super performKeyEquivalent:theEvent];
	}
	return r;
}

#pragma mark Actions

- (void)performClose:(id)sender
{
	BOOL shouldClose = YES;
	id delegate = [self delegate];
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(window:shouldClose:)])
		{
			shouldClose = [delegate window:self shouldClose:sender];
		}
	}
	if (shouldClose)
	{
		[super performClose:sender];
	}
}

#pragma mark Construction

- (void)constructInnerView
{
	innerView = [[SBInnerView alloc] initWithFrame:[self innerRect]];
	[innerView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
	[self.contentView addSubview:innerView];
}

#pragma mark Menu validation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	BOOL r = YES;
	SEL selector = [menuItem action];
	if (selector == @selector(toggleToolbarShown:))
	{
		[menuItem setTitle:[self.toolbar isVisible] ? NSLocalizedString(@"Hide Toolbar", nil) : NSLocalizedString(@"Show Toolbar", nil)];
		r = !self.coverWindow;
	}
	else {
		r = [super validateMenuItem:menuItem];
	}
	return r;
}

#pragma mark Setter

- (void)setTitle:(NSString *)title
{
	if (!title)
	{
		title = [NSString string];
	}
	[super setTitle:title];
}

- (void)setToolbar:(SBToolbar *)toolbar
{
	if (self.toolbar != toolbar)
	{
		[super setToolbar:(NSToolbar *)toolbar];
	}
}

- (void)setContentView:(NSView *)contentView
{
	[super setContentView:contentView];
}

- (void)setTabbar:(SBTabbar *)inTabbar
{
	if (tabbar != inTabbar)
	{
		[inTabbar retain];
		[tabbar release];
		tabbar = inTabbar;
		NSRect r = [self tabbarRect];
		if (!NSEqualRects(tabbar.frame, r))
		{
			tabbar.frame = r;
		}
		[tabbar setAutoresizingMask:(NSViewWidthSizable | NSViewMinYMargin)];
		[self.innerView addSubview:(NSView *)tabbar];
	}
}

- (void)setSplitView:(SBSplitView *)inSplitView
{
	if (splitView != inSplitView)
	{
		[inSplitView retain];
		[splitView release];
		splitView = inSplitView;
		NSRect r = [self splitViewRect];
		if (!NSEqualRects(splitView.frame, r))
		{
			[splitView setFrame:r];
		}
		[splitView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
		[self.innerView addSubview:(NSView *)splitView];
	}
}

- (void)setKeyView:(BOOL)isKeyView
{
	if (keyView != isKeyView)
	{
		keyView = isKeyView;
	}
}

#pragma mark Actions

- (void)zoom:(id)sender
{
	if (!coverWindow)
	{
		[super zoom:sender];
	}
}

- (void)destructCoverWindow
{
	if (coverWindow)
	{
		[self removeChildWindow:coverWindow];
		[coverWindow close];
		coverWindow = nil;
	}
	[self setShowsToolbarButton:YES];
}

- (void)showCoverWindow:(SBView *)view
{
	NSRect r = view.frame;
	NSSize size = self.innerRect.size;
	r.origin.x = (size.width - r.size.width) / 2;
	r.origin.y = (size.height - r.size.height) / 2;
	view.frame = r;
	[self constructCoverWindowWithView:view];
}

- (void)constructCoverWindowWithView:(id)view
{
	SBBLKGUIScrollView *scrollView = nil;
	NSRect vr = [view frame];
	NSRect br = self.splitView.bounds;
	NSRect r = NSZeroRect;
	BOOL hasHorizontalScroller = vr.size.width > br.size.width;
	BOOL hasVerticalScroller = vr.size.height > br.size.height;
	r.origin.x = hasHorizontalScroller ? br.origin.x : vr.origin.x;
	r.size.width = hasHorizontalScroller ? br.size.width : vr.size.width;
	r.origin.y = hasVerticalScroller ? br.origin.y : vr.origin.y;
	r.size.height = hasVerticalScroller ? br.size.height : vr.size.height;
	[self destructCoverWindow];
	coverWindow = [[SBCoverWindow alloc] initWithParentWindow:self size:br.size];
	scrollView = [[[SBBLKGUIScrollView alloc] initWithFrame:NSIntegralRect(r)] autorelease];
	[scrollView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
	[scrollView setHasHorizontalScroller:hasHorizontalScroller];
	[scrollView setHasVerticalScroller:hasVerticalScroller];
	[scrollView setDrawsBackground:NO];
	[[coverWindow contentView] addSubview:scrollView];
	[scrollView setDocumentView:view];
	[self setShowsToolbarButton:NO];
	
#if 1
	[self addChildWindow:coverWindow ordered:NSWindowAbove];
	[coverWindow makeKeyWindow];
#else
	NSViewAnimation *animation = nil;
	NSMutableDictionary *animationInfo = [NSMutableDictionary dictionaryWithCapacity:0];
	[[coverWindow contentView] setHidden:YES];
	[NSApp beginSheet:coverWindow modalForWindow:self modalDelegate:self didEndSelector:@selector(coverWindowDidEnd:returnCode:contextInfo:) contextInfo:nil];
    
	[animationInfo setObject:[coverWindow contentView] forKey:NSViewAnimationTargetKey];
	[animationInfo setObject:NSViewAnimationFadeInEffect forKey:NSViewAnimationEffectKey];
	animation = [[[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:animationInfo]] autorelease];
    [animation setDuration:0.35];
    [animation setAnimationBlockingMode:NSAnimationNonblockingThreaded];
    [animation setAnimationCurve:NSAnimationEaseIn];
	[animation setDelegate:self];
	[animation startAnimation];
	[[coverWindow contentView] setHidden:NO];
#endif
}

#if 1
- (void)hideCoverWindow
{
	[self removeChildWindow:coverWindow];
	[coverWindow orderOut:nil];
	[self destructCoverWindow];
	[self makeKeyWindow];
}
#else
- (void)animationDidStop:(NSAnimation *)animation
{
	if ([coverWindow contentView])
	{
		[[coverWindow contentView] setHidden:NO];
	}
}

- (void)coverWindowDidEnd:(NSWindow *)window returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	[self destructCoverWindow];
}

- (void)hideCoverWindow
{
	[NSApp endSheet:coverWindow];
}
#endif

- (void)hideToolbar
{
	if ([self.toolbar isVisible])
		[self toggleToolbarShown:self];
}

- (void)showToolbar
{
	if (![self.toolbar isVisible])
		[self toggleToolbarShown:self];
}

- (void)hideTabbar
{
	if (tabbarVisivility)
	{
		tabbarVisivility = NO;
		NSRect r = NSZeroRect;
		r = [self tabbarRect];
		if (!NSEqualRects(tabbar.frame, r))
		{
			tabbar.frame = r;
		}
		r = [self splitViewRect];
		if (!NSEqualRects(splitView.frame, r))
		{
			splitView.frame = r;
		}
	}
}

- (void)showTabbar
{
	if (!tabbarVisivility)
	{
		tabbarVisivility = YES;
		NSRect r = NSZeroRect;
		r = [self tabbarRect];
		if (!NSEqualRects(tabbar.frame, r))
		{
			tabbar.frame = r;
		}
		r = [self splitViewRect];
		if (!NSEqualRects(splitView.frame, r))
		{
			splitView.frame = r;
		}
	}
}

- (void)flip
{
	SBBLKGUIButton *doneButton = nil;
	NSRect doneRect = NSZeroRect;
	doneRect.size.width = 105.0;
	doneRect.size.height = 24.0;
	doneButton = [[[SBBLKGUIButton alloc] initWithFrame:doneRect] autorelease];
	[doneButton setTitle:NSLocalizedString(@"Done", nil)];
	[doneButton setTarget:self];
	[doneButton setAction:@selector(doneFlip)];
	[doneButton setEnabled:YES];
	[doneButton setKeyEquivalent:@"\r"];
	[self flip:(SBView *)doneButton];
}

- (void)flip:(SBView *)view
{
	NSRect r = self.frame;
	NSRect br = r;
	br.size.width = kSBBackWindowFrameWidth;
	br.size.height = kSBBackWindowFrameHeight;
	br.origin.x = self.frame.origin.x + (self.frame.size.width - br.size.width) / 2;
	br.origin.y = self.frame.origin.y + (self.frame.size.height - br.size.height) / 2;
	br.size.height -= 23.0;
	backWindow = [[NSWindow alloc] initWithContentRect:br styleMask:(NSTitledWindowMask | NSClosableWindowMask) backing:NSBackingStoreBuffered defer:YES];
	[backWindow setBackgroundColor:[NSColor colorWithCalibratedRed:SBWindowBackColors[0] green:SBWindowBackColors[1] blue:SBWindowBackColors[2] alpha:SBWindowBackColors[3]]];
	[view setFrame:NSMakeRect((br.size.width - view.frame.size.width) / 2, (br.size.height - view.frame.size.height) / 2, view.frame.size.width, view.frame.size.height)];
	[[backWindow contentView] addSubview:view];
	[backWindow makeKeyAndOrderFront:nil];
	[self setAlphaValue:0];
}

- (void)doneFlip
{
	if (backWindow)
	{
		[backWindow close];
		backWindow = nil;
	}
	[self setAlphaValue:1];
}

@end
