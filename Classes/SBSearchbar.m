/*
 
 SBSearchbar.m
 
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
