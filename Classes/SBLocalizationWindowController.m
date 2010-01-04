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


@implementation SBLocalizationWindowController

@synthesize textSet;
@synthesize fieldSet;

- (id)initWithViewSize:(NSSize)inViewSize
{
	if (self = [super initWithViewSize:inViewSize])
	{
		NSWindow *window = [self window];
		[window setMinSize:NSMakeSize([window frame].size.width, 200.0)];
		[window setMaxSize:NSMakeSize([window frame].size.width, viewSize.height + 100)];
		[window setTitle:NSLocalizedString(@"Localize", nil)];
		[self constructButtons];
	}
	return self;
}

- (void)dealloc
{
	[langPopup release];
	[scrollView release];
	[contentView release];
	[textSet release];
	[fieldSet release];
	[openButton release];
	[cancelButton release];
	[doneButton release];
	[super dealloc];
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
	return 30.0;
}

- (void)constructButtons
{
	NSRect openRect = NSZeroRect;
	NSRect cancelRect = NSZeroRect;
	NSRect doneRect = NSZeroRect;
	CGFloat margin = [self margin];
	CGFloat bottomMargin = [self bottomMargin];
	NSRect contentRect = [[[self window] contentView] bounds];
	openRect.size = NSMakeSize(118.0, 25.0);
	cancelRect.size = NSMakeSize(118.0, 25.0);
	doneRect.size = NSMakeSize(118.0, 25.0);
	doneRect.origin.y = ((bottomMargin + margin) - doneRect.size.height) / 2;
	doneRect.origin.x = contentRect.size.width - doneRect.size.width - margin;
	cancelRect.origin.y = doneRect.origin.y;
	cancelRect.origin.x = doneRect.origin.x - cancelRect.size.width - margin;
	openRect.origin.y = doneRect.origin.y;
	openRect.origin.x = margin;
	openButton = [[NSButton alloc] initWithFrame:openRect];
	cancelButton = [[NSButton alloc] initWithFrame:cancelRect];
	doneButton = [[NSButton alloc] initWithFrame:doneRect];
	[openButton setButtonType:NSMomentaryPushInButton];
	[openButton setBezelStyle:NSTexturedRoundedBezelStyle];
	[openButton setTitle:NSLocalizedString(@"Open...", nil)];
	[openButton setTarget:self];
	[openButton setAction:@selector(open)];
	[cancelButton setButtonType:NSMomentaryPushInButton];
	[cancelButton setBezelStyle:NSTexturedRoundedBezelStyle];
	[cancelButton setTitle:NSLocalizedString(@"Cancel", nil)];
	[cancelButton setTarget:self];
	[cancelButton setAction:@selector(cancel)];
	[cancelButton setKeyEquivalent:@"\e"];
	[doneButton setTitle:NSLocalizedString(@"Create", nil)];
	[doneButton setButtonType:NSMomentaryPushInButton];
	[doneButton setBezelStyle:NSTexturedRoundedBezelStyle];
	[doneButton setTarget:self];
	[doneButton setAction:@selector(done)];
	[doneButton setKeyEquivalent:@"\r"];
	[[[self window] contentView] addSubview:openButton];
	[[[self window] contentView] addSubview:cancelButton];
	[[[self window] contentView] addSubview:doneButton];
}

- (void)setTextSet:(NSMutableArray *)inTextSet
{
	if (textSet != inTextSet)
	{
		[inTextSet retain];
		if (textSet)
		{
			[textSet release];
			textSet = nil;
		}
		textSet = inTextSet;
		// Apply to fields
		NSInteger i = 0;
		for (NSArray *fields in fieldSet)
		{
			NSInteger j = 0;
			for (NSTextField *field in fields)
			{
				NSString *text = [[textSet objectAtIndex:i] objectAtIndex:j];
				if (text)
					[field setStringValue:text];
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
		NSRect langRect = NSZeroRect;
		NSRect langFRect = NSZeroRect;
		NSRect scrollRect = NSZeroRect;
		CGFloat margin = [self margin];
		CGFloat topMargin = [self topMargin];
		CGFloat bottomMargin = [self bottomMargin];
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
		NSMenu *menu = [[[NSMenu alloc] init] autorelease];
		[inFieldSet retain];
		if (fieldSet)
		{
			[fieldSet release];
			fieldSet = nil;
		}
		fieldSet = inFieldSet;
		if (langField)
		{
			[langField removeFromSuperview];
			[langField release];
			langField = nil;
		}
		if (langPopup)
		{
			[langPopup removeFromSuperview];
			[langPopup release];
			langPopup = nil;
		}
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
		contentView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, viewSize.width, viewSize.height)];
		for (NSArray *fields in fieldSet)
		{
			for (NSTextField *field in fields)
			{
				[contentView addSubview:field];
			}
		}
		contentRect = [[[self window] contentView] bounds];
		scrollRect = NSMakeRect(margin, bottomMargin + margin, contentRect.size.width - margin * 2, contentRect.size.height - topMargin - bottomMargin - margin * 2);
		langFRect.size.width = 100.0;
		langFRect.size.height = 22.0;
		langFRect.origin.x = margin;
		langFRect.origin.y = NSMaxY(scrollRect);
		langRect = langFRect;
		langRect.size.width = 250.0;
		langRect.size.height = 22.0;
		langRect.origin.x = NSMaxX(langFRect) + 8.0;
		langField = [[NSTextField alloc] initWithFrame:langFRect];
		[langField setEditable:NO];
		[langField setSelectable:NO];
		[langField setBezeled:NO];
		[langField setDrawsBackground:NO];
		[langField setFont:[NSFont systemFontOfSize:14.0]];
		[langField setTextColor:[NSColor darkGrayColor]];
		[langField setAlignment:NSRightTextAlignment];
		[langField setStringValue:[NSLocalizedString(@"Language", nil) stringByAppendingString:@" :"]];
		langPopup = [[NSPopUpButton alloc] initWithFrame:langRect pullsDown:NO];
		[langPopup setBezelStyle:NSTexturedRoundedBezelStyle];
		[[langPopup cell] setArrowPosition:NSPopUpArrowAtBottom];
		for (NSString *lang in languages)
		{
			NSString *title = [[NSLocale systemLocale] displayNameForKey:NSLocaleIdentifier value:lang];
			[menu addItemWithTitle:title representedObject:lang];
		}
		[langPopup setMenu:menu];
		scrollView = [[NSScrollView alloc] initWithFrame:scrollRect];
		[scrollView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
		[scrollView setBackgroundColor:[NSColor clearColor]];
		[scrollView setDrawsBackground:NO];
		[scrollView setHasVerticalScroller:YES];
		[scrollView setHasHorizontalScroller:NO];
		[scrollView setAutohidesScrollers:YES];
		[[[self window] contentView] addSubview:langPopup];
		[[[self window] contentView] addSubview:langField];
		[[[self window] contentView] addSubview:scrollView];
		[scrollView setDocumentView:contentView];	// Set document view after adding as subview
		[contentView scrollRectToVisible:NSMakeRect(0, viewSize.height, 0, 0)];
	}
}

- (void)open
{
	SBOpenPanel *panel = [SBOpenPanel openPanel];
	NSString *directoryPath = SBApplicationSupportDirectory([kSBApplicationSupportDirectoryName stringByAppendingPathComponent:kSBLocalizationsDirectoryName]);
	[panel setAllowedFileTypes:[NSArray arrayWithObject:@"strings"]];
	[panel beginSheetForDirectory:directoryPath file:nil modalForWindow:self.window modalDelegate:self didEndSelector:@selector(openDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)openDidEnd:(SBOpenPanel *)panel returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSOKButton)
	{
		[self mergeFilePath:[panel filename]];
	}
}

- (void)mergeFilePath:(NSString *)path
{
	NSMutableArray *tSet = nil;
	NSArray *fSet = nil;
	NSSize vSize = NSZeroSize;
	NSString *lang = [[path lastPathComponent] stringByDeletingPathExtension];
	SBGetLocalizableTextSet(path, &tSet, &fSet, &vSize);
	
	// Replace text
	for (NSArray *texts in tSet)
	{
		if ([texts count] == 2)
		{
			NSString *text0 = [texts objectAtIndex:0];
			NSString *text1 = [texts objectAtIndex:1];
			for (NSArray *fields in fieldSet)
			{
				if ([fields count] == 2)
				{
					NSTextField *field0 = [fields objectAtIndex:0];
					NSTextField *field1 = [fields objectAtIndex:1];
					if ([[field0 stringValue] isEqualToString:text0] && ![[field1 stringValue] isEqualToString:text1])
					{
						[field1 setStringValue:text1];
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
		NSString *langCode = [[langPopup selectedItem] representedObject];
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
					[manager createDirectoryAtPath:directoryPath attributes:nil];
				NSString *dstPath = [[directoryPath stringByAppendingPathComponent:@"Localizable"] stringByAppendingPathExtension:@"strings"];
				NSError *error = nil;
				if ([manager fileExistsAtPath:dstPath])
					[manager removeItemAtPath:dstPath error:&error];
				if ([manager copyItemAtPath:[url path] toPath:dstPath error:&error])
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
		NSBeginAlertSheet(title, okTitle, nil, nil, [self window], nil, nil, nil, nil, message);
	}
}

- (void)export
{
	SBSavePanel *panel = [SBSavePanel savePanel];
	NSString *langCode = [[langPopup selectedItem] representedObject];
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
			NSString *path = [sheet filename];
			NSURL *url = [NSURL fileURLWithPath:path];
			if ([data writeToURL:url atomically:YES])	
			{
				[self performSelector:@selector(copyResourceInBundle:) withObject:url afterDelay:0];
			}
		}
	}
}

@end
