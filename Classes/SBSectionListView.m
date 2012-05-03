/*

SBSectionListView.m
 
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

#import "SBSectionListView.h"
#import "SBBLKGUI.h"
#import "SBPreferences.h"
#import "SBSavePanel.h"
#import "SBSectionGroupe.h"
#import "SBUtil.h"

#define kSBSectionTitleHeight 32.0
#define kSBSectionItemHeight 32.0
#define kSBSectionMarginX 10.0
#define kSBSectionTopMargin 10.0
#define kSBSectionBottomMargin 20.0
#define kSBSectionMarginY kSBSectionTopMargin + kSBSectionBottomMargin
#define kSBSectionInnerMarginX 15.0

@implementation SBSectionListView

@synthesize sectionGroupeViews;
@synthesize sections;

- (id)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		sectionGroupeViews = [[NSMutableArray alloc] initWithCapacity:0];
		[self constructScrollView];
	}
	return self;
}

- (void)dealloc
{
	[sectionGroupeViews release];
	[sections release];
	[self destructScrollView];
	[super dealloc];
}

- (NSRect)contentViewRect
{
	NSRect r = NSZeroRect;
	NSInteger i = 0;
	r.size.width = self.bounds.size.width - 20.0;
	for (SBSectionGroupe *groupe in sections)
	{
		r.size.height += [groupe.items count] * kSBSectionItemHeight + kSBSectionTitleHeight + kSBSectionMarginY;
		i++;
	}
	return r;
}

- (NSRect)groupeViewRectAtIndex:(NSInteger)index
{
	NSRect r = NSZeroRect;
	NSInteger i = 0;
	CGFloat height = [self contentViewRect].size.height;
	r.size.width = self.bounds.size.width - 20.0;
	for (SBSectionGroupe *groupe in sections)
	{
		CGFloat h = [groupe.items count] * kSBSectionItemHeight + kSBSectionTitleHeight + kSBSectionMarginY;
		if (i < index)
		{
			r.origin.y += h;
		}
		else {
			r.size.height = h;
			break;
		}
		i++;
	}
	r.origin.y = height - NSMaxY(r);
	return r;
}

- (void)destructScrollView
{
	if (contentView)
	{
		[contentView removeFromSuperview];
		[contentView release];
		contentView = nil;
	}
	if (scrollView)
	{
		[scrollView removeFromSuperview];
		[scrollView release];
		scrollView = nil;
	}
}

- (void)constructScrollView
{
	SBBLKGUIClipView *clipView = nil;
	[self destructScrollView];
	scrollView = [[NSScrollView alloc] initWithFrame:self.bounds];
	clipView = [[[SBBLKGUIClipView alloc] initWithFrame:self.bounds] autorelease];
	contentView = [[NSView alloc] initWithFrame:self.bounds];
	[scrollView setContentView:clipView];
	[scrollView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
	[scrollView setDrawsBackground:NO];
	[scrollView setHasHorizontalScroller:NO];
	[scrollView setHasVerticalScroller:YES];
	[scrollView setDocumentView:contentView];
	[scrollView setAutohidesScrollers:YES];
	[self addSubview:scrollView];
}

- (void)constructSectionGroupeViews
{
	NSInteger index = 0;
	for (SBSectionGroupeView *sectionView in sectionGroupeViews)
		[sectionView removeFromSuperview];
	[sectionGroupeViews removeAllObjects];
	for (SBSectionGroupe *groupe in sections)
	{
		SBSectionGroupeView *groupeView = nil;
		NSRect gr = [self groupeViewRectAtIndex:index];
		groupeView = [[[SBSectionGroupeView alloc] initWithFrame:gr] autorelease];
		groupeView.groupe = groupe;
		[groupeView setAutoresizingMask:(NSViewWidthSizable)];
		for (SBSectionItem *item in groupe.items)
		{
			SBSectionItemView *itemView = nil;
			itemView = [[[SBSectionItemView alloc] initWithItem:item] autorelease];
			[itemView setAutoresizingMask:(NSViewWidthSizable)];
			[groupeView addItemView:itemView];
		}
		[contentView addSubview:groupeView];
		index++;
	}
}

- (void)setSections:(NSMutableArray *)inSections
{
	if (sections != inSections)
	{
		[inSections retain];
		[sections release];
		sections = inSections;
		contentView.frame = [self contentViewRect];
		[contentView scrollRectToVisible:NSMakeRect(0, NSMaxY(contentView.frame), 0, 0)];
		[self constructSectionGroupeViews];
	}
}

@end

@implementation SBSectionGroupeView

@synthesize itemViews;
@synthesize groupe;

- (id)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		itemViews = [[NSMutableArray alloc] initWithCapacity:0];
	}
	return self;
}

- (void)dealloc
{
	[itemViews release];
	[groupe release];
	[super dealloc];
}

- (NSRect)itemViewRectAtIndex:(NSInteger)index
{
	NSRect r = NSZeroRect;
	r.size.width = self.bounds.size.width - kSBSectionMarginX * 2;
	r.size.height = kSBSectionItemHeight;
	r.origin.x = kSBSectionMarginX;
	r.origin.y = index * kSBSectionItemHeight + kSBSectionTitleHeight + kSBSectionTopMargin;
	r.origin.y = self.bounds.size.height - NSMaxY(r);
	return r;
}

- (void)addItemView:(SBSectionItemView *)itemView
{
	itemView.frame = [self itemViewRectAtIndex:[itemViews count]];
	[itemView constructControl];
	[itemViews addObject:itemView];
	[self addSubview:itemView];
}

- (void)drawRect:(NSRect)rect
{
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
	CGRect r = CGRectZero;
	NSRect tr = NSZeroRect;
	CGPathRef path = nil;
	CGColorRef shadowColor = nil;
	CGPathRef strokePath = nil;
	NSUInteger count = 2;
	CGFloat locations[count];
	CGFloat colors[count * 4];
	CGFloat storkeColor[4];
	CGPoint points[count];
	NSDictionary *attributes = nil;
	
	r = NSRectToCGRect(self.bounds);
	r.origin.x += kSBSectionMarginX;
	r.origin.y += kSBSectionBottomMargin;
	r.size.width -= kSBSectionMarginX * 2;
	r.size.height -= kSBSectionMarginY;
	
	// Paths
	// Gray scales
	path = SBRoundedPath(CGRectInset(r, 0.0, 0.0), 8.0, 0.0, YES, YES);
	strokePath = SBRoundedPath(CGRectInset(r, 0.5, 0.5), 8.0, 0.0, YES, YES);
	shadowColor = CGColorCreateGenericGray(0.0, 0.5);
	
	// Fill
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, path);
	CGContextSetShadowWithColor(ctx, CGSizeMake(0.0, -2.0), 5.0, shadowColor);
	CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
	CGContextFillPath(ctx);
	CGContextRestoreGState(ctx);
	
	// Gradient
	colors[0] = colors[1] = colors[2] = 0.9;
	colors[3] = 1.0;
	colors[4] = colors[5] = colors[6] = 1.0;
	colors[7] = 1.0;
	storkeColor[0] = storkeColor[1] = storkeColor[2] = 0.2;
	storkeColor[3] = 1.0;
	locations[0] = 0.0;
	locations[1] = 1.0;
	points[0] = CGPointZero;
	points[1] = CGPointMake(0.0, r.size.height);
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, path);
	CGContextSetShadowWithColor(ctx, CGSizeMake(0.0, 10.0), 5.0, shadowColor);
	CGContextClip(ctx);
	SBDrawGradientInContext(ctx, count, locations, colors, points);
	CGContextRestoreGState(ctx);
	CGColorRelease(shadowColor);
	
	// Stroke
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, strokePath);
	CGContextSetLineWidth(ctx, 0.5);
	CGContextSetRGBStrokeColor(ctx, storkeColor[0], storkeColor[1], storkeColor[2], storkeColor[3]);
	CGContextStrokePath(ctx);
	CGContextRestoreGState(ctx);
	
	tr = NSRectFromCGRect(r);
	tr.origin.x += kSBSectionInnerMarginX;
	tr.size.height = 24.0;
	tr.origin.y += r.size.height - tr.size.height - 5.0;
	tr.size.width -= kSBSectionInnerMarginX * 2;
	attributes = [NSDictionary dictionaryWithObjectsAndKeys:
				  [NSFont boldSystemFontOfSize:13.0], NSFontAttributeName, 
				  [NSColor colorWithCalibratedWhite:0.65 alpha:1.0], NSForegroundColorAttributeName, nil];
	[groupe.title drawInRect:tr withAttributes:attributes];
	tr.origin.y -= 1.0;
	tr.origin.x += 1.0;
	attributes = [NSDictionary dictionaryWithObjectsAndKeys:
				  [NSFont boldSystemFontOfSize:13.0], NSFontAttributeName, 
				  [NSColor colorWithCalibratedWhite:0.55 alpha:1.0], NSForegroundColorAttributeName, nil];
	[groupe.title drawInRect:tr withAttributes:attributes];
	tr.origin.x -= 2.0;
	attributes = [NSDictionary dictionaryWithObjectsAndKeys:
				  [NSFont boldSystemFontOfSize:13.0], NSFontAttributeName, 
				  [NSColor colorWithCalibratedWhite:0.55 alpha:1.0], NSForegroundColorAttributeName, nil];
	[groupe.title drawInRect:tr withAttributes:attributes];
	tr.origin.y -= 2.0;
	tr.origin.x += 1.0;
	attributes = [NSDictionary dictionaryWithObjectsAndKeys:
				  [NSFont boldSystemFontOfSize:13.0], NSFontAttributeName, 
				  [NSColor colorWithCalibratedWhite:0.45 alpha:1.0], NSForegroundColorAttributeName, nil];
	[groupe.title drawInRect:tr withAttributes:attributes];
	tr.origin.y += 2.0;
	attributes = [NSDictionary dictionaryWithObjectsAndKeys:
				  [NSFont boldSystemFontOfSize:13.0], NSFontAttributeName, 
				  [NSColor colorWithCalibratedWhite:1.0 alpha:1.0], NSForegroundColorAttributeName, nil];
	[groupe.title drawInRect:tr withAttributes:attributes];
}

@end

@implementation SBSectionItemView

@synthesize item;
@synthesize currentImageView;
@synthesize currentField;

- (id)initWithItem:(SBSectionItem *)inItem
{
	if (self = [super initWithFrame:NSZeroRect])
	{
		self.item = inItem;
	}
	return self;
}

- (void)dealloc
{
	[item release];
	currentImageView = nil;
	currentField = nil;
	[super dealloc];
}

- (NSRect)titleRect
{
	NSRect r = self.bounds;
	r.size.width = r.size.width * 0.4;
	return r;
}

- (NSRect)valueRect
{
	NSRect r = self.bounds;
	CGFloat margin = 10.0;
	r.origin.x = r.size.width * 0.4 + margin;
	r.size.width = r.size.width * 0.6 - margin * 2;
	return r;
}

- (void)constructControl
{
	NSRect r = [self valueRect];
	if ([item controlClass] == [NSPopUpButton class])
	{
		NSString *string = [SBPreferences objectForKey:item.keyName];
		NSPopUpButton *popUp = nil;
		NSMenuItem *selectedItem = nil;
		r.origin.y = (r.size.height - 26.0) / 2;
		r.size.height = 26.0;
		popUp = [[[NSPopUpButton alloc] initWithFrame:r pullsDown:NO] autorelease];
		if ([item.context isKindOfClass:[NSMenu class]])
		{
			[popUp setTarget:self];
			[popUp setAction:@selector(select:)];
			[popUp setMenu:item.context];
		}
		selectedItem = [[popUp menu] selectItemWithRepresentedObject:string];
		if (selectedItem)
			[popUp selectItem:selectedItem];
		[self addSubview:popUp];
	}
	else if ([item controlClass] == [NSTextField class])
	{
		NSString *string = [SBPreferences objectForKey:item.keyName];
		NSTextField *field = nil;
		r.origin.y = (r.size.height - 22.0) / 2;
		r.size.height = 22.0;
		field = [[[NSTextField alloc] initWithFrame:r] autorelease];
		[field setDelegate:self];
		[[field cell] setFocusRingType:NSFocusRingTypeNone];
		[[field cell] setPlaceholderString:[item.context isKindOfClass:[NSString class]] ? item.context : nil];
		if (string)
			[field setStringValue:string];
		[self addSubview:field];
	}
	else if ([item controlClass] == [NSOpenPanel class])
	{
		NSWorkspace *space = [NSWorkspace sharedWorkspace];
		NSString *path = [SBPreferences objectForKey:item.keyName];
		NSString *tpath = nil;
		NSImage *image = [space iconForFile:path];
		NSButton *button = nil;
		NSImageView *imageView = nil;
		NSTextField *field = nil;
		NSRect fr = r;
		NSRect ir = r;
		NSRect br = r;
		ir.size.width = 22;
		br.size.width = 120;
		fr.origin.x += ir.size.width;
		fr.size.width -= (ir.size.width + br.size.width);
		br.origin.x += (ir.size.width + fr.size.width);
		ir.origin.y = (ir.size.height - 22.0) / 2;
		ir.size.height = 22.0;
		fr.origin.y = (fr.size.height - 22.0) / 2;
		fr.size.height = 22.0;
		br.origin.y = (br.size.height - 32.0) / 2;
		br.size.height = 32.0;
		button = [[[NSButton alloc] initWithFrame:br] autorelease];
		imageView = [[[NSImageView alloc] initWithFrame:ir] autorelease];
		field = [[[NSTextField alloc] initWithFrame:fr] autorelease];
		[button setTarget:self];
		[button setAction:@selector(open:)];
		[button setTitle:NSLocalizedString(@"Open…", nil)];
		[button setButtonType:NSMomentaryLightButton];
		[button setBezelStyle:NSRoundedBezelStyle];
		if (image)
			[image setSize:NSMakeSize(16.0, 16.0)];
		[imageView setImage:image];
		[imageView setImageFrameStyle:NSImageFrameNone];
		[field setBordered:NO];
		[field setSelectable:NO];
		[field setEditable:NO];
		[field setDrawsBackground:NO];
		[[field cell] setPlaceholderString:[item.context isKindOfClass:[NSString class]] ? item.context : nil];
		if (path)
		{
			tpath = [path stringByAbbreviatingWithTildeInPath];
			[field setStringValue:tpath];
		}
		[self addSubview:imageView];
		[self addSubview:field];
		[self addSubview:button];
		self.currentImageView = imageView;
		self.currentField = field;
	}
	else if ([item controlClass] == [NSButton class])
	{
		BOOL enabled = [SBPreferences boolForKey:item.keyName];
		NSButton *button = nil;
		r.origin.y = (r.size.height - 18.0) / 2;
		r.size.height = 18.0;
		button = [[[NSButton alloc] initWithFrame:r] autorelease];
		[button setTarget:self];
		[button setAction:@selector(check:)];
		[button setButtonType:NSSwitchButton];
		[button setTitle:[item.context isKindOfClass:[NSString class]] ? item.context : nil];
		[button setState:enabled ? NSOnState : NSOffState];
		[self addSubview:button];
	}
}

#pragma mark Delegate

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	NSTextField *field = [aNotification object];
	NSString *text = [field stringValue];
	if (item.keyName)
		[SBPreferences setObject:text forKey:item.keyName];
}

#pragma mark Actions

- (void)select:(id)sender
{
	//kSBOpenURLFromApplications
	//kSBDefaultEncoding
	NSPopUpButton *popUpButton = (NSPopUpButton *)sender;
	NSMenuItem *selectedItem = [popUpButton respondsToSelector:@selector(selectedItem)] ? [popUpButton selectedItem] : nil;
	id representedObject = selectedItem ? [selectedItem representedObject] : nil;
	if (representedObject && item.keyName)
	{
		[SBPreferences setObject:representedObject forKey:item.keyName];
	}
}

- (void)open:(id)sender
{
	SBOpenPanel *panel = [SBOpenPanel openPanel];
	NSWindow *window = [self window];
	[panel setAllowsMultipleSelection:NO];
	[panel setCanChooseFiles:NO];
	[panel setCanChooseDirectories:YES];
	[panel beginSheetForDirectory:nil file:nil types:nil modalForWindow:window modalDelegate:self didEndSelector:@selector(openDidEnd:returnCode:contextInfo:) contextInfo:sender];
}

- (void)openDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	[panel orderOut:nil];
	if (returnCode == NSOKButton)
	{
		if (self.currentImageView && self.currentField && item.keyName)
		{
			NSWorkspace *space = [NSWorkspace sharedWorkspace];
			NSString *path = [panel filename];
			NSString *tpath = [path stringByAbbreviatingWithTildeInPath];
			NSImage *image = [space iconForFile:path];
			if (image)
				[image setSize:NSMakeSize(16.0, 16.0)];
			[self.currentImageView setImage:image];
			[self.currentField setStringValue:tpath];
			[SBPreferences setObject:path forKey:item.keyName];
		}
	}
}

- (void)check:(id)sender
{
	BOOL enabled = [sender state] == NSOnState;
	if (item.keyName)
		[SBPreferences setBool:enabled forKey:item.keyName];
}

#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
	CGRect r = NSRectToCGRect(self.bounds);
	CGFloat margin = 0;
	CGMutablePathRef path = CGPathCreateMutable();
	NSRect titleRect = NSZeroRect;
	NSDictionary *attributes = nil;
	NSMutableParagraphStyle *paragraph = nil;
	NSString *titleString = nil;
	
	// Stroke
	margin = 10.0;
	CGPathMoveToPoint(path, nil, r.origin.x + margin, CGRectGetMaxY(r));
	CGPathAddLineToPoint(path, nil, CGRectGetMaxX(r) - margin * 2, CGRectGetMaxY(r));
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, path);
	CGContextSetLineWidth(ctx, 0.5);
	CGContextSetRGBStrokeColor(ctx, 0.6, 0.6, 0.6, 1.0);
	CGContextStrokePath(ctx);
	CGContextRestoreGState(ctx);
	CGPathRelease(path);
	
	titleString = [NSString stringWithFormat:@"%@ :", item.title];
	titleRect = [self titleRect];
	paragraph = [[NSMutableParagraphStyle alloc] init];
	[paragraph setAlignment:NSRightTextAlignment];
	attributes = [NSDictionary dictionaryWithObjectsAndKeys:
				  [NSFont boldSystemFontOfSize:12.0], NSFontAttributeName, 
				  [NSColor colorWithCalibratedWhite:0.3 alpha:1.0], NSForegroundColorAttributeName, 
				  paragraph, NSParagraphStyleAttributeName, nil];
	titleRect.size.height = [titleString sizeWithAttributes:attributes].height;
	titleRect.origin.y = (self.bounds.size.height - titleRect.size.height) / 2;
	[titleString drawInRect:titleRect withAttributes:attributes];
	[paragraph release];
}

@end
