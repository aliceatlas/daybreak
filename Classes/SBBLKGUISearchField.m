//
//  SBBLKGUISearchField.m
//  Sunrise
//
//  Created by Atsushi Jike on 10/03/21.
//  Copyright 2010 Atsushi Jike. All rights reserved.
//

#import "SBBLKGUISearchField.h"
#import "SBUtil.h"

@implementation SBBLKGUISearchField

+ (void)initialize
{
	if (self == [SBBLKGUISearchField class])
	{
		[self setCellClass:[SBBLKGUISearchFieldCell class]];
	}
}

+ (Class)cellClass
{
	return [SBBLKGUISearchFieldCell class];
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
	[self setAlignment:NSLeftTextAlignment];
	[self setDrawsBackground:NO];
	[self setTextColor:[NSColor whiteColor]];
}

@end

@implementation SBBLKGUISearchFieldCell

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
	NSButtonCell *searchButtonCell = nil;
	searchButtonCell = [self searchButtonCell];
	[self setWraps:NO];
	[self setScrollable:YES];
	[self setFocusRingType:NSFocusRingTypeExterior];
	[searchButtonCell setImage:[NSImage imageNamed:@"Search.png"]];
	[searchButtonCell setAlternateImage:[NSImage imageNamed:@"Search.png"]];
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
	path = SBRoundedPath(r, r.size.height / 2, 0, YES, YES);
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, path);
	CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, alpha * 0.1);
	CGContextFillPath(ctx);
	CGContextRestoreGState(ctx);
	CGPathRelease(path);
	
	r = NSRectToCGRect(cellFrame);
	r.origin.x += 0.5;
	r.origin.y += 0.5;
	r.size.width -= 1.0;
	r.size.height -= 1.0;
	path = SBRoundedPath(r, r.size.height / 2, 0, YES, YES);
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, path);
	CGContextSetLineWidth(ctx, 0.5);
	CGContextSetRGBStrokeColor(ctx, 1.0, 1.0, 1.0, alpha);
	CGContextStrokePath(ctx);
	CGContextRestoreGState(ctx);
	CGPathRelease(path);
	
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