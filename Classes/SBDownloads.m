/*
 
 SBDownloads.m
 
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

#import "SBDownloads.h"
#import "SBPreferences.h"
#import "NSString-SBURLAdditions.h"

NSString *SBDownloadsDidAddItemNotification = @"SBDownloadsDidAddItemNotification";
NSString *SBDownloadsWillRemoveItemNotification = @"SBDownloadsWillRemoveItemNotification";
NSString *SBDownloadsDidUpdateItemNotification = @"SBDownloadsDidUpdateItemNotification";
NSString *SBDownloadsDidFinishItemNotification = @"SBDownloadsDidFinishItemNotification";
NSString *SBDownloadsDidFailItemNotification = @"SBDownloadsDidFailItemNotification";

@implementation SBDownloads

static SBDownloads *sharedDownloads;

@synthesize items;

+ (id)sharedDownloads
{
	if (!sharedDownloads)
	{
		sharedDownloads = [[self alloc] init];
	}
	return sharedDownloads;
}

- (id)init
{
	if (self = [super init])
	{
		_identifier = 0;
		items = [[NSMutableArray alloc] initWithCapacity:0];
	}
	return self;
}

- (BOOL)downloading
{
	BOOL r = NO;
	for (SBDownload *item in items)
	{
		if (item.downloading)
		{
			r = YES;
			break;
		}
	}
	return r;
}

#pragma mark Actions

- (void)addItem:(SBDownload *)item
{
	[items addObject:item];
	item.identifier = [self createdIdentifier];
	// Update views
	[self executeDidAddItem:item];
}

- (void)addItemWithURL:(NSURL *)url
{
	SBDownload *item = nil;
	item = [SBDownload itemWithURL:url];
	[self addItem:item];
}

- (void)removeItem:(SBDownload *)item
{
	[self removeItems:[NSArray arrayWithObject:item]];
}

- (void)removeItems:(NSArray *)inItems
{
	for (SBDownload *item in inItems)
	{
		if (item.downloading)
		{
			[item stop];
		}
	}
	// Update views
	[self executeWillRemoveItem:inItems];
	[items removeObjectsInArray:inItems];
}

#pragma mark Execute

- (void)executeDidAddItem:(SBDownload *)anItem
{
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:anItem forKey:kSBDownloadsItem];
	[[NSNotificationCenter defaultCenter] postNotificationName:SBDownloadsDidAddItemNotification object:self userInfo:userInfo];
}

- (void)executeWillRemoveItem:(NSArray *)inItems
{
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:inItems forKey:kSBDownloadsItems];
	[[NSNotificationCenter defaultCenter] postNotificationName:SBDownloadsWillRemoveItemNotification object:self userInfo:userInfo];
}

- (void)executeDidUpdateItem:(SBDownload *)anItem
{
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:anItem forKey:kSBDownloadsItem];
	[[NSNotificationCenter defaultCenter] postNotificationName:SBDownloadsDidUpdateItemNotification object:self userInfo:userInfo];
}

- (void)executeDidFinishItem:(SBDownload *)anItem
{
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:anItem forKey:kSBDownloadsItem];
	[[NSNotificationCenter defaultCenter] postNotificationName:SBDownloadsDidFinishItemNotification object:self userInfo:userInfo];
}

#pragma mark NSURLDownload Delegate

- (void)downloadDidBegin:(NSURLDownload *)aDownload
{
	SBDownload *downloadItem = nil;
	for (SBDownload *item in items)
	{
		if (item.download == aDownload)
		{
			downloadItem = item;
			break;
		}
	}
	if (!downloadItem)
	{
		downloadItem = [SBDownload itemWithDownload:aDownload];
		[self addItem:downloadItem];
	}
	// Update view
	downloadItem.status = SBStatusProcessing;
	[self executeDidUpdateItem:downloadItem];
}

- (NSURLRequest *)download:(NSURLDownload *)aDownload willSendRequest:(NSURLRequest *)aRequest redirectResponse:(NSURLResponse *)redirectResponse
{
	for (SBDownload *item in items)
	{
		if (item.download == aDownload)
		{
			// Update views
			[self executeDidUpdateItem:item];
		}
	}
	return aRequest;
}

- (void)download:(NSURLDownload *)aDownload didReceiveResponse:(NSURLResponse *)response
{
	for (SBDownload *item in items)
	{
		if (item.download == aDownload)
		{
			item.expectedLength = [response expectedContentLength] > 0 ? [response expectedContentLength] : 0;
			item.bytes = [NSString bytesString:item.receivedLength expectedLength:item.expectedLength];
			// Update views
			[self executeDidUpdateItem:item];
			break;
		}
	}
}

- (void)download:(NSURLDownload *)aDownload decideDestinationWithSuggestedFilename:(NSString *)filename
{
	for (SBDownload *item in items)
	{
		if (item.download == aDownload)
		{
			item.path = [SBPreferences objectForKey:kSBSaveDownloadedFilesTo];
			if ([[NSFileManager defaultManager] fileExistsAtPath:item.path])
			{
				item.path = [item.path stringByAppendingPathComponent:filename];
				[item.download setDestination:item.path allowOverwrite:NO];
				// Update views
				[self executeDidUpdateItem:item];
			}
			else{
				//<# Alert not found path #>
				item.receivedLength = 0;
				item.expectedLength = 0;
				[item stop];
			}
			break;
		}
	}
}

- (void)download:(NSURLDownload *)aDownload didReceiveDataOfLength:(NSUInteger)length
{
	for (SBDownload *item in items)
	{
		if (item.download == aDownload)
		{
			// Update the item
			if (item.expectedLength > 0)
			{
				item.receivedLength += length;
			}
			item.bytes = [NSString bytesString:item.receivedLength expectedLength:item.expectedLength];
			// Update views
			[self executeDidUpdateItem:item];
			break;
		}
	}
}

- (void)downloadDidFinish:(NSURLDownload *)aDownload
{
	for (SBDownload *item in items)
	{
		if (item.download == aDownload)
		{
			// Finish the item
			item.status = SBStatusDone;
			item.downloading = NO;
			// Update views
			[self executeDidFinishItem:item];
			break;
		}
	}
}

- (void)download:(NSURLDownload *)aDownload didFailWithError:(NSError *)error
{
	for (SBDownload *item in items)
	{
		if (item.download == aDownload)
		{
			item.status = SBStatusUndone;
			item.downloading = NO;
			item.receivedLength = 0;
			item.expectedLength = 0;
			// Update views
			[self executeDidUpdateItem:item];
			break;
		}
	}
}

- (BOOL)download:(NSURLDownload *)aDownload shouldDecodeSourceDataOfMIMEType:(NSString *)encodingType
{
	return YES;
}

- (void)download:(NSURLDownload *)aDownload didCreateDestination:(NSString *)aPath
{
	for (SBDownload *item in items)
	{
		if (item.download == aDownload)
		{
			if (aPath != nil)
			{
				if ([[aPath lastPathComponent] length] > 0)
				{
					item.name = [aPath lastPathComponent];
				}
				item.path = aPath;
			}
			break;
		}
	}
}

#pragma mark Function

- (NSNumber *)createdIdentifier
{
	_identifier++;
	return [NSNumber numberWithUnsignedInteger:_identifier];
}

@end
