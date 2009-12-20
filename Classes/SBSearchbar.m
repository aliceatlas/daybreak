//
//  SBSearchbar.m
//  Sunrise
//
//  Created by Atsushi Jike on 09/12/19.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SBSearchbar.h"


@implementation SBSearchbar

+ (CGFloat)minimumWidth
{
	return 200;
}

+ (CGFloat)availableWidth
{
	return 200;
}

#pragma mark Rects

- (NSRect)searchRect
{
	NSRect r = NSZeroRect;
	NSRect closeRect = [self closeRect];
	r.size.width = self.bounds.size.width - NSMaxX(closeRect);
	r.size.height = 19.0;
	r.origin.x = NSMaxX(closeRect);
	r.origin.y = (self.bounds.size.height - r.size.height) / 2;
	return r;
}

#pragma mark Construction

- (void)constructSearchField
{
	NSRect r = [self searchRect];
	NSString *string = [[NSPasteboard pasteboardWithName:NSFindPboard] stringForType:NSStringPboardType];
	[self destructSearchField];
	searchField = [[SBFindSearchField alloc] initWithFrame:r];
	[searchField setAutoresizingMask:(NSViewWidthSizable)];
	[searchField setDelegate:self];
	[searchField setTarget:self];
	[searchField setAction:@selector(executeDoneSelector:)];
	[[searchField cell] setSendsWholeSearchString:YES];
	[[searchField cell] setSendsSearchStringImmediately:NO];
	if (string)
		[searchField setStringValue:string];
	[contentView addSubview:searchField];
}

- (void)constructBackwardButton
{
	
}

- (void)constructForwardButton
{
	
}

- (void)constructCaseSensitiveCheck
{
	
}

- (void)constructWrapCheck
{
	
}

#pragma mark Actions

- (void)executeDoneSelector:(id)sender
{
	NSString *text = [searchField stringValue];
	if ([text length] > 0)
	{
		if (target && doneSelector)
		{
			if ([target respondsToSelector:doneSelector])
			{
				[target performSelector:doneSelector withObject:text];
			}
		}
	}
}

- (void)executeClose
{
	if (target && cancelSelector)
	{
		if ([target respondsToSelector:cancelSelector])
		{
			[target performSelector:cancelSelector withObject:self];
		}
	}
}

@end
