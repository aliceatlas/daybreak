/*

SBBLKGUISlider.m
 
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

#import "SBBLKGUISlider.h"
#import "SBUtil.h"

@implementation SBBLKGUISlider

- (id)initWithFrame:(NSRect)frameRect
{
	if (self = [super initWithFrame:frameRect])
	{
		SBBLKGUISliderCell *cell = nil;
		cell = [[[SBBLKGUISliderCell alloc] init] autorelease];
		[self setCell:cell];
	}
	
	return self;
}

@end

@implementation SBBLKGUISliderCell

- (void)drawKnob:(NSRect)knobRect
{
	CGContextRef ctx = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
	CGMutablePathRef path = nil;
	NSUInteger count = 2;
	CGFloat locations[count];
	CGFloat colors[count * 4];
	CGPoint points[count];
	CGRect r = CGRectInset(NSRectToCGRect(knobRect), 2, 2);
	
	r.origin.y += 1;
	locations[0] = 0.0;
	locations[1] = 1.0;
	colors[0] = colors[1] = colors[2] = 0.45;
	colors[3] = 1.0;
	colors[4] = colors[5] = colors[6] = 0.05;
	colors[7] = 1.0;
	points[0] = CGPointMake(0.0, r.origin.y);
	points[1] = CGPointMake(0.0, CGRectGetMaxY(r));
	path = CGPathCreateMutable();
	CGContextSaveGState(ctx);
	CGPathAddEllipseInRect(path, nil, r);
	CGContextAddPath(ctx, path);
	CGContextClip(ctx);
	SBDrawGradientInContext(ctx, count, locations, colors, points);
	CGContextRestoreGState(ctx);
	
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, path);
	CGContextSetRGBStrokeColor(ctx, 0.75, 0.75, 0.75, 1.0);
	CGContextSetLineWidth(ctx, 0.5);
	CGContextStrokePath(ctx);
	CGContextRestoreGState(ctx);
	
	CGPathRelease(path);
}

//- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
//{
//	[super drawWithFrame:cellFrame inView:controlView];
//	
//	[super drawBarInside:cellFrame flipped:[controlView isFlipped]];
//	[self drawKnob];
//}

@end
