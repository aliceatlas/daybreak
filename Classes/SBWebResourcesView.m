/*
 
 SBWebResourcesView.m
 
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

#import "SBWebResourcesView.h"
#import "SBUtil.h"

#import "Sunrise3-Bridging-Header.h"
#import "Sunrise3-Swift.h"

@implementation SBWebResourcesView

@synthesize dataSource;
@synthesize delegate;

- (instancetype)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		[self constructTableView];
	}
	return self;
}

- (void)dealloc
{
	dataSource = nil;
	delegate = nil;
}

#pragma mark Constructions

- (void)constructTableView
{
	NSRect scrollerRect = self.bounds;
	NSTableColumn *urlColumn = nil;
	NSTableColumn *lengthColumn = nil;
	NSTableColumn *cachedColumn = nil;
	NSTableColumn *actionColumn = nil;
	SBWebResourceButtonCell *cachedCell = nil;
	SBWebResourceButtonCell *actionCell = nil;
	SBTableCell *urlTextCell = nil;
	SBTableCell *lengthTextCell = nil;
	NSRect tableRect = NSZeroRect;
	CGFloat lengthWidth = 110.0;
	CGFloat cachedWidth = 22.0;
	CGFloat actionWidth = 22.0;
	tableRect.size = scrollerRect.size;
	scrollView = [[SBBLKGUIScrollView alloc] initWithFrame:scrollerRect];
	tableView = [[NSTableView alloc] initWithFrame:tableRect];
	urlColumn = [[NSTableColumn alloc] initWithIdentifier:kSBURL];
	lengthColumn = [[NSTableColumn alloc] initWithIdentifier:@"Length"];
	cachedColumn = [[NSTableColumn alloc] initWithIdentifier:@"Cached"];
	actionColumn = [[NSTableColumn alloc] initWithIdentifier:@"Action"];
	urlTextCell = [[SBTableCell alloc] init];
	lengthTextCell = [[SBTableCell alloc] init];
	cachedCell = [[SBWebResourceButtonCell alloc] init];
	actionCell = [[SBWebResourceButtonCell alloc] init];
    urlTextCell.font = [NSFont systemFontOfSize:12.0];
    urlTextCell.showRoundedPath = YES;
    urlTextCell.alignment = NSLeftTextAlignment;
    urlTextCell.lineBreakMode = NSLineBreakByTruncatingMiddle;
    lengthTextCell.font = [NSFont systemFontOfSize:10.0];
    lengthTextCell.showRoundedPath = NO;
    lengthTextCell.showSelection = NO;
    lengthTextCell.alignment = NSRightTextAlignment;
    cachedCell.target = self;
    cachedCell.action = @selector(save:);
    actionCell.target = self;
    actionCell.action = @selector(download:);
    urlColumn.dataCell = urlTextCell;
    urlColumn.width = tableRect.size.width - lengthWidth - cachedWidth - actionWidth;
    urlColumn.editable = NO;
    urlColumn.resizingMask = NSTableColumnAutoresizingMask;
    lengthColumn.dataCell = lengthTextCell;
    lengthColumn.width = lengthWidth;
	lengthColumn.editable = NO;
    lengthColumn.resizingMask = NSTableColumnNoResizing;
    cachedColumn.dataCell = cachedCell;
    cachedColumn.width = cachedWidth;
    cachedColumn.editable = NO;
    cachedColumn.resizingMask = NSTableColumnNoResizing;
    actionColumn.dataCell = actionCell;
    actionColumn.width = actionWidth;
    actionColumn.editable = NO;
    actionColumn.resizingMask = NSTableColumnNoResizing;
	tableView.backgroundColor = NSColor.clearColor;
    tableView.rowHeight = 20;
	[tableView addTableColumn:urlColumn];
	[tableView addTableColumn:lengthColumn];
	[tableView addTableColumn:cachedColumn];
	[tableView addTableColumn:actionColumn];
    tableView.allowsMultipleSelection = YES;
    tableView.allowsColumnSelection = NO;
    tableView.allowsEmptySelection = YES;
	tableView.doubleAction = @selector(tableViewDidDoubleAction:);
	tableView.columnAutoresizingStyle = NSTableViewLastColumnOnlyAutoresizingStyle;
	tableView.headerView = nil;
    tableView.cornerView = nil;
    tableView.autoresizingMask = NSViewWidthSizable;
    tableView.dataSource = self;
    tableView.delegate = self;
	tableView.focusRingType = NSFocusRingTypeNone;
    tableView.doubleAction = @selector(open);
    tableView.intercellSpacing = NSZeroSize;
	scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    scrollView.autohidesScrollers = YES;
    scrollView.hasVerticalScroller = YES;
    scrollView.hasHorizontalScroller = NO;
    scrollView.autohidesScrollers = YES;
	scrollView.backgroundColor = [NSColor colorWithCalibratedRed:SBBackgroundColors[0] green:SBBackgroundColors[1] blue:SBBackgroundColors[2] alpha:SBBackgroundColors[3]];
    scrollView.drawsBackground = YES;
    scrollView.documentView = tableView;
	[self addSubview:scrollView];
}

#pragma mark DataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	NSUInteger count = 0;
	if ([dataSource respondsToSelector:@selector(numberOfRowsInWebResourcesView:)])
	{
		count = [dataSource numberOfRowsInWebResourcesView:self];
	}
	return count;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	id object = nil;
	if ([dataSource respondsToSelector:@selector(webResourcesView:objectValueForTableColumn:row:)])
	{
		object = [dataSource webResourcesView:self objectValueForTableColumn:aTableColumn row:rowIndex];
	}
	return object;
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	if ([dataSource respondsToSelector:@selector(webResourcesView:objectValueForTableColumn:row:)])
	{
		[dataSource webResourcesView:self willDisplayCell:aCell forTableColumn:aTableColumn row:rowIndex];
	}
}

#pragma mark Actions

- (void)reload
{
	[tableView reloadData];
}

- (void)save:(NSTableView  *)aTableView
{
	NSInteger rowIndex = aTableView.clickedRow;
	if (rowIndex != NSNotFound)
	{
		if ([delegate respondsToSelector:@selector(webResourcesView:shouldSaveAtRow:)])
		{
			[delegate webResourcesView:self shouldSaveAtRow:rowIndex];
		}
	}
}

- (void)download:(NSTableView  *)aTableView
{
	NSInteger rowIndex = aTableView.clickedRow;
	if (rowIndex != NSNotFound)
	{
		if ([delegate respondsToSelector:@selector(webResourcesView:shouldDownloadAtRow:)])
		{
			[delegate webResourcesView:self shouldDownloadAtRow:rowIndex];
		}
	}
}

#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	
}

@end

@implementation SBWebResourceButtonCell

@synthesize highlightedImage;

- (CGFloat)side
{
	return 5.0;
}

#pragma mark Drawing

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[self drawInteriorWithFrame:cellFrame inView:controlView];
	[self drawImageWithFrame:cellFrame inView:controlView];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[[NSColor colorWithCalibratedRed:SBBackgroundColors[0] green:SBBackgroundColors[1] blue:SBBackgroundColors[2] alpha:SBBackgroundColors[3]] set];
	NSRectFill(cellFrame);
	[[NSColor colorWithCalibratedRed:SBTableCellColors[0] green:SBTableCellColors[1] blue:SBTableCellColors[2] alpha:SBTableCellColors[3]] set];
	NSRectFill(NSInsetRect(cellFrame, 0.0, 0.5));
}

- (void)drawImageWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSImage *image = nil;
	CGFloat fraction = 1.0;
	if ([self isHighlighted])
	{
		fraction = self.highlightedImage ? 1.0 : 0.5;
		image = self.highlightedImage ? self.highlightedImage : self.image;
	}
	else {
		image = self.image;
	}
	if (image)
	{
		NSSize size = NSZeroSize;
		NSRect r = NSZeroRect;
		CGFloat side = self.side;
		
		size = image.size;
		r.size = size;
		r.origin.x = cellFrame.origin.x + side + ((cellFrame.size.width - side * 2) - r.size.width) / 2;
		r.origin.y = cellFrame.origin.y + (cellFrame.size.height - r.size.height) / 2;
		r = NSIntegralRect(r);
		[image drawInRect:r operation:NSCompositeSourceOver fraction:fraction respectFlipped:!image.isFlipped];
	}
}

@end