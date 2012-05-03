/*

SBBLKGUIScrollView.m
 
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

#import "SBBLKGUIScrollView.h"


@implementation SBBLKGUIScrollView

@dynamic horizontalScroller;
@dynamic verticalScroller;

- (id)initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect])
	{
		[self initialize];
	}
	return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
    if (self = [super initWithCoder:coder])
	{
		[self initialize];
	}
	return self;
}

/*
+ (Class)_horizontalScrollerClass
{
	return [SBBLKGUIScroller class];
}

+ (Class)_verticalScrollerClass
{
	return [SBBLKGUIScroller class];
}
*/

- (void)initialize
{
	NSClipView *contentView = nil;
	SBBLKGUIClipView *newContentView = nil;
//	NSScroller *scroller = nil;
//	SBBLKGUIScroller *newScroller = nil;
	
	contentView = [self contentView];
	newContentView = [[[SBBLKGUIClipView alloc] initWithFrame:[contentView frame]] autorelease];
	[self setContentView:newContentView];
//	[self setHasVerticalScroller:hasVerticalScroller];
//	[self setHasHorizontalScroller:hasHorizontalScroller];
//	if ([self hasVerticalScroller])
//	{
//		scroller = [self verticalScroller];
//		newScroller = [[[SBBLKGUIScroller alloc] initWithFrame:[scroller frame]] autorelease];
//		newScroller.backgroundColor = [self backgroundColor];
//		[newScroller setArrowsPosition:NSScrollerArrowsMaxEnd];
//		[newScroller setControlSize:[scroller controlSize]];
//		[self setVerticalScroller:newScroller];
//	}
//	
//	if ([self hasHorizontalScroller])
//	{
//		scroller = [self horizontalScroller];
//		newScroller = [[[SBBLKGUIScroller alloc] initWithFrame:[scroller frame]] autorelease];
//		newScroller.backgroundColor = [self backgroundColor];
//		[newScroller setArrowsPosition:NSScrollerArrowsMaxEnd];
//		[newScroller setControlSize:[scroller controlSize]];
//		[self setHorizontalScroller:newScroller];
//	}
}

#if 1
#else
- (SBBLKGUIScroller *)horizontalScroller
{
	return (SBBLKGUIScroller *)[super horizontalScroller];
}

- (SBBLKGUIScroller *)verticalScroller
{
	return (SBBLKGUIScroller *)[super verticalScroller];
}

- (void)setHorizontalScroller:(SBBLKGUIScroller *)horizontalScroller
{
	[super setHorizontalScroller:(NSScroller *)horizontalScroller];
}

- (void)setVerticalScroller:(SBBLKGUIScroller *)verticalScroller
{
	[super setVerticalScroller:(NSScroller *)verticalScroller];
}
#endif

- (void)setBackgroundColor:(NSColor *)inBackgroundColor
{
	[super setBackgroundColor:inBackgroundColor];
#if 1
#else
	if ([self hasVerticalScroller])
	{
		[[self verticalScroller] setBackgroundColor:inBackgroundColor];
	}
	
	if ([self hasHorizontalScroller])
	{
		[[self horizontalScroller] setBackgroundColor:inBackgroundColor];
	}
#endif
}

- (void)setDrawsBackground:(BOOL)flag
{
	[super setDrawsBackground:flag];
#if 1
#else
	if ([self hasVerticalScroller])
	{
		[[self verticalScroller] setDrawsBackground:flag];
	}
	
	if ([self hasHorizontalScroller])
	{
		[[self horizontalScroller] setDrawsBackground:flag];
	}
#endif
}

- (void)drawRect:(NSRect)rect
{
	if ([self drawsBackground])
	{
		NSColor *color = [NSColor colorWithCalibratedWhite:0.0 alpha:0.85];
		[color set];
		NSRectFill(rect);
		[[NSColor lightGrayColor] set];
		[[NSBezierPath bezierPathWithRect:rect] stroke];
	}
	else {
		[super drawRect:rect];
	}
}

- (BOOL)_fixHeaderAndCornerViews
{
	return NO;
}

@end


@implementation SBBLKGUIScroller

@synthesize drawsBackground, backgroundColor;

- (id)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		drawsBackground = NO;
		backgroundColor = nil;
	}
	return self;
}

- (void)dealloc
{
	[backgroundColor release];
	[super dealloc];
}

- (void)setDrawsBackground:(BOOL)inDrawsBackground
{
	if (drawsBackground != inDrawsBackground)
	{
		drawsBackground = inDrawsBackground;
		[self setNeedsDisplay:YES];
	}
}

- (void)setBackgroundColor:(NSColor *)inBackgroundColor
{
	if (backgroundColor != inBackgroundColor)
	{
		[inBackgroundColor retain];
		if (backgroundColor)
		{
			[backgroundColor release];
			backgroundColor = nil;
		}
		backgroundColor = inBackgroundColor;
		[self setNeedsDisplay:YES];
	}
}

- (void)drawRect:(NSRect)rect
{
	NSRect r = self.bounds;
	if (drawsBackground)
	{
		NSColor *color = [NSColor colorWithCalibratedWhite:0.0 alpha:0.85];
		[backgroundColor ? backgroundColor : color set];
		NSRectFill(r);
	}
	[super drawRect:r];
}

- (void)drawArrow:(NSScrollerArrow)arrow highlightPart:(int)part
{
	NSColor *color = [NSColor colorWithCalibratedWhite:0.0 alpha:0.85];
	BOOL isFlipped = NO;
	NSRect arrowRect = NSZeroRect;
	NSRect drawRect = NSZeroRect;
	NSImage *image = nil;
	BOOL isVertical = NO;
	
	isVertical = ([self bounds].size.width < [self bounds].size.height);
	isFlipped = [self isFlipped];
	arrowRect = [self bounds];
	
	// Fill bounds
	[backgroundColor set];
	NSRectFill(arrowRect);
	
	// Up
	if (isVertical)
	{
		NSImage *downImage = nil;
		if (part == 1)
			image = [NSImage imageNamed:@"BLKGUI_ScrollerArrow-Highlighted-Vertical-Up.png"];
		else
			image = [NSImage imageNamed:@"BLKGUI_ScrollerArrow-Vertical-Up.png"];
		downImage = [NSImage imageNamed:@"BLKGUI_ScrollerArrow-Vertical-Down.png"];
		drawRect.size = [image size];
		drawRect.origin.y = arrowRect.origin.y + (arrowRect.size.height - ([image size].height + [downImage size].height));
	}
	// Right
	else {
		if (part == 0)
			image = [NSImage imageNamed:@"BLKGUI_ScrollerArrow-Highlighted-Horizontal-Right.png"];
		else
			image = [NSImage imageNamed:@"BLKGUI_ScrollerArrow-Horizontal-Right.png"];
		drawRect.size = [image size];
		drawRect.origin.x = (arrowRect.origin.x + arrowRect.size.width) - drawRect.size.width;
	}
	if (drawsBackground)
	{
		[backgroundColor ? backgroundColor : color set];
		NSRectFill(drawRect);
	}
	[image drawInRect:drawRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:isFlipped];
	
	// Down
	if (isVertical)
	{
		if (part == 0)
			image = [NSImage imageNamed:@"BLKGUI_ScrollerArrow-Highlighted-Vertical-Down.png"];
		else
			image = [NSImage imageNamed:@"BLKGUI_ScrollerArrow-Vertical-Down.png"];
		drawRect.size = [image size];
		drawRect.origin.y = (arrowRect.origin.y + arrowRect.size.height) - drawRect.size.height;
	}
	// Left
	else {
		NSImage *rightImage = nil;
		
		if (part == 1)
			image = [NSImage imageNamed:@"BLKGUI_ScrollerArrow-Highlighted-Horizontal-Left.png"];
		else
			image = [NSImage imageNamed:@"BLKGUI_ScrollerArrow-Horizontal-Left.png"];
		rightImage = [NSImage imageNamed:@"BLKGUI_ScrollerArrow-Horizontal-Right.png"];
		drawRect.size = [image size];
		drawRect.origin.x = (arrowRect.origin.x + arrowRect.size.width) - (drawRect.size.width + [rightImage size].width);
	}
	if (drawsBackground)
	{
		[backgroundColor ? backgroundColor : color set];
		NSRectFill(drawRect);
	}
	[image drawInRect:drawRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:isFlipped];
	
	// Stroke bounds
	[[NSColor lightGrayColor] set];
	NSFrameRect([self bounds]);
}

- (void)drawKnobSlotInRect:(struct _NSRect)rect highlight:(BOOL)highlight
{
	NSRect r = [self rectForPart:NSScrollerKnobSlot];
	NSColor *color = [NSColor colorWithCalibratedWhite:0.0 alpha:0.85];
	NSImage *image = nil;
	NSRect drawRect = NSZeroRect;
	BOOL isVertical = NO;
	BOOL isFlipped = NO;
	
	isVertical = ([self bounds].size.width < [self bounds].size.height);
	isFlipped = [self isFlipped];
	
	if (drawsBackground)
	{
		[backgroundColor ? backgroundColor : color set];
		NSRectFill(r);
	}
	else {
		[[NSColor blackColor] set];
		NSRectFill(r);
	}
	
	// Stroke bounds
	[[NSColor lightGrayColor] set];
	NSFrameRect(r);
	
	// Get image
	if (isVertical)
	{
		image = [NSImage imageNamed:@"BLKGUI_ScrollerSlot-Vertical-Top.png"];
	}
	else {
		image = [NSImage imageNamed:@"BLKGUI_ScrollerSlot-Horizontal-Left.png"];
	}
	
	// Draw top image
	if (image)
	{
		drawRect.size = [image size];
		[image drawInRect:drawRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:isFlipped];
	}
}

- (void)drawKnob
{
	BOOL isFlipped = NO;
	NSRect knobRect = NSZeroRect;
	NSRect drawRect = NSZeroRect;
	BOOL isVertical = NO;
	NSInteger m = 2;
	
	
	isVertical = ([self bounds].size.width < [self bounds].size.height);
	isFlipped = [self isFlipped];
	knobRect = [self rectForPart:NSScrollerKnob];
	
	if (isVertical)
	{
		NSImage *topImage = nil;
		NSImage *middleImage = nil;
		NSImage *bottomImage = nil;
		
		// Bottom
		bottomImage = [NSImage imageNamed:@"BLKGUI_ScrollerKnob-Vertical-Bottom.png"];
		drawRect.size = [bottomImage size];
		drawRect.origin.x = knobRect.origin.x + (knobRect.size.width - drawRect.size.width) / 2;
		drawRect.origin.y = (knobRect.origin.y + knobRect.size.height) - [bottomImage size].height - m;
		[bottomImage drawInRect:drawRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:isFlipped];
		
		// Top
		topImage = [NSImage imageNamed:@"BLKGUI_ScrollerKnob-Vertical-Top.png"];
		drawRect.size = [topImage size];
		drawRect.origin.x = knobRect.origin.x + (knobRect.size.width - drawRect.size.width) / 2;
		drawRect.origin.y = knobRect.origin.y + m;
		[topImage drawInRect:drawRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:isFlipped];
		
		// Middle
		middleImage = [NSImage imageNamed:@"BLKGUI_ScrollerKnob-Vertical-Middle.png"];
		drawRect.size.width = [middleImage size].width;
		drawRect.origin.x = knobRect.origin.x + (knobRect.size.width - drawRect.size.width) / 2;
		drawRect.origin.y = knobRect.origin.y + [bottomImage size].height + m;
		drawRect.size.height = knobRect.size.height - ([bottomImage size].height + [topImage size].height) - (m * 2);
		[middleImage drawInRect:drawRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:isFlipped];
	}
	else {
		NSImage *leftImage = nil;
		NSImage *centerImage = nil;
		NSImage *rightImage = nil;
		
		// Left
		leftImage = [NSImage imageNamed:@"BLKGUI_ScrollerKnob-Horizontal-Left.png"];
		drawRect.size = [leftImage size];
		drawRect.origin.x = knobRect.origin.x + m;
		drawRect.origin.y = knobRect.origin.y + (knobRect.size.height - drawRect.size.height) / 2;
		[leftImage drawInRect:drawRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:isFlipped];
		
		// Right
		rightImage = [NSImage imageNamed:@"BLKGUI_ScrollerKnob-Horizontal-Right.png"];
		drawRect.size = [rightImage size];
		drawRect.origin.y = knobRect.origin.y + (knobRect.size.height - drawRect.size.height) / 2;
		drawRect.origin.x = knobRect.origin.x + knobRect.size.width - ([leftImage size].width + m);
		[rightImage drawInRect:drawRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:isFlipped];
		
		// Center
		centerImage = [NSImage imageNamed:@"BLKGUI_ScrollerKnob-Horizontal-Center.png"];
		drawRect.size.height = [centerImage size].height;
		drawRect.origin.y = knobRect.origin.y + (knobRect.size.height - drawRect.size.height) / 2;
		drawRect.origin.x = knobRect.origin.x + [leftImage size].width + m;
		drawRect.size.width = knobRect.size.width - ([leftImage size].width + [rightImage size].width + m * 2);
		[centerImage drawInRect:drawRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:isFlipped];
	}
}

@end

@implementation SBBLKGUIClipView

- (BOOL)isFlipped
{
	return YES;
}

@end