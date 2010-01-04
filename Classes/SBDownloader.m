/*
 
 SBDownloader.h
 
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

#import "SBDownloader.h"


@implementation SBDownloader

@synthesize url;
@synthesize delegate;

+ (id)downloadWithURL:(NSURL *)url
{
	id downloader = [[[self alloc] init] autorelease];
	[downloader setUrl:url];
	return downloader;
}

- (id)init
{
	if (self = [super init])
	{
		receivedData = nil;
	}
	return self;
}

- (void)dealloc
{
	[url release];
	[connection release];
	[receivedData release];
	delegate = nil;
	[super dealloc];
}

#pragma mark Delegate

- (NSCachedURLResponse *)connection:(NSURLConnection *)aConnection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
	return nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSHTTPURLResponse *resp = [response isKindOfClass:[NSHTTPURLResponse class]] ? (NSHTTPURLResponse *)response : nil;
	NSUInteger statusCode = resp ? [resp statusCode] : 0;
	if (statusCode != 200)
	{
		[self executeDidFail:nil];
		[self cancel];
	}
}

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)aData
{
	if (!receivedData)
	{
		receivedData = [aData mutableCopy];
	}
	else {
		[receivedData appendData:aData];
	}
}

-(void)connectionDidFinishLoading:(NSURLConnection *)aConnection
{
	if ([receivedData length] > 0)
	{
		[self executeDidFinish];
	}
	else {
		[self executeDidFail:nil];
	}
	[self destructConnection];
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)aError
{
	[self executeDidFail:aError];
	[self destructConnection];
}

#pragma mark Execute

- (void)executeDidFinish
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(downloader:didFinish:)])
		{
			NSData *data = [[receivedData copy] autorelease];
			[delegate downloader:self didFinish:data];
		}
	}
}

- (void)executeDidFail:(NSError *)error
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(downloader:didFail:)])
		{
			[delegate downloader:self didFail:error];
		}
	}
}

#pragma mark Actions

- (void)destructConnection
{
	if (connection)
	{
		[connection release];
		connection = nil;
	}
}

- (void)destructReceivedData
{
	if (receivedData)
	{
		[receivedData release];
		receivedData = nil;
	}
}

- (void)start
{
	[self destructReceivedData];
	if (url)
	{
		NSURLRequest *request = nil;
		request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:kSBTimeoutInterval];
		[self destructConnection];
		connection = [NSURLConnection connectionWithRequest:request delegate:self];
		[connection retain];
	}
}

- (void)cancel
{
	if (connection)
	{
		[connection cancel];
	}
}

@end
