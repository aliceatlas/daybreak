/*

SBSnapshotView.m
 
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

#import "SBSnapshotView.h"
#import "SBDocument.h"
#import "SBSavePanel.h"

#define kSBMinFrameSizeWidth 600
#define kSBMaxFrameSizeWidth 1200
#define kSBMinFrameSizeHeight 480
#define kSBMaxFrameSizeHeight 960
#define kSBMaxImageSizeWidth 10000
#define kSBMaxImageSizeHeight 10000

@implementation SBSnapshotView

@synthesize title;
@dynamic filename;
@synthesize data;

- (id)initWithFrame:(NSRect)frame
{
	NSRect r = frame;
	if (r.size.width < kSBMinFrameSizeWidth)
		r.size.width = kSBMinFrameSizeWidth;
	if (r.size.width > kSBMaxFrameSizeWidth)
		r.size.width = kSBMaxFrameSizeWidth;
	if (r.size.height < kSBMinFrameSizeHeight)
		r.size.height = kSBMinFrameSizeHeight;
	if (r.size.height > kSBMaxFrameSizeHeight)
		r.size.height = kSBMaxFrameSizeHeight;
	if (self = [super initWithFrame:r])
	{
		title = nil;
		data = nil;
		[self constructViews];
		[self constructDoneButton];
		[self constructCancelButton];
		[self setAutoresizingMask:(NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin)];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResizeNotification object:[self window]];
	[image release];
	[self destructUpdateTimer];
	[scrollView release];
	[imageView release];
	[toolsView release];
	[onlyVisibleButton release];
	[updateButton release];
	[sizeLabel release];
	[widthField release];
	[heightField release];
	[scaleLabel release];
	[scaleField release];
	[lockButton release];
	[filetypeLabel release];
	[filetypePopup release];
	[optionTabView release];
	[tiffOptionLabel release];
	[tiffOptionPopup release];
	[jpgOptionLabel release];
	[jpgOptionSlider release];
	[jpgOptionField release];
	[filesizeLabel release];
	[filesizeField release];
	target = nil;
	[doneButton release];
	[cancelButton release];
	[title release];
	[data release];
	[super dealloc];
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

- (NSRect)doneButtonRect
{
	NSRect r = NSZeroRect;
	CGFloat buttonMargin = [self buttonMargin];
	r.size = [self buttonSize];
	r.origin.x = (self.bounds.size.width - (r.size.width * 2 + buttonMargin)) / 2 + r.size.width + buttonMargin;
	return r;
}

- (NSRect)cancelButtonRect
{
	NSRect r = NSZeroRect;
	CGFloat buttonMargin = [self buttonMargin];
	r.size = [self buttonSize];
	r.origin.x = (self.bounds.size.width - (r.size.width * 2 + buttonMargin)) / 2;
	return r;
}

#pragma mark Construction

- (void)constructViews
{
	NSTabViewItem *tabViewItem0 = nil;
	NSTabViewItem *tabViewItem1 = nil;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMenu *menu = nil;
	NSInteger i = 0;
	NSInteger count = 0;
	NSInteger selectedIndex = 0;
	NSPoint margin = NSZeroPoint;
	NSSize imageViewSize = NSZeroSize;
	CGFloat toolWidth = 0;
	
	margin = NSMakePoint(20, 52);
	toolWidth = 140;
	imageViewSize = NSMakeSize(self.frame.size.width - margin.x - toolWidth - 8.0, self.frame.size.height - margin.y - 20.0);
	scrollView = [[SBBLKGUIScrollView alloc] initWithFrame:NSMakeRect(margin.x, margin.y, imageViewSize.width, imageViewSize.height)];
	imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, imageViewSize.width, imageViewSize.height)];
	toolsView = [[NSView alloc] initWithFrame:NSMakeRect(imageViewSize.width + margin.x + 8.0, margin.y, toolWidth, imageViewSize.height)];
	onlyVisibleButton = [[SBBLKGUIButton alloc] initWithFrame:NSMakeRect(6, imageViewSize.height - 36, 119, 36)];
	updateButton = [[SBBLKGUIButton alloc] initWithFrame:NSMakeRect(6, imageViewSize.height - 76, 119, 32)];
	sizeLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(6, imageViewSize.height - 98, 120, 14)];
	widthField = [[SBBLKGUITextField alloc] initWithFrame:NSMakeRect(6, imageViewSize.height - 130, 67, 24)];
	heightField = [[SBBLKGUITextField alloc] initWithFrame:NSMakeRect(6, imageViewSize.height - 162, 67, 24)];
	scaleLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(6, imageViewSize.height - 184, 120, 14)];
	scaleField = [[SBBLKGUITextField alloc] initWithFrame:NSMakeRect(6, imageViewSize.height - 216, 67, 24)];
	lockButton = [[NSButton alloc] initWithFrame:NSMakeRect(93, imageViewSize.height - 151, 32, 32)];
	filetypeLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(6, imageViewSize.height - 238, 120, 14)];
	filetypePopup = [[SBBLKGUIPopUpButton alloc] initWithFrame:NSMakeRect(6, imageViewSize.height - 272, 114, 26)];
	optionTabView = [[NSTabView alloc] initWithFrame:NSMakeRect(6, imageViewSize.height - 321, 114, 45)];
	tiffOptionLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 32, 120, 13)];
	tiffOptionPopup = [[SBBLKGUIPopUpButton alloc] initWithFrame:NSMakeRect(12, 0, 100, 26)];
	jpgOptionLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 32, 120, 13)];
	jpgOptionSlider = [[SBBLKGUISlider alloc] initWithFrame:NSMakeRect(5, 8, 75, 17)];
	jpgOptionField = [[NSTextField alloc] initWithFrame:NSMakeRect(90, 10, 30, 13)];
	filesizeLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(3, imageViewSize.height - 343, 120, 14)];
	filesizeField = [[NSTextField alloc] initWithFrame:NSMakeRect(15, imageViewSize.height - 368, 108, 17)];
	
	visibleRect = NSZeroRect;
	successSize = NSZeroSize;
	successScale = 1.0;
	[lockButton setImagePosition:NSImageOnly];
	[[lockButton cell] setButtonType:NSToggleButton];
	[lockButton setImage:[NSImage imageNamed:@"Icon_Lock.png"]];
	[lockButton setAlternateImage:[NSImage imageNamed:@"Icon_Unlock.png"]];
	[[lockButton cell] setImageScaling:NSImageScaleNone];
	[sizeLabel setBordered:NO];
	[lockButton setBordered:NO];
	[scaleLabel setBordered:NO];
	[filetypeLabel setBordered:NO];
	[tiffOptionLabel setBordered:NO];
	[jpgOptionLabel setBordered:NO];
	[filesizeLabel setBordered:NO];
	[filesizeField setBordered:NO];
	[sizeLabel setEditable:NO];
	[scaleLabel setEditable:NO];
	[filetypeLabel setEditable:NO];
	[tiffOptionLabel setEditable:NO];
	[jpgOptionLabel setEditable:NO];
	[filesizeLabel setEditable:NO];
	[filesizeField setEditable:NO];
	[sizeLabel setDrawsBackground:NO];
	[scaleLabel setDrawsBackground:NO];
	[filetypeLabel setDrawsBackground:NO];
	[tiffOptionLabel setDrawsBackground:NO];
	[jpgOptionLabel setDrawsBackground:NO];
	[filesizeLabel setDrawsBackground:NO];
	[filesizeField setDrawsBackground:NO];
	[sizeLabel setTextColor:[NSColor whiteColor]];
	[scaleLabel setTextColor:[NSColor whiteColor]];
	[filetypeLabel setTextColor:[NSColor whiteColor]];
	[tiffOptionLabel setTextColor:[NSColor whiteColor]];
	[jpgOptionLabel setTextColor:[NSColor whiteColor]];
	[filesizeLabel setTextColor:[NSColor whiteColor]];
	[filesizeField setTextColor:[NSColor whiteColor]];
	[optionTabView setTabViewType:NSNoTabsNoBorder];
	[optionTabView setDrawsBackground:NO];
	
	// Controls
	[onlyVisibleButton setButtonType:NSSwitchButton];
	[onlyVisibleButton setState:[defaults boolForKey:kSBSnapshotOnlyVisiblePortion] ? NSOnState : NSOffState];
	[updateButton setButtonType:NSMomentaryLight];
	[onlyVisibleButton setTarget:self];
	[updateButton setTarget:self];
	[onlyVisibleButton setAction:@selector(checkOnlyVisible:)];
	[updateButton setAction:@selector(update:)];
	[onlyVisibleButton setTitle:NSLocalizedString(@"Only visible portion", nil)];
	[updateButton setImage:[NSImage imageNamed:@"Icon_Camera.png"]];
	[updateButton setTitle:NSLocalizedString(@"Update", nil)];
	[onlyVisibleButton setFont:[NSFont systemFontOfSize:10.0]];
	[updateButton setFont:[NSFont systemFontOfSize:11.0]];
	[updateButton setKeyEquivalentModifierMask:NSCommandKeyMask];
	[updateButton setKeyEquivalent:@"r"];
	[widthField setDelegate:self];
	[heightField setDelegate:self];
	[scaleField setDelegate:self];
	
	// Views
	tabViewItem0 = [[[NSTabViewItem alloc] initWithIdentifier:[NSString stringWithFormat:@"%d", NSTIFFFileType]] autorelease];
	tabViewItem1 = [[[NSTabViewItem alloc] initWithIdentifier:[NSString stringWithFormat:@"%d", NSJPEGFileType]] autorelease];
	[scrollView setDocumentView:imageView];
	[scrollView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
	[scrollView setHasHorizontalScroller:YES];
	[scrollView setHasVerticalScroller:YES];
	[scrollView setAutohidesScrollers:YES];
	[scrollView setBackgroundColor:[NSColor blackColor]];
	[scrollView setDrawsBackground:YES];
	[optionTabView addTabViewItem:tabViewItem0];
	[optionTabView addTabViewItem:tabViewItem1];
	
	[sizeLabel setStringValue:[NSString stringWithFormat:@"%@ :", NSLocalizedString(@"Size", nil)]];
	[scaleLabel setStringValue:[NSString stringWithFormat:@"%@ :", NSLocalizedString(@"Scale", nil)]];
	[filetypeLabel setStringValue:[NSString stringWithFormat:@"%@ :", NSLocalizedString(@"File Type", nil)]];
	[filesizeLabel setStringValue:[NSString stringWithFormat:@"%@ :", NSLocalizedString(@"File Size", nil)]];
	[progressField setStringValue:NSLocalizedString(@"Updating...", nil)];
	
	// Default values
	if ([defaults objectForKey:kSBSnapshotFileType])
	{
		filetype = [[defaults objectForKey:kSBSnapshotFileType] intValue];
	}
	else {
		filetype = NSTIFFFileType;
	}
	if ([defaults objectForKey:kSBSnapshotTIFFCompression])
	{
		tiffCompression = [[defaults objectForKey:kSBSnapshotTIFFCompression] intValue];
	}
	else {
		tiffCompression = NSTIFFCompressionNone;
	}
	if ([defaults objectForKey:kSBSnapshotJPGFactor])
	{
		jpgFactor = [[defaults objectForKey:kSBSnapshotJPGFactor] floatValue];
	}
	else {
		jpgFactor = 1.0;
	}
	
	// File type
	menu = [filetypePopup menu];
	count = 4;
	NSString *fileTypeNames[4] = {@"TIFF", @"GIF", @"JPEG", @"PNG"};
	NSBitmapImageFileType filetypes[4] = {NSTIFFFileType, NSGIFFileType, NSJPEGFileType, NSPNGFileType};
	[menu addItemWithTitle:[NSString string] action:nil keyEquivalent:@""];
	for (i = 0; i < count; i++)
	{
		NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:fileTypeNames[i] action:@selector(selectFiletype:) keyEquivalent:@""] autorelease];
		[item setTarget:self];
		[item setTag:filetypes[i]];
		[item setState:(filetype == filetypes[i] ? NSOnState : NSOffState)];
		if (filetype == filetypes[i])
			selectedIndex = i + 1;
		[menu addItem:item];
	}
	[filetypePopup setPullsDown:YES];
	[filetypePopup selectItemAtIndex:selectedIndex];
	
	// Option view
	if (filetype == NSTIFFFileType)
	{
		[optionTabView selectTabViewItemWithIdentifier:[NSString stringWithFormat:@"%d", NSTIFFFileType]];
		[optionTabView setHidden:NO];
	}
	else if (filetype == NSJPEGFileType)
	{
		[optionTabView selectTabViewItemWithIdentifier:[NSString stringWithFormat:@"%d", NSJPEGFileType]];
		[optionTabView setHidden:NO];
	}
	else {
		[optionTabView setHidden:YES];
	}
	[tiffOptionLabel setStringValue:[NSString stringWithFormat:@"%@ :", NSLocalizedString(@"Compression", nil)]];
	[jpgOptionLabel setStringValue:[NSString stringWithFormat:@"%@ :", NSLocalizedString(@"Quality", nil)]];
	
	count = 3;
	menu = [tiffOptionPopup menu];
	NSString *compressionNames[3] = {NSLocalizedString(@"None", nil), @"LZW", @"PackBits"};
	NSTIFFCompression compressions[3] = {NSTIFFCompressionNone, NSTIFFCompressionLZW, NSTIFFCompressionPackBits};
	[menu addItemWithTitle:[NSString string] action:nil keyEquivalent:@""];
	for (i = 0; i < count; i++)
	{
		NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:compressionNames[i] action:@selector(selectTiffOption:) keyEquivalent:@""] autorelease];
		[item setTag:compressions[i]];
		[item setState:(tiffCompression == compressions[i] ? NSOnState : NSOffState)];
		if (tiffCompression == compressions[i])
			selectedIndex = i + 1;
		[menu addItem:item];
	}
	[tiffOptionPopup setPullsDown:YES];
	[tiffOptionPopup selectItemAtIndex:selectedIndex];
	[[jpgOptionSlider cell] setControlSize:NSMiniControlSize];
	[jpgOptionSlider setMinValue:0.0];
	[jpgOptionSlider setMaxValue:1.0];
	[jpgOptionSlider setNumberOfTickMarks:11];
	[jpgOptionSlider setTickMarkPosition:NSTickMarkBelow];
	[jpgOptionSlider setAllowsTickMarkValuesOnly:YES];
	[jpgOptionSlider setFloatValue:jpgFactor];
	[jpgOptionSlider setTarget:self];
	[jpgOptionSlider setAction:@selector(slideJpgOption:)];
	[jpgOptionField setEditable:NO];
	[jpgOptionField setSelectable:NO];
	[jpgOptionField setBordered:NO];
	[jpgOptionField setDrawsBackground:NO];
	[jpgOptionField setTextColor:[NSColor whiteColor]];
	[jpgOptionField setStringValue:[NSString stringWithFormat:@"%.1f", jpgFactor]];
	
	// Notification
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResize:) name:NSWindowDidResizeNotification object:[self window]];
	
	[self addSubview:scrollView];
	[self addSubview:toolsView];
	[toolsView addSubview:onlyVisibleButton];
	[toolsView addSubview:updateButton];
	[toolsView addSubview:sizeLabel];
	[toolsView addSubview:widthField];
	[toolsView addSubview:heightField];
	[toolsView addSubview:scaleLabel];
	[toolsView addSubview:scaleField];
	[toolsView addSubview:lockButton];
	[toolsView addSubview:filetypeLabel];
	[toolsView addSubview:filetypePopup];
	[toolsView addSubview:optionTabView];
	[[tabViewItem0 view] addSubview:tiffOptionLabel];
	[[tabViewItem0 view] addSubview:tiffOptionPopup];
	[[tabViewItem1 view] addSubview:jpgOptionLabel];
	[[tabViewItem1 view] addSubview:jpgOptionSlider];
	[[tabViewItem1 view] addSubview:jpgOptionField];
	[toolsView addSubview:filesizeLabel];
	[toolsView addSubview:filesizeField];
}

- (void)constructDoneButton
{
	NSRect r = [self doneButtonRect];
	doneButton = [[SBBLKGUIButton alloc] initWithFrame:r];
	[doneButton setTitle:NSLocalizedString(@"Done", nil)];
	[doneButton setTarget:self];
	[doneButton setAction:@selector(save:)];
	[doneButton setEnabled:NO];
	[doneButton setKeyEquivalent:@"\r"];	// busy if button is added into a view
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

#pragma mark Delegate

- (void)windowDidResize:(NSNotification *)notification
{
	NSRect imageRect = [imageView frame];
	NSSize imageSize = [[imageView image] size];
	NSRect scrollBounds = NSZeroRect;
	scrollBounds.size = [scrollView frame].size;
	if (imageSize.width != imageRect.size.width)
	{
		imageRect.size.width = imageSize.width;
	}
	if (imageSize.height != imageRect.size.height)
	{
		imageRect.size.height = imageSize.height;
	}
	if (imageRect.size.width < scrollBounds.size.width)
	{
		imageRect.size.width = scrollBounds.size.width;
	}
	if (imageRect.size.height < scrollBounds.size.height)
	{
		imageRect.size.height = scrollBounds.size.height;
	}
	if (!NSEqualRects(imageRect, [imageView frame]))
	{
		[imageView setFrame:imageRect];
	}
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	id field = [aNotification object];
	NSDictionary *userInfo = nil;
	[self destructUpdateTimer];
	if ([self shouldShowSizeWarning:field])
	{
		NSString *aTitle = NSLocalizedString(@"The application may not respond if the processing is continued. Are you sure you want to continue?", nil);
		int r = NSRunAlertPanel(aTitle, @"", NSLocalizedString(@"Continue", nil), NSLocalizedString(@"Cancel", nil), nil);
		if (r == NSOKButton)
		{
			userInfo = [NSDictionary dictionaryWithObject:field forKey:@"Object"];
			updateTimer = [[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateWithTimer:) userInfo:userInfo repeats:NO] retain];
		}
		else {
			if (field == widthField)
			{
				[widthField setIntValue:(int)successSize.width];
			}
			else if (field == heightField)
			{
				[heightField setIntValue:(int)successSize.height];
			}
			else if (field == scaleField)
			{
				[scaleField setIntValue:(int)(successScale * 100)];
			}
		}
	}
	else {
		userInfo = [NSDictionary dictionaryWithObject:field forKey:@"Object"];
		updateTimer = [[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateWithTimer:) userInfo:userInfo repeats:NO] retain];
	}
}

- (void)controlTextDidEndEditing:(NSNotification *)aNotification
{
	
}

#pragma mark -
#pragma mark Actions (Private)

- (BOOL)shouldShowSizeWarning:(id)field
{
	BOOL r = NO;
	if (field == scaleField)
	{
		CGFloat s = (CGFloat)[scaleField intValue] / 100;
		if ([lockButton state] == NSOffState)
		{
			if ([onlyVisibleButton state] == NSOnState)
			{
				r = (visibleRect.size.width * s >= kSBMaxImageSizeWidth);
				if (!r)
					r = (visibleRect.size.height * s >= kSBMaxImageSizeHeight);
			}
			else {
				r = ([image size].width * s >= kSBMaxImageSizeWidth);
				if (!r)
					r = ([image size].height * s >= kSBMaxImageSizeHeight);
			}
		}
	}
	else if (field == widthField)
	{
		int w = [widthField intValue];
		r = (w >= kSBMaxImageSizeWidth);
		if (!r)
		{
			if ([lockButton state] == NSOffState)
			{
				CGFloat per = 1.0;
				if ([onlyVisibleButton state] == NSOnState)
				{
					per = w / visibleRect.size.width;
					r = (visibleRect.size.height * per >= kSBMaxImageSizeHeight);
				}
				else {
					per = w / visibleRect.size.width;
					r = ([image size].height * per >= kSBMaxImageSizeHeight);
				}
			}
		}
	}
	else if (field == heightField)
	{
		int h = [heightField intValue];
		r = (h >= kSBMaxImageSizeHeight);
		if (!r)
		{
			if ([lockButton state] == NSOffState)
			{
				CGFloat per = 1.0;
				if ([onlyVisibleButton state] == NSOnState)
				{
					per = h / visibleRect.size.height;
					r = (visibleRect.size.width * per >= kSBMaxImageSizeWidth);
				}
				else {
					per = h / visibleRect.size.height;
					r = ([image size].width * per >= kSBMaxImageSizeWidth);
				}
			}
		}
	}
	return r;
}

- (void)setTarget:(id)inTarget
{
	target = inTarget;
}

- (void)setVisibleRect:(NSRect)inVisibleRect
{
	visibleRect = inVisibleRect;
}

- (BOOL)setImage:(NSImage *)inImage
{
	BOOL can = NO;
	if (inImage)
	{
		can = !(NSEqualSizes([inImage size], NSZeroSize) || ([inImage size].width == 0 || [inImage size].height == 0));
		if (can)
		{
			NSRect r = NSZeroRect;
			BOOL enableVisiblity = NO;
			if (image != inImage)
			{
				[inImage retain];
				[image release];
				image = inImage;
			}
			if ([onlyVisibleButton state] == NSOnState)
			{
				r.size = visibleRect.size;
			}
			else {
				r.size = [image size];
			}
			enableVisiblity = !(NSEqualSizes(visibleRect.size, [image size]) || (visibleRect.size.width == 0 || visibleRect.size.height == 0));
			[onlyVisibleButton setEnabled:enableVisiblity];
			if (!enableVisiblity && [onlyVisibleButton state] == NSOnState)
			{
				[onlyVisibleButton setState:NSOffState];
				r.size = [image size];
			}
			else {
				[onlyVisibleButton setState:[[NSUserDefaults standardUserDefaults] boolForKey:kSBSnapshotOnlyVisiblePortion] ? NSOnState : NSOffState];
			}
			// Set image to image view
			[widthField setIntValue:(int)r.size.width];
			[heightField setIntValue:(int)r.size.height];
			[scaleField setIntValue:100];
			[self updateForField:nil];
			successScale = 1.0;
		}
	}
	return can;
}

- (void)destructUpdateTimer
{
	if (updateTimer)
	{
		[updateTimer invalidate];
		[updateTimer release];
		updateTimer = nil;
	}
}

- (void)showProgress
{
	NSRect r = NSZeroRect;
	r = [scrollView frame];
	[progressBackgroundView setFrame:r];
	[progressIndicator startAnimation:nil];
	[self addSubview:progressBackgroundView];
}

- (void)hideProgress
{
	[progressIndicator stopAnimation:nil];
	[progressBackgroundView removeFromSuperview];
}

- (void)updateWithTimer:(NSTimer *)timer
{
	NSDictionary *userInfo = [timer userInfo];
	id field = (userInfo ? [userInfo objectForKey:@"Object"] : nil);
	[self destructUpdateTimer];
	[self updateForField:field];
}

- (void)updateForField:(id)field
{
	// Show Progress
	[self showProgress];
	// Perform update
	if ([self respondsToSelector:@selector(updatingForField:)])
	{
		NSArray *modes = [NSArray arrayWithObjects:NSDefaultRunLoopMode, NSEventTrackingRunLoopMode, NSModalPanelRunLoopMode, nil];
		[self performSelector:@selector(updatingForField:) withObject:field afterDelay:0 inModes:modes];
	}
}

- (void)updatingForField:(id)field
{
	[self updateFieldsForField:field];
	[self updatePreviewImage];
	// Hide Progress
	[self hideProgress];
}

- (void)updatePreviewImage
{
	CGFloat width = (CGFloat)[widthField intValue];
	CGFloat height = (CGFloat)[heightField intValue];
	unsigned int length = 0;
	NSImage *compressedImage = nil;
	if (data)
	{
		[data release];
		data = nil;
	}
	data = [self imageData:filetype size:NSMakeSize(width, height)];
	[data retain];
	if (data)
	{
		compressedImage = [[[NSImage alloc] initWithData:data] autorelease];
	}
	if (compressedImage)
	{
		NSString *fileSizeString = nil;
		// Set image to image view
		[imageView setImage:compressedImage];
		// Get length of image data
		length = [data length];
		// Set length as string
		fileSizeString = [NSString bytesStringForLength:length];
		[filesizeField setStringValue:fileSizeString];
		[doneButton setEnabled:YES];
	}
	else {
		[doneButton setEnabled:NO];
	}
}

- (void)updateFieldsForField:(id)field
{
	BOOL locked = [lockButton state] == NSOffState;
	NSSize newSize = NSZeroSize;
	NSRect r = [imageView frame];
	CGFloat value = 0.0;
	CGFloat per = 1.0;
	if ([onlyVisibleButton state] == NSOnState)
	{
		newSize = visibleRect.size;
	}
	else {
		newSize = [image size];
	}
	if ([field isEqual:widthField])
	{
		value = (CGFloat)[widthField intValue];
		if (value < 1)
		{
			value = 1;
		}
		if (locked)
		{
			if ([onlyVisibleButton state] == NSOnState)
			{
				per = value / visibleRect.size.width;
				newSize.height = visibleRect.size.height * per;
			}
			else {
				per = value / [image size].width;
				newSize.height = [image size].height * per;
			}
			if (newSize.height < 1)
			{
				newSize.height = 1;
			}
			if (per < 0.01)
			{
				per = 0.01;
			}
			[heightField setIntValue:(int)newSize.height];
			[scaleField setIntValue:(int)(per * 100)];
		}
		newSize.width = value;
		[widthField setIntValue:(int)newSize.width];
	}
	else if ([field isEqual:heightField])
	{
		value = (CGFloat)[heightField intValue];
		if (value < 1)
		{
			[heightField setIntValue:1];
			value = 1;
		}
		if (locked)
		{
			if ([onlyVisibleButton state] == NSOnState)
			{
				per = value / visibleRect.size.height;
				newSize.width = visibleRect.size.width * per;
			}
			else {
				per = value / [image size].height;
				newSize.width = [image size].width * per;
			}
			if (newSize.width < 1)
			{
				newSize.width = 1;
			}
			if (per < 0.01)
			{
				per = 0.01;
			}
			[widthField setIntValue:(int)newSize.width];
			[scaleField setIntValue:(int)(per * 100)];
		}
		newSize.height = value;
		[heightField setIntValue:(int)newSize.height];
	}
	else if ([field isEqual:scaleField])
	{
		if (locked)
		{
			per = ((CGFloat)[scaleField intValue] / 100);
			if (per < 0.01)
			{
				[scaleField setIntValue:1];
				per = 0.01;
			}
			if ([onlyVisibleButton state] == NSOnState)
			{
				newSize.width = visibleRect.size.width * per;
				newSize.height = visibleRect.size.height * per;
			}
			else {
				newSize.width = [image size].width * per;
				newSize.height = [image size].height * per;
			}
			[widthField setIntValue:(int)newSize.width];
			[heightField setIntValue:(int)newSize.height];
			[scaleField setIntValue:(int)(per * 100)];
			successScale = per;
		}
	}
	else {
		if (locked)
		{
			per = ((CGFloat)[scaleField intValue] / 100);
		}
		if (per < 0.01)
		{
			[scaleField setIntValue:1];
			per = 0.01;
		}
		if ([onlyVisibleButton state] == NSOnState)
		{
			newSize.width = visibleRect.size.width * per;
			newSize.height = visibleRect.size.height * per;
		}
		else {
			newSize.width = [image size].width * per;
			newSize.height = [image size].height * per;
		}
		[widthField setIntValue:(int)newSize.width];
		[heightField setIntValue:(int)newSize.height];
		[scaleField setIntValue:(int)(per * 100)];
	}
	[self updatePreviewImage];
	r.size = newSize;
	if (r.size.width < [scrollView frame].size.width)
		r.size.width = [scrollView frame].size.width;
	if (r.size.height < [scrollView frame].size.height)
		r.size.height = [scrollView frame].size.height;
	[imageView setFrame:r];
	[imageView display];
	[imageView scrollPoint:NSMakePoint(0, r.size.height)];
}

#pragma mark -
#pragma mark Actions

- (void)checkOnlyVisible:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setBool:([onlyVisibleButton state] == NSOnState) forKey:kSBSnapshotOnlyVisiblePortion];
	[self updateForField:nil];
}

- (void)update:(id)sender
{
	if (target)
	{
		if ([target respondsToSelector:@selector(visibleRectOfSelectedWebDocumentView)])
		{
			visibleRect = [target visibleRectOfSelectedWebDocumentView];
		}
		if ([target respondsToSelector:@selector(selectedWebViewImage)])
		{
			NSImage *selectedWebViewImage = [target selectedWebViewImage];
			if (selectedWebViewImage)
			{
				[self setImage:selectedWebViewImage];
			}
		}
	}
}

- (void)lock:(id)sender
{
	BOOL locked = [lockButton state] == NSOffState;
	if (locked)
	{
		[self updateForField:widthField];
	}
	[scaleField setEnabled:locked];
}

- (void)selectFiletype:(id)sender
{
	NSMenuItem *item = (NSMenuItem *)sender;
	int tag = [item tag];
	if (filetype != tag)
	{
		NSArray *items = [[filetypePopup menu] itemArray];
		int i = 0;
		int count = [items count];
		filetype = tag;
		for (i = 0; i < count; i ++)
		{
			NSMenuItem *item = [items objectAtIndex:i];
			[item setState:(filetype == [item tag] ? NSOnState : NSOffState)];
		}
		// Update image
		[self updateForField:nil];
		// Save to defaults
		[[NSUserDefaults standardUserDefaults] setInteger:filetype forKey:kSBSnapshotFileType];
	}
	if (filetype == NSTIFFFileType)
	{
		[optionTabView selectTabViewItemWithIdentifier:[NSString stringWithFormat:@"%d", NSTIFFFileType]];
		[optionTabView setHidden:NO];
	}
	else if (filetype == NSJPEGFileType)
	{
		[optionTabView selectTabViewItemWithIdentifier:[NSString stringWithFormat:@"%d", NSJPEGFileType]];
		[optionTabView setHidden:NO];
	}
	else {
		[optionTabView setHidden:YES];
	}
}

- (void)selectTiffOption:(id)sender
{
	NSMenuItem *item = (NSMenuItem *)sender;
	int tag = [item tag];
	if (tiffCompression != tag)
	{
		NSArray *items = [[tiffOptionPopup menu] itemArray];
		int i = 0;
		int count = [items count];
		tiffCompression = tag;
		for (i = 0; i < count; i ++)
		{
			NSMenuItem *item = [items objectAtIndex:i];
			[item setState:(tiffCompression == [item tag] ? NSOnState : NSOffState)];
		}
		// Update image
		[self updateForField:nil];
		// Save to defaults
		[[NSUserDefaults standardUserDefaults] setInteger:tiffCompression forKey:kSBSnapshotTIFFCompression];
	}
}

- (void)slideJpgOption:(id)sender
{
	jpgFactor = [jpgOptionSlider floatValue];
	[jpgOptionField setStringValue:[NSString stringWithFormat:@"%.1f", jpgFactor]];
	// Save to defaults
	[[NSUserDefaults standardUserDefaults] setFloat:jpgFactor forKey:kSBSnapshotJPGFactor];
	// Update image
	[self destructUpdateTimer];
	updateTimer = [[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateWithTimer:) userInfo:nil repeats:NO] retain];
}

- (void)save:(id)sender
{
	if (data)
	{
		SBSavePanel *panel = [SBSavePanel savePanel];
		NSString *filename = self.filename;
		[panel setCanCreateDirectories:YES];
		if ([panel runModalForDirectory:nil file:filename] == NSOKButton)
		{
			NSString *path = [panel filename];
			if ([data writeToFile:path atomically:YES])
			{
				[self done];
			}
		}
	}
}

- (void)destruct
{
	if (image)
	{
		[imageView setImage:nil];
		[image release];
		image = nil;
	}
	[self destructUpdateTimer];
	visibleRect = NSZeroRect;
}

#pragma mark -

- (NSString *)filename
{
	NSString *filename = nil;
	if (filetype == NSTIFFFileType)
	{
		filename = [title ? title : NSLocalizedString(@"Untitled", nil) stringByAppendingPathExtension:@"tiff"];
	}
	else if (filetype == NSGIFFileType)
	{
		filename = [title ? title : NSLocalizedString(@"Untitled", nil) stringByAppendingPathExtension:@"gif"];
	}
	else if (filetype == NSJPEGFileType)
	{
		filename = [title ? title : NSLocalizedString(@"Untitled", nil) stringByAppendingPathExtension:@"jpg"];
	}
	else if (filetype == NSPNGFileType)
	{
		filename = [title ? title : NSLocalizedString(@"Untitled", nil) stringByAppendingPathExtension:@"png"];
	}
	else {
		filename = title ? title : NSLocalizedString(@"Untitled", nil);
	}
	return filename;
}

- (NSData *)imageData:(NSBitmapImageFileType)inFiletype size:(NSSize)size
{
	NSData *aData = nil;
	NSImage *anImage = nil;
	NSBitmapImageRep *bitmapImageRep = nil;
	NSDictionary *properties = nil;
	NSRect fromRect = NSZeroRect;
	
	// Resize
	anImage = [[NSImage alloc] initWithSize:size];
	if ([onlyVisibleButton state] == NSOnState)
	{
		fromRect = visibleRect;
		fromRect.origin.y = [image size].height - NSMaxY(visibleRect);
	}
	else {
		fromRect.size = [image size];
	}
	[anImage lockFocus];
	[image drawInRect:NSMakeRect(0, 0, size.width, size.height) fromRect:fromRect operation:NSCompositeSourceOver fraction:1.0];
	[anImage unlockFocus];
	
	// Change filetype
	aData = [anImage TIFFRepresentation];
	[anImage release];
	if (inFiletype == NSTIFFFileType)
	{
		bitmapImageRep = [NSBitmapImageRep imageRepWithData:aData];
		aData = [bitmapImageRep TIFFRepresentationUsingCompression:tiffCompression factor:1.0];
	}
	else if (inFiletype == NSGIFFileType)
	{
		bitmapImageRep = [NSBitmapImageRep imageRepWithData:aData];
		properties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSImageDitherTransparency, nil];
		aData = [bitmapImageRep representationUsingType:NSGIFFileType properties:properties];
	}
	else if (inFiletype == NSJPEGFileType)
	{
		bitmapImageRep = [NSBitmapImageRep imageRepWithData:aData];
		properties = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:jpgFactor] forKey:NSImageCompressionFactor];
		aData = [bitmapImageRep representationUsingType:NSJPEGFileType properties:properties];
	}
	else if (inFiletype == NSPNGFileType)
	{
		bitmapImageRep = [NSBitmapImageRep imageRepWithData:aData];
		aData = [bitmapImageRep representationUsingType:NSPNGFileType properties:nil];
	}
	if (aData)
	{
		successSize = size;
	}
	return aData;
}

@end
