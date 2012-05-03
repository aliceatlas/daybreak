/*
 
 SBTableCell.m
 
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

#import "SBTableCell.h"
#import "SBUtil.h"


@implementation SBTableCell

@synthesize enabled;
@synthesize style;
@synthesize showRoundedPath;
@synthesize showSelection;
@synthesize lineBreakMode;

- (id)init
{
	if (self = [super init])
	{
		enabled = YES;
		style = SBTableCellGrayStyle;
		showSelection = YES;
		lineBreakMode = NSLineBreakByTruncatingTail;
	}
	return self;
}

- (CGFloat)side
{
	return 5.0;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[self drawInteriorWithFrame:cellFrame inView:controlView];
	[self drawTitleWithFrame:cellFrame inView:controlView];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	CGFloat backgroundColors[4];
	CGFloat cellColors[4];
	CGFloat selectedCellColors[4];
	if (style == SBTableCellGrayStyle)
	{
		memcpy(backgroundColors, SBBackgroundColors, sizeof(SBBackgroundColors));
		memcpy(cellColors, SBTableCellColors, sizeof(SBTableCellColors));
		memcpy(selectedCellColors, SBSidebarSelectedCellColors, sizeof(SBSidebarSelectedCellColors));
	}
	else if (style == SBTableCellWhiteStyle)
	{
		NSColor *selectedColor = [[NSColor alternateSelectedControlColor] colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
		memcpy(backgroundColors, SBBackgroundLightGrayColors, sizeof(SBBackgroundLightGrayColors));
		memcpy(cellColors, SBTableLightGrayCellColors, sizeof(SBTableLightGrayCellColors));
		[selectedColor getComponents:selectedCellColors];
	}
	else
	{
		return;
	}
	if (style == SBTableCellGrayStyle || style == SBTableCellWhiteStyle)
	{
		[[NSColor colorWithCalibratedRed:backgroundColors[0] green:backgroundColors[1] blue:backgroundColors[2] alpha:backgroundColors[3]] set];
		NSRectFill(cellFrame);
	}
	if (showRoundedPath)
	{
		[[NSColor colorWithCalibratedRed:cellColors[0] green:cellColors[1] blue:cellColors[2] alpha:cellColors[3]] set];
		NSRectFill(NSInsetRect(cellFrame, 0.0, 0.5));
		if ([self isHighlighted] && showSelection)
		{
			CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
			CGRect r = CGRectZero;
			CGPathRef path = nil;
			r = NSRectToCGRect(cellFrame);
			path = SBRoundedPath(CGRectInset(r, 1.0, 0.5), (cellFrame.size.height - 0.5 * 2) / 2, 0.0, YES, YES);
			CGContextSaveGState(ctx);
			CGContextAddPath(ctx, path);
			CGContextSetRGBFillColor(ctx, selectedCellColors[0], selectedCellColors[1], selectedCellColors[2], selectedCellColors[3]);
			CGContextFillPath(ctx);
			CGContextRestoreGState(ctx);
		}
	}
	else {
		if ([self isHighlighted] && showSelection)
			[[NSColor colorWithCalibratedRed:selectedCellColors[0] green:selectedCellColors[1] blue:selectedCellColors[2] alpha:selectedCellColors[3]] set];
		else
			[[NSColor colorWithCalibratedRed:cellColors[0] green:cellColors[1] blue:cellColors[2] alpha:cellColors[3]] set];
		NSRectFill(NSInsetRect(cellFrame, 0.0, 0.5));
	}
}

- (void)drawTitleWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSString *title = nil;
	CGFloat textColors[4];
	NSColor *sTextColor = nil;
	
	title = [self title];
	if (style == SBTableCellGrayStyle)
	{
		memcpy(textColors, SBSidebarTextColors, sizeof(SBSidebarTextColors));
		sTextColor = [NSColor blackColor];
	}
	else if (style == SBTableCellWhiteStyle)
	{
		NSColor *textColor = [(enabled ? [NSColor blackColor] : [NSColor grayColor]) colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
		[textColor getComponents:textColors];
		sTextColor = [self isHighlighted] ? [NSColor clearColor] : [NSColor whiteColor];
	}
	
	if ([title length] > 0 && (style == SBTableCellGrayStyle || style == SBTableCellWhiteStyle))
	{
		NSSize size = NSZeroSize;
		NSColor *color = nil;
		NSFont *font = nil;
		NSDictionary *attribute = nil;
		NSDictionary *sattribute = nil;
		NSRect r = NSZeroRect;
		NSRect sr = NSZeroRect;
		NSMutableParagraphStyle *paragraphStyle = nil;
		CGFloat side = [self side] + (cellFrame.size.height - 0.5 * 2) / 2;
		
		color = [self isHighlighted] ? [NSColor whiteColor] : [NSColor colorWithCalibratedRed:textColors[0] green:textColors[1] blue:textColors[2] alpha:textColors[3]];
		font = [self font];
		paragraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
		[paragraphStyle setLineBreakMode:lineBreakMode];
		attribute = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, color, NSForegroundColorAttributeName, paragraphStyle, NSParagraphStyleAttributeName, nil];
		sattribute = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, sTextColor, NSForegroundColorAttributeName, paragraphStyle, NSParagraphStyleAttributeName, nil];
		size = [title sizeWithAttributes:attribute];
		if (size.width > (cellFrame.size.width - side * 2))
			size.width = cellFrame.size.width - side * 2;
		r.size = size;
		if ([self alignment] == NSLeftTextAlignment)
		{
			r.origin.x = cellFrame.origin.x + side;
		}
		else if ([self alignment] == NSRightTextAlignment)
		{
			r.origin.x = cellFrame.origin.x + side + ((cellFrame.size.width - side * 2) - size.width);
		}
		else if ([self alignment] == NSCenterTextAlignment)
		{
			r.origin.x = cellFrame.origin.x + ((cellFrame.size.width - side * 2) - size.width) / 2;
		}
		r.origin.y = cellFrame.origin.y + (cellFrame.size.height - r.size.height) / 2;
		sr = r;
		if (style == SBTableCellGrayStyle)
		{
			sr.origin.y -= 1.0;
		}
		else if (style == SBTableCellWhiteStyle)
		{
			sr.origin.y += 1.0;
		}
		[title drawInRect:sr withAttributes:sattribute];
		[title drawInRect:r withAttributes:attribute];
	}
}

@end

@implementation SBIconDataCell

@synthesize drawsBackground;

- (id)init
{
	if (self = [super init])
	{
		drawsBackground = YES;
	}
	return self;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[self drawInteriorWithFrame:cellFrame inView:controlView];
	[self drawImageWithFrame:cellFrame inView:controlView];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	if (drawsBackground)
	{
		[[NSColor colorWithCalibratedRed:SBBackgroundLightGrayColors[0] green:SBBackgroundLightGrayColors[1] blue:SBBackgroundLightGrayColors[2] alpha:SBBackgroundLightGrayColors[3]] set];
		NSRectFill(cellFrame);
		[[NSColor colorWithCalibratedRed:SBTableLightGrayCellColors[0] green:SBTableLightGrayCellColors[1] blue:SBTableLightGrayCellColors[2] alpha:SBTableLightGrayCellColors[3]] set];
		NSRectFill(NSInsetRect(cellFrame, 0.0, 0.5));
	}
}

- (void)drawImageWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSImage *image = [self image];
	if (image)
	{
		NSRect r = NSZeroRect;
		r.size = [image size];
		r.origin.x = cellFrame.origin.x + (cellFrame.size.width - r.size.width) / 2;
		r.origin.y = cellFrame.origin.y + (cellFrame.size.height - r.size.height) / 2;
		[image drawInRect:r operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES];
	}
}

@end