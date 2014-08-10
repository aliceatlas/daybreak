/*

SBLocalizationWindowController.m
 
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

#import "SBLocalizationWindowController.h"
#import "SBSavePanel.h"
#import "SBUtil.h"

#define kSBLocalizationAvailableSubversionAccess 0


@implementation SBLocalizationWindowController

@synthesize textSet;
@synthesize fieldSet;

- (instancetype)initWithViewSize:(NSSize)inViewSize
{
	if (self = [super initWithViewSize:inViewSize])
	{
		NSWindow *window = self.window;
        window.minSize = NSMakeSize(window.frame.size.width, 520.0);
		window.maxSize = NSMakeSize(window.frame.size.width, viewSize.height + 100);
        window.title = NSLocalizedString(@"Localize", nil);
        ((NSView *)window.contentView).wantsLayer = YES;
		animating = NO;
		[self constructCommonViews];
		[self constructEditView];
		[self constructContributeView];
	}
	return self;
}

- (CGFloat)margin
{
	return 20.0;
}

- (CGFloat)topMargin
{
	return 40.0;
}

- (CGFloat)bottomMargin
{
	return 40.0;
}

- (void)constructCommonViews
{
	NSUserDefaults *defaults = nil;
	NSArray *languages = nil;
	NSMenu *menu = nil;
	CGFloat margin = self.margin;
	CGFloat topMargin = self.topMargin;
	NSRect langRect = NSZeroRect;
	NSRect langFRect = NSZeroRect;
	NSRect contentRect = NSZeroRect;
	NSRect switchRect = NSZeroRect;
	NSView *aContentView = nil;
	defaults = [NSUserDefaults standardUserDefaults];
	languages = [defaults objectForKey:@"AppleLanguages"];
	menu = [[NSMenu alloc] init];
	aContentView = self.window.contentView;
	contentRect = aContentView.bounds;
	langFRect.size.width = 100.0;
	langFRect.size.height = 22.0;
	langFRect.origin.x = margin;
	langFRect.origin.y = (contentRect.size.height - topMargin) + (topMargin - langFRect.size.height) / 2;
	langRect = langFRect;
	langRect.size.width = 250.0;
	langRect.size.height = 22.0;
	langRect.origin.x = NSMaxX(langFRect) + 8.0;
	switchRect.size = NSMakeSize(118.0, 25.0);
	switchRect.origin.x = contentRect.size.width - switchRect.size.width - margin;
	switchRect.origin.y = (contentRect.size.height - topMargin) + (topMargin - switchRect.size.height) / 2;
	langField = [[NSTextField alloc] initWithFrame:langFRect];
	langField.autoresizingMask = NSViewMinYMargin;
    langField.editable = NO;
    langField.selectable = NO;
    langField.bezeled = NO;
    langField.drawsBackground = NO;
    langField.font = [NSFont systemFontOfSize:14.0];
    langField.textColor = NSColor.blackColor;
    langField.alignment = NSRightTextAlignment;
	langField.stringValue = [NSLocalizedString(@"Language", nil) stringByAppendingString:@" :"];
	langPopup = [[NSPopUpButton alloc] initWithFrame:langRect pullsDown:NO];
    langPopup.autoresizingMask = NSViewMinYMargin;
    langPopup.bezelStyle = NSTexturedRoundedBezelStyle;
	[langPopup.cell setArrowPosition:NSPopUpArrowAtBottom];
	for (NSString *lang in languages)
	{
		NSString *title = [[NSLocale systemLocale] displayNameForKey:NSLocaleIdentifier value:lang];
		[menu addItemWithTitle:title representedObject:lang target:self action:@selector(selectLanguage:)];
	}
    langPopup.menu = menu;
	switchButton = [[NSButton alloc] initWithFrame:switchRect];
    switchButton.autoresizingMask = NSViewMinYMargin;
    switchButton.buttonType = NSMomentaryPushInButton;
    switchButton.bezelStyle = NSTexturedRoundedBezelStyle;
    switchButton.target = self;
    switchButton.title = NSLocalizedString(@"Contibute", nil);
    switchButton.action = @selector(showContribute);
	[aContentView addSubview:langPopup];
	[aContentView addSubview:langField];
#if kSBLocalizationAvailableSubversionAccess
	[aContentView addSubview:switchButton];
#endif
}

- (void)constructEditView
{
	NSRect editRect = NSZeroRect;
	NSRect contentRect = NSZeroRect;
	CGFloat topMargin = self.topMargin;
	NSView *aContentView = nil;
	CGColorRef aBackgroundColor = nil;
	aContentView = self.window.contentView;
	contentRect = aContentView.bounds;
	editRect = contentRect;
	editRect.size.height -= topMargin;
	editView = [[NSView alloc] initWithFrame:editRect];
    editView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	[self constructButtonsInEditView];
	[aContentView addSubview:editView];
	aBackgroundColor = CGColorCreateGenericGray(0.8, 1.0);
	aContentView.layer.backgroundColor = aBackgroundColor;
	CGColorRelease(aBackgroundColor);
}

- (void)constructButtonsInEditView
{
	NSRect openRect = NSZeroRect;
	NSRect cancelRect = NSZeroRect;
	NSRect doneRect = NSZeroRect;
	CGFloat margin = self.margin;
	CGFloat bottomMargin = self.bottomMargin;
	NSRect contentRect = editView.bounds;
	openRect.size = NSMakeSize(118.0, 25.0);
	cancelRect.size = NSMakeSize(118.0, 25.0);
	doneRect.size = NSMakeSize(118.0, 25.0);
	doneRect.origin.y = (bottomMargin - doneRect.size.height) / 2;
	doneRect.origin.x = contentRect.size.width - doneRect.size.width - margin;
	cancelRect.origin.y = doneRect.origin.y;
	cancelRect.origin.x = doneRect.origin.x - cancelRect.size.width - margin;
	openRect.origin.y = doneRect.origin.y;
	openRect.origin.x = margin;
	openButton = [[NSButton alloc] initWithFrame:openRect];
	cancelButton = [[NSButton alloc] initWithFrame:cancelRect];
	createButton = [[NSButton alloc] initWithFrame:doneRect];
    openButton.buttonType = NSMomentaryPushInButton;
    openButton.bezelStyle = NSTexturedRoundedBezelStyle;
    openButton.title = NSLocalizedString(@"Open…", nil);
    openButton.target = self;
    openButton.action = @selector(open);
    cancelButton.buttonType = NSMomentaryPushInButton;
    cancelButton.bezelStyle = NSTexturedRoundedBezelStyle;
    cancelButton.title = NSLocalizedString(@"Cancel", nil);
    cancelButton.target = self;
    cancelButton.action = @selector(cancel);
	cancelButton.keyEquivalent = @"\e";
    createButton.title = NSLocalizedString(@"Create", nil);
    createButton.buttonType = NSMomentaryPushInButton;
    createButton.bezelStyle = NSTexturedRoundedBezelStyle;
    createButton.target = self;
    createButton.action = @selector(done);
	createButton.keyEquivalent = @"\r";
	[editView addSubview:openButton];
	[editView addSubview:cancelButton];
	[editView addSubview:createButton];
}

- (void)constructContributeView
{
	NSRect contributeRect = NSZeroRect;
	NSRect contentRect = NSZeroRect;
	CGFloat topMargin = self.topMargin;
	contentRect = [self.window.contentView bounds];
	contributeRect = contentRect;
	contributeRect.size.height -= topMargin;
	contributeView = [[NSView alloc] initWithFrame:contributeRect];
    contributeView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	[self constructButtonsInContributeView];
}

- (void)constructButtonsInContributeView
{
	NSRect iconRect = NSZeroRect;
	NSRect textRect = NSZeroRect;
	NSRect checkoutTitleRect = NSZeroRect;
	NSRect checkoutButtonRect = NSZeroRect;
	NSRect commitTitleRect = NSZeroRect;
	NSRect commitButtonRect = NSZeroRect;
	iconRect = NSMakeRect(50.0, 840.0, 128.0, 128.0);
	textRect = NSMakeRect(200.0, 840.0, 490.0, 128.0);
	checkoutTitleRect = NSMakeRect(70.0, 775.0, 615.0, 25.0);
	checkoutButtonRect = NSMakeRect(70.0, 690.0, 615.0, 80.0);
	commitTitleRect = NSMakeRect(70.0, 630.0, 615.0, 25.0);
	commitButtonRect = NSMakeRect(70.0, 545.0, 615.0, 80.0);
	
	iconImageView = [[NSImageView alloc] initWithFrame:iconRect];
    iconImageView.autoresizingMask = NSViewMinYMargin;
    iconImageView.image = [NSImage imageNamed:@"Icon_Contribute.png"];
	textField = [[NSTextField alloc] initWithFrame:textRect];
    textField.autoresizingMask = NSViewMinYMargin;
    textField.editable = NO;
    textField.selectable = NO;
    textField.bezeled = NO;
    textField.drawsBackground = NO;
    textField.font = [NSFont systemFontOfSize:16.0];
    textField.textColor = NSColor.whiteColor;
    textField.alignment = NSLeftTextAlignment;
    textField.stringValue = NSLocalizedString(@"You can contribute the translation file for the Sunrise project if you participate in the project on Google Code.", nil);
	checkoutTitleField = [[NSTextField alloc] initWithFrame:checkoutTitleRect];
    checkoutTitleField.autoresizingMask = NSViewMinYMargin;
    checkoutTitleField.editable = NO;
    checkoutTitleField.selectable = NO;
    checkoutTitleField.bezeled = NO;
    checkoutTitleField.drawsBackground = NO;
    checkoutTitleField.font = [NSFont boldSystemFontOfSize:16.0];
    checkoutTitleField.textColor = NSColor.whiteColor;
    checkoutTitleField.alignment = NSLeftTextAlignment;
    checkoutTitleField.stringValue = NSLocalizedString(@"Check out", nil);
	checkoutButton = [[NSButton alloc] initWithFrame:checkoutButtonRect];
    checkoutButton.autoresizingMask = NSViewMinYMargin;
    checkoutButton.buttonType = NSMomentaryPushInButton;
    checkoutButton.bezelStyle = NSTexturedSquareBezelStyle;
    checkoutButton.image = [NSImage imageNamed:@"Icon_Checkout.png"];
    checkoutButton.imagePosition = NSImageLeft;
    checkoutButton.title = NSLocalizedString(@"Check out the translation file from the project on Google Code.", nil);
    checkoutButton.target = self;
    checkoutButton.action = @selector(openCheckoutDirectory);
	commitTitleField = [[NSTextField alloc] initWithFrame:commitTitleRect];
    commitTitleField.autoresizingMask = NSViewMinYMargin;
    commitTitleField.editable = NO;
    commitTitleField.selectable = NO;
    commitTitleField.bezeled = NO;
    commitTitleField.drawsBackground = NO;
    commitTitleField.font = [NSFont boldSystemFontOfSize:16.0];
    commitTitleField.textColor = NSColor.whiteColor;
    commitTitleField.alignment = NSLeftTextAlignment;
    commitTitleField.stringValue = NSLocalizedString(@"Commit", nil);
	commitButton = [[NSButton alloc] initWithFrame:commitButtonRect];
    commitButton.autoresizingMask = NSViewMinYMargin;
    commitButton.buttonType = NSMomentaryPushInButton;
    commitButton.bezelStyle = NSTexturedSquareBezelStyle;
    commitButton.image = [NSImage imageNamed:@"Icon_Commit.png"];
    commitButton.imagePosition = NSImageLeft;
    commitButton.title = NSLocalizedString(@"Commit your translation file to the project.", nil);
    commitButton.target = self;
    commitButton.action = @selector(openCommitDirectory);
	
	[contributeView addSubview:iconImageView];
	[contributeView addSubview:textField];
	[contributeView addSubview:checkoutTitleField];
	[contributeView addSubview:checkoutButton];
	[contributeView addSubview:commitTitleField];
	[contributeView addSubview:commitButton];
}

- (void)setTextSet:(NSMutableArray *)inTextSet
{
	if (textSet != inTextSet)
	{
		textSet = inTextSet;
		// Apply to fields
		NSInteger i = 0;
		for (NSArray *fields in fieldSet)
		{
			NSInteger j = 0;
			for (NSTextField *field in fields)
			{
				NSString *text = textSet[i][j];
				if (text)
                    field.stringValue = text;
				j++;
			}
			i++;
		}
	}
}

- (void)setFieldSet:(NSArray *)inFieldSet
{
	if (fieldSet != inFieldSet)
	{
		NSRect contentRect = NSZeroRect;
		NSRect scrollRect = NSZeroRect;
		CGFloat margin = self.margin;
		CGFloat bottomMargin = self.bottomMargin;
		fieldSet = inFieldSet;
		if (editContentView)
		{
			[editContentView removeFromSuperview];
			editContentView = nil;
		}
		if (editScrollView)
		{
			[editScrollView removeFromSuperview];
			editScrollView = nil;
		}
		editContentView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, viewSize.width, viewSize.height)];
		for (NSArray *fields in fieldSet)
		{
			for (NSTextField *field in fields)
			{
				[editContentView addSubview:field];
			}
		}
		contentRect = editView.bounds;
		scrollRect = NSMakeRect(margin, bottomMargin, contentRect.size.width - margin * 2, contentRect.size.height - bottomMargin);
		editScrollView = [[NSScrollView alloc] initWithFrame:scrollRect];
        editScrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        editScrollView.backgroundColor = NSColor.clearColor;
        editScrollView.drawsBackground = NO;
        editScrollView.hasVerticalScroller = YES;
        editScrollView.hasHorizontalScroller = NO;
        editScrollView.autohidesScrollers = YES;
		[editView addSubview:editScrollView];
		editScrollView.documentView = editContentView;	// Set document view after adding as subview
		[editContentView scrollRectToVisible:NSMakeRect(0, viewSize.height, 0, 0)];
	}
}

- (void)selectLanguage:(NSMenuItem *)sender
{
#if kSBLocalizationAvailableSubversionAccess
	NSString *lang = sender.representedObject;
#endif
}

- (void)open
{
	SBOpenPanel *panel = [SBOpenPanel openPanel];
	NSString *directoryPath = SBApplicationSupportDirectory([kSBApplicationSupportDirectoryName stringByAppendingPathComponent:kSBLocalizationsDirectoryName]);
    panel.allowedFileTypes = @[@"strings"];
	[panel beginSheetForDirectory:directoryPath file:nil modalForWindow:self.window modalDelegate:self didEndSelector:@selector(openDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)openDidEnd:(SBOpenPanel *)panel returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSOKButton)
	{
		[self mergeFilePath:panel.filename];
	}
}

- (void)mergeFilePath:(NSString *)path
{
	NSMutableArray *tSet = nil;
	NSArray *fSet = nil;
	NSSize vSize = NSZeroSize;
	NSString *lang = path.lastPathComponent.stringByDeletingPathExtension;
	SBGetLocalizableTextSet(path, &tSet, &fSet, &vSize);
	
	// Replace text
	for (NSArray *texts in tSet)
	{
		if (texts.count == 2)
		{
			NSString *text0 = texts[0];
			NSString *text1 = texts[1];
			for (NSArray *fields in fieldSet)
			{
				if (fields.count == 2)
				{
					NSTextField *field0 = fields[0];
					NSTextField *field1 = fields[1];
					if ([field0.stringValue isEqualToString:text0] && ![field1.stringValue isEqualToString:text1])
					{
                        field1.stringValue = text1;
						break;
					}
				}
			}
		}
	}
	
	// Select lang
	if (lang)
		[[langPopup menu] selectItemWithRepresentedObject:lang];
}

- (void)showContribute
{
	if (!animating)
	{
		[self changeView:0];
        switchButton.title = NSLocalizedString(@"Edit", nil);
        switchButton.action = @selector(showEdit);
	}
}

- (void)showEdit
{
	if (!animating)
	{
		[self changeView:1];
        switchButton.title = NSLocalizedString(@"Contibute", nil);
        switchButton.action = @selector(showContribute);
	}
}

/* index:
 * 0 - Show the contribute view
 * 1 - Show the edit view
 */
- (void)changeView:(NSInteger)index
{
	NSMutableArray *animations = [NSMutableArray arrayWithCapacity:0];
	NSDictionary *info = nil;
	SBViewAnimation *animation = nil;
	NSRect editRect0 = NSZeroRect;
	NSRect editRect1 = NSZeroRect;
	NSRect contributeRect0 = NSZeroRect;
	NSRect contributeRect1 = NSZeroRect;
	NSView *aContentView = self.window.contentView;
	CGFloat topMargin = self.topMargin;
	CGFloat duration = 0.4;
	CGColorRef aBackgroundColor = nil;
	animating = YES;
	editRect0 = editRect1 = editView.frame;
	contributeRect0 = contributeRect1 = contributeView.frame;
	if (index == 0)
	{
		editRect0.origin.x = 0;
		editRect1.origin.x = -editRect1.size.width;
		contributeRect0.origin.x = contributeRect0.size.width;
		contributeRect1.origin.x = 0;
		editRect0.size.height = editRect1.size.height = contributeRect0.size.height = contributeRect1.size.height = [aContentView bounds].size.height - topMargin;
		contributeView.frame = contributeRect0;
		[aContentView addSubview:contributeView];
	}
	else {
		editRect0.origin.x = -editRect1.size.width;
		editRect1.origin.x = 0;
		contributeRect0.origin.x = 0;
		contributeRect1.origin.x = contributeRect0.size.width;
		editRect0.size.height = editRect1.size.height = contributeRect0.size.height = contributeRect1.size.height = [aContentView bounds].size.height - topMargin;
		editView.frame = editRect0;
		[aContentView addSubview:editView];
	}
    info = @{NSViewAnimationTargetKey: editView,
             NSViewAnimationStartFrameKey: [NSValue valueWithRect:editRect0],
             NSViewAnimationEndFrameKey: [NSValue valueWithRect:editRect1]};
	[animations addObject:info];
    info = @{NSViewAnimationTargetKey: contributeView,
             NSViewAnimationStartFrameKey: [NSValue valueWithRect:contributeRect0],
             NSViewAnimationEndFrameKey: [NSValue valueWithRect:contributeRect1]};
    [animations addObject:info];
	animation = [[SBViewAnimation alloc] initWithViewAnimations:animations];
	animation.context = @(index);
    animation.duration = duration;
    animation.delegate = self;
	[animation startAnimation];
	
	aBackgroundColor = CGColorCreateGenericGray(index == 0 ? 0.5 : 0.8, 1.0);
	[CATransaction begin];
	[CATransaction setValue:@(duration) forKey:kCATransactionAnimationDuration];
	aContentView.layer.backgroundColor = aBackgroundColor;
	[CATransaction commit];
	CGColorRelease(aBackgroundColor);
}

- (void)animationDidEnd:(SBViewAnimation *)animation
{
	if (animation.context)
	{
		NSUInteger index = ((NSNumber *)animation.context).unsignedIntegerValue;
		if (index == 0)
		{
			[editView removeFromSuperview];
		}
		else {
			[contributeView removeFromSuperview];
		}
	}
	animating = NO;
}

- (void)cancel
{
	[self close];
}

- (void)done
{
	NSData *data = SBLocalizableStringsData(fieldSet);
	BOOL success = NO;
	if (data)
	{
		NSString *directoryPath = SBApplicationSupportDirectory([kSBApplicationSupportDirectoryName stringByAppendingPathComponent:kSBLocalizationsDirectoryName]);
		NSString *langCode = langPopup.selectedItem.representedObject;
		NSString *name = langCode ? [langCode stringByAppendingPathExtension:@"strings"] : nil;
		if (name)
		{
			// Create strings into application support folder
			NSString *path = [directoryPath stringByAppendingPathComponent:name];
			NSURL *url = [NSURL fileURLWithPath:path];
			if ([data writeToURL:url atomically:YES])
			{
				// Copy strings into bundle resource
				NSFileManager *manager = [NSFileManager defaultManager];
				NSString *directoryPath = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:langCode] stringByAppendingPathExtension:@"lproj"];
				if (![manager fileExistsAtPath:directoryPath])
					[manager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
				NSString *dstPath = [[directoryPath stringByAppendingPathComponent:@"Localizable"] stringByAppendingPathExtension:@"strings"];
				NSError *error = nil;
				if ([manager fileExistsAtPath:dstPath])
					[manager removeItemAtPath:dstPath error:&error];
				if ([manager copyItemAtPath:url.path toPath:dstPath error:&error])
				{
					// Complete
					NSString *title = NSLocalizedString(@"Complete to add new localization. Restart Sunrise.", nil);
					NSString *message = [NSString string];
					NSString *okTitle = NSLocalizedString(@"OK", nil);
					NSBeginAlertSheet(title, okTitle, nil, nil, [self window], nil, nil, nil, nil, message);
					success = YES;
				}
			}
		}
	}
	if (!success)
	{
		// Error
		NSString *title = NSLocalizedString(@"Failed to add new localization.", nil);
		NSString *message = [NSString string];
		NSString *okTitle = NSLocalizedString(@"OK", nil);
		NSBeginAlertSheet(title, okTitle, nil, nil, self.window, nil, nil, nil, nil, message);
	}
}

- (void)export
{
	SBSavePanel *panel = [SBSavePanel savePanel];
	NSString *langCode = langPopup.selectedItem.representedObject;
	NSString *name = langCode ? [langCode stringByAppendingPathExtension:@"strings"] : nil;
	[panel beginSheetForDirectory:nil file:name modalForWindow:self.window modalDelegate:self didEndSelector:@selector(exportDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)exportDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSOKButton)
	{
		NSData *data = SBLocalizableStringsData(fieldSet);
		if (data)
		{
			NSString *path = sheet.filename;
			NSURL *url = [NSURL fileURLWithPath:path];
			if ([data writeToURL:url atomically:YES])	
			{
				[self performSelector:@selector(copyResourceInBundle:) withObject:url afterDelay:0];
			}
		}
	}
}

#pragma mark Contribute

- (void)openCheckoutDirectory
{
	
}

- (void)openCommitDirectory
{
	
}

@end

@implementation SBViewAnimation

@synthesize context;

@end
