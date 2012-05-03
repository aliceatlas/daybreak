/*

SBTabbarItem.m
 
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

#import "SBTabbarItem.h"
#import "SBCircleProgressIndicator.h"
#import "SBTabbar.h"
#import "SBUtil.h"

@implementation SBTabbarItem

@synthesize tabbar;
@synthesize progressIndicator;
@synthesize identifier;
@synthesize image;
@synthesize title;
@synthesize selected;
@synthesize closable;
@synthesize closeSelector;
@synthesize selectSelector;
@dynamic progress;

- (id)initWithFrame:(NSRect)frame
{
    if (self = [super initWithFrame:frame])
	{
		[self constructProgressIndicator];
		area = [[NSTrackingArea alloc] initWithRect:self.bounds options:(NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved |NSTrackingActiveAlways | NSTrackingInVisibleRect) owner:self userInfo:nil];
		[self addTrackingArea:area];
	}
    return self;
}

- (void)dealloc
{
	[self destructProgressIndicator];
	tabbar = nil;
	[identifier release];
	[image release];
	[title release];
	closeSelector = nil;
	selectSelector = nil;
	[area release];
	[super dealloc];
}

#pragma mark Rects

- (CGRect)closableRect
{
	CGRect r = CGRectZero;
	CGFloat across = 12.0;
	CGFloat margin = (self.bounds.size.height - across) / 2;
	r = CGRectMake(margin, margin, across, across);
	return r;
}

- (CGRect)progressRect
{
	CGRect r = CGRectZero;
	CGFloat across = 18.0;
	CGFloat margin = (self.bounds.size.height - across) / 2;
	r = CGRectMake(self.bounds.size.width - margin - across, margin, across, across);
	return r;
}

#pragma mark Getter

- (CGFloat)progress
{
	return progressIndicator.progress;
}

#pragma mark Setter

- (void)setKeyView:(BOOL)isKeyView
{
	progressIndicator.keyView = isKeyView;
	[super setKeyView:isKeyView];
}

- (void)setToolbarVisible:(BOOL)isToolbarVisible
{
	if (toolbarVisible != isToolbarVisible)
	{
		toolbarVisible = isToolbarVisible;
		progressIndicator.toolbarVisible = isToolbarVisible;
		[self setNeedsDisplay:YES];
	}
}

- (void)setTitle:(NSString *)inTitle
{
	if (![title isEqualToString:inTitle])
	{
		[inTitle retain];
		if (title)
		{
			[title release];
			title = nil;
		}
		title = inTitle;
		[self setNeedsDisplay:YES];
	}
}

- (void)setSelected:(BOOL)inSelected
{
	if (selected != inSelected)
	{
		selected = inSelected;
		progressIndicator.selected = inSelected;
		[self setNeedsDisplay:YES];
	}
}

- (void)setClosable:(BOOL)inClosable
{
	if (closable != inClosable)
	{
		closable = inClosable;
		[self setNeedsDisplay:YES];
	}
}

- (void)setProgress:(CGFloat)progress
{
	progressIndicator.progress = progress;
}

#pragma mark Destruction

- (void)destructProgressIndicator
{
	if (progressIndicator)
	{
		[progressIndicator removeFromSuperview];
		[progressIndicator release];
		progressIndicator = nil;
	}
}

#pragma mark Construction

- (void)constructProgressIndicator
{
	[self destructProgressIndicator];
	progressIndicator = [[SBCircleProgressIndicator alloc] initWithFrame:NSRectFromCGRect(self.progressRect)];
	[progressIndicator setAutoresizingMask:(NSViewMinXMargin)];
	[self addSubview:progressIndicator];
}

#pragma mark Exec

- (void)executeShouldClose
{
	if (target && closeSelector)
	{
		if ([target respondsToSelector:closeSelector])
		{
			[[NSRunLoop currentRunLoop] cancelPerformSelector:closeSelector target:target argument:nil];
			[target performSelector:closeSelector withObject:self afterDelay:0];
		}
	}
}

- (void)executeShouldSelect
{
	if (target && selectSelector)
	{
		if ([target respondsToSelector:selectSelector])
		{
			[target performSelector:selectSelector withObject:self afterDelay:0];
		}
	}
}

#pragma mark Event

#pragma mark Event

- (void)mouseDown:(NSEvent *)theEvent
{
	NSPoint location = [theEvent locationInWindow];
	NSPoint point = [self convertPoint:location fromView:nil];
	_dragInClose = NO;
	if (closable)
	{
		_downInClose = CGRectContainsPoint([self closableRect], NSPointToCGPoint(point));
		if (_downInClose)
		{
			// Close
			_dragInClose = YES;
			[self setNeedsDisplay:YES];
		}
	}
	if (!_dragInClose)
	{
		[[self superview] mouseDown:theEvent];
		if (!self.selected)
		{
			[self executeShouldSelect];
		}
		else {
			[tabbar executeShouldReselect:self];
		}
	}
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	NSPoint location = [theEvent locationInWindow];
	NSPoint point = [self convertPoint:location fromView:nil];
	if (_downInClose)
	{
		// Close
		BOOL close =  CGRectContainsPoint([self closableRect], NSPointToCGPoint(point));
		if (_dragInClose != close)
		{
			_dragInClose = close;
			[self setNeedsDisplay:YES];
		}
	}
	else {
		[[self superview] mouseDragged:theEvent];
	}
}

- (void)mouseMoved:(NSEvent *)theEvent
{
	if ([tabbar canClosable])
	{
		NSPoint location = [theEvent locationInWindow];
		NSPoint point = [self convertPoint:location fromView:nil];
		[[self superview] mouseMoved:theEvent];
		if (CGRectContainsPoint(NSRectToCGRect(self.bounds), NSPointToCGPoint(point)))
		{
			[tabbar constructClosableTimerForItem:self];
		}
		else {
			[tabbar applyDisclosableAllItem];
		}
	}
}

- (void)mouseEntered:(NSEvent *)theEvent
{
	[[self superview] mouseEntered:theEvent];
}

- (void)mouseExited:(NSEvent *)theEvent
{
	[[self superview] mouseExited:theEvent];
	if ([tabbar canClosable])
	{
		[tabbar applyDisclosableAllItem];
	}
}

- (void)mouseUp:(NSEvent *)theEvent
{
	NSPoint location = [theEvent locationInWindow];
	NSPoint point = [self convertPoint:location fromView:nil];
	if (_downInClose)
	{
		// Close
		if (self.closable)
		{
			if (CGRectContainsPoint([self closableRect], NSPointToCGPoint(point)))
			{
				[self executeShouldClose];
			}
		}
	}
	else {
		[[self superview] mouseUp:theEvent];
	}
	_dragInClose = NO;
	_downInClose = NO;
	[self setNeedsDisplay:YES];
}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	return [self.tabbar menuForItem:self];
}

#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
	CGRect b = NSRectToCGRect(self.bounds);
	CGPathRef path = nil;
	CGPathRef strokePath = nil;
	NSUInteger count = 2;
	CGFloat locations[count];
	CGFloat colors[count * 4];
	CGFloat storkeColor[4];
	CGPoint points[count];
	CGFloat grayScaleDown = 0.0;
	CGFloat grayScaleUp = 0.0;
	CGFloat strokeGrayScale = 0.0;
	CGFloat titleLeftMargin = 10.0;
	CGFloat titleRightMargin = self.bounds.size.width - [self progressRect].origin.x;
	locations[0] = 0.0;
	locations[1] = 1.0;
	
	// Paths
	// Gray scales
	if (selected)
	{
		path = SBRoundedPath(CGRectInset(b, 0.0, 0.0), 4.0, 0.0, NO, YES);
		strokePath = SBRoundedPath(CGRectInset(b, 0.5, 0.5), 4.0, 0.0, NO, YES);
		grayScaleDown = (keyView ? 140 : 207) / 255.0;
		grayScaleUp = (keyView ? (kSBFlagIsSnowLepard ? 175 : 150) : (kSBFlagIsSnowLepard ? 222 : 207)) / 255.0;
		strokeGrayScale = 0.2;
	}
	else {
		path = SBRoundedPath(CGRectInset(b, 0.0, 1.0), 4.0, 0.0, YES, NO);
		strokePath = SBRoundedPath(CGRectInset(b, 0.5, 1.0), 4.0, 0.0, YES, NO);
		grayScaleDown = (keyView ? 130 : 207) / 255.0;
		grayScaleUp = (keyView ? 140 : 207) / 255.0;
		strokeGrayScale = 0.4;
	}
	
	// Frame
	colors[0] = colors[1] = colors[2] = grayScaleDown;
	colors[3] = 1.0;
	colors[4] = colors[5] = colors[6] = grayScaleUp;
	colors[7] = 1.0;
	storkeColor[0] = storkeColor[1] = storkeColor[2] = strokeGrayScale;
	storkeColor[3] = 1.0;
	points[0] = CGPointZero;
	points[1] = CGPointMake(0.0, b.size.height);
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, path);
	CGContextClip(ctx);
	SBDrawGradientInContext(ctx, count, locations, colors, points);
	CGContextRestoreGState(ctx);
	
	// Stroke
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, strokePath);
	CGContextSetLineWidth(ctx, 0.5);
	CGContextSetRGBStrokeColor(ctx, storkeColor[0], storkeColor[1], storkeColor[2], storkeColor[3]);
	CGContextStrokePath(ctx);
	CGContextRestoreGState(ctx);
	
	if (closable)
	{
		// Close button
		CGRect closableRect = [self closableRect];
		CGMutablePathRef xPath = CGPathCreateMutable();
		CGPoint p = CGPointZero;
		CGFloat across = closableRect.size.width;
		CGFloat length = 10.0;
		CGFloat margin = closableRect.origin.x;
		CGFloat lineWidth = 2;
		CGFloat center = margin + across / 2;
		CGFloat closeGrayScale = _dragInClose ? 0.2 : 0.4;
		CGAffineTransform t = CGAffineTransformIdentity;
		t = CGAffineTransformTranslate(t, center, center);
		t = CGAffineTransformRotate(t, -45 * M_PI / 180);
		p.x = -length / 2;
		CGPathMoveToPoint(xPath, &t, p.x, p.y);
		p.x = length / 2;
		CGPathAddLineToPoint(xPath, &t, p.x, p.y);
		p.x = 0;
		p.y = -length / 2;
		CGPathMoveToPoint(xPath, &t, p.x, p.y);
		p.y = length / 2;
		CGPathAddLineToPoint(xPath, &t, p.x, p.y);
		
		// Ellipse
		CGContextSaveGState(ctx);
		CGContextAddEllipseInRect(ctx, closableRect);
		CGContextSetLineWidth(ctx, lineWidth);
		CGContextSetRGBFillColor(ctx, closeGrayScale, closeGrayScale, closeGrayScale, 1.0);
		CGContextFillPath(ctx);
		CGContextRestoreGState(ctx);
		
		// Close
		CGContextSaveGState(ctx);
		CGContextAddPath(ctx, xPath);
		CGContextSetLineWidth(ctx, lineWidth);
		CGContextSetRGBStrokeColor(ctx, grayScaleUp, grayScaleUp, grayScaleUp, 1.0);
		CGContextStrokePath(ctx);
		CGContextRestoreGState(ctx);
		CGPathRelease(xPath);
		
		titleLeftMargin = across + margin * 2;
	}
	
	if ([title length] > 0)
	{
		// Title
		NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:0];
		NSSize size = NSZeroSize;
		NSRect r = NSZeroRect;
		CGFloat width = (b.size.width - titleLeftMargin - titleRightMargin);
		NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
		NSMutableParagraphStyle *paragraph = [[[NSMutableParagraphStyle alloc] init] autorelease];
		[shadow setShadowColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]];
		[shadow setShadowOffset:NSMakeSize(0, -0.5)];
		[shadow setShadowBlurRadius:0.5];
		[paragraph setLineBreakMode:NSLineBreakByTruncatingTail];
		[attributes setObject:[NSFont boldSystemFontOfSize:12.0] forKey:NSFontAttributeName];
		[attributes setObject:[NSColor colorWithCalibratedWhite:0.1 alpha:1.0] forKey:NSForegroundColorAttributeName];
		[attributes setObject:shadow forKey:NSShadowAttributeName];
		[attributes setObject:paragraph forKey:NSParagraphStyleAttributeName];
		size = [title sizeWithAttributes:attributes];
		r.size = size;
		if (size.width > width)
		{
			r.size.width = width;
		}
		r.origin.x = titleLeftMargin + (width - r.size.width) / 2;
		r.origin.y = (b.size.height - r.size.height) / 2;
		[title drawInRect:r withAttributes:attributes];
	}
}

@end
