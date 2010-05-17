/*

NSImage-SBAdditions.m
 
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

#import "NSImage-SBAdditions.h"


@implementation NSImage (SBAdditions)

+ (NSImage *)imageWithView:(NSView *)view
{
	NSImage *image = nil;
	NSBitmapImageRep *bitmapImageRep = nil;
	bitmapImageRep = [view bitmapImageRepForCachingDisplayInRect:view.bounds];
	if ([view respondsToSelector:@selector(layout)])
	{
		[(id)view layout];
	}
	if (bitmapImageRep)
	{
		[view cacheDisplayInRect:view.bounds toBitmapImageRep:bitmapImageRep];
		image = [[[NSImage alloc] initWithSize:view.bounds.size] autorelease];
		[image addRepresentation:bitmapImageRep];
	}
	return image;
}

- (NSImage *)stretchableImageWithSize:(NSSize)size sideCapWidth:(NSInteger)sideCapWidth
{
	NSImage *image = nil;
	NSSize imageSize = NSZeroSize;
	NSPoint leftPoint = NSZeroPoint;
	NSPoint rightPoint = NSZeroPoint;
	NSRect fillRect = NSZeroRect;
	image = [[[NSImage alloc] initWithSize:size] autorelease];
	[image lockFocus];
	imageSize = [self size];
	rightPoint = NSMakePoint(size.width - imageSize.width,0);
	fillRect = NSMakeRect(sideCapWidth, 0, size.width - sideCapWidth * 2, size.height);
	[self drawAtPoint:leftPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	[self drawAtPoint:rightPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	[self drawInRect:fillRect fromRect:NSMakeRect(sideCapWidth, 0, imageSize.width - sideCapWidth * 2, imageSize.height) operation:NSCompositeSourceOver fraction:1.0];
	[image unlockFocus];
	return image;
}

- (NSImage *)insetWithSize:(NSSize)size intersectRect:(NSRect)intersectRect offset:(NSPoint)offset
{
	NSImage *image = nil;
	if (self)
	{
		NSSize imageSize = [self size];
		NSRect inRect = NSEqualRects(intersectRect, NSZeroRect) ? NSMakeRect(0, 0, imageSize.width, imageSize.height) : intersectRect;
		NSAffineTransform *transform = nil;
		NSPoint translate = NSZeroPoint;
		NSPoint flippedPoint = NSZeroPoint;
		NSSize resizedSize = NSZeroSize;
		NSSize perSize = NSZeroSize;
		NSSize offsetSize = NSZeroSize;
		CGFloat per = 0;
		
		transform = [NSAffineTransform transform];
		image = [[[NSImage alloc] initWithSize:size] autorelease];
		
		perSize.width = inRect.size.width / 4;
		perSize.height = inRect.size.height / 3;
		resizedSize = inRect.size;
		if (perSize.width > perSize.height)
		{
			resizedSize.width = (inRect.size.height / 3) * 4;
			per = size.height / inRect.size.height;
		}
		else {
			resizedSize.height = (inRect.size.width / 4) * 3;
			per = size.width / inRect.size.width;
		}
		flippedPoint.x = inRect.origin.x;
		flippedPoint.y = ((imageSize.height - inRect.size.height) - inRect.origin.y);
		translate.x = - flippedPoint.x;
		translate.y = - (flippedPoint.y + (inRect.size.height - resizedSize.height));
		offsetSize.width = [self size].width * offset.x;
		offsetSize.height = [self size].height * offset.y;
		translate.x -= offsetSize.width;
		translate.y += offsetSize.height;
		
		// Draw in image
		[image lockFocus];
		[transform scaleBy:per];
		[transform translateXBy:translate.x yBy:translate.y];
		[transform concat];
		[self drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
		[image unlockFocus];
	}
	return image;
}

+ (NSImage *)colorImage:(NSSize)size colorName:(NSString *)colorName
{
	NSImage *image = [[[NSImage alloc] initWithSize:size] autorelease];
	NSColor *color = [NSColor colorWithLabelColorName:colorName];
	[image lockFocus];
	if (color)
	{
		[color set];
		NSRectFill(NSMakeRect(0, 0, size.width, size.height));
	}
	else {
		[[NSColor grayColor] set];
		NSFrameRect(NSMakeRect(0, 0, size.width, size.height));
	}
	[image unlockFocus];
	return image;
}

+ (NSImage *)imageWithCGImage:(CGImageRef)srcImage
{
	NSImage *image = nil;
	if (srcImage)
	{
		NSBitmapImageRep *bitmapImageRep = [[NSBitmapImageRep alloc] initWithCGImage:srcImage];
		image = [[[NSImage alloc] init] autorelease];
		[image addRepresentation:bitmapImageRep];
		[bitmapImageRep release];
	}
	return image;
}

- (CGImageRef)CGImage
{
	CGImageRef image = nil;
	if (self)
	{
		NSBitmapImageRep *bitmapImageRep = [self bitmapImageRep];
		image = [bitmapImageRep CGImage];
	}
	return image;
}

- (NSBitmapImageRep *)bitmapImageRep
{
	id imageRep = nil;
	imageRep = [self bestRepresentationForDevice:nil];
	if ([imageRep isKindOfClass:[NSBitmapImageRep class]])
	{
		
	}
	else {
		imageRep = [NSBitmapImageRep imageRepWithData:[self TIFFRepresentation]];
	}
	return (NSBitmapImageRep *)imageRep;
}

- (void)drawInRect:(NSRect)rect operation:(NSCompositingOperation)op fraction:(CGFloat)requestedAlpha respectFlipped:(BOOL)respectContextIsFlipped
{
	BOOL isFlipped = [self isFlipped];
	if (isFlipped != respectContextIsFlipped)
	{
		// Set flipped peroperty
		[self setFlipped:respectContextIsFlipped];
	}
	[self drawInRect:rect fromRect:NSZeroRect operation:op fraction:requestedAlpha];
	if (isFlipped != respectContextIsFlipped)
	{
		// Restore flipped peroperty
		[self setFlipped:isFlipped];
	}
}

@end
