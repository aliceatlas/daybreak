/*

SBLoadButton.m
 
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

#import "SBLoadButton.h"


@implementation SBLoadButton

@synthesize images;
@synthesize on;

- (id)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		[self constructIndicator];
		on = NO;
	}
	return self;
}

- (void)dealloc
{
	[images release];
	[super dealloc];
}

#pragma mark NSCoding Protocol

- (id)initWithCoder:(NSCoder *)decoder
{
	if ((self = [super initWithCoder:decoder]))
	{
		if ([decoder allowsKeyedCoding])
		{
			if ([decoder containsValueForKey:@"images"])
			{
				self.images = [decoder decodeObjectForKey:@"images"];
			}
			if ([decoder containsValueForKey:@"on"])
			{
				self.on = [decoder decodeBoolForKey:@"on"];
			}
		}
	}
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];
	if (images)
		[coder encodeObject:images forKey:@"images"];
	[coder encodeBool:on forKey:@"on"];
}

- (void)constructIndicator
{
	indicator = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect((self.bounds.size.width - 16.0) / 2, (self.bounds.size.height - 16.0) / 2, 16.0, 16.0)];
	[indicator setAutoresizingMask:(NSViewMaxXMargin | NSViewMinXMargin | NSViewMaxYMargin | NSViewMinYMargin)];
	[indicator setUsesThreadedAnimation:YES];
	[indicator setStyle:NSProgressIndicatorSpinningStyle];
	[indicator setDisplayedWhenStopped:NO];
	[indicator setControlSize:NSSmallControlSize];
	[self addSubview:indicator];
}

- (void)setImages:(NSArray *)inImages
{
	if (images != inImages)
	{
		[inImages retain];
		[images release];
		images = inImages;
		if ([images count] > 0)
		{
			self.image = [images objectAtIndex:0];
			[self setNeedsDisplay:YES];
		}
		on = NO;
	}
}

- (void)setFrame:(NSRect)frame
{
	NSRect r = frame;
	r.size.width = r.size.height;
	r.origin.x += (frame.size.width - r.size.width) / 2;
	[super setFrame:r];
}

- (void)setOn:(BOOL)isOn
{
	if (on != isOn)
	{
		if (isOn)
		{
			[indicator startAnimation:nil];
			on = YES;
		}
		else {
			[indicator stopAnimation:nil];
			on = NO;
		}
		[self switchImage];
	}
}

- (void)switchImage
{
	if ([images count] == 2)
	{
		if (on)
		{
			if (self.image == [images objectAtIndex:0])
			{
				self.image = [images objectAtIndex:1];
				[self setNeedsDisplay:YES];
			}
		}
		else {
			if (self.image == [images objectAtIndex:1])
			{
				self.image = [images objectAtIndex:0];
				[self setNeedsDisplay:YES];
			}
		}
	}
}

#pragma mark Event

- (void)mouseUp:(NSEvent *)theEvent
{
	if (enabled)
	{
		NSPoint location = [theEvent locationInWindow];
		NSPoint point = [self convertPoint:location fromView:nil];
		if (NSPointInRect(point, self.bounds))
		{
			self.pressed = NO;
			self.on = !on;
			[self executeAction];
		}
	}
}

#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	[super drawRect:self.bounds];
}

@end
