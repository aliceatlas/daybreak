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
#import "SBView.h"

#pragma mark Get objects

SBApplicationDelegate *SBGetApplicationDelegate()
{
	return (SBApplicationDelegate *)[[NSApplication sharedApplication] delegate];
}

SBDocumentController *SBGetDocumentController()
{
	return (SBDocumentController *)[SBDocumentController sharedDocumentController];
}

SBDocument *SBGetSelectedDocument()
{
	SBDocument *document = nil;
	NSArray *documents = [[NSApplication sharedApplication] orderedDocuments];
	if ([documents count] == 0)
	{
		if (!document)
		{
			NSError *error = nil;
			document = [SBGetDocumentController() openUntitledDocumentAndDisplay:YES error:&error];
		}
	}
	else {
		if ([[documents objectAtIndex:0] isKindOfClass:[SBDocument class]])
		{
			document = [documents objectAtIndex:0];
		}
	}
	return document;
}

WebPreferences *SBGetWebPreferences()
{
	WebPreferences *preferences = nil;
	preferences = [[[WebPreferences alloc] initWithIdentifier:kSBWebPreferencesIdentifier] autorelease];
	[preferences setAutosaves:YES];
	return preferences;
}

NSMenu *SBMenuWithTag(NSInteger tag)
{
	NSMenu *menu = nil;
	for (NSMenuItem *menuItem in [[[NSApplication sharedApplication] mainMenu] itemArray])
	{
		if ([menuItem tag] == tag)
		{
			menu = [menuItem submenu];
			break;
		}
	}
	return menu;
}

NSMenuItem *SBMenuItemWithTag(NSInteger tag)
{
	NSMenuItem *item = nil;
	for (NSMenuItem *menuItem in [[[NSApplication sharedApplication] mainMenu] itemArray])
	{
		NSMenu *menu = [menuItem submenu];
		item = [menu itemWithTag:tag];
		if (item)
		{
			break;
		}
	}
	return item;
}

#pragma mark Default values

NSRect SBDefaultDocumentWindowRect()
{
	NSRect r = NSZeroRect;
	NSArray *screens = [NSScreen screens];
	NSScreen *screen = [screens count] > 0 ? [screens objectAtIndex:0] : nil;
	r = screen ? [screen visibleFrame] : NSZeroRect;
	return r;
}

// Return value for key in "com.apple.internetconfig.plist"
NSString *SBDefaultHomePage()
{
	id value = nil;
	NSDictionary *internetConfig = nil;
	NSString *path = nil;
	
	path = SBSearchFileInDirectory(@"com.apple.internetconfig", SBLibraryDirectory(@"Preferences"));
	if (path)
	{
		if ([[NSFileManager defaultManager] fileExistsAtPath:path])
		{
			internetConfig = [NSDictionary dictionaryWithContentsOfFile:path];
			if (internetConfig)
			{
				value = SBValueForKey(@"WWWHomePage", internetConfig);
			}
		}
	}
	return value;
}

NSString *SBDefaultSaveDownloadedFilesToPath()
{
	NSString *path = SBSearchPath(NSDownloadsDirectory, nil);
	if (path)
		path = [path stringByExpandingTildeInPath];
	return path;
}

NSDictionary *SBDefaultBookmarks()
{
	NSArray *items = nil;
	NSDictionary *defaultItem = nil;
	NSString *path = [[NSBundle mainBundle] pathForResource:@"DefaultBookmark" ofType:@"plist"];
	if ((defaultItem = [NSDictionary dictionaryWithContentsOfFile:path]))
	{
		NSString *title = nil;
		NSData *imageData = nil;
		NSString *URLString = nil;
		title = [defaultItem objectForKey:kSBBookmarkTitle];
		imageData = [defaultItem objectForKey:kSBBookmarkImage];
		URLString = [defaultItem objectForKey:kSBBookmarkURL];
		if (!title) title = NSLocalizedString(@"Untitled", nil);
		if (!URLString) URLString = @"http://www.example.com/";
		if (!imageData) imageData = SBEmptyBookmarkImageData();
		items = [NSArray arrayWithObject:SBCreateBookmarkItem(title, URLString, imageData, [NSDate date], nil, NSStringFromPoint(NSZeroPoint))];
	}
	return [items count] > 0 ? SBBookmarksWithItems(items) : nil;
}

NSData *SBEmptyBookmarkImageData()
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
	
	size = NSSizeToCGSize(SBBookmarkImageMaxSize());
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
	SBDrawGradientInContext(ctx, count, locations, colors, points);
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
	SBDrawGradientInContext(ctx, count, locations, colors, points);
	CGContextRestoreGState(ctx);
	CGPathRelease(path);
	
	paledImage = [[NSImage imageNamed:@"PaledApplicationIcon"] CGImage];
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
		bitmapImageRep = [[[NSBitmapImageRep alloc] initWithCGImage:image] autorelease];
		CGImageRelease(image);
		data = [bitmapImageRep data];
	}
	return data;
}

#pragma mark Bookmarks

NSDictionary *SBBookmarksWithItems(NSArray *items)
{
	NSDictionary *info = nil;
	info = [NSDictionary dictionaryWithObjectsAndKeys:
			SBBookmarkVersion, kSBBookmarkVersion, 
			items, kSBBookmarkItems, nil];
	return info;
}

NSDictionary *SBCreateBookmarkItem(NSString *title, NSString *url, NSData *imageData, NSDate *date, NSString *labelName, NSString *offsetString)
{
	NSMutableDictionary *item = nil;
	item = [NSMutableDictionary dictionaryWithCapacity:0];
	if (title)
		[item setObject:title forKey:kSBBookmarkTitle];
	if (url)
		[item setObject:url forKey:kSBBookmarkURL];
	if (imageData)
		[item setObject:imageData forKey:kSBBookmarkImage];
	if (date)
		[item setObject:date forKey:kSBBookmarkDate];
	if (labelName)
		[item setObject:labelName forKey:kSBBookmarkLabelName];
	if (offsetString)
		[item setObject:offsetString forKey:kSBBookmarkOffset];
	return [[item copy] autorelease];
}

NSMenu *SBBookmarkLabelColorMenu(BOOL pullsDown, id target, SEL action, id representedObject)
{
	NSMenu *menu = [[[NSMenu alloc] init] autorelease];
	NSInteger i = 0;
	if (pullsDown)
		[menu addItemWithTitle:[NSString string] action:nil keyEquivalent:@""];
	for (i = 0; i < SBBookmarkCountOfLabelColors; i++)
	{
		NSString *labelName = SBBookmarkLabelColorNames[i];
		NSImage *image = [NSImage colorImage:NSMakeSize(24.0, 16.0) colorName:labelName];
		NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:NSLocalizedString(labelName, nil) action:action keyEquivalent:@""] autorelease];
		if (target)
			[item setTarget:target];
		if (representedObject)
			[item setRepresentedObject:representedObject];
		[item setImage:image];
		[menu addItem:item];
	}
	return menu;
}

NSArray *SBBookmarkItemsFromBookmarkDictionaryList(NSArray *bookmarkDictionaryList)
{
	NSMutableArray *items = nil;
	if ([bookmarkDictionaryList count] > 0)
	{
		NSData *emptyImageData = SBEmptyBookmarkImageData();
		items = [NSMutableArray arrayWithCapacity:0];
		for (NSDictionary *dictionary in bookmarkDictionaryList)
		{
			NSString *type = [dictionary objectForKey:@"WebBookmarkType"];
			NSString *URLString = [dictionary objectForKey:@"URLString"];
			NSDictionary *uriDictionary = [dictionary objectForKey:@"URIDictionary"];
			NSString *title = uriDictionary ? [uriDictionary objectForKey:@"title"] : nil;
			BOOL hasScheme = NO;
			if ([type isEqualToString:@"WebBookmarkTypeLeaf"] && [URLString isURLString:&hasScheme])
			{
				NSMutableDictionary *item = [NSMutableDictionary dictionaryWithCapacity:0];
				if (!hasScheme)
				{
					URLString = [@"http://" stringByAppendingString:[URLString stringByDeletingScheme]];
				}
				if (title)
					[item setObject:title forKey:kSBBookmarkTitle];
				if (emptyImageData)
					[item setObject:emptyImageData forKey:kSBBookmarkImage];
				[item setObject:URLString forKey:kSBBookmarkURL];
				[items addObject:[[item copy] autorelease]];
			}
		}
	}
	return [items count] > 0 ? [[items copy] autorelease] : nil;
}

#pragma mark Rects

NSSize SBBookmarkImageMaxSize()
{
	return NSMakeSize(kSBBookmarkCellMaxWidth, kSBBookmarkCellMaxWidth / kSBBookmarkFactorForImageWidth * kSBBookmarkFactorForImageHeight);
}

#pragma mark File paths

NSString *SBFilePathInApplicationBundle(NSString *name, NSString *ext)
{
	NSString *path = nil;
	NSFileManager *manager = nil;
	manager = [NSFileManager defaultManager];
	path = [[NSBundle mainBundle] pathForResource:name ofType:ext];
	if (![manager fileExistsAtPath:path])
	{
		path = nil;
	}
	return path;
}

NSString *SBApplicationSupportDirectory(NSString *subdirectory)
{
	return SBSearchPath(NSApplicationSupportDirectory, subdirectory);
}

NSString *SBLibraryDirectory(NSString *subdirectory)
{
	return SBSearchPath(NSLibraryDirectory, subdirectory);
}

NSString *SBSearchFileInDirectory(NSString *filename, NSString *directoryPath)
{
	NSString *path = nil;
	if (directoryPath)
	{
		NSString *findFileName = nil;
		NSFileManager *manager = [NSFileManager defaultManager];
		NSArray *contents = [manager contentsOfDirectoryAtPath:directoryPath error:nil];
		for (NSString *file in contents)
		{
			if ([file hasPrefix:filename])
			{
				findFileName = file;
				break;
			}
		}
		if (findFileName)
		{
			path = [directoryPath stringByAppendingPathComponent:findFileName];
		}
	}
	return path;
}

NSString *SBSearchPath(NSSearchPathDirectory searchPathDirectory, NSString *subdirectory)
{
	NSString *path = nil;
    NSArray *paths = nil;
	NSFileManager *manager = nil;
	manager = [NSFileManager defaultManager];
	paths = NSSearchPathForDirectoriesInDomains(searchPathDirectory, NSUserDomainMask, YES);
    path = [paths count] > 0 ? [paths objectAtIndex:0] : nil;
	if ([manager fileExistsAtPath:path])
	{
		if (subdirectory)
		{
			path = [path stringByAppendingPathComponent:subdirectory];
			if ([manager fileExistsAtPath:path])
			{
				
			}
			else {
				if ([manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil])
				{
					
				}
				else {
					path = nil;
				}
			}
		}
	}
	else {
		path = nil;
	}
	return path;
}

NSString *SBBookmarksFilePath()
{
	NSString *path = nil;
	NSFileManager *manager = nil;
	manager = [NSFileManager defaultManager];
	path = [SBApplicationSupportDirectory(kSBApplicationSupportDirectoryName) stringByAppendingPathComponent:kSBBookmarksFileName];
	if ([manager fileExistsAtPath:path])
	{
		// Exist current bookmarks
	}
	else {
		NSData *plistData = nil;
		NSString *errorString = nil;
		NSString *version1Path = SBBookmarksVersion1FilePath();
		
		if ([manager fileExistsAtPath:version1Path])
		{
			NSArray *items = nil;
			// Exist version1 bookmarks
			plistData = [[[NSData alloc] initWithContentsOfFile:version1Path] autorelease];
			items = [NSPropertyListSerialization propertyListFromData:plistData mutabilityOption:NSPropertyListImmutable format:nil errorDescription:&errorString];
			if (items)
			{
				plistData = [NSPropertyListSerialization dataFromPropertyList:SBBookmarksWithItems(items) format:NSPropertyListBinaryFormat_v1_0 errorDescription:&errorString];
				if ([plistData writeToFile:path atomically:YES])
				{
					
				}
				else {
					path = nil;
				}
			}
		}
		else {
			// Create default bookmarks
			plistData = [NSPropertyListSerialization dataFromPropertyList:SBDefaultBookmarks() format:NSPropertyListBinaryFormat_v1_0 errorDescription:&errorString];
			if (plistData)
			{
				if ([plistData writeToFile:path atomically:YES])
				{
					
				}
				else {
					path = nil;
				}
			}
			else {
				path = nil;
			}
			DebugLog(@"%s error = %@", __func__, errorString);
		}
	}
	return path;
}

NSString *SBBookmarksVersion1FilePath()
{
	NSString *path = nil;
	NSFileManager *manager = nil;
	manager = [NSFileManager defaultManager];
	path = [SBApplicationSupportDirectory(kSBApplicationSupportDirectoryName_Version1) stringByAppendingPathComponent:kSBBookmarksFileName];
	if ([manager fileExistsAtPath:path])
	{
		// Exist current bookmarks
	}
	return path;
}

NSString *SBHistoryFilePath()
{
	return [SBApplicationSupportDirectory(kSBApplicationSupportDirectoryName) stringByAppendingPathComponent:kSBHistoryFileName];
}

#pragma mark Paths

CGPathRef SBRoundedPath(CGRect rect, CGFloat curve, CGFloat inner, BOOL top, BOOL bottom)
{
	CGPathRef copiedPath = nil;
	CGMutablePathRef path = CGPathCreateMutable();
	CGPoint point, cp1, cp2;
	point = cp1 = cp2 = CGPointZero;
	
	rect.origin.x += inner / 2;
	rect.origin.y += inner / 2;
	rect.size.width -= inner;
	rect.size.height -= inner;
	
	if (top && bottom)
	{
		// Left-top to right
		point.x = (rect.origin.x + curve);
		point.y = rect.origin.y;
		CGPathMoveToPoint(path, nil, point.x,point.y);
		point.x = (rect.origin.x + rect.size.width - curve);
		CGPathAddLineToPoint(path, nil, point.x,point.y);
		point.x = (rect.origin.x + rect.size.width);
		cp1.x = (rect.origin.x + rect.size.width);
		cp1.y = rect.origin.y + curve / 2;
		cp2.x = (rect.origin.x + rect.size.width) - curve / 2;
		cp2.y = rect.origin.y;
		point.y = (rect.origin.y + curve);
		CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,point.x,point.y);
		// Right-top to bottom
		point.y = (rect.origin.y + rect.size.height - curve);
		CGPathAddLineToPoint(path, nil, point.x,point.y);
		point.y = (rect.origin.y + rect.size.height);
		cp1.y = (rect.origin.y + rect.size.height);
		cp1.x = (rect.origin.x + rect.size.width) - curve / 2;
		cp2.y = (rect.origin.y + rect.size.height) - curve / 2;
		cp2.x = (rect.origin.x + rect.size.width);
		point.x = (rect.origin.x + rect.size.width - curve);
		CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,point.x,point.y);
		// Right-bottom to left
		point.x = (rect.origin.x + curve);
		CGPathAddLineToPoint(path, nil, point.x,point.y);
		point.x = rect.origin.x;
		cp1.x = rect.origin.x;
		cp1.y = (rect.origin.y + rect.size.height) - curve / 2;
		cp2.x = rect.origin.x + curve / 2;
		cp2.y = (rect.origin.y + rect.size.height);
		point.y = (rect.origin.y + rect.size.height - curve);
		CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,point.x,point.y);
		// Left-bottom to top
		point.y = (rect.origin.y + curve);
		CGPathAddLineToPoint(path, nil, point.x,point.y);
		point.y = rect.origin.y;
		cp1.y = rect.origin.y;
		cp1.x = rect.origin.x + curve / 2;
		cp2.y = rect.origin.y + curve / 2;
		cp2.x = rect.origin.x;
		point.x = (rect.origin.x + curve);
		CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,point.x,point.y);
		// add left edge and close 
		CGPathCloseSubpath(path);
	}
	else if (top)
	{
		point = rect.origin;
		point.x = rect.origin.x + rect.size.width;
		CGPathMoveToPoint(path, nil, point.x,point.y);
		
		point.y = (rect.origin.y + rect.size.height - curve);
		CGPathAddLineToPoint(path, nil, point.x,point.y);
		point.y = (rect.origin.y + rect.size.height);
		cp1.y = (rect.origin.y + rect.size.height);
		cp1.x = (rect.origin.x + rect.size.width) - curve / 2;
		cp2.y = (rect.origin.y + rect.size.height) - curve / 2;
		cp2.x = (rect.origin.x + rect.size.width);
		point.x = (rect.origin.x + rect.size.width - curve);
		CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,point.x,point.y);
		
		point.x = (rect.origin.x + curve);
		CGPathAddLineToPoint(path, nil, point.x,point.y);
		point.x = rect.origin.x;
		cp1.x = rect.origin.x;
		cp1.y = (rect.origin.y + rect.size.height) - curve / 2;
		cp2.x = rect.origin.x + curve / 2;
		cp2.y = (rect.origin.y + rect.size.height);
		point.y = (rect.origin.y + rect.size.height - curve);
		CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,point.x,point.y);
		point = rect.origin;
		CGPathAddLineToPoint(path, nil, point.x,point.y);
	}
	else if (bottom)
	{
		point.x = rect.origin.x;
		point.y = (rect.origin.y + rect.size.height);
		CGPathMoveToPoint(path, nil, point.x,point.y);
		
		point.y = rect.origin.y + curve;
		CGPathAddLineToPoint(path, nil, point.x,point.y);
		point.y = rect.origin.y;
		cp1.y = rect.origin.y;
		cp1.x = rect.origin.x + curve / 2;
		cp2.y = rect.origin.y + curve / 2;
		cp2.x = rect.origin.x;
		point.x = (rect.origin.x + curve);
		CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,point.x,point.y);
		point.x = (rect.origin.x + rect.size.width - curve);
		CGPathAddLineToPoint(path, nil, point.x,point.y);
		point.x = (rect.origin.x + rect.size.width);
		cp1.x = (rect.origin.x + rect.size.width);
		cp1.y = rect.origin.y + curve / 2;
		cp2.x = (rect.origin.x + rect.size.width) - curve / 2;
		cp2.y = rect.origin.y;
		point.y = (rect.origin.y + curve);
		CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,point.x,point.y);
		point.y = (rect.origin.y + rect.size.height);
		CGPathAddLineToPoint(path, nil, point.x,point.y);
	}
	else {
		CGPathAddRect(path, nil, rect);
	}
	
	copiedPath = CGPathCreateCopy(path);
	CGPathRelease(path);
	
	return (CGPathRef)[(id)copiedPath autorelease];
}

CGPathRef SBLeftButtonPath(CGSize size)
{
	CGPathRef copiedPath = nil;
	CGMutablePathRef path = CGPathCreateMutable();
	CGPoint p = CGPointZero;
	CGPoint cp1 = CGPointZero;
	CGPoint cp2 = CGPointZero;
	CGFloat curve = 4.0;
	
	p.x = size.width;
	p.y = 0.5;
	CGPathMoveToPoint(path, nil, p.x, p.y);
	p.x = curve + 1.0;
	CGPathAddLineToPoint(path, nil, p.x, p.y);
	p.x = 0.5;
	cp1.x = 0.5;
	cp1.y = 0.5 + curve / 2;
	cp2.x = curve / 2 + 0.5;
	cp2.y = 0.5;
	p.y = curve + 0.5;
	CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
	p.y = size.height - curve - 0.5;
	CGPathAddLineToPoint(path, nil, p.x, p.y);
	p.x = curve + 0.5;
	cp2.x = 0.5;
	cp2.y = size.height - curve / 2 - 0.5;
	cp1.x = curve / 2 + 0.5;
	cp1.y = size.height - 0.5;
	p.y = size.height - 0.5;
	CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
	p.x = size.width;
	CGPathAddLineToPoint(path, nil, p.x, p.y);
	p.y = 0.5;
	CGPathAddLineToPoint(path, nil, p.x, p.y);
	
	copiedPath = CGPathCreateCopy(path);
	CGPathRelease(path);
	
	return (CGPathRef)[(id)copiedPath autorelease];
}

CGPathRef SBCenterButtonPath(CGSize size)
{
	CGPathRef copiedPath = nil;
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddRect(path, nil, CGRectMake(0.5, 0.5, size.width - 1.0, size.height - 1.0));
	
	copiedPath = CGPathCreateCopy(path);
	CGPathRelease(path);
	
	return (CGPathRef)[(id)copiedPath autorelease];
}

CGPathRef SBRightButtonPath(CGSize size)
{
	CGPathRef copiedPath = nil;
	CGMutablePathRef path = CGPathCreateMutable();
	CGPoint p = CGPointZero;
	CGPoint cp1 = CGPointZero;
	CGPoint cp2 = CGPointZero;
	CGFloat curve = 4.0;
	
	p.x = 0.5;
	p.y = 0.5;
	CGPathMoveToPoint(path, nil, p.x, p.y);
	p.x = size.width - curve - 1.0;
	CGPathAddLineToPoint(path, nil, p.x, p.y);
	p.x = size.width - 1.0;
	cp1.x = size.width - 0.5;
	cp1.y = 0.5 + curve / 2;
	cp2.x = size.width - curve / 2 - 1.0;
	cp2.y = 0.5;
	p.y = curve + 0.5;
	CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
	p.y = size.height - curve - 1.0;
	CGPathAddLineToPoint(path, nil, p.x, p.y);
	p.x = size.width - curve - 1.0;
	cp2.x = size.width - 1.0;
	cp2.y = size.height - curve / 2 - 1.0;
	cp1.x = size.width - curve / 2 - 1.0;
	cp1.y = size.height - 0.5;
	p.y = size.height - 0.5;
	CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
	p.x = 0.5;
	CGPathAddLineToPoint(path, nil, p.x, p.y);
	p.y = 0.5;
	CGPathAddLineToPoint(path, nil, p.x, p.y);
	
	copiedPath = CGPathCreateCopy(path);
	CGPathRelease(path);
	
	return (CGPathRef)[(id)copiedPath autorelease];
}

// direction: 0 = left, 1 = top, 2 = right, 3 = bottom
CGPathRef SBTrianglePath(CGRect rect, NSInteger direction)
{
	CGPathRef copiedPath = nil;
	CGMutablePathRef path = CGPathCreateMutable();
	CGPoint p = CGPointZero;
	
	if (direction == 0)	// Left
	{
		p.x = CGRectGetMaxX(rect);
		p.y = CGRectGetMinY(rect);
		CGPathMoveToPoint(path, nil, p.x, p.y);
		p.y = CGRectGetMaxY(rect);
		CGPathAddLineToPoint(path, nil, p.x, p.y);
		p.x = CGRectGetMinX(rect);
		p.y = CGRectGetMidY(rect);
		CGPathAddLineToPoint(path, nil, p.x, p.y);
		p.x = CGRectGetMaxX(rect);
		p.y = CGRectGetMinY(rect);
		CGPathAddLineToPoint(path, nil, p.x, p.y);
	}
	if (direction == 1)	// Top
	{
		p.x = CGRectGetMinX(rect);
		p.y = CGRectGetMaxY(rect);
		CGPathMoveToPoint(path, nil, p.x, p.y);
		p.x = CGRectGetMaxX(rect);
		CGPathAddLineToPoint(path, nil, p.x, p.y);
		p.x = CGRectGetMidX(rect);
		p.y = CGRectGetMinY(rect);
		CGPathAddLineToPoint(path, nil, p.x, p.y);
		p.x = CGRectGetMinX(rect);
		p.y = CGRectGetMaxY(rect);
		CGPathAddLineToPoint(path, nil, p.x, p.y);
	}
	else if (direction == 2)	// Right
	{
		p.x = CGRectGetMinX(rect);
		p.y = CGRectGetMinY(rect);
		CGPathMoveToPoint(path, nil, p.x, p.y);
		p.y = CGRectGetMaxY(rect);
		CGPathAddLineToPoint(path, nil, p.x, p.y);
		p.x = CGRectGetMaxX(rect);
		p.y = CGRectGetMidY(rect);
		CGPathAddLineToPoint(path, nil, p.x, p.y);
		p.x = CGRectGetMinX(rect);
		p.y = CGRectGetMinY(rect);
		CGPathAddLineToPoint(path, nil, p.x, p.y);
	}
	else if (direction == 3)	// Bottom
	{
		p.x = CGRectGetMinX(rect);
		p.y = CGRectGetMinY(rect);
		CGPathMoveToPoint(path, nil, p.x, p.y);
		p.x = CGRectGetMaxX(rect);
		CGPathAddLineToPoint(path, nil, p.x, p.y);
		p.x = CGRectGetMidX(rect);
		p.y = CGRectGetMaxY(rect);
		CGPathAddLineToPoint(path, nil, p.x, p.y);
		p.x = CGRectGetMinX(rect);
		p.y = CGRectGetMinY(rect);
		CGPathAddLineToPoint(path, nil, p.x, p.y);
	}
	
	copiedPath = CGPathCreateCopy(path);
	CGPathRelease(path);
	
	return (CGPathRef)[(id)copiedPath autorelease];
}

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
	SBCGPointApplyTransform3D(&p, &transform);
	CGPathMoveToPoint(path, nil, p.x, p.y);
	p.x = r.origin.x;
	p.y = CGRectGetMidY(r);
	cp1.x = r.origin.x + r.size.width / 4;
	cp1.y = r.origin.y;
	cp2.x = r.origin.x;
	cp2.y = r.origin.y + r.size.height / 4;
	SBCGPointApplyTransform3D(&p, &transform);
	SBCGPointApplyTransform3D(&cp1, &transform);
	SBCGPointApplyTransform3D(&cp2, &transform);
	CGPathAddCurveToPoint(path, nil, cp1.x, cp1.y, cp2.x, cp2.y, p.x, p.y);
	p.x = CGRectGetMidX(r);
	p.y = CGRectGetMaxY(r);
	cp1.x = r.origin.x;
	cp1.y = r.origin.y + r.size.height / 4 * 3;
	cp2.x = r.origin.x + r.size.width / 4;
	cp2.y = CGRectGetMaxY(r);
	SBCGPointApplyTransform3D(&p, &transform);
	SBCGPointApplyTransform3D(&cp1, &transform);
	SBCGPointApplyTransform3D(&cp2, &transform);
	CGPathAddCurveToPoint(path, nil, cp1.x, cp1.y, cp2.x, cp2.y, p.x, p.y);
	p.x = CGRectGetMaxX(r);
	p.y = CGRectGetMidY(r);
	cp1.x = r.origin.x + r.size.width / 4 * 3;
	cp1.y = CGRectGetMaxY(r);
	cp2.x = CGRectGetMaxX(r);
	cp2.y = r.origin.y + r.size.height / 4 * 3;
	SBCGPointApplyTransform3D(&p, &transform);
	SBCGPointApplyTransform3D(&cp1, &transform);
	SBCGPointApplyTransform3D(&cp2, &transform);
	CGPathAddCurveToPoint(path, nil, cp1.x, cp1.y, cp2.x, cp2.y, p.x, p.y);
	p.x = CGRectGetMidX(r);
	p.y = r.origin.y;
	cp1.x = CGRectGetMaxX(r);
	cp1.y = r.origin.y + r.size.height / 4;
	cp2.x = r.origin.x + r.size.width / 4 * 3;
	cp2.y = r.origin.y;
	SBCGPointApplyTransform3D(&p, &transform);
	SBCGPointApplyTransform3D(&cp1, &transform);
	SBCGPointApplyTransform3D(&cp2, &transform);
	CGPathAddCurveToPoint(path, nil, cp1.x, cp1.y, cp2.x, cp2.y, p.x, p.y);
	
	copiedPath = CGPathCreateCopy(path);
	CGPathRelease(path);
	
	return (CGPathRef)[(id)copiedPath autorelease];
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
	SBCGPointApplyTransform3D(&p, &transform);
	CGPathMoveToPoint(path, &t, p.x,p.y);
	p.x = (rect.origin.x + rect.size.width - curve);
	p.y = rect.origin.y;
	SBCGPointApplyTransform3D(&p, &transform);
	CGPathAddLineToPoint(path, &t, p.x,p.y);
	p.x = (rect.origin.x + rect.size.width);
	cp1.x = (rect.origin.x + rect.size.width);
	cp1.y = rect.origin.y + curve / 2;
	cp2.x = (rect.origin.x + rect.size.width) - curve / 2;
	cp2.y = rect.origin.y;
	p.y = (rect.origin.y + curve);
	SBCGPointApplyTransform3D(&p, &transform);
	SBCGPointApplyTransform3D(&cp1, &transform);
	SBCGPointApplyTransform3D(&cp2, &transform);
	CGPathAddCurveToPoint(path, &t, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
	
	p.x = (rect.origin.x + rect.size.width);
	p.y = (rect.origin.y + rect.size.height - curve);
	SBCGPointApplyTransform3D(&p, &transform);
	CGPathAddLineToPoint(path, &t, p.x,p.y);
	p.x = (rect.origin.x + rect.size.width - curve);
	p.y = (rect.origin.y + rect.size.height);
	cp1.y = (rect.origin.y + rect.size.height);
	cp1.x = (rect.origin.x + rect.size.width) - curve / 2;
	cp2.y = (rect.origin.y + rect.size.height) - curve / 2;
	cp2.x = (rect.origin.x + rect.size.width);
	SBCGPointApplyTransform3D(&p, &transform);
	SBCGPointApplyTransform3D(&cp1, &transform);
	SBCGPointApplyTransform3D(&cp2, &transform);
	CGPathAddCurveToPoint(path, &t, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
	
	p.x = (rect.origin.x + curve);
	p.y = (rect.origin.y + rect.size.height);
	SBCGPointApplyTransform3D(&p, &transform);
	CGPathAddLineToPoint(path, &t, p.x,p.y);
	p.x = rect.origin.x;
	cp1.x = rect.origin.x;
	cp1.y = (rect.origin.y + rect.size.height) - curve / 2;
	cp2.x = rect.origin.x + curve / 2;
	cp2.y = (rect.origin.y + rect.size.height);
	p.y = (rect.origin.y + rect.size.height - curve);
	SBCGPointApplyTransform3D(&p, &transform);
	SBCGPointApplyTransform3D(&cp1, &transform);
	SBCGPointApplyTransform3D(&cp2, &transform);
	CGPathAddCurveToPoint(path, &t, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
	
	p.x = rect.origin.x;
	p.y = (rect.origin.y + curve);
	SBCGPointApplyTransform3D(&p, &transform);
	CGPathAddLineToPoint(path, &t, p.x,p.y);
	p.y = rect.origin.y;
	cp1.y = rect.origin.y;
	cp1.x = rect.origin.x + curve / 2;
	cp2.y = rect.origin.y + curve / 2;
	cp2.x = rect.origin.x;
	p.x = (rect.origin.x + curve);
	SBCGPointApplyTransform3D(&p, &transform);
	SBCGPointApplyTransform3D(&cp1, &transform);
	SBCGPointApplyTransform3D(&cp2, &transform);
	CGPathAddCurveToPoint(path, &t, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
	
	CGPathCloseSubpath(path);
	copiedPath = CGPathCreateCopy(path);
	CGPathRelease(path);
	
	return (CGPathRef)[(id)copiedPath autorelease];
}

void SBCGPointApplyTransform3D(CGPoint *p, const CATransform3D *t)
{
	double px = p->x;
	double py = p->y, w;
	w  = px * t->m14 + py * t->m24 + t->m44;
	p->x = (px * t->m11 + py * t->m21 + t->m41) / w;
	p->y = (px * t->m12 + py * t->m22 + t->m42) / w;
}

#pragma mark Drawing

void SBDrawGradientInContext(CGContextRef ctx, NSUInteger count, CGFloat locations[], CGFloat colors[], CGPoint points[])
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

void SBDrawRadialGradientInContext(CGContextRef ctx, NSUInteger count, CGFloat locations[], CGFloat colors[], CGPoint centers[], CGFloat radiuses[])
{
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, count);
	CGContextDrawRadialGradient(ctx, gradient, centers[0], radiuses[0], centers[1], radiuses[1], kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(gradient);
	CGColorSpaceRelease(colorSpace);
}

void SBGetAlternateSelectedLightControlColorComponents(CGFloat colors[4])
{
	NSColor *selectedDarkColor = [[[NSColor alternateSelectedControlColor] blendedColorWithFraction:0.3 ofColor:[NSColor whiteColor]] colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
	[selectedDarkColor getComponents:colors];
}

void SBGetAlternateSelectedControlColorComponents(CGFloat colors[4])
{
	NSColor *selectedColor = [[NSColor alternateSelectedControlColor] colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
	[selectedColor getComponents:colors];
}

void SBGetAlternateSelectedDarkControlColorComponents(CGFloat colors[4])
{
	NSColor *selectedDarkColor = [[[NSColor alternateSelectedControlColor] blendedColorWithFraction:0.3 ofColor:[NSColor blackColor]] colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
	[selectedDarkColor getComponents:colors];
}

#pragma mark Image

CGImageRef SBBackwardIconImage(CGSize size, BOOL enabled, BOOL backing)
{
	CGImageRef image = nil;
	CGContextRef ctx = nil;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGPathRef path = nil;
	CGPathRef tpath = SBTrianglePath(CGRectMake(9.0, 7.0, size.width - 9.0 * 2, size.height - 7.0 * 2), 0);
	NSUInteger count = 2;
	CGFloat locations[count];
	CGFloat colors[count * 4];
	CGPoint points[count];
	CGFloat tgrayScale = enabled ? 0.2 : 0.5;
	
	ctx = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast));
	CGColorSpaceRelease(colorSpace);
	CGContextSaveGState(ctx);
	CGContextTranslateCTM(ctx, 0.0, size.height);
	CGContextScaleCTM(ctx, 1.0, -1.0);
	
	path = SBLeftButtonPath(size);
	
	// Background
	locations[0] = 0.0;
	locations[1] = 1.0;
	colors[0] = colors[1] = colors[2] = backing ? 0.95 : 0.8;
	colors[3] = 1.0;
	colors[4] = colors[5] = colors[6] = backing ? 0.65 : 0.5;
	colors[7] = 1.0;
	points[0] = CGPointZero;
	points[1] = CGPointMake(0.0, size.height);
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, path);
	CGContextClip(ctx);
	SBDrawGradientInContext(ctx, count, locations, colors, points);
	CGContextRestoreGState(ctx);
	
	// Frame
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, path);
	CGContextSetRGBStrokeColor(ctx, 0.2, 0.2, 0.2, 1.0);
	CGContextSetLineWidth(ctx, 0.5);
	CGContextStrokePath(ctx);
	CGContextRestoreGState(ctx);
	
	// Triangle
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, tpath);
	CGContextSetRGBFillColor(ctx, tgrayScale, tgrayScale, tgrayScale, 1.0);
	CGContextSetLineWidth(ctx, 0.5);
	CGContextFillPath(ctx);
	CGContextRestoreGState(ctx);
	
	image = CGBitmapContextCreateImage(ctx);
	CGContextRelease(ctx);
	return (CGImageRef)[(id)image autorelease];
}

CGImageRef SBForwardIconImage(CGSize size, BOOL enabled, BOOL backing)
{
	CGImageRef image = nil;
	CGContextRef ctx = nil;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGPathRef path = nil;
	CGPathRef tpath = SBTrianglePath(CGRectMake(9.0, 7.0, size.width - 9.0 * 2, size.height - 7.0 * 2), 2);
	NSUInteger count = 2;
	CGFloat locations[count];
	CGFloat colors[count * 4];
	CGPoint points[count];
	CGFloat tgrayScale = enabled ? 0.2 : 0.5;
	
	ctx = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast));
	CGColorSpaceRelease(colorSpace);
	CGContextSaveGState(ctx);
	CGContextTranslateCTM(ctx, 0.0, size.height);
	CGContextScaleCTM(ctx, 1.0, -1.0);
	
	path = SBCenterButtonPath(size);
	
	// Background
	locations[0] = 0.0;
	locations[1] = 1.0;
	colors[0] = colors[1] = colors[2] = backing ? 0.95 : 0.8;
	colors[3] = 1.0;
	colors[4] = colors[5] = colors[6] = backing ? 0.65 : 0.5;
	colors[7] = 1.0;
	points[0] = CGPointZero;
	points[1] = CGPointMake(0.0, size.height);
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, path);
	CGContextClip(ctx);
	SBDrawGradientInContext(ctx, count, locations, colors, points);
	CGContextRestoreGState(ctx);
	
	// Frame
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, path);
	CGContextSetRGBStrokeColor(ctx, 0.2, 0.2, 0.2, 1.0);
	CGContextSetLineWidth(ctx, 0.5);
	CGContextStrokePath(ctx);
	CGContextRestoreGState(ctx);
	
	// Triangle
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, tpath);
	CGContextSetRGBFillColor(ctx, tgrayScale, tgrayScale, tgrayScale, 1.0);
	CGContextSetLineWidth(ctx, 0.5);
	CGContextFillPath(ctx);
	CGContextRestoreGState(ctx);
	
	image = CGBitmapContextCreateImage(ctx);
	CGContextRelease(ctx);
	return (CGImageRef)[(id)image autorelease];
}

CGImageRef SBGoIconImage(CGSize size, BOOL enabled, BOOL backing)
{
	CGImageRef image = nil;
	CGContextRef ctx = nil;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGPathRef path = nil;
	CGFloat components1[4];
	CGFloat components2[4];
	NSUInteger count = 2;
	CGFloat locations[count];
	CGFloat colors[count * 4];
	CGPoint points[count];
	
	ctx = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast));
	CGColorSpaceRelease(colorSpace);
	CGContextSaveGState(ctx);
	CGContextTranslateCTM(ctx, 0.0, size.height);
	CGContextScaleCTM(ctx, 1.0, -1.0);
	
	path = SBRightButtonPath(size);
	
	// Background
	if (!backing)
	{
		SBGetAlternateSelectedLightControlColorComponents(components1);
		SBGetAlternateSelectedControlColorComponents(components2);
	}
	else {
		components1[0] = components1[1] = components1[2] = 0.95;
		components2[0] = components2[1] = components2[2] = 0.65;
	}
	locations[0] = 0.0;
	locations[1] = 1.0;
	colors[0] = components1[0];
	colors[1] = components1[1];
	colors[2] = components1[2];
	colors[3] = enabled ? 1.0 : 0.5;
	colors[4] = components2[0];
	colors[5] = components2[1];
	colors[6] = components2[2];
	colors[7] = enabled ? 1.0 : 0.5;
	points[0] = CGPointZero;
	points[1] = CGPointMake(0.0, size.height);
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, path);
	CGContextClip(ctx);
	SBDrawGradientInContext(ctx, count, locations, colors, points);
	CGContextRestoreGState(ctx);
	
	// Frame
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, path);
	CGContextSetRGBStrokeColor(ctx, 0.2, 0.2, 0.2, 1.0);
	CGContextSetLineWidth(ctx, 0.5);
	CGContextStrokePath(ctx);
	CGContextRestoreGState(ctx);
	
	image = CGBitmapContextCreateImage(ctx);
	CGContextRelease(ctx);
	return (CGImageRef)[(id)image autorelease];
}

CGImageRef SBZoomOutIconImage(CGSize size)
{
	CGImageRef image = nil;
	CGContextRef ctx = nil;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	NSGraphicsContext *bctx = nil;
	NSImage *frameImage = [NSImage imageNamed:@"LeftButton"];
	NSImage *iconImage = [NSImage imageNamed:@"ZoomOut"];
	NSRect r = NSZeroRect;
	
	ctx = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast));
	bctx = [NSGraphicsContext graphicsContextWithGraphicsPort:ctx flipped:NO];
	CGColorSpaceRelease(colorSpace);
	
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:bctx];
	
	// Frame
	if (frameImage)
	{
		r.size = [frameImage size];
		r.origin.x = (size.width - r.size.width) / 2;
		r.origin.y = (size.height - r.size.height) / 2;
		[frameImage drawInRect:r fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	}
	
	// Image
	if (iconImage)
	{
		r.size = [iconImage size];
		r.origin.x = (size.width - r.size.width) / 2;
		r.origin.y = (size.height - r.size.height) / 2;
		[iconImage drawInRect:r fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	}
	[NSGraphicsContext restoreGraphicsState];
	
	image = CGBitmapContextCreateImage(ctx);
	CGContextRelease(ctx);
	return (CGImageRef)[(id)image autorelease];
}

CGImageRef SBActualSizeIconImage(CGSize size)
{
	CGImageRef image = nil;
	CGContextRef ctx = nil;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	NSGraphicsContext *bctx = nil;
	NSImage *frameImage = [NSImage imageNamed:@"CenterButton"];
	NSImage *iconImage = [NSImage imageNamed:@"ActualSize"];
	NSRect r = NSZeroRect;
	
	ctx = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast));
	bctx = [NSGraphicsContext graphicsContextWithGraphicsPort:ctx flipped:NO];
	CGColorSpaceRelease(colorSpace);
	
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:bctx];
	
	// Frame
	if (frameImage)
	{
		r.size = [frameImage size];
		r.origin.x = (size.width - r.size.width) / 2;
		r.origin.y = (size.height - r.size.height) / 2;
		[frameImage drawInRect:r fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	}
	
	// Image
	if (iconImage)
	{
		r.size = [iconImage size];
		r.origin.x = (size.width - r.size.width) / 2;
		r.origin.y = (size.height - r.size.height) / 2;
		[NSGraphicsContext saveGraphicsState];
		[NSGraphicsContext setCurrentContext:bctx];
		[iconImage drawInRect:r fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	}
	[NSGraphicsContext restoreGraphicsState];
	
	image = CGBitmapContextCreateImage(ctx);
	CGContextRelease(ctx);
	return (CGImageRef)[(id)image autorelease];
}

CGImageRef SBZoomInIconImage(CGSize size)
{
	CGImageRef image = nil;
	CGContextRef ctx = nil;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	NSGraphicsContext *bctx = nil;
	NSImage *frameImage = [NSImage imageNamed:@"RightButton"];
	NSImage *iconImage = [NSImage imageNamed:@"ZoomIn"];
	NSRect r = NSZeroRect;
	
	ctx = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast));
	bctx = [NSGraphicsContext graphicsContextWithGraphicsPort:ctx flipped:NO];
	CGColorSpaceRelease(colorSpace);
	
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:bctx];
	
	// Frame
	if (frameImage)
	{
		r.size = [frameImage size];
		r.origin.x = (size.width - r.size.width) / 2;
		r.origin.y = (size.height - r.size.height) / 2;
		[frameImage drawInRect:r fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	}
	
	// Image
	if (iconImage)
	{
		r.size = [iconImage size];
		r.origin.x = (size.width - r.size.width) / 2;
		r.origin.y = (size.height - r.size.height) / 2;
		[NSGraphicsContext saveGraphicsState];
		[NSGraphicsContext setCurrentContext:bctx];
		[iconImage drawInRect:r fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	}
	[NSGraphicsContext restoreGraphicsState];
	
	image = CGBitmapContextCreateImage(ctx);
	CGContextRelease(ctx);
	return (CGImageRef)[(id)image autorelease];
}

CGImageRef SBAddIconImage(CGSize size, BOOL backing)
{
	CGImageRef image = nil;
	CGContextRef ctx = nil;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGMutablePathRef path = nil;
	CGPoint p = CGPointZero;
	CGPoint cp1 = CGPointZero;
	CGPoint cp2 = CGPointZero;
	CGFloat curve = 4.0;
	CGFloat margin = 7.0;
	
	ctx = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast));
	CGColorSpaceRelease(colorSpace);
	CGContextSaveGState(ctx);
	CGContextTranslateCTM(ctx, 0.0, size.height);
	CGContextScaleCTM(ctx, 1.0, -1.0);
	
	path = CGPathCreateMutable();
	p.y = 1.0;
	CGPathMoveToPoint(path, nil, p.x, p.y);
	p.x = size.width - curve;
	CGPathAddLineToPoint(path, nil, p.x, p.y);
	p.x = size.width;
	cp1.x = size.width;
	cp1.y = 1.0 + curve / 2;
	cp2.x = size.width - curve / 2;
	cp2.y = 1.0;
	p.y = 1.0 + curve;
	CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
	p.y = size.height;
	CGPathAddLineToPoint(path, nil, p.x, p.y);
	p.x = 0.0;
	CGPathAddLineToPoint(path, nil, p.x, p.y);
	
	if (!backing)
	{
		// Background
		NSUInteger count = 2;
		CGFloat locations[count];
		CGFloat colors[count * 4];
		CGPoint points[count];
		locations[0] = 0.0;
		locations[1] = 1.0;
		colors[0] = colors[1] = colors[2] = 0.6;
		colors[3] = 1.0;
		colors[4] = colors[5] = colors[6] = 0.55;
		colors[7] = 1.0;
		points[0] = CGPointZero;
		points[1] = CGPointMake(0.0, size.height);
		CGContextSaveGState(ctx);
		CGContextAddPath(ctx, path);
		CGContextClip(ctx);
		SBDrawGradientInContext(ctx, count, locations, colors, points);
		CGContextRestoreGState(ctx);
	}
	
	// Frame
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, path);
	CGContextSetRGBStrokeColor(ctx, 0.2, 0.2, 0.2, 1.0);
	CGContextSetLineWidth(ctx, 0.5);
	CGContextStrokePath(ctx);
	CGContextRestoreGState(ctx);
	CGPathRelease(path);
	
	// Cross
	path = CGPathCreateMutable();
	p.x = size.width / 2;
	p.y = margin - 1.0;
	CGPathMoveToPoint(path, nil, p.x, p.y);
	p.y = size.height / 2;
	CGPathAddLineToPoint(path, nil, p.x, p.y);
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, path);
	CGContextSetRGBStrokeColor(ctx, 0.3, 0.3, 0.3, 1.0);
	CGContextSetLineWidth(ctx, 3.0);
	CGContextStrokePath(ctx);
	CGContextRestoreGState(ctx);
	CGPathRelease(path);
	
	path = CGPathCreateMutable();
	p.x = margin - 1.0;
	p.y = size.height / 2 - 1.0;
	CGPathMoveToPoint(path, nil, p.x, p.y);
	p.x = size.width - margin + 1.0;
	CGPathAddLineToPoint(path, nil, p.x, p.y);
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, path);
	CGContextSetRGBStrokeColor(ctx, 0.3, 0.3, 0.3, 1.0);
	CGContextSetLineWidth(ctx, 2.0);
	CGContextStrokePath(ctx);
	CGContextRestoreGState(ctx);
	CGPathRelease(path);
	
	path = CGPathCreateMutable();
	p.x = size.width / 2;
	p.y = size.height / 2;
	CGPathMoveToPoint(path, nil, p.x, p.y);
	p.y = size.height - margin + 1.0;
	CGPathAddLineToPoint(path, nil, p.x, p.y);
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, path);
	CGContextSetRGBStrokeColor(ctx, 0.75, 0.75, 0.75, 1.0);
	CGContextSetLineWidth(ctx, 3.0);
	CGContextStrokePath(ctx);
	CGContextRestoreGState(ctx);
	CGPathRelease(path);
	
	path = CGPathCreateMutable();
	p.x = margin - 1.0;
	p.y = size.height / 2 + 1.0;
	CGPathMoveToPoint(path, nil, p.x, p.y);
	p.x = size.width - margin + 1.0;
	CGPathAddLineToPoint(path, nil, p.x, p.y);
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, path);
	CGContextSetRGBStrokeColor(ctx, 0.75, 0.75, 0.75, 1.0);
	CGContextSetLineWidth(ctx, 2.0);
	CGContextStrokePath(ctx);
	CGContextRestoreGState(ctx);
	CGPathRelease(path);
	
	path = CGPathCreateMutable();
	p.x = size.width / 2;
	p.y = margin;
	CGPathMoveToPoint(path, nil, p.x, p.y);
	p.y = size.height - margin;
	CGPathAddLineToPoint(path, nil, p.x, p.y);
	p.x = margin;
	p.y = size.height / 2;
	CGPathMoveToPoint(path, nil, p.x, p.y);
	p.x = size.width - margin;
	CGPathAddLineToPoint(path, nil, p.x, p.y);
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, path);
	if (backing)
		CGContextSetRGBStrokeColor(ctx, 0.7, 0.7, 0.7, 1.0);
	else
		CGContextSetRGBStrokeColor(ctx, 0.5, 0.5, 0.5, 1.0);
	CGContextSetLineWidth(ctx, 3.0);
	CGContextStrokePath(ctx);
	CGContextRestoreGState(ctx);
	CGPathRelease(path);
	
	image = CGBitmapContextCreateImage(ctx);
	CGContextRelease(ctx);
	return (CGImageRef)[(id)image autorelease];
}

CGImageRef SBCloseIconImage()
{
	CGImageRef image = nil;
	CGContextRef ctx = nil;
	CGSize size = CGSizeMake(17.0, 17.0);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	ctx = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast));
	CGColorSpaceRelease(colorSpace);
	CGContextSaveGState(ctx);
	CGContextTranslateCTM(ctx, 0.0, size.height);
	CGContextScaleCTM(ctx, 1.0, -1.0);
	
	CGFloat side = size.width;
	CGRect r = CGRectMake((size.width - side) / 2, (size.height - side) / 2, side, side);
	CGMutablePathRef xPath = CGPathCreateMutable();
	CGPoint p = CGPointZero;
	CGFloat across = r.size.width;
	CGFloat length = 11.0;
	CGFloat margin = r.origin.x;
	CGFloat lineWidth = 2;
	CGFloat center = margin + across / 2;
	CGFloat grayScaleUp = 1.0;
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
	
	// Close
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, xPath);
	CGContextSetLineWidth(ctx, lineWidth);
	CGContextSetRGBStrokeColor(ctx, grayScaleUp, grayScaleUp, grayScaleUp, 1.0);
	CGContextStrokePath(ctx);
	CGContextRestoreGState(ctx);
	CGPathRelease(xPath);
	
	image = CGBitmapContextCreateImage(ctx);
	CGContextRelease(ctx);
	return (CGImageRef)[(id)image autorelease];
}

CGImageRef SBIconImageWithName(NSString *imageName, SBButtonShape shape, CGSize size)
{
	return SBIconImage([[NSImage imageNamed:imageName] CGImage], shape, size);
}

CGImageRef SBIconImage(CGImageRef iconImage, SBButtonShape shape, CGSize size)
{
	CGImageRef image = nil;
	CGContextRef ctx = nil;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGSize imageSize = CGSizeMake(CGImageGetWidth(iconImage), CGImageGetHeight(iconImage));
	CGRect imageRect = CGRectMake((size.width - imageSize.width) / 2, (size.height - imageSize.height) / 2, imageSize.width, imageSize.height);
	
	ctx = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast));
	CGColorSpaceRelease(colorSpace);
	CGContextSaveGState(ctx);
	CGContextTranslateCTM(ctx, 0.0, size.height);
	CGContextScaleCTM(ctx, 1.0, -1.0);
	
	// Frame
	{
		CGMutablePathRef path = nil;
		CGRect insetRect = CGRectZero;
		CGColorRef shadowColor = nil;
		CGFloat insetMargin = 3.0;
		CGFloat lineWidth = 2.0;
		path = CGPathCreateMutable();
		insetRect = CGRectMake(0.0, 0.0, size.width, size.height);
		switch (shape)
		{
			case SBButtonExclusiveShape:
				insetMargin = 4.0;
				insetRect = CGRectInset(insetRect, insetMargin, insetMargin);
				CGPathAddEllipseInRect(path, nil, insetRect);
				break;
			case SBButtonLeftShape:
			{
				CGPoint p = CGPointZero;
				CGPoint cp1 = CGPointZero;
				CGPoint cp2 = CGPointZero;
				CGFloat rad = 0;
				
				insetRect.origin.x += insetMargin;
				insetRect.origin.y += insetMargin;
				insetRect.size.width -= insetMargin;
				insetRect.size.height -= insetMargin * 2;
				rad = insetRect.size.height / 2;
				
				p.x = CGRectGetMaxX(insetRect) + lineWidth / 4;
				p.y = insetRect.origin.y;
				CGPathMoveToPoint(path, nil, p.x, p.y);
				p.x = insetRect.origin.x + rad;
				CGPathAddLineToPoint(path, nil, p.x, p.y);
				
				p.x = insetRect.origin.x;
				cp1.x = insetRect.origin.x;
				cp1.y = insetRect.origin.y + rad / 2;
				cp2.x = insetRect.origin.x + rad / 2;
				cp2.y = insetRect.origin.y;
				p.y = insetRect.origin.y + rad;
				CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
				
				p.x = insetRect.origin.x + rad;
				cp2.x = insetRect.origin.x;
				cp2.y = CGRectGetMaxY(insetRect) - rad / 2;
				cp1.x = insetRect.origin.x + rad / 2;
				cp1.y = CGRectGetMaxY(insetRect);
				p.y = CGRectGetMaxY(insetRect);
				CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
				
				p.x = CGRectGetMaxX(insetRect) + lineWidth / 4;
				CGPathAddLineToPoint(path, nil, p.x, p.y);
				
				CGPathCloseSubpath(path);
				
				imageRect.origin.x += insetMargin;
				break;
			}
			case SBButtonCenterShape:
			{
				insetRect.origin.y += insetMargin;
				insetRect.size.height -= insetMargin * 2;
				CGPathAddRect(path, nil, insetRect);
				break;
			}
			case SBButtonRightShape:
			{
				CGPoint p = CGPointZero;
				CGPoint cp1 = CGPointZero;
				CGPoint cp2 = CGPointZero;
				CGFloat rad = 0;
				
				insetRect.origin.y += insetMargin;
				insetRect.size.width -= insetMargin;
				insetRect.size.height -= insetMargin * 2;
				rad = insetRect.size.height / 2;
				
				p.x = insetRect.origin.x - lineWidth / 4;
				p.y = insetRect.origin.y;
				CGPathMoveToPoint(path, nil, p.x, p.y);
				p.x = CGRectGetMaxX(insetRect) - rad;
				CGPathAddLineToPoint(path, nil, p.x, p.y);
				
				p.x = CGRectGetMaxX(insetRect);
				cp1.x = CGRectGetMaxX(insetRect);
				cp1.y = CGRectGetMinY(insetRect) + rad / 2;
				cp2.x = CGRectGetMaxX(insetRect) - rad / 2;
				cp2.y = CGRectGetMinY(insetRect);
				p.y = CGRectGetMinY(insetRect) + rad;
				CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
				
				p.x = CGRectGetMaxX(insetRect) - rad;
				cp2.x = CGRectGetMaxX(insetRect);
				cp2.y = CGRectGetMaxY(insetRect) - rad / 2;
				cp1.x = CGRectGetMaxX(insetRect) - rad / 2;
				cp1.y = CGRectGetMaxY(insetRect);
				p.y = CGRectGetMaxY(insetRect);
				CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
				
				p.x = insetRect.origin.x - lineWidth / 4;
				CGPathAddLineToPoint(path, nil, p.x, p.y);
				
				CGPathCloseSubpath(path);
				
				imageRect.origin.x -= insetMargin / 2;
				break;
			}
		}
		shadowColor = CGColorCreateGenericGray(0.0, 1.0);
		
		// Fill
		CGContextSaveGState(ctx);
		CGContextAddPath(ctx, path);
		CGContextSetShadowWithColor(ctx, CGSizeZero, insetMargin, shadowColor);
		CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 1.0);
		CGContextFillPath(ctx);
		CGContextRestoreGState(ctx);
		CGColorRelease(shadowColor);
		
		// Stroke
		CGContextSaveGState(ctx);
		CGContextAddPath(ctx, path);
		CGContextSetLineWidth(ctx, lineWidth);
		CGContextSetRGBStrokeColor(ctx, 0.9, 0.9, 0.9, 1.0);
		CGContextStrokePath(ctx);
		CGContextRestoreGState(ctx);
		CGPathRelease(path);
	}
	
	// Icon
	if (iconImage)
	{
		CGContextSaveGState(ctx);
		CGContextTranslateCTM(ctx, 0.0, size.height);
		CGContextScaleCTM(ctx, 1.0, -1.0);
		CGContextDrawImage(ctx, imageRect, iconImage);
		CGContextRestoreGState(ctx);
	}
	
	CGContextRestoreGState(ctx);
	image = CGBitmapContextCreateImage(ctx);
	CGContextRelease(ctx);
	return (CGImageRef)[(id)image autorelease];
}

CGImageRef SBFindBackwardIconImage(CGSize size, BOOL enabled)
{
	CGImageRef image = nil;
	CGContextRef ctx = nil;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGMutablePathRef path = nil;
	CGPathRef tpath = SBTrianglePath(CGRectMake(9.0, 5.0, size.width - 9.0 * 2, size.height - 5.0 * 2), 0);
	CGPoint p = CGPointZero;
	CGPoint cp1 = CGPointZero;
	CGPoint cp2 = CGPointZero;
	CGFloat curve = size.height / 2;
	NSUInteger count = 2;
	CGFloat locations[count];
	CGFloat colors[count * 4];
	CGPoint points[count];
	CGFloat tgrayScale = enabled ? 0.9 : 0.5;
	
	ctx = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast));
	CGColorSpaceRelease(colorSpace);
	CGContextSaveGState(ctx);
	CGContextTranslateCTM(ctx, 0.0, size.height);
	CGContextScaleCTM(ctx, 1.0, -1.0);
	
	path = CGPathCreateMutable();
	p.x = size.width;
	p.y = 0.5;
	CGPathMoveToPoint(path, nil, p.x, p.y);
	p.x = curve + 1.0;
	CGPathAddLineToPoint(path, nil, p.x, p.y);
	p.x = 0.5;
	cp1.x = 0.5;
	cp1.y = 0.5 + curve / 2;
	cp2.x = curve / 2 + 0.5;
	cp2.y = 0.5;
	p.y = curve + 0.5;
	CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
	p.x = curve + 0.5;
	cp2.x = 0.5;
	cp2.y = size.height - curve / 2 - 0.5;
	cp1.x = curve / 2 + 0.5;
	cp1.y = size.height - 0.5;
	p.y = size.height - 0.5;
	CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
	p.x = size.width;
	CGPathAddLineToPoint(path, nil, p.x, p.y);
	p.y = 0.5;
	CGPathAddLineToPoint(path, nil, p.x, p.y);
	
	// Background
	locations[0] = 0.0;
	locations[1] = 1.0;
	colors[0] = colors[1] = colors[2] = 0.5;
	colors[3] = 1.0;
	colors[4] = colors[5] = colors[6] = 0.0;
	colors[7] = 1.0;
	points[0] = CGPointZero;
	points[1] = CGPointMake(0.0, size.height);
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, path);
	CGContextClip(ctx);
	SBDrawGradientInContext(ctx, count, locations, colors, points);
	CGContextRestoreGState(ctx);
	
	// Frame
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, path);
	CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 0.0, 1.0);
	CGContextSetLineWidth(ctx, 0.5);
	CGContextStrokePath(ctx);
	CGContextRestoreGState(ctx);
	CGPathRelease(path);
	
	// Triangle
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, tpath);
	CGContextSetRGBFillColor(ctx, tgrayScale, tgrayScale, tgrayScale, 1.0);
	CGContextSetLineWidth(ctx, 0.5);
	CGContextFillPath(ctx);
	CGContextRestoreGState(ctx);
	
	image = CGBitmapContextCreateImage(ctx);
	CGContextRelease(ctx);
	return (CGImageRef)[(id)image autorelease];
}

CGImageRef SBFindForwardIconImage(CGSize size, BOOL enabled)
{
	CGImageRef image = nil;
	CGContextRef ctx = nil;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGMutablePathRef path = nil;
	CGPathRef tpath = SBTrianglePath(CGRectMake(9.0, 5.0, size.width - 9.0 * 2, size.height - 5.0 * 2), 2);
	CGPoint p = CGPointZero;
	CGPoint cp1 = CGPointZero;
	CGPoint cp2 = CGPointZero;
	CGFloat curve = size.height / 2;
	NSUInteger count = 2;
	CGFloat locations[count];
	CGFloat colors[count * 4];
	CGPoint points[count];
	CGFloat tgrayScale = enabled ? 0.9 : 0.5;
	
	ctx = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast));
	CGColorSpaceRelease(colorSpace);
	CGContextSaveGState(ctx);
	CGContextTranslateCTM(ctx, 0.0, size.height);
	CGContextScaleCTM(ctx, 1.0, -1.0);
	
	path = CGPathCreateMutable();
	p.x = 0.0;
	p.y = 0.5;
	CGPathMoveToPoint(path, nil, p.x, p.y);
	p.x = size.width - (curve + 1.0);
	CGPathAddLineToPoint(path, nil, p.x, p.y);
	p.x = size.width;
	cp1.x = size.width;
	cp1.y = 0.5 + curve / 2;
	cp2.x = size.width - curve / 2;
	cp2.y = 0.5;
	p.y = curve + 0.5;
	CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
	p.x = size.width - curve;
	cp2.x = size.width;
	cp2.y = size.height - curve / 2 - 0.5;
	cp1.x = size.width - curve / 2;
	cp1.y = size.height - 0.5;
	p.y = size.height - 0.5;
	CGPathAddCurveToPoint(path, nil, cp2.x,cp2.y,cp1.x,cp1.y,p.x,p.y);
	p.x = 0.0;
	CGPathAddLineToPoint(path, nil, p.x, p.y);
	p.y = 0.5;
	CGPathAddLineToPoint(path, nil, p.x, p.y);
	
	// Background
	locations[0] = 0.0;
	locations[1] = 1.0;
	colors[0] = colors[1] = colors[2] = 0.5;
	colors[3] = 1.0;
	colors[4] = colors[5] = colors[6] = 0.0;
	colors[7] = 1.0;
	points[0] = CGPointZero;
	points[1] = CGPointMake(0.0, size.height);
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, path);
	CGContextClip(ctx);
	SBDrawGradientInContext(ctx, count, locations, colors, points);
	CGContextRestoreGState(ctx);
	
	// Frame
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, path);
	CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 0.0, 1.0);
	CGContextSetLineWidth(ctx, 0.5);
	CGContextStrokePath(ctx);
	CGContextRestoreGState(ctx);
	CGPathRelease(path);
	
	// Triangle
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, tpath);
	CGContextSetRGBFillColor(ctx, tgrayScale, tgrayScale, tgrayScale, 1.0);
	CGContextSetLineWidth(ctx, 0.5);
	CGContextFillPath(ctx);
	CGContextRestoreGState(ctx);
	
	image = CGBitmapContextCreateImage(ctx);
	CGContextRelease(ctx);
	return (CGImageRef)[(id)image autorelease];
}

CGImageRef SBBookmarkReflectionMaskImage(CGSize size)
{
	CGImageRef maskImage = nil;
	CGContextRef ctx = nil;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	NSUInteger count = 2;
	CGFloat locations[count];
	CGFloat colors[count * 4];
	CGPoint points[count];
	ctx = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast));
	CGColorSpaceRelease(colorSpace);
	locations[0] = 0.0;
	locations[1] = 1.0;
	colors[0] = colors[1] = colors[2] = 1.0;
	colors[3] = 0.2;
	colors[4] = colors[5] = colors[6] = 1.0;
	colors[7] = 0.0;
	points[0] = CGPointZero;
	points[1] = CGPointMake(0.0, size.height);
	CGContextSaveGState(ctx);
	CGContextAddRect(ctx, CGRectMake(0, 0, size.width, size.height));
	CGContextClip(ctx);
	SBDrawGradientInContext(ctx, count, locations, colors, points);
	CGContextRestoreGState(ctx);
	maskImage = CGBitmapContextCreateImage(ctx);
	CGContextRelease(ctx);
	return (CGImageRef)[(id)maskImage autorelease];
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
	
	value = [dictionary objectForKey:keyName];
	if (value == nil) {
		int i;
		for (i = 0; i < [[dictionary allValues] count]; i++)
		{
			id object = nil;
			object = [[dictionary allValues] objectAtIndex:i];
			if ([object isKindOfClass:[NSDictionary class]]) {
				value = SBValueForKey(keyName, object);
			}
		}
	}
	else if ([value isKindOfClass:[NSDictionary class]])
	{
		value = [[value allValues] objectAtIndex:0];
	}
	return value;
}

NSMenu *SBEncodingMenu(id target, SEL selector, BOOL showDefault)
{
	NSMenu *menu = [[[NSMenu alloc] init] autorelease];
	NSArray *encs = nil;
	NSMutableArray *mencs = [NSMutableArray arrayWithCapacity:0];
#if kSBFlagShowAllStringEncodings
    const NSStringEncoding *encoding = [NSString availableStringEncodings];
	NSData *hint = nil;
	
	// Get available encodings
    while (*encoding)
	{
		[mencs addObject:[NSNumber numberWithUnsignedInteger:*encoding]];
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
		[mencs addObject:[NSNumber numberWithUnsignedInteger:*encoding]];
		encoding++;
	}
	encs = [[mencs copy] autorelease];
#endif
	
	// Create menu items
	for (NSNumber *enc in encs)
	{
		NSStringEncoding stringEncoding = [enc unsignedIntegerValue];
		if (stringEncoding == NSNotFound)
		{
			[menu addItem:[NSMenuItem separatorItem]];
		}
		else {
			NSString *encodingName = nil;
			NSString *ianaName = nil;
			encodingName = [NSString localizedNameOfStringEncoding:stringEncoding];
			ianaName = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding([enc unsignedIntegerValue]));
			DebugLog(@"%d\t%d\t%@\t%@\t%@", CFStringIsEncodingAvailable(CFStringConvertNSStringEncodingToEncoding([enc unsignedIntegerValue])), stringEncoding, encodingName, (NSString *)CFStringGetNameOfEncoding(CFStringConvertNSStringEncodingToEncoding([enc unsignedIntegerValue])), ianaName);
			if (encodingName)
			{
				NSMenuItem *item = nil;
				item = [[[NSMenuItem alloc] initWithTitle:encodingName action:selector keyEquivalent:@""] autorelease];
				if (target)
					[item setTarget:target];
				[item setRepresentedObject:ianaName];
				[menu addItem:item];
			}
		}
	}
	if (showDefault)
	{
		NSMenuItem *defaultItem = nil;
		defaultItem = [[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Default", nil) action:selector keyEquivalent:@""] autorelease];
		if (target)
			[defaultItem setTarget:target];
		[defaultItem setRepresentedObject:nil];
		[menu insertItem:[NSMenuItem separatorItem] atIndex:0];
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

void SBRunAlertWithMessage(NSString *message)
{
	NSRunAlertPanel(NSLocalizedString(@"Error", nil), message, NSLocalizedString(@"OK", nil), nil, nil);
}

void SBDisembedViewInSplitView(NSView *view, NSSplitView *splitView)
{
	NSRect r = splitView.frame;
	id superview = [splitView superview];
	if (superview)
	{
		view.frame = r;
		[view removeFromSuperview];
		[superview addSubview:view];
		[splitView removeFromSuperview];
	}
}

CGFloat SBDistancePoints(NSPoint p1, NSPoint p2)
{
	return sqrtf((p2.x - p1.x) * (p2.x - p1.x) + (p2.y - p1.y) * (p2.y - p1.y));
}

BOOL SBAllowsDrag(NSPoint downPoint, NSPoint dragPoint)
{
	return SBDistancePoints(downPoint, dragPoint) > 10;
}

void SBLocalizeTitlesInMenu(NSMenu *menu)
{
	NSString *mtitle = [menu title];
	NSString *mlocalizedTitle = NSLocalizedString(mtitle, nil);
	if (![mtitle isEqualToString:mlocalizedTitle])
	{
		[menu setTitle:mlocalizedTitle];
	}
	for (NSMenuItem *item in [menu itemArray])
	{
		NSMenu *submenu = [item submenu];
		NSString *title = [item title];
		NSString *localizedTitle = NSLocalizedString(title, nil);
		if (![title isEqualToString:localizedTitle])
		{
			[item setTitle:localizedTitle];
		}
		if (submenu)
		{
			SBLocalizeTitlesInMenu(submenu);
		}
	}
}

void SBGetLocalizableTextSet(NSString *path, NSMutableArray **tSet, NSArray **fSet, NSSize *viewSize)
{
	NSMutableArray *textSet = nil;
	NSMutableArray *fieldSet = nil;
	NSSize size = NSZeroSize;
	NSError *error = nil;
	NSString *localizableString = nil;
	
	localizableString = [NSString stringWithContentsOfFile:path encoding:NSUTF16StringEncoding error:&error];
	
	if ([localizableString length] > 0)
	{
		NSSize fieldSize = NSMakeSize(300, 22);
		NSPoint offset = NSMakePoint(45, 12);
		CGFloat margin = 20;
		NSArray *lines = [localizableString componentsSeparatedByString:@"\n"];
		NSInteger count = [lines count];
		
		size.width = offset.x + fieldSize.width * 2 + margin * 2;
		size.height = (fieldSize.height + offset.y) * count + offset.y + margin * 2;
		
		if (count > 1)
		{
			NSInteger i = 0;
			textSet = [NSMutableArray arrayWithCapacity:0];
			fieldSet = [NSMutableArray arrayWithCapacity:0];
			for (NSString *line in lines)
			{
				NSInteger j = 0;
				NSRect fieldRect = NSZeroRect;
				NSMutableArray *texts = [NSMutableArray arrayWithCapacity:0];
				NSMutableArray *fields = [NSMutableArray arrayWithCapacity:0];
				NSArray *components = [line componentsSeparatedByString:@" = "];
				
				fieldRect.size = fieldSize;
				fieldRect.origin.y = size.height - margin - (fieldSize.height * (i + 1)) - (offset.y * i);
				
				for (NSString *component in components)
				{
					if ([component length] > 0)
					{
						NSTextField *field = nil;
						BOOL isMenuitem = ![component hasPrefix:@"//"];
						BOOL editable = isMenuitem && j == 1;
						NSString *string = component;
						fieldRect.origin.x = j * (fieldSize.width + offset.x);
						field = [[[NSTextField alloc] initWithFrame:fieldRect] autorelease];
						[field setEditable:editable];
						[field setSelectable:isMenuitem];
						[field setBordered:isMenuitem];
						[field setDrawsBackground:isMenuitem];
						[field setBezeled:editable];
						[[field cell] setScrollable:isMenuitem];
						if (isMenuitem)
						{
							string = [component stringByDeletingQuotations];
						}
						[texts addObject:string];
						[fields addObject:field];
					}
					j++;
				}
				if ([texts count] >= 1)
				{
					[textSet addObject:texts];
				}
				if ([fields count] >= 1)
				{
					[fieldSet addObject:fields];
				}
				i++;
			}
			*viewSize = size;
			*tSet = textSet;
			*fSet = [[fieldSet copy] autorelease];
		}
	}
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
			field0 = [fields objectAtIndex:0];
			text0 = field0 ? [field0 stringValue] : nil;
			if (text0)
			{
				[string appendFormat:@"\n%@\n", text0];
			}
		}
		else if ([fields count] == 2)
		{
			field0 = [fields objectAtIndex:0];
			field1 = [fields objectAtIndex:1];
			text0 = field0 ? [field0 stringValue] : nil;
			text1 = field1 ? [field1 stringValue] : nil;
			if (text0 && text1)
			{
				[string appendFormat:@"\"%@\" = \"%@\";\n", text0, text1];
			}
		}
	}
	if ([string length] > 0)
	{
		data = [[[string copy] autorelease] dataUsingEncoding:NSUTF16StringEncoding];
	}
	return data;
}

#pragma mark Debug

NSDictionary *SBDebugViewStructure(NSView *view)
{
	NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:0];
	NSArray *subviews = [view subviews];
	NSString *description = nil;
	NSUInteger count = [subviews count];
	if ([view isKindOfClass:[SBView class]])
		description = [view description];
	else
		description = [NSString stringWithFormat:@"%@ %@", view, NSStringFromRect([view frame])];
	[info setObject:description forKey:@"Description"];
	if (count > 0)
	{
		NSMutableArray *childs = [NSMutableArray arrayWithCapacity:0];
		for (NSUInteger i = 0; i < count; i++)
		{
			id subview = [subviews objectAtIndex:i];
			[childs addObject:SBDebugViewStructure(subview)];
		}
		[info setObject:[[childs copy] autorelease] forKey:@"Children"];
	}
	return [[info copy] autorelease];
}

NSDictionary *SBDebugLayerStructure(CALayer *layer)
{
	NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:0];
	NSArray *sublayers = [layer sublayers];
	NSString *description = nil;
	NSUInteger count = [sublayers count];
	description = [NSString stringWithFormat:@"%@ %@", layer, NSStringFromRect(NSRectFromCGRect([layer frame]))];
	[info setObject:description forKey:@"Description"];
	if (count > 0)
	{
		NSMutableArray *childs = [NSMutableArray arrayWithCapacity:0];
		for (NSUInteger i = 0; i < count; i++)
		{
			id sublayer = [sublayers objectAtIndex:i];
			[childs addObject:SBDebugLayerStructure(sublayer)];
		}
		[info setObject:[[childs copy] autorelease] forKey:@"Children"];
	}
	return [[info copy] autorelease];
}

NSDictionary *SBDebugDumpMainMenu()
{
	NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:0];
	NSArray *items = SBDebugDumpMenu([[NSApplication sharedApplication] mainMenu]);
	[info setObject:items forKey:@"MenuItems"];
	return [[info copy] autorelease];
}

NSArray *SBDebugDumpMenu(NSMenu *menu)
{
	NSMutableArray *items = [NSMutableArray arrayWithCapacity:0];
	for (NSMenuItem *item in [menu itemArray])
	{
		NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:0];
		NSMenu *submenu = [item submenu];
		NSString *title = [item title];
		id target = [item target];
		SEL action = [item action];
		NSInteger tag = [item tag];
		NSInteger state = [item state];
		NSImage *image = [item image];
		NSString *keyEquivalent = [item keyEquivalent];
		NSUInteger keyEquivalentModifierMask = [item keyEquivalentModifierMask];
		NSString *toolTip = [item toolTip];
		if (title)
			[info setObject:title forKey:@"Title"];
		if (target)
			[info setObject:[NSString stringWithFormat:@"%@", target] forKey:@"Target"];
		if (action)
			[info setObject:NSStringFromSelector(action) forKey:@"Action"];
		[info setObject:[NSNumber numberWithInteger:tag] forKey:@"Tag"];
		[info setObject:[NSNumber numberWithInteger:state] forKey:@"State"];
		if (image)
			[info setObject:[image TIFFRepresentation] forKey:@"Image"];
		if (keyEquivalent)
			[info setObject:keyEquivalent forKey:@"KeyEquivalent"];
		[info setObject:[NSNumber numberWithUnsignedInteger:keyEquivalentModifierMask] forKey:@"KeyEquivalentModifierMask"];
		if (toolTip)
			[info setObject:toolTip forKey:@"ToolTip"];
		if (submenu)
		{
			[info setObject:SBDebugDumpMenu(submenu) forKey:@"MenuItems"];
		}
		[items addObject:[[info copy] autorelease]];
	}
	return [[items copy] autorelease];
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
