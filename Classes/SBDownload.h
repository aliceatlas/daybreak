/*
 
 SBDownload.h
 
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

#import "SBDefinitions.h"

@interface SBDownload : NSObject
{
	NSNumber *identifier;
	NSString *name;
	NSURL *URL;
	NSURLDownload *download;
	NSString *path;
	NSString *bytes;
	BOOL downloading;
	long long receivedLength;
	long long expectedLength;
	SBStatus status;
}
@property (nonatomic, retain) NSNumber *identifier;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, readonly, assign) NSURL *URL;
@property (nonatomic, readonly, assign) CGFloat progress;
@property (nonatomic, retain) NSURLDownload *download;
@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSString *bytes;
@property (nonatomic) long long receivedLength;
@property (nonatomic) long long expectedLength;
@property (nonatomic) BOOL downloading;
@property (nonatomic) SBStatus status;

+ (id)itemWithURL:(NSURL *)URL;
+ (id)itemWithDownload:(NSURLDownload *)download;
- (id)init;

// Actions
- (void)stop;

@end
