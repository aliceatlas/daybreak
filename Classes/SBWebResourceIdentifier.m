//
//  SBWebResourceIdentifier.m
//  Sunrise
//
//  Created by Atsushi Jike on 10/03/07.
//  Copyright 2010 Atsushi Jike. All rights reserved.
//

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
	return flag ? [NSString stringWithFormat:@"%@ URL %@, %d / %d", [self className], self.URL, received, length] : [NSString stringWithFormat:@"%@ URL %@", [self className], self.URL];
}

@end
