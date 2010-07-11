/*

SBDrawer.m
 
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

#import "SBDrawer.h"
#import "SBDownloadsView.h"
#import "SBUtil.h"


@implementation SBDrawer

@synthesize view;

- (NSRect)availableRect
{
	NSRect r = self.bounds;
	if (self.subview)
	{
		NSRect sr = self.subview.frame;
		r.size.height -= NSMaxY(sr);
		r.origin.y = NSMaxY(sr);
	}
	return r;
}

- (void)dealloc
{
	[view release];
	[super dealloc];
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldBoundsSize
{
	[super resizeSubviewsWithOldSize:oldBoundsSize];
	if (view)
	{
		if ([view respondsToSelector:@selector(layoutItems:)])
		{
			[(id)view layoutItems:NO];
		}
	}
}

- (void)setView:(NSView *)aView
{
	if (view != aView)
	{
		[aView retain];
		[view release];
		view = aView;
		if (!scrollView)
		{
			scrollView = [[SBBLKGUIScrollView alloc] initWithFrame:[self availableRect]];
			[scrollView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
			[scrollView setAutohidesScrollers:YES];
			[scrollView setHasHorizontalScroller:NO];
			[scrollView setHasVerticalScroller:YES];
			[scrollView setBackgroundColor:[NSColor colorWithCalibratedRed:SBBackgroundColors[0] green:SBBackgroundColors[1] blue:SBBackgroundColors[2] alpha:SBBackgroundColors[3]]];
			[scrollView setDrawsBackground:YES];
			[self addSubview:scrollView];
		}
		[scrollView setDocumentView:view];
		[[scrollView contentView] setCopiesOnScroll:YES];
	}
}

#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	NSRect bounds = self.bounds;
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
	NSUInteger count = 2;
	CGFloat locations[count];
	CGPoint points[count];
	CGFloat lh = 1.0;
	
	// Background
	[[NSColor colorWithCalibratedRed:SBWindowBackColors[0] green:SBWindowBackColors[1] blue:SBWindowBackColors[2] alpha:SBWindowBackColors[3]] set];
	NSRectFill(rect);
	
	// Bottom
	locations[0] = 0.0;
	locations[1] = 1.0;
	points[0] = CGPointZero;
	points[1] = CGPointMake(0.0, kSBBottombarHeight);
	SBDrawGradientInContext(ctx, count, locations, SBBottombarColors, points);
	
	// Line
	[[NSColor colorWithCalibratedWhite:1.0 alpha:0.3] set];
	NSRectFill(NSMakeRect(bounds.origin.x, 0.0, bounds.size.width, lh));
	
}

@end
