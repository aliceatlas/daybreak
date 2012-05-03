/*

SBSegmentedButton.m
 
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

#import "SBSegmentedButton.h"


@implementation SBSegmentedButton

@synthesize buttons;

- (id)init
{
	if (self = [super initWithFrame:NSZeroRect])
	{
		
	}
	return self;
}

- (void)dealloc
{
	[buttons release];
	[super dealloc];
}

#pragma mark NSCoding Protocol

- (id)initWithCoder:(NSCoder *)decoder
{
	if ((self = [super initWithCoder:decoder]))
	{
		if ([decoder allowsKeyedCoding])
		{
			if ([decoder containsValueForKey:@"buttons"])
			{
				self.buttons = [decoder decodeObjectForKey:@"buttons"];
			}
		}
	}
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];
	if (buttons)
		[coder encodeObject:buttons forKey:@"buttons"];
}

#pragma mark Setter

- (void)setButtons:(NSArray *)inButtons
{
	if (buttons != inButtons)
	{
		[inButtons retain];
		[buttons release];
		buttons = inButtons;
		for (SBButton *button in buttons)
		{
			[self addSubview:button];
		}
		[self adjustFrame];
	}
}

#pragma mark Actions

- (void)adjustFrame
{
	NSRect r = NSZeroRect;
	for (SBButton *button in buttons)
	{
		NSRect br = button.frame;
		r = NSUnionRect(r, br);
	}
	self.frame = r;
}

@end
