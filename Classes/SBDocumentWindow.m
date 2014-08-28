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
#import "SBBLKGUI.h"
#import "SBDefinitions.h"
#import "SBInnerView.h"
#import "SBSplitView.h"
#import "SBTabbar.h"
#import "SBUtil.h"

#import "Sunrise3-Bridging-Header.h"
#import "Sunrise3-Swift.h"

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

- (instancetype)initWithFrame:(NSRect)frame delegate:(id)delegate tabbarVisivility:(BOOL)inTabbarVisivility
{
	NSUInteger styleMask = NSTitledWindowMask | NSClosableWindowMask |NSMiniaturizableWindowMask | NSResizableWindowMask;
	if (self = [super initWithContentRect:frame styleMask:styleMask backing:NSBackingStoreBuffered defer:YES])
	{
		[self constructInnerView];
        self.minSize = NSMakeSize(kSBDocumentWindowMinimumSizeWidth, kSBDocumentWindowMinimumSizeHeight);
        self.delegate = delegate;
        self.releasedWhenClosed = YES;
        self.showsToolbarButton = YES;
        self.oneShot = YES;
        self.acceptsMouseMovedEvents = YES;
        self.collectionBehavior = NSWindowCollectionBehaviorFullScreenPrimary | NSWindowCollectionBehaviorFullScreenAuxiliary;
        self.animationBehavior = NSWindowAnimationBehaviorNone;
		tabbarVisivility = inTabbarVisivility;
	}
	return self;
}

- (void)dealloc
{
    self.delegate = nil;
	[self destructCoverWindow];
}

- (BOOL)isCovering
{
	NSWindow *keyWindow = [NSApp keyWindow];
	return keyWindow ? keyWindow == coverWindow : NO;
}

- (BOOL)canBecomeKeyWindow
{
	BOOL r = self.covering ? NO : super.canBecomeKeyWindow;
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
	return super.title;
}

- (SBToolbar *)toolbar
{
	return (SBToolbar *)super.toolbar;
}

- (NSView *)contentView
{
	return super.contentView;
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
	NSRect innerRect = self.innerRect;
	r.size.width = innerRect.size.width;
	r.size.height = self.tabbarHeight;
	r.origin.y = tabbarVisivility ? innerRect.size.height - r.size.height : innerRect.size.height;
	return r;
}

- (NSRect)splitViewRect
{
	NSRect r = NSZeroRect;
	NSRect innerRect = self.innerRect;
	r.size.width = innerRect.size.width;
	r.size.height = tabbarVisivility ? innerRect.size.height - self.tabbarHeight : innerRect.size.height;
	return r;
}

- (CGFloat)sheetPosition
{
	CGFloat position = self.splitViewRect.size.height;
	return position;
}

#pragma mark Responding

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent
{
	BOOL r = NO;
	if (self.delegate)
	{
		if ([self.delegate respondsToSelector:@selector(window:shouldHandleKeyEvent:)])
		{
			r = [(id<SBDocumentWindowDelegate>)self.delegate window:self shouldHandleKeyEvent:theEvent];
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
	id delegate = self.delegate;
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
	innerView = [[SBInnerView alloc] initWithFrame:self.innerRect];
    innerView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	[self.contentView addSubview:innerView];
}

#pragma mark Menu validation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	BOOL r = YES;
	SEL selector = menuItem.action;
	if (selector == @selector(toggleToolbarShown:))
	{
        menuItem.title = self.toolbar.visible ? NSLocalizedString(@"Hide Toolbar", nil) : NSLocalizedString(@"Show Toolbar", nil);
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
    super.title = title;
}

- (void)setToolbar:(SBToolbar *)toolbar
{
	if (self.toolbar != toolbar)
	{
        super.toolbar = toolbar;
	}
}

- (void)setContentView:(NSView *)contentView
{
    super.contentView = contentView;
}

- (void)setTabbar:(SBTabbar *)inTabbar
{
	if (tabbar != inTabbar)
	{
		tabbar = inTabbar;
		NSRect r = self.tabbarRect;
		if (!NSEqualRects(tabbar.frame, r))
		{
			tabbar.frame = r;
		}
        tabbar.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin;
		[self.innerView addSubview:tabbar];
	}
}

- (void)setSplitView:(SBSplitView *)inSplitView
{
	if (splitView != inSplitView)
	{
		splitView = inSplitView;
		NSRect r = self.splitViewRect;
		if (!NSEqualRects(splitView.frame, r))
		{
            splitView.frame = r;
		}
        splitView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
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
    self.showsToolbarButton = YES;
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

- (void)constructCoverWindowWithView:(NSView *)view
{
	SBBLKGUIScrollView *scrollView = nil;
	NSRect vr = view.frame;
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
	scrollView = [[SBBLKGUIScrollView alloc] initWithFrame:NSIntegralRect(r)];
    scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    scrollView.hasHorizontalScroller = hasHorizontalScroller;
    scrollView.hasVerticalScroller = hasVerticalScroller;
    scrollView.drawsBackground = NO;
	[coverWindow.contentView addSubview:scrollView];
    coverWindow.releasedWhenClosed = NO;
    scrollView.documentView = view;
    self.showsToolbarButton = NO;
	
#if 1
	[self addChildWindow:coverWindow ordered:NSWindowAbove];
	[coverWindow makeKeyWindow];
#else
	NSViewAnimation *animation = nil;
	NSDictionary *animationInfo = nil;
    coverWindow.contentView.hidden = YES;
	[NSApp beginSheet:coverWindow modalForWindow:self modalDelegate:self didEndSelector:@selector(coverWindowDidEnd:returnCode:contextInfo:) contextInfo:nil];
    
    animationInfo = @{NSViewAnimationTargetKey: coverWindow.contentView,
                      NSViewAnimationEffectKey: NSViewAnimationFadeInEffect};
	animation = [[NSViewAnimation alloc] initWithViewAnimations:@[animationInfo]];
    animation.duration = 0.35;
    animation.animationBlockingMode = NSAnimationNonblockingThreaded;
    animation.animationCurve = NSAnimationEaseIn;
    animation.delegate = self;
	[animation startAnimation];
    coverWindow.contentView.hidden = NO;
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
	if (coverWindow.contentView)
	{
        coverWindow.contentView.hidden = NO;
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
	if (self.toolbar.visible)
		[self toggleToolbarShown:self];
}

- (void)showToolbar
{
    if (self.toolbar.visible)
        [self toggleToolbarShown:self];
}

- (void)hideTabbar
{
	if (tabbarVisivility)
	{
		tabbarVisivility = NO;
		NSRect r = NSZeroRect;
		r = self.tabbarRect;
		if (!NSEqualRects(tabbar.frame, r))
		{
			tabbar.frame = r;
		}
		r = self.splitViewRect;
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
		r = self.tabbarRect;
		if (!NSEqualRects(tabbar.frame, r))
		{
			tabbar.frame = r;
		}
		r = self.splitViewRect;
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
	doneButton = [[SBBLKGUIButton alloc] initWithFrame:doneRect];
    doneButton.title = NSLocalizedString(@"Done", nil);
    doneButton.target = self;
    doneButton.action = @selector(doneFlip);
    doneButton.enabled = YES;
	doneButton.keyEquivalent = @"\r";
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
	backWindow.backgroundColor = [NSColor colorWithCalibratedRed:SBWindowBackColors[0] green:SBWindowBackColors[1] blue:SBWindowBackColors[2] alpha:SBWindowBackColors[3]];
    backWindow.releasedWhenClosed = NO;
	view.frame = NSMakeRect((br.size.width - view.frame.size.width) / 2, (br.size.height - view.frame.size.height) / 2, view.frame.size.width, view.frame.size.height);
	[backWindow.contentView addSubview:view];
	[backWindow makeKeyAndOrderFront:nil];
    self.alphaValue = 0;
}

- (void)doneFlip
{
	if (backWindow)
	{
		[backWindow close];
		backWindow = nil;
	}
    self.alphaValue = 1;
}

@end
