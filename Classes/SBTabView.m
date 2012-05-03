/*

SBTabView.m
 
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

#import "SBTabView.h"


@implementation SBTabView

@dynamic frame;
@dynamic bounds;
@synthesize delegate;

- (id)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		
	}
	return self;
}

- (void)dealloc
{
	delegate = nil;
	[super dealloc];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p frame = %@>", [self className], self, NSStringFromRect(self.frame)];
}

- (NSRect)frame
{
	return [super frame];
}

- (NSRect)bounds
{
	return [super bounds];
}

- (void)setFrame:(NSRect)frame
{
	[super setFrame:frame];
}

- (void)setBounds:(NSRect)bounds
{
	[super setBounds:bounds];
}

- (SBTabViewItem *)selectedTabViewItem
{
	return (SBTabViewItem *)[super selectedTabViewItem];
}

- (SBTabViewItem *)tabViewItemWithIdentifier:(NSNumber *)identifier
{
	SBTabViewItem *tabViewItem = nil;
	for (SBTabViewItem *item in [self tabViewItems])
	{
		if ([[item identifier] isEqualToNumber:identifier])
		{
			tabViewItem = item;
			break;
		}
	}
	return tabViewItem;
}

#pragma mark Actions

- (void)selectTabViewItem:(NSTabViewItem *)tabViewItem
{
	[super selectTabViewItem:tabViewItem];
	[self performSelector:@selector(executeDidSelectTabViewItem:) withObject:tabViewItem afterDelay:0.0];
}

- (SBTabViewItem *)addItemWithIdentifier:(NSNumber *)identifier
{
	SBTabViewItem *tabViewItem = nil;
	tabViewItem = [[[SBTabViewItem alloc] initWithIdentifier:identifier] autorelease];
	[self addTabViewItem:tabViewItem];
	return tabViewItem;
}

- (SBTabViewItem *)selectTabViewItemWithItemIdentifier:(NSNumber *)identifier
{
	SBTabViewItem *tabViewItem = nil;
	[super selectTabViewItemWithIdentifier:identifier];
	tabViewItem = [self selectedTabViewItem];
	return tabViewItem;
}

- (void)openURLInSelectedTabViewItem:(NSString *)URLString
{
	SBTabViewItem *tabViewItem = nil;
	tabViewItem = [self selectedTabViewItem];
	if (tabViewItem)
	{
		[tabViewItem setURLString:URLString];
	}
}

- (void)closeAllTabViewItem
{
	for (SBTabViewItem *item in [[self tabViewItems] reverseObjectEnumerator])
	{
		[item removeFromTabView];
	}
}

#pragma mark Exec

- (void)executeSelectedItemDidStartLoading:(SBTabViewItem *)aTabViewItem
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(tabView:selectedItemDidStartLoading:)])
		{
			[delegate tabView:self selectedItemDidStartLoading:aTabViewItem];
		}
	}
}

- (void)executeSelectedItemDidFinishLoading:(SBTabViewItem *)aTabViewItem
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(tabView:selectedItemDidFinishLoading:)])
		{
			[delegate tabView:self selectedItemDidFinishLoading:aTabViewItem];
		}
	}
}

- (void)executeSelectedItemDidFailLoading:(SBTabViewItem *)aTabViewItem
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(tabView:selectedItemDidFailLoading:)])
		{
			[delegate tabView:self selectedItemDidFailLoading:aTabViewItem];
		}
	}
}

- (void)executeSelectedItemDidReceiveTitle:(SBTabViewItem *)aTabViewItem
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(tabView:selectedItemDidReceiveTitle:)])
		{
			[delegate tabView:self selectedItemDidReceiveTitle:aTabViewItem];
		}
	}
}

- (void)executeSelectedItemDidReceiveIcon:(SBTabViewItem *)aTabViewItem
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(tabView:selectedItemDidReceiveIcon:)])
		{
			[delegate tabView:self selectedItemDidReceiveIcon:aTabViewItem];
		}
	}
}

- (void)executeSelectedItemDidReceiveServerRedirect:(SBTabViewItem *)aTabViewItem
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(tabView:selectedItemDidFinishLoading:)])
		{
			[delegate tabView:self selectedItemDidReceiveServerRedirect:aTabViewItem];
		}
	}
}

- (void)executeShouldAddNewItemForURL:(NSURL *)url selection:(BOOL)selection
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(tabView:shouldAddNewItemForURL:selection:)])
		{
			[delegate tabView:self shouldAddNewItemForURL:url selection:selection];
		}
	}
}

- (void)executeShouldSearchString:(NSString *)string newTab:(BOOL)newTab
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(tabView:shouldSearchString:newTab:)])
		{
			[delegate tabView:self shouldSearchString:string newTab:newTab];
		}
	}
}

- (BOOL)executeShouldConfirmMessage:(NSString *)message
{
	BOOL r = NO;
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(tabView:shouldConfirmWithMessage:)])
		{
			r = [delegate tabView:self shouldConfirmWithMessage:message];
		}
	}
	return r;
}

- (void)executeShouldShowMessage:(NSString *)message
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(tabView:shouldShowMessage:)])
		{
			[delegate tabView:self shouldShowMessage:message];
		}
	}
}

- (NSString *)executeShouldTextInput:(NSString *)prompt
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(tabView:shouldTextInput:)])
		{
			return [delegate tabView:self shouldTextInput:prompt];
		}
	}
	return nil;
}

- (void)executeSelectedItemDidAddResourceID:(SBWebResourceIdentifier *)resourceID
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(tabView:didAddResourceID:)])
		{
			[delegate tabView:self didAddResourceID:resourceID];
		}
	}
}

- (void)executeSelectedItemDidReceiveExpectedContentLengthOfResourceID:(SBWebResourceIdentifier *)resourceID
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(tabView:didReceiveExpectedContentLengthOfResourceID:)])
		{
			[delegate tabView:self didReceiveExpectedContentLengthOfResourceID:resourceID];
		}
	}
}

- (void)executeSelectedItemDidReceiveContentLengthOfResourceID:(SBWebResourceIdentifier *)resourceID
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(tabView:didReceiveContentLengthOfResourceID:)])
		{
			[delegate tabView:self didReceiveContentLengthOfResourceID:resourceID];
		}
	}
}

- (void)executeSelectedItemDidReceiveFinishLoadingOfResourceID:(SBWebResourceIdentifier *)resourceID
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(tabView:didReceiveFinishLoadingOfResourceID:)])
		{
			[delegate tabView:self didReceiveFinishLoadingOfResourceID:resourceID];
		}
	}
}

- (void)executeDidSelectTabViewItem:(SBTabViewItem *)aTabViewItem
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(tabView:didSelectTabViewItem:)])
		{
			[delegate tabView:self didSelectTabViewItem:aTabViewItem];
		}
	}
}

#pragma mark Event

- (void)mouseDown:(NSEvent *)theEvent
{
	[super mouseDown:theEvent];
	[[self superview] mouseDown:theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	[super mouseDragged:theEvent];
	[[self superview] mouseDragged:theEvent];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
	[super mouseMoved:theEvent];
	[[self superview] mouseMoved:theEvent];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
	[super mouseEntered:theEvent];
	[[self superview] mouseEntered:theEvent];
}

- (void)mouseExited:(NSEvent *)theEvent
{
	[super mouseExited:theEvent];
	[[self superview] mouseExited:theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent
{
	[super mouseUp:theEvent];
	[[self superview] mouseUp:theEvent];
}

@end
