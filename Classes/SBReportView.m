/*
 
SBReportView.m
 
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

#import "SBReportView.h"
#include <mach/mach_host.h>

#define kSBMinFrameSizeWidth 600
#define kSBMaxFrameSizeWidth 900
#define kSBMinFrameSizeHeight 480
#define kSBMaxFrameSizeHeight 720

@implementation SBReportView

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
		[self constructTitle];
		[self constructSummery];
		[self constructUserAgent];
		[self constructSwitch];
		[self constructWay];
		[self constructButtons];
		[self setAutoresizingMask:(NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin)];
	}
	return self;
}

- (void)dealloc
{
	[iconImageView release];
	[titleLabel release];
	[summeryLabel release];
	[summeryField release];
	[switchLabel release];
	[switchMatrix release];
	[wayLabel release];
	[wayField release];
	[cancelButton release];
	[doneButton release];
	[super dealloc];
}

#pragma mark Rects

- (NSPoint)margin
{
	return NSMakePoint(20.0, 20.0);
}

- (CGFloat)labelWidth
{
	return 200.0;
}

- (NSRect)iconRect
{
	NSRect r = NSZeroRect;
	NSPoint margin = [self margin];
	r.size.width = 32.0;
	r.origin.x = [self labelWidth] - r.size.width;
	r.size.height = 32.0;
	r.origin.y = self.bounds.size.height - margin.y - r.size.height;
	return r;
}

- (NSRect)titleRect
{
	NSRect r = NSZeroRect;
	NSRect iconRect = [self iconRect];
	NSPoint margin = [self margin];
	r.origin.x = NSMaxX(iconRect) + 10.0;
	r.size.width = self.bounds.size.width - r.origin.x - margin.x;
	r.size.height = 19.0;
	r.origin.y = self.bounds.size.height - margin.y - r.size.height - (32.0 - r.size.height) / 2;
	return r;
}

- (NSRect)summeryLabelRect
{
	NSRect r = NSZeroRect;
	NSRect iconRect = [self iconRect];
	NSPoint margin = [self margin];
	r.origin.x = margin.x;
	r.size.width = [self labelWidth] - r.origin.x;
	r.size.height = 19.0;
	r.origin.y = iconRect.origin.y - 20.0 - r.size.height;
	return r;
}

- (NSRect)summeryFieldRect
{
	NSRect r = NSZeroRect;
	NSRect summeryLabelRect = [self summeryLabelRect];
	NSPoint margin = [self margin];
	r.origin.x = NSMaxX(summeryLabelRect) + 8.0;
	r.size.width = self.bounds.size.width - r.origin.x - margin.x;
	r.size.height = 58.0;
	r.origin.y = NSMaxY(summeryLabelRect) - r.size.height + 2.0;
	return r;
}

- (NSRect)userAgentLabelRect
{
	NSRect r = NSZeroRect;
	NSRect summeryFieldRect = [self summeryFieldRect];
	NSPoint margin = [self margin];
	r.origin.x = margin.x;
	r.size.width = [self labelWidth] - r.origin.x;
	r.size.height = 19.0;
	r.origin.y = summeryFieldRect.origin.y - 20.0 - r.size.height;
	return r;
}

- (NSRect)userAgentPopupRect
{
	NSRect r = NSZeroRect;
	NSRect userAgentLabelRect = [self userAgentLabelRect];
	NSPoint margin = [self margin];
	r.origin.x = NSMaxX(userAgentLabelRect) + 8.0;
	r.size.width = self.bounds.size.width - r.origin.x - margin.x;
	r.size.height = 26.0;
	r.origin.y = NSMaxY(userAgentLabelRect) - r.size.height + 2.0;
	return r;
}

- (NSRect)switchLabelRect
{
	NSRect r = NSZeroRect;
	NSRect userAgentPopupRect = [self userAgentPopupRect];
	NSPoint margin = [self margin];
	r.origin.x = margin.x;
	r.size.width = [self labelWidth] - r.origin.x;
	r.size.height = 19.0;
	r.origin.y = userAgentPopupRect.origin.y - 20.0 - r.size.height;
	return r;
}

- (NSRect)switchRect
{
	NSRect r = NSZeroRect;
	NSRect switchLabelRect = [self switchLabelRect];
	NSPoint margin = [self margin];
	r.origin.x = NSMaxX(switchLabelRect) + 8.0;
	r.size.width = self.bounds.size.width - r.origin.x - margin.x;
	r.size.height = 18.0;
	r.origin.y = NSMaxY(switchLabelRect) - r.size.height;
	return r;
}

- (NSRect)wayLabelRect
{
	NSRect r = NSZeroRect;
	NSRect switchRect = [self switchRect];
	NSPoint margin = [self margin];
	r.origin.x = margin.x;
	r.size.width = [self labelWidth] - r.origin.x;
	r.size.height = 19.0;
	r.origin.y = switchRect.origin.y - 20.0 - r.size.height;
	return r;
}

- (NSRect)wayFieldRect
{
	NSRect r = NSZeroRect;
	NSRect wayLabelRect = [self wayLabelRect];
	NSPoint margin = [self margin];
	r.origin.x = NSMaxX(wayLabelRect) + 8.0;
	r.size.width = self.bounds.size.width - r.origin.x - margin.x;
	r.origin.y = (32.0 + margin.y * 2) + 4.0;
	r.size.height = NSMaxY(wayLabelRect) - r.origin.y;
	return r;
}

- (NSRect)cancelRect
{
	NSRect r = NSZeroRect;
	NSPoint margin = [self margin];
	r.size.width = 124.0;
	r.size.height = 32.0;
	r.origin.x = self.bounds.size.width - (margin.x + r.size.width * 2 + 8.0);
	r.origin.y = margin.y;
	return r;
}

- (NSRect)doneRect
{
	NSRect r = NSZeroRect;
	NSPoint margin = [self margin];
	r.size.width = 124.0;
	r.size.height = 32.0;
	r.origin.x = self.bounds.size.width - (margin.x + r.size.width);
	r.origin.y = margin.y;
	return r;
}

#pragma mark Construction

- (void)constructTitle
{
	NSImage *image = nil;
	image = [NSImage imageNamed:@"Bug"];
	iconImageView = [[NSImageView alloc] initWithFrame:[self iconRect]];
	titleLabel = [[NSTextField alloc] initWithFrame:[self titleRect]];
	if (image)
	{
		[image setSize:[iconImageView frame].size];
		[iconImageView setImage:image];
	}
	[titleLabel setStringValue:NSLocalizedString(@"Send Bug Report", nil)];
	[titleLabel setBordered:NO];
	[titleLabel setEditable:NO];
	[titleLabel setSelectable:NO];
	[titleLabel setDrawsBackground:NO];
	[titleLabel setFont:[NSFont boldSystemFontOfSize:16.0]];
	[titleLabel setTextColor:[NSColor whiteColor]];
	[titleLabel setAutoresizingMask:(NSViewWidthSizable)];
	[self addSubview:iconImageView];
	[self addSubview:titleLabel];
}

- (void)constructSummery
{
	summeryLabel = [[NSTextField alloc] initWithFrame:[self summeryLabelRect]];
	summeryField = [[SBBLKGUITextField alloc] initWithFrame:[self summeryFieldRect]];
	[summeryLabel setStringValue:NSLocalizedString(@"Summary", nil)];
	[summeryLabel setAlignment:NSRightTextAlignment];
	[summeryLabel setBordered:NO];
	[summeryLabel setEditable:NO];
	[summeryLabel setSelectable:NO];
	[summeryLabel setDrawsBackground:NO];
	[summeryLabel setFont:[NSFont systemFontOfSize:14.0]];
	[summeryLabel setTextColor:[NSColor whiteColor]];
	[summeryField setAlignment:NSLeftTextAlignment];
	[summeryField setFont:[NSFont systemFontOfSize:14.0]];
	[summeryField setTextColor:[NSColor whiteColor]];
	[summeryField setDelegate:self];
	[[summeryField cell] setWraps:YES];
	[self addSubview:summeryLabel];
	[self addSubview:summeryField];
}

- (void)constructUserAgent
{
	NSMenu *menu = nil;
	NSString *userAgentName = nil;
	NSMutableArray *names = nil;
	NSInteger selectedIndex = 0;
	userAgentLabel = [[NSTextField alloc] initWithFrame:[self userAgentLabelRect]];
	userAgentPopup = [[SBBLKGUIPopUpButton alloc] initWithFrame:[self userAgentPopupRect]];
	[userAgentLabel setStringValue:NSLocalizedString(@"User Agent", nil)];
	[userAgentLabel setAlignment:NSRightTextAlignment];
	[userAgentLabel setBordered:NO];
	[userAgentLabel setEditable:NO];
	[userAgentLabel setSelectable:NO];
	[userAgentLabel setDrawsBackground:NO];
	[userAgentLabel setFont:[NSFont systemFontOfSize:14.0]];
	[userAgentLabel setTextColor:[NSColor whiteColor]];
	menu = [userAgentPopup menu];
	names = [NSMutableArray arrayWithCapacity:0];
	NSImage *icon0 = [SBUserAgentNames[0] isEqualToString:@"Sunrise"] ? [NSImage imageNamed:@"Application.icns"] : nil;
	NSImage *icon1 = [SBUserAgentNames[1] isEqualToString:@"Safari"] ? [[[NSImage alloc] initWithContentsOfFile:@"/Applications/Safari.app/Contents/Resources/compass.icns"] autorelease] : nil;
	if (icon0) [icon0 setSize:NSMakeSize(24.0, 24.0)];
	if (icon1) [icon1 setSize:NSMakeSize(24.0, 24.0)];
	userAgentName = [[NSUserDefaults standardUserDefaults] objectForKey:kSBUserAgentName];
	[names addObject:SBUserAgentNames[0]];
	[names addObject:SBUserAgentNames[1]];
	if (![userAgentName isEqualToString:SBUserAgentNames[0]] && ![userAgentName isEqualToString:SBUserAgentNames[1]] && [userAgentName length] > 0)
	{
		[names addObject:userAgentName];
	}
	NSImage *images[2] = {icon0, icon1};
	[menu addItemWithTitle:[NSString string] action:nil keyEquivalent:@""];
	for (NSUInteger i = 0; i < [names count]; i++)
	{
		NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:[names objectAtIndex:i] action:@selector(selectApp:) keyEquivalent:@""] autorelease];
		[item setTarget:self];
		if (i < 2)
			[item setImage:images[i]];
		[menu addItem:item];
	}
	selectedIndex = [userAgentPopup indexOfItemWithTitle:userAgentName];
	[userAgentPopup setPullsDown:YES];
	[userAgentPopup selectItemAtIndex:selectedIndex];
	[self addSubview:userAgentLabel];
	[self addSubview:userAgentPopup];
}

- (void)constructSwitch
{
	SBBLKGUIButtonCell *cell = nil;
	switchLabel = [[NSTextField alloc] initWithFrame:[self switchLabelRect]];
	cell = [[[SBBLKGUIButtonCell alloc] init] autorelease];
	[cell setButtonType:NSRadioButton];
	switchMatrix = [[NSMatrix alloc] initWithFrame:[self switchRect] mode:NSRadioModeMatrix prototype:cell numberOfRows:1 numberOfColumns:2];
	[switchLabel setStringValue:NSLocalizedString(@"Reproducibility", nil)];
	[switchLabel setAlignment:NSRightTextAlignment];
	[switchLabel setBordered:NO];
	[switchLabel setEditable:NO];
	[switchLabel setSelectable:NO];
	[switchLabel setDrawsBackground:NO];
	[switchLabel setFont:[NSFont systemFontOfSize:14.0]];
	[switchLabel setTextColor:[NSColor whiteColor]];
	[switchMatrix setCellSize:NSMakeSize(150.0, 18.0)];
	[switchMatrix setDrawsBackground:NO];
	[[switchMatrix cellAtRow:0 column:0] setTitle:NSLocalizedString(@"Describe", nil)];
	[[switchMatrix cellAtRow:0 column:1] setTitle:NSLocalizedString(@"None", nil)];
	[switchMatrix setTarget:self];
	[switchMatrix setAction:@selector(switchReproducibility:)];
	[self addSubview:switchLabel];
	[self addSubview:switchMatrix];
}

- (void)constructWay
{
	wayLabel = [[NSTextField alloc] initWithFrame:[self wayLabelRect]];
	wayField = [[SBBLKGUITextField alloc] initWithFrame:[self wayFieldRect]];
	[wayLabel setStringValue:NSLocalizedString(@"A way to reproduce", nil)];
	[wayLabel setAlignment:NSRightTextAlignment];
	[wayLabel setBordered:NO];
	[wayLabel setEditable:NO];
	[wayLabel setSelectable:NO];
	[wayLabel setDrawsBackground:NO];
	[wayLabel setFont:[NSFont systemFontOfSize:14.0]];
	[wayLabel setTextColor:[NSColor whiteColor]];
	[wayField setAlignment:NSLeftTextAlignment];
	[wayField setFont:[NSFont systemFontOfSize:14.0]];
	[wayField setTextColor:[NSColor whiteColor]];
	[wayField setDelegate:self];
	[[wayField cell] setWraps:YES];
	[self addSubview:wayLabel];
	[self addSubview:wayField];
}

- (void)constructButtons
{
	cancelButton = [[SBBLKGUIButton alloc] initWithFrame:[self cancelRect]];
	doneButton = [[SBBLKGUIButton alloc] initWithFrame:[self doneRect]];
	[cancelButton setTitle:NSLocalizedString(@"Cancel", nil)];
	[cancelButton setTarget:self];
	[cancelButton setAction:@selector(cancel)];
	[cancelButton setKeyEquivalent:@"\e"];
	[doneButton setTitle:NSLocalizedString(@"Done", nil)];
	[doneButton setTarget:self];
	[doneButton setAction:@selector(send)];
	[doneButton setEnabled:NO];
	[doneButton setKeyEquivalent:@"\r"];
	[self addSubview:cancelButton];
	[self addSubview:doneButton];
}

#pragma mark Delegate

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	[self validateDoneButton];
}

#pragma mark Actions

- (void)validateDoneButton
{
	BOOL canDone = NO;
	canDone = [[summeryField stringValue] length] > 0;
	if (canDone && [switchMatrix selectedColumn] == 0)
	{
		canDone = [[wayField stringValue] length] > 0;
	}
	[doneButton setEnabled:canDone];
}

- (void)selectApp:(id)sender
{
	
}

- (void)switchReproducibility:(id)sender
{
	BOOL selected = [switchMatrix selectedColumn] == 0;
	[wayField setEnabled:selected];
	[self validateDoneButton];
}

- (NSString *)sendMailWithMessage:(NSString *)message subject:(NSString *)subject to:(NSArray *)addresses
{
	NSString *errorString = nil;
	NSUInteger i, count;
	count = [addresses count];
	if ([addresses count] > 0)
	{
		NSString *urlString = nil;
		urlString = @"mailto:";
		urlString = [urlString stringByAppendingString:[addresses objectAtIndex:0]];
		if ([addresses count] > 1)
		{
			for (i = 0; i < count; i++)
			{
				NSString *address = [addresses objectAtIndex:i];
				urlString = [urlString stringByAppendingFormat:@", %@", address];
			}
		}
		if (subject)
		{
			urlString = [urlString stringByAppendingFormat:@"?subject=%@", subject];
		}
		if (message)
		{
			urlString = [urlString stringByAppendingFormat:@"%@body=%@", subject != nil ? @"&" : @"?", message];
		}
		urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
	}
	else {
		// Error
		errorString = NSLocalizedString(@"Could not send the report.", nil);
	}
	return errorString;
}

- (void)send
{
	NSString *errorDescription = nil;
	NSMutableString *message = nil;
	NSString *summery = nil;
	NSString *userAgent = nil;
	BOOL reproducibility = YES;
	NSString *wayToReproduce = nil;
	NSString *osVersion = nil;
	NSString *processor = nil;
	NSString *applicationVersion = nil;
	host_basic_info_data_t hostInfo;
	mach_msg_type_number_t infoCount = HOST_BASIC_INFO_COUNT;
	kern_return_t result = host_info(mach_host_self(), HOST_BASIC_INFO, (host_info_t)&hostInfo, &infoCount);
	
	// Get properties
	message = [NSMutableString stringWithCapacity:0];
	summery = [summeryField stringValue];
	userAgent = [userAgentPopup titleOfSelectedItem];
	reproducibility = ([switchMatrix selectedColumn] == 0);
	wayToReproduce = [wayField stringValue];
	osVersion = [[NSProcessInfo processInfo] operatingSystemVersionString];
	if (result == KERN_SUCCESS)
	{
		if (hostInfo.cpu_type == CPU_TYPE_POWERPC)
		{
			processor = @"Power PC";
		}
		else if (hostInfo.cpu_type == CPU_TYPE_I386)
		{
			processor = @"Intel";
		}
		else {
			processor = @"Unknown Processor";
		}
	}
	applicationVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	
	// Make message
	if ([summery length] > 0)
	{
		[message appendFormat:@"%@ : \n%@\n\n", NSLocalizedString(@"Summary", nil), summery];
	}
	if ([userAgent length] > 0)
	{
		[message appendFormat:@"%@ : \n%@\n\n", NSLocalizedString(@"User Agent", nil), userAgent];
	}
	if (reproducibility && [wayToReproduce length] > 0)if (reproducibility)
	{
		[message appendFormat:@"%@ : \n%@\n\n", NSLocalizedString(@"A way to reproduce", nil), wayToReproduce];
	}
	if ([osVersion length] > 0)
	{
		[message appendFormat:@"%@ : %@\n", NSLocalizedString(@"OS", nil), osVersion];
	}
	if ([processor length] > 0)
	{
		[message appendFormat:@"%@ : %@\n", NSLocalizedString(@"Processor", nil), processor];
	}
	if ([applicationVersion length] > 0)
	{
		[message appendFormat:@"%@ : %@\n", NSLocalizedString(@"Application Version", nil), applicationVersion];
	}
	
	// Send message
	errorDescription = [self sendMailWithMessage:[[message copy] autorelease] subject:NSLocalizedString(@"Sunrise Bug Report", nil) to:[NSArray arrayWithObject:kSBBugReportMailAddress]];
	if (!errorDescription)
	{
		[self done];
	}
}

@end
