//
//  SBWebResourcesView.m
//  Sunrise
//
//  Created by Atsushi Jike on 10/03/07.
//  Copyright 2010 Atsushi Jike. All rights reserved.
//

#import "SBWebResourcesView.h"
#import "SBUtil.h"

@implementation SBWebResourcesView

@synthesize dataSource;
@synthesize delegate;

- (id)initWithFrame:(NSRect)frame
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
	[tableView release];
	[scrollView release];
	[super dealloc];
}

#pragma mark Constructions

- (void)constructTableView
{
	NSRect scrollerRect = [self bounds];
	NSTableColumn *urlColumn = nil;
	NSTableColumn *lengthColumn = nil;
	NSTableColumn *actionColumn = nil;
	SBWebResourceButtonCell *buttonCell = nil;
	SBWebResourceCell *urlTextCell = nil;
	SBWebResourceCell *lengthTextCell = nil;
	NSRect tableRect = NSZeroRect;
	CGFloat lengthWidth = 110.0;
	CGFloat actionWidth = 22.0;
	tableRect.size = scrollerRect.size;
	scrollView = [[SBBLKGUIScrollView alloc] initWithFrame:scrollerRect];
	tableView = [[NSTableView alloc] initWithFrame:tableRect];
	urlColumn = [[[NSTableColumn alloc] initWithIdentifier:kSBURL] autorelease];
	lengthColumn = [[[NSTableColumn alloc] initWithIdentifier:@"Length"] autorelease];
	actionColumn = [[[NSTableColumn alloc] initWithIdentifier:@"Action"] autorelease];
	urlTextCell = [[[SBWebResourceCell alloc] init] autorelease];
	lengthTextCell = [[[SBWebResourceCell alloc] init] autorelease];
	buttonCell = [[[SBWebResourceButtonCell alloc] init] autorelease];
	[urlTextCell setFont:[NSFont systemFontOfSize:12.0]];
	[urlTextCell setShowRoundedPath:YES];
	[urlTextCell setAlignment:NSLeftTextAlignment];
	[lengthTextCell setFont:[NSFont systemFontOfSize:10.0]];
	[lengthTextCell setShowRoundedPath:NO];
	[lengthTextCell setAlignment:NSRightTextAlignment];
	[buttonCell setTarget:self];
	[buttonCell setAction:@selector(download:)];
	[urlColumn setDataCell:urlTextCell];
	[urlColumn setWidth:(tableRect.size.width - lengthWidth - actionWidth)];
	[urlColumn setEditable:NO];
	[urlColumn setResizingMask:NSTableColumnAutoresizingMask];
	[lengthColumn setDataCell:lengthTextCell];
	[lengthColumn setWidth:lengthWidth];
	[lengthColumn setEditable:NO];
	[lengthColumn setResizingMask:NSTableColumnNoResizing];
	[actionColumn setDataCell:buttonCell];
	[actionColumn setWidth:actionWidth];
	[actionColumn setEditable:NO];
	[actionColumn setResizingMask:NSTableColumnNoResizing];
	[tableView setBackgroundColor:[NSColor clearColor]];
	[tableView setRowHeight:20];
	[tableView addTableColumn:urlColumn];
	[tableView addTableColumn:lengthColumn];
	[tableView addTableColumn:actionColumn];
	[tableView setAllowsMultipleSelection:YES];
	[tableView setAllowsColumnSelection:NO];
	[tableView setAllowsEmptySelection:YES];
	[tableView setDoubleAction:@selector(tableViewDidDoubleAction:)];
	[tableView setColumnAutoresizingStyle:NSTableViewLastColumnOnlyAutoresizingStyle];
	[tableView setHeaderView:nil];
	[tableView setCornerView:nil];
	[tableView setAutoresizingMask:(NSViewWidthSizable)];
	[tableView setDataSource:self];
	[tableView setDelegate:self];
	[tableView setFocusRingType:NSFocusRingTypeNone];
	[tableView setDoubleAction:@selector(open)];
	[tableView setIntercellSpacing:NSZeroSize];
	[scrollView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
	[scrollView setAutohidesScrollers:YES];
	[scrollView setHasVerticalScroller:YES];
	[scrollView setHasHorizontalScroller:NO];
	[scrollView setAutohidesScrollers:YES];
	[scrollView setBackgroundColor:[NSColor colorWithCalibratedRed:SBSidebarBackgroundColors[0] green:SBSidebarBackgroundColors[1] blue:SBSidebarBackgroundColors[2] alpha:SBSidebarBackgroundColors[3]]];
	[scrollView setDrawsBackground:YES];
	[scrollView setDocumentView:tableView];
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

- (void)download:(NSTableView  *)aTableView
{
	NSInteger rowIndex = [aTableView clickedRow];
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

@implementation SBWebResourceCell

@synthesize showRoundedPath;

- (CGFloat)side
{
	return 5.0;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[self drawInteriorWithFrame:cellFrame inView:controlView];
	[self drawTitleWithFrame:cellFrame inView:controlView];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[[NSColor colorWithCalibratedRed:SBSidebarBackgroundColors[0] green:SBSidebarBackgroundColors[1] blue:SBSidebarBackgroundColors[2] alpha:SBSidebarBackgroundColors[3]] set];
	NSRectFill(cellFrame);
	[[NSColor colorWithCalibratedRed:SBSidebarCellColors[0] green:SBSidebarCellColors[1] blue:SBSidebarCellColors[2] alpha:SBSidebarCellColors[3]] set];
	NSRectFill(NSInsetRect(cellFrame, 0.0, 0.5));
	if ([self isHighlighted] && showRoundedPath)
	{
		CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
		CGRect r = CGRectZero;
		CGPathRef path = nil;
		r = NSRectToCGRect(cellFrame);
		path = SBRoundedPath(CGRectInset(r, 1.0, 0.5), (cellFrame.size.height - 0.5 * 2) / 2, 0.0, YES, YES);
		CGContextSaveGState(ctx);
		CGContextAddPath(ctx, path);
		CGContextSetRGBFillColor(ctx, SBSidebarSelectedCellColors[0], SBSidebarSelectedCellColors[1], SBSidebarSelectedCellColors[2], SBSidebarSelectedCellColors[3]);
		CGContextFillPath(ctx);
		CGContextRestoreGState(ctx);
		CGPathRelease(path);
	}
}

- (void)drawTitleWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSString *title = nil;
	
	title = [self title];
	
	if ([title length] > 0)
	{
		NSSize size = NSZeroSize;
		NSColor *color = nil;
		NSColor *scolor = nil;
		NSFont *font = nil;
		NSDictionary *attribute = nil;
		NSDictionary *sattribute = nil;
		NSRect r = NSZeroRect;
		NSRect sr = NSZeroRect;
		NSMutableParagraphStyle *style = nil;
		CGFloat side = [self side] + (cellFrame.size.height - 0.5 * 2) / 2;
		
		color = [self isHighlighted] ? [NSColor whiteColor] : [NSColor colorWithCalibratedRed:SBSidebarTextColors[0] green:SBSidebarTextColors[1] blue:SBSidebarTextColors[2] alpha:SBSidebarTextColors[3]];
		scolor = [NSColor blackColor];
		font = [self font];
		style = [[[NSMutableParagraphStyle alloc] init] autorelease];
		[style setLineBreakMode:NSLineBreakByTruncatingTail];
		attribute = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, color, NSForegroundColorAttributeName, style, NSParagraphStyleAttributeName, nil];
		sattribute = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, scolor, NSForegroundColorAttributeName, style, NSParagraphStyleAttributeName, nil];
		size = [title sizeWithAttributes:attribute];
		if (size.width > (cellFrame.size.width - side * 2))
			size.width = cellFrame.size.width - side * 2;
		r.size = size;
		if ([self alignment] == NSLeftTextAlignment)
		{
			r.origin.x = cellFrame.origin.x + side;
		}
		else if ([self alignment] == NSRightTextAlignment)
		{
			r.origin.x = cellFrame.origin.x + side + ((cellFrame.size.width - side * 2) - size.width);
		}
		else if ([self alignment] == NSCenterTextAlignment)
		{
			r.origin.x = cellFrame.origin.x + ((cellFrame.size.width - side * 2) - size.width) / 2;
		}
		r.origin.y = cellFrame.origin.y + (cellFrame.size.height - r.size.height) / 2;
		sr = r;
		sr.origin.y -= 1.0;
		[title drawInRect:sr withAttributes:sattribute];
		[title drawInRect:r withAttributes:attribute];
	}
}

@end

@implementation SBWebResourceButtonCell

@synthesize highlightedImage;

- (void)dealloc
{
	[highlightedImage release];
	[super dealloc];
}

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
	[[NSColor colorWithCalibratedRed:SBSidebarBackgroundColors[0] green:SBSidebarBackgroundColors[1] blue:SBSidebarBackgroundColors[2] alpha:SBSidebarBackgroundColors[3]] set];
	NSRectFill(cellFrame);
	[[NSColor colorWithCalibratedRed:SBSidebarCellColors[0] green:SBSidebarCellColors[1] blue:SBSidebarCellColors[2] alpha:SBSidebarCellColors[3]] set];
	NSRectFill(NSInsetRect(cellFrame, 0.0, 0.5));
}

- (void)drawImageWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSImage *image = nil;
	CGFloat fraction = 1.0;
	if ([self isHighlighted])
	{
		fraction = self.highlightedImage ? 1.0 : 0.5;
		image = self.highlightedImage ? self.highlightedImage : [self image];
	}
	else {
		image = [self image];
	}
	if (image)
	{
		NSSize size = NSZeroSize;
		NSRect r = NSZeroRect;
		CGFloat side = [self side];
		
		size = [image size];
		r.size = size;
		r.origin.x = cellFrame.origin.x + side + ((cellFrame.size.width - side * 2) - r.size.width) / 2;
		r.origin.y = cellFrame.origin.y + (cellFrame.size.height - r.size.height) / 2;
		r = NSIntegralRect(r);
		if (![image isFlipped])
		{
			[image setFlipped:YES];
		}
		[image drawInRect:r fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:fraction];
	}
}

@end