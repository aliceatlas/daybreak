/*

SBBLKGUIButton.m
 
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

#import "SBBLKGUIButton.h"


@implementation SBBLKGUIButton

+ (void)initialize
{
	if (self == [SBBLKGUIButton class])
	{
		[self setCellClass:[SBBLKGUIButtonCell class]];
	}
}

+ (Class)cellClass
{
	return [SBBLKGUIButtonCell class];
}

- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	
	if (self)
	{
		[self setButtonType:NSMomentaryChangeButton];
		[self setBezelStyle:NSRoundedBezelStyle];
	}
	
	return self;
}

- (NSButtonType)buttonType
{
	return [[self cell] buttonType];
}

- (BOOL)isSelected
{
	return [[self cell] isSelected];
}

- (void)setButtonType:(NSButtonType)buttonType
{
	[[self cell] setButtonType:buttonType];
}

- (void)setSelected:(BOOL)isSelected
{
	[[self cell] setSelected:isSelected];
}

@end

@implementation SBBLKGUIButtonCell

- (void)setButtonType:(NSButtonType)buttonType
{
	_buttonType = buttonType;
	[super setButtonType:_buttonType];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSImage *image = nil;
	BOOL isDone = [controlView respondsToSelector:@selector(keyEquivalent)] ? [[(NSButton *)controlView keyEquivalent] isEqualToString:@"\r"] : NO;
	//if (NSEqualRects(cellFrame, [controlView bounds]))
	{
		NSImage *leftImage = nil;
		NSImage *centerImage = nil;
		NSImage *rightImage = nil;
		NSRect r = NSZeroRect;
		CGFloat offset = 0;
		if (_buttonType == NSSwitchButton)
		{
			NSRect imageRect = NSZeroRect;
			
			if ([self state] == NSOnState)
			{
				image = [NSImage imageNamed:([self isHighlighted] ? @"BLKGUI_CheckBox-Selected-Highlighted.png" : @"BLKGUI_CheckBox-Selected.png")];
			}
			else {
				image = [NSImage imageNamed:([self isHighlighted] ? @"BLKGUI_CheckBox-Highlighted.png" : @"BLKGUI_CheckBox.png")];
			}
			
			imageRect.size = [image size];
			r.size = imageRect.size;
			r.origin.y = cellFrame.origin.y + (cellFrame.size.height - r.size.height) / 2;
			[image drawInRect:r operation:NSCompositeSourceOver fraction:([self isEnabled] ? 1.0 : 0.5) respectFlipped:[controlView isFlipped]];
		}
		else if (_buttonType == NSRadioButton)
		{
			NSRect imageRect = NSZeroRect;
			
			if ([self state] == NSOnState)
			{
				image = [NSImage imageNamed:([self isHighlighted] ? @"BLKGUI_Radio-Selected-Highlighted.png" : @"BLKGUI_Radio-Selected.png")];
			}
			else {
				image = [NSImage imageNamed:([self isHighlighted] ? @"BLKGUI_Radio-Highlighted.png" : @"BLKGUI_Radio.png")];
			}
			
			imageRect.size = (image ? [image size] : NSZeroSize);
			r.size = imageRect.size;
			r.origin.x = cellFrame.origin.x;
			r.origin.y = cellFrame.origin.y + (cellFrame.size.height - r.size.height) / 2;
			[image drawInRect:r operation:NSCompositeSourceOver fraction:([self isEnabled] ? 1.0 : 0.5) respectFlipped:[controlView isFlipped]];
		}
		else {
			if (isDone)
			{
				if ([self isHighlighted])
				{
					leftImage = [NSImage imageNamed:@"BLKGUI_Button-Active-Highlighted-Left.png"];
					centerImage = [NSImage imageNamed:@"BLKGUI_Button-Active-Highlighted-Center.png"];
					rightImage = [NSImage imageNamed:@"BLKGUI_Button-Active-Highlighted-Right.png"];
				}
				else {
					leftImage = [NSImage imageNamed:@"BLKGUI_Button-Active-Left.png"];
					centerImage = [NSImage imageNamed:@"BLKGUI_Button-Active-Center.png"];
					rightImage = [NSImage imageNamed:@"BLKGUI_Button-Active-Right.png"];
				}
			}
			else {
				if ([self isHighlighted])
				{
					leftImage = [NSImage imageNamed:@"BLKGUI_Button-Highlighted-Left.png"];
					centerImage = [NSImage imageNamed:@"BLKGUI_Button-Highlighted-Center.png"];
					rightImage = [NSImage imageNamed:@"BLKGUI_Button-Highlighted-Right.png"];
				}
				else {
					leftImage = [NSImage imageNamed:@"BLKGUI_Button-Left.png"];
					centerImage = [NSImage imageNamed:@"BLKGUI_Button-Center.png"];
					rightImage = [NSImage imageNamed:@"BLKGUI_Button-Right.png"];
				}
			}
			
			if (leftImage)
			{
				r.size = [leftImage size];
				r.origin.y = (cellFrame.size.height - r.size.height) / 2;
				[leftImage drawInRect:r operation:NSCompositeSourceOver fraction:([self isEnabled] ? 1.0 : 0.5) respectFlipped:[controlView isFlipped]];
				offset = NSMaxX(r);
			}
			if (centerImage)
			{
				r.origin.x = leftImage ? [leftImage size].width : 0.0;
				r.size.width = cellFrame.size.width - (leftImage ? [leftImage size].width : 0 + rightImage ? [rightImage size].width : 0);
				r.size.height = [centerImage size].height;
				r.origin.y = (cellFrame.size.height - r.size.height) / 2;
				[centerImage drawInRect:r operation:NSCompositeSourceOver fraction:([self isEnabled] ? 1.0 : 0.5) respectFlipped:[controlView isFlipped]];
				offset = NSMaxX(r);
			}
			if (rightImage)
			{
				r.origin.x = offset;
				r.size = [rightImage size];
				r.origin.y = (cellFrame.size.height - r.size.height) / 2;
				[rightImage drawInRect:r operation:NSCompositeSourceOver fraction:([self isEnabled] ? 1.0 : 0.5) respectFlipped:[controlView isFlipped]];
			}
		}
	}
	
	if ([self title] > 0)
	{
		NSDictionary *attributes = nil;
		NSString *title = [self title];
		NSSize size = NSZeroSize;
		float frameMargin = 2.0;
		NSFont *font = [self font];
		NSRect frame = NSMakeRect(cellFrame.origin.x + frameMargin, cellFrame.origin.y, cellFrame.size.width - frameMargin * 2, cellFrame.size.height);
		NSRect r = frame;
		NSColor *foregroundColor = nil;
		if (_buttonType == NSSwitchButton || _buttonType == NSRadioButton)
		{
			foregroundColor = [self isEnabled] ? [NSColor whiteColor] : [NSColor grayColor];
		}
		else {
			foregroundColor = [self isEnabled] ? ([self isHighlighted] ? [NSColor grayColor] : [NSColor whiteColor]) : (isDone ? [NSColor grayColor] : [NSColor darkGrayColor]);
		}
		attributes = [NSDictionary dictionaryWithObjectsAndKeys:
					  font, NSFontAttributeName, 
					  foregroundColor, NSForegroundColorAttributeName, 
					  nil];
		if (_buttonType == NSSwitchButton || _buttonType == NSRadioButton)
		{
			int i = 0, l = 0, h = 1;
			size.width = frame.size.width - (image ? ([image size].width + 2) : 2);
			size.height = [font pointSize] + 2.0;
			for (i = 1; i <= [title length]; i++)
			{
				NSString *t = [title substringWithRange:NSMakeRange(l, i - l)];
				NSSize s = [t sizeWithAttributes:attributes];
				if (size.width <= s.width)
				{
					l = i;
					h++;
				}
			}
			size.height = size.height * h;
		}
		else {
			size = [title sizeWithAttributes:attributes];
		}
		r.size = size;
		if (_buttonType == NSSwitchButton || _buttonType == NSRadioButton)
		{
			r.origin.y = frame.origin.y + (cellFrame.size.height - r.size.height) / 2;
			r.origin.x = frame.origin.x + (image ? ([image size].width + 3) : 3);
		}
		else {
			r.origin.x = (frame.size.width - r.size.width) / 2;
			r.origin.y = (frame.size.height - r.size.height) / 2;
			r.origin.y -= 2.0;
			if ([self image])
			{
				NSImage *image = [self image];
				NSRect imageRect = NSZeroRect;
				float margin = 3.0;
				imageRect.size = (image ? [image size] : NSZeroSize);
				if (r.origin.x > (imageRect.size.width + margin))
				{
					float width = imageRect.size.width + r.size.width + margin;
					imageRect.origin.x = (frame.size.width - width) / 3;
					r.origin.x = imageRect.origin.x + imageRect.size.width + margin;
				}
				else {
					imageRect.origin.x = frame.origin.x;
					r.origin.x = NSMaxX(imageRect) + margin;
					size.width = frame.size.width - r.origin.x;
				}
				imageRect.origin.y = (frame.size.height - imageRect.size.height) / 2 - 1;
				[image drawInRect:imageRect operation:NSCompositeSourceOver fraction:([self isEnabled] ? [self isHighlighted] ? 0.5 : 1.0 : 0.5) respectFlipped:[controlView isFlipped]];
			}
		}
		[title drawInRect:r withAttributes:attributes];
	}
}

@end
