//
//  SBWebResourceIdentifier.h
//  Sunrise
//
//  Created by Atsushi Jike on 10/03/07.
//  Copyright 2010 Atsushi Jike. All rights reserved.
//

#import "SBDefinitions.h"


@interface SBWebResourceIdentifier : NSObject
{
	NSURLRequest *request;
	long long length;
	long long received;
	BOOL flag;
}
@property (nonatomic, retain) NSURLRequest *request;
@property (nonatomic, readonly) NSURL *URL;
@property (nonatomic) long long length;
@property (nonatomic) long long received;
@property (nonatomic) BOOL flag;

+ (id)identifierWithURLRequest:(NSURLRequest *)aRequest;

@end
