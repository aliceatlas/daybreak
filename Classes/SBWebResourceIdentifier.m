/*
 
 SBWebResourceIdentifier.m
 
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

#import "SBWebResourceIdentifier.h"


@implementation SBWebResourceIdentifier

@synthesize request;
@dynamic URL;
@synthesize length;
@synthesize received;
@synthesize flag;

+ (id)identifierWithURLRequest:(NSURLRequest *)aRequest
{
	id identifier = nil;
	identifier = [[[self alloc] init] autorelease];
	[identifier setRequest:aRequest];
	return identifier;
}

- (id)init
{
	if (self = [super init])
	{
		request = nil;
		length = 0;
		received = 0;
		flag = YES;
	}
	return self;
}

- (void)dealloc
{
	[request release];
	[super dealloc];
}

- (NSURL *)URL
{
	return request ? [request URL] : nil;
}

- (NSString *)description
{
	return flag ? [NSString stringWithFormat:@"%@ URL %@, %lld / %lld", [self className], self.URL, received, length] : [NSString stringWithFormat:@"%@ URL %@", [self className], self.URL];
}

@end
