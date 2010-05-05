/*

SBPreferencesWindowController.m
 
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

#import "SBPreferencesWindowController.h"
#import "SBAdditions.h"
#import "SBPreferences.h"
#import "SBSectionListView.h"
#import "SBSectionGroupe.h"
#import "SBUtil.h"
#import "SBView.h"

@implementation SBPreferencesWindowController

@synthesize sections;

- (id)initWithViewSize:(NSSize)inViewSize
{
	if (self = [super initWithViewSize:inViewSize])
	{
		NSWindow *window = [self window];
		NSRect r = [window frame];
		[window setMaxSize:NSMakeSize(r.size.width, ULONG_MAX)];
		[window setMinSize:NSMakeSize(r.size.width, 100.0)];
	}
	return self;
}

- (void)dealloc
{
	[sections release];
	[sectionListView release];
	[super dealloc];
}

- (NSRect)sectionListViewRect
{
	NSRect r = NSZeroRect;
	NSWindow *window = [self window];
	r = [window contentRectForFrameRect:window.frame];
	r.origin = NSZeroPoint;
//	r.origin.x = 20;
//	r.origin.y = 20;
//	r.size.width -= r.origin.x * 2;
//	r.size.height -= r.origin.y * 2;
	return r;
}

- (void)prepare
{
	[self constructSections];
	[self constructSectionListView];
}

- (void)constructSections
{
	SBSectionGroupe *groupe0 = nil;
	SBSectionGroupe *groupe1 = nil;
//	SBSectionGroupe *groupe2 = nil;
	SBSectionGroupe *groupe3 = nil;
//	SBSectionGroupe *groupe4 = nil;
	SBSectionGroupe *groupe5 = nil;
	SBSectionItem *item = nil;
	NSInteger index = 0;
	id context = nil;
	sections = [[NSMutableArray alloc] initWithCapacity:0];
	groupe0 = [SBSectionGroupe groupeWithTitle:NSLocalizedString(@"General", nil)];
	item = [SBSectionItem itemWithTitle:NSLocalizedString(@"Open new windows with home page", nil) keyName:kSBOpenNewWindowsWithHomePage controlClass:[NSButton class] context:context];
	[groupe0 addItem:item];
	if (context) context = nil;
	item = [SBSectionItem itemWithTitle:NSLocalizedString(@"Open new tabs with home page", nil) keyName:kSBOpenNewTabsWithHomePage controlClass:[NSButton class] context:context];
	[groupe0 addItem:item];
	if (context) context = nil;
	context = @"http://www.homepage.com";
	item = [SBSectionItem itemWithTitle:NSLocalizedString(@"Home page", nil) keyName:kSBHomePage controlClass:[NSTextField class] context:context];
	[groupe0 addItem:item];
	if (context) context = nil;
	context = @"~/Downloads";
	item = [SBSectionItem itemWithTitle:NSLocalizedString(@"Save downloaded files to", nil) keyName:kSBSaveDownloadedFilesTo controlClass:[NSOpenPanel class] context:context];
	[groupe0 addItem:item];
	if (context) context = nil;
	context = [[[NSMenu alloc] init] autorelease];
	for (index = 0; index < SBCountOfOpenMethods; index++)
	{
		[(NSMenu *)context addItemWithTitle:NSLocalizedString(SBOpenMethods[index], nil) representedObject:SBOpenMethods[index] target:nil action:nil];
	}
	item = [SBSectionItem itemWithTitle:NSLocalizedString(@"Open URL from applications", nil) keyName:kSBOpenURLFromApplications controlClass:[NSPopUpButton class] context:context];
	[groupe0 addItem:item];
	if (context) context = nil;
	item = [SBSectionItem itemWithTitle:NSLocalizedString(@"Quit when the last window is closed", nil) keyName:kSBQuitWhenTheLastWindowIsClosed controlClass:[NSButton class] context:context];
	[groupe0 addItem:item];
	if (context) context = nil;
//	item = [SBSectionItem itemWithTitle:NSLocalizedString(@"Confirm before closing multiple tabs", nil) keyName:kSBConfirmBeforeClosingMultipleTabs controlClass:[NSButton class] context:context];
//	[groupe0 addItem:item];
//	if (context) context = nil;
	item = [SBSectionItem itemWithTitle:NSLocalizedString(@"Check the new version after launching", nil) keyName:kSBCheckTheNewVersionAfterLaunching controlClass:[NSButton class] context:context];
	[groupe0 addItem:item];
	if (context) context = nil;
//	item = [SBSectionItem itemWithTitle:NSLocalizedString(@"Clears all caches after launching", nil) keyName:kSBClearsAllCachesAfterLaunching controlClass:[NSButton class] context:context];
//	[groupe0 addItem:item];
//	if (context) context = nil;
	[sections addObject:groupe0];
	
	groupe1 = [SBSectionGroupe groupeWithTitle:NSLocalizedString(@"Appearance", nil)];
	item = [SBSectionItem itemWithTitle:NSLocalizedString(@"Allows animated image to loop", nil) keyName:kSBAllowsAnimatedImageToLoop controlClass:[NSButton class] context:context];
	[groupe1 addItem:item];
	if (context) context = nil;
	item = [SBSectionItem itemWithTitle:NSLocalizedString(@"Allows animated images", nil) keyName:kSBAllowsAnimatedImages controlClass:[NSButton class] context:context];
	[groupe1 addItem:item];
	if (context) context = nil;
	item = [SBSectionItem itemWithTitle:NSLocalizedString(@"Loads images automatically", nil) keyName:kSBLoadsImagesAutomatically controlClass:[NSButton class] context:context];
	[groupe1 addItem:item];
	if (context) context = nil;
	context = SBEncodingMenu(nil, nil, NO);
	item = [SBSectionItem itemWithTitle:NSLocalizedString(@"Default encoding", nil) keyName:kSBDefaultEncoding controlClass:[NSPopUpButton class] context:context];
	[groupe1 addItem:item];
	if (context) context = nil;
	item = [SBSectionItem itemWithTitle:NSLocalizedString(@"Include backgrounds when printing", nil) keyName:kSBIncludeBackgroundsWhenPrinting controlClass:[NSButton class] context:context];
	[groupe1 addItem:item];
	[sections addObject:groupe1];
	if (context) context = nil;
	
//	groupe2 = [SBSectionGroupe groupeWithTitle:NSLocalizedString(@"Bookmarks", nil)];
//	item = [SBSectionItem itemWithTitle:NSLocalizedString(@"Show bookmarks when window opens", nil) keyName:kSBShowBookmarksWhenWindowOpens controlClass:[NSButton class] context:context];
//	[groupe2 addItem:item];
//	if (context) context = nil;
//	item = [SBSectionItem itemWithTitle:NSLocalizedString(@"Show alert when removing bookmark", nil) keyName:kSBShowAlertWhenRemovingBookmark controlClass:[NSButton class] context:context];
//	[groupe2 addItem:item];
//	if (context) context = nil;
//	item = [SBSectionItem itemWithTitle:NSLocalizedString(@"Updates image when accessing bookmark URL", nil) keyName:kSBUpdatesImageWhenAccessingBookmarkURL controlClass:[NSButton class] context:context];
//	[groupe2 addItem:item];
//	if (context) context = nil;
//	[sections addObject:groupe2];
	
	groupe3 = [SBSectionGroupe groupeWithTitle:NSLocalizedString(@"Security", nil)];
	item = [SBSectionItem itemWithTitle:NSLocalizedString(@"Enable plug-ins", nil) keyName:kSBEnablePlugIns controlClass:[NSButton class] context:context];
	[groupe3 addItem:item];
	if (context) context = nil;
	item = [SBSectionItem itemWithTitle:NSLocalizedString(@"Enable Java", nil) keyName:kSBEnableJava controlClass:[NSButton class] context:context];
	[groupe3 addItem:item];
	if (context) context = nil;
	item = [SBSectionItem itemWithTitle:NSLocalizedString(@"Enable JavaScript", nil) keyName:kSBEnableJavaScript controlClass:[NSButton class] context:context];
	[groupe3 addItem:item];
	if (context) context = nil;
	item = [SBSectionItem itemWithTitle:NSLocalizedString(@"Block pop-up windows", nil) keyName:kSBBlockPopUpWindows controlClass:[NSButton class] context:context];
	[groupe3 addItem:item];
	if (context) context = nil;
	item = [SBSectionItem itemWithTitle:NSLocalizedString(@"URL field shows IDN as ASCII", nil) keyName:kSBURLFieldShowsIDNAsASCII controlClass:[NSButton class] context:context];
	[groupe3 addItem:item];
	if (context) context = nil;
//	context = [[NSMenu alloc] init];
//	for (index = 0; index < SBCountOfCookieMethods; index++)
//		[(NSMenu *)context addItemWithTitle:NSLocalizedString(SBCookieMethods[index], nil) representedObject:SBCookieMethods[index]];
//	item = [SBSectionItem itemWithTitle:NSLocalizedString(@"Accept cookies", nil) keyName:kSBAcceptCookies controlClass:[NSPopUpButton class] context:context];
//	[groupe3 addItem:item];
//	if (context) context = nil;
	[sections addObject:groupe3];
	
//	groupe4 = [SBSectionGroupe groupeWithTitle:NSLocalizedString(@"History", nil)];
//	item = [SBSectionItem itemWithTitle:NSLocalizedString(@"Save history for", nil) keyName:kSBHistorySaveDays controlClass:[NSButton class] context:context];
//	[groupe4 addItem:item];
//	if (context) context = nil;
//	[sections addObject:groupe4];
	
	groupe5 = [SBSectionGroupe groupeWithTitle:NSLocalizedString(@"Advanced", nil)];
	if (context) context = nil;
	item = [SBSectionItem itemWithTitle:NSLocalizedString(@"Enable Web Inspector", nil) keyName:kWebKitDeveloperExtras controlClass:[NSButton class] context:context];
	[groupe5 addItem:item];
	if (context) context = nil;
	item = [SBSectionItem itemWithTitle:NSLocalizedString(@"When a new tab opens, make it active", nil) keyName:kSBWhenNewTabOpensMakeActiveFlag controlClass:[NSButton class] context:context];
	[groupe5 addItem:item];
	if (context) context = nil;
	[sections addObject:groupe5];
}

- (void)constructSectionListView
{
	NSRect r = [self sectionListViewRect];
	sectionListView = [[SBSectionListView alloc] initWithFrame:r];
	[sectionListView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
	sectionListView.sections = sections;
	[[[self window] contentView] addSubview:sectionListView];
}


@end
