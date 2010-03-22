/*
 
 SBHistory.m
 
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

#import "SBHistory.h"
#import "SBUtil.h"

@implementation SBHistory

@dynamic items;

static SBHistory *sharedHistory = nil;

+ (id)sharedHistory
{
	if (!sharedHistory)
	{
		sharedHistory = [[self alloc] init];
	}
	return sharedHistory;
}

- (id)init
{
	if (self = [super init])
	{
		history = [[WebHistory alloc] init];
		[WebHistory setOptionalSharedHistory:history];
		[self readFromFile];
	}
	return self;
}

- (void)dealloc
{
	[history release];
	[super dealloc];
}

- (NSURL *)URL
{
	NSURL *URL = nil;
	NSString *path = SBHistoryFilePath();
	if (path)
		URL = [NSURL fileURLWithPath:path];
	return URL;
}

- (NSArray *)items
{
	NSMutableArray *items = [NSMutableArray arrayWithCapacity:0];
	for (NSCalendarDate *date in [history orderedLastVisitedDays])
	{
		NSArray *orderedItems = [history orderedItemsLastVisitedOnDay:date];
		[items addObjectsFromArray:orderedItems];
	}
	return [[items copy] autorelease];
}

- (NSArray *)itemsAtIndexes:(NSIndexSet *)indexes
{
	return [[self items] objectsAtIndexes:indexes];
}

- (void)addNewItemWithURLString:(NSString *)URLString title:(NSString *)title
{
	WebHistoryItem *item = nil;
	item = [[[WebHistoryItem alloc] initWithURLString:URLString title:title lastVisitedTimeInterval:[[NSDate date] timeIntervalSince1970]] autorelease];
	[history addItems:[NSArray arrayWithObject:item]];
	[self writeToFile];
}

- (void)removeItems:(NSArray *)items
{
	if ([items count] > 0)
	{
		[history removeItems:items];
		[self writeToFile];
	}
}

- (void)removeAtIndexes:(NSIndexSet *)indexes
{
	[self removeItems:[self itemsAtIndexes:indexes]];
}

- (void)removeAllItems
{
	[history removeAllItems];
	[self writeToFile];
}

- (BOOL)readFromFile
{
	BOOL r = NO;
	NSError *error = nil;
	r = [history loadFromURL:[self URL] error:&error];
	return r;
}

- (BOOL)writeToFile
{
	BOOL r = NO;
	NSError *error = nil;
	r = [history saveToURL:[self URL] error:&error];
	return r;
}

@end
