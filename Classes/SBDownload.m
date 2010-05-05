/*
 
 SBDownload.m
 
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

#import "SBDownload.h"
#import "SBDownloads.h"

@implementation SBDownload

@synthesize identifier;
@synthesize name;
@dynamic URL;
@dynamic progress;
@synthesize download;
@synthesize downloading;
@synthesize path;
@synthesize bytes;
@synthesize receivedLength;
@synthesize expectedLength;
@synthesize status;

+ (id)itemWithURL:(NSURL *)URL
{
	NSURLDownload *download = nil;
	download = [[[NSURLDownload alloc] initWithRequest:[NSURLRequest requestWithURL:URL] delegate:[SBDownloads sharedDownloads]] autorelease];
	return [self itemWithDownload:download];
}

+ (id)itemWithDownload:(NSURLDownload *)download
{
	id item = [[[self alloc] init] autorelease];
	[(SBDownload *)item setDownload:download];
	[(SBDownload *)item setDownloading:YES];
	return item;
}

- (id)init
{
	if (self = [super init])
	{
		status = SBStatusProcessing;
		path = nil;
	}
	return self;
}

#pragma mark Getter

- (NSString *)name
{
	return name ? name : [URL absoluteString];
}

- (CGFloat)progress
{
	return status == SBStatusDone ? 1.0 : (expectedLength == 0 ? 0 : (CGFloat)receivedLength / (CGFloat)expectedLength);
}

#pragma mark Actions

- (void)stop
{
	[download cancel];
	[download release];
	download = nil;
	downloading = NO;
}

@end
