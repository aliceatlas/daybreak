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
@synthesize flipped;

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
		flipWindow = nil;
		tabbarVisivility = inTabbarVisivility;
		flipped = NO;
		flipping = NO;
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
	if (flipWindow)
	{
		[flipWindow close];
		flipWindow = nil;
	}
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
			r = [[self delegate] window:self shouldHandleKeyEvent:theEvent];
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
	doneButton = [[SBBLKGUIButton alloc] initWithFrame:doneRect];
	[doneButton setTitle:NSLocalizedString(@"Done", nil)];
	[doneButton setTarget:self];
	[doneButton setAction:@selector(doneFlip)];
	[doneButton setEnabled:YES];
	[doneButton setKeyEquivalent:@"\r"];
	[self flip:(SBView *)doneButton];
}

- (void)flip:(SBView *)view
{
	if (kSBFlagIsSnowLepard)
	{
		if (!flipping)
		{
			NSRect r = self.frame;
			NSRect wr = r;
			NSRect br = r;
			CALayer *layer0 = nil;
			CALayer *layer1 = nil;
			NSView *contentView = nil;
			NSPoint margin = NSMakePoint(kSBFlipAnimationRectMargin, kSBFlipAnimationRectMargin);
			NSPoint d = NSZeroPoint;
			
			[CATransaction begin];
			[CATransaction setValue:[NSNumber numberWithFloat:0.0] forKey:kCATransactionAnimationDuration];
			[CATransaction setValue:[NSNumber numberWithBool:YES] forKey:kCATransactionDisableActions];
			
			flipping = YES;
			d.x = r.size.width < kSBBackWindowFrameWidth ? (kSBBackWindowFrameWidth - r.size.width) : 0.0;
			d.y = r.size.height < kSBBackWindowFrameHeight ? (kSBBackWindowFrameHeight - r.size.height) : 0.0;
			margin.x += d.x;
			margin.y += d.y;
			wr.origin.x -= margin.x;
			wr.origin.y -= margin.y;
			wr.size.width += margin.x * 2;
			wr.size.height += margin.y * 2;
			br.size.width = kSBBackWindowFrameWidth;
			br.size.height = kSBBackWindowFrameHeight;
			br.origin.x = self.frame.origin.x + (self.frame.size.width - br.size.width) / 2;
			br.origin.y = self.frame.origin.y + (self.frame.size.height - br.size.height) / 2;
			br.size.height -= 23.0;
			if (flipWindow)
			{
				[flipWindow close];
				flipWindow = nil;
			}
			backWindow = [[NSWindow alloc] initWithContentRect:br styleMask:(NSTitledWindowMask | NSClosableWindowMask) backing:NSBackingStoreBuffered defer:YES];
			flipWindow = [[NSWindow alloc] initWithContentRect:wr styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES];
			contentView = [flipWindow contentView];
			[contentView setWantsLayer:YES];
			[backWindow setBackgroundColor:[NSColor colorWithCalibratedRed:SBWindowBackColors[0] green:SBWindowBackColors[1] blue:SBWindowBackColors[2] alpha:SBWindowBackColors[3]]];
			[flipWindow setOpaque:NO];
			[flipWindow setBackgroundColor:[NSColor clearColor]];
			[flipWindow setIgnoresMouseEvents:NO];
			[flipWindow setHasShadow:YES];
			[view setFrame:NSMakeRect((br.size.width - view.frame.size.width) / 2, (br.size.height - view.frame.size.height) / 2, view.frame.size.width, view.frame.size.height)];
			[[backWindow contentView] addSubview:view];
			layer0 = [CALayer layer];
			layer1 = [CALayer layer];
			layer0.frame = CGRectMake(margin.x, margin.y, r.size.width, r.size.height);
			layer1.frame = CGRectMake(margin.x, margin.y, r.size.width, r.size.height);
			layer0.shadowOpacity = 0.5;
			layer0.shadowRadius = 17.5;
			layer0.shadowOffset = CGSizeMake(0.0, -15.0);
			layer1.shadowOpacity = 0.5;
			layer1.shadowRadius = 17.5;
			layer1.shadowOffset = CGSizeMake(0.0, -15.0);
			layer0.edgeAntialiasingMask = (kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge);
			layer1.edgeAntialiasingMask = (kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge);
			
			[backWindow setAlphaValue:0.0];
			[backWindow makeKeyAndOrderFront:nil];
			
			[[contentView layer] addSublayer:layer0];
			[[contentView layer] addSublayer:layer1];
			[self setFlipContents:0];
			[self setFlipContents:1];
			[self flipContents:0 back:NO];
			[CATransaction commit];
			
			[backWindow orderOut:nil];
			[backWindow setAlphaValue:1.0];
			
			[flipWindow orderWindow:NSWindowAbove relativeTo:[self windowNumber]];
			[self setAlphaValue:0];
			
			[self performSelector:@selector(flipToZero) withObject:nil afterDelay:0.0];
		}
	}
	else {
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
}

- (void)doneFlip
{
	if (kSBFlagIsSnowLepard)
	{
		NSPoint cp = NSZeroPoint;
		NSRect fr = flipWindow.frame;
		NSRect r = self.frame;
		cp.x = NSMidX(backWindow.frame);
		cp.y = NSMidY(backWindow.frame);
		fr.origin.x = cp.x - fr.size.width / 2;
		fr.origin.y = cp.y - fr.size.height / 2;
		r.origin.x = cp.x - r.size.width / 2;
		r.origin.y = cp.y - r.size.height / 2;
		[self setFlipContents:1];
		[flipWindow setFrame:fr display:NO];
		[self setFrame:r display:NO];
		[flipWindow orderFront:nil];
		if (backWindow)
		{
			[backWindow close];
			backWindow = nil;
		}
		[self performSelector:@selector(doneFlipToZero) withObject:nil afterDelay:0.0];
	}
	else {
		if (backWindow)
		{
			[backWindow close];
			backWindow = nil;
		}
		[self setAlphaValue:1];
	}
}

- (void)flipToZero
{
	[self flipAnimate:0 back:NO];
}

- (void)flipToOne
{
	[self flipAnimate:1 back:NO];
}

- (void)doneFlipToZero
{
	[self flipAnimate:0 back:YES];
}

- (void)doneFlipToOne
{
	[self flipAnimate:1 back:YES];
}

- (void)flipAnimate:(NSInteger)scene back:(BOOL)back
{
	NSArray *sublayers = [[[flipWindow contentView] layer] sublayers];
	CALayer *layer = nil;
	if (!back)
	{
		layer = [sublayers count] == 2 ? [sublayers objectAtIndex:scene] : nil;
	}
	else {
		layer = [sublayers count] == 2 ? [sublayers objectAtIndex:(scene == 0 ? 1 : 0)] : nil;
	}
	if (layer)
	{
		CAKeyframeAnimation *tanimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
		NSMutableArray *tvalues = [NSMutableArray arrayWithCapacity:0];
		CGPoint scale0 = CGPointMake(1.0, 1.0);
		CGPoint scale1 = scale0;
		
		scale1.x = kSBBackWindowFrameWidth / layer.bounds.size.width;
		scale1.y = kSBBackWindowFrameHeight / layer.bounds.size.height;
		scale0.x = scale1.x + (1.0 - scale1.x) / 2;
		scale0.y = scale1.y + (1.0 - scale1.y) / 2;
		
		if (!back)
		{
			if (scene == 0)
			{
				CATransform3D transform = CATransform3DIdentity;
				transform.m34 = 1.0 / - (layer.bounds.size.width * 2);
				transform = CATransform3DRotate(transform, 90 * M_PI / 180, 0.0, 1.0, 0.0);
				transform = CATransform3DScale(transform, scale0.x, scale0.y, 1.0);
				[tvalues addObject:[NSValue valueWithCATransform3D:CATransform3DIdentity]];
				[tvalues addObject:[NSValue valueWithCATransform3D:transform]];
				tanimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
			}
			else if (scene == 1)
			{
				CATransform3D transform0 = CATransform3DIdentity;
				CATransform3D transform1 = CATransform3DIdentity;
				transform0.m34 = 1.0 / - (layer.bounds.size.width * 2);
				transform1.m34 = 1.0 / - (layer.bounds.size.width * 2);
				transform0 = CATransform3DRotate(transform0, 90 * M_PI / 180, 0.0, 1.0, 0.0);
				transform1 = CATransform3DRotate(transform1, 180 * M_PI / 180, 0.0, 1.0, 0.0);
				transform0 = CATransform3DScale(transform0, scale0.x, scale0.y, 1.0);
				transform1 = CATransform3DScale(transform1, scale1.x, scale1.y, 1.0);
				[tvalues addObject:[NSValue valueWithCATransform3D:transform0]];
				[tvalues addObject:[NSValue valueWithCATransform3D:transform1]];
				tanimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
			}
			else {
				return;
			}
		}
		else {
			if (scene == 0)
			{
				CATransform3D transform0 = CATransform3DIdentity;
				CATransform3D transform1 = CATransform3DIdentity;
				transform0.m34 = 1.0 / - (layer.bounds.size.width * 2);
				transform1.m34 = 1.0 / - (layer.bounds.size.width * 2);
				transform0 = CATransform3DRotate(transform0, 180 * M_PI / 180, 0.0, 1.0, 0.0);
				transform1 = CATransform3DRotate(transform1, 90 * M_PI / 180, 0.0, 1.0, 0.0);
				transform0 = CATransform3DScale(transform0, scale1.x, scale1.y, 1.0);
				transform1 = CATransform3DScale(transform1, scale0.x, scale0.y, 1.0);
				[tvalues addObject:[NSValue valueWithCATransform3D:transform0]];
				[tvalues addObject:[NSValue valueWithCATransform3D:transform1]];
				tanimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
			}
			else if (scene == 1)
			{
				CATransform3D transform0 = CATransform3DIdentity;
				CATransform3D transform1 = CATransform3DIdentity;
				transform0.m34 = 1.0 / - (layer.bounds.size.width * 2);
				transform1.m34 = 1.0 / - (layer.bounds.size.width * 2);
				transform0 = CATransform3DRotate(transform0, 90 * M_PI / 180, 0.0, 1.0, 0.0);
				transform1 = CATransform3DRotate(transform1, 0 * M_PI / 180, 0.0, 1.0, 0.0);
				transform0 = CATransform3DScale(transform0, scale1.x, scale1.y, 1.0);
				transform1 = CATransform3DScale(transform1, 1.0, 1.0, 1.0);
				[tvalues addObject:[NSValue valueWithCATransform3D:transform0]];
				[tvalues addObject:[NSValue valueWithCATransform3D:transform1]];
				tanimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
			}
			else {
				return;
			}
		}
		
		tanimation.values = tvalues;
		tanimation.duration = kSBFlipAnimationDuration / 2;
		tanimation.removedOnCompletion = NO;
		tanimation.fillMode = kCAFillModeForwards;
		tanimation.delegate = self;
		[tanimation setValue:[NSNumber numberWithBool:back] forKey:@"Back"];
		[tanimation setValue:[NSNumber numberWithInteger:scene] forKey:@"Scene"];
		[layer removeAllAnimations];
		[layer addAnimation:tanimation forKey:nil];
	}
}

- (void)setFlipContents:(NSInteger)scene
{
	NSArray *sublayers = [[[flipWindow contentView] layer] sublayers];
	CALayer *layer = [sublayers count] == 2 ? [sublayers objectAtIndex:scene] : nil;
	if (layer)
	{
		CGImageRef cgimage = nil;
		CGSize size = layer.bounds.size;
		if (scene == 0)
		{
			cgimage = [self faceImage:size];
		}
		else if (scene == 1)
		{
			cgimage = [self backImage:size];
		}
		if (cgimage)
		{
			[CATransaction begin];
			[CATransaction setValue:[NSNumber numberWithFloat:0.0] forKey:kCATransactionAnimationDuration];
			layer.contents = (id)cgimage;
			[CATransaction commit];
		}
	}
}

- (void)flipContents:(NSInteger)scene back:(BOOL)back
{
	CALayer *layer = [[flipWindow contentView] layer];
	NSArray *sublayers = [layer sublayers];
	if ([sublayers count] == 2)
	{
		CALayer *visibleLayer = nil;
		CALayer *invisibleLayer = nil;
		if (!back)
		{
			if (scene == 0)
			{
				visibleLayer = [sublayers objectAtIndex:0];
				invisibleLayer = [sublayers objectAtIndex:1];
			}
			else if (scene == 1)
			{
				visibleLayer = [sublayers objectAtIndex:1];
				invisibleLayer = [sublayers objectAtIndex:0];
			}
		}
		else {
			if (scene == 0)
			{
				visibleLayer = [sublayers objectAtIndex:1];
				invisibleLayer = [sublayers objectAtIndex:0];
			}
			else if (scene == 1)
			{
				visibleLayer = [sublayers objectAtIndex:0];
				invisibleLayer = [sublayers objectAtIndex:1];
			}
		}
		[CATransaction begin];
		[CATransaction setValue:[NSNumber numberWithFloat:0.0] forKey:kCATransactionAnimationDuration];
		[CATransaction setValue:[NSNumber numberWithBool:YES] forKey:kCATransactionDisableActions];
		visibleLayer.opacity = 1.0;
		invisibleLayer.opacity = 0.0;
		[CATransaction commit];
	}
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
	if (flag)
	{
		NSNumber *backNumber = [theAnimation valueForKey:@"Back"];
		NSNumber *sceneNumber = [theAnimation valueForKey:@"Scene"];
		BOOL back = [backNumber boolValue];
		NSInteger scene = [sceneNumber integerValue];
		
		[CATransaction begin];
		[CATransaction setValue:[NSNumber numberWithFloat:0.0] forKey:kCATransactionAnimationDuration];
		[CATransaction setValue:[NSNumber numberWithBool:YES] forKey:kCATransactionDisableActions];
		
		if (!back)
		{
			if (scene == 0)
			{
				[self flipContents:1 back:back];
				[self flipAnimate:1 back:back];
			}
			else if (scene == 1)
			{
				[self showBackWindow];
				[self flipDidEnd];
			}
		}
		else {
			if (scene == 0)
			{
				[self flipContents:1 back:back];
				[self flipAnimate:1 back:back];
			}
			else if (scene == 1)
			{
				[self setAlphaValue:1.0];
				[self hideBackWindow];
				if (flipWindow)
				{
					[flipWindow close];
					flipWindow = nil;
				}
				[self flipDidEnd];
			}
		}
		
		[CATransaction commit];
	}
}

- (void)showBackWindow
{
	[backWindow makeKeyAndOrderFront:nil];
	[flipWindow orderOut:nil];
}

- (void)hideBackWindow
{
	[backWindow orderOut:nil];
}

- (void)flipDidEnd
{
	if ([self delegate])
	{
		if ([[self delegate] respondsToSelector:@selector(windowDidFinishFlipping:)])
		{
			[[self delegate] windowDidFinishFlipping:self];
		}
	}
	flipping = NO;
}

- (CGImageRef)imageOfWindow:(NSWindow *)window size:(CGSize)size flipped:(BOOL)isFlipped
{
	CGImageRef cgimage = nil;
	NSView *superview = [[window contentView] superview];
	NSImage *image = [NSImage imageWithView:superview];
	if (image)
	{
		CGContextRef ctx = nil;
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		ctx = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast));
		CGColorSpaceRelease(colorSpace);
		if (isFlipped)
		{
			CGContextScaleCTM(ctx, -1.0, 1.0);
			CGContextTranslateCTM(ctx, -size.width, 0.0);
		}
		CGContextDrawImage(ctx, CGRectMake(0.0, 0.0, size.width, size.height), [image CGImage]);
		cgimage = CGBitmapContextCreateImage(ctx);
		CGContextRelease(ctx);
	}
	return (CGImageRef)[(id)cgimage autorelease];
}

- (CGImageRef)faceImage:(CGSize)size
{
	return [self imageOfWindow:self size:size flipped:NO];
}

- (CGImageRef)backImage:(CGSize)size
{
	CGImageRef image = nil;
	image = [self imageOfWindow:backWindow size:size flipped:YES];
	return image;
}

- (CGImageRef)backgroundImage:(CGSize)size
{
	CGImageRef image = nil;
	CGContextRef ctx = nil;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	NSUInteger count = 3;
	CGFloat locations[count];
	CGFloat colors[count * 4];
	CGPoint points[count];
	CGMutablePathRef path = nil;
	
	ctx = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast));
	
	CGContextSaveGState(ctx);
	locations[0] = 1.0;
	locations[1] = 0.35;
	locations[2] = 0.0;
	colors[0] = colors[1] = colors[2] = 1.0;
	colors[3] = 1.0;
	colors[4] = colors[5] = colors[6] = 0.0;
	colors[7] = 1.0;
	colors[8] = colors[9] = colors[10] = 0.5;
	colors[11] = 1.0;
	points[0] = CGPointZero;
	points[1] = CGPointMake(0.0, size.height * locations[1]);
	points[2] = CGPointMake(0.0, size.height);
	path = CGPathCreateMutable();
	CGPathAddRect(path, nil, CGRectInset(CGRectMake(0, 0, size.width, size.height), 0.5, 0.5));
	CGContextAddPath(ctx, path);
	CGContextClip(ctx);
	SBDrawGradientInContext(ctx, count, locations, colors, points);
	CGContextRestoreGState(ctx);
	CGPathRelease(path);
	
	image = CGBitmapContextCreateImage(ctx);
	CGContextRelease(ctx);
	CGColorSpaceRelease(colorSpace);
	return (CGImageRef)[(id)image autorelease];
}

@end
