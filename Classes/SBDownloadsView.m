/*
 
 SBDownloadsView.m
 
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

#import "SBDownloadsView.h"
#import "SBButton.h"
#import "SBDownloads.h"
#import "SBDownloadView.h"
#import "SBUtil.h"

@implementation SBDownloadsView

@synthesize delegate;

- (id)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		downloadViews = [[NSMutableArray alloc] initWithCapacity:0];
		toolsItemView = nil;
		[self constructControls];
	}
	return self;
}

- (void)dealloc
{
	delegate = nil;
	[downloadViews release];
	[self destructControls];
	[self destructToolsTimer];
	toolsItemView = nil;
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

- (NSSize)cellSize
{
	return NSMakeSize(kSBDownloadItemSize, kSBDownloadItemSize);
}

- (NSUInteger)blockX
{
	NSUInteger blockX = 0;
	NSRect b = self.bounds;
	NSSize cellSize = [self cellSize];
	if (b.size.width < cellSize.width)
		blockX = 1;
	else
		blockX = (NSUInteger)(b.size.width / cellSize.width);
	return blockX;
}

- (NSRect)cellFrameAtIndex:(NSUInteger)index
{
	NSRect r = NSZeroRect;
	NSRect b = self.bounds;
	NSUInteger blockX = [self blockX];
	NSPoint p = NSZeroPoint;
	r.size = [self cellSize];
	p.y = index >= blockX ? (index / blockX) : 0;
	p.x = index - p.y * blockX;
	r.origin.x = p.x * r.size.width;
	r.origin.y = b.size.height - (p.y * r.size.height + r.size.height);
	return r;
}

- (NSRect)removeButtonRect:(SBDownloadView *)itemView
{
	NSRect r = NSZeroRect;
	r.size.width = r.size.height = 24.0;
	if (itemView)
	{
		r.origin.x = itemView.frame.origin.x;
		r.origin.y = NSMaxY(itemView.frame) - r.size.height;
	}
	return r;
}

- (NSRect)finderButtonRect:(SBDownloadView *)itemView
{
	NSRect r = NSZeroRect;
	r.size.width = r.size.height = 24.0;
	if (itemView)
	{
		r.origin.x = itemView.frame.origin.x;
		r.origin.y = NSMaxY(itemView.frame) - r.size.height;
	}
	r.origin.x += r.size.width;
	return r;
}

#pragma mark Actions

- (void)addForItem:(SBDownload *)item
{
	SBDownloadView *downloadView = nil;
	BOOL find = NO;
	for (SBDownloadView *downloadView in downloadViews)
	{
		if ([downloadView.download.identifier isEqualToNumber:item.identifier])
		{
			find = YES;
			break;
		}
	}
	if (!find)
	{
		NSUInteger count = [downloadViews count];
		NSRect r = [self cellFrameAtIndex:count];
		downloadView = [[[SBDownloadView alloc] initWithFrame:r] autorelease];
		[downloadView setAutoresizingMask:(NSViewMaxXMargin | NSViewMinYMargin)];
		downloadView.download = item;
		[downloadView update];
		[downloadViews addObject:downloadView];
		[self addSubview:downloadView];
	}
	downloadView.download = item;
	[self layoutItems:YES];
}

- (BOOL)removeForItem:(SBDownload *)item
{
	BOOL find = NO;
	for (SBDownloadView *downloadView in downloadViews)
	{
		if ([downloadView.download.identifier isEqualToNumber:item.identifier])
		{
			[downloadView removeFromSuperview];
			[downloadViews removeObject:downloadView];
			find = YES;
			break;
		}
	}
	if (find)
	{
		if ([downloadViews count] > 0)
		{
			[self layoutItems:YES];
		}
		else {
			[self executeDidRemoveAllItems];
		}
	}
	return find;
}

- (void)updateForItem:(SBDownload *)item
{
	for (SBDownloadView *downloadView in downloadViews)
	{
		if (downloadView.download == item)
		{
			[downloadView update];
		}
	}
}

- (void)finishForItem:(SBDownload *)item
{
	for (SBDownloadView *downloadView in downloadViews)
	{
		if (downloadView.download == item)
		{
			[downloadView update];
		}
	}
}

- (void)failForItem:(SBDownload *)item
{
	if (item.status != SBStatusUndone)
	{
		for (SBDownloadView *downloadView in downloadViews)
		{
			if (downloadView.download == item)
			{
				[downloadView update];
			}
		}
	}
}

- (void)layoutToolsForItem:(SBDownloadView *)itemView
{
	if (toolsItemView != itemView)
	{
		toolsItemView = itemView;
		[self destructToolsTimer];
		toolsTimer = [NSTimer scheduledTimerWithTimeInterval:kSBDownloadsToolsInterval target:self selector:@selector(layoutTools) userInfo:nil repeats:NO];
		[toolsTimer retain];
	}
}

- (void)layoutTools
{
	[self destructToolsTimer];
	if (toolsItemView)
	{
		removeButton.frame = [self removeButtonRect:toolsItemView];
		finderButton.frame = [self finderButtonRect:toolsItemView];
		removeButton.target = toolsItemView;
		finderButton.target = toolsItemView;
		[self addSubview:removeButton];
		[self addSubview:finderButton];
	}
}

- (void)layoutToolsHidden
{
	removeButton.target = nil;
	finderButton.target = nil;
	[removeButton removeFromSuperview];
	[finderButton removeFromSuperview];
	toolsItemView = nil;
}

#pragma mark Actions (Private)

- (void)needsDisplaySelectedItemViews
{
	for (SBDownloadView *downloadView in downloadViews)
	{
		if (downloadView.selected)
			[downloadView setNeedsDisplay:YES];
	}
}

- (void)executeDidRemoveAllItems
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(downloadsViewDidRemoveAllItems:)])
		{
			[delegate performSelector:@selector(downloadsViewDidRemoveAllItems:) withObject:self];
		}
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
	if (finderButton)
	{
		[finderButton removeFromSuperview];
		[finderButton release];
		finderButton = nil;
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

- (void)constructDownloadViews
{
	SBDownloads *downloads = [SBDownloads sharedDownloads];
	for (SBDownload *item in downloads.items)
	{
		[self addForItem:item];
	}
	[self layoutItems:YES];
}

- (void)constructControls
{
	NSRect removeRect = [self removeButtonRect:nil];
	NSRect finderRect = [self finderButtonRect:nil];
	[self destructControls];
	removeButton = [[SBButton alloc] initWithFrame:removeRect];
	finderButton = [[SBButton alloc] initWithFrame:finderRect];
	[removeButton setAutoresizingMask:(NSViewMaxXMargin | NSViewMinYMargin)];
	removeButton.image = [NSImage imageWithCGImage:SBIconImage(SBCloseIconImage(), SBButtonLeftShape, NSSizeToCGSize(removeRect.size))];
	removeButton.action = @selector(remove);
	[finderButton setAutoresizingMask:(NSViewMaxXMargin | NSViewMinYMargin)];
	finderButton.image = [NSImage imageWithCGImage:SBIconImageWithName(@"Finder", SBButtonRightShape, NSSizeToCGSize(finderRect.size))];
	finderButton.action = @selector(finder);
}

- (void)layoutItems:(BOOL)animated
{
	NSSize enclosingSize = [self enclosingScrollView] ? [[self enclosingScrollView] contentSize] : self.bounds.size;
	if (enclosingSize.width > 0 && enclosingSize.height > 0)
	{
		NSUInteger index = 0;
		NSRect r = self.frame;
		NSPoint block = NSZeroPoint;
		NSSize cellSize = [self cellSize];
		NSMutableArray *animations = [NSMutableArray arrayWithCapacity:0];
		NSEvent *currentEvent = [[NSApplication sharedApplication] currentEvent];
		NSPoint location = [currentEvent locationInWindow];
		SBDownloadView *currentDownloadView = nil;
		NSUInteger count = [downloadViews count];

		
		// Calculate the view frame
		block.x = [self blockX];
		block.y = (NSUInteger)(count / block.x);
		if ((count / block.x) - (NSUInteger)(count / block.x) > 0)
			block.y += 1;
		r.size.width = enclosingSize.width;
		r.size.height = block.y * cellSize.height;
		if (r.size.height < enclosingSize.height)
			r.size.height = enclosingSize.height;
		if (!NSEqualRects(self.frame, r))
		{
			self.frame = r;
		}
		
		// Set frame of item views
		for (SBDownloadView *downloadView in downloadViews)
		{
			NSRect r0 = downloadView.frame;
			NSRect r1 = [self cellFrameAtIndex:index];
			NSPoint point = [self convertPoint:location fromView:nil];
			if (!NSEqualRects(r0, r1))
			{
				NSRect visibleRect = [self visibleRect];
				if (animated && (NSIntersectsRect(visibleRect, downloadView.frame) || NSIntersectsRect(visibleRect, r)))	// Only visible views
				{
					NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:0];
					[info setObject:downloadView forKey:NSViewAnimationTargetKey];
					[info setObject:[NSValue valueWithRect:r0] forKey:NSViewAnimationStartFrameKey];
					[info setObject:[NSValue valueWithRect:r1] forKey:NSViewAnimationEndFrameKey];
					[animations addObject:[[info copy] autorelease]];
				}
				else {
					downloadView.frame = r1;
				}
			}
			if (NSPointInRect(point, r1))
			{
				currentDownloadView = downloadView;
			}
			index++;
		}
		if ([animations count] > 0)
		{
			NSViewAnimation *animation = [[[NSViewAnimation alloc] initWithViewAnimations:animations] autorelease];
			[animation setDuration:0.25];
			[animation setDelegate:self];
			[animation startAnimation];
		}
		if (currentDownloadView)
		{
			[self layoutToolsForItem:currentDownloadView];
		}
	}
}

#pragma mark Menu Actions

- (void)delete:(id)sender
{
	NSMutableArray *selectedDownloads = [NSMutableArray arrayWithCapacity:0];
	SBDownloads *downloads = [SBDownloads sharedDownloads];
	[self layoutToolsHidden];
	for (SBDownloadView *downloadView in downloadViews)
	{
		if (downloadView.selected)
		{
			[selectedDownloads addObject:downloadView.download];
		}
	}
	if ([selectedDownloads count] > 0)
	{
		[downloads removeItems:selectedDownloads];
	}
}

- (void)selectAll:(id)sender
{
	for (SBDownloadView *downloadView in downloadViews)
	{
		if (!downloadView.selected)
		{
			downloadView.selected = YES;
		}
	}
}

#pragma mark Event

- (void)mouseDown:(NSEvent *)theEvent
{
	NSPoint location = [theEvent locationInWindow];
	NSPoint point = [self convertPoint:location fromView:nil];
	NSInteger index = 0;
	for (SBDownloadView *downloadView in downloadViews)
	{
		NSRect r = [self cellFrameAtIndex:index];
		if (NSPointInRect(point, r))
		{
			downloadView.selected = YES;
		}
		else {
			downloadView.selected = NO;
		}
		index++;
	}
}

- (void)keyDown:(NSEvent *)theEvent
{
	NSString *characters = [theEvent characters];
	unichar character = [characters characterAtIndex:0];
	if (character == NSDeleteCharacter)
	{
		[self delete:nil];
	}
}

- (void)mouseUp:(NSEvent*)theEvent
{
	if([theEvent clickCount] == 2)
	{
		NSPoint location = [theEvent locationInWindow];
		NSPoint point = [self convertPoint:location fromView:nil];
		NSInteger index = 0;
		for (SBDownloadView *downloadView in downloadViews)
		{
			NSRect r = [self cellFrameAtIndex:index];
			if (NSPointInRect(point, r))
			{
				[downloadView open];
			}
			index++;
		}
	}
}

@end