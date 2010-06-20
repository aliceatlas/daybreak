/*

SBBookmarksView.m
 
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

#import "SBBookmarksView.h"
#import "SBBookmarks.h"
#import "SBUtil.h"

@implementation SBBookmarksView

@synthesize listView;
@dynamic cellWidth;
@dynamic mode;
@synthesize delegate;

- (void)dealloc
{
	[splitView release];
	[listView release];
	[scrollView release];
	delegate = nil;
	[super dealloc];
}

- (CGFloat)splitWidth:(CGFloat)proposedWidth
{
	return listView ? [listView splitWidth:proposedWidth] : 0;
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

#pragma mark Delegate

- (void)bookmarkListViewShouldOpenSearchbar:(SBBookmarkListView *)bookmarkListView
{
	if (self.bounds.size.width >= [SBSearchbar availableWidth])
	{
		[self setShowSearchbar:YES];
	}
	else {
		NSBeep();
	}
}

- (BOOL)bookmarkListViewShouldCloseSearchbar:(SBBookmarkListView *)bookmarkListView
{
	return [self setShowSearchbar:NO];
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
	[scrollView setAutohidesScrollers:YES];
	[scrollView setHasHorizontalScroller:NO];
	[scrollView setHasVerticalScroller:YES];
	[scrollView setBackgroundColor:[NSColor colorWithCalibratedRed:SBBackgroundColors[0] green:SBBackgroundColors[1] blue:SBBackgroundColors[2] alpha:SBBackgroundColors[3]]];
	[scrollView setDrawsBackground:YES];
	listView.wrapperView = self;
	listView.cellWidth = (CGFloat)[[NSUserDefaults standardUserDefaults] integerForKey:kSBBookmarkCellWidth];
	[scrollView setDocumentView:listView];
	[[scrollView contentView] setCopiesOnScroll:YES];
	[self addSubview:scrollView];
	[listView setCellSizeForMode:inMode];
	[listView createItemViews];
	listView.delegate = self;
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
	[self executeDidCellWidth];
}

- (void)setMode:(SBBookmarkMode)mode
{
	listView.mode = mode;
	[[NSUserDefaults standardUserDefaults] setInteger:mode forKey:kSBBookmarkMode];
	[self executeDidChangeMode];
}

- (BOOL)setShowSearchbar:(BOOL)showSearchbar
{
	BOOL r = NO;
	if (showSearchbar)
	{
		if (!splitView)
		{
			searchbar = [[SBSearchbar alloc] initWithFrame:NSMakeRect(0, 0, scrollView.frame.size.width, 24.0)];
			searchbar.target = self;
			searchbar.doneSelector = @selector(searchWithText:);
			searchbar.cancelSelector = @selector(closeSearchbar);
			splitView = [[SBFixedSplitView splitViewWithEmbedViews:[NSArray arrayWithObjects:searchbar, scrollView, nil] frameRect:scrollView.frame] retain];
			[splitView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
			[searchbar autorelease];
			r = YES;
		}
		[searchbar selectText:nil];
	}
	else {
		if (splitView)
		{
			SBDisembedViewInSplitView(scrollView, splitView);
			[splitView release];
			splitView = nil;
			[[scrollView window] makeFirstResponder:scrollView];
			r = YES;
		}
	}
	return r;
}

- (void)searchWithText:(NSString *)text
{
	if ([text length] > 0)
	{
		[listView searchWithText:text];
	}
}

- (void)closeSearchbar
{
	[self setShowSearchbar:NO];
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

- (void)executeDidCellWidth
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(bookmarksView:didChangeCellWidth:)])
		{
			[delegate bookmarksView:self didChangeCellWidth:listView.cellWidth];
		}
	}
}

#pragma mark Actions

- (void)addForBookmarkItem:(NSDictionary *)item
{
	[listView addForItem:item];
}

- (void)scrollToItem:(NSDictionary *)bookmarkItem
{
	SBBookmarks *bookmarks = [SBBookmarks sharedBookmarks];
	NSInteger index = [bookmarks indexOfItem:bookmarkItem];
	if (index != NSNotFound)
	{
		NSRect itemRect = [listView itemRectAtIndex:index];
		[scrollView scrollRectToVisible:itemRect];
	}
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
