/*

SBUtil.m
 
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

#import "SBUtil.h"

#import "Sunrise3-Bridging-Header.h"
#import "Sunrise3-Swift.h"

NSDictionary *SBCreateBookmarkItemO(NSString *title, NSString *url, NSData *imageData, NSDate *date, NSString *labelName, NSString *offsetString);
NSDictionary *SBDefaultBookmarksO();
NSData *SBEmptyBookmarkImageDataO();
NSDictionary *SBBookmarksWithItemsO(NSArray *items);
NSSize SBBookmarkImageMaxSizeO();
void SBDrawGradientInContextO(CGContextRef ctx, NSUInteger count, const CGFloat locations[], const CGFloat colors[], const CGPoint points[]);
void SBCGPointApplyTransform3DO(CGPoint *p, const CATransform3D *t);

#pragma mark Default values

NSDictionary *SBDefaultBookmarksO()
{
	NSArray *items = nil;
	NSDictionary *defaultItem = nil;
	NSString *path = [NSBundle.mainBundle pathForResource:@"DefaultBookmark" ofType:@"plist"];
	if ((defaultItem = [NSDictionary dictionaryWithContentsOfFile:path]))
	{
		NSString *title = defaultItem[kSBBookmarkTitle];
		NSData *imageData = defaultItem[kSBBookmarkImage];
		NSString *URLString = defaultItem[kSBBookmarkURL];
		if (!title) title = NSLocalizedString(@"Untitled", nil);
		if (!URLString) URLString = @"http://www.example.com/";
		if (!imageData) imageData = SBEmptyBookmarkImageDataO();
		items = @[SBCreateBookmarkItemO(title, URLString, imageData, [NSDate date], nil, NSStringFromPoint(NSZeroPoint))];
	}
	return items.count > 0 ? SBBookmarksWithItemsO(items) : nil;
}

NSData *SBEmptyBookmarkImageDataO()
{
	NSData *data = nil;
	NSBitmapImageRep *bitmapImageRep = nil;
	CGImageRef image = nil;
	CGImageRef paledImage = nil;
	CGContextRef ctx = nil;
	CGSize size = CGSizeZero;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGMutablePathRef path = nil;
	NSUInteger count = 2;
	CGFloat locations[count];
	CGFloat colors[count * 4];
	CGPoint points[count];
	
	size = NSSizeToCGSize(SBBookmarkImageMaxSizeO());
	ctx = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast));
	CGColorSpaceRelease(colorSpace);
	
	// Background
	locations[0] = 0.0;
	locations[1] = 1.0;
	colors[0] = colors[1] = colors[2] = 0.0;
	colors[3] = 1.0;
	colors[4] = colors[5] = colors[6] = 0.75;
	colors[7] = 1.0;
	points[0] = CGPointZero;
	points[1] = CGPointMake(0.0, size.height);
	CGContextSaveGState(ctx);
	path = CGPathCreateMutable();
	CGPathAddRect(path, nil, CGRectMake(0, 0, size.width, size.height));
	CGContextAddPath(ctx, path);
	CGContextClip(ctx);
	SBDrawGradientInContextO(ctx, count, locations, colors, points);
	CGContextRestoreGState(ctx);
	CGPathRelease(path);
	
	locations[0] = 0.5;
	locations[1] = 1.0;
	colors[0] = colors[1] = colors[2] = 0.1;
	colors[3] = 1.0;
	colors[4] = colors[5] = colors[6] = 0.25;
	colors[7] = 1.0;
	points[0] = CGPointZero;
	points[1] = CGPointMake(0.0, size.height);
	CGContextSaveGState(ctx);
	path = CGPathCreateMutable();
	CGPathAddRect(path, nil, CGRectInset(CGRectMake(0, 0, size.width, size.height), 0.5, 0.5));
	CGContextAddPath(ctx, path);
	CGContextClip(ctx);
	SBDrawGradientInContextO(ctx, count, locations, colors, points);
	CGContextRestoreGState(ctx);
	CGPathRelease(path);
	
	paledImage = [NSImage imageNamed:@"PaledApplicationIcon"].CGImage;
	if (paledImage)
	{
		CGRect r = CGRectZero;
		r.size.width = CGImageGetWidth(paledImage);
		r.size.height = CGImageGetHeight(paledImage);
		r.origin.x = (size.width - r.size.width) / 2;
		r.origin.y = (size.height - r.size.height) / 2;
		CGContextSaveGState(ctx);
		CGContextDrawImage(ctx, r, paledImage);
		CGContextRestoreGState(ctx);
	}
	
	image = CGBitmapContextCreateImage(ctx);
	CGContextRelease(ctx);
	if (image)
	{
		bitmapImageRep = [[NSBitmapImageRep alloc] initWithCGImage:image];
		CGImageRelease(image);
		data = bitmapImageRep.data;
	}
	return data;
}

#pragma mark Bookmarks

NSDictionary *SBBookmarksWithItemsO(NSArray *items)
{
	NSDictionary *info = nil;
	info = @{kSBBookmarkVersion: SBBookmarkVersion, 
             kSBBookmarkItems: items};
	return info;
}

NSDictionary *SBCreateBookmarkItemO(NSString *title, NSString *url, NSData *imageData, NSDate *date, NSString *labelName, NSString *offsetString)
{
	NSMutableDictionary *item = nil;
	item = [NSMutableDictionary dictionaryWithCapacity:0];
	if (title)
		item[kSBBookmarkTitle] = title;
	if (url)
		item[kSBBookmarkURL] = url;
	if (imageData)
		item[kSBBookmarkImage] = imageData;
	if (date)
		item[kSBBookmarkDate] = date;
	if (labelName)
		item[kSBBookmarkLabelName] = labelName;
	if (offsetString)
		item[kSBBookmarkOffset] = offsetString;
	return [item copy];
}

#pragma mark Rects

NSSize SBBookmarkImageMaxSizeO()
{
	return NSMakeSize(kSBBookmarkCellMaxWidth, kSBBookmarkCellMaxWidth / kSBBookmarkFactorForImageWidth * kSBBookmarkFactorForImageHeight);
}

#pragma mark Paths

CGPathRef SBEllipsePath3D(CGRect r, CATransform3D transform)
{
	CGPathRef copiedPath = nil;
	CGMutablePathRef path = nil;
	CGPoint p = CGPointZero;
	CGPoint cp1 = CGPointZero;
	CGPoint cp2 = CGPointZero;
	
	path = CGPathCreateMutable();
	p.x = CGRectGetMidX(r);
	p.y = r.origin.y;
	SBCGPointApplyTransform3DO(&p, &transform);
	CGPathMoveToPoint(path, nil, p.x, p.y);
	p.x = r.origin.x;
	p.y = CGRectGetMidY(r);
	cp1.x = r.origin.x + r.size.width / 4;
	cp1.y = r.origin.y;
	cp2.x = r.origin.x;
	cp2.y = r.origin.y + r.size.height / 4;
	SBCGPointApplyTransform3DO(&p, &transform);
	SBCGPointApplyTransform3DO(&cp1, &transform);
	SBCGPointApplyTransform3DO(&cp2, &transform);
	CGPathAddCurveToPoint(path, nil, cp1.x, cp1.y, cp2.x, cp2.y, p.x, p.y);
	p.x = CGRectGetMidX(r);
	p.y = CGRectGetMaxY(r);
	cp1.x = r.origin.x;
	cp1.y = r.origin.y + r.size.height / 4 * 3;
	cp2.x = r.origin.x + r.size.width / 4;
	cp2.y = CGRectGetMaxY(r);
	SBCGPointApplyTransform3DO(&p, &transform);
	SBCGPointApplyTransform3DO(&cp1, &transform);
	SBCGPointApplyTransform3DO(&cp2, &transform);
	CGPathAddCurveToPoint(path, nil, cp1.x, cp1.y, cp2.x, cp2.y, p.x, p.y);
	p.x = CGRectGetMaxX(r);
	p.y = CGRectGetMidY(r);
	cp1.x = r.origin.x + r.size.width / 4 * 3;
	cp1.y = CGRectGetMaxY(r);
	cp2.x = CGRectGetMaxX(r);
	cp2.y = r.origin.y + r.size.height / 4 * 3;
	SBCGPointApplyTransform3DO(&p, &transform);
	SBCGPointApplyTransform3DO(&cp1, &transform);
	SBCGPointApplyTransform3DO(&cp2, &transform);
	CGPathAddCurveToPoint(path, nil, cp1.x, cp1.y, cp2.x, cp2.y, p.x, p.y);
	p.x = CGRectGetMidX(r);
	p.y = r.origin.y;
	cp1.x = CGRectGetMaxX(r);
	cp1.y = r.origin.y + r.size.height / 4;
	cp2.x = r.origin.x + r.size.width / 4 * 3;
	cp2.y = r.origin.y;
	SBCGPointApplyTransform3DO(&p, &transform);
	SBCGPointApplyTransform3DO(&cp1, &transform);
	SBCGPointApplyTransform3DO(&cp2, &transform);
	CGPathAddCurveToPoint(path, nil, cp1.x, cp1.y, cp2.x, cp2.y, p.x, p.y);
	
	copiedPath = CGPathCreateCopy(path);
	CGPathRelease(path);
    
    return CFAutorelease(copiedPath);
}

CGPathRef SBRoundedPath3D(CGRect rect, CGFloat curve, CATransform3D transform)
{
	CGPathRef copiedPath = nil;
	CGMutablePathRef path = CGPathCreateMutable();
	CGPoint p = CGPointZero;
	CGPoint cp1 = CGPointZero;
	CGPoint cp2 = CGPointZero;
	CGAffineTransform t = CGAffineTransformIdentity;
	
	// line left-top to right-top
	p.x = (rect.origin.x + curve);
	p.y = rect.origin.y;
	SBCGPointApplyTransform3DO(&p, &transform);
	CGPathMoveToPoint(path, &t, p.x,p.y);
	p.x = (rect.origin.x + rect.size.width - curve);
	p.y = rect.origin.y;
	SBCGPointApplyTransform3DO(&p, &transform);
	CGPathAddLineToPoint(path, &t, p.x,p.y);
	p.x = (rect.origin.x + rect.size.width);
	cp1.x = (rect.origin.x + rect.size.width);
	cp1.y = rect.origin.y + curve / 2;
	cp2.x = (rect.origin.x + rect.size.width) - curve / 2;
	cp2.y = rect.origin.y;
	p.y = (rect.origin.y + curve);
	SBCGPointApplyTransform3DO(&p, &transform);
	SBCGPointApplyTransform3DO(&cp1, &transform);
	SBCGPointApplyTransform3DO(&cp2, &transform);
	CGPathAddCurveToPoint(path, &t, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
	
	p.x = (rect.origin.x + rect.size.width);
	p.y = (rect.origin.y + rect.size.height - curve);
	SBCGPointApplyTransform3DO(&p, &transform);
	CGPathAddLineToPoint(path, &t, p.x,p.y);
	p.x = (rect.origin.x + rect.size.width - curve);
	p.y = (rect.origin.y + rect.size.height);
	cp1.y = (rect.origin.y + rect.size.height);
	cp1.x = (rect.origin.x + rect.size.width) - curve / 2;
	cp2.y = (rect.origin.y + rect.size.height) - curve / 2;
	cp2.x = (rect.origin.x + rect.size.width);
	SBCGPointApplyTransform3DO(&p, &transform);
	SBCGPointApplyTransform3DO(&cp1, &transform);
	SBCGPointApplyTransform3DO(&cp2, &transform);
	CGPathAddCurveToPoint(path, &t, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
	
	p.x = (rect.origin.x + curve);
	p.y = (rect.origin.y + rect.size.height);
	SBCGPointApplyTransform3DO(&p, &transform);
	CGPathAddLineToPoint(path, &t, p.x,p.y);
	p.x = rect.origin.x;
	cp1.x = rect.origin.x;
	cp1.y = (rect.origin.y + rect.size.height) - curve / 2;
	cp2.x = rect.origin.x + curve / 2;
	cp2.y = (rect.origin.y + rect.size.height);
	p.y = (rect.origin.y + rect.size.height - curve);
	SBCGPointApplyTransform3DO(&p, &transform);
	SBCGPointApplyTransform3DO(&cp1, &transform);
	SBCGPointApplyTransform3DO(&cp2, &transform);
	CGPathAddCurveToPoint(path, &t, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
	
	p.x = rect.origin.x;
	p.y = (rect.origin.y + curve);
	SBCGPointApplyTransform3DO(&p, &transform);
	CGPathAddLineToPoint(path, &t, p.x,p.y);
	p.y = rect.origin.y;
	cp1.y = rect.origin.y;
	cp1.x = rect.origin.x + curve / 2;
	cp2.y = rect.origin.y + curve / 2;
	cp2.x = rect.origin.x;
	p.x = (rect.origin.x + curve);
	SBCGPointApplyTransform3DO(&p, &transform);
	SBCGPointApplyTransform3DO(&cp1, &transform);
	SBCGPointApplyTransform3DO(&cp2, &transform);
	CGPathAddCurveToPoint(path, &t, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
	
	CGPathCloseSubpath(path);
	copiedPath = CGPathCreateCopy(path);
	CGPathRelease(path);
    
    return CFAutorelease(copiedPath);
}

void SBCGPointApplyTransform3DO(CGPoint *p, const CATransform3D *t)
{
	double px = p->x;
	double py = p->y, w;
	w  = px * t->m14 + py * t->m24 + t->m44;
	p->x = (px * t->m11 + py * t->m21 + t->m41) / w;
	p->y = (px * t->m12 + py * t->m22 + t->m42) / w;
}

#pragma mark Drawing

void SBDrawGradientInContextO(CGContextRef ctx, NSUInteger count, const CGFloat locations[], const CGFloat colors[], const CGPoint points[])
{
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, count);
//	CGFunctionRef gradientFunction = CGGradientGetFunction(gradient);
	CGContextDrawLinearGradient(ctx, gradient, points[0], points[1], kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(gradient);
	CGColorSpaceRelease(colorSpace);
//	if (CFGetRetainCount(gradientFunction) > 0)
//		CGFunctionRelease(gradientFunction);
}

void SBGetAlternateSelectedLightControlColorComponents(CGFloat colors[4])
{
	NSColor *selectedDarkColor = [[NSColor.alternateSelectedControlColor blendedColorWithFraction:0.3 ofColor:NSColor.whiteColor] colorUsingColorSpace:NSColorSpace.genericRGBColorSpace];
	[selectedDarkColor getComponents:colors];
}

void SBGetAlternateSelectedControlColorComponents(CGFloat colors[4])
{
	NSColor *selectedColor = [NSColor.alternateSelectedControlColor colorUsingColorSpace:NSColorSpace.genericRGBColorSpace];
	[selectedColor getComponents:colors];
}

void SBGetAlternateSelectedDarkControlColorComponents(CGFloat colors[4])
{
	NSColor *selectedDarkColor = [[NSColor.alternateSelectedControlColor blendedColorWithFraction:0.3 ofColor:NSColor.blackColor] colorUsingColorSpace:NSColorSpace.genericRGBColorSpace];
	[selectedDarkColor getComponents:colors];
}

#pragma mark Math

NSInteger SBRemainder(NSInteger value1, NSInteger value2)
{
	return value1 - (value1 / value2) * value2;
}

BOOL SBRemainderIsZero(NSInteger value1, NSInteger value2)
{
	return SBRemainder(value1, value2) == 0;
}

NSInteger SBGreatestCommonDivisor(NSInteger a, NSInteger b)
{
	NSInteger v = 0;
	if (a == 0 || b == 0)
	{
		v = 0;
	}
	else {
		// Euclidean
		while(a != b)
		{
			if (a > b)
			{
				a = a - b;
			}
			else {
				b = b - a;
			}
		}
	}
	return v;
}

#pragma mark Others

id SBValueForKey(NSString *keyName, NSDictionary *dictionary)
{
	id value = nil;
	
	value = dictionary[keyName];
	if (value == nil) {
		for (id object in dictionary.allValues)
		{
			if ([object isKindOfClass:NSDictionary.class]) {
				value = SBValueForKey(keyName, object);
			}
		}
	}
	else if ([value isKindOfClass:NSDictionary.class])
	{
		value = ((NSDictionary *)value).allValues[0];
	}
	return value;
}

NSMenu *SBEncodingMenu(id target, SEL selector, BOOL showDefault)
{
	NSMenu *menu = [[NSMenu alloc] init];
	NSArray *encs = nil;
	NSMutableArray *mencs = [NSMutableArray arrayWithCapacity:0];
#if kSBFlagShowAllStringEncodings
    const NSStringEncoding *encoding = NSString.availableStringEncodings;
	NSData *hint = nil;
	
	// Get available encodings
    while (*encoding)
	{
		[mencs addObject:@(*encoding)];
		encoding++;
	}
	
	// Sort
	hint = [mencs sortedArrayHint];
	encs = [mencs sortedArrayUsingFunction:SBStringEncodingSortFunction context:nil hint:hint];
#else
	const NSStringEncoding *encoding = SBAvailableStringEncodings;
	// Get available encodings
    while (*encoding)	// Continue while encoding is NULL
	{
		[mencs addObject:@(*encoding)];
		encoding++;
	}
	encs = [mencs copy];
#endif
	
	// Create menu items
	for (NSNumber *enc in encs)
	{
		NSStringEncoding stringEncoding = enc.unsignedIntegerValue;
		if (stringEncoding == NSNotFound)
		{
			[menu addItem:NSMenuItem.separatorItem];
		}
		else {
			NSString *encodingName = nil;
			NSString *ianaName = nil;
			encodingName = [NSString localizedNameOfStringEncoding:stringEncoding];
			ianaName = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(enc.unsignedIntegerValue));
			DebugLog(@"%d\t%lu\t%@\t%@\t%@", CFStringIsEncodingAvailable(CFStringConvertNSStringEncodingToEncoding(enc.unsignedIntegerValue)), (unsigned long)stringEncoding, encodingName, (NSString *)CFStringGetNameOfEncoding(CFStringConvertNSStringEncodingToEncoding(enc.unsignedIntegerValue)), ianaName);
			if (encodingName)
			{
				NSMenuItem *item = nil;
				item = [[NSMenuItem alloc] initWithTitle:encodingName action:selector keyEquivalent:@""];
				if (target)
                    item.target = target;
                item.representedObject = ianaName;
				[menu addItem:item];
			}
		}
	}
	if (showDefault)
	{
		NSMenuItem *defaultItem = nil;
		defaultItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Default", nil) action:selector keyEquivalent:@""];
		if (target)
            defaultItem.target = target;
        defaultItem.representedObject = nil;
		[menu insertItem:NSMenuItem.separatorItem atIndex:0];
		[menu insertItem:defaultItem atIndex:0];
	}
	return menu;
}

NSComparisonResult SBStringEncodingSortFunction(id num1, id num2, void *context)
{
	NSComparisonResult r = NSOrderedSame;
	NSString *enc1 = [NSString localizedNameOfStringEncoding:[num1 unsignedIntegerValue]];
	NSString *enc2 = [NSString localizedNameOfStringEncoding:[num2 unsignedIntegerValue]];
	r = [enc1 compare:enc2];
	return r;
}

NSInteger SBUnsignedIntegerSortFunction(id num1, id num2, void *context)
{
	NSInteger r = NSOrderedSame;
    NSUInteger v1 = [num1 unsignedIntegerValue];
    NSUInteger v2 = [num2 unsignedIntegerValue];
    if (v1 < v2)
	{
		r = NSOrderedAscending;
	}
    else if (v1 > v2)
	{
		r = NSOrderedDescending;
	}
	return r;
}

NSData *SBLocalizableStringsData(NSArray *fieldSet)
{
	NSData *data = nil;
	NSMutableString *string = [NSMutableString stringWithCapacity:0];
	[string appendString:[NSString string]];
	for (NSArray *fields in fieldSet)
	{
		NSTextField *field0 = nil;
		NSTextField *field1 = nil;
		NSString *text0 = nil;
		NSString *text1 = nil;
		if ([fields count] == 1)
		{
			field0 = fields[0];
			text0 = field0 ? field0.stringValue : nil;
			if (text0)
			{
				[string appendFormat:@"\n%@\n", text0];
			}
		}
		else if ([fields count] == 2)
		{
			field0 = fields[0];
			field1 = fields[1];
			text0 = field0 ? field0.stringValue : nil;
			text1 = field1 ? field1.stringValue : nil;
			if (text0 && text1)
			{
				[string appendFormat:@"\"%@\" = \"%@\";\n", text0, text1];
			}
		}
	}
	if ([string length] > 0)
	{
		data = [string dataUsingEncoding:NSUTF16StringEncoding];
	}
	return data;
}

#pragma mark Debug

NSDictionary *SBDebugViewStructure(NSView *view)
{
	NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:0];
	NSArray *subviews = view.subviews;
	NSString *description = nil;
	if ([view isKindOfClass:SBView.class])
		description = view.description;
	else
		description = [NSString stringWithFormat:@"%@ %@", view, NSStringFromRect(view.frame)];
	info[@"Description"] = description;
	if (subviews.count > 0)
	{
		NSMutableArray *children = [NSMutableArray arrayWithCapacity:0];
		for (id subview in subviews)
		{
			[children addObject:SBDebugViewStructure(subview)];
		}
		info[@"Children"] = [children copy];
	}
	return [info copy];
}

NSDictionary *SBDebugLayerStructure(CALayer *layer)
{
	NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:0];
	NSArray *sublayers = layer.sublayers;
	NSString *description = nil;
	description = [NSString stringWithFormat:@"%@ %@", layer, NSStringFromRect(NSRectFromCGRect([layer frame]))];
	info[@"Description"] = description;
	if (sublayers.count > 0)
	{
		NSMutableArray *children = [NSMutableArray arrayWithCapacity:0];
		for (id sublayer in sublayers)
		{
			[children addObject:SBDebugLayerStructure(sublayer)];
		}
		info[@"Children"] = [children copy];
	}
	return [info copy];
}

NSDictionary *SBDebugDumpMainMenu()
{
    return @{@"MenuItems": SBDebugDumpMenu(NSApplication.sharedApplication.mainMenu)};
}

NSArray *SBDebugDumpMenu(NSMenu *menu)
{
	NSMutableArray *items = [NSMutableArray arrayWithCapacity:0];
	for (NSMenuItem *item in menu.itemArray)
	{
		NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:0];
		NSMenu *submenu = item.submenu;
		NSString *title = item.title;
		id target = item.target;
		SEL action = item.action;
		NSInteger tag = item.tag;
		NSInteger state = item.state;
		NSImage *image = item.image;
		NSString *keyEquivalent = item.keyEquivalent;
		NSUInteger keyEquivalentModifierMask = item.keyEquivalentModifierMask;
		NSString *toolTip = item.toolTip;
		if (title)
			info[@"Title"] = title;
		if (target)
			info[@"Target"] = [NSString stringWithFormat:@"%@", target];
		if (action)
			info[@"Action"] = NSStringFromSelector(action);
		info[@"Tag"] = @(tag);
		info[@"State"] = @(state);
		if (image)
			info[@"Image"] = image.TIFFRepresentation;
		if (keyEquivalent)
			info[@"KeyEquivalent"] = keyEquivalent;
		info[@"KeyEquivalentModifierMask"] = @(keyEquivalentModifierMask);
		if (toolTip)
			info[@"ToolTip"] = toolTip;
		if (submenu)
		{
			info[@"MenuItems"] = SBDebugDumpMenu(submenu);
		}
		[items addObject:[info copy]];
	}
	return [items copy];
}

BOOL SBDebugWriteViewStructure(NSView *view, NSString *path)
{
	BOOL r = NO;
	NSDictionary *info = SBDebugViewStructure(view);
	r = [info writeToFile:path atomically:YES];
	return r;
}

BOOL SBDebugWriteLayerStructure(CALayer *layer, NSString *path)
{
	BOOL r = NO;
	NSDictionary *info = SBDebugLayerStructure(layer);
	r = [info writeToFile:path atomically:YES];
	return r;
}

BOOL SBDebugWriteMainMenu(NSString *path)
{
	BOOL r = NO;
	NSDictionary *info = SBDebugDumpMainMenu();
	r = [info writeToFile:path atomically:YES];
	return r;
}

void SBPerform(id target, SEL action, id object) {
    [target performSelector:action withObject: object];
}

void SBPerformWithModes(id target, SEL action, id object, NSArray *modes) {
    [target performSelector:action withObject:object afterDelay:0 inModes:modes];
}

kern_return_t SBCPUType(cpu_type_t *cpuType) {
    host_basic_info_data_t hostInfo;
    mach_msg_type_number_t infoCount = HOST_BASIC_INFO_COUNT;
    kern_return_t result = host_info(mach_host_self(), HOST_BASIC_INFO, (host_info_t)&hostInfo, &infoCount);
    if (result == KERN_SUCCESS) {
        *cpuType = hostInfo.cpu_type;
    }
    return result;
}