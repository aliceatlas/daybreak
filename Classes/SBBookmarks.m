/*

SBBookmarks.m
 
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

#import "SBBookmarks.h"
#import "SBUtil.h"

static SBBookmarks *sharedBookmarks;

@implementation SBBookmarks

@synthesize items;

+ (id)sharedBookmarks
{
	if (!sharedBookmarks)
	{
		sharedBookmarks = [[self alloc] init];
	}
	return sharedBookmarks;
}

- (id)init
{
	if (self = [super init])
	{
		if ([self readFromFile])
		{
		}
	}
	return self;
}

- (void)dealloc
{
	[items release];
	[super dealloc];
}

#pragma mark Getter

- (BOOL)containsURL:(NSString *)urlString
{
	return [self indexOfURL:urlString] != NSNotFound;
}

- (NSUInteger)indexOfURL:(NSString *)urlString
{
	NSUInteger index = NSNotFound;
	NSUInteger i = 0;
	for (NSDictionary *item in items)
	{
		if ([[item objectForKey:kSBBookmarkURL] isEqualToString:urlString])
		{
			index = i;
			break;
		}
		i++;
	}
	return index;
}

- (BOOL)isEqualBookmarkItems:(NSDictionary *)item1 anotherItem:(NSDictionary *)item2
{
	BOOL r = NO;
	r = ([[item1 objectForKey:kSBBookmarkTitle] isEqualToString:[item2 objectForKey:kSBBookmarkTitle]] && 
		 [[item1 objectForKey:kSBBookmarkURL] isEqualToString:[item2 objectForKey:kSBBookmarkURL]] && 
		 [[item1 objectForKey:kSBBookmarkImage] isEqualToData:[item2 objectForKey:kSBBookmarkImage]]);
	return r;
}

- (NSDictionary *)itemAtIndex:(NSUInteger)index
{
	NSDictionary *item = nil;
	if (index < [items count])
	{
		item = [items objectAtIndex:index];
	}
	return item;
}

- (NSInteger)containsItem:(NSDictionary *)anItem
{
	NSInteger index = NSNotFound;
	NSInteger i = 0;
	for (NSDictionary *item in items)
	{
		if ([self isEqualBookmarkItems:item anotherItem:anItem])
		{
			index = i;
			break;
		}
		i++;
	}
	return index;
}

- (NSInteger )indexOfItem:(NSDictionary *)bookmarkItem
{
	NSInteger index = NSNotFound;
	NSInteger i = 0;
	for (NSDictionary *item in items)
	{
		if ([item isEqualToDictionary:bookmarkItem])
		{
			index = i;
			break;
		}
		i++;
	}
	return index;
}

- (NSIndexSet *)indexesOfItems:(NSArray *)bookmarkItems
{
	NSMutableIndexSet *indexes = nil;
	indexes = [NSMutableIndexSet indexSet];
	for (id bookmarkItem in bookmarkItems)
	{
		NSUInteger index = NSNotFound;
		NSUInteger i = 0;
		for (id bitem in items)
		{
			if ([self isEqualBookmarkItems:bitem anotherItem:bookmarkItem])
			{
				index = i;
				break;
			}
			i++;
		}
		if (index != NSNotFound)
		{
			[indexes addIndex:index];
		}
	}
	return [[indexes copy] autorelease];
}

#pragma mark Notify

- (void)notifyDidUpdate
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center postNotificationName:SBBookmarksDidUpdateNotification object:self];
}

#pragma mark Actions

- (BOOL)readFromFile
{
	BOOL r = NO;
	if (!items)
		items = [[NSMutableArray alloc] initWithCapacity:0];
#if kSBCountOfDebugBookmarks > 0
	for (NSUInteger index = 0; index < kSBCountOfDebugBookmarks; index++)
	{
		NSString *title = [NSString stringWithFormat:@"Title %d", index];
		NSString *url = [NSString stringWithFormat:@"http://%d.com/", index];
		NSDictionary *item = SBCreateBookmarkItem(title, url, SBEmptyBookmarkImageData(), [NSDate date], nil, NSStringFromPoint(NSZeroPoint));
		[items addObject:item];
	}
#else
	NSString *path = SBBookmarksFilePath();
	NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:path];
	if (info)
	{
		NSArray *bookmarkItems = [info objectForKey:kSBBookmarkItems];
		if ([bookmarkItems count] > 0)
		{
			[items removeAllObjects];
			[items addObjectsFromArray:bookmarkItems];
			r = YES;
		}
	}
#endif
	return r;
}

- (BOOL)writeToFile
{
	BOOL r = NO;
	if (items)
	{
		NSString *path = SBBookmarksFilePath();
		NSData *data = nil;
		NSString  *errorString = nil;
		data = [NSPropertyListSerialization dataFromPropertyList:SBBookmarksWithItems(items) format:NSPropertyListBinaryFormat_v1_0 errorDescription:&errorString];
		if (data)
		{
			r = [data writeToFile:path atomically:YES];
			if (errorString)
			{
				DebugLog(@"%s error = %@", __func__, errorString);
			}
		}
	}
	return r;
}

- (void)addItem:(NSDictionary *)item
{
	if (item)
	{
		NSUInteger index = [self indexOfURL:[item objectForKey:kSBBookmarkURL]];
		if (index == NSNotFound)
		{
			[items addObject:item];
		}
		else {
			[items replaceObjectAtIndex:index withObject:item];
		}
		[self writeToFile];
		[self performSelector:@selector(notifyDidUpdate) withObject:nil afterDelay:0];
	}
}

- (void)replaceItem:(NSDictionary *)item atIndex:(NSUInteger)index
{
	[items replaceObjectAtIndex:index withObject:item];
	[self writeToFile];
	[self performSelector:@selector(notifyDidUpdate) withObject:nil afterDelay:0];
}

- (void)replaceItem:(NSDictionary *)oldItem withItem:(NSDictionary *)newItem
{
	NSUInteger index = [items indexOfObject:oldItem];
	if (index != NSNotFound)
	{
		[items replaceObjectAtIndex:index withObject:newItem];
		[self writeToFile];
		[self performSelector:@selector(notifyDidUpdate) withObject:nil afterDelay:0];
	}
}

- (void)addItems:(NSArray *)inItems toIndex:(NSUInteger)toIndex
{
	if ([inItems count] > 0 && toIndex <= [items count])
	{
//		[items insertObjects:inItems atIndexes:[NSIndexSet indexSetWithIndex:toIndex]];
		[items insertObjects:inItems atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(toIndex, [inItems count])]];
		[self writeToFile];
		[self performSelector:@selector(notifyDidUpdate) withObject:nil afterDelay:0];
	}
}

- (void)moveItemsAtIndexes:(NSIndexSet *)indexes toIndex:(NSUInteger)toIndex
{
	NSArray *bookmarkItems = [items objectsAtIndexes:indexes];
	if ([bookmarkItems count] > 0 && toIndex <= [items count])
	{
		NSUInteger to = toIndex;
		NSUInteger offset = 0;
		NSUInteger i = 0;
		for (i = [indexes lastIndex]; i != NSNotFound; i = [indexes indexLessThanIndex:i])
		{
			if (i < to)
				offset++;
		}
		if (to >= offset)
		{
			to -= offset;
		}
		[bookmarkItems retain];
		[items removeObjectsAtIndexes:indexes];
		[items insertObjects:bookmarkItems atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(to, [indexes count])]];
		[bookmarkItems release];
		[self writeToFile];
		[self performSelector:@selector(notifyDidUpdate) withObject:nil afterDelay:0];
	}
}

- (void)removeItemsAtIndexes:(NSIndexSet *)indexes
{
	[items removeObjectsAtIndexes:indexes];
	[self writeToFile];
	[self performSelector:@selector(notifyDidUpdate) withObject:nil afterDelay:0];
}

- (void)doubleClickItemsAtIndexes:(NSIndexSet *)indexes
{
	NSArray *selectedItems = [items objectsAtIndexes:indexes];
	[self openItemsInSelectedDocument:selectedItems];
}

- (void)changeLabelName:(NSString *)labelName atIndexes:(NSIndexSet *)indexes
{
	NSUInteger i = 0;
	for (i = [indexes lastIndex]; i != NSNotFound; i = [indexes indexLessThanIndex:i])
	{
		NSMutableDictionary *item = [[items objectAtIndex:i] mutableCopy];
		[item setObject:labelName forKey:kSBBookmarkLabelName];
		[items removeObjectAtIndex:i];
		[items insertObject:[[item copy] autorelease] atIndex:i];
		[item release];
	}
	[self writeToFile];
	[self performSelector:@selector(notifyDidUpdate) withObject:nil afterDelay:0];
}

#pragma mark Exec

- (void)openItemsFromMenuItem:(NSMenuItem *)menuItem
{
	NSArray *representedItems = [menuItem representedObject];
	if ([representedItems count] > 0)
	{
		[self openItemsInSelectedDocument:representedItems];
	}
}

- (void)openItemsInSelectedDocument:(NSArray *)inItems
{
	SBDocument *selectedDocument = SBGetSelectedDocument();
	if (selectedDocument)
	{
		if ([selectedDocument respondsToSelector:@selector(openAndConstructTabWithBookmarkItems:)])
		{
			[selectedDocument openAndConstructTabWithBookmarkItems:inItems];
		}
	}
}

- (void)removeItemsFromMenuItem:(NSMenuItem *)menuItem
{
	NSIndexSet *representedIndexes = [menuItem representedObject];
	if ([representedIndexes count] > 0)
	{
		[self removeItemsAtIndexes:representedIndexes];
	}
}

- (void)changeLabelFromMenuItem:(NSMenuItem *)menuItem
{
	NSIndexSet *representedIndexes = [menuItem representedObject];
	NSUInteger tag = [[menuItem menu] indexOfItem:menuItem];
	NSString *labelName = SBBookmarkLabelColorNames[tag];
	if ([representedIndexes count] > 0 && labelName)
	{
		[self changeLabelName:labelName atIndexes:representedIndexes];
	}
}

@end
