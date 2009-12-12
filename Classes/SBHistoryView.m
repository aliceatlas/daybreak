/*

SBHistoryView.m
 
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

#import "SBHistoryView.h"
#import "SBHistory.h"
#import "SBURLField.h"


@implementation SBHistoryView

@dynamic message;

- (id)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		[self constructMessageLabel];
		[self constructTableView];
		[self constructRemoveButtons];
		[self constructBackButton];
		[self makeResponderChain];
		[self setAutoresizingMask:(NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin)];
	}
	return self;
}

- (void)dealloc
{
	[messageLabel release];
	[tableView release];
	[removeButton release];
	[removeAllButton release];
	[backButton release];
	[super dealloc];
}

#pragma mark Rects

- (NSPoint)margin
{
	return NSMakePoint(36.0, 32.0);
}

- (CGFloat)labelWidth
{
	return 85.0;
}

- (NSSize)buttonSize
{
	return NSMakeSize(124.0, 24.0);
}

- (CGFloat)buttonMargin
{
	return 15.0;
}

- (NSRect)iconRect
{
	NSRect r = NSZeroRect;
	NSPoint margin = [self margin];
	r.size.width = 32.0;
	r.origin.x = [self labelWidth] - r.size.width;
	r.size.height = 32.0;
	r.origin.y = self.bounds.size.height - margin.y - r.size.height;
	return r;
}

- (NSRect)messageLabelRect
{
	NSRect r = NSZeroRect;
	NSRect iconRect = [self iconRect];
	NSPoint margin = [self margin];
	r.origin.x = NSMaxX(iconRect) + 10.0;
	r.size.width = self.bounds.size.width - r.origin.x - margin.x;
	r.size.height = 20.0;
	r.origin.y = self.bounds.size.height - margin.y - r.size.height - (iconRect.size.height - r.size.height) / 2;
	return r;
}

- (NSRect)tableViewRect
{
	NSRect r = NSZeroRect;
	NSPoint margin = [self margin];
	NSRect iconRect = [self iconRect];
	r.origin.x = margin.x;
	r.size.width = self.bounds.size.width - r.origin.x - margin.x;
	r.size.height = self.bounds.size.height - iconRect.size.height - 10.0 - margin.y * 3 - [self buttonSize].height;
	r.origin.y = margin.y * 2 + [self buttonSize].height;
	return r;
}

- (NSRect)removeButtonRect
{
	NSRect r = NSZeroRect;
	NSPoint margin = [self margin];
	r.size.width = 105.0;
	r.size.height = 24.0;
	r.origin.y = margin.y;
	r.origin.x = margin.x;
	return r;
}

- (NSRect)removeAllButtonRect
{
	NSRect r = NSZeroRect;
	NSRect removeButtonRect = [self removeButtonRect];
	NSPoint margin = [self margin];
	r.size.width = 140.0;
	r.size.height = removeButtonRect.size.height;
	r.origin.y = margin.y;
	r.origin.x = NSMaxX(removeButtonRect) + 10.0;
	return r;
}

- (NSRect)backButtonRect
{
	NSRect r = NSZeroRect;
	NSPoint margin = [self margin];
	r.size.width = 105.0;
	r.size.height = 24.0;
	r.origin.y = margin.y;
	r.origin.x = (self.bounds.size.width - r.size.width - margin.x);
	return r;
}

#pragma mark DataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	NSUInteger count = [[[SBHistory sharedHistory] items] count];
	[removeAllButton setEnabled:(count > 0)];
	return count;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	NSString *object = nil;
	NSString *identifier = [aTableColumn identifier];
	NSArray *items = [[SBHistory sharedHistory] items];
	WebHistoryItem *item = (rowIndex < [items count]) ? [items objectAtIndex:rowIndex] : nil;
	if ([identifier isEqual:kSBTitle])
	{
		object = item ? [item title] : nil;
	}
	else if ([identifier isEqual:kSBURL])
	{
		object = item ? [item URLString] : nil;
	}
	else if ([identifier isEqual:kSBDate])
	{
		
	}
	return object;
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	NSString *identifier = [aTableColumn identifier];
	NSArray *items = [[SBHistory sharedHistory] items];
	WebHistoryItem *item = (rowIndex < [items count]) ? [items objectAtIndex:rowIndex] : nil;
	NSString *string = nil;
	if ([identifier isEqualToString:kSBImage])
	{
		NSImage *image = item ? [item icon] : nil;
		if (image)
		{
			[aCell setImage:image];
		}
	}
	else if ([identifier isEqual:kSBTitle])
	{
		string = item ? [item title] : nil;
	}
	else if ([identifier isEqual:kSBURL])
	{
		string = item ? [item URLString] : nil;
	}
	else if ([identifier isEqual:kSBDate])
	{
		NSTimeInterval interval = item ? [item lastVisitedTimeInterval] : 0;
		if (interval > 0)
		{
			NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] initWithDateFormat:@"%Y/%m/%d %H:%M:%S" allowNaturalLanguage:YES] autorelease];
			[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
			[dateFormatter setDateStyle:NSDateFormatterLongStyle];
			[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
			[dateFormatter setLocale:[NSLocale currentLocale]];
			string = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:interval]];
		}
	}
	if ([string length] > 0)
	{
		NSColor *color = [NSColor whiteColor];
		NSFont *font = [NSFont systemFontOfSize:14.0];
		NSDictionary *attribute = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, color, NSForegroundColorAttributeName, nil];
		NSAttributedString *attributedString = [[[NSAttributedString alloc] initWithString:string attributes:attribute] autorelease];
		[aCell setAttributedStringValue:attributedString];
	}
}

#pragma mark Delegate

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	[removeButton setEnabled:([[tableView selectedRowIndexes] count] > 0)];
}

#pragma mark Construction

- (void)constructMessageLabel
{
	NSImage *image = nil;
	image = [NSImage imageNamed:@"History"];
	iconImageView = [[NSImageView alloc] initWithFrame:[self iconRect]];
	messageLabel = [[NSTextField alloc] initWithFrame:[self messageLabelRect]];
	if (image)
	{
		[image setSize:[iconImageView frame].size];
		[iconImageView setImage:image];
	}
	[messageLabel setAutoresizingMask:(NSViewMinXMargin | NSViewMinYMargin)];
	[messageLabel setEditable:NO];
	[messageLabel setBordered:NO];
	[messageLabel setDrawsBackground:NO];
	[messageLabel setTextColor:[NSColor whiteColor]];
	[[messageLabel cell] setFont:[NSFont boldSystemFontOfSize:16]];
	[[messageLabel cell] setAlignment:NSLeftTextAlignment];
	[[messageLabel cell] setWraps:YES];
	[self addSubview:iconImageView];
	[self addSubview:messageLabel];
}

- (void)constructTableView
{
	NSRect scrollerRect = [self tableViewRect];
	NSTableColumn *iconColumn = nil;
	NSTableColumn *titleColumn = nil;
	NSTableColumn *urlColumn = nil;
	NSTableColumn *dateColumn = nil;
	SBIconDataCell *iconCell = nil;
	NSCell *textCell = nil;
	NSRect tableRect = NSZeroRect;
	tableRect.size = scrollerRect.size;
	scrollView = [[SBBLKGUIScrollView alloc] initWithFrame:scrollerRect];
	tableView = [[NSTableView alloc] initWithFrame:tableRect];
	iconColumn = [[[NSTableColumn alloc] initWithIdentifier:kSBImage] autorelease];
	titleColumn = [[[NSTableColumn alloc] initWithIdentifier:kSBTitle] autorelease];
	urlColumn = [[[NSTableColumn alloc] initWithIdentifier:kSBURL] autorelease];
	dateColumn = [[[NSTableColumn alloc] initWithIdentifier:kSBDate] autorelease];
	iconCell = [[[SBIconDataCell alloc] init] autorelease];
	textCell = [[[NSCell alloc] init] autorelease];
	[iconColumn setWidth:22.0];
	[iconColumn setDataCell:iconCell];
	[iconColumn setEditable:NO];
	[titleColumn setDataCell:textCell];
	[titleColumn setWidth:(tableRect.size.width - 22.0) * 0.3];
	[titleColumn setEditable:NO];
	[urlColumn setDataCell:textCell];
	[urlColumn setWidth:(tableRect.size.width - 22.0) * 0.4];
	[urlColumn setEditable:NO];
	[dateColumn setDataCell:textCell];
	[dateColumn setWidth:(tableRect.size.width - 22.0) * 0.3];
	[dateColumn setEditable:NO];
	[tableView setBackgroundColor:[NSColor clearColor]];
	[tableView setRowHeight:20];
	[tableView addTableColumn:iconColumn];
	[tableView addTableColumn:titleColumn];
	[tableView addTableColumn:urlColumn];
	[tableView addTableColumn:dateColumn];
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
	[scrollView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
	[scrollView setBackgroundColor:[NSColor blackColor]];
	[scrollView setDrawsBackground:NO];
	[scrollView setAutohidesScrollers:YES];
	[scrollView setHasVerticalScroller:YES];
	[scrollView setHasHorizontalScroller:NO];
	[scrollView setAutohidesScrollers:YES];
	//	[[scrollView verticalScroller] setControlSize:NSSmallControlSize];
	[scrollView setDocumentView:tableView];
	[self addSubview:scrollView];
}

- (void)constructRemoveButtons
{
	removeButton = [[SBBLKGUIButton alloc] initWithFrame:[self removeButtonRect]];
	removeAllButton = [[SBBLKGUIButton alloc] initWithFrame:[self removeAllButtonRect]];
	[removeButton setTitle:NSLocalizedString(@"Remove", nil)];
	[removeButton setTarget:self];
	[removeButton setAction:@selector(remove)];
	[removeButton setEnabled:NO];
	[removeAllButton setTitle:NSLocalizedString(@"Remove All", nil)];
	[removeAllButton setTarget:self];
	[removeAllButton setAction:@selector(removeAll)];
	[removeAllButton setEnabled:NO];
	[self addSubview:removeButton];
	[self addSubview:removeAllButton];
}

- (void)constructBackButton
{
	backButton = [[SBBLKGUIButton alloc] initWithFrame:[self backButtonRect]];
	[backButton setTitle:NSLocalizedString(@"Back", nil)];
	[backButton setTarget:self];
	[backButton setAction:@selector(cancel)];
	[backButton setKeyEquivalent:@"\e"];
	[self addSubview:backButton];
}

- (void)makeResponderChain
{
	if (removeAllButton)
		[removeButton setNextKeyView:removeAllButton];
	if (removeButton)
		[backButton setNextKeyView:removeButton];
	if (backButton)
		[tableView setNextKeyView:backButton];
	if (tableView)
		[removeAllButton setNextKeyView:tableView];
}

#pragma mark Getter

- (NSString *)message
{
	return [messageLabel stringValue];
}

#pragma mark Setter

- (void)setMessage:(NSString *)message
{
	[messageLabel setStringValue:message];
}

#pragma mark Actions

- (void)remove
{
	NSIndexSet *indexes = [tableView selectedRowIndexes];
	if ([indexes count] > 0)
	{
		[[SBHistory sharedHistory] removeAtIndexes:indexes];
		[tableView deselectAll:nil];
		[tableView reloadData];
	}
}

- (void)removeAll
{
	NSString *title = nil;
	NSString *message = nil;
	NSString *defaultTitle = nil;
	NSString *alternateTitle = nil;
	title = NSLocalizedString(@"Are you sure you want to remove all items?", nil);
	message = [NSString string];
	defaultTitle = NSLocalizedString(@"Remove All", nil);
	alternateTitle = NSLocalizedString(@"Cancel", nil);
	NSBeginAlertSheet(title, defaultTitle, alternateTitle, nil, nil, self, @selector(removeAllDidEnd:returnCode:contextInfo:), nil, nil, message);
}

- (void)removeAllDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSOKButton)
	{
		[[SBHistory sharedHistory] removeAllItems];
		[tableView deselectAll:nil];
		[tableView reloadData];
	}
	[sheet orderOut:nil];
}

- (void)open
{
	NSMutableArray *urls = [NSMutableArray arrayWithCapacity:0];
	NSUInteger index = 0;
	NSIndexSet *indexes = [tableView selectedRowIndexes];
	NSArray *items = [[SBHistory sharedHistory] items];
	for (index = [indexes lastIndex]; index != NSNotFound; index = [indexes indexLessThanIndex:index])
	{
		WebHistoryItem *item = (index < [items count]) ? [items objectAtIndex:index] : nil;
		NSString *URLString = [item URLString];
		NSURL *url = URLString ? [NSURL URLWithString:URLString] : nil;
		if (url)
			[urls addObject:url];
	}
	if (target && doneSelector)
	{
		if ([target respondsToSelector:doneSelector])
		{
			[target performSelector:doneSelector withObject:[[urls copy] autorelease]];
		}
	}
}

@end
