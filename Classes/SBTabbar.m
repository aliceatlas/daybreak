/*

SBTabbar.m
 
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

#import "SBTabbar.h"
#import "SBButton.h"
#import "SBDefinitions.h"
#import "SBTabbarItem.h"
#import "SBUtil.h"

@implementation SBTabbar

@synthesize items;
@synthesize delegate;
@dynamic selectedTabbarItem;

- (id)init
{
	if (self = [super initWithFrame:NSZeroRect])
	{
		[self constructContentView];
		[self constructItems];
		[self registerForDraggedTypes:[NSArray arrayWithObjects:SBBookmarkPboardType, NSURLPboardType, NSFilenamesPboardType, nil]];
		_animating = NO;
	}
	return self;
}

- (void)dealloc
{
	[self destructContentView];
	[self destructItems];
	[self destructButtons];
	[self destructAddButton];
	[self destructAutoScrollTimer];
	[self destructClosableTimer];
	delegate = nil;
	_draggedItem = nil;
	_shouldReselectItem = nil;
	closableItem = nil;
	[super dealloc];
}

#pragma mark Rects

- (CGFloat)itemWidth
{
	return kSBTabbarItemMaximumWidth;
}

- (CGFloat)itemMinimumWidth
{
	return kSBTabbarItemMinimumWidth;
}

- (BOOL)filled
{
	BOOL r = NO;
	NSRect bounds = self.bounds;
	CGFloat itemWidth = [self itemWidth];
	CGFloat itemMinWidth = [self itemMinimumWidth];
	CGFloat width = bounds.size.width - [self addButtonWidth];
	NSInteger count = [items count];
	r = ((count * itemWidth) > width) && ((width / count) < itemMinWidth);
	return r;
}

- (CGFloat)addButtonWidth
{
	return self.bounds.size.height;
}

- (CGFloat)innerWidth
{
	return self.bounds.size.width - [self addButtonWidth];
}

- (NSRect)addButtonRect
{
	return [self addButtonRect:[items count]];
}

- (NSRect)addButtonRect:(NSInteger)count
{
	NSRect r = NSZeroRect;
	CGFloat itemWidth = [self itemWidth];
	CGFloat itemMinWidth = [self itemMinimumWidth];
	CGFloat width = [self innerWidth];
	if ((count * itemWidth) > width)
	{
		CGFloat w = (width / count);
		itemWidth = w < itemMinWidth ? itemMinWidth : w;
	}
	r.size.width = [self addButtonWidth];
	r.size.height = self.bounds.size.height;
	r.origin.x = count * itemWidth;
	return NSIntegralRect(r);
}

- (NSRect)newItemRect
{
	return [self itemRectAtIndex:[items count]];
}

- (NSRect)itemRectAtIndex:(NSInteger)index
{
	NSRect r = NSZeroRect;
	CGFloat itemWidth = [self itemWidth];
	CGFloat itemMinWidth = [self itemMinimumWidth];
	CGFloat width = [self innerWidth];
	NSInteger count = [items count];
	if (index >= count)
		count += 1;
	if ((count * itemWidth) > width)
	{
		CGFloat w = (width / count);
		itemWidth = w < itemMinWidth ? itemMinWidth : w;
	}
	r.size.width = itemWidth;
	r.size.height = self.bounds.size.height;
	r.origin.x = index * itemWidth;
	return NSIntegralRect(r);
}

- (NSInteger)indexForPoint:(NSPoint)point rect:(NSRect *)rect
{
	NSInteger index = NSNotFound;
	NSInteger count = [items count];
	for (index = 0; index < count; index++)
	{
		NSRect r = [self itemRectAtIndex:index];
		if (point.x >= r.origin.x && point.x <= NSMaxX(r))
		{
			*rect = r;
			break;
		}
	}
	return index;
}

- (SBTabbarItem *)itemAtPoint:(NSPoint)point
{
	SBTabbarItem *item = nil;
	for (SBTabbarItem *anItem in items)
	{
		if (NSPointInRect(point, anItem.frame))
		{
			item = anItem;
			break;
		}
	}
	return item;
}

- (SBTabbarItem *)selectedTabbarItem
{
	SBTabbarItem *item = nil;
	for (SBTabbarItem *anItem in items)
	{
		if (anItem.selected)
		{
			item = anItem;
			break;
		}
	}
	return item;
}

#pragma mark NSAnimation Delegate

- (BOOL)animationShouldStart:(NSAnimation *)animation
{
	BOOL should = !_animating;
	_animating = YES;
	return should;
}

- (float)animation:(NSAnimation *)animation valueForProgress:(NSAnimationProgress)progress
{
	if (_draggedItem)
	{
		// Needs display dragged item
		[_draggedItem setNeedsDisplay:YES];
	}
	return progress;
}

- (void)animationDidEnd:(NSAnimation *)animation
{
	if (!_draggedItem)
	{
		[self updateItems];
	}
	_animating = NO;
}

- (void)animationDidStop:(NSAnimation *)animation
{
	_animating = NO;
}

#pragma mark Setter

- (void)setToolbarVisible:(BOOL)isToolbarVisible
{
	if (toolbarVisible != isToolbarVisible)
	{
		toolbarVisible = isToolbarVisible;
		[self setNeedsDisplay:YES];
		if ([[self subviews] count] > 0)
		{
			for (NSView *subview in [self subviews])
			{
				if ([subview respondsToSelector:@selector(setToolbarVisible:)])
				{
					[(id)subview setToolbarVisible:isToolbarVisible];
				}
			}
		}
	}
}

#pragma mark Destruction

- (void)destructContentView
{
	if (contentView)
	{
		[contentView removeFromSuperview];
		[contentView release];
		contentView = nil;
	}
}

- (void)destructItems
{
	if (items)
	{
		[items removeAllObjects];
		[items release];
		items = nil;
	}
}

- (void)destructButtons
{
	[self destructAddButton];
}

- (void)destructAddButton
{
	if (addButton)
	{
		[addButton removeFromSuperview];
		[addButton release];
		addButton = nil;
	}
}

- (void)destructAutoScrollTimer
{
	if (autoScrollTimer)
	{
		[autoScrollTimer invalidate];
		[autoScrollTimer release];
		autoScrollTimer = nil;
	}
}

- (void)destructClosableTimer
{
	if (closableTimer)
	{
		[closableTimer invalidate];
		[closableTimer release];
		closableTimer = nil;
	}
}

#pragma mark Construction

- (void)constructContentView
{
	[self destructContentView];
	contentView = [[SBView alloc] initWithFrame:self.bounds];
	[self addSubview:contentView];
}

- (void)constructItems
{
	[self destructItems];
	items = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)constructAddButton
{
	NSRect r = [self addButtonRect];
	[self destructAddButton];
	addButton = [[SBButton alloc] initWithFrame:r];
	addButton.image = [NSImage imageWithCGImage:SBAddIconImage(NSSizeToCGSize(r.size), NO)];
	addButton.backImage = [NSImage imageWithCGImage:SBAddIconImage(NSSizeToCGSize(r.size), YES)];
	addButton.target = self;
	addButton.action = @selector(addNewItem:);
	[contentView addSubview:addButton];
}

#pragma mark Exec

- (void)executeShouldAddNewItemForURLs:(NSArray *)urls
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(tabbar:shouldAddNewItemForURLs:)])
		{
			[delegate tabbar:self shouldAddNewItemForURLs:urls];
		}
	}
}

- (void)executeShouldOpenURLs:(NSArray *)urls startInItem:(SBTabbarItem *)item
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(tabbar:shouldOpenURLs:startInItem:)])
		{
			[delegate tabbar:self shouldOpenURLs:urls startInItem:item];
		}
	}
}

- (void)executeShouldReloadItem:(SBTabbarItem *)item
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(tabbar:shouldReload:)])
		{
			[delegate tabbar:self shouldReload:item];
		}
	}
}

- (void)executeShouldReselect:(SBTabbarItem *)item
{
	_shouldReselectItem = item;
}

- (void)executeDidChangeSelection:(SBTabbarItem *)item
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(tabbar:didChangeSelection:)])
		{
			[delegate tabbar:self didChangeSelection:item];
		}
	}
}

- (void)executeDidReselectItem:(SBTabbarItem *)item
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(tabbar:didReselection:)])
		{
			[delegate tabbar:self didReselection:item];
		}
	}
}

- (void)executeDidRemoveItem:(NSString *)identifier
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(tabbar:didChangeSelection:)])
		{
			[delegate tabbar:self didRemoveItem:identifier];
		}
	}
}

#pragma mark Actions

- (SBTabbarItem *)addItemWithIdentifier:(NSNumber *)identifier
{
	SBTabbarItem *newItem = nil;
	NSRect r = [self newItemRect];
	newItem = [[[SBTabbarItem alloc] initWithFrame:r] autorelease];
	newItem.tabbar = self;
	newItem.identifier = identifier;
	newItem.target = self;
	newItem.closeSelector = @selector(closeItem:);
	newItem.selectSelector = @selector(selectItem:);
	newItem.keyView = self.keyView;
	[self addItem:newItem];
	[self updateItems];
	return newItem;
}

- (void)addItem:(SBTabbarItem *)item
{
	[items addObject:item];
	[contentView addSubview:item];
}

- (BOOL)removeItem:(SBTabbarItem *)item
{
	BOOL r = NO;
	if ([items containsObject:item])
	{
		[item removeFromSuperview];
		[items removeObject:item];
		r = YES;
	}
	return r;
}

- (void)selectItem:(SBTabbarItem *)item
{
	if ([items count] > 0)
	{
		BOOL changed = NO;
		for (SBTabbarItem *anItem in items)
		{
			if (anItem == item)
			{
				if (!anItem.selected)
				{
					anItem.selected = YES;
					changed = YES;
				}
			}
			else {
				anItem.selected = NO;
			}
		}
		if (changed)
		{
			[self executeDidChangeSelection:item];
		}
	}
	else {
		NSBeep();
	}
}

- (void)selectItemForIndex:(NSUInteger)index
{
	SBTabbarItem *item = nil;
	NSUInteger count = [items count];
	if (index == 0)
	{
		if (count > 0)
		{
			item = [items objectAtIndex:index];
		}
	}
	else if (index == count)
	{
		item = [items objectAtIndex:index - 1];
	}
	else {
		item = [items objectAtIndex:index];
	}
	if (item)
	{
		[self selectItem:item];
	}
}

- (void)selectLastItem
{
	if ([items count] > 0)
	{
		[self selectItem:[items lastObject]];
	}
	else {
		NSBeep();
	}
}

- (void)selectPreviousItem
{
	if ([items count] > 0)
	{
		SBTabbarItem *prevItem = nil;
		for (SBTabbarItem *item in items)
		{
			if (item.selected)
			{
				break;
			}
			prevItem = item;
		}
		if (!prevItem)
			prevItem = [items lastObject];
		[self selectItem:prevItem];
	}
	else {
		NSBeep();
	}
}

- (void)selectNextItem
{
	if ([items count] > 0)
	{
		SBTabbarItem *item = nil;
		BOOL find = NO;
		for (item in items)
		{
			if (find)
			{
				break;
			}
			else {
				if (item.selected)
				{
					find = YES;
				}
			}
		}
		if (!item)
			item = [items objectAtIndex:0];
		[self selectItem:item];
	}
	else {
		NSBeep();
	}
}

- (void)closeItem:(SBTabbarItem *)item
{
	if ([items count] > 0)
	{
		BOOL shouldSelect = (item.selected);
		NSString *itemIdentifier = [[item.identifier copy] autorelease];
		NSUInteger index = [items indexOfObject:item];
		if ([self removeItem:item])
		{
			[self updateItems];
			if (shouldSelect)
			{
				[self selectItemForIndex:index];
			}
			[self executeDidRemoveItem:itemIdentifier];
		}
	}
	else {
		NSBeep();
	}
}

- (void)closeSelectedItem
{
	if ([items count] > 0)
	{
		for (SBTabbarItem *item in items)
		{
			if (item.selected)
			{
				[self closeItem:item];
				break;
			}
		}
	}
	else {
		NSBeep();
	}
}

- (void)addNewItem:(id)sender
{
	[self executeShouldAddNewItemForURLs:nil];
}

- (void)closeItemFromMenu:(NSMenuItem *)menuItem
{
	SBTabbarItem *item = [items objectAtIndex:[menuItem tag]];
	if (item)
	{
		[self closeItem:item];
	}
}

- (void)closeOtherItemsFromMenu:(NSMenuItem *)menuItem
{
	for (SBTabbarItem *item in [items reverseObjectEnumerator])
	{
		if ([items indexOfObject:item] != [menuItem tag])
		{
			[self closeItem:item];
		}
	}
}

- (void)reloadItemFromMenu:(NSMenuItem *)menuItem
{
	SBTabbarItem *item = [items objectAtIndex:[menuItem tag]];
	if (item)
	{
		[self executeShouldReloadItem:item];
	}
}

- (void)layout
{
	BOOL filled = [self filled];
	NSRect bounds = self.bounds;
	NSSize size = bounds.size;
	if (filled)
	{
		CGFloat itemMinWidth = [self itemMinimumWidth];
		NSInteger count = [items count];
		size.width = itemMinWidth * count + [self addButtonWidth];
		[contentView setAutoresizingMask:(NSViewMinYMargin)];
	}
	else {
		[contentView setFrameOrigin:NSZeroPoint];
		[contentView setAutoresizingMask:(NSViewWidthSizable | NSViewMinYMargin)];
	}
	[contentView setFrameSize:size];
}

- (void)scroll:(CGFloat)deltaX
{
	if ([self filled])
	{
		NSRect bounds = self.bounds;
		NSRect contentRect = [contentView frame];
		CGFloat x = (contentRect.origin.x + deltaX);
		if (x > 0)
			contentRect.origin.x = 0;
		else if (x < (bounds.size.width - contentRect.size.width))
			contentRect.origin.x = (bounds.size.width - contentRect.size.width);
		else
			contentRect.origin.x = x;
		[contentView setFrame:contentRect];
	}
}

- (BOOL)autoScrollWithPoint:(NSPoint)point
{
	BOOL r = NO;
	CGFloat deltaX = 0;
	CGFloat width = 20.0;
	NSRect leftRect = NSZeroRect;
	NSRect rightRect = NSZeroRect;
	leftRect = rightRect = self.bounds;
	leftRect.size.width = rightRect.size.width = width;
	rightRect.origin.x = self.bounds.size.width - width;
	if (leftRect.origin.x < point.x && NSMaxX(leftRect) > point.x)
	{
		deltaX = 10.0;
	}
	else if (rightRect.origin.x < point.x && NSMaxX(rightRect) > point.x)
	{
		deltaX = -10.0;
	}
	if (deltaX != 0)
	{
		[self scroll:deltaX];
		r = YES;
	}
	return r;
}

- (void)autoScroll:(NSEvent *)theEvent
{
	[self destructAutoScrollTimer];
	if ([self filled])
	{
		NSDictionary *userInfo = nil;
		NSPoint point = NSZeroPoint;
		userInfo = [NSDictionary dictionaryWithObject:theEvent forKey:@"Event"];
		point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
		if ([self autoScrollWithPoint:point])
		{
			autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(mouseDraggedWithTimer:) userInfo:userInfo repeats:YES];
			[autoScrollTimer retain];
		}
	}
}

- (void)mouseDraggedWithTimer:(NSTimer *)timer
{
	NSEvent *theEvent = [[timer userInfo] objectForKey:@"Event"];
	[self mouseDragged:theEvent];
}

- (BOOL)canClosable
{
	return [items count] > 1;
}

- (void)constructClosableTimerForItem:(SBTabbarItem *)item
{
	if (closableItem != item)
	{
		closableItem = item;
		[self destructClosableTimer];
		closableTimer = [NSTimer scheduledTimerWithTimeInterval:kSBTabbarItemClosableInterval target:self selector:@selector(applyClosableItem) userInfo:nil repeats:NO];
		[closableTimer retain];
	}
}

- (void)applyClosableItem
{
	[self destructClosableTimer];
	if (closableItem)
	{
		closableItem.closable = YES;
	}
}

- (void)applyDisclosableAllItem
{
	[self destructClosableTimer];
	for (SBTabbarItem *item in items)
	{
		item.closable = NO;
	}
	closableItem = nil;
}

#pragma mark Update

- (void)updateItems
{
	NSRect r = NSZeroRect;
	NSInteger index = 0;
	NSEvent *currentEvent = [[NSApplication sharedApplication] currentEvent];
	NSPoint location = [currentEvent locationInWindow];
	for (SBTabbarItem *item in items)
	{
		// Update frame of item
		r = [self itemRectAtIndex:index];
		if (!NSEqualRects(item.frame, r))
		{
			item.frame = r;
		}
		else {
			[item setNeedsDisplay:YES];
		}
		if (_draggedItem)
		{
			// Ignore while dragging
		}
		else {
			if ([self canClosable])
			{
				// If the mouse is entered in the closable rect, make a tabbar item closable
				NSPoint point = [item convertPoint:location fromView:nil];
				if (CGRectContainsPoint([item closableRect], NSPointToCGPoint(point)))
				{
					[self constructClosableTimerForItem:item];
				}
			}
		}
		index++;
	}
	addButton.frame = [self addButtonRect];
	addButton.pressed = NO;
	[self layout];
}

- (void)dragItemAtPoint:(NSPoint)point
{
	NSRect r = NSZeroRect;
	NSInteger index = 0;
	NSMutableArray *animations = [NSMutableArray arrayWithCapacity:0];
	NSMutableDictionary *info = nil;
	
	for (SBTabbarItem *item in items)
	{
		r = [self itemRectAtIndex:index];
		if (point.x >= r.origin.x && point.x <= NSMaxX(r))
		{
			index++;
			r = [self itemRectAtIndex:index];
		}
		if (!NSEqualRects(item.frame, r) && !_animating)
		{
			info = [NSMutableDictionary dictionaryWithCapacity:0];
			[info setObject:item forKey:NSViewAnimationTargetKey];
			[info setObject:[NSValue valueWithRect:item.frame] forKey:NSViewAnimationStartFrameKey];
			[info setObject:[NSValue valueWithRect:r] forKey:NSViewAnimationEndFrameKey];
			[animations addObject:[[info copy] autorelease]];
		}
		else {
			[item setNeedsDisplay:YES];
		}
		index++;
	}
	r = [self addButtonRect:index];
	if (!NSEqualRects(addButton.frame, r) && !_animating)
	{
		info = [NSMutableDictionary dictionaryWithCapacity:0];
		[info setObject:addButton forKey:NSViewAnimationTargetKey];
		[info setObject:[NSValue valueWithRect:addButton.frame] forKey:NSViewAnimationStartFrameKey];
		[info setObject:[NSValue valueWithRect:r] forKey:NSViewAnimationEndFrameKey];
		[animations addObject:[[info copy] autorelease]];
	}
	
	if ([animations count] > 0 && !_animating)
	{
		NSViewAnimation *animation = [[[NSViewAnimation alloc] initWithViewAnimations:animations] autorelease];
		[animation setDuration:0.25];
		[animation setDelegate:self];
		[animation startAnimation];
	}
}

#pragma mark Dragging DataSource

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
	return NSDragOperationCopy;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender
{
	return NSDragOperationCopy;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
	BOOL r = YES;
	NSPasteboard *pasteboard = [sender draggingPasteboard];
	NSArray *types = [pasteboard types];
	NSArray *pbItems = [pasteboard propertyListForType:SBBookmarkPboardType];
	NSPoint point = [contentView convertPoint:[sender draggingLocation] fromView:nil];
	
	if ([types containsObject:SBBookmarkPboardType] && [pbItems count] > 0)
	{
		NSMutableArray *urls = nil;
		urls = [NSMutableArray arrayWithCapacity:0];
		for (NSDictionary *item in pbItems)
		{
			NSString *urlString = [item objectForKey:kSBBookmarkURL];
			NSURL *url = [urlString length] ? [NSURL URLWithString:urlString] : nil;
			if (url)
			{
				[urls addObject:url];
			}
		}
		if ([urls count] > 0)
		{
			if ([urls count] == 1)
			{
				SBTabbarItem *item = nil;
				if ((item = [self itemAtPoint:point]))
				{
					[self executeShouldOpenURLs:[NSArray arrayWithObject:[urls objectAtIndex:0]] startInItem:item];
				}
				else {
					[self executeShouldAddNewItemForURLs:[[urls copy] autorelease]];
				}
			}
			else {
				[self executeShouldAddNewItemForURLs:[[urls copy] autorelease]];
			}
		}
	}
	else if ([types containsObject:NSURLPboardType])
	{
		NSURL *url = [NSURL URLFromPasteboard:pasteboard];
		SBTabbarItem *item = nil;
		if ((item = [self itemAtPoint:point]))
		{
			[self executeShouldOpenURLs:[NSArray arrayWithObject:url] startInItem:item];
		}
		else {
			[self executeShouldAddNewItemForURLs:[NSArray arrayWithObject:url]];
		}
	}
	return r;
}

#pragma mark Event

- (void)mouseDown:(NSEvent *)theEvent
{
	if ([items count] > 1)
	{
		NSPoint location = [theEvent locationInWindow];
		_draggedItem = nil;
		_shouldReselectItem = nil;
		_draggedItemRect = NSZeroRect;
		_downPoint = [contentView convertPoint:location fromView:nil];
	}
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	if ([items count] > 1 || _draggedItem)
	{
		NSPoint location = [theEvent locationInWindow];
		NSPoint point = [contentView convertPoint:location fromView:nil];
		if (SBAllowsDrag(_downPoint, point))
		{
			if (!_draggedItem)
			{
				// Get dragging item
				if ((_draggedItem = [self itemAtPoint:_downPoint]))
				{
					_shouldReselectItem = nil;
					_draggedItemRect = _draggedItem.frame;
					[items removeObject:_draggedItem];
					[contentView addSubview:_draggedItem];	// Bring to front
				}
			}
			if (_draggedItem)
			{
				// Move dragged item
				NSRect r = _draggedItemRect;
				if ((NSMaxX(r) + (point.x - _downPoint.x)) >= contentView.bounds.size.width)
				{
					// Max
					r.origin.x = contentView.bounds.size.width - r.size.width;
				}
				else if ((r.origin.x + (point.x - _downPoint.x)) <= 0)
				{
					// Min
					r.origin.x = 0;
				}
				else {
					r.origin.x += point.x - _downPoint.x;
				}
				_draggedItem.frame = r;
				[self dragItemAtPoint:point];
				[self setNeedsDisplay:YES];
				[self autoScroll:theEvent];
			}
		}
	}
}

- (void)mouseMoved:(NSEvent *)theEvent
{
	
}

- (void)mouseEntered:(NSEvent *)theEvent
{
	
}

- (void)mouseExited:(NSEvent *)theEvent
{
	[self destructAutoScrollTimer];
}

- (void)mouseUp:(NSEvent *)theEvent
{
	if (_draggedItem)
	{
		NSPoint location = [theEvent locationInWindow];
		NSPoint point = [contentView convertPoint:location fromView:nil];
		NSRect r = NSZeroRect;
		NSInteger index = [self indexForPoint:point rect:&r];
		// Add dragged item
		_draggedItem.frame = r;
		[items insertObject:_draggedItem atIndex:index];
		[self updateItems];
		if (_draggedItem.selected)
		{
			[self selectItem:_draggedItem];
		}
		_draggedItem = nil;
		[self destructAutoScrollTimer];
	}
	if (_shouldReselectItem)
	{
		[self executeDidReselectItem:_shouldReselectItem];
		_shouldReselectItem = nil;
	}
}

- (void)scrollWheel:(NSEvent *)theEvent
{
	CGFloat deltaX = [theEvent deltaX];
	[self scroll:deltaX];
}

- (NSMenu *)menuForItem:(SBTabbarItem *)item
{
	NSMenu *menu = nil;
	if (item)
	{
		BOOL single = [items count] == 1;
		NSInteger index = [items indexOfObject:item];
		menu = [[[NSMenu alloc] init] autorelease];
		[menu addItemWithTitle:NSLocalizedString(@"New Tab", nil) action:@selector(addNewItem:) keyEquivalent:[NSString string]];
		if (single)
		{
			
		}
		else {
			[menu addItemWithTitle:NSLocalizedString(@"Close", nil) target:self action:@selector(closeItemFromMenu:) tag:index];
			[menu addItemWithTitle:NSLocalizedString(@"Close Others", nil) target:self action:@selector(closeOtherItemsFromMenu:) tag:index];
		}
		[menu addItem:[NSMenuItem separatorItem]];
		[menu addItemWithTitle:NSLocalizedString(@"Reload", nil) target:self action:@selector(reloadItemFromMenu:) tag:index];
	}
	return menu;
}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	NSMenu *menu = [[[NSMenu alloc] init] autorelease];
	[menu addItemWithTitle:NSLocalizedString(@"New Tab", nil) action:@selector(addNewItem:) keyEquivalent:[NSString string]];
	return menu;
}

#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
	CGMutablePathRef path = nil;
	NSUInteger count = 2;
	CGFloat locations[count];
	CGFloat colors[count * 4];
	CGFloat storkeColor[4];
	CGPoint points[count];
	CGRect r = CGRectZero;
	locations[0] = 0.7;
	locations[1] = 1.0;
	colors[0] = (keyView ? 150 : 207) / 255.0;
	colors[1] = (keyView ? 150 : 207) / 255.0;
	colors[2] = (keyView ? 150 : 207) / 255.0;
	colors[3] = 1.0;
	colors[4] = (keyView ? 135 : 207) / 255.0;
	colors[5] = (keyView ? 135 : 207) / 255.0;
	colors[6] = (keyView ? 135 : 207) / 255.0;
	colors[7] = 1.0;
	storkeColor[0] = 0.3;
	storkeColor[1] = 0.3;
	storkeColor[2] = 0.3;
	storkeColor[3] = 1.0;
	points[0] = CGPointZero;
	points[1] = CGPointMake(0.0, rect.size.height);
	CGContextSaveGState(ctx);
	SBDrawGradientInContext(ctx, count, locations, colors, points);
	CGContextRestoreGState(ctx);
	
	r = NSRectToCGRect(rect);
	path = CGPathCreateMutable();
	CGPathMoveToPoint(path, nil, r.origin.x, r.origin.y);
	CGPathAddLineToPoint(path, nil, CGRectGetMaxX(r), r.origin.y);
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, path);
	CGContextSetLineWidth(ctx, 0.5);
	CGContextSetRGBStrokeColor(ctx, storkeColor[0], storkeColor[1], storkeColor[2], storkeColor[3]);
	CGContextStrokePath(ctx);
	CGContextRestoreGState(ctx);
	CGPathRelease(path);
	
	path = CGPathCreateMutable();
	CGPathMoveToPoint(path, nil, r.origin.x, CGRectGetMaxY(r) - 0.5);
	CGPathAddLineToPoint(path, nil, CGRectGetMaxX(r), CGRectGetMaxY(r) - 0.5);
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, path);
	CGContextSetLineWidth(ctx, 0.5);
	CGContextSetRGBStrokeColor(ctx, storkeColor[0], storkeColor[1], storkeColor[2], storkeColor[3]);
	CGContextStrokePath(ctx);
	CGContextRestoreGState(ctx);
	CGPathRelease(path);
}

@end
