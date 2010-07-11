/*

SBSplitView.m
 
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

#import "SBSplitView.h"
#import "SBUtil.h"

#define SBSplitViewDividerThickness 1.0

@implementation SBSplitView

@synthesize view;
@synthesize sidebar;
@synthesize sidebarPosition;
@dynamic frame;
@dynamic visibleSidebar;
@dynamic animating;
@synthesize sidebarWidth;

- (id)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		dividerThickness = SBSplitViewDividerThickness;
		sidebarWidth = [[NSUserDefaults standardUserDefaults] floatForKey:kSBSidebarWidth];
		if (sidebarWidth < kSBSidebarMinimumWidth)
			sidebarWidth = kSBDefaultSidebarWidth;
		[self setVertical:YES];
		[self setDividerStyle:NSSplitViewDividerStyleThin];
	}
	return self;
}

- (void)dealloc
{
	[view release];
	[sidebar release];
	[self destructDividerAnimation];
	[super dealloc];
}

#pragma mark Rects

- (NSRect)viewRect
{
	NSRect r = NSZeroRect;
	r = self.bounds;
	r.size.width = self.bounds.size.width - sidebarWidth;
	return r;
}

- (NSRect)sidebarRect
{
	NSRect r = NSZeroRect;
	r = self.bounds;
	r.size.width = sidebarWidth;
	return r;
}

#pragma mark Getter

- (NSRect)frame
{
	return [super frame];
}

- (BOOL)animating
{
	return (_divideAnimation != nil);
}

- (BOOL)visibleSidebar
{
	return [sidebar superview] != nil;
}

#pragma mark Setter

- (void)setFrame:(NSRect)frame
{
	[super setFrame:frame];
}

- (void)setView:(NSView *)aView
{
	if (view != aView)
	{
		if (view)
		{
			[view removeFromSuperview];
			[view release];
			view = nil;
		}
		view = [aView retain];
		[self addSubview:view];
	}
}

- (void)setSidebar:(SBSidebar *)aSidebar
{
	if (sidebar != aSidebar)
	{
		if (sidebar)
		{
			[sidebar removeFromSuperview];
			[sidebar release];
			sidebar = nil;
		}
		sidebar = [aSidebar retain];
		[self addSubview:sidebar];
		[self switchView:sidebarPosition];
	}
}

- (void)setSidebarPosition:(SBSidebarPosition)inSidebarPosition
{
	if (sidebarPosition != inSidebarPosition)
	{
		sidebarPosition = inSidebarPosition;
		if (sidebar && view)
		{
			[self switchView:inSidebarPosition];
			sidebar.position = sidebarPosition;
			if ([self visibleSidebar])
			{
				[self openSidebar:nil];
			}
		}
	}
}

#pragma mark Destruction

- (void)destructDividerAnimation
{
	if (_divideAnimation)
	{
		[_divideAnimation release];
		_divideAnimation = nil;
	}
}

#pragma mark SplitView

- (CGFloat)dividerThickness
{
	return dividerThickness;
}

- (void)drawDividerInRect:(NSRect)aRect
{
	[[NSColor colorWithCalibratedWhite:0.0 alpha:1.0] set];
	NSRectFill(aRect);
}

#pragma mark Delegate

- (void)sidebarShouldOpen:(SBSidebar *)inSidebar
{
	[self openSidebar:nil];
}

- (void)sidebarShouldClose:(SBSidebar *)inSidebar
{
	[self closeSidebar:nil];
}

- (void)sidebarDidOpenDrawer:(SBSidebar *)inSidebar
{
	if ([self delegate])
	{
		if ([[self delegate] respondsToSelector:@selector(splitViewDidOpenDrawer:)])
		{
			[[self delegate] performSelector:@selector(splitViewDidOpenDrawer:) withObject:self];
		}
	}
}

- (void)adjustSubviews
{
	if (!animating)
	{
		[super adjustSubviews];
	}
}

#pragma mark Actions

- (void)openSidebar:(id)sender
{
	if (sidebarWidth < kSBSidebarMinimumWidth)
		sidebarWidth = kSBSidebarMinimumWidth;
	[self returnSidebarIfNeeded];
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSBSidebarVisibilityFlag];
}

- (void)closeSidebar:(id)sender
{
	[self takeSidebarIfNeeded];
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSBSidebarVisibilityFlag];
}

- (void)switchView:(SBSidebarPosition)position
{
	if (view && sidebar)
	{
		BOOL switching = NO;
		NSArray *subviews = [self subviews];
		NSView *subview0 = [subviews count] > 0 ? [subviews objectAtIndex:0] : nil;
		NSView *subview1 = [subviews count] > 1 ? [subviews objectAtIndex:1] : nil;
		if (position == SBSidebarLeftPosition && subview0 == view && subview1 == sidebar)
		{
			switching = YES;
		}
		else if (position == SBSidebarRightPosition && subview0 == sidebar && subview1 == view)
		{
			switching = YES;
		}
		if (switching)
		{
			if (subview0)
			{
				[subview0 retain];
				[subview0 removeFromSuperview];
				[self addSubview:subview0];
				[subview0 release];
			}
		}
	}
}

- (void)takeSidebarIfNeeded
{
	dividerThickness = 0.0;
	if ([sidebar superview] == self)
	{
		[self takeSidebar];
		sidebar.frame = [self sidebarRect];
	}
	view.frame = [self viewRect];
	[self adjustSubviews];
}

- (void)takeSidebar
{
	[sidebar retain];
	[sidebar removeFromSuperview];
}

- (void)returnSidebarIfNeeded
{
	dividerThickness = SBSplitViewDividerThickness;
	if ([sidebar superview] != self)
	{
		[self returnSidebar];
	}
	view.frame = [self viewRect];
	sidebar.frame = [self sidebarRect];
	[self adjustSubviews];
}

- (void)returnSidebar
{
	if (sidebarPosition == SBSidebarLeftPosition)
	{
		[view removeFromSuperview];
		[self addSubview:sidebar];
		[self addSubview:view];
		[sidebar release];
	}
	else if (sidebarPosition == SBSidebarRightPosition)
	{
		[self addSubview:sidebar];
	}
}

@end