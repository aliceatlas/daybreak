/*

SBCircleProgressIndicator.m
 
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

#import "SBCircleProgressIndicator.h"
#import "SBUtil.h"
#import "SBDownloadsView.h"

@implementation SBCircleProgressIndicator

@synthesize style;
@synthesize progress;
@synthesize selected;
@synthesize highlighted;
@synthesize backgroundColor;
@synthesize fillColor;
@synthesize alwaysDrawing;
@synthesize showPercentage;

- (id)initWithFrame:(NSRect)frame
{
    if (self = [super initWithFrame:frame])
	{
		CGColorRef aBackgroundColor = nil;
		CGColorRef aFillColor = nil;
		style = SBCircleProgressIndicatorRegulerStyle;
		progress = 0.0;
		selected = NO;
		alwaysDrawing = NO;
		showPercentage = NO;
		highlighted = NO;
		aBackgroundColor = CGColorCreateGenericGray(0.5, 1.0);
		aFillColor = CGColorCreateGenericGray(0.85, 1.0);
		self.backgroundColor = aBackgroundColor;
		self.fillColor = aFillColor;
		CGColorRelease(aBackgroundColor);
		CGColorRelease(aFillColor);
	}
    return self;
}

- (void)dealloc
{
	CGColorRelease(backgroundColor);
	CGColorRelease(fillColor);
	[super dealloc];
}

#pragma mark View

- (BOOL)isOpaque
{
	return YES;
}

// Clicking through
- (NSView*)hitTest:(NSPoint)point
{
	NSView *view = [super hitTest:point];
	return (view == self) ? nil : view;
}

#pragma mark Setter

- (void)setProgress:(CGFloat)inProgress
{
	if (progress != inProgress)
	{
		progress = inProgress;
		[self setNeedsDisplay:YES];
		if (!alwaysDrawing)
		{
			if (inProgress >= 1.0)
			{
				[self performSelector:@selector(clearProgress) withObject:nil afterDelay:0.5];
			}
		}
	}
}

- (void)setSelected:(BOOL)inSelected
{
	if (selected != inSelected)
	{
		selected = inSelected;
		[self setNeedsDisplay:YES];
	}
}

- (void)setHighlighted:(BOOL)inHighlighted
{
	if (highlighted != inHighlighted)
	{
		highlighted = inHighlighted;
		[self setNeedsDisplay:YES];
	}
}

- (void)setBackgroundColor:(CGColorRef)aBackgroundColor
{
	if (backgroundColor != aBackgroundColor)
	{
		CGColorRetain(aBackgroundColor);
		CGColorRelease(backgroundColor);
		backgroundColor = aBackgroundColor;
	}
}

- (void)setFillColor:(CGColorRef)aFillColor
{
	if (fillColor != aFillColor)
	{
		CGColorRetain(aFillColor);
		CGColorRelease(fillColor);
		fillColor = aFillColor;
	}
}

- (void)clearProgress
{
	progress = -1;
	[self setNeedsDisplay:YES];
	[[super superview] setNeedsDisplay:YES];
}

#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	if (alwaysDrawing || (!alwaysDrawing && progress < 1.0))
	{
		if (progress >= 0)
		{
			NSRect r = self.bounds;
			CGContextRef ctx = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
			CGMutablePathRef path = nil;
			CGColorRef color = nil;
			CGPoint cp = CGPointZero;
			CGFloat radius = 0;
			CGFloat lw = 0;
			CGFloat sa = 0;
			CGFloat ea = 0;
			CGFloat startAngle = 0;
			CGFloat endAngle = 0;
			CGFloat components1[4];
			CGFloat components2[4];
			NSUInteger count = 2;
			CGFloat locations[count];
			CGFloat colors[count * 4];
			CGPoint points[count];
			id superview = nil;
			BOOL isFirstResponder = NO;
			
			cp.x = NSMidX(r);
			cp.y = NSMidY(r);
			lw = 1.5;
			radius = (r.size.width < r.size.height ? r.size.width / 2 : r.size.height / 2) - lw;
			sa = 0;
			ea = (progress * 360);
			startAngle = (sa - 270) * (M_PI / 180);
			endAngle = (-ea - 270) * (M_PI / 180);
			
			superview = [self superview];
			isFirstResponder = [superview respondsToSelector:@selector(isFirstResponder)] ? [superview isFirstResponder] : NO;
			
			if (selected && keyView)
			{
				locations[0] = 0.0;
				locations[1] = 1.0;
				colors[0] = colors[1] = colors[2] = 1.0;
				colors[3] = 1.0;
				colors[4] = colors[5] = colors[6] = 0.15;
				colors[7] = 1.0;
				points[0] = CGPointZero;
				points[1] = CGPointMake(0.0, r.size.height);
				CGContextSaveGState(ctx);
				path = CGPathCreateMutable();
				CGPathAddArc(path, nil, cp.x, cp.y, radius, 0 * M_PI / 180, 360 * M_PI / 180, FALSE);
				CGContextAddPath(ctx, path);
				CGContextClip(ctx);
				SBDrawGradientInContext(ctx, count, locations, colors, points);
				CGPathRelease(path);
				CGContextRestoreGState(ctx);
			}
			
			if (style == SBCircleProgressIndicatorWhiteStyle)
			{
				if (highlighted && isFirstResponder)
				{
					SBGetAlternateSelectedDarkControlColorComponents(components1);
				}
				else {
					components1[0] = components1[1] = components1[2] = 1.0;
					components1[3] = 0.75;
				}
				CGContextSaveGState(ctx);
				path = CGPathCreateMutable();
				CGContextSetLineWidth(ctx, 1.0);
				CGPathAddArc(path, nil, cp.x, cp.y, radius - 1.0, 0 * M_PI / 180, 360 * M_PI / 180, FALSE);
				CGContextAddPath(ctx, path);
				CGContextSetRGBStrokeColor(ctx, components1[0], components1[1], components1[2], components1[3]);
				CGContextStrokePath(ctx);
				CGPathRelease(path);
				CGContextRestoreGState(ctx);
			}
			else {
				CGContextSaveGState(ctx);
				path = CGPathCreateMutable();
				color = CGColorCreateCopyWithAlpha(backgroundColor, selected && keyView ? 1.0 : 0.5);
				CGPathAddArc(path, nil, cp.x, cp.y, radius - 1.0, 0 * M_PI / 180, 360 * M_PI / 180, FALSE);
				CGContextAddPath(ctx, path);
				CGContextSetFillColorWithColor(ctx, color);
				CGContextFillPath(ctx);
				CGPathRelease(path);
				CGColorRelease(color);
				CGContextRestoreGState(ctx);
			}
			
			// Percentage(Arc)
			CGContextSaveGState(ctx);
			path = CGPathCreateMutable();
			CGPathMoveToPoint(path, nil, cp.x, cp.y);
			CGPathAddArc(path, nil, cp.x, cp.y, radius - 1.0, startAngle, endAngle, TRUE);
			CGPathCloseSubpath(path);
			CGContextAddPath(ctx, path);
			CGContextSetLineWidth(ctx, 0);
			if (highlighted && isFirstResponder)
			{
				SBGetAlternateSelectedControlColorComponents(components1);
				SBGetAlternateSelectedDarkControlColorComponents(components2);
			}
			else {
				if (style == SBCircleProgressIndicatorWhiteStyle)
				{
					components1[0] = components1[1] = components1[2] = 1.0;
					components2[0] = components2[1] = components2[2] = 1.0;
					components1[3] = components2[3] = 0.75;
				}
				else {
					components1[0] = components1[1] = components1[2] = selected && keyView ? 1.0 : 0.75;
					components2[0] = components2[1] = components2[2] = selected && keyView ? 0.75 : 0.5;
					components1[3] = components2[3] = 1.0;
				}
			}
			locations[0] = 0.0;
			locations[1] = 1.0;
			colors[0] = components2[0];
			colors[1] = components2[1];
			colors[2] = components2[2];
			colors[3] = components2[3];
			colors[4] = components1[0];
			colors[5] = components1[1];
			colors[6] = components1[2];
			colors[7] = components1[3];
			points[0] = CGPointZero;
			points[1] = CGPointMake(0.0, r.size.height);
			CGContextClip(ctx);
			SBDrawGradientInContext(ctx, count, locations, colors, points);
			CGPathRelease(path);
			CGContextRestoreGState(ctx);
			
			if (showPercentage)
			{
				// Percentage(String)
				NSString *percentage = [NSString stringWithFormat:@"%.1f%%", progress * 100];
				NSDictionary *attributes = nil;
				NSDictionary *sattributes = nil;
				NSRect tr = NSZeroRect;
				NSRect sr = NSZeroRect;
				attributes = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSFont boldSystemFontOfSize:10.0], NSFontAttributeName, 
							  [NSColor whiteColor], NSForegroundColorAttributeName, 
							  nil];
				sattributes = [NSDictionary dictionaryWithObjectsAndKeys:
							   [NSFont boldSystemFontOfSize:10.0], NSFontAttributeName, 
							   [NSColor colorWithCalibratedWhite:0.0 alpha:0.75], NSForegroundColorAttributeName, 
							   nil];
				tr.size = [percentage sizeWithAttributes:attributes];
				tr.origin.x = (r.size.width - tr.size.width) / 2;
				tr.origin.y = (r.size.height - tr.size.height) / 2;
				
				// Draw edge
				CGContextSaveGState(ctx);
				sr = tr;
				sr.origin.y -= 1.0;
				// bottom
				[percentage drawInRect:sr withAttributes:sattributes];
				sr = tr;
				sr.origin.y += 1.0;
				// top
				[percentage drawInRect:sr withAttributes:sattributes];
				sr = tr;
				sr.origin.x -= 1.0;
				// left
				[percentage drawInRect:sr withAttributes:sattributes];
				sr = tr;
				sr.origin.x += 1.0;
				// right
				[percentage drawInRect:sr withAttributes:sattributes];
				CGContextRestoreGState(ctx);
				
				// Draw text
				CGContextSaveGState(ctx);
				[percentage drawInRect:tr withAttributes:attributes];
				CGContextRestoreGState(ctx);
			}
		}
	}
}

@end
