/*

SBSectionGroupe.m
 
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

#import "SBSectionGroupe.h"


@implementation SBSectionGroupe

@synthesize title;
@synthesize items;

+ (id)groupeWithTitle:(NSString *)title
{
	SBSectionGroupe *groupe = [[[SBSectionGroupe alloc] init] autorelease];
	[groupe setTitle:title];
	return groupe;
}

- (id)init
{
	if (self = [super init])
	{
		title = nil;
		items = [[NSMutableArray alloc] initWithCapacity:0];
	}
	return self;
}

- (void)dealloc
{
	[title release];
	[items release];
	[super dealloc];
}

- (void)addItem:(SBSectionItem *)item
{
	[items addObject:item];
}

@end

@implementation SBSectionItem

@synthesize title;
@synthesize keyName;
@synthesize context;

+ (id)itemWithTitle:(NSString *)title keyName:(NSString *)keyName controlClass:(Class)controlClass context:(id)context
{
	SBSectionItem *item = [[[SBSectionItem alloc] init] autorelease];
	[item setTitle:title];
	[item setKeyName:keyName];
	[item setControlClass:controlClass];
	[item setContext:context];
	return item;
}

- (id)init
{
	if (self = [super init])
	{
		title = nil;
		keyName = nil;
		controlClass = [NSObject class];
	}
	return self;
}

- (void)dealloc
{
	[title release];
	[keyName release];
	[context release];
	[super dealloc];
}

- (Class)controlClass
{
	return controlClass;
}

- (void)setControlClass:(Class)aControlClass
{
	if (controlClass != aControlClass)
	{
		controlClass = aControlClass;
	}
}

@end