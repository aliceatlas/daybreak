/*

SBSidebar.m
 
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

#import "SBSidebar.h"
#import "SBButton.h"
#import "SBBookmarks.h"
#import "SBBookmarksView.h"
#import "SBUtil.h"

@implementation SBSidebar

@synthesize view;
@synthesize drawer;
@synthesize bottombar;
@synthesize position;
@synthesize siderbarDelegate;
@dynamic visibleDrawer;
@dynamic animating;
@synthesize drawerHeight;

- (id)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		drawerHeight = 0;
		[self setVertical:NO];
		[self setDividerStyle:NSSplitViewDividerStyleThin];
	}
	return self;
}

- (void)dealloc
{
	[view release];
	[self destructDrawer];
	[self destructBottombar];
	[self destructDividerAnimation];
	siderbarDelegate = nil;
	[super dealloc];
}

#pragma mark Getter

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p frame = %@>", [self className], self, NSStringFromRect(self.frame)];
}

- (NSRect)viewRect
{
	NSRect r = NSZeroRect;
	r = self.bounds;
	r.size.height = self.bounds.size.height - drawerHeight;
	return r;
}

- (NSRect)drawerRect
{
	NSRect r = NSZeroRect;
	r = self.bounds;
	r.size.height = drawerHeight - kSBBottombarHeight;
	return r;
}

- (NSRect)bottombarRect
{
	NSRect r = NSZeroRect;
	r = self.bounds;
	r.size.height = kSBBottombarHeight;
	return r;
}

- (BOOL)visibleDrawer
{
	return drawer.frame.size.height > kSBBottombarHeight;
}

- (SBSideBottombar *)bottombar
{
	return bottombar;
}

- (BOOL)animating
{
	return (_divideAnimation != nil);
}

- (void)setFrame:(NSRect)frame
{
	[super setFrame:frame];
}

#pragma mark Delegate

- (void)downloadsViewDidRemoveAllItems:(SBDownloadsView *)aDownloadsView
{
	[self closeDrawer:nil];
}

- (void)bottombarDidSelectedOpen:(SBSideBottombar *)inBottombar
{
	if (siderbarDelegate)
	{
		if ([siderbarDelegate respondsToSelector:@selector(sidebarShouldOpen:)])
		{
			[siderbarDelegate performSelector:@selector(sidebarShouldOpen:) withObject:self];
		}
	}
}

- (void)bottombarDidSelectedClose:(SBSideBottombar *)inBottombar
{
	if (siderbarDelegate)
	{
		if ([siderbarDelegate respondsToSelector:@selector(sidebarShouldClose:)])
		{
			[siderbarDelegate performSelector:@selector(sidebarShouldClose:) withObject:self];
		}
	}
}

- (void)bottombarDidSelectedDrawerOpen:(SBSideBottombar *)inBottombar
{
	if (!self.animating)
		[self openDrawer:nil];
	if (siderbarDelegate)
	{
		if ([siderbarDelegate respondsToSelector:@selector(sidebarDidOpenDrawer:)])
		{
			[siderbarDelegate performSelector:@selector(sidebarDidOpenDrawer:) withObject:self];
		}
	}
}

- (void)bottombarDidSelectedDrawerClose:(SBSideBottombar *)inBottombar
{
	if (!self.animating)
		[self closeDrawer:nil];
}

- (void)bottombar:(SBSideBottombar *)inBottombar didChangeSize:(CGFloat)size
{
	if ([view respondsToSelector:@selector(setCellWidth:)])
	{
		[(SBBookmarksView *)view setCellWidth:size];
	}
}

- (void)animationDidEnd:(NSAnimation *)animation
{
	if (animation == _divideAnimation)
	{
		[self destructDividerAnimation];
		[self adjustSubviews];
	}
}

#pragma mark Setter

- (void)setView:(NSView *)aView
{
	if (view != aView)
	{
		if (view)
		{
			if ([view respondsToSelector:@selector(setDataSource:)])
				[(id)view setDataSource:nil];
			[view removeFromSuperview];
			[view release];
			view = nil;
		}
		view = [aView retain];
		[view setFrame:[self viewRect]];
		if ([[self subviews] count] > 0)
			[self addSubview:view positioned:NSWindowBelow relativeTo:[[self subviews] objectAtIndex:0]];
		else
			[self addSubview:view];
	}
}

- (void)setDrawer:(SBDrawer *)inDrawer
{
	if (drawer != inDrawer)
	{
		if (drawer)
		{
			[drawer removeFromSuperview];
			[drawer release];
			drawer = nil;
		}
		drawer = [inDrawer retain];
		[self addSubview:drawer];
	}
}

- (void)setPosition:(SBSidebarPosition)inPosition
{
	if (position != inPosition)
	{
		position = inPosition;
		bottombar.position = position;
	}
}

#pragma mark SplitView

- (CGFloat)dividerThickness
{
	return 1.0;
}

- (void)drawDividerInRect:(NSRect)aRect
{
	[[NSColor colorWithCalibratedWhite:0.0 alpha:1.0] set];
	NSRectFill(aRect);
}

#pragma mark Destruction

- (void)destructDrawer
{
	if (drawer)
	{
		[drawer removeFromSuperview];
		[drawer release];
		drawer = nil;
	}
}

- (void)destructBottombar
{
	if (bottombar)
	{
		[bottombar removeFromSuperview];
		[bottombar release];
		bottombar = nil;
	}
}

- (void)destructDividerAnimation
{
	if (_divideAnimation)
	{
		[_divideAnimation release];
		_divideAnimation = nil;
	}
}

#pragma mark Construction

- (void)constructBottombar
{
	[self destructBottombar];
	bottombar = [[SBSideBottombar alloc] initWithFrame:[self bottombarRect]];
	bottombar.delegate = self;
	bottombar.position = position;
	bottombar.drawerVisibility = self.visibleDrawer;
	[bottombar setAutoresizingMask:(NSViewWidthSizable | NSViewMaxYMargin)];
	[drawer addSubview:bottombar];
}

#pragma mark Actions

- (void)setDividerPosition:(CGFloat)pos
{
	[self setDividerPosition:pos animate:NO];
}

- (void)setDividerPosition:(CGFloat)pos animate:(BOOL)animate
{
	NSRect r0 = NSZeroRect;
	NSRect r1 = NSZeroRect;
	NSView *subview0 = nil;
	NSView *subview1 = nil;
	subview0 = view;
	subview1 = drawer;
	r0 = subview0.frame;
	r1 = subview1.frame;
	r0.size.height = pos;
	r1.origin.y = r0.size.height;
	r1.size.height = self.bounds.size.height - pos;
	if (animate)
	{
		NSTimeInterval duration = 0.25;
		NSMutableArray *animations = [NSMutableArray arrayWithCapacity:0];
		NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:0];
		[info setObject:subview0 forKey:NSViewAnimationTargetKey];
		[info setObject:[NSValue valueWithRect:r0] forKey:NSViewAnimationEndFrameKey];
		[animations addObject:[[info copy] autorelease]];
		[info removeAllObjects];
		[info setObject:subview1 forKey:NSViewAnimationTargetKey];
		[info setObject:[NSValue valueWithRect:r1] forKey:NSViewAnimationEndFrameKey];
		[animations addObject:[[info copy] autorelease]];
		[self destructDividerAnimation];
		_divideAnimation = [[NSViewAnimation alloc] initWithViewAnimations:animations];
		[_divideAnimation setDuration:duration];
		[_divideAnimation setDelegate:self];
		[_divideAnimation startAnimation];
	}
	else {
		[subview0 setFrame:r0];
		[subview1 setFrame:r1];
		[self adjustSubviews];
	}
}

- (void)openDrawer:(id)sender
{
	CGFloat pos = self.bounds.size.height - drawerHeight;
	[self setDividerPosition:pos animate:YES];
	bottombar.drawerVisibility = YES;
}

- (void)closeDrawer:(id)sender
{
	[self closeDrawerWithAnimatedFlag:YES];
}

- (void)closeDrawerWithAnimatedFlag:(BOOL)animated
{
	CGFloat pos = self.bounds.size.height - kSBBottombarHeight;
	[self setDividerPosition:pos animate:animated];
	bottombar.drawerVisibility = NO;
}

- (void)showBookmarkItemIndexes:(NSIndexSet *)indexes
{
	
}

@end

@implementation SBSideBottombar

@synthesize sizeSlider;
@synthesize position;
@synthesize delegate;
@synthesize drawerVisibility;

- (id)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		position = -1;
		buttons = [[NSMutableArray alloc] initWithCapacity:0];
		[self constructDrawerButton];
//		[self constructNewFolderButton];
		[self constructSizeSlider];
	}
	return self;
}

- (void)dealloc
{
	[self destructDrawerButton];
	[self destructNewFolderButton];
	[self destructSizeSlider];
	[buttons release];
	delegate = nil;
	[super dealloc];
}

#pragma mark Rects

- (CGFloat)buttonWidth
{
	return self.bounds.size.height;
}

- (CGFloat)sliderWidth
{
	CGFloat width = self.bounds.size.width - kSBSidebarResizableWidth * 2 - [self sliderSideMargin] * 2;
	return width > 120.0 ? 120.0 : width;
}

- (CGFloat)sliderSideMargin
{
	return 10.0;
}

- (NSRect)resizableRect
{
	NSRect r = NSZeroRect;
	r.size.width = kSBSidebarResizableWidth;
	r.size.height = self.bounds.size.height;
	if (position == SBSidebarLeftPosition)
	{
		r.origin.x = self.bounds.size.width - r.size.width;
	}
	return r;
}

- (NSRect)drawerButtonRect
{
	NSRect r = NSZeroRect;
	r.size.width = r.size.height = [self buttonWidth];
	if (position == SBSidebarLeftPosition)
	{
		r.origin.x = self.bounds.size.width - (r.size.width + kSBSidebarResizableWidth);
	}
	else if (position == SBSidebarRightPosition)
	{
		r.origin.x = kSBSidebarResizableWidth;
	}
	return r;
}

- (NSRect)newFolderButtonRect
{
	NSRect r = NSZeroRect;
	NSRect drawerButtonRect = [self drawerButtonRect];
	r.size.width = kSBSidebarNewFolderButtonWidth;
	r.size.height = [self buttonWidth];
	if (position == SBSidebarLeftPosition)
	{
		r.origin.x = NSMaxX(drawerButtonRect) - kSBSidebarNewFolderButtonWidth;
	}
	else if (position == SBSidebarRightPosition)
	{
		r.origin.x = NSMaxX(drawerButtonRect);
	}
	return r;
}

- (NSRect)sizeSliderRect
{
	NSRect r = NSZeroRect;
	CGFloat sideMargin = [self sliderSideMargin];
	CGFloat leftMargin = sideMargin;
	CGFloat rightMargin = sideMargin + kSBSidebarResizableWidth;
	r.size.width = [self sliderWidth];
	r.size.height = 21.0;
	if (position == SBSidebarLeftPosition)
	{
		r.origin.x = leftMargin;
	}
	else if (position == SBSidebarRightPosition)
	{
		r.origin.x = self.bounds.size.width - (r.size.width + rightMargin);
	}
	return r;
}

- (void)setFrame:(NSRect)frame
{
	if (!NSEqualRects(frame, self.frame))
	{
		[super setFrame:frame];
		[self adjustButtons];
	}
}

- (void)setPosition:(SBSidebarPosition)inPosition
{
	if (position != inPosition)
	{
		position = inPosition;
		[drawerButton setFrame:[self drawerButtonRect]];
		[newFolderButton setFrame:[self newFolderButtonRect]];
		[sizeSlider setFrame:[self sizeSliderRect]];
		if (position == SBSidebarLeftPosition)
		{
			[drawerButton setAutoresizingMask:(NSViewMinXMargin)];
			[newFolderButton setAutoresizingMask:(NSViewMinXMargin)];
		}
		else if (position == SBSidebarRightPosition)
		{
			[drawerButton setAutoresizingMask:(NSViewMaxXMargin)];
			[newFolderButton setAutoresizingMask:(NSViewMaxXMargin)];
		}
		[self adjustButtons];
		[self setNeedsDisplay:YES];
	}
}

- (void)setDrawerVisibility:(BOOL)inDrawerVisibility
{
	if (drawerVisibility != inDrawerVisibility)
	{
		drawerVisibility = inDrawerVisibility;
		if (drawerVisibility)
		{
			drawerButton.image = [NSImage imageNamed:@"ResizerDown.png"];
		}
		else {
			drawerButton.image = [NSImage imageNamed:@"ResizerUp.png"];
		}
	}
}

- (void)destructDrawerButton
{
	if (drawerButton)
	{
		[drawerButton removeFromSuperview];
		[drawerButton release];
		drawerButton = nil;
	}
}

- (void)destructNewFolderButton
{
	if (newFolderButton)
	{
		[newFolderButton removeFromSuperview];
		[newFolderButton release];
		newFolderButton = nil;
	}
}

- (void)destructSizeSlider
{
	if (sizeSlider)
	{
		[sizeSlider removeFromSuperview];
		[sizeSlider release];
		sizeSlider = nil;
	}
}

- (void)constructDrawerButton
{
	[self destructDrawerButton];
	drawerButton = [[SBButton alloc] initWithFrame:[self drawerButtonRect]];
	if (position == SBSidebarLeftPosition)
	{
		[drawerButton setAutoresizingMask:(NSViewMinXMargin)];
	}
	drawerButton.target = self;
	drawerButton.action = @selector(toggleDrawer);
	[self addSubview:drawerButton];
	[buttons addObject:drawerButton];
}

- (void)constructNewFolderButton
{
	[self destructNewFolderButton];
	newFolderButton = [[SBButton alloc] initWithFrame:[self newFolderButtonRect]];
	if (position == SBSidebarLeftPosition)
	{
		[newFolderButton setAutoresizingMask:(NSViewMinXMargin)];
	}
	newFolderButton.title = NSLocalizedString(@"New Folder", nil);
	newFolderButton.target = self;
	newFolderButton.action = @selector(newFolder);
	[self addSubview:newFolderButton];
	[buttons addObject:newFolderButton];
}

- (void)constructSizeSlider
{
	[self destructSizeSlider];
	sizeSlider = [[SBBLKGUISlider alloc] initWithFrame:[self sizeSliderRect]];
	[[sizeSlider cell] setControlSize:NSSmallControlSize];
	[sizeSlider setMinValue:kSBBookmarkCellMinWidth];
	[sizeSlider setMaxValue:kSBBookmarkCellMaxWidth];
	[sizeSlider setFloatValue:kSBBookmarkCellMinWidth];
	[sizeSlider setTarget:self];
	[sizeSlider setAction:@selector(slide)];
	[sizeSlider setAutoresizingMask:(NSViewMinXMargin)];
	[self addSubview:sizeSlider];
}

#pragma mark Actions

- (void)adjustButtons
{
	NSRect validRect = NSZeroRect;
	NSRect sliderRect = [self sizeSliderRect];
	if (position == SBSidebarLeftPosition)
	{
		validRect.origin.x = NSMaxX(sliderRect);
		validRect.size.width = self.bounds.size.width - NSMaxX(sliderRect) - kSBSidebarResizableWidth;
		validRect.size.height = self.bounds.size.height;
	}
	else if (position == SBSidebarRightPosition)
	{
		validRect.origin.x = kSBSidebarResizableWidth;
		validRect.size.width = sliderRect.origin.x - kSBSidebarResizableWidth;
		validRect.size.height = self.bounds.size.height;
	}
	for (SBButton *button in buttons)
	{
		button.hidden = !NSContainsRect(validRect, button.frame);
	}
	sizeSlider.frame = [self sizeSliderRect];
}

#pragma mark Execute

- (void)open
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(bottombarDidSelectedOpen:)])
		{
			[delegate performSelector:@selector(bottombarDidSelectedOpen:) withObject:self];
		}
	}
}

- (void)close
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(bottombarDidSelectedClose:)])
		{
			[delegate performSelector:@selector(bottombarDidSelectedClose:) withObject:self];
		}
	}
}

- (void)toggleDrawer
{
	self.drawerVisibility = !drawerVisibility;
	if (delegate)
	{
		if (drawerVisibility)
		{
			if ([delegate respondsToSelector:@selector(bottombarDidSelectedDrawerOpen:)])
			{
				[delegate performSelector:@selector(bottombarDidSelectedDrawerOpen:) withObject:self];
			}
		}
		else {
			if ([delegate respondsToSelector:@selector(bottombarDidSelectedDrawerClose:)])
			{
				[delegate performSelector:@selector(bottombarDidSelectedDrawerClose:) withObject:self];
			}
		}
	}
}

- (void)newFolder
{
	
}

- (void)slide
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(bottombar:didChangeSize:)])
		{
			CGFloat value = [sizeSlider floatValue];
			if (value > kSBBookmarkCellMaxWidth)
				value = kSBBookmarkCellMaxWidth;
			if (value < kSBBookmarkCellMinWidth)
				value = kSBBookmarkCellMinWidth;
			[delegate bottombar:self didChangeSize:value];
			if (value != [sizeSlider floatValue])
				[sizeSlider setFloatValue:value];
		}
	}
}

#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
	
	[super drawRect:rect];
	
	NSRect resizableRect = [self resizableRect];
	CGRect r = NSRectToCGRect(resizableRect);
	NSImage *resizerImage = [NSImage imageNamed:@"Resizer.png"];
	[resizerImage drawInRect:resizableRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	if (position == SBSidebarLeftPosition)
	{
		r.origin.x = r.origin.x - 1;
		r.size.width = 1;
	}
	else if (position == SBSidebarRightPosition)
	{
		r.origin.x = CGRectGetMaxX(r) + 1;
		r.size.width = 1;
	}
	CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 1.0);
	CGContextFillRect(ctx, r);
	if (position == SBSidebarLeftPosition)
	{
		r.origin.x = r.origin.x + 1;
	}
	else if (position == SBSidebarRightPosition)
	{
		r.origin.x = r.origin.x + 1;
	}
	CGContextSetRGBFillColor(ctx, 0.3, 0.3, 0.3, 1.0);
	CGContextFillRect(ctx, r);
}

@end
