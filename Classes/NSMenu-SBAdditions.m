/*

NSMenu-SBAdditions.m
 
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

#import "NSMenu-SBAdditions.h"


@implementation NSMenu (SBAdditions)

- (NSMenuItem *)selectedItem
{
	NSMenuItem *menuItem = nil;
	for (NSMenuItem *item in [self itemArray])
	{
		if ([item state] == NSOnState)
		{
			menuItem = item;
			break;
		}
	}
	return menuItem;
}

- (void)selectItem:(NSMenuItem *)menuItem
{
	for (NSMenuItem *item in [self itemArray])
	{
		[item setState:(item == menuItem ? NSOnState : NSOffState)];
	}
}

- (NSMenuItem *)selectItemWithRepresentedObject:(id)representedObject
{
	NSMenuItem *selectedItem = nil;
	for (NSMenuItem *item in [self itemArray])
	{
		id repObject = [item representedObject];
		BOOL equal = (!repObject && !representedObject) || [repObject isEqualTo:representedObject];
		[item setState:(equal ? (selectedItem ? NSOffState : NSOnState) : NSOffState)];
		if (equal)
		{
			if (!selectedItem)
				selectedItem = item;
		}
	}
	return selectedItem;
}

- (void)deselectItem
{
	for (NSMenuItem *item in [self itemArray])
	{
		[item setState:NSOffState];
	}
}

- (NSMenuItem *)addItemWithTitle:(NSString *)aString target:(id)target action:(SEL)aSelector tag:(NSInteger)tag
{
	NSMenuItem *item = [[[NSMenuItem alloc] init] autorelease];
	[item setTitle:aString];
	[item setTarget:target];
	[item setAction:aSelector];
	[item setTag:tag];
	[self addItem:item];
	return item;
}

- (NSMenuItem *)addItemWithTitle:(NSString *)aString representedObject:(id)representedObject target:(id)target action:(SEL)aSelector
{
	NSMenuItem *item = [[[NSMenuItem alloc] init] autorelease];
	[item setTitle:aString];
	[item setTarget:target];
	[item setAction:aSelector];
	[item setRepresentedObject:representedObject];
	[self addItem:item];
	return item;
}

@end
