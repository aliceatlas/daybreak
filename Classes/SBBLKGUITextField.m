/*

SBBLKGUITextField.m
 
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

#import "SBBLKGUITextField.h"
#import "SBUtil.h"

@implementation SBBLKGUITextField

+ (void)initialize
{
	if (self == [SBBLKGUITextField class])
	{
		[self setCellClass:[SBBLKGUITextFieldCell class]];
	}
}

+ (Class)cellClass
{
	return [SBBLKGUITextFieldCell class];
}

- (id)initWithFrame:(NSRect)rect
{
	if (self = [super initWithFrame:rect])
	{
		[self setDefaultValues];
	}
	return self;
}

- (void)setDefaultValues
{
	[self setAlignment:NSRightTextAlignment];
	[self setDrawsBackground:NO];
	[self setTextColor:[NSColor whiteColor]];
}

@end

@implementation SBBLKGUITextFieldCell

- (id)init
{
	if (self = [super init])
	{
		[self setDefaultValues];
	}
	return self;
}

- (void)setDefaultValues
{
	[self setWraps:NO];
	[self setScrollable:YES];
	[self setFocusRingType:NSFocusRingTypeExterior];
}

- (NSText *)setUpFieldEditorAttributes:(NSText *)textObj
{
	NSText *text = [super setUpFieldEditorAttributes:textObj];
	if ([text isKindOfClass:[NSTextView class]])
	{
		NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSColor whiteColor], 
									NSForegroundColorAttributeName, 
									[NSColor grayColor], 
									NSBackgroundColorAttributeName, nil];
		[(NSTextView *)text setInsertionPointColor:[NSColor whiteColor]];
		[(NSTextView *)text setSelectedTextAttributes:attributes];
	}
	return text;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	CGRect r = CGRectZero;
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
	CGPathRef path = nil;
	CGFloat alpha = [controlView respondsToSelector:@selector(isEnabled)] ? ([(NSTextField *)controlView isEnabled] ? 1.0 : 0.2) : 1.0;
	
	r = NSRectToCGRect(cellFrame);
	path = SBRoundedPath(r, SBFieldRoundedCurve, 0, YES, YES);
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, path);
	CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, alpha * 0.1);
	CGContextFillPath(ctx);
	CGContextRestoreGState(ctx);
	
	r = NSRectToCGRect(cellFrame);
	r.origin.x += 0.5;
	r.origin.y += 0.5;
	r.size.width -= 1.0;
	r.size.height -= 1.0;
	path = SBRoundedPath(r, SBFieldRoundedCurve, 0, YES, YES);
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, path);
	CGContextSetLineWidth(ctx, 0.5);
	CGContextSetRGBStrokeColor(ctx, 1.0, 1.0, 1.0, alpha);
	CGContextStrokePath(ctx);
	CGContextRestoreGState(ctx);
	
	[self drawInteriorWithFrame:cellFrame inView:controlView];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[super drawInteriorWithFrame:cellFrame inView:controlView];
}

- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent
{
	[super editWithFrame:aRect inView:controlView editor:textObj delegate:anObject event:theEvent];
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(int)selStart length:(int)selLength
{
	[super selectWithFrame:aRect inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
}

@end