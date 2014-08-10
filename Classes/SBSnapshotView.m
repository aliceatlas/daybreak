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

- (instancetype)initWithFrame:(NSRect)frame
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
        self.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin;
	}
	return self;
}

- (void)dealloc
{
	[NSNotificationCenter.defaultCenter removeObserver:self name:NSWindowDidResizeNotification object:self.window];
	[self destructUpdateTimer];
	target = nil;
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
	CGFloat buttonMargin = self.buttonMargin;
	r.size = self.buttonSize;
	r.origin.x = (self.bounds.size.width - (r.size.width * 2 + buttonMargin)) / 2 + r.size.width + buttonMargin;
	return r;
}

- (NSRect)cancelButtonRect
{
	NSRect r = NSZeroRect;
	CGFloat buttonMargin = self.buttonMargin;
	r.size = self.buttonSize;
	r.origin.x = (self.bounds.size.width - (r.size.width * 2 + buttonMargin)) / 2;
	return r;
}

#pragma mark Construction

- (void)constructViews
{
	NSTabViewItem *tabViewItem0 = nil;
	NSTabViewItem *tabViewItem1 = nil;
	NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
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
    lockButton.imagePosition = NSImageOnly;
    lockButton.buttonType = NSToggleButton;
    lockButton.image = [NSImage imageNamed:@"Icon_Lock.png"];
    lockButton.alternateImage = [NSImage imageNamed:@"Icon_Unlock.png"];
	[lockButton.cell setImageScaling:NSImageScaleNone];
    sizeLabel.bordered = NO;
    lockButton.bordered = NO;
    scaleLabel.bordered = NO;
    filetypeLabel.bordered = NO;
    tiffOptionLabel.bordered = NO;
    jpgOptionLabel.bordered = NO;
    filesizeLabel.bordered = NO;
    filesizeField.bordered = NO;
    sizeLabel.editable = NO;
    scaleLabel.editable = NO;
    filetypeLabel.editable = NO;
    tiffOptionLabel.editable = NO;
    jpgOptionLabel.editable = NO;
    filesizeLabel.editable = NO;
    filesizeField.editable = NO;
    sizeLabel.drawsBackground = NO;
    scaleLabel.drawsBackground = NO;
    filetypeLabel.drawsBackground = NO;
    tiffOptionLabel.drawsBackground = NO;
    jpgOptionLabel.drawsBackground = NO;
    filesizeLabel.drawsBackground = NO;
    filesizeField.drawsBackground = NO;
    sizeLabel.textColor = NSColor.whiteColor;
    scaleLabel.textColor = NSColor.whiteColor;
    filetypeLabel.textColor = NSColor.whiteColor;
    tiffOptionLabel.textColor = NSColor.whiteColor;
    jpgOptionLabel.textColor = NSColor.whiteColor;
    filesizeLabel.textColor = NSColor.whiteColor;
    filesizeField.textColor = NSColor.whiteColor;
    optionTabView.tabViewType = NSNoTabsNoBorder;
    optionTabView.drawsBackground = NO;
	
	// Controls
    onlyVisibleButton.buttonType = NSSwitchButton;
    onlyVisibleButton.state = [defaults boolForKey:kSBSnapshotOnlyVisiblePortion] ? NSOnState : NSOffState;
    updateButton.buttonType = NSMomentaryPushInButton;
    onlyVisibleButton.target = self;
    updateButton.target = self;
    onlyVisibleButton.action = @selector(checkOnlyVisible:);
    updateButton.action = @selector(update:);
    onlyVisibleButton.title = NSLocalizedString(@"Only visible portion", nil);
    updateButton.image = [NSImage imageNamed:@"Icon_Camera.png"];
    updateButton.title = NSLocalizedString(@"Update", nil);
    onlyVisibleButton.font = [NSFont systemFontOfSize:10.0];
    updateButton.font = [NSFont systemFontOfSize:11.0];
    updateButton.keyEquivalentModifierMask = NSCommandKeyMask;
	updateButton.keyEquivalent = @"r";
    widthField.delegate = self;
    heightField.delegate = self;
    scaleField.delegate = self;
	
	// Views
	tabViewItem0 = [[NSTabViewItem alloc] initWithIdentifier:[NSString stringWithFormat:@"%d", NSTIFFFileType]];
	tabViewItem1 = [[NSTabViewItem alloc] initWithIdentifier:[NSString stringWithFormat:@"%d", NSJPEGFileType]];
    scrollView.documentView = imageView;
    scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    scrollView.hasHorizontalScroller = YES;
    scrollView.hasVerticalScroller = YES;
    scrollView.autohidesScrollers = YES;
    scrollView.backgroundColor = NSColor.blackColor;
    scrollView.drawsBackground = YES;
	[optionTabView addTabViewItem:tabViewItem0];
	[optionTabView addTabViewItem:tabViewItem1];
	
    sizeLabel.stringValue = [NSString stringWithFormat:@"%@ :", NSLocalizedString(@"Size", nil)];
    scaleLabel.stringValue = [NSString stringWithFormat:@"%@ :", NSLocalizedString(@"Scale", nil)];
    filetypeLabel.stringValue = [NSString stringWithFormat:@"%@ :", NSLocalizedString(@"File Type", nil)];
    filesizeLabel.stringValue = [NSString stringWithFormat:@"%@ :", NSLocalizedString(@"File Size", nil)];
    progressField.stringValue = NSLocalizedString(@"Updating...", nil);
	
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
    menu = filetypePopup.menu;
	count = 4;
	NSString *fileTypeNames[4] = {@"TIFF", @"GIF", @"JPEG", @"PNG"};
	NSBitmapImageFileType filetypes[4] = {NSTIFFFileType, NSGIFFileType, NSJPEGFileType, NSPNGFileType};
	[menu addItemWithTitle:[NSString string] action:nil keyEquivalent:@""];
	for (i = 0; i < count; i++)
	{
		NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:fileTypeNames[i] action:@selector(selectFiletype:) keyEquivalent:@""];
        item.target = self;
        item.tag = filetypes[i];
        item.state = filetype == filetypes[i] ? NSOnState : NSOffState;
		if (filetype == filetypes[i])
			selectedIndex = i + 1;
		[menu addItem:item];
	}
    filetypePopup.pullsDown = YES;
	[filetypePopup selectItemAtIndex:selectedIndex];
	
	// Option view
	if (filetype == NSTIFFFileType)
	{
		[optionTabView selectTabViewItemWithIdentifier:[NSString stringWithFormat:@"%d", NSTIFFFileType]];
        optionTabView.hidden = NO;
	}
	else if (filetype == NSJPEGFileType)
	{
		[optionTabView selectTabViewItemWithIdentifier:[NSString stringWithFormat:@"%d", NSJPEGFileType]];
        optionTabView.hidden = NO;
	}
	else {
        optionTabView.hidden = YES;
	}
    tiffOptionLabel.stringValue = [NSString stringWithFormat:@"%@ :", NSLocalizedString(@"Compression", nil)];
    jpgOptionLabel.stringValue = [NSString stringWithFormat:@"%@ :", NSLocalizedString(@"Quality", nil)];
	
	count = 3;
	menu = tiffOptionPopup.menu;
	NSString *compressionNames[3] = {NSLocalizedString(@"None", nil), @"LZW", @"PackBits"};
	NSTIFFCompression compressions[3] = {NSTIFFCompressionNone, NSTIFFCompressionLZW, NSTIFFCompressionPackBits};
	[menu addItemWithTitle:[NSString string] action:nil keyEquivalent:@""];
	for (i = 0; i < count; i++)
	{
		NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:compressionNames[i] action:@selector(selectTiffOption:) keyEquivalent:@""];
        item.tag = compressions[i];
        item.state = tiffCompression == compressions[i] ? NSOnState : NSOffState;
		if (tiffCompression == compressions[i])
			selectedIndex = i + 1;
		[menu addItem:item];
	}
    tiffOptionPopup.pullsDown = YES;
	[tiffOptionPopup selectItemAtIndex:selectedIndex];
	jpgOptionSlider.controlSize = NSMiniControlSize;
    jpgOptionSlider.minValue = 0.0;
    jpgOptionSlider.maxValue = 1.0;
    jpgOptionSlider.numberOfTickMarks = 11;
    jpgOptionSlider.tickMarkPosition = NSTickMarkBelow;
    jpgOptionSlider.allowsTickMarkValuesOnly = YES;
    jpgOptionSlider.floatValue = jpgFactor;
    jpgOptionSlider.target = self;
    jpgOptionSlider.action = @selector(slideJpgOption:);
    jpgOptionField.editable = NO;
    jpgOptionField.selectable = NO;
    jpgOptionField.bordered = NO;
    jpgOptionField.drawsBackground = NO;
    jpgOptionField.textColor = NSColor.whiteColor;
    jpgOptionField.stringValue = [NSString stringWithFormat:@"%.1f", jpgFactor];
	
	// Notification
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(windowDidResize:) name:NSWindowDidResizeNotification object:self.window];
	
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
	[tabViewItem0.view addSubview:tiffOptionLabel];
	[tabViewItem0.view addSubview:tiffOptionPopup];
	[tabViewItem1.view addSubview:jpgOptionLabel];
	[tabViewItem1.view addSubview:jpgOptionSlider];
	[tabViewItem1.view addSubview:jpgOptionField];
	[toolsView addSubview:filesizeLabel];
	[toolsView addSubview:filesizeField];
}

- (void)constructDoneButton
{
	NSRect r = self.doneButtonRect;
	doneButton = [[SBBLKGUIButton alloc] initWithFrame:r];
    doneButton.title = NSLocalizedString(@"Done", nil);
    doneButton.target = self;
    doneButton.action = @selector(save:);
    doneButton.enabled = NO;
	doneButton.keyEquivalent = @"\r";	// busy if button is added into a view
	[self addSubview:doneButton];
}

- (void)constructCancelButton
{
	NSRect r = self.cancelButtonRect;
	cancelButton = [[SBBLKGUIButton alloc] initWithFrame:r];
    cancelButton.title = NSLocalizedString(@"Cancel", nil);
    cancelButton.target = self;
    cancelButton.action = @selector(cancel);
	cancelButton.keyEquivalent = @"\e";
	[self addSubview:cancelButton];
}

#pragma mark Delegate

- (void)windowDidResize:(NSNotification *)notification
{
	NSRect imageRect = imageView.frame;
	NSSize imageSize = imageView.image.size;
	NSRect scrollBounds = NSZeroRect;
	scrollBounds.size = scrollView.frame.size;
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
	if (!NSEqualRects(imageRect, imageView.frame))
	{
		imageView.frame = imageRect;
	}
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	id field = aNotification.object;
	NSDictionary *userInfo = nil;
	[self destructUpdateTimer];
	if ([self shouldShowSizeWarning:field])
	{
		NSString *aTitle = NSLocalizedString(@"The application may not respond if the processing is continued. Are you sure you want to continue?", nil);
		int r = NSRunAlertPanel(aTitle, @"", NSLocalizedString(@"Continue", nil), NSLocalizedString(@"Cancel", nil), nil);
		if (r == NSOKButton)
		{
			userInfo = @{@"Object": field};
			updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateWithTimer:) userInfo:userInfo repeats:NO];
		}
		else {
			if (field == widthField)
			{
                widthField.intValue = (int)successSize.width;
			}
			else if (field == heightField)
			{
                heightField.intValue = (int)successSize.height;
			}
			else if (field == scaleField)
			{
                scaleField.intValue = (int)(successScale * 100);
			}
		}
	}
	else {
		userInfo = @{@"Object": field};
		updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateWithTimer:) userInfo:userInfo repeats:NO];
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
		CGFloat s = (CGFloat)scaleField.intValue / 100;
		if (lockButton.state == NSOffState)
		{
			if (onlyVisibleButton.state == NSOnState)
			{
				r = (visibleRect.size.width * s >= kSBMaxImageSizeWidth);
				if (!r)
					r = (visibleRect.size.height * s >= kSBMaxImageSizeHeight);
			}
			else {
				r = (image.size.width * s >= kSBMaxImageSizeWidth);
				if (!r)
					r = (image.size.height * s >= kSBMaxImageSizeHeight);
			}
		}
	}
	else if (field == widthField)
	{
		int w = widthField.intValue;
		r = (w >= kSBMaxImageSizeWidth);
		if (!r)
		{
			if (lockButton.state == NSOffState)
			{
				CGFloat per = 1.0;
				if (onlyVisibleButton.state == NSOnState)
				{
					per = w / visibleRect.size.width;
					r = (visibleRect.size.height * per >= kSBMaxImageSizeHeight);
				}
				else {
					per = w / visibleRect.size.width;
					r = (image.size.height * per >= kSBMaxImageSizeHeight);
				}
			}
		}
	}
	else if (field == heightField)
	{
		int h = heightField.intValue;
		r = (h >= kSBMaxImageSizeHeight);
		if (!r)
		{
			if (lockButton.state == NSOffState)
			{
				CGFloat per = 1.0;
				if (onlyVisibleButton.state == NSOnState)
				{
					per = h / visibleRect.size.height;
					r = (visibleRect.size.width * per >= kSBMaxImageSizeWidth);
				}
				else {
					per = h / visibleRect.size.height;
					r = (image.size.width * per >= kSBMaxImageSizeWidth);
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
		can = !(NSEqualSizes(inImage.size, NSZeroSize) || (inImage.size.width == 0 || inImage.size.height == 0));
		if (can)
		{
			NSRect r = NSZeroRect;
			BOOL enableVisiblity = NO;
			if (image != inImage)
			{
				image = inImage;
			}
			if (onlyVisibleButton.state == NSOnState)
			{
				r.size = visibleRect.size;
			}
			else {
				r.size = image.size;
			}
			enableVisiblity = !(NSEqualSizes(visibleRect.size, image.size) || (visibleRect.size.width == 0 || visibleRect.size.height == 0));
            onlyVisibleButton.enabled = enableVisiblity;
			if (!enableVisiblity && onlyVisibleButton.state == NSOnState)
			{
                onlyVisibleButton.state = NSOffState;
				r.size = image.size;
			}
			else {
                onlyVisibleButton.state = [[NSUserDefaults standardUserDefaults] boolForKey:kSBSnapshotOnlyVisiblePortion] ? NSOnState : NSOffState;
			}
			// Set image to image view
            widthField.intValue = (int)r.size.width;
            heightField.intValue = (int)r.size.height;
            scaleField.intValue = 100;
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
		updateTimer = nil;
	}
}

- (void)showProgress
{
    progressBackgroundView.frame = scrollView.frame;
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
	NSDictionary *userInfo = timer.userInfo;
	id field = userInfo ? userInfo[@"Object"] : nil;
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
		NSArray *modes = @[NSDefaultRunLoopMode, NSEventTrackingRunLoopMode, NSModalPanelRunLoopMode];
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
	CGFloat width = (CGFloat)widthField.intValue;
	CGFloat height = (CGFloat)heightField.intValue;
	unsigned int length = 0;
	NSImage *compressedImage = nil;
	data = [self imageData:filetype size:NSMakeSize(width, height)];
	if (data)
	{
		compressedImage = [[NSImage alloc] initWithData:data];
	}
	if (compressedImage)
	{
		NSString *fileSizeString = nil;
		// Set image to image view
        imageView.image = compressedImage;
		// Get length of image data
		length = data.length;
		// Set length as string
		fileSizeString = [NSString bytesStringForLength:length];
        filesizeField.stringValue = fileSizeString;
        doneButton.enabled = YES;
	}
	else {
        doneButton.enabled = NO;
	}
}

- (void)updateFieldsForField:(id)field
{
	BOOL locked = lockButton.state == NSOffState;
	NSSize newSize = NSZeroSize;
	NSRect r = imageView.frame;
	CGFloat value = 0.0;
	CGFloat per = 1.0;
	if (onlyVisibleButton.state == NSOnState)
	{
		newSize = visibleRect.size;
	}
	else {
		newSize = image.size;
	}
	if ([field isEqual:widthField])
	{
		value = (CGFloat)widthField.intValue;
		if (value < 1)
		{
			value = 1;
		}
		if (locked)
		{
			if (onlyVisibleButton.state == NSOnState)
			{
				per = value / visibleRect.size.width;
				newSize.height = visibleRect.size.height * per;
			}
			else {
				per = value / image.size.width;
				newSize.height = image.size.height * per;
			}
			if (newSize.height < 1)
			{
				newSize.height = 1;
			}
			if (per < 0.01)
			{
				per = 0.01;
			}
            heightField.intValue = (int)newSize.height;
            scaleField.intValue = (int)(per * 100);
		}
		newSize.width = value;
        widthField.intValue = (int)newSize.width;
	}
	else if ([field isEqual:heightField])
	{
		value = (CGFloat)heightField.intValue;
		if (value < 1)
		{
            heightField.intValue = 1;
			value = 1;
		}
		if (locked)
		{
			if (onlyVisibleButton.state == NSOnState)
			{
				per = value / visibleRect.size.height;
				newSize.width = visibleRect.size.width * per;
			}
			else {
				per = value / image.size.height;
				newSize.width = image.size.width * per;
			}
			if (newSize.width < 1)
			{
				newSize.width = 1;
			}
			if (per < 0.01)
			{
				per = 0.01;
			}
            widthField.intValue = (int)newSize.width;
            scaleField.intValue = (int)(per * 100);
		}
		newSize.height = value;
        heightField.intValue = (int)newSize.height;
	}
	else if ([field isEqual:scaleField])
	{
		if (locked)
		{
			per = (CGFloat)scaleField.intValue / 100;
			if (per < 0.01)
			{
				scaleField.intValue = 1;
				per = 0.01;
			}
			if (onlyVisibleButton.state == NSOnState)
			{
				newSize.width = visibleRect.size.width * per;
				newSize.height = visibleRect.size.height * per;
			}
			else {
				newSize.width = image.size.width * per;
				newSize.height = image.size.height * per;
			}
            widthField.intValue = (int)newSize.width;
            heightField.intValue = (int)newSize.height;
            scaleField.intValue = (int)(per * 100);
			successScale = per;
		}
	}
	else {
		if (locked)
		{
			per = (CGFloat)scaleField.intValue / 100;
		}
		if (per < 0.01)
		{
            scaleField.intValue = 1;
			per = 0.01;
		}
		if (onlyVisibleButton.state == NSOnState)
		{
			newSize.width = visibleRect.size.width * per;
			newSize.height = visibleRect.size.height * per;
		}
		else {
			newSize.width = image.size.width * per;
			newSize.height = image.size.height * per;
		}
        widthField.intValue = (int)newSize.width;
        heightField.intValue = (int)newSize.height;
        scaleField.intValue = (int)(per * 100);
	}
	[self updatePreviewImage];
	r.size = newSize;
	if (r.size.width < scrollView.frame.size.width)
		r.size.width = scrollView.frame.size.width;
	if (r.size.height < scrollView.frame.size.height)
		r.size.height = scrollView.frame.size.height;
    imageView.frame = r;
	[imageView display];
	[imageView scrollPoint:NSMakePoint(0, r.size.height)];
}

#pragma mark -
#pragma mark Actions

- (void)checkOnlyVisible:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setBool:(onlyVisibleButton.state == NSOnState) forKey:kSBSnapshotOnlyVisiblePortion];
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
                self.image = selectedWebViewImage;
			}
		}
	}
}

- (void)lock:(id)sender
{
	BOOL locked = lockButton.state == NSOffState;
	if (locked)
	{
		[self updateForField:widthField];
	}
    scaleField.enabled = locked;
}

- (void)selectFiletype:(NSMenuItem *)sender
{
	int tag = sender.tag;
	if (filetype != tag)
	{
		NSArray *items = filetypePopup.menu.itemArray;
		filetype = tag;
		for (NSMenuItem *item in items)
		{
            item.state = filetype == item.tag ? NSOnState : NSOffState;
		}
		// Update image
		[self updateForField:nil];
		// Save to defaults
		[[NSUserDefaults standardUserDefaults] setInteger:filetype forKey:kSBSnapshotFileType];
	}
	if (filetype == NSTIFFFileType)
	{
		[optionTabView selectTabViewItemWithIdentifier:[NSString stringWithFormat:@"%d", NSTIFFFileType]];
        optionTabView.hidden = NO;
	}
	else if (filetype == NSJPEGFileType)
	{
		[optionTabView selectTabViewItemWithIdentifier:[NSString stringWithFormat:@"%d", NSJPEGFileType]];
        optionTabView.hidden = NO;
	}
	else {
        optionTabView.hidden = YES;
	}
}

- (void)selectTiffOption:(NSMenuItem *)sender
{
	int tag = [sender tag];
	if (tiffCompression != tag)
	{
		NSArray *items = tiffOptionPopup.menu.itemArray;
		tiffCompression = tag;
		for (NSMenuItem *item in items)
		{
            item.state = tiffCompression == item.tag ? NSOnState : NSOffState;
		}
		// Update image
		[self updateForField:nil];
		// Save to defaults
		[[NSUserDefaults standardUserDefaults] setInteger:tiffCompression forKey:kSBSnapshotTIFFCompression];
	}
}

- (void)slideJpgOption:(id)sender
{
	jpgFactor = jpgOptionSlider.floatValue;
	jpgOptionField.stringValue = [NSString stringWithFormat:@"%.1f", jpgFactor];
	// Save to defaults
	[[NSUserDefaults standardUserDefaults] setFloat:jpgFactor forKey:kSBSnapshotJPGFactor];
	// Update image
	[self destructUpdateTimer];
	updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateWithTimer:) userInfo:nil repeats:NO];
}

- (void)save:(id)sender
{
	if (data)
	{
		SBSavePanel *panel = [SBSavePanel savePanel];
		NSString *filename = self.filename;
        panel.canCreateDirectories = YES;
		if ([panel runModalForDirectory:nil file:filename] == NSOKButton)
		{
			NSString *path = panel.filename;
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
        imageView.image = nil;
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
	if (onlyVisibleButton.state == NSOnState)
	{
		fromRect = visibleRect;
		fromRect.origin.y = image.size.height - NSMaxY(visibleRect);
	}
	else {
		fromRect.size = image.size;
	}
	[anImage lockFocus];
	[image drawInRect:NSMakeRect(0, 0, size.width, size.height) fromRect:fromRect operation:NSCompositeSourceOver fraction:1.0];
	[anImage unlockFocus];
	
	// Change filetype
	aData = anImage.TIFFRepresentation;
	if (inFiletype == NSTIFFFileType)
	{
		bitmapImageRep = [NSBitmapImageRep imageRepWithData:aData];
		aData = [bitmapImageRep TIFFRepresentationUsingCompression:tiffCompression factor:1.0];
	}
	else if (inFiletype == NSGIFFileType)
	{
		bitmapImageRep = [NSBitmapImageRep imageRepWithData:aData];
		properties = @{NSImageDitherTransparency: @YES};
		aData = [bitmapImageRep representationUsingType:NSGIFFileType properties:properties];
	}
	else if (inFiletype == NSJPEGFileType)
	{
		bitmapImageRep = [NSBitmapImageRep imageRepWithData:aData];
		properties = @{NSImageCompressionFactor: @(jpgFactor)};
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
