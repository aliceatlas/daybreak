/*

SBToolbar.m
 
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

#import "SBToolbar.h"


@implementation SBToolbar

- (void)setVisible:(BOOL)shown
{
	if (shown != [self isVisible])
	{
		[super setVisible:shown];
		if (shown)
		{
			[self executeDidVisible];
		}
		else {
			[self executeDidInvisible];
		}
	}
}

- (void)executeDidVisible
{
	id delegate = [self delegate];
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(toolbarDidVisible:)])
		{
			[delegate toolbarDidVisible:self];
		}
	}
}

- (void)executeDidInvisible
{
	id delegate = [self delegate];
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(toolbarDidInvisible:)])
		{
			[delegate toolbarDidInvisible:self];
		}
	}
}

// Returns whether the main toolbar contains item from item identifier
- (NSToolbarItem *)visibleItemForItemIdentifier:(NSString *)itemIdentifier
{
	NSToolbarItem *item = nil;
	NSArray *items = nil;
	NSEnumerator *enumerator;
	
	items = [self items];
	enumerator = [items objectEnumerator];
	while (item = [enumerator nextObject])
	{
		if ([[item itemIdentifier] isEqualToString:itemIdentifier])
		{
			break;
		}
	}
	
	return item;
}

- (NSRect)itemRectInWindowForIdentifier:(NSString *)identifier
{
	NSRect r = NSZeroRect;
	NSToolbarItem *item = nil;
	NSArray *items = [self visibleItems];
	NSEnumerator *enumerator = [items objectEnumerator];
	NSPoint delta = NSZeroPoint;
	
	while (item = [enumerator nextObject])
	{
		if ([[item itemIdentifier] isEqualToString:identifier])
		{
			id view = [item view];
			while (1)
			{
				view = [view superview];
				if (!view)
				{
					break;
				}
				else {
					delta.x += [view frame].origin.x;
					delta.y += [view frame].origin.y;
					if ([view isKindOfClass:NSClassFromString(@"NSToolbarView")])
					{
						break;
					}
				}
			}
			break;
		}
	}
	if ([item view])
	{
		r = [[item view] frame];
		r.origin.x += delta.x;
		r.origin.y += delta.y;
	}
	return r;
}

- (NSRect)itemRectInScreenForIdentifier:(NSString *)identifier
{
	NSRect r = NSZeroRect;
	NSWindow *window = [self window];
	r = [self itemRectInWindowForIdentifier:identifier];
	r.origin = [window convertBaseToScreen:r.origin];
	return r;
}

- (NSWindow *)window
{
	NSWindow *window = nil;
	NSArray *windows = [NSApp windows];
	NSWindow *w = nil;
	NSEnumerator *enumerator = [windows objectEnumerator];
	
	while (w = [enumerator nextObject])
	{
		if ([[w toolbar] isEqual:self])
		{
			window = w;
			break;
		}
	}
	
	return window;
}

@end
