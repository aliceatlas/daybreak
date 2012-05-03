/*

SBBookmarkListView.m
 
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

#import "SBBookmarkListView.h"
#import "SBBookmarkListItemView.h"
#import "SBBookmarks.h"
#import "SBBookmarksView.h"
#import "SBUtil.h"

@implementation SBBookmarkListView

@synthesize wrapperView;
@synthesize mode;
@synthesize cellSize;
@dynamic width;
@synthesize cellWidth;
@synthesize block = _block;
@dynamic items;
@synthesize draggedItems;
@synthesize delegate;

- (id)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		mode = SBBookmarkIconMode;
		_block = NSZeroPoint;
		_point = NSZeroPoint;
		selectionView = nil;
		draggingLineView = nil;
		toolsItemView = nil;
		[self constructControls];
		[self registerForDraggedTypes:[NSArray arrayWithObjects:SBBookmarkPboardType, NSURLPboardType, NSFilenamesPboardType, nil]];
	}
	return self;
}

- (void)dealloc
{
	delegate = nil;
	wrapperView = nil;
	draggedItemView = nil;
	toolsItemView = nil;
	[draggedItems release];
	[itemViews release];
	[self destructSelectionView];
	[self destructDraggingLineView];
	[self destructControls];
	[self destructToolsTimer];
	[self destructSearchAnimations];
	[super dealloc];
}

#pragma mark Responder

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (BOOL)becomeFirstResponder
{
	[self needsDisplaySelectedItemViews];
	return YES;
}

- (BOOL)resignFirstResponder
{
	[self needsDisplaySelectedItemViews];
	return YES;
}

- (BOOL)isFlipped
{
	return YES;
}

#pragma mark Getter

- (CGFloat)splitWidth:(CGFloat)proposedWidth
{
	CGFloat width = proposedWidth;
	if (mode == SBBookmarkTileMode)
	{
#if 1
		CGFloat scrollerWidth = 0;
#else
		CGFloat scrollerWidth = [[self enclosingScrollView] bounds].size.width - [self width];
#endif
		NSInteger x = (NSInteger)((proposedWidth - scrollerWidth) / cellSize.width);
		width = cellSize.width * x + scrollerWidth;
		width += 2;// plus 1 for fitting
	}
	return width;
}

- (CGFloat)width
{
	CGFloat w = 0;
	NSScrollView *scrollView = nil;
	NSSize contentSize = NSZeroSize;
	NSRect documentRect = NSZeroRect;
	NSRect documentVisibleRect = NSZeroRect;
	NSRect scrollFrame = NSZeroRect;
	scrollView = [self enclosingScrollView];
	documentRect = [[scrollView documentView] frame];
	documentVisibleRect = [scrollView documentVisibleRect];
	contentSize = [scrollView contentSize];
	scrollFrame = [scrollView frame];
	w = documentRect.size.height > documentVisibleRect.size.height ? contentSize.width : scrollFrame.size.width;
	return w;
}

- (CGFloat)minimumHeight
{
	return [[self enclosingScrollView] contentSize].height;
}

- (NSPoint)spacing
{
	NSPoint s = NSZeroPoint;
	CGFloat width = [self width];
	s.x = (width - _block.x * cellSize.width) / (_block.x + 1);
	return s;
}

- (NSPoint)block
{
	NSPoint block = NSZeroPoint;
	NSInteger count = [self.items count];
	CGFloat width = [self width];
	block.x = (NSInteger)(width / cellSize.width);
	if (block.x == 0) block.x = 1;
	block.y = (NSInteger)(count / (NSInteger)block.x) + (SBRemainderIsZero(count, (NSInteger)block.x) ? 0 : 1);
	if (block.y == 0) block.y = 1;
	return block;
}

- (NSRect)itemRectAtIndex:(NSInteger)index
{
	NSRect r = NSZeroRect;
	NSPoint spacing = NSZeroPoint;
	NSPoint pos = NSZeroPoint;
	r.size = cellSize;
	spacing = mode == SBBookmarkIconMode ? [self spacing] : spacing;
	pos.y = (NSInteger)(index / (NSInteger)_block.x);
	pos.x = SBRemainder(index, (NSInteger)_block.x);
	r.origin.x = pos.x * cellSize.width + spacing.x * pos.x;
	r.origin.y = pos.y * cellSize.height;
	return r;
}

- (SBBookmarkListItemView *)itemViewAtPoint:(NSPoint)point
{
	SBBookmarkListItemView *view = nil;
#if 1
	NSUInteger index = NSNotFound;
	NSUInteger count = [self.items count];
	NSPoint loc = NSZeroPoint;
	CGFloat location = 0;
	if (mode == SBBookmarkIconMode || mode == SBBookmarkTileMode)
	{
		NSPoint spacing = [self spacing];
		loc.y = (NSInteger)(point.y / cellSize.height);
		location = (point.x / (cellSize.width + spacing.x));
		loc.x = (NSInteger)location;
		index = _block.x * loc.y + loc.x;
		if (index > count)
		{
			loc.x = count - _block.x * loc.y;
			index = _block.x * loc.y + loc.x;
		}
	}
	else if (mode == SBBookmarkListMode)
	{
		loc.y = (NSInteger)(point.y / 22.0);
		location = (point.y - loc.y * 22.0);
		if (location > 22.0 / 2)
		{
			loc.y += 1;
		}
		index = loc.y;
	}
	if (index != NSNotFound)
		view = [itemViews objectAtIndex:index];
#else
	for (SBBookmarkListItemView *itemView in itemViews)
	{
		NSRect r = itemView.frame;
		if ([itemView hitToPoint:NSMakePoint(point.x - r.origin.x, r.size.height - (point.y - r.origin.y))])
		{
			view = itemView;
			break;
		}
	}
#endif
	return view;
}

- (NSUInteger)indexAtPoint:(NSPoint)point
{
	NSInteger index = NSNotFound;
	NSUInteger count = [self.items count];
	NSPoint loc = NSZeroPoint;
	CGFloat location = 0;
	if (mode == SBBookmarkIconMode || mode == SBBookmarkTileMode)
	{
		NSPoint spacing = [self spacing];
		loc.y = (NSInteger)(point.y / cellSize.height);
		location = (point.x / (cellSize.width + spacing.x));
		if (location > (NSUInteger)location)
		{
			if ((location - (NSUInteger)location) > 0.5)
				loc.x = (NSInteger)location + 1;
			else
				loc.x = (NSInteger)location;
		}
		else {
			loc.x = (NSInteger)location;
		}
		index = _block.x * loc.y + loc.x;
		if (index > count)
		{
			loc.x = count - _block.x * loc.y;
			index = _block.x * loc.y + loc.x;
		}
	}
	else if (mode == SBBookmarkListMode)
	{
		loc.y = (NSInteger)(point.y / 22.0);
		location = (point.y - loc.y * 22.0);
		if (location > 22.0 / 2)
		{
			loc.y += 1;
		}
		index = loc.y;
	}
	return index;
}

- (NSIndexSet *)selectedIndexes
{
	NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
	NSUInteger index = 0;
	for (SBBookmarkListItemView *itemView in itemViews)
	{
		if (itemView.selected)
		{
			[indexes addIndex:index];
		}
		index++;
	}
	return [[indexes copy] autorelease];
}

- (NSRect)dragginLineRectAtPoint:(NSPoint)point
{
	NSRect r = NSZeroRect;
	NSInteger index = NSNotFound;
	NSUInteger count = [self.items count];
	NSPoint loc = NSZeroPoint;
	CGFloat location = 0;
	if (mode == SBBookmarkIconMode || mode == SBBookmarkTileMode)
	{
		NSPoint spacing = [self spacing];
		CGFloat spacingX = 0;
		loc.y = (NSInteger)(point.y / cellSize.height);
		location = (point.x / (cellSize.width + spacing.x));
		if (location > (NSUInteger)location)
		{
			if ((location - (NSUInteger)location) > 0.5)
				loc.x = (NSInteger)location + 1;
			else
				loc.x = (NSInteger)location;
		}
		else {
			loc.x = (NSInteger)location;
		}
		index = _block.x * loc.y + loc.x;
		if (index > count)
		{
			loc.x = count - _block.x * loc.y;
		}
		r.size.width = 5.0;
		r.size.height = cellSize.height;
		spacingX = loc.x > 0 ? (loc.x * spacing.x - spacing.x / 2) : 0;
		r.origin.x = loc.x * cellSize.width - r.size.width / 2 + spacingX;
		r.origin.y = loc.y * cellSize.height;
	}
	else if (mode == SBBookmarkListMode)
	{
		loc.y = (NSInteger)(point.y / 22.0);
		location = (point.y - loc.y * 22.0);
		if (location > 22.0 / 2)
		{
			loc.y += 1;
		}
		r.size.width = cellSize.width;
		r.size.height = 5.0;
		r.origin.y = loc.y * 22.0 - r.size.height / 2;
	}
	return r;
}

- (NSRect)removeButtonRect:(SBBookmarkListItemView *)itemView
{
	NSRect r = NSZeroRect;
	r.size.width = r.size.height = 24.0;
	if (itemView)
	{
		r.origin = itemView.frame.origin;
	}
	return r;
}

- (NSRect)editButtonRect:(SBBookmarkListItemView *)itemView
{
	NSRect r = NSZeroRect;
	NSRect removeButtonRect = [self removeButtonRect:itemView];
	r.size.width = 20.0;
	r.size.height = 24.0;
	if (itemView)
	{
		r.origin = itemView.frame.origin;
	}
	r.origin.x = NSMaxX(removeButtonRect);
	return r;
}

- (NSRect)updateButtonRect:(SBBookmarkListItemView *)itemView
{
	NSRect r = NSZeroRect;
	NSRect editButtonRect = [self editButtonRect:itemView];
	r.size.width = r.size.height = 24.0;
	if (itemView)
	{
		r.origin = itemView.frame.origin;
	}
	r.origin.x = NSMaxX(editButtonRect);
	return r;
}

- (NSMutableArray *)items
{
	SBBookmarks *bookmarks = [SBBookmarks sharedBookmarks];
	return bookmarks.items;
}

- (NSArray *)getSelectedItems
{
	NSMutableArray *ditems = nil;
	ditems = [NSMutableArray arrayWithCapacity:0];
	for (SBBookmarkListItemView *itemView in itemViews)
	{
		if (itemView.selected)
		{
			NSDictionary *item = itemView.item;
			if (item)
				[ditems addObject:item];
		}
	}
	return [ditems count] > 0 ? [[ditems copy] autorelease] : nil;
}

- (BOOL)canScrollToNext
{
	BOOL r = NO;
	NSRect bounds = [self bounds];
	NSRect visibleRect = [self visibleRect];
	r = (NSMaxY(visibleRect) < NSMaxY(bounds));
	return r;
}

- (BOOL)canScrollToPrevious
{
	BOOL r = NO;
	NSRect visibleRect = [self visibleRect];
	r = (visibleRect.origin.y > 0);
	return r;
}

#pragma mark Destruction

- (void)destructSelectionView
{
	if (selectionView)
	{
		[selectionView removeFromSuperview];
		[selectionView release];
		selectionView = nil;
	}
}

- (void)destructDraggingLineView
{
	if (draggingLineView)
	{
		[draggingLineView removeFromSuperview];
		[draggingLineView release];
		draggingLineView = nil;
	}
}

- (void)destructControls
{
	if (removeButton)
	{
		[removeButton removeFromSuperview];
		[removeButton release];
		removeButton = nil;
	}
	if (editButton)
	{
		[editButton removeFromSuperview];
		[editButton release];
		editButton = nil;
	}
	if (updateButton)
	{
		[updateButton removeFromSuperview];
		[updateButton release];
		updateButton = nil;
	}
}

- (void)destructToolsTimer
{
	if (toolsTimer)
	{
		[toolsTimer invalidate];
		[toolsTimer release];
		toolsTimer = nil;
	}
}

- (void)destructSearchAnimations
{
	if (searchAnimations)
	{
		if ([searchAnimations isAnimating])
			[searchAnimations stopAnimation];
		[searchAnimations release];
		searchAnimations = nil;
	}
}

#pragma mark Construction

- (void)constructControls
{
	NSRect removeRect = [self removeButtonRect:nil];
	NSRect editRect = [self editButtonRect:nil];
	NSRect updateRect = [self updateButtonRect:nil];
	[self destructControls];
	removeButton = [[SBButton alloc] initWithFrame:removeRect];
	editButton = [[SBButton alloc] initWithFrame:editRect];
	updateButton = [[SBButton alloc] initWithFrame:updateRect];
	[removeButton setAutoresizingMask:(NSViewMaxXMargin | NSViewMinYMargin)];
	removeButton.image = [NSImage imageWithCGImage:SBIconImage(SBCloseIconImage(), SBButtonLeftShape, NSSizeToCGSize(removeRect.size))];
	removeButton.action = @selector(remove);
	[editButton setAutoresizingMask:(NSViewMaxXMargin | NSViewMinYMargin)];
	[updateButton setAutoresizingMask:(NSViewMaxXMargin | NSViewMinYMargin)];
	editButton.image = [NSImage imageWithCGImage:SBIconImageWithName(@"Edit", SBButtonCenterShape, NSSizeToCGSize(editRect.size))];
	updateButton.image = [NSImage imageWithCGImage:SBIconImageWithName(@"Update", SBButtonRightShape, NSSizeToCGSize(editRect.size))];
	editButton.action = @selector(edit);
	updateButton.action = @selector(update);
}

#pragma mark Setter

- (void)setCellSizeForMode:(SBBookmarkMode)inMode
{
	mode = inMode;
	if (mode == SBBookmarkIconMode)
	{
		cellSize = NSMakeSize(cellWidth, cellWidth);
	}
	else if (mode == SBBookmarkListMode)
	{
		cellSize = NSMakeSize([self width], 22.0);
	}
	else if (mode == SBBookmarkTileMode)
	{
		cellSize = NSMakeSize(cellWidth / kSBBookmarkFactorForImageHeight * kSBBookmarkFactorForImageWidth, cellWidth);
	}
}

- (void)setMode:(SBBookmarkMode)inMode
{
	if (mode != inMode)
	{
		[self setCellSizeForMode:inMode];
		[self layout:0.0];
	}
}

- (void)setCellWidth:(CGFloat)inCellWidth
{
	if (cellWidth != inCellWidth)
	{
		cellWidth = inCellWidth;
		if (mode == SBBookmarkIconMode)
		{
			cellSize = NSMakeSize(cellWidth, cellWidth);
		}
		else if (mode == SBBookmarkListMode)
		{
			cellSize = NSMakeSize([self width], 22.0);
		}
		else if (mode == SBBookmarkTileMode)
		{
			cellSize = NSMakeSize(cellWidth / kSBBookmarkFactorForImageHeight * kSBBookmarkFactorForImageWidth, cellWidth);
		}
		[self layout:0.0];
	}
}

#pragma mark Actions

- (void)addForItem:(NSDictionary *)item
{
	NSUInteger count = [self.items count];
	NSInteger index = count - 1;//count > 0 ? count - 1 : 0;
	[self layoutFrame];
	[self addItemViewAtIndex:index item:item];
}

- (void)addForItems:(NSArray *)inItems toIndex:(NSInteger)toIndex
{
	[self layoutFrame];
	[self addItemViewsToIndex:toIndex items:inItems];
}

- (void)createItemViews
{
	NSInteger index = 0;
	[self layoutFrame];
	if (itemViews)
	{
		[itemViews removeAllObjects];
		[itemViews release];
		itemViews = nil;
	}
	itemViews = [[NSMutableArray alloc] initWithCapacity:0];
	for (NSDictionary *item in self.items)
	{
		[self addItemViewAtIndex:index item:item];
		index++;
	}
}

- (void)addItemViewAtIndex:(NSInteger)index item:(NSDictionary *)item
{
	SBBookmarkListItemView *itemView = nil;
	NSRect r = [self itemRectAtIndex:index];
	itemView = [SBBookmarkListItemView viewWithFrame:r item:item];
	itemView.target = self;
	itemView.mode = mode;
	[itemViews insertObject:itemView atIndex:index];
	[self addSubview:itemView];
}

- (void)addItemViewsToIndex:(NSInteger)toIndex items:(NSArray *)inItems
{
	NSInteger index = toIndex;
	for (NSDictionary *item in inItems)
	{
		[self addItemViewAtIndex:index item:item];
		index++;
	}
	[self layoutItemViewsWithAnimationFromIndex:0];
}

- (void)moveItemViewsAtIndexes:(NSIndexSet *)indexes toIndex:(NSUInteger)toIndex
{
	NSArray *views = [itemViews objectsAtIndexes:indexes];
	if ([views count] > 0 && toIndex <= [itemViews count])
	{
		if ([itemViews containsIndexes:indexes])
		{
			NSUInteger to = toIndex;
			NSUInteger offset = 0;
			NSUInteger i = 0;
			for (i = [indexes lastIndex]; i != NSNotFound; i = [indexes indexLessThanIndex:i])
			{
				if (i < to)
					offset++;
			}
			to -= offset;
			[views retain];
			[itemViews removeObjectsAtIndexes:indexes];
			[itemViews insertObjects:views atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(to, [indexes count])]];
			[views release];
		}
	}
}

- (void)removeItemView:(SBBookmarkListItemView *)itemView
{
	[itemView removeFromSuperview];
	[self removeItemViewsAtIndexes:[NSIndexSet indexSetWithIndex:[itemViews indexOfObject:itemView]]];
}

- (void)removeItemViewsAtIndexes:(NSIndexSet *)indexes
{
	SBBookmarks *bookmarks = [SBBookmarks sharedBookmarks];
	if ([itemViews containsIndexes:indexes] && [bookmarks.items containsIndexes:indexes])
	{
		[itemViews removeObjectsAtIndexes:indexes];
		[bookmarks removeItemsAtIndexes:indexes];
		[self layout:0];
	}
	[self layoutToolsHidden];
}

- (void)editItemView:(SBBookmarkListItemView *)itemView
{
	[self editItemViewsAtIndex:[itemViews indexOfObject:itemView]];
}

- (void)editItemViewsAtIndex:(NSUInteger)index
{
	[wrapperView executeShouldEditItemAtIndex:index];
}

- (void)openItemsAtIndexes:(NSIndexSet *)indexes
{
	SBBookmarks *bookmarks = [SBBookmarks sharedBookmarks];
	[bookmarks doubleClickItemsAtIndexes:indexes];
}

- (void)selectPoint:(NSPoint)point toPoint:(NSPoint)toPoint exclusive:(BOOL)exclusive
{
	if (selectionView)
	{
		NSRect r = NSZeroRect;
		r = NSUnionRect(NSMakeRect(toPoint.x, toPoint.y, 1.0, 1.0), NSMakeRect(point.x, point.y, 1.0, 1.0));
		for (SBBookmarkListItemView *itemView in itemViews)
		{
			NSRect intersectionRect = NSIntersectionRect(r, itemView.frame);
			if (NSEqualRects(intersectionRect, NSZeroRect))
			{
				if (exclusive)
					itemView.selected = NO;
			}
			else {
				NSRect intersectionRectInView = intersectionRect;
				intersectionRectInView.origin.x = intersectionRect.origin.x - itemView.frame.origin.x;
				intersectionRectInView.origin.y = intersectionRect.origin.y - itemView.frame.origin.y;
				intersectionRectInView.origin.y = itemView.frame.size.height - NSMaxY(intersectionRectInView);
				itemView.selected = [itemView hitToRect:intersectionRectInView];
			}
		}
	}
}

- (void)layout:(NSTimeInterval)animationTime
{
	_animationIndex = NSNotFound;
	[self layoutFrame];
	if (animationTime > 0)
	{
		[self layoutItemViewsWithAnimationFromIndex:0 duration:animationTime];
	}
	else {
		[self layoutItemViews];
	}
}

- (void)layoutFrame
{
	NSRect r = self.frame;
	NSSize size = NSMakeSize([self width], [self minimumHeight]);
	_block = [self block];
	r.size.width = size.width;
	r.size.height = _block.y * cellSize.height;
	if (r.size.height < size.height) r.size.height = size.height;
	self.frame = r;
}

- (void)layoutItemViews
{
	NSInteger index = 0;
	if (mode == SBBookmarkListMode)
	{
		cellSize.width = [self width];
	}
	for (SBBookmarkListItemView *itemView in itemViews)
	{
		NSRect r = [self itemRectAtIndex:index];
		itemView.mode = mode;
		itemView.frame = r;
		[itemView setNeedsDisplay:YES];
		index++;
	}
}

- (void)layoutItemViewsWithAnimationFromIndex:(NSInteger)fromIndex
{
	[self layoutItemViewsWithAnimationFromIndex:fromIndex duration:0.25];
}

- (void)layoutItemViewsWithAnimationFromIndex:(NSInteger)fromIndex duration:(NSTimeInterval)duration
{
	NSMutableArray *animations = [NSMutableArray arrayWithCapacity:0];
	NSInteger index = 0;
	NSInteger count = [itemViews count];
	for (index = fromIndex; index < count; index++)
	{
		SBBookmarkListItemView *itemView = nil;
		NSRect r = NSZeroRect;
		NSRect visibleRect = [self visibleRect];
		itemView = [itemViews objectAtIndex:index];
		itemView.mode = mode;
		r = [self itemRectAtIndex:index];
		if (NSIntersectsRect(visibleRect, itemView.frame) || NSIntersectsRect(visibleRect, r))	// Only visible views
		{
			NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:0];
			[info setObject:itemView forKey:NSViewAnimationTargetKey];
			[info setObject:[NSValue valueWithRect:itemView.frame] forKey:NSViewAnimationStartFrameKey];
			[info setObject:[NSValue valueWithRect:r] forKey:NSViewAnimationEndFrameKey];
			[animations addObject:[[info copy] autorelease]];
		}
		else {
			itemView.frame = r;
		}
	}
	if ([animations count] > 0)
	{
		NSViewAnimation *animation = [[[NSViewAnimation alloc] initWithViewAnimations:animations] autorelease];
		[animation setDuration:duration];
		[animation setDelegate:self];
		[animation startAnimation];
	}
}

- (void)layoutSelectionView:(NSPoint)point
{
	NSRect r = NSZeroRect;
	if (!selectionView)
	{
		selectionView = [[SBView alloc] initWithFrame:NSZeroRect];
		selectionView.frameColor = [NSColor alternateSelectedControlColor];
		[self addSubview:selectionView];
	}
	r = NSUnionRect(NSMakeRect(_point.x, _point.y, 1.0, 1.0), NSMakeRect(point.x, point.y, 1.0, 1.0));
	selectionView.frame = r;
}

- (void)layoutToolsForItem:(SBBookmarkListItemView *)itemView
{
	if (toolsItemView != itemView)
	{
		toolsItemView = itemView;
		[self destructToolsTimer];
		toolsTimer = [NSTimer scheduledTimerWithTimeInterval:kSBBookmarkToolsInterval target:self selector:@selector(layoutTools) userInfo:nil repeats:NO];
		[toolsTimer retain];
	}
}

- (void)layoutTools
{
	[self destructToolsTimer];
	if (toolsItemView)
	{
		removeButton.frame = [self removeButtonRect:toolsItemView];
		editButton.frame = [self editButtonRect:toolsItemView];
		updateButton.frame = [self updateButtonRect:toolsItemView];
		removeButton.target = toolsItemView;
		editButton.target = toolsItemView;
		updateButton.target = toolsItemView;
		[self addSubview:removeButton];
		[self addSubview:editButton];
		[self addSubview:updateButton];
		[toolsItemView setNeedsDisplay:YES];
	}
}

- (void)layoutToolsHidden
{
	removeButton.target = nil;
	editButton.target = nil;
	updateButton.target = nil;
	[removeButton removeFromSuperview];
	[editButton removeFromSuperview];
	[updateButton removeFromSuperview];
	toolsItemView = nil;
}

- (void)layoutDraggingLineView:(NSPoint)point
{
	NSRect r = NSZeroRect;
	if (!draggingLineView)
	{
		draggingLineView = [[SBView alloc] initWithFrame:NSZeroRect];
		draggingLineView.frameColor = [NSColor alternateSelectedControlColor];
		[self addSubview:draggingLineView];
	}
	r = [self dragginLineRectAtPoint:point];
	draggingLineView.frame = r;
}

- (void)updateItems
{
	NSUInteger index = 0;
	NSArray *bookmarkItems = self.items;
	BOOL shouldLayout = NO;
	index = [itemViews count] - 1;
	for (SBBookmarkListItemView *itemView in [itemViews reverseObjectEnumerator])
	{
		NSDictionary *item = nil;
		item = [bookmarkItems count] > index ? [bookmarkItems objectAtIndex:index] : nil;
		if (item)
		{
			itemView.item = item;
			[itemView setNeedsDisplay:YES];
		}
		else {
			shouldLayout = YES;
			[itemView removeFromSuperview];
		}
		if (itemView.selected)
		{
			itemView.selected = NO;
			[itemView setNeedsDisplay:YES];
		}
		index--;
	}
	if (shouldLayout)
	{
		[self layoutFrame];
	}
}

- (void)scrollToNext
{
	NSRect bounds = [self bounds];
	NSRect visibleRect = [self visibleRect];
	NSRect r = visibleRect;
	if ((NSMaxY(visibleRect) + visibleRect.size.height) < bounds.size.height)
	{
		r.origin.y = NSMaxY(visibleRect);
	}
	else {
		r.origin.y = bounds.size.height - visibleRect.size.height;
	}
	[self scrollRectToVisible:r];
}

- (void)scrollToPrevious
{
	NSRect visibleRect = [self visibleRect];
	NSRect r = visibleRect;
	if ((visibleRect.origin.y - visibleRect.size.height) > 0)
	{
		r.origin.y = visibleRect.origin.y - visibleRect.size.height;
	}
	else {
		r.origin.y = 0;
	}
	[self scrollRectToVisible:r];
}

- (void)needsDisplaySelectedItemViews
{
	for (SBBookmarkListItemView *itemView in itemViews)
	{
		if (itemView.selected)
			[itemView setNeedsDisplay:YES];
	}
}

- (void)executeShouldOpenSearchbar
{
	_animationIndex = NSNotFound;
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(bookmarkListViewShouldOpenSearchbar:)])
		{
			[delegate bookmarkListViewShouldOpenSearchbar:self];
		}
	}
}

- (BOOL)executeShouldCloseSearchbar
{
	BOOL r = NO;
	_animationIndex = NSNotFound;
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(bookmarkListViewShouldCloseSearchbar:)])
		{
			r = [delegate bookmarkListViewShouldCloseSearchbar:self];
		}
	}
	return r;
}

- (void)searchWithText:(NSString *)text
{
	if ([text length] > 0)
	{
		NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
		NSUInteger index = 0;
		
		// Search in bookmarks
		for (NSDictionary *bookmarkItem in self.items)
		{
			NSString *title = [bookmarkItem objectForKey:kSBBookmarkTitle];
			NSString *urlString = [bookmarkItem objectForKey:kSBBookmarkURL];
			NSString *SchemelessUrlString = [urlString stringByDeletingScheme];
			NSRange range = [title rangeOfString:text options:NSCaseInsensitiveSearch];
			if (range.location == NSNotFound)
			{
				range = [urlString rangeOfString:text];
			}
			if (range.location == NSNotFound)
			{
				range = [SchemelessUrlString rangeOfString:text];
			}
			if (range.location != NSNotFound)
			{
				[indexes addIndex:index];
			}
			index++;
		}
		if ([indexes count] > 0)
		{
			[self showIndexes:[[indexes copy] autorelease]];
		}
		else {
			NSBeep();
		}
	}
}

- (void)showIndexes:(NSIndexSet *)indexes
{
	NSUInteger index = 0;
	NSMutableArray *infos = [NSMutableArray arrayWithCapacity:0];
	NSUInteger firstIndex = NSNotFound;
	if (_animationIndex == [indexes lastIndex] || ![indexes containsIndex:_animationIndex])
		_animationIndex = NSNotFound;
	for (index = [indexes firstIndex]; index != NSNotFound; index = [indexes indexGreaterThanIndex:index])
	{
		SBBookmarkListItemView *itemView = [itemViews objectAtIndex:index];
		if (firstIndex == NSNotFound && 
			(_animationIndex == NSNotFound || (_animationIndex != NSNotFound && _animationIndex < index)))
		{
			// Get first index
			firstIndex = index;
			
			// Add animation
			NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:0];
			NSRect startRect = NSZeroRect;
			NSRect endRect = NSZeroRect;
			endRect = [self itemRectAtIndex:firstIndex];
			startRect = endRect;
			if (mode == SBBookmarkIconMode || mode == SBBookmarkTileMode)
			{
				startRect.size.width = startRect.size.width * 1.5;
				startRect.size.height = startRect.size.height * 1.5;
			}
			else if (mode == SBBookmarkListMode)
			{
				startRect.size.width = startRect.size.width * 1.2;
				startRect.size.height = startRect.size.height * 2.0;
			}
			startRect.origin.x -= (startRect.size.width - endRect.size.width) / 2;
			startRect.origin.y -= (startRect.size.height - endRect.size.height) / 2;
			[info setObject:itemView forKey:NSViewAnimationTargetKey];
			[info setObject:[NSValue valueWithRect:startRect] forKey:NSViewAnimationStartFrameKey];
			[info setObject:[NSValue valueWithRect:endRect] forKey:NSViewAnimationEndFrameKey];
			[infos addObject:[[info copy] autorelease]];
			
			// Put to top level
			[[itemView superview] addSubview:itemView];
			
			// Scroll to item as top
			[self scrollPoint:endRect.origin];
			_animationIndex = index;
			break;
		}
	}
	if ([infos count] > 0)
	{
		[self performSelector:@selector(startAnimations:) withObject:[[infos copy] autorelease] afterDelay:0];
	}
}

- (void)startAnimations:(NSArray *)infos
{
	if (infos)
	{
		[self destructSearchAnimations];
		searchAnimations = [[NSViewAnimation alloc] initWithViewAnimations:infos];
		[searchAnimations setDuration:0.25];
		[searchAnimations setAnimationCurve:NSAnimationEaseIn];
		[searchAnimations setDelegate:self];
		[searchAnimations startAnimation];
	}
}

- (void)animationDidEnd:(NSAnimation *)animation
{
	if (animation == searchAnimations)
	{
		
	}
}

#pragma mark Menu Actions

- (void)delete:(id)sender
{
	NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
	NSInteger index = 0;
	for (SBBookmarkListItemView *itemView in itemViews)
	{
		if (itemView.selected)
		{
			[itemView removeFromSuperview];
			[indexes addIndex:index];
		}
		index++;
	}
	[self removeItemViewsAtIndexes:[[indexes copy] autorelease]];
}

- (void)selectAll:(id)sender
{
	for (SBBookmarkListItemView *itemView in itemViews)
	{
		if (!itemView.selected)
		{
			itemView.selected = YES;
		}
	}
}

- (void)openSelectedItems:(id)sender
{
	NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
	NSInteger index = 0;
	for (SBBookmarkListItemView *itemView in itemViews)
	{
		if (itemView.selected)
		{
			[indexes addIndex:index];
		}
		index++;
	}
	[self openItemsAtIndexes:[[indexes copy] autorelease]];
}

#pragma mark Event

- (void)mouseDown:(NSEvent *)theEvent
{
	if([theEvent clickCount] == 2)
	{
		
	}
	else {
		NSPoint location = [theEvent locationInWindow];
		NSUInteger modifierFlags = [theEvent modifierFlags];
		NSMutableArray *selectedViews = [NSMutableArray arrayWithCapacity:0];
		NSInteger index = 0;
		BOOL alreadySelect = NO;
		BOOL selection = NO;
		_point = [self convertPoint:location fromView:nil];
		for (SBBookmarkListItemView *itemView in itemViews)
		{
			NSRect r = [self itemRectAtIndex:index];
			if ([itemView hitToPoint:NSMakePoint(_point.x - r.origin.x, r.size.height - (_point.y - r.origin.y))])
			{
				selection = YES;
				alreadySelect = itemView.selected;
				itemView.selected = YES;
			}
			else {
				if (itemView.selected)
				{
					[selectedViews addObject:itemView];
				}
			}
			index++;
		}
		if (!alreadySelect && !(modifierFlags & NSCommandKeyMask) && !(modifierFlags & NSShiftKeyMask))
		{
			for (SBBookmarkListItemView *itemView in selectedViews)
			{
				itemView.selected = NO;
			}
		}
		if (selection)
		{
			_point = NSZeroPoint;
		}
	}
	draggedItemView.dragged = NO;
	draggedItemView = nil;
	self.draggedItems = nil;
	[self destructSelectionView];
	[self destructDraggingLineView];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	NSPoint location = [theEvent locationInWindow];
	NSPoint point = [self convertPoint:location fromView:nil];
	NSUInteger modifierFlags = [theEvent modifierFlags];
	BOOL exclusive = !(modifierFlags & NSShiftKeyMask);
	if (NSEqualPoints(_point, NSZeroPoint))
	{
		// Drag
		if (draggedItemView && draggedItems)
		{
			NSImage *image = [NSImage imageWithView:draggedItemView];
			NSPoint dragLocation = NSMakePoint(point.x + _offset.width, point.y + (draggedItemView.frame.size.height - _offset.height));
			NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSDragPboard];
			NSString *title = [draggedItemView.item objectForKey:kSBBookmarkTitle];
			NSData *imageData = [draggedItemView.item objectForKey:kSBBookmarkImage];
			NSString *urlString = [draggedItemView.item objectForKey:kSBBookmarkURL];
			NSURL *url = urlString ? [NSURL URLWithString:urlString] : nil;
			[pasteboard declareTypes:[NSArray arrayWithObjects:SBBookmarkPboardType, NSURLPboardType, nil] owner:nil];
			if (draggedItems)
				[pasteboard setPropertyList:draggedItems forType:SBBookmarkPboardType];
			if (url)
				[url writeToPasteboard:pasteboard];
			if (title)
				[pasteboard setString:title forType:NSStringPboardType];
			if (imageData)
				[pasteboard setData:imageData forType:NSTIFFPboardType];
			[self dragImage:image at:dragLocation offset:NSZeroSize event:theEvent pasteboard:pasteboard source:[self window] slideBack:YES];
			draggedItemView.dragged = NO;
		}
		else {
			draggedItemView = [self itemViewAtPoint:point];
			self.draggedItems = [self getSelectedItems];
			if (draggedItemView && draggedItems)	
			{
				_offset = NSMakeSize(draggedItemView.frame.origin.x - point.x, point.y - draggedItemView.frame.origin.y);
				draggedItemView.dragged = YES;
				[self layoutToolsHidden];
			}
		}
	}
	else {
		// Selection
		[self autoscroll:theEvent];
		[self layoutSelectionView:point];
		[self selectPoint:point toPoint:_point exclusive:exclusive];
	}
}

- (void)mouseUp:(NSEvent*)theEvent
{
	if([theEvent clickCount] == 2)
	{
		NSPoint location = [theEvent locationInWindow];
		NSPoint point = [self convertPoint:location fromView:nil];
		NSInteger index = 0;
		for (SBBookmarkListItemView *itemView in itemViews)
		{
			NSRect r = [self itemRectAtIndex:index];
			if ([itemView hitToPoint:NSMakePoint(point.x - r.origin.x, r.size.height - (point.y - r.origin.y))])
			{
				[self openSelectedItems:nil];
				break;
			}
			index++;
		}
	}
	draggedItemView.dragged = NO;
	draggedItemView = nil;
	self.draggedItems = nil;
	[self destructSelectionView];
	[self destructDraggingLineView];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
	[self layoutToolsHidden];
}

- (void)mouseExited:(NSEvent *)theEvent
{
	[self layoutToolsHidden];
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
	NSMenu *menu = nil;
	[self mouseDown:theEvent];
	menu = [self menuForEvent:theEvent];
	_point = NSZeroPoint;
	draggedItemView.dragged = NO;
	draggedItemView = nil;
	self.draggedItems = nil;
	[self destructSelectionView];
	[self destructDraggingLineView];
	if (menu)
	{
		[NSMenu popUpContextMenu:menu withEvent:theEvent forView:self];
	}
}

- (void)keyDown:(NSEvent *)theEvent
{
	NSString *characters = [theEvent characters];
	unichar character = [characters characterAtIndex:0];
	if (character == NSDeleteCharacter)
	{
		// Delete
		[self delete:nil];
	}
	else if (character == NSEnterCharacter || character == NSCarriageReturnCharacter)
	{
		// Open URL
		[self openSelectedItems:nil];
	}
	else if (character == 'f' && ([theEvent modifierFlags] & NSCommandKeyMask))
	{
		// Open searchbar
		[self executeShouldOpenSearchbar];
	}
	else if (character == '\e')
	{
		// Close searchbar
		[self executeShouldCloseSearchbar];
	}
}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	NSMenu *menu = nil;
	NSIndexSet *indexes = [self selectedIndexes];
	if ([indexes count] > 0)
	{
		SBBookmarks *bookmarks = nil;
		NSUInteger i = 0;
		NSMutableArray *representedItems = nil;
		NSString *title = nil;
		NSMenuItem *openItem = nil;
		NSMenuItem *removeItem = nil;
		NSMenuItem *labelsItem = nil;
		NSMenu *labelsMenu = nil;
		bookmarks = [SBBookmarks sharedBookmarks];
		representedItems = [NSMutableArray arrayWithCapacity:0];
		menu = [[[NSMenu alloc] init] autorelease];
		title = indexes.count == 1 ? NSLocalizedString(@"Open an item", nil) : [NSString stringWithFormat:NSLocalizedString(@"Open %d items", nil), indexes.count];
		openItem = [[[NSMenuItem alloc] initWithTitle:title action:@selector(openItemsFromMenuItem:) keyEquivalent:[NSString string]] autorelease];
		title = indexes.count == 1 ? NSLocalizedString(@"Remove an item", nil) : [NSString stringWithFormat:NSLocalizedString(@"Remove %d items", nil), indexes.count];
		removeItem = [[[NSMenuItem alloc] initWithTitle:title action:@selector(removeItemsFromMenuItem:) keyEquivalent:[NSString string]] autorelease];
		labelsItem = [[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Label", nil) action:nil keyEquivalent:[NSString string]] autorelease];
		[openItem setTarget:bookmarks];
		[removeItem setTarget:bookmarks];
		for (i = [indexes lastIndex]; i != NSNotFound; i = [indexes indexLessThanIndex:i])
		{
			NSDictionary *item = [bookmarks.items objectAtIndex:i];
			if (item)
				[representedItems addObject:item];
		}
		[openItem setRepresentedObject:representedItems];
		[removeItem setRepresentedObject:indexes];
		labelsMenu = SBBookmarkLabelColorMenu(NO, bookmarks, @selector(changeLabelFromMenuItem:), indexes);
		[labelsItem setSubmenu:labelsMenu];
		[menu addItem:openItem];
		[menu addItem:removeItem];
		[menu addItem:[NSMenuItem separatorItem]];
		[menu addItem:labelsItem];
	}
	return menu;
}

#pragma mark Dragging DataSource

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
	return NSDragOperationCopy;
}

- (void)draggingExited:(id < NSDraggingInfo >)sender
{
	[self destructDraggingLineView];
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender
{
	NSPoint point = NSZeroPoint;
	point = [self convertPoint:[sender draggingLocation] fromView:nil];
	[self layoutDraggingLineView:point];
	[self autoscroll:[NSApp currentEvent]];
	return NSDragOperationCopy;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
	BOOL r = YES;
	NSPasteboard *pasteboard = [sender draggingPasteboard];
	NSPoint point = [self convertPoint:[sender draggingLocation] fromView:nil];
	SBBookmarks *bookmarks = nil;
	NSArray *types = [pasteboard types];
	NSArray *pbItems = nil;
	
	if ([types containsObject:SBBookmarkPboardType])
	{
		// Sunrise bookmarks
		pbItems = [pasteboard propertyListForType:SBBookmarkPboardType];
		if ([pbItems count] > 0)
		{
			NSIndexSet *indexes = nil;
			NSUInteger toIndex;
			bookmarks = [SBBookmarks sharedBookmarks];
			indexes = [bookmarks indexesOfItems:pbItems];
			toIndex = [self indexAtPoint:point];
			if ([indexes count] > 0)
			{
				// Move item
				[bookmarks moveItemsAtIndexes:indexes toIndex:toIndex];
				[self moveItemViewsAtIndexes:indexes toIndex:toIndex];
			}
			else {
				// Add as new item
				[bookmarks addItems:pbItems toIndex:toIndex];
				[self addForItems:pbItems toIndex:toIndex];
			}
			[self layoutItemViewsWithAnimationFromIndex:0];
		}
	}
	else if ([types containsObject:SBSafariBookmarkDictionaryListPboardType])
	{
		// Safari bookmarks
		NSArray *bookmarkItems = nil;
		pbItems = [pasteboard propertyListForType:SBSafariBookmarkDictionaryListPboardType];
		bookmarkItems = SBBookmarkItemsFromBookmarkDictionaryList(pbItems);
		if ([bookmarkItems count] > 0)
		{
			NSUInteger toIndex;
			bookmarks = [SBBookmarks sharedBookmarks];
			toIndex = [self indexAtPoint:point];
			[bookmarks addItems:bookmarkItems toIndex:toIndex];
			[self addForItems:bookmarkItems toIndex:toIndex];
			[self layoutItemViewsWithAnimationFromIndex:0];
		}
	}
	else if ([types containsObject:NSURLPboardType])
	{
		// General URL
		NSString *url = [[NSURL URLFromPasteboard:pasteboard] absoluteString];
		NSString *title = nil;
		NSData *data = nil;
		if ([types containsObject:NSStringPboardType])
		{
			title = [pasteboard stringForType:NSStringPboardType];
		}
		else {
			title = NSLocalizedString(@"Untitled", nil);
		}
		if ([types containsObject:NSTIFFPboardType])
		{
			BOOL shouldInset = YES;
			NSImage *image = nil;
			data = [pasteboard dataForType:NSTIFFPboardType];
			if ((image = [[[NSImage alloc] initWithData:data] autorelease]))
			{
				shouldInset = !NSEqualSizes([image size], SBBookmarkImageMaxSize());
			}
			if (shouldInset)
			{
				NSBitmapImageRep *bitmapImageRep = nil;
				NSImage *insetImage = nil;
				insetImage = [[[[NSImage alloc] initWithData:data] autorelease] insetWithSize:SBBookmarkImageMaxSize() intersectRect:NSZeroRect offset:NSZeroPoint];
				if (insetImage)
					bitmapImageRep = [insetImage bitmapImageRep];
				if (bitmapImageRep)
					data = [bitmapImageRep data];
			}
		}
		else {
			data = SBEmptyBookmarkImageData();
		}
		
		if (url)
		{
			bookmarks = [SBBookmarks sharedBookmarks];
			NSDictionary *item = SBCreateBookmarkItem(title, url, data, [NSDate date], nil, NSStringFromPoint(NSZeroPoint));
			NSInteger fromIndex = [bookmarks containsItem:item];
			NSUInteger toIndex = [self indexAtPoint:point];
			NSMutableArray *bookmarkItems = [NSMutableArray arrayWithCapacity:0];
			if (fromIndex != NSNotFound)
			{
				// Move item
				[bookmarks moveItemsAtIndexes:[NSIndexSet indexSetWithIndex:fromIndex] toIndex:toIndex];
				[self moveItemViewsAtIndexes:[NSIndexSet indexSetWithIndex:fromIndex] toIndex:toIndex];
				[self layoutItemViewsWithAnimationFromIndex:0];
			}
			else {
				// Add as new item
				if (toIndex != NSNotFound)
				{
					[bookmarkItems addObject:item];
					[bookmarks addItems:bookmarkItems toIndex:toIndex];
					[self addForItems:bookmarkItems toIndex:toIndex];
				}
			}
		}
	}
	[self destructDraggingLineView];
	return r;
}

#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
}

#pragma mark Gesture(10.6only)

- (BOOL)acceptsTouchEvents
{
	return YES;
}

- (void)swipeWithEvent:(NSEvent *)event
{
	CGFloat deltaX = [event deltaX];
	if (deltaX > 0)			// Left
	{
		if ([self canScrollToPrevious])
		{
			[self scrollToPrevious];
		}
		else {
			NSBeep();
		}
	}
	else if (deltaX < 0)	// Right
	{
		if ([self canScrollToNext])
		{
			[self scrollToNext];
		}
		else {
			NSBeep();
		}
	}
}

@end
