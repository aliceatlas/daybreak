/*

SBBookmarksView.m
 
Authoring by Atsushi Jike

Copyright 2009 Atsushi Jike. All rights reserved.

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

#import "SBBookmarksView.h"
#import "SBBookmarkListView.h"
#import "SBBookmarks.h"
#import "SBUtil.h"

@implementation SBBookmarksView

@synthesize listView;
@dynamic cellWidth;
@dynamic mode;
@synthesize delegate;

- (void)dealloc
{
	[listView release];
	[scrollView release];
	delegate = nil;
	[super dealloc];
}

- (void)setFrame:(NSRect)frame
{
	[super setFrame:frame];
	[listView layoutFrame];
	[listView layoutItemViews];
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldBoundsSize
{
//	[listView layoutFrame];
//	[listView layoutItemViews];
	[super resizeSubviewsWithOldSize:oldBoundsSize];
}

#pragma mark Destruction

- (void)destructListView
{
	if (listView)
	{
		[listView removeFromSuperview];
		[listView release];
		listView = nil;
	}
}

#pragma mark Construction

- (void)constructListView:(SBBookmarkMode)inMode
{
	NSRect r = self.bounds;
	[self destructListView];
	scrollView = [[SBBLKGUIScrollView alloc] initWithFrame:r];
	listView = [[SBBookmarkListView alloc] initWithFrame:r];
	[scrollView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
	[scrollView setBackgroundColor:[NSColor colorWithCalibratedWhite:0.25 alpha:1.0]];
	[scrollView setDrawsBackground:YES];
	[scrollView setAutohidesScrollers:YES];
	[scrollView setHasHorizontalScroller:NO];
	[scrollView setHasVerticalScroller:YES];
	listView.wrapperView = self;
	listView.cellWidth = 128.0;
	[scrollView setDocumentView:listView];
	[[scrollView contentView] setCopiesOnScroll:YES];
	[self addSubview:scrollView];
	[listView setCellSizeForMode:inMode];
	[listView createItemViews];
}

#pragma mark Getter

- (CGFloat)cellWidth
{
	return listView.cellWidth;
}

- (SBBookmarkMode)mode
{
	return listView.mode;
}

#pragma mark Setter

- (void)setCellWidth:(CGFloat)cellWidth
{
	if (listView.cellWidth != cellWidth)
	{
		listView.cellWidth = cellWidth;
		[[NSUserDefaults standardUserDefaults] setInteger:(NSInteger)cellWidth forKey:kSBBookmarkCellWidth];
	}
}

- (void)setMode:(SBBookmarkMode)mode
{
	listView.mode = mode;
	[[NSUserDefaults standardUserDefaults] setInteger:mode forKey:kSBBookmarkMode];
	[self executeDidChangeMode];
}

#pragma mark Execute

- (void)executeDidChangeMode
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(bookmarksView:didChangeMode:)])
		{
			[delegate bookmarksView:self didChangeMode:listView.mode];
		}
	}
}

- (void)executeShouldEditItemAtIndex:(NSUInteger)index
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(bookmarksView:shouldEditItemAtIndex:)])
		{
			[delegate bookmarksView:self shouldEditItemAtIndex:index];
		}
	}
}

#pragma mark Actions

- (void)addForBookmarkItem:(NSDictionary *)item
{
	[listView addForItem:item];
}

- (void)scrollToItem:(NSDictionary *)bookmarKItem
{
	SBBookmarks *bookmarks = [SBBookmarks sharedBookmarks];
	NSInteger index = [bookmarks indexOfItem:bookmarKItem];
	NSRect itemRect = [listView itemRectAtIndex:index];
	[scrollView scrollRectToVisible:itemRect];
}

- (void)reload
{
	[listView updateItems];
}

#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
	CGRect r = NSRectToCGRect(self.bounds);
	NSUInteger count = 2;
	CGFloat locations[count];
	CGFloat colors[count * 4];
	CGPoint points[count];
	locations[0] = 0.0;
	locations[1] = 1.0;
	if (keyView)
	{
		colors[0] = colors[1] = colors[2] = 0.35;
		colors[3] = 1.0;
		colors[4] = colors[5] = colors[6] = 0.1;
		colors[7] = 1.0;
	}
	else {
		colors[0] = colors[1] = colors[2] = 0.75;
		colors[3] = 1.0;
		colors[4] = colors[5] = colors[6] = 0.6;
		colors[7] = 1.0;
	}
	points[0] = CGPointZero;
	points[1] = CGPointMake(0.0, r.size.height);
	CGContextSaveGState(ctx);
	CGContextAddRect(ctx, r);
	CGContextClip(ctx);
	SBDrawGradientInContext(ctx, count, locations, colors, points);
	CGContextRestoreGState(ctx);
}

@end
