/*

SBBookmarkView.m
 
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

#import "SBBookmarkView.h"
#import "SBUtil.h"

@implementation SBBookmarkView

@synthesize image;
@dynamic message;
@dynamic title;
@dynamic urlString;
@synthesize fillMode;

- (id)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		fillMode = 1;
		animationDuration = 1.0;
		[self constructMessageLabel];
		[self constructTitleLabel];
		[self constructURLLabel];
		[self constructColorLabel];
		[self constructTitleField];
		[self constructURLField];
		[self constructColorPopup];
		[self constructDoneButton];
		[self constructCancelButton];
		[self makeResponderChain];
		[self setAutoresizingMask:(NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin)];
	}
	return self;
}

- (void)dealloc
{
	[image release];
	[self destructMessageLabel];
	[titleLabel release];
	[urlLabel release];
	[colorLabel release];
	[titleField release];
	[urlField release];
	[colorPopup release];
	[doneButton release];
	[cancelButton release];
	[super dealloc];
}

#pragma mark Getter

- (NSDictionary *)itemRepresentation
{
	NSString *title = self.title;
	NSString *urlString = self.urlString;
	NSData *data = [[image bitmapImageRep] data];
	NSString *labelName = SBBookmarkLabelColorNames[[colorPopup indexOfSelectedItem] - 1];
	NSString *offset = NSStringFromPoint(NSZeroPoint);
	return SBCreateBookmarkItem(title, urlString, data, [NSDate date], labelName, offset);
}

#pragma mark Rects

- (NSPoint)margin
{
	return NSMakePoint(36.0, 32.0);
}

- (CGFloat)labelWidth
{
	return 85.0;
}

- (NSSize)buttonSize
{
	return NSMakeSize(105.0, 24.0);
}

- (CGFloat)buttonMargin
{
	return 15.0;
}

- (NSRect)imageRect
{
	NSRect r = NSZeroRect;
	NSPoint margin = NSZeroPoint;
	r.size = SBBookmarkImageMaxSize();
	margin.x = (self.bounds.size.height - r.size.height) / 2;
	margin.y = r.size.height * 0.5;
	r.origin = margin;
	return r;
}

- (NSRect)messageLabelRect
{
	NSRect r = NSZeroRect;
	NSRect imageRect = [self imageRect];
	NSPoint margin = [self margin];
	r.size.width = self.bounds.size.width - margin.x * 2;
	r.size.height = 36.0;
	r.origin.x = margin.x;
	r.origin.y = self.bounds.size.height - imageRect.origin.y / 2 - r.size.height;
	return r;
}

- (NSRect)titleLabelRect
{
	NSRect r = NSZeroRect;
	NSRect imageRect = [self imageRect];
	r.origin.x = NSMaxX(imageRect) + 10.0;
	r.size.width = [self labelWidth];
	r.size.height = 24.0;
	r.origin.y = NSMaxY(imageRect) - r.size.height;
	return r;
}

- (NSRect)urlLabelRect
{
	NSRect r = NSZeroRect;
	NSRect titleRect = [self titleLabelRect];
	r.origin.x = titleRect.origin.x;
	r.size.width = [self labelWidth];
	r.size.height = 24.0;
	r.origin.y = titleRect.origin.y - 10.0 - r.size.height;
	return r;
}

- (NSRect)colorLabelRect
{
	NSRect r = NSZeroRect;
	NSRect urlRect = [self urlLabelRect];
	r.origin.x = urlRect.origin.x;
	r.size.width = [self labelWidth];
	r.size.height = 24.0;
	r.origin.y = urlRect.origin.y - 10.0 - r.size.height;
	return r;
}

- (NSRect)titleFieldRect
{
	NSRect r = NSZeroRect;
	NSPoint margin = [self margin];
	NSRect titleLabelRect = [self titleLabelRect];
	r.origin.x = NSMaxX(titleLabelRect) + 10.0;
	r.origin.y = titleLabelRect.origin.y;
	r.size.width = self.bounds.size.width - r.origin.x - margin.x;
	r.size.height = 24.0;
	return r;
}

- (NSRect)urlFieldRect
{
	NSRect r = NSZeroRect;
	NSPoint margin = [self margin];
	NSRect urlLabelRect = [self urlLabelRect];
	r.origin.x = NSMaxX(urlLabelRect) + 10.0;
	r.origin.y = urlLabelRect.origin.y;
	r.size.width = self.bounds.size.width - r.origin.x - margin.x;
	r.size.height = 24.0;
	return r;
}

- (NSRect)colorPopupRect
{
	NSRect r = NSZeroRect;
	NSRect colorLabelRect = [self colorLabelRect];
	r.origin.x = NSMaxX(colorLabelRect) + 10.0;
	r.origin.y = colorLabelRect.origin.y;
	r.size.width = 150.0;
	r.size.height = 26.0;
	return r;
}

- (NSRect)doneButtonRect
{
	NSRect r = NSZeroRect;
	NSPoint margin = [self margin];
	CGFloat buttonMargin = [self buttonMargin];
	r.size = [self buttonSize];
	r.origin.y = margin.y;
	r.origin.x = (self.bounds.size.width - (r.size.width * 2 + buttonMargin)) / 2 + r.size.width + buttonMargin;
	return r;
}

- (NSRect)cancelButtonRect
{
	NSRect r = NSZeroRect;
	NSPoint margin = [self margin];
	CGFloat buttonMargin = [self buttonMargin];
	r.size = [self buttonSize];
	r.origin.y = margin.y;
	r.origin.x = (self.bounds.size.width - (r.size.width * 2 + buttonMargin)) / 2;
	return r;
}

#pragma mark Destruction

- (void)destructMessageLabel
{
	if (messageLabel)
	{
		[messageLabel removeFromSuperview];
		[messageLabel release];
		messageLabel = nil;
	}
}

#pragma mark Construction

- (void)constructMessageLabel
{
	NSRect r = [self messageLabelRect];
	messageLabel = [[NSTextField alloc] initWithFrame:r];
	[messageLabel setAutoresizingMask:(NSViewMinXMargin | NSViewMinYMargin)];
	[messageLabel setEditable:NO];
	[messageLabel setBordered:NO];
	[messageLabel setDrawsBackground:NO];
	[messageLabel setTextColor:[NSColor whiteColor]];
	[[messageLabel cell] setFont:[NSFont boldSystemFontOfSize:16]];
	[[messageLabel cell] setAlignment:NSCenterTextAlignment];
	[[messageLabel cell] setWraps:YES];
	[self addSubview:messageLabel];
}

- (void)constructTitleLabel
{
	NSRect r = [self titleLabelRect];
	titleLabel = [[NSTextField alloc] initWithFrame:r];
	[titleLabel setAutoresizingMask:(NSViewMinXMargin | NSViewMinYMargin)];
	[titleLabel setEditable:NO];
	[titleLabel setBordered:NO];
	[titleLabel setDrawsBackground:NO];
	[titleLabel setTextColor:[NSColor lightGrayColor]];
	[[titleLabel cell] setFont:[NSFont systemFontOfSize:12]];
	[[titleLabel cell] setAlignment:NSRightTextAlignment];
	[titleLabel setStringValue:[NSString stringWithFormat:@"%@ :", NSLocalizedString(@"Title", nil)]];
	[self addSubview:titleLabel];
}

- (void)constructURLLabel
{
	NSRect r = [self urlLabelRect];
	urlLabel = [[NSTextField alloc] initWithFrame:r];
	[urlLabel setAutoresizingMask:(NSViewMinXMargin | NSViewMinYMargin)];
	[urlLabel setEditable:NO];
	[urlLabel setBordered:NO];
	[urlLabel setDrawsBackground:NO];
	[urlLabel setTextColor:[NSColor lightGrayColor]];
	[[urlLabel cell] setFont:[NSFont systemFontOfSize:12]];
	[[urlLabel cell] setAlignment:NSRightTextAlignment];
	[urlLabel setStringValue:[NSString stringWithFormat:@"%@ :", NSLocalizedString(@"URL", nil)]];
	[self addSubview:urlLabel];
}

- (void)constructColorLabel
{
	NSRect r = [self colorLabelRect];
	colorLabel = [[NSTextField alloc] initWithFrame:r];
	[colorLabel setAutoresizingMask:(NSViewMinXMargin | NSViewMinYMargin)];
	[colorLabel setEditable:NO];
	[colorLabel setBordered:NO];
	[colorLabel setDrawsBackground:NO];
	[colorLabel setTextColor:[NSColor lightGrayColor]];
	[[colorLabel cell] setFont:[NSFont systemFontOfSize:12]];
	[[colorLabel cell] setAlignment:NSRightTextAlignment];
	[colorLabel setStringValue:[NSString stringWithFormat:@"%@ :", NSLocalizedString(@"Label", nil)]];
	[self addSubview:colorLabel];
}

- (void)constructTitleField
{
	NSRect r = [self titleFieldRect];
	titleField = [[SBBLKGUITextField alloc] initWithFrame:r];
	[titleField setAutoresizingMask:(NSViewMinXMargin | NSViewMinYMargin)];
	[[titleField cell] setAlignment:NSLeftTextAlignment];
	[self addSubview:titleField];
}

- (void)constructURLField
{
	NSRect r = [self urlFieldRect];
	urlField = [[SBBLKGUITextField alloc] initWithFrame:r];
	[urlField setAutoresizingMask:(NSViewMinXMargin | NSViewMinYMargin)];
	[urlField setDelegate:self];
	[[urlField cell] setAlignment:NSLeftTextAlignment];
	[self addSubview:urlField];
}

- (void)constructColorPopup
{
	NSRect r = [self colorPopupRect];
	colorPopup = [[SBBLKGUIPopUpButton alloc] initWithFrame:r];
	[colorPopup setAutoresizingMask:(NSViewMinXMargin | NSViewMinYMargin)];
	[colorPopup setPullsDown:YES];
	[[colorPopup cell] setAlignment:NSLeftTextAlignment];
	[colorPopup setMenu:SBBookmarkLabelColorMenu(YES, nil, nil, nil)];
	[colorPopup selectItemAtIndex:1];
	[self addSubview:colorPopup];
}

- (void)constructDoneButton
{
	NSRect r = [self doneButtonRect];
	doneButton = [[SBBLKGUIButton alloc] initWithFrame:r];
	[doneButton setTitle:NSLocalizedString(@"Add", nil)];
	[doneButton setTarget:self];
	[doneButton setAction:@selector(done)];
	[doneButton setKeyEquivalent:@"\r"];	// busy if button is added into a view
	[doneButton setEnabled:NO];
	[self addSubview:doneButton];
}

- (void)constructCancelButton
{
	NSRect r = [self cancelButtonRect];
	cancelButton = [[SBBLKGUIButton alloc] initWithFrame:r];
	[cancelButton setTitle:NSLocalizedString(@"Cancel", nil)];
	[cancelButton setTarget:self];
	[cancelButton setAction:@selector(cancel)];
	[cancelButton setKeyEquivalent:@"\e"];
	[self addSubview:cancelButton];
}

- (void)makeResponderChain
{
	if (urlField)
		[titleField setNextKeyView:urlField];
	if (cancelButton)
		[urlField setNextKeyView:cancelButton];
	if (doneButton)
		[cancelButton setNextKeyView:doneButton];
	if (titleField)
		[doneButton setNextKeyView:titleField];
}

#pragma mark Getter

- (NSString *)message
{
	return [messageLabel stringValue];
}

- (NSString *)title
{
	return [titleField stringValue];
}

- (NSString *)urlString
{
	return [urlField stringValue];
}

#pragma mark Setter

- (void)setImage:(NSImage *)inImage
{
	if (image != inImage)
	{
		if (image)
		{
			[image release];
		}
		image = [inImage retain];
		[self setNeedsDisplay:YES];
	}
}

- (void)setMessage:(NSString *)message
{
	[messageLabel setStringValue:message];
}

- (void)setTitle:(NSString *)title
{
	[titleField setStringValue:title];
}

- (void)setUrlString:(NSString *)urlString
{
	[urlField setStringValue:urlString];
	[doneButton setEnabled:[urlString length] > 0];
}

#pragma mark Delegate

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	if ([aNotification object] == urlField)
	{
		NSString *stringValue = [urlField stringValue];
		[doneButton setEnabled:[stringValue length] > 0];
	}
}

#pragma mark Actions

- (void)makeFirstResponderToTitleField
{
	[[self window] makeFirstResponder:titleField];
}

#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	NSRect bounds = self.bounds;
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
	NSUInteger count = 2;
	CGFloat locations[count];
	CGFloat colors[count * 4];
	CGPoint points[count];
	CGPathRef path = nil;
	CATransform3D transform = CATransform3DIdentity;
	
	
	// Background
	locations[0] = 0.0;
	locations[1] = 0.6;
	colors[0] = colors[1] = colors[2] = 0.4;
	colors[3] = 0.9;
	colors[4] = colors[5] = colors[6] = 0.0;
	colors[7] = 0.0;
	points[0] = CGPointZero;
	points[1] = CGPointMake(0.0, bounds.size.height);
	
	if (fillMode == 0)
	{
		CGRect r = CGRectZero;
		r = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.width);
		transform = CATransform3DRotate(transform, -70 * M_PI / 180, 1.0, 0.0, 0.0);
		path = SBEllipsePath3D(r, transform);
	}
	else {
		CGMutablePathRef mpath = CGPathCreateMutable();
		CGPoint p = CGPointZero;
		CGFloat behind = 0.7;
		CGPathMoveToPoint(mpath, nil, p.x, p.y);
		p.x = bounds.size.width;
		CGPathAddLineToPoint(mpath, nil, p.x, p.y);
		p.x = bounds.size.width - ((bounds.size.width * (1.0 - behind)) / 2);
		p.y = bounds.size.height * locations[1];
		CGPathAddLineToPoint(mpath, nil, p.x, p.y);
		p.x = (bounds.size.width * (1.0 - behind)) / 2;
		CGPathAddLineToPoint(mpath, nil, p.x, p.y);
		p = CGPointZero;
		CGPathAddLineToPoint(mpath, nil, p.x, p.y);
		path = (CGPathRef)[(id)CGPathCreateCopy(mpath) autorelease];
		CGPathRelease(mpath);
	}
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, path);
	CGContextClip(ctx);
	SBDrawGradientInContext(ctx, count, locations, colors, points);
	CGContextRestoreGState(ctx);
	
	if (image)
	{
		CGRect imageRect = NSRectToCGRect([self imageRect]);
		CGImageRef maskImage = nil;
		
		[image drawInRect:NSRectFromCGRect(imageRect) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:0.85];
		
		imageRect.origin.y -= imageRect.size.height;
		imageRect.size.height *= 0.5;
		maskImage = SBBookmarkReflectionMaskImage(imageRect.size);
		CGContextTranslateCTM(ctx, 0.0, 0.0);
		CGContextScaleCTM(ctx, 1.0, -1.0);
		CGContextClipToMask(ctx, imageRect, maskImage);
		[image drawInRect:NSRectFromCGRect(imageRect) fromRect:NSMakeRect(0, 0, [image size].width, [image size].height * 0.5) operation:NSCompositeSourceOver fraction:1.0];
	}
}

@end

@implementation SBEditBookmarkView

@synthesize index;
@dynamic labelName;

- (id)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		index = NSNotFound;
		[self destructMessageLabel];
		
		[doneButton setTitle:NSLocalizedString(@"Done", nil)];
	}
	return self;
}

- (NSString *)labelName
{
	NSString *labelName = nil;
	NSInteger itemIndex = [colorPopup indexOfSelectedItem] - 1;
	if (itemIndex < SBBookmarkCountOfLabelColors)
	{
		labelName = SBBookmarkLabelColorNames[itemIndex];
	}
	return labelName;
}

- (void)setLabelName:(NSString *)labelName
{
	NSUInteger itemIndex = NSNotFound;
	for (NSUInteger i = 0; i < SBBookmarkCountOfLabelColors; i++)
	{
		if ([labelName isEqualToString:SBBookmarkLabelColorNames[i]])
		{
			itemIndex = i;
			break;
		}
	}
	if (itemIndex != NSNotFound)
	{
		[colorPopup selectItemAtIndex:itemIndex + 1];
	}
}

@end
