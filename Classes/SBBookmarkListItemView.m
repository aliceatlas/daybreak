/*
 
 SBBookmarkListItemView.m
 
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

#import "SBBookmarkListItemView.h"
#import "SBBookmarkListView.h"
#import "SBBookmarks.h"
#import "SBRenderWindow.h"
#import "SBUtil.h"


@implementation SBBookmarkListItemView

@synthesize mode, item, selected, dragged;

+ (id)viewWithFrame:(NSRect)frame item:(NSDictionary *)item
{
	id view = [[[self alloc] initWithFrame:frame] autorelease];
	[(SBBookmarkListItemView *)view setItem:item];
	return view;
}

- (id)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		progressIndicator = nil;
		selected = NO;
		dragged = NO;
		area = [[NSTrackingArea alloc] initWithRect:self.bounds options:(NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved |NSTrackingActiveAlways | NSTrackingInVisibleRect) owner:self userInfo:nil];
		[self addTrackingArea:area];
	}
	return self;
}

- (void)dealloc
{
	[progressIndicator release];
	[item release];
	[area release];
	[super dealloc];
}

#pragma mark View

// Clicking through
- (NSView*)hitTest:(NSPoint)point
{
	NSView *view = [super hitTest:point];
	return (view == self) ? nil : view;
}

- (void)setNeedsDisplay:(BOOL)display
{
	[super setNeedsDisplay:display];
}

#pragma mark Getter

- (NSPoint)padding
{
	CGFloat padding = self.bounds.size.width * kSBBookmarkCellPaddingPercentage;
	return NSMakePoint(padding, padding);
}

- (CGFloat)heights
{
	return [self titleHeight] + [self bytesHeight];
}

- (CGFloat)titleHeight
{
	return 15.0;
}

- (CGFloat)bytesHeight
{
	return 12.0;
}

- (BOOL)visible
{
	return NSIntersectsRect([self.superview visibleRect], self.frame);
}

#pragma mark Rects

- (NSRect)imageRect
{
	NSRect r = NSZeroRect;
	NSPoint padding = [self padding];
	CGFloat titleHeight = [self titleHeight];
	CGFloat bytesHeight = [self bytesHeight];
	NSData *imageData = [item objectForKey:kSBBookmarkImage];
	NSImage *image = [[[NSImage alloc] initWithData:imageData] autorelease];
	NSSize imageSize = image ? [image size] : NSZeroSize;
	NSPoint p = NSZeroPoint;
	CGFloat s = 0;
	r = NSZeroRect;
	r.origin.x = padding.x;
	r.origin.y = bytesHeight + titleHeight + padding.y * 2;
	r.size.width = self.bounds.size.width - padding.x * 2;
	r.size.height = self.bounds.size.height - r.origin.y - padding.y;
	p.x = r.size.width / imageSize.width;
	p.y = r.size.height / imageSize.height;
	if (p.x > p.y)
	{
		s = imageSize.width * p.y;
		r.origin.x += (r.size.width - s) / 2;
		r.size.width = s;
	}
	else {
		s = imageSize.height * p.x;
		r.origin.y += (r.size.height - s) / 2;
		r.size.height = s;
	}
	return r;
}

- (NSRect)titleRect
{
	NSRect r = NSZeroRect;
	NSRect bounds = self.bounds;
	NSPoint padding = [self padding];
	CGFloat titleHeight = [self titleHeight];
	CGFloat bytesHeight = [self bytesHeight];
	CGFloat margin = titleHeight / 2;
	r = NSZeroRect;
	r.size.width = bounds.size.width - margin * 2;
	r.size.height = titleHeight;
	r.origin.x = margin;
	r.origin.y = padding.y + bytesHeight;
	return r;
}

- (NSRect)bytesRect
{
	NSRect r = NSZeroRect;
	NSRect bounds = self.bounds;
	NSPoint padding = [self padding];
	CGFloat bytesHeight = [self bytesHeight];
	r.size.width = bounds.size.width;
	r.size.height = bytesHeight;
	r.origin.y = padding.y;
	return r;
}

#pragma mark Setter

- (void)setSelected:(BOOL)isSelected
{
	//if (selected != isSelected)
	{
		selected = isSelected;
		[self setNeedsDisplay:YES];
	}
}

- (void)setDragged:(BOOL)isDragged
{
	if (dragged != isDragged)
	{
		dragged = isDragged;
		self.alphaValue = dragged ? 0.5 : 1.0;
	}
}

#pragma mark Actions

- (void)showProgress
{
	if (!progressIndicator)
	{
		NSRect r = NSZeroRect;
		NSPoint padding = [self padding];
		CGFloat titleHeight = [self titleHeight];
		CGFloat bytesHeight = [self bytesHeight];
		r.size.width = r.size.height = 32.0;
		r.origin.x = (self.bounds.size.width - r.size.width) / 2;
		r.origin.y = ((self.bounds.size.height - titleHeight - bytesHeight - padding.y) - r.size.height) / 2 + (titleHeight + bytesHeight + padding.y);
		progressIndicator = [[NSProgressIndicator alloc] initWithFrame:r];
		[progressIndicator setStyle:NSProgressIndicatorSpinningStyle];
		[progressIndicator setControlSize:NSRegularControlSize];
	}
	[progressIndicator startAnimation:nil];
	[self addSubview:progressIndicator];
}

- (void)hideProgress
{
	[progressIndicator stopAnimation:nil];
	[progressIndicator removeFromSuperview];
}

- (void)remove
{
	if (target)
	{
		if ([target respondsToSelector:@selector(removeItemView:)])
		{
			[target removeItemView:self];
		}
	}
}

- (void)edit
{
	if (target)
	{
		if ([target respondsToSelector:@selector(editItemView:)])
		{
			[target editItemView:self];
		}
	}
}

- (void)update
{
	NSString *urlString = [item objectForKey:kSBBookmarkURL];
	NSURL *url = urlString ? [NSURL URLWithString:urlString] : nil;
	if (url)
	{
		SBRenderWindow *window = nil;
		window = [SBRenderWindow startRenderingWithSize:NSMakeSize(800, 600) delegate:self url:url];
		[window retain];
	}
}

- (BOOL)hitToPoint:(NSPoint)point
{
	BOOL r = NO;
	if (mode == SBBookmarkIconMode)
	{
		r = NSPointInRect(point, [self imageRect]);
		if (!r) r = NSPointInRect(point, [self titleRect]);
		if (!r) r = NSPointInRect(point, [self bytesRect]);
	}
	else if (mode == SBBookmarkListMode)
	{
		r = NSPointInRect(point, self.bounds);
	}
	return r;
}

- (BOOL)hitToRect:(NSRect)rect
{
	BOOL r = NO;
	if (mode == SBBookmarkIconMode)
	{
		r = NSIntersectsRect(rect, [self imageRect]);
		if (!r) r = NSIntersectsRect(rect, [self titleRect]);
		if (!r) r = NSIntersectsRect(rect, [self bytesRect]);
	}
	else if (mode == SBBookmarkListMode)
	{
		r = NSIntersectsRect(rect, self.bounds);
	}
	return r;
}

#pragma mark Delegate

- (void)renderWindowDidStartRendering:(SBRenderWindow *)renderWindow
{
	[self showProgress];
}

- (void)renderWindow:(SBRenderWindow *)renderWindow didFinishRenderingImage:(NSImage *)image
{
	NSData *data = nil;
	if (image)
	{
		data = [[image bitmapImageRep] data];
	}
	if (data)
	{
		SBBookmarks *bookmarks = [SBBookmarks sharedBookmarks];
		NSMutableDictionary *mItem = [[item mutableCopy] autorelease];
		[mItem setObject:data forKey:kSBBookmarkImage];
		[bookmarks replaceItem:item withItem:[[mItem copy] autorelease]];
	}
	[self hideProgress];
	[renderWindow close];
}

- (void)renderWindow:(SBRenderWindow *)renderWindow didFailWithError:(NSError *)error
{
	[self hideProgress];
	[renderWindow close];
}

#pragma mark Event

- (void)mouseEntered:(NSEvent *)theEvent
{
	[(SBBookmarkListView *)self.superview layoutToolsForItem:self];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
	NSPoint location = [theEvent locationInWindow];
	NSPoint point = [self convertPoint:location fromView:nil];
	if (NSPointInRect(point, self.bounds))
	{
		[(SBBookmarkListView *)self.superview layoutToolsForItem:self];
	}
}

- (void)mouseExited:(NSEvent *)theEvent
{
	[(SBBookmarkListView *)self.superview layoutToolsHidden];
}

#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	if ([self visible])
	{
		CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
		NSRect bounds = self.bounds;
		NSRect r = NSZeroRect;
		NSData *imageData = [item objectForKey:kSBBookmarkImage];
		NSString *title = [item objectForKey:kSBBookmarkTitle];
		NSString *urlString = [item objectForKey:kSBBookmarkURL];
		NSString *labelColorName = [item objectForKey:kSBBookmarkLabelName];
		NSColor *labelColor = labelColorName ? [NSColor colorWithLabelColorName:labelColorName] : nil;
		NSPoint padding = [self padding];
		NSDictionary *attributes = nil;
		NSSize size = NSZeroSize;
		NSMutableParagraphStyle *paragraph = nil;
		BOOL iconed = NO;
		NSPoint transformScale = NSZeroPoint;
		
		if ([self.superview respondsToSelector:@selector(transformScale)])
			transformScale = [(SBBookmarkListView *)self.superview transformScale];
		if (NSEqualPoints(transformScale, NSZeroPoint))
			iconed = mode == SBBookmarkIconMode;
		else
			iconed = (transformScale.x / transformScale.y) > (bounds.size.width / bounds.size.height);
		
		if (iconed)
		{
			CGFloat titleHeight = [self titleHeight];
			
			// image
			if (imageData)
			{
				NSImage *image = [[NSImage alloc] initWithData:imageData];
				CGPathRef path = nil;
				CGColorRef shadowColor = nil;
				r = [self imageRect];
				
				// frame
				if ([[self window] firstResponder] == [self superview] && selected)
				{
					CGFloat components[4];
					CGRect fr = CGRectInset(NSRectToCGRect(r), -padding.x / 1.5, -padding.y / 1.5);
					path = SBRoundedPath(fr, 6.0, 0.0, YES, YES);
					SBGetAlternateSelectedControlColorComponents(components);
					CGContextSaveGState(ctx);
					CGContextAddPath(ctx, path);
					CGContextSetRGBFillColor(ctx, components[0], components[1], components[2], 0.25);
					CGContextFillPath(ctx);
					CGContextRestoreGState(ctx);
					
					CGContextSaveGState(ctx);
					CGContextAddPath(ctx, path);
					CGContextSetLineWidth(ctx, 1.5);
					CGContextSetRGBStrokeColor(ctx, components[0], components[1], components[2], components[3]);
					CGContextStrokePath(ctx);
					CGContextRestoreGState(ctx);
					CGPathRelease(path);
				}
				path = SBRoundedPath(NSRectToCGRect(r), 6.0, 0.0, YES, YES);
				shadowColor = CGColorCreateGenericGray(0.0, 0.6);
				CGContextSaveGState(ctx);
				CGContextAddPath(ctx, path);
				CGContextSetShadowWithColor(ctx, CGSizeMake(0, -2.0), 5.0, shadowColor);
				CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 1.0);
				CGContextFillPath(ctx);
				CGContextRestoreGState(ctx);
				CGColorRelease(shadowColor);
				
				CGContextSaveGState(ctx);
				CGContextAddPath(ctx, path);
				CGContextClip(ctx);
				[image drawInRect:r fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
				[image release];
				CGContextRestoreGState(ctx);
				CGPathRelease(path);
			}
			// title string
			if (title)
			{
				NSShadow *shadow = nil;
				CGFloat margin = titleHeight / 2;
				
				r = [self titleRect];
				
				if (labelColor)
				{
					// Label color
					CGRect sr = NSRectToCGRect(r);
					CGFloat components[4];
					CGPathRef path = nil;
					CGFloat tmargin = margin - 1.0;
					[labelColor getComponents:components];
					sr.origin.x -= tmargin;
					sr.size.width += tmargin * 2;
					CGRectInset(sr, 2.0, 2.0);
					path = SBRoundedPath(sr, sr.size.height / 2, 0.0, YES, YES);
					CGContextSaveGState(ctx);
					CGContextAddPath(ctx, path);
					CGContextSetRGBFillColor(ctx, components[0], components[1], components[2], components[3]);
					CGContextFillPath(ctx);
					CGContextRestoreGState(ctx);
					CGPathRelease(path);
				}
				
				if (selected)
				{
					// Background
					CGRect sr = NSRectToCGRect(r);
					CGFloat components[4];
					CGPathRef path = nil;
					CGFloat tmargin = margin - 1.0;
					if ([[self window] firstResponder] == [self superview])
					{
						SBGetAlternateSelectedControlColorComponents(components);
					}
					else {
						components[0] = components[1] = components[2] = 0.8;
						components[3] = 1.0;
					}
					sr.origin.x -= tmargin;
					sr.size.width += tmargin * 2;
					if (labelColor)
					{
						sr = CGRectInset(sr, 2.0, 2.0);
					}
					path = SBRoundedPath(sr, sr.size.height / 2, 0.0, YES, YES);
					CGContextSaveGState(ctx);
					CGContextAddPath(ctx, path);
					CGContextSetRGBFillColor(ctx, components[0], components[1], components[2], components[3]);
					CGContextFillPath(ctx);
					CGContextRestoreGState(ctx);
					CGPathRelease(path);
				}
				if (labelColor && ! selected)
				{
					shadow = [[NSShadow alloc] init];
					[shadow setShadowOffset:NSMakeSize(0.0, -1.0)];
					[shadow setShadowBlurRadius:2.0];
					[shadow setShadowColor:[NSColor blackColor]];
				}
				paragraph = [[NSMutableParagraphStyle alloc] init];
				[paragraph setAlignment:NSCenterTextAlignment];
				attributes = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSFont boldSystemFontOfSize:10.0], NSFontAttributeName, 
							  [NSColor whiteColor], NSForegroundColorAttributeName, 
							  paragraph, NSParagraphStyleAttributeName, 
							  shadow, NSShadowAttributeName, nil];
				[paragraph release];
				[shadow release];
				size = [title sizeWithAttributes:attributes];
				r.origin.y += (r.size.height - size.height) / 2;
				r.size.height = size.height;
				[title drawInRect:r withAttributes:attributes];
			}
			// url string
			if (urlString)
			{
				r = [self bytesRect];
				paragraph = [[NSMutableParagraphStyle alloc] init];
				[paragraph setAlignment:NSCenterTextAlignment];
				attributes = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSFont systemFontOfSize:9.0], NSFontAttributeName, 
							  [NSColor lightGrayColor], NSForegroundColorAttributeName, 
							  paragraph, NSParagraphStyleAttributeName, nil];
				[paragraph release];
				size = [urlString sizeWithAttributes:attributes];
				r.origin.y += (r.size.height - size.height) / 2;
				r.size.height = size.height;
				[urlString drawInRect:r withAttributes:attributes];
			}
		}
		else
		{
			NSRect imageRect = NSZeroRect;
			NSRect titleRect = NSZeroRect;
			NSRect urlRect = NSZeroRect;
			
			// Rects
			imageRect = NSMakeRect(0, 0, 60, bounds.size.height);
			titleRect = NSMakeRect((NSMaxX(imageRect) + padding.x), 0, (bounds.size.width - (NSMaxX(imageRect) + padding.x)) * 0.5, bounds.size.height);
			urlRect = NSMakeRect((NSMaxX(titleRect) + padding.x), 0, (bounds.size.width - (NSMaxX(titleRect) + padding.x)), bounds.size.height);
			
			// line
			[[NSColor darkGrayColor] set];
			NSRectFill(NSMakeRect(bounds.origin.x, NSMaxY(bounds) - 1.0, bounds.size.width, 1.0));
			
			// image
			if (imageData)
			{
				
			}
			// title string
			if (title)
			{
				CGFloat margin = bounds.size.height / 2;
				NSShadow *shadow = nil;
				r = self.bounds;
				if (labelColor)
				{
					// Label color
					CGRect sr = NSRectToCGRect(r);
					CGFloat components[4];
					CGPathRef path = nil;
					CGFloat tmargin = margin - 1.0;
					[labelColor getComponents:components];
					sr.origin.x -= tmargin;
					sr.size.width += tmargin * 2;
					CGRectInset(sr, 2.0, 2.0);
					path = SBRoundedPath(sr, sr.size.height / 2, 0.0, YES, YES);
					CGContextSaveGState(ctx);
					CGContextAddPath(ctx, path);
					CGContextSetRGBFillColor(ctx, components[0], components[1], components[2], components[3]);
					CGContextFillPath(ctx);
					CGContextRestoreGState(ctx);
					CGPathRelease(path);
				}
				if (selected)
				{
					// Background
					CGRect sr = NSRectToCGRect(r);
					CGFloat components[4];
					CGMutablePathRef path = nil;
					CGFloat tmargin = margin - 1.0;
					NSUInteger count = 2;
					CGFloat locations[count];
					CGFloat colors[count * 4];
					CGPoint points[count];
					if ([[self window] firstResponder] == [self superview])
					{
						SBGetAlternateSelectedControlColorComponents(components);
					}
					else {
						components[0] = components[1] = components[2] = 0.8;
						components[3] = 1.0;
					}
					sr.origin.x -= tmargin;
					sr.size.width += tmargin * 2;
					if (labelColor)
					{
						sr = CGRectInset(sr, 2.0, 2.0);
					}
					locations[0] = 0.0;
					locations[1] = 1.0;
					colors[0] = components[0] - 0.2;
					colors[1] = components[1] - 0.2;
					colors[2] = components[2] - 0.2;
					colors[3] = components[3];
					colors[4] = components[0];
					colors[5] = components[1];
					colors[6] = components[2];
					colors[7] = components[3];
					points[0] = CGPointZero;
					points[1] = CGPointMake(0.0, sr.size.height);
					CGContextSaveGState(ctx);
					path = CGPathCreateMutable();
					CGPathAddRect(path, nil, sr);
					CGContextAddPath(ctx, path);
					CGContextClip(ctx);
					SBDrawGradientInContext(ctx, count, locations, colors, points);
					CGContextRestoreGState(ctx);
					CGPathRelease(path);
				}
				if (labelColor && ! selected)
				{
					shadow = [[NSShadow alloc] init];
					[shadow setShadowOffset:NSMakeSize(0.0, -1.0)];
					[shadow setShadowBlurRadius:2.0];
					[shadow setShadowColor:[NSColor blackColor]];
				}
				paragraph = [[NSMutableParagraphStyle alloc] init];
				[paragraph setLineBreakMode:NSLineBreakByTruncatingTail];
				[paragraph setAlignment:NSLeftTextAlignment];
				attributes = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSFont boldSystemFontOfSize:11.0], NSFontAttributeName, 
							  [NSColor whiteColor], NSForegroundColorAttributeName, 
							  paragraph, NSParagraphStyleAttributeName, 
							  shadow, NSShadowAttributeName, nil];
				[paragraph release];
				[shadow release];
				size = [title sizeWithAttributes:attributes];
				titleRect.origin.y += (titleRect.size.height - size.height) / 2;
				titleRect.size.height = size.height;
				[title drawInRect:titleRect withAttributes:attributes];
			}
			// url string
			if (urlString)
			{
				NSColor *color = nil;
				color = selected ? [NSColor whiteColor] : (labelColor ? [NSColor blackColor] : [NSColor lightGrayColor]);
				paragraph = [[NSMutableParagraphStyle alloc] init];
				[paragraph setLineBreakMode:NSLineBreakByTruncatingTail];
				[paragraph setAlignment:NSLeftTextAlignment];
				attributes = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSFont systemFontOfSize:11.0], NSFontAttributeName, 
							  color, NSForegroundColorAttributeName, 
							  paragraph, NSParagraphStyleAttributeName, nil];
				[paragraph release];
				size = [urlString sizeWithAttributes:attributes];
				urlRect.origin.y += (urlRect.size.height - size.height) / 2;
				urlRect.size.height = size.height;
				[urlString drawInRect:urlRect withAttributes:attributes];
			}
			[[NSColor darkGrayColor] set];
			NSFrameRect(bounds);
		}
	}
}

@end
