/*

SBBLKGUIPopUpButton.m
 
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

#import "SBBLKGUIPopUpButton.h"


@implementation SBBLKGUIPopUpButton

+ (void)initialize
{
	if (self == [SBBLKGUIPopUpButtonCell class])
	{
		[self setCellClass:[SBBLKGUIPopUpButtonCell class]];
	}
}

+ (Class)cellClass
{
	return [SBBLKGUIPopUpButtonCell class];
}

@end

@implementation SBBLKGUIPopUpButtonCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSImage *image = nil;
	NSAttributedString *attributedTitle = nil;
	NSImage *leftImage = nil;
	NSImage *centerImage = nil;
	NSImage *rightImage = nil;
	
	image = [[(NSPopUpButton *)controlView selectedItem] image];
	attributedTitle = [[[NSAttributedString alloc] initWithString:[(NSPopUpButton *)controlView titleOfSelectedItem]] autorelease];
	
	if ([self isBordered])
	{
		NSRect drawRect = NSZeroRect;
		float fraction = 0;
		
		fraction = ([self isEnabled] ? 1.0 : 0.5);
		
		leftImage = [NSImage imageNamed:([self isHighlighted] ? @"BLKGUI_PopUp-Highlighted-Left.png" : @"BLKGUI_PopUp-Left.png")];
		centerImage = [NSImage imageNamed:([self isHighlighted] ? @"BLKGUI_PopUp-Highlighted-Center.png" : @"BLKGUI_PopUp-Center.png")];
		rightImage = [NSImage imageNamed:([self isHighlighted] ? @"BLKGUI_PopUp-Highlighted-Right.png" : @"BLKGUI_PopUp-Right.png")];
		
		// Left
		drawRect.origin = cellFrame.origin;
		drawRect.size = [leftImage size];
		drawRect.origin.y = (cellFrame.size.height - drawRect.size.height) / 2;
		[leftImage drawInRect:drawRect operation:NSCompositeSourceOver fraction:fraction respectFlipped:[controlView isFlipped]];
		
		// Center
		drawRect.origin.x = [leftImage size].width;
		drawRect.size.width = cellFrame.size.width - ([leftImage size].width + [rightImage size].width);
		drawRect.origin.y = (cellFrame.size.height - drawRect.size.height) / 2;
		[centerImage drawInRect:drawRect operation:NSCompositeSourceOver fraction:fraction respectFlipped:[controlView isFlipped]];
		
		// Right
		drawRect.size = [rightImage size];
		drawRect.origin.x = cellFrame.size.width - drawRect.size.width;
		drawRect.origin.y = (cellFrame.size.height - drawRect.size.height) / 2;
		[rightImage drawInRect:drawRect operation:NSCompositeSourceOver fraction:fraction respectFlipped:[controlView isFlipped]];
	}
	
	if (image)
	{
		CGContextRef ctx = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
		NSRect imageRect = NSZeroRect;
		imageRect.size = [image size];
		imageRect.origin.x = cellFrame.origin.x + 5.0;
		imageRect.origin.y = cellFrame.origin.y + ((cellFrame.size.height - imageRect.size.height) / 2);
		CGContextSaveGState(ctx);
		CGContextTranslateCTM(ctx, 0.0, cellFrame.size.height);
		CGContextScaleCTM(ctx, 1.0, -1.0);
		[image drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
		CGContextRestoreGState(ctx);
	}
	
	if ([attributedTitle length] > 0)
	{
		NSRect titleRect = NSZeroRect;
		NSMutableAttributedString *mutableTitle = nil;
		NSRange range;
		NSMutableParagraphStyle *style = nil;
		NSFont *font = nil;
		NSColor *foregroundColor = nil;
		
		mutableTitle = [[[NSMutableAttributedString alloc] initWithAttributedString:attributedTitle] autorelease];
		range = NSMakeRange(0,[attributedTitle length]);
		style = [[[NSMutableParagraphStyle alloc] init] autorelease];
		font = [NSFont fontWithName:[[self font] fontName] size:[NSFont systemFontSizeForControlSize:[self controlSize]]];
		foregroundColor = ([self isEnabled] ? [self isHighlighted] ? [NSColor lightGrayColor] : [NSColor whiteColor] : [NSColor grayColor]);
		
		[style setAlignment:NSCenterTextAlignment];
		[style setLineBreakMode:NSLineBreakByTruncatingTail];
		[mutableTitle beginEditing];
		[mutableTitle addAttribute:NSForegroundColorAttributeName value:foregroundColor range:range];
		[mutableTitle addAttribute:NSFontAttributeName value:font range:range];
		[mutableTitle addAttribute:NSParagraphStyleAttributeName value:style range:range];
		[mutableTitle endEditing];
		
		titleRect.size.width = [mutableTitle size].width;
		titleRect.size.height = [mutableTitle size].height;
		titleRect.origin.x = cellFrame.origin.x + (leftImage ? [leftImage size].width : 0.0) + 5.0 + (image ? [image size].width + 5.0 : 0);
		titleRect.origin.y = cellFrame.origin.y + ((cellFrame.size.height - titleRect.size.height) / 2) - 2;
		[mutableTitle drawInRect:titleRect];
	}
}

@end