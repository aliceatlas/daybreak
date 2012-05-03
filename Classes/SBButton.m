/*

SBButton.m
 
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

#import "SBButton.h"


@implementation SBButton

@synthesize title;
@synthesize image;
@synthesize disableImage;
@synthesize backImage;
@synthesize backDisableImage;
@synthesize action;
@synthesize enabled;
@synthesize pressed;
@synthesize keyEquivalent;
@synthesize keyEquivalentModifierMask;

- (id)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		title = nil;
		pressed = NO;
		enabled = YES;
		keyEquivalent = nil;
		keyEquivalentModifierMask = 0;
	}
	return self;
}

- (void)dealloc
{
	[title release];
	[image release];
	[disableImage release];
	[backImage release];
	[backDisableImage release];
	action = nil;
	[keyEquivalent release];
	[super dealloc];
}

#pragma mark NSCoding Protocol

- (id)initWithCoder:(NSCoder *)decoder
{
	if ((self = [super initWithCoder:decoder]))
	{
		if ([decoder allowsKeyedCoding])
		{
			if ([decoder containsValueForKey:@"image"])
			{
				self.image = [decoder decodeObjectForKey:@"image"];
			}
			if ([decoder containsValueForKey:@"disableImage"])
			{
				self.disableImage = [decoder decodeObjectForKey:@"disableImage"];
			}
			if ([decoder containsValueForKey:@"backImage"])
			{
				self.backImage = [decoder decodeObjectForKey:@"backImage"];
			}
			if ([decoder containsValueForKey:@"backDisableImage"])
			{
				self.backDisableImage = [decoder decodeObjectForKey:@"backDisableImage"];
			}
			if ([decoder containsValueForKey:@"action"])
			{
				self.action = NSSelectorFromString([decoder decodeObjectForKey:@"action"]);
			}
			if ([decoder containsValueForKey:@"keyEquivalent"])
			{
				self.keyEquivalent = [decoder decodeObjectForKey:@"keyEquivalent"];
			}
			if ([decoder containsValueForKey:@"enabled"])
			{
				self.enabled = [decoder decodeBoolForKey:@"enabled"];
			}
			if ([decoder containsValueForKey:@"keyEquivalentModifierMask"])
			{
				self.keyEquivalentModifierMask = [decoder decodeIntegerForKey:@"keyEquivalentModifierMask"];
			}
		}
	}
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];
	if (image)
		[coder encodeObject:image forKey:@"image"];
	if (disableImage)
		[coder encodeObject:disableImage forKey:@"disableImage"];
	if (backImage)
		[coder encodeObject:backImage forKey:@"backImage"];
	if (backDisableImage)
		[coder encodeObject:backDisableImage forKey:@"backDisableImage"];
	if (action)
		[coder encodeObject:NSStringFromSelector(action) forKey:@"action"];
	if (keyEquivalent)
		[coder encodeObject:keyEquivalent forKey:@"keyEquivalent"];
	[coder encodeBool:enabled forKey:@"enabled"];
	[coder encodeInteger:keyEquivalentModifierMask forKey:@"keyEquivalentModifierMask"];
}

#pragma mark Setter

- (void)setToolbarVisible:(BOOL)isToolbarVisible
{
	if (toolbarVisible != isToolbarVisible)
	{
		toolbarVisible = isToolbarVisible;
		[self setNeedsDisplay:YES];
	}
}

- (void)setEnabled:(BOOL)inEnabled
{
	if (enabled != inEnabled)
	{
		enabled = inEnabled;
		[self setNeedsDisplay:YES];
	}
}

- (void)setPressed:(BOOL)isPressed
{
	if (pressed != isPressed)
	{
		pressed = isPressed;
		[self setNeedsDisplay:YES];
	}
}

- (void)setTitle:(NSString *)inTitle
{
	if (![title isEqualToString:inTitle])
	{
		[inTitle retain];
		[title release];
		title = inTitle;
		[self setNeedsDisplayInRect:self.bounds];
	}
}

#pragma mark Exec

- (void)executeAction
{
	if (target && action)
	{
		if ([target respondsToSelector:action])
		{
			[target performSelector:action withObject:self];
		}
	}
}

#pragma mark Event

- (void)mouseDown:(NSEvent *)theEvent
{
	if (enabled)
	{
		self.pressed = YES;
	}
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	if (enabled)
	{
		NSPoint location = [theEvent locationInWindow];
		NSPoint point = [self convertPoint:location fromView:nil];
		self.pressed = NSPointInRect(point, self.bounds);
	}
}

- (void)mouseUp:(NSEvent *)theEvent
{
	if (enabled)
	{
		NSPoint location = [theEvent locationInWindow];
		NSPoint point = [self convertPoint:location fromView:nil];
		if (NSPointInRect(point, self.bounds))
		{
			self.pressed = NO;
			[self executeAction];
		}
	}
}

#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	NSImage *anImage = nil;
	NSRect r = self.bounds;
	if (keyView)
	{
		if (enabled)
		{
			anImage = image ? image : nil;
		}
		else {
			anImage = disableImage ? disableImage : (image ? image : nil);
		}
	}
	else {
		if (enabled)
		{
			anImage = backImage ? backImage : (image ? image : nil);
		}
		else {
			anImage = backDisableImage ? backDisableImage : (backImage ? backImage : (image ? image : nil));
		}
	}
	if (anImage)
	{
		[anImage drawInRect:r fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
		if (pressed)
		{
			[anImage drawInRect:r fromRect:NSZeroRect operation:NSCompositeXOR fraction:0.3];
		}
	}
	if (title)
	{
		NSDictionary *attributes = nil;
		NSShadow *shadow = nil;
		NSMutableParagraphStyle *style = nil;
		CGFloat padding = 10.0;
		NSColor *color = nil;
		shadow = [[NSShadow alloc] init];
		[shadow setShadowOffset:NSMakeSize(0.0, -1.0)];
		[shadow setShadowColor:keyView ? [NSColor blackColor] : [NSColor whiteColor]];
		style = [[NSMutableParagraphStyle alloc] init];
		[style setLineBreakMode:NSLineBreakByTruncatingTail];
		color = [NSColor colorWithCalibratedWhite:1.0 alpha:keyView ? (pressed ? 0.5 : 1.0) : (pressed ? 0.25 : 0.5)];
		attributes = [NSDictionary dictionaryWithObjectsAndKeys:
					  [NSFont boldSystemFontOfSize:11.0], NSFontAttributeName, 
					  color, NSForegroundColorAttributeName, 
					  shadow, NSShadowAttributeName, 
					  style, NSParagraphStyleAttributeName, nil];
		r.size = [title sizeWithAttributes:attributes];
		if (r.size.width > (self.bounds.size.width - padding * 2))
			r.size.width = (self.bounds.size.width - padding * 2);
		r.origin.x = padding + ((self.bounds.size.width - padding * 2) - r.size.width) / 2;
		r.origin.y = (self.bounds.size.height - r.size.height) / 2;
		[title drawInRect:r withAttributes:attributes];
		[shadow release];
		[style release];
	}
}

@end