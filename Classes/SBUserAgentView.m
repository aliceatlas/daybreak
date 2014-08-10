/*
 
 SBUserAgentView.m
 
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

#import "SBUserAgentView.h"


@implementation SBUserAgentView

@dynamic userAgentName;

- (instancetype)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		[self constructTitle];
		[self constructPopup];
		[self constructButtons];
        self.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin;
	}
	return self;
}

#pragma mark Rects

- (NSPoint)margin
{
	return NSMakePoint(20.0, 20.0);
}

- (CGFloat)labelWidth
{
	return 60.0;
}

- (NSRect)iconRect
{
	NSRect r = NSZeroRect;
	r.size.width = 32.0;
	r.origin.x = self.labelWidth - r.size.width;
	r.size.height = 32.0;
	r.origin.y = self.bounds.size.height - self.margin.y - r.size.height;
	return r;
}

- (NSRect)titleRect
{
	NSRect r = NSZeroRect;
	NSPoint margin = self.margin;
	r.origin.x = NSMaxX(self.iconRect) + 10.0;
	r.size.width = self.bounds.size.width - r.origin.x - margin.x;
	r.size.height = 19.0;
	r.origin.y = self.bounds.size.height - margin.y - r.size.height - (32.0 - r.size.height) / 2;
	return r;
}

- (NSRect)popupRect
{
	NSRect r = NSZeroRect;
	NSRect iconRect = self.iconRect;
	r.origin.x = iconRect.origin.x;
	r.size.width = self.bounds.size.width - r.origin.x - self.margin.x;
	r.size.height = 26;
	r.origin.y = iconRect.origin.y - 20.0 - r.size.height;
	return r;
}

- (NSRect)fieldRect
{
	NSRect r = NSZeroRect;
	NSRect popupRect = self.popupRect;
	r.origin.x = popupRect.origin.x;
	r.size.width = self.bounds.size.width - r.origin.x - self.margin.x;
	r.size.height = 58.0;
	r.origin.y = popupRect.origin.y - 20.0 - r.size.height;
	return r;
}

- (NSRect)cancelRect
{
	NSRect r = NSZeroRect;
	NSPoint margin = self.margin;
	r.size.width = 124.0;
	r.size.height = 32.0;
	r.origin.x = self.bounds.size.width - (margin.x + r.size.width * 2 + 8.0);
	r.origin.y = margin.y;
	return r;
}

- (NSRect)doneRect
{
	NSRect r = NSZeroRect;
	NSPoint margin = self.margin;
	r.size.width = 124.0;
	r.size.height = 32.0;
	r.origin.x = self.bounds.size.width - (margin.x + r.size.width);
	r.origin.y = margin.y;
	return r;
}

- (NSString *)userAgentName
{
	NSString *userAgentName = nil;
	NSInteger selectedIndex = popup.indexOfSelectedItem;
	if (selectedIndex == SBCountOfUserAgentNames)
	{
		userAgentName = field.stringValue;
	}
	else {
		userAgentName = SBUserAgentNames[selectedIndex - 1];
	}
	return userAgentName;
}

#pragma mark Construction

- (void)constructTitle
{
	NSImage *image = nil;
	image = [NSImage imageNamed:@"UserAgent"];
	iconImageView = [[NSImageView alloc] initWithFrame:self.iconRect];
	titleLabel = [[NSTextField alloc] initWithFrame:self.titleRect];
	if (image)
	{
        image.size = iconImageView.frame.size;
        iconImageView.image = image;
	}
    titleLabel.stringValue = NSLocalizedString(@"Select User Agent", nil);
    titleLabel.bordered = NO;
    titleLabel.editable = NO;
    titleLabel.selectable = NO;
    titleLabel.drawsBackground = NO;
    titleLabel.font = [NSFont boldSystemFontOfSize:16.0];
	titleLabel.textColor = NSColor.whiteColor;
    titleLabel.autoresizingMask = NSViewWidthSizable;
	[self addSubview:iconImageView];
	[self addSubview:titleLabel];
}

- (void)constructPopup
{
	NSString *userAgentName = nil;
	NSMenu *menu = nil;
	NSUInteger count = 0;
	NSUInteger i = 0;
	NSUInteger selectedIndex = NSNotFound;
	popup = [[SBBLKGUIPopUpButton alloc] initWithFrame:self.popupRect];
	field = [[SBBLKGUITextField alloc] initWithFrame:self.fieldRect];
    field.alignment = NSLeftTextAlignment;
    field.font = [NSFont systemFontOfSize:14.0];
	field.textColor = NSColor.whiteColor;
    field.delegate = self;
	[field.cell setWraps:YES];
	field.hidden = YES;
	menu = popup.menu;
	count = SBCountOfUserAgentNames;
	userAgentName = [[NSUserDefaults standardUserDefaults] objectForKey:kSBUserAgentName];
	if (userAgentName)
	{
		for (i = 0; i < count; i++)
		{
			if ([SBUserAgentNames[i] isEqualToString:userAgentName])
			{
				selectedIndex = i + 1;
				break;
			}
		}
	}
	if (selectedIndex == NSNotFound)
	{
		selectedIndex = count;
        field.stringValue = userAgentName;
        field.hidden = NO;
	}
	NSImage *icon0 = [SBUserAgentNames[0] isEqualToString:@"Sunrise"] ? [NSImage imageNamed:@"Application.icns"] : nil;
	NSImage *icon1 = [SBUserAgentNames[1] isEqualToString:@"Safari"] ? [[NSImage alloc] initWithContentsOfFile:@"/Applications/Safari.app/Contents/Resources/compass.icns"] : nil;
    if (icon0) icon0.size = NSMakeSize(24.0, 24.0);
    if (icon1) icon1.size = NSMakeSize(24.0, 24.0);
	NSImage *images[2] = {icon0, icon1};
	[menu addItemWithTitle:[NSString string] action:nil keyEquivalent:@""];
	for (i = 0; i < count; i++)
	{
		NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(SBUserAgentNames[i], nil) action:@selector(selectApp:) keyEquivalent:@""];
        item.target = self;
		if (i < 2)
            item.image = images[i];
        item.tag = i;
		[menu addItem:item];
	}
    popup.pullsDown = YES;
	[popup selectItemAtIndex:selectedIndex];
	[self addSubview:popup];
	[self addSubview:field];
}

- (void)constructButtons
{
	cancelButton = [[SBBLKGUIButton alloc] initWithFrame:self.cancelRect];
	doneButton = [[SBBLKGUIButton alloc] initWithFrame:self.doneRect];
    cancelButton.title = NSLocalizedString(@"Cancel", nil);
    cancelButton.target = self;
    cancelButton.action = @selector(cancel);
	cancelButton.keyEquivalent = @"\e";
    doneButton.title = NSLocalizedString(@"Done", nil);
    doneButton.target = self;
    doneButton.enabled = self.userAgentName.length > 0;
    doneButton.action = @selector(done);
	doneButton.keyEquivalent = @"\r";
	[self addSubview:cancelButton];
	[self addSubview:doneButton];
}

#pragma mark Delegate

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	doneButton.enabled = self.userAgentName.length > 0;
}

#pragma mark Actions

- (void)selectApp:(id)sender
{
	NSInteger selectedIndex = popup.indexOfSelectedItem;
	if (selectedIndex == SBCountOfUserAgentNames)
	{
        field.hidden = NO;
		[field selectText:nil];
	}
	else {
        field.hidden = YES;
	}
    doneButton.enabled = self.userAgentName.length > 0;
}

- (void)done
{
	NSString *userAgentName = self.userAgentName;
	if (userAgentName)
	{
		[[NSUserDefaults standardUserDefaults] setObject:userAgentName forKey:kSBUserAgentName];
		[super done];
	}
}

@end
