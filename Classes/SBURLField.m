/*

SBURLField.m
 
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

#import "SBURLField.h"
#import "SBBLKGUI.h"
#import "SBButton.h"
#import "SBDocument.h"
#import "SBToolbar.h"
#import "SBUtil.h"

#define SBURLFieldRowCount 3
#define SBURLFieldRowHeight 20
#define SBURLFieldRoundedCurve SBFieldRoundedCurve
#define SBURLFieldSheetPaddingBottom 10

@implementation SBURLField

@synthesize backwardButton;
@synthesize forwardButton;
@synthesize imageView;
@synthesize field;
@synthesize goButton;
@synthesize sheet;
@synthesize contentView;
@synthesize dataSource;
@synthesize delegate;
@dynamic image;
@dynamic stringValue;
@synthesize items;
@dynamic enabledBackward;
@dynamic enabledForward;
@dynamic enabledGo;
@dynamic hiddenGo;

- (id)initWithFrame:(NSRect)rect
{
	NSRect r = rect;
	NSSize minSize = [self minimumSize];
	
	if (r.size.width < minSize.width)
		r.size.width = minSize.width;
	if (r.size.height < minSize.height)
		r.size.height = minSize.height;
	if (self = [super initWithFrame:r])
	{
		
	}
	return self;
}

- (void)dealloc
{
	[backwardButton release];
	[forwardButton release];
	[imageView release];
	[field release];
	[goButton release];
	[sheet release];
	[contentView release];
	dataSource = nil;
	delegate = nil;
	[items release];
	[super dealloc];
}

- (NSSize)minimumSize
{
	return NSMakeSize(100.0, 22.0);
}

- (NSFont *)font
{
	return [field font];
}

- (CGFloat)sheetHeight
{
	NSInteger rowCount = (([items count] < 10) ? [items count] : 10);
	return SBURLFieldRowHeight * rowCount + SBURLFieldSheetPaddingBottom;
}

- (NSRect)appearedSheetRect
{
	NSRect r = NSZeroRect;
	NSRect bounds = [self bounds];
	NSRect frame = [self frame];
	NSPoint position = NSZeroPoint;
	
	r.size.width = bounds.size.width;
	r.size.height = [self sheetHeight];
	position = [(SBToolbar *)[[self window] toolbar] itemRectInScreenForIdentifier:kSBToolbarURLFieldItemIdentifier].origin;
	r.origin.x = frame.origin.x + position.x;
	r.origin.y = frame.origin.y + position.y;
	r.origin.y = r.origin.y - r.size.height + 1;
	return r;
}

- (BOOL)isOpenSheet
{
	return _isOpenSheet;
}

- (BOOL)isEditing
{
	return YES;
}

- (BOOL)isFirstResponder
{
	BOOL r = NO;
	NSText *editor = [field currentEditor];
	r = [[[self window] firstResponder] isEqual:editor];
	return r;
}

- (SBURLFieldSheet *)sheet
{
	return sheet;
}

- (NSImage *)image
{
	return [imageView image];
}

- (NSString *)stringValue
{
	return [field stringValue];
}

- (NSMutableArray *)items
{
	return items;
}

- (BOOL)enabledBackward
{
	return backwardButton.enabled;
}

- (BOOL)enabledForward
{
	return forwardButton.enabled;
}

- (BOOL)enabledGo
{
	return goButton.enabled;
}

- (BOOL)hiddenGo
{
	return goButton.hidden;
}

#pragma mark Rects

- (CGFloat)buttonWidth
{
	return 27.0;
}

- (CGFloat)goButtonWidth
{
	return 75.0;
}

- (CGFloat)imageWidth
{
	return 22.0;
}

- (NSRect)backwardRect
{
	NSRect r = NSZeroRect;
	r.size.width = [self buttonWidth];
	r.size.height = self.bounds.size.height;
	r.origin.x = 0.0;
	r.origin.y = 0.0;
	return r;
}

- (NSRect)forwardRect
{
	NSRect r = NSZeroRect;
	CGFloat buttonWidth = [self buttonWidth];
	r.size.width = buttonWidth;
	r.size.height = self.bounds.size.height;
	r.origin.x = buttonWidth;
	r.origin.y = 0.0;
	return r;
}

- (NSRect)imageRect
{
	NSRect r = NSZeroRect;
	r.size.width = r.size.height = 16.0;
	r.origin.x = [self buttonWidth] * 2 + ([self imageWidth] - r.size.width) / 2;
	r.origin.y = (self.bounds.size.height - r.size.height) / 2;
	return r;
}

- (NSRect)fieldRect
{
	NSRect r = NSZeroRect;
	CGFloat buttonWidth = [self buttonWidth];
	CGFloat imageWidth = [self imageWidth];
	r.size.width = self.bounds.size.width - imageWidth - 4.0 - buttonWidth * 2 - (goButton && !goButton.hidden ? [self goButtonWidth] : 0);
	r.size.height = self.bounds.size.height - 2;
	r.origin.x = buttonWidth * 2 + imageWidth;
	r.origin.y = -2.0;
	return r;
}

- (NSRect)goRect
{
	NSRect r = NSZeroRect;
	CGFloat buttonWidth = [self goButtonWidth];
	r.size.width = buttonWidth;
	r.size.height = self.bounds.size.height;
	r.origin.x = self.bounds.size.width - buttonWidth;
	r.origin.y = 0.0;
	return r;
}

#pragma mark Construction

- (void)constructViews
{
	[self constructButtons];
	[self constructField];
	[self constructGoButton];
	[self constructSheet];
	self.hiddenGo = YES;
	_isOpenSheet = NO;
}

- (void)constructButtons
{
	NSRect backwardRect = [self backwardRect];
	NSRect forwardRect = [self forwardRect];
	backwardButton = [[SBButton alloc] initWithFrame:backwardRect];
	forwardButton = [[SBButton alloc] initWithFrame:forwardRect];
	backwardButton.image = [NSImage imageWithCGImage:SBBackwardIconImage(NSSizeToCGSize(backwardRect.size), YES, NO)];
	backwardButton.disableImage = [NSImage imageWithCGImage:SBBackwardIconImage(NSSizeToCGSize(backwardRect.size), NO, NO)];
	backwardButton.backImage = [NSImage imageWithCGImage:SBBackwardIconImage(NSSizeToCGSize(backwardRect.size), YES, YES)];
	backwardButton.backDisableImage = [NSImage imageWithCGImage:SBBackwardIconImage(NSSizeToCGSize(backwardRect.size), NO, YES)];
	forwardButton.image = [NSImage imageWithCGImage:SBForwardIconImage(NSSizeToCGSize(forwardRect.size), YES, NO)];
	forwardButton.disableImage = [NSImage imageWithCGImage:SBForwardIconImage(NSSizeToCGSize(forwardRect.size), NO, NO)];
	forwardButton.backImage = [NSImage imageWithCGImage:SBForwardIconImage(NSSizeToCGSize(forwardRect.size), YES, YES)];
	forwardButton.backDisableImage = [NSImage imageWithCGImage:SBForwardIconImage(NSSizeToCGSize(forwardRect.size), NO, YES)];
	backwardButton.target = self;
	forwardButton.target = self;
	backwardButton.action = @selector(executeDidSelectBackward);
	forwardButton.action = @selector(executeDidSelectForward);
	[self addSubview:backwardButton];
	[self addSubview:forwardButton];
}

- (void)constructField
{
	imageView = [[SBURLImageView alloc] initWithFrame:[self imageRect]];
	field = [[SBURLTextField alloc] initWithFrame:[self fieldRect]];
	[imageView setImageFrameStyle:NSImageFrameNone];
	[field setTarget:self];
	[field setAction:@selector(executeShouldOpenURL)];
	[field setCommandAction:@selector(executeShouldOpenURLInNewTab)];
	[field setOptionAction:@selector(executeShouldDownloadURL)];
	[field setBezeled:NO];
	[field setDrawsBackground:NO];
	[field setBordered:NO];
	[field setFocusRingType:NSFocusRingTypeNone];
	[field setDelegate:self];
	[field setFont:[NSFont systemFontOfSize:13.0]];
	[field setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
	[[field cell] setWraps:NO];
	[[field cell] setScrollable:YES];
	[field setRefusesFirstResponder:NO];
	[self addSubview:imageView];
	[self addSubview:field];
}

- (void)constructGoButton
{
	NSRect goRect = [self goRect];
	goButton = [[SBButton alloc] initWithFrame:goRect];
	[goButton setAutoresizingMask:(NSViewMinXMargin)];
	goButton.image = [NSImage imageWithCGImage:SBGoIconImage(NSSizeToCGSize(goRect.size), YES, NO)];
	goButton.disableImage = [NSImage imageWithCGImage:SBGoIconImage(NSSizeToCGSize(goRect.size), NO, NO)];
	goButton.backImage = [NSImage imageWithCGImage:SBGoIconImage(NSSizeToCGSize(goRect.size), YES, YES)];
	goButton.backDisableImage = [NSImage imageWithCGImage:SBGoIconImage(NSSizeToCGSize(goRect.size), NO, YES)];
	goButton.target = self;
	goButton.action = @selector(executeShouldOpenURL);
	goButton.enabled = NO;
	[self addSubview:goButton];
}

- (void)constructSheet
{
	NSRect sheetRect = [self appearedSheetRect];
	NSRect contentRect = NSZeroRect;
	
	contentRect.size = sheetRect.size;
	items = [[NSMutableArray alloc] initWithCapacity:0];
	sheet = [[SBURLFieldSheet alloc] initWithContentRect:sheetRect styleMask:(NSBorderlessWindowMask | NSNonactivatingPanelMask) backing:NSBackingStoreBuffered defer:YES];
	contentView = [[SBURLFieldContentView alloc] initWithFrame:contentRect];
	[sheet setAlphaValue:[[self window] alphaValue]];
	[sheet setOpaque:NO];
	[sheet setBackgroundColor:[NSColor clearColor]];
	[sheet setHasShadow:NO];
	[sheet setContentView:contentView];
}

- (void)tableViewDidDoubleAction:(NSTableView *)tableView
{
	if ([tableView selectedRow] != -1)
	{
		[contentView pushSelectedItem];
		[self disappearSheet];
		[[field target] performSelector:[field action] withObject:field];
	}
}

#pragma mark Delegate

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	if ([[aNotification object] selectedRow] != -1)
	{
		[contentView pushSelectedItem];
	}
}

- (void)tableViewSelectionIsChanging:(NSNotification *)aNotification
{
	[contentView setNeedsDisplay:YES];	// Keep drawing background
}

- (void)controlTextDidBeginEditing:(NSNotification *)aNotification
{
	// Show go button
	self.hiddenGo = NO;
	[self updateGoTitle:[NSApp currentEvent]];
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	NSEvent *currentEvent = [NSApp currentEvent];
	NSString *characters = [currentEvent characters];
	unichar character = [characters characterAtIndex:0];
	NSString *stringValue = [field stringValue];
	BOOL hasScheme = NO;
	
	// Update go button
	self.hiddenGo = NO;
	goButton.enabled = [stringValue length] > 0;
	goButton.title = goButton.enabled ? ([stringValue isURLString:&hasScheme] ? NSLocalizedString(@"Go", nil) : NSLocalizedString(@"Search", nil)) : nil;
	
	if (character == NSDeleteCharacter || 
		character == NSBackspaceCharacter || 
		character == NSLeftArrowFunctionKey || 
		character == NSRightArrowFunctionKey)
	{
		// Disappear sheet
		if (_isOpenSheet)
		{
			[self disappearSheet];
		}
	}
	else {
		// Get items from Bookmarks and History items
		[self executeTextDidChange];
		if ([items count] > 0)
		{
			if (!_isOpenSheet)
			{
				[self appearSheet];
			}
			[self reloadData];
			[self adjustSheet];
			[contentView deselectRow];
		}
		else {
			[self disappearSheet];
		}
	}
}

- (void)controlTextDidEndEditing:(NSNotification *)aNotification
{
	NSEvent *currentEvent = [[self window] currentEvent];
	
	// Hide go button
	self.hiddenGo = YES;
	
	// Disappear sheet
	if (_isOpenSheet)
	{
		[self disappearSheet];
	}
	
	if ([currentEvent type] == NSKeyDown)
	{
		NSString *characters = [currentEvent characters];
		unichar character = [characters characterAtIndex:0];
		if (character == NSTabCharacter || character == '\t')		// Tab
		{
			// If the user push Tab key, make first responder to next responder
			id nextKeyView = [field nextKeyView];
			[[self window] makeFirstResponder:nextKeyView];
		}
	}
}

- (BOOL)control:(NSControl*)control textView:(NSTextView*)textView doCommandBySelector:(SEL)commandSelector
{
    BOOL r = NO;
	if (control == field)
	{
		if (commandSelector == @selector(insertNewlineIgnoringFieldEditor:))
		{
			// Ignore new line action
			NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
			[center postNotificationName:NSControlTextDidEndEditingNotification object:self];
			[field sendAction:field.optionAction to:[field target]];
			r = YES;
		}
	}
    return r;
}

#pragma mark DataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [items count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	NSString *object = nil;
	NSString *identifier = [aTableColumn identifier];
	NSDictionary *item = (rowIndex < [items count]) ? [items objectAtIndex:rowIndex] : nil;
	if ([identifier isEqual:kSBURL])
	{
		NSString *title = item ? [item objectForKey:kSBTitle] : nil;
		object = item ? [item objectForKey:kSBURL] : nil;
		if (title)
			object = [title stringByAppendingFormat:@" - %@", object];
	}
	return object;
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	NSString *identifier = [aTableColumn identifier];
	if ([identifier isEqualToString:kSBImage])
	{
		NSDictionary *item = (rowIndex < [items count]) ? [items objectAtIndex:rowIndex] : nil;
		NSData *data = item ? [item objectForKey:kSBImage] : nil;
		NSImage *image = nil;
		if (data)
		{
			image = [[[NSImage alloc] initWithData:data] autorelease];
			[image setSize:NSMakeSize(16.0, 16.0)];
		}
		if (image)
		{
			[aCell setImage:image];
		}
	}
}

#pragma mark Setter

- (void)setImage:(NSImage *)image
{
	if (self.image != image)
	{
		[imageView setImage:image];
	}
}

- (void)setStringValue:(NSString *)stringValue
{
	if (!stringValue)
	{
		stringValue = [NSString string];
	}
	if (![self.stringValue isEqualToString:stringValue])
	{
		[field setStringValue:stringValue];
		// Update go button
		BOOL hasScheme = NO;
		goButton.enabled = [stringValue length] > 0;
		goButton.title = goButton.enabled ? ([stringValue isURLString:&hasScheme] ? NSLocalizedString(@"Go", nil) : NSLocalizedString(@"Search", nil)) : nil;
	}
}

- (void)setURLString:(NSString *)URLString
{
	NSText *editor = [field currentEditor];
	if (!editor)
		editor = [[self window] fieldEditor:YES forObject:field];
	NSRange selectedRange = [editor selectedRange];
	NSRange range = {NSNotFound, 0};
	NSString *string = [self stringValue];
	NSString *currentScheme = [SBURLFieldUtil schemeForURLString:string];
	NSString *scheme = [SBURLFieldUtil schemeForURLString:URLString];
	if ([scheme hasPrefix:string])
	{
		NSRange headRange = [URLString rangeOfString:string];
		range.location = headRange.location + headRange.length;
		range.length = [URLString length] - range.location;
	}
	else {
		CGFloat currentSchemeLength = 0;
		CGFloat schemeLength = 0;
		if (currentScheme) currentSchemeLength = [currentScheme length];
		if (scheme) schemeLength = [scheme length];
		
		selectedRange.location -= currentSchemeLength;
		selectedRange.length -= currentSchemeLength;
		if (selectedRange.length == 0)
		{
			range.location = selectedRange.location + selectedRange.length + schemeLength;
		}
		else {
			range.location = selectedRange.location + schemeLength;
		}
		range.length = [URLString length] - range.location;
	}
	[self setStringValue:URLString];
	[editor setSelectedRange:range];
}

- (void)setPlaceholderString:(NSString *)string
{
	[[field cell] setPlaceholderString:string];
}

- (void)setDataSource:(id)inDataSource
{
	if (dataSource != inDataSource)
	{
		dataSource = inDataSource;
		[contentView setDataSource:self];
	}
}

- (void)setDelegate:(id)inDelegate
{
	if (delegate != inDelegate)
	{
		delegate = inDelegate;
		[contentView setDelegate:self];
	}
}

- (void)setURLItems:(NSArray *)URLItems
{
	[items removeAllObjects];
	if ([URLItems count] > 0)
		[items addObjectsFromArray:URLItems];
	[self reloadData];
	
	if ([items count] == 0)
	{
		[self disappearSheet];
	}
	else {
		[self adjustSheet];
		[contentView deselectRow];
	}
}

- (void)setEnabledBackward:(BOOL)enabledBackward
{
	backwardButton.enabled = enabledBackward;
}

- (void)setEnabledForward:(BOOL)enabledForward
{
	forwardButton.enabled = enabledForward;
}

- (void)setEnabledGo:(BOOL)enabledGo
{
	goButton.enabled = enabledGo;
}

- (void)setHiddenGo:(BOOL)hiddenGo
{
	goButton.hidden = hiddenGo;
	field.frame = [self fieldRect];
}

#pragma mark Action

- (void)endEditing
{
	[self disappearSheet];
	self.hiddenGo = YES;
	[[field cell] endEditing:[[self window] fieldEditor:NO forObject:field]];
}

- (void)adjustSheet
{
	NSRect sheetRect = NSZeroRect;
	sheetRect = [self appearedSheetRect];
	[sheet setFrame:sheetRect display:YES];
	[sheet setAlphaValue:[[self window] alphaValue]];
	[contentView adjustTable];
}

- (void)appearSheet
{
	if (![sheet isVisible])
	{
		[self adjustSheet];
		[[self window] addChildWindow:sheet ordered:NSWindowAbove];
		[contentView deselectRow];
		[sheet orderFront:nil];
		_isOpenSheet = YES;
		[self setNeedsDisplay:YES];
		[contentView setNeedsDisplay:YES];
	}
}

- (void)disappearSheet
{
	if ([sheet isVisible])
	{
		[[self window] removeChildWindow:sheet];
		[self setNeedsDisplay:YES];
		[sheet orderOut:nil];
		_isOpenSheet = NO;
		[self setNeedsDisplay:YES];
	}
}

- (void)selectRowAbove
{
	[contentView selectRowAbove];
}

- (void)selectRowBelow
{
	[contentView selectRowBelow];
}

- (BOOL)selectRow
{
	return [contentView selectRow];
}

- (void)reloadData
{
	[contentView reloadData];
}

- (void)selectText:(id)sender
{
	[field selectText:sender];
}

- (void)setTextColor:(NSColor *)color
{
	[field setTextColor:color];
}

- (void)setNextKeyView:(id)responder
{
	[field setNextKeyView:responder];
}

- (void)updateGoTitle:(NSEvent *)theEvent
{
	NSUInteger modifierFlags = [theEvent modifierFlags];
	if (modifierFlags & NSCommandKeyMask)
	{
		if (![goButton.title isEqualToString:NSLocalizedString(@"Open", nil)])
		{
			goButton.title = NSLocalizedString(@"Open", nil);
		}
	}
	else if (modifierFlags & NSAlternateKeyMask)
	{
		if (![goButton.title isEqualToString:NSLocalizedString(@"Download", nil)])
		{
			goButton.title = NSLocalizedString(@"Download", nil);
		}
	}
	else {
		BOOL hasScheme = NO;
		NSString *title = nil;
		if ([self.stringValue length] > 0)
			title = [self.stringValue isURLString:&hasScheme] ? NSLocalizedString(@"Go", nil) : NSLocalizedString(@"Search", nil);
		if (![goButton.title isEqualToString:title])
		{
			goButton.title = title;
		}
	}
}

#pragma mark Exec

- (void)executeDidSelectBackward
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(urlFieldDidSelectBackward:)])
		{
			[delegate urlFieldDidSelectBackward:self];
		}
	}
}

- (void)executeDidSelectForward
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(urlFieldDidSelectForward:)])
		{
			[delegate urlFieldDidSelectForward:self];
		}
	}
}

- (void)executeShouldOpenURL
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(urlFieldShouldOpenURL:)])
		{
			[delegate urlFieldShouldOpenURL:self];
		}
	}
}

- (void)executeShouldOpenURLInNewTab
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(urlFieldShouldOpenURLInNewTab:)])
		{
			[delegate urlFieldShouldOpenURLInNewTab:self];
		}
	}
}

- (void)executeShouldDownloadURL
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(urlFieldShouldDownloadURL:)])
		{
			[delegate urlFieldShouldDownloadURL:self];
		}
	}
}

- (void)executeTextDidChange
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(urlFieldTextDidChange:)])
		{
			[delegate urlFieldTextDidChange:self];
		}
	}
}

- (void)executeWillResignFirstResponder
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(urlFieldWillResignFirstResponder:)])
		{
			[delegate urlFieldWillResignFirstResponder:self];
		}
	}
}

#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	if (_isOpenSheet)
	{
		CGRect r = CGRectZero;
		CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
		CGPathRef path = nil;
		
		r = NSRectToCGRect(self.bounds);
		path = SBRoundedPath(r, SBURLFieldRoundedCurve, 0, YES, NO);
		CGContextSaveGState(ctx);
		CGContextAddPath(ctx, path);
		CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
		CGContextFillPath(ctx);
		CGContextRestoreGState(ctx);
		CGPathRelease(path);
		
		r = NSRectToCGRect(self.bounds);
		r.origin.x += 0.5;
		r.origin.y += 3.0;
		r.size.width -= 1.0;
		r.size.height -= 4.5;
		path = SBRoundedPath(r, SBURLFieldRoundedCurve, 0, YES, NO);
		CGContextSaveGState(ctx);
		CGContextAddPath(ctx, path);
		CGContextSetLineWidth(ctx, 1.0);
		CGContextSetRGBStrokeColor(ctx, 0.75, 0.75, 0.75, 1.0);
		CGContextStrokePath(ctx);
		CGContextRestoreGState(ctx);
		CGPathRelease(path);
		
		r = NSRectToCGRect(self.bounds);
		r.origin.x += 0.5;
		r.origin.y += 0.5;
		r.size.width -= 1.0;
		r.size.height -= 1.0;
		path = SBRoundedPath(r, SBURLFieldRoundedCurve, 0, YES, NO);
		CGContextSaveGState(ctx);
		CGContextAddPath(ctx, path);
		CGContextSetLineWidth(ctx, 0.5);
		CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 0.0, 1.0);
		CGContextStrokePath(ctx);
		CGContextRestoreGState(ctx);
		CGPathRelease(path);
	}
	else {
		CGRect r = CGRectZero;
		CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
		CGPathRef path = nil;
		
		r = NSRectToCGRect(self.bounds);
		path = SBRoundedPath(r, SBURLFieldRoundedCurve, 0, YES, YES);
		CGContextSaveGState(ctx);
		CGContextAddPath(ctx, path);
		CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
		CGContextFillPath(ctx);
		CGContextRestoreGState(ctx);
		CGPathRelease(path);
		
		r = NSRectToCGRect(self.bounds);
		r.origin.x += 0.5;
		r.origin.y += 3.0;
		r.size.width -= 1.0;
		r.size.height -= 4.5;
		path = SBRoundedPath(r, SBURLFieldRoundedCurve, 0, YES, NO);
		CGContextSaveGState(ctx);
		CGContextAddPath(ctx, path);
		CGContextSetLineWidth(ctx, 1.0);
		CGContextSetRGBStrokeColor(ctx, 0.75, 0.75, 0.75, 1.0);
		CGContextStrokePath(ctx);
		CGContextRestoreGState(ctx);
		CGPathRelease(path);
		
		r = NSRectToCGRect(self.bounds);
		r.origin.x += 0.5;
		r.origin.y += 0.5;
		r.size.width -= 1.0;
		r.size.height -= 1.0;
		path = SBRoundedPath(r, SBURLFieldRoundedCurve, 0, YES, YES);
		CGContextSaveGState(ctx);
		CGContextAddPath(ctx, path);
		CGContextSetLineWidth(ctx, 0.5);
		CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 0.0, 1.0);
		CGContextStrokePath(ctx);
		CGContextRestoreGState(ctx);
		CGPathRelease(path);
	}
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldBoundsSize
{
	if (_isOpenSheet)
	{
		[self disappearSheet];
	}
	[super resizeWithOldSuperviewSize:oldBoundsSize];
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldBoundsSize
{
	if (_isOpenSheet)
	{
		[self disappearSheet];
	}
	[super resizeSubviewsWithOldSize:oldBoundsSize];
}

@end

@implementation SBURLImageView

@dynamic field;

- (SBURLField *)field
{
	return (SBURLField *)[self superview];
}

- (NSURL *)url
{
	return [NSURL URLWithString:[self.field stringValue]];
}

- (NSData *)selectedWebViewImageDataForBookmark
{
	NSData *data = nil;
	SBDocument *document = (SBDocument *)self.field.delegate;
	if (document)
		data = document.selectedWebViewImageDataForBookmark;
	return data;
}

- (NSImage *)dragImage
{
	NSImage *image = nil;
	NSDictionary *attribute = nil;
	NSString *urlString = [[self url] absoluteString];
	NSSize size = NSZeroSize;
	NSSize textSize = NSZeroSize;
	NSFont *font = [self.field font];
	NSRect imageRect = NSZeroRect;
	NSRect textRect = NSZeroRect;
	CGFloat margin = 0;
	
	margin = 5.0;
	attribute = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
	textSize = [urlString sizeWithAttributes:attribute];
	size.height = [self bounds].size.height;
	size.width = [self bounds].size.width + textSize.width + margin;
	imageRect.size = [self bounds].size;
	imageRect.origin.x = (size.height - imageRect.size.width) / 2;
	imageRect.origin.y = (size.height - imageRect.size.height) / 2;
	textRect.size.height = size.height;
	textRect.size.width = textSize.width;
	textRect.origin.x = (margin + NSMaxX(imageRect));
	image = [[[NSImage alloc] initWithSize:size] autorelease];
	
	[image lockFocus];
	[[self image] drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	[urlString drawInRect:textRect withAttributes:attribute];
	[image unlockFocus];
	
	return image;
}

- (void)mouseDown:(NSEvent *)event
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
	
	for (;;)
	{
		NSEvent *newEvent = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
		NSPoint newPoint = [self convertPoint:[newEvent locationInWindow] fromView:nil];
		BOOL isDragging = NO;
		if (NSPointInRect(newPoint,[self bounds]))
		{
			if ([newEvent type] == NSLeftMouseUp)
			{
				[self mouseUpActionWithEvent:event];
				break;
			}
			else if ([newEvent type] == NSLeftMouseDragged)
			{
				isDragging = YES;
			}
		}
		else {
			if ([newEvent type] == NSLeftMouseDragged)
			{
				isDragging = YES;
			}
		}
		
		if (isDragging)
		{
			NSPoint delta = NSMakePoint(point.x - newPoint.x,point.y - newPoint.y);
			if (delta.x >= 5 || delta.x <= -5 || delta.y >= 5 || delta.y <= -5)
			{
				[self mouseDraggedActionWithEvent:event];
				break;
			}
		}
	}
	[pool release];
}

- (void)mouseDraggedActionWithEvent:(NSEvent *)theEvent
{
	NSPasteboard *pasteboard = nil;
	NSString *title = nil;
	NSData *imageData = nil;
	
	pasteboard = [NSPasteboard pasteboardWithName:NSDragPboard];
	title = [[self window] title];
	imageData = [self selectedWebViewImageDataForBookmark];
	[pasteboard declareTypes:[NSArray arrayWithObjects:NSURLPboardType, nil] owner:nil];
	[[self url] writeToPasteboard:pasteboard];
	if (title)
		[pasteboard setString:title forType:NSStringPboardType];
	if (imageData)
		[pasteboard setData:imageData forType:NSTIFFPboardType];
	
	[self dragImage:[self dragImage] at:NSZeroPoint offset:NSZeroSize event:theEvent pasteboard:pasteboard source:[self window] slideBack:YES];
}

- (void)mouseUpActionWithEvent:(NSEvent *)theEvent
{
	[self.field selectText:self];
}

@end

@implementation SBURLTextField

@dynamic field;
@synthesize commandAction;
@synthesize optionAction;

- (id)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		commandAction = nil;
		optionAction = nil;
	}
	return self;
}

- (SBURLField *)field
{
	return (SBURLField *)[self superview];
}

#pragma mark Responder

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (BOOL)becomeFirstResponder
{
	// self through NSControlTextDidBeginEditingNotification
	[[NSNotificationCenter defaultCenter] postNotificationName:NSControlTextDidBeginEditingNotification object:self];
	return YES;
}

- (BOOL)resignFirstResponder
{
	[self.field executeWillResignFirstResponder];
	return YES;
}

- (void)selectText:(id)sender
{
	[super selectText:nil];
	// self through NSControlTextDidBeginEditingNotification
	[[NSNotificationCenter defaultCenter] postNotificationName:NSControlTextDidBeginEditingNotification object:self];
}

- (void)flagsChanged:(NSEvent *)theEvent
{
	[self.field updateGoTitle:theEvent];
}

#pragma mark Event

- (BOOL)performKeyEquivalent:(NSEvent *)event
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	NSString *characters = [event characters];
	unichar character = [characters characterAtIndex:0];
	if (character == NSCarriageReturnCharacter || character == NSEnterCharacter)
	{
		NSUInteger modifierFlags = [event modifierFlags];
		if (modifierFlags & NSCommandKeyMask)
		{
			// Command + Return
			[center postNotificationName:NSControlTextDidEndEditingNotification object:self];
			[self sendAction:commandAction to:[self target]];
			return YES;
		}
	}
	else {
		if ([self.field isOpenSheet])
		{
			if ([event type] == NSKeyDown)
			{
				if (character == NSUpArrowFunctionKey)
				{
					[self.field selectRowAbove];
					return YES;
				}
				else if (character == NSDownArrowFunctionKey)
				{
					[self.field selectRowBelow];
					return YES;
				}
				else if (character == NSLeftArrowFunctionKey)
				{
					[center postNotificationName:NSControlTextDidChangeNotification object:self];
				}
				else if (character == NSRightArrowFunctionKey)
				{
					[center postNotificationName:NSControlTextDidChangeNotification object:self];
				}
				else if (character == '\e')
				{
					[self.field disappearSheet];
				}
			}
		}
	}
	return [super performKeyEquivalent:event];
}

@end

@implementation SBURLFieldSheet

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (BOOL)becomeFirstResponder
{
	return YES;
}

- (BOOL)resignFirstResponder
{
	return YES;
}

- (BOOL)acceptsMouseMovedEvents
{
	return YES;
}

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent
{
	return [super performKeyEquivalent:theEvent];
}

@end

@implementation SBURLFieldContentView

@dynamic field;

- (id)initWithFrame:(NSRect)rect
{
	if (self = [super initWithFrame:rect])
	{
		[self constructTable];
	}
	return self;
}

- (void)dealloc
{
	[_scroller release];
	[_text release];
	[_table release];
	dataSource = nil;
	delegate = nil;
	[super dealloc];
}

- (SBURLField *)field
{
	id aField = nil;
	if ([[_table delegate] isKindOfClass:[SBURLField class]])
	{
		aField = [_table delegate];
	}
	return aField;
}

#pragma mark Construction

- (void)constructTable
{
	NSTableColumn *iconColumn = nil;
	NSTableColumn *nameColumn = nil;
	SBIconDataCell *iconCell = nil;
	NSRect bounds = [self bounds];
	NSRect scrollerRect = NSZeroRect;
	NSRect tableRect = NSZeroRect;
	scrollerRect.origin.x = 1;
	scrollerRect.size.width = bounds.size.width - 2;
	scrollerRect.size.height = SBURLFieldRowHeight * SBURLFieldRowCount;
	scrollerRect.origin.y = bounds.size.height - scrollerRect.size.height;
	tableRect.size = scrollerRect.size;
	_scroller = [[SBBLKGUIScrollView alloc] initWithFrame:scrollerRect];
	_table = [[SBURLTableView alloc] initWithFrame:tableRect];
	iconColumn = [[[NSTableColumn alloc] initWithIdentifier:kSBImage] autorelease];
	nameColumn = [[[NSTableColumn alloc] initWithIdentifier:kSBURL] autorelease];
	iconCell = [[[SBIconDataCell alloc] init] autorelease];
	[iconColumn setWidth:22.0];
	[iconColumn setDataCell:iconCell];
	[iconColumn setEditable:NO];
	[nameColumn setWidth:bounds.size.width - 22.0];
	[nameColumn setEditable:NO];
//	[_table setBackgroundColor:[NSColor clearColor]];
	[_table setRowHeight:SBURLFieldRowHeight - 2];
	[_table addTableColumn:iconColumn];
	[_table addTableColumn:nameColumn];
	[_table setAllowsMultipleSelection:NO];
	[_table setAllowsColumnSelection:NO];
	[_table setAllowsEmptySelection:YES];
	[_table setDoubleAction:@selector(tableViewDidDoubleAction:)];
	[_table setColumnAutoresizingStyle:NSTableViewLastColumnOnlyAutoresizingStyle];
	[_table setHeaderView:nil];
	[_table setCornerView:nil];
	[_table setAutoresizingMask:(NSViewWidthSizable)];
	[_scroller setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
	[_scroller setBackgroundColor:[NSColor whiteColor]];
	[_scroller setDrawsBackground:NO];
	[_scroller setAutohidesScrollers:YES];
	[_scroller setHasVerticalScroller:YES];
	[_scroller setAutohidesScrollers:YES];
//	[[_scroller verticalScroller] setControlSize:NSSmallControlSize];
	[_scroller setDocumentView:_table];
	[self addSubview:_scroller];
}

#pragma mark Setter

- (void)setDataSource:(id)inDataSource
{
	[_table setDataSource:inDataSource];
}

- (void)setDelegate:(id)inDelegate
{
	[_table setDelegate:inDelegate];
}

#pragma mark Action

- (void)adjustTable
{
	NSRect bounds = [self bounds];
	NSRect scrollerRect = [_scroller frame];
	NSRect tableRect = [_table frame];
	NSInteger rowCount = (([_table numberOfRows] < 10) ? [_table numberOfRows] : 10);
	scrollerRect.size.width = bounds.size.width - 2;
	scrollerRect.size.height = SBURLFieldRowHeight * rowCount;
	scrollerRect.origin.y = SBURLFieldSheetPaddingBottom;
	tableRect.size.width = scrollerRect.size.width;
	[_scroller setFrame:scrollerRect];
	[_table setFrame:tableRect];
}

- (void)selectRowAbove
{
	NSInteger rowIndex = [_table selectedRow];
	if (rowIndex == 0)
	{
		[self.field disappearSheet];
	}
	else {
		rowIndex--;
		[_table selectRow:rowIndex byExtendingSelection:NO];
		[_table scrollRowToVisible:rowIndex];
	}
	if ([self selectRow])
	{
		[_table scrollRowToVisible:rowIndex];
	}
}

- (void)selectRowBelow
{
	NSInteger rowIndex = [_table selectedRow];
	if (rowIndex == [_table numberOfRows] - 1)
	{
		[_table selectRow:0 byExtendingSelection:NO];
	}
	else {
		rowIndex++;
		[_table selectRow:rowIndex byExtendingSelection:NO];
	}
	if ([self selectRow])
	{
		[_table scrollRowToVisible:rowIndex];
	}
}

- (BOOL)selectRow
{
	BOOL r = YES;
	NSInteger rowIndex = [_table selectedRow];
	if (rowIndex != -1)
	{
		[self pushItemAtIndex:rowIndex];
	}
	else {
		r = NO;
	}
	return r;
}

- (void)deselectRow
{
	SBURLField *field = self.field;
	[_table deselectAll:nil];
	[_table scrollRowToVisible:0];
	[field setImage:nil];
}

- (void)reloadData
{
	[_table reloadData];
}

- (void)pushSelectedItem
{
	NSInteger rowIndex = [_table selectedRow];
	[self pushItemAtIndex:rowIndex];
}

- (void)pushItemAtIndex:(NSInteger)index
{
	SBURLField *field = self.field;
	if (index < [[field items] count])
	{
		NSDictionary *selectedItem = [[field items] objectAtIndex:index];
		NSString *URLString = [selectedItem objectForKey:kSBURL];
		if (![URLString isEqualToString:[field stringValue]])
		{
			NSData *data = [selectedItem objectForKey:kSBImage];
			NSImage *icon = [[[NSImage alloc] initWithData:data] autorelease];
			[field setURLString:URLString];
			[field setImage:icon];
		}
	}
}

#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	if (rect.size.width == [self bounds].size.width)
	{
		CGRect r = NSRectToCGRect(rect);
		CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
		CGPathRef path = SBRoundedPath(r, SBURLFieldRoundedCurve, 0, NO, YES);
		NSUInteger count = 2;
		CGFloat locations[count];
		CGFloat colors[count * 4];
		CGPoint points[2];
		locations[0] = 0.05;
		locations[1] = 0.0;
		colors[0] = colors[1] = colors[2] = 1.0;
		colors[3] = 1.0;
		colors[4] = colors[5] = colors[6] = 0.75;
		colors[7] = 1.0;
		points[0] = CGPointZero;
		points[1] = CGPointMake(0.0, rect.size.height);
		
		CGContextSaveGState(ctx);
		CGContextAddPath(ctx, path);
		CGContextClip(ctx);
		SBDrawGradientInContext(ctx, count, locations, colors, points);
		CGContextRestoreGState(ctx);
		CGPathRelease(path);
		
		r.origin.x += 0.5;
		r.origin.y += 0.5;
		r.size.width -= 1.0;
		path = SBRoundedPath(r, SBURLFieldRoundedCurve, 0, NO, YES);
		CGContextSaveGState(ctx);
		CGContextAddPath(ctx, path);
		CGContextSetLineWidth(ctx, 0.5);
		CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 0.0, 1.0);
		CGContextStrokePath(ctx);
		CGContextRestoreGState(ctx);
		CGPathRelease(path);
	}
}

@end

@implementation SBIconDataCell

- (BOOL)isOpaque
{
	return NO;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSImage *image = [self image];
	if (image)
	{
		NSRect r = NSZeroRect;
		[image setFlipped:YES];
		r.size = [image size];
		r.origin.x = cellFrame.origin.x + (cellFrame.size.width - r.size.width) / 2;
		r.origin.y = cellFrame.origin.y + (cellFrame.size.height - r.size.height) / 2;
		[image drawInRect:r fromRect:NSMakeRect(0, 0, r.size.width, r.size.height) operation:NSCompositeSourceOver fraction:1.0];
	}
}

@end

@implementation SBURLFieldUtil

+ (NSString *)schemeForURLString:(NSString *)urlString
{
	NSString *scheme = nil;
	NSRange range = {0, NSNotFound};
	
	range = [urlString rangeOfString:@"://"];
	if (range.location != NSNotFound)
	{
		range.length = (range.location + range.length);
		range.location = 0;
		scheme = [urlString substringWithRange:range];
	}
	
	return scheme;
}

@end

@implementation SBURLTableView

//- (BOOL)isOpaque
//{
//    return NO;
//}

//- (void)drawBackgroundInClipRect:(NSRect)clipRect
//{
//	NSScrollView *scrollView = [self enclosingScrollView];
//	NSView *superview = [scrollView superview];
//	[superview display];
//}

@end
