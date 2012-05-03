/*

SBApplicationDelegate.m
 
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

#import "SBApplicationDelegate.h"
#import "SBBookmarks.h"
#import "SBDocument.h"
#import "SBDocumentController.h"
#import "SBDocumentWindow.h"
#import "SBDownloads.h"
#import "SBHistory.h"
#import "SBLocalizationWindowController.h"
#import "SBPreferences.h"
#import "SBPreferencesWindowController.h"
#import "SBSavePanel.h"
#import "SBUpdater.h"
#import "SBUpdateView.h"
#import "SBUtil.h"

@implementation SBApplicationDelegate

- (void)dealloc
{
	[self destructUpdateView];
	[self destructLocalizeWindowController];
	[self destructPreferencesWindowController];
	[super dealloc];
}

#pragma mark Application Delegate

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
#ifdef __debug__
	[self constructDebugMenu];
#endif
	// Handle AppleScript (Open URL from other application)
	[[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(openURL:withReplyEvent:) forEventClass:'GURL' andEventID:'GURL'];
	// Localize menu
	SBLocalizeTitlesInMenu([NSApp mainMenu]);
	// Register defaults
	[[SBPreferences sharedPreferences] registerDefaults];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	SBUpdater *updater = [SBUpdater sharedUpdater];
	// Add observe notifications
	[center addObserver:self selector:@selector(updaterShouldUpdate:) name:SBUpdaterShouldUpdateNotification object:updater];
	[center addObserver:self selector:@selector(updaterNotNeedUpdate:) name:SBUpdaterNotNeedUpdateNotification object:updater];
	[center addObserver:self selector:@selector(updaterDidFailChecking:) name:SBUpdaterDidFailCheckingNotification object:updater];
	// Read bookmarks
	[SBBookmarks sharedBookmarks];
	// Create History instance
	[SBHistory sharedHistory];
	[self performSelector:@selector(applicationHasFinishLaunching:) withObject:[aNotification object] afterDelay:0];
}

- (void)applicationHasFinishLaunching:(NSApplication *)application
{
	if ([[NSUserDefaults standardUserDefaults] boolForKey:kSBCheckTheNewVersionAfterLaunching])
	{
		// Check new version
		[[SBUpdater sharedUpdater] check];
	}
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames
{
	NSUInteger index = 0;
	SBDocumentController *documentController = [SBDocumentController sharedDocumentController];
	SBDocument *document = SBGetSelectedDocument();
	if (document)
	{
		for (NSString *filename in filenames)
		{
			NSString *type = nil;
			NSError *error = nil;
			NSURL *url = [NSURL fileURLWithPath:filename];
			if ((type = [documentController typeForContentsOfURL:url error:&error]))
			{
				if ([type isEqualToString:kSBStringsDocumentTypeName])
				{
					NSString *path = nil;
					path = [[NSBundle mainBundle] pathForResource:@"Localizable" ofType:@"strings"];
					[self openStringsWithPath:path anotherPath:[url path]];
				}
				else if ([type isEqualToString:kSBDocumentTypeName])
				{
					[document constructNewTabWithURL:url selection:(index == ([filenames count] - 1))];
					index++;
				}
			}
		}
	}
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	// Add observe notifications
	[center removeObserver:self name:SBUpdaterShouldUpdateNotification object:nil];
	[center removeObserver:self name:SBUpdaterNotNeedUpdateNotification object:nil];
	[center removeObserver:self name:SBUpdaterDidFailCheckingNotification object:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:kSBQuitWhenTheLastWindowIsClosed];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	NSApplicationTerminateReply reply = NSTerminateNow;
	// Is downloading
	if ([[SBDownloads sharedDownloads] downloading])
	{
		NSString *title = NSLocalizedString(@"Are you sure you want to quit? Sunrise is currently downloading some files. If you quit now, it will not finish downloading these files.", nil);
		NSString *message = [NSString string];
		NSString *okTitle = NSLocalizedString(@"Quit", nil);
		NSString *otherTitle = NSLocalizedString(@"Don't Quit", nil);
		SBDocument *doc = SBGetSelectedDocument();
		SBDocumentWindow *window = doc ? doc.window : nil;
		NSAlert *alert = [NSAlert alertWithMessageText:title defaultButton:okTitle alternateButton:nil otherButton:otherTitle informativeTextWithFormat:message];
		[alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(shouldTerminateAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
		reply = NSTerminateLater;
	}
	return reply;
}

- (void)shouldTerminateAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	BOOL shouldTerminate = YES;
	if (returnCode == NSAlertOtherReturn)
	{
		shouldTerminate = NO;
	}
	[NSApp replyToApplicationShouldTerminate:shouldTerminate];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
	return flag;
}

#pragma mark Apple Events

- (void)openURL:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
	NSString *URLString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
	if (URLString)
	{
		SBDocument *document = nil;
		NSString *method = [[NSUserDefaults standardUserDefaults] objectForKey:kSBOpenURLFromApplications];
		if ([method isEqualToString:@"in a new window"])
		{
			NSError *error = nil;
			document = [SBGetDocumentController() openUntitledDocumentAndDisplay:YES error:&error];
			if (document)
			{
				[document openURLStringInSelectedTabViewItem:URLString];
			}
		}
		else if ([method isEqualToString:@"in a new tab"])
		{
			document = SBGetSelectedDocument();
			if (document)
			{
				[document constructNewTabWithURL:[NSURL URLWithString:URLString] selection:YES];
			}
		}
		else if ([method isEqualToString:@"in the current tab"])
		{
			document = SBGetSelectedDocument();
			if (document)
			{
				[document openURLStringInSelectedTabViewItem:URLString];
			}
		}
	}
}

#pragma mark Notifications

- (void)updaterShouldUpdate:(NSNotification *)aNotification
{
	NSDictionary *userInfo = [aNotification userInfo];
	NSString *versionString = [userInfo objectForKey:kSBUpdaterVersionString];
	[self update:versionString];
}

- (void)updaterNotNeedUpdate:(NSNotification *)aNotification
{
	NSDictionary *userInfo = [aNotification userInfo];
	NSString *versionString = [userInfo objectForKey:kSBUpdaterVersionString];
	NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Sunrise %@ is currently the newest version available.", nil), versionString];
	NSString *defaultButton = NSLocalizedString(@"OK", nil);
	NSRunAlertPanel(title, [NSString string], defaultButton, nil, nil);
}

- (void)updaterDidFailChecking:(NSNotification *)aNotification
{
	NSDictionary *userInfo = [aNotification userInfo];
	NSString *errorDescription = [userInfo objectForKey:kSBUpdaterErrorDescription];
	NSString *title = errorDescription;
	NSString *defaultButton = NSLocalizedString(@"OK", nil);
	NSRunAlertPanel(title, [NSString string], defaultButton, nil, nil);
}

#pragma mark Actions

- (void)destructUpdateView
{
	if (updateView)
	{
		[updateView removeFromSuperview];
		[updateView release];
		updateView = nil;
	}
}

- (void)destructLocalizeWindowController
{
	if (localizationWindowController)
	{
		[localizationWindowController close];
		[localizationWindowController release];
		localizationWindowController = nil;
	}
}

- (void)destructPreferencesWindowController
{
	if (preferencesWindowController)
	{
		[preferencesWindowController close];
		[preferencesWindowController release];
		preferencesWindowController = nil;
	}
}

- (void)update:(NSString *)versionString
{
	SBDocumentWindow *window = [SBGetSelectedDocument() window];
	NSDictionary *info = [[NSBundle mainBundle] localizedInfoDictionary];
	NSString *urlString = info ? [info objectForKey:@"SBReleaseNotesURL"] : nil;
	[self destructUpdateView];
	updateView = [[SBUpdateView alloc] initWithFrame:[window splitViewRect]];
	updateView.title = [NSString stringWithFormat:NSLocalizedString(@"A new version of Sunrise %@ is available.", nil), versionString];
	updateView.text = NSLocalizedString(@"If you click the \"Download\" button, the download of the disk image file will begin. ", nil);
	updateView.versionString = versionString;
	updateView.target = self;
	updateView.doneSelector = @selector(doneUpdate);
	updateView.cancelSelector = @selector(cancelUpdate);
	[updateView loadRequest:[NSURL URLWithString:urlString]];
	[window showCoverWindow:updateView];
}

- (void)doneUpdate
{
	SBDocument *document = SBGetSelectedDocument();
	SBDocumentWindow *window = document.window;
	NSString *versionString = updateView.versionString;
	NSMutableString *mutableVString = [versionString mutableCopy];
	NSRange r;
	do {
		r = [mutableVString rangeOfString:@" "];
		if (r.location != NSNotFound && r.length > 0)
			[mutableVString deleteCharactersInRange:r];
	}
	while (r.location != NSNotFound && r.length > 0);
	if ([versionString length] != [mutableVString length])
		versionString = [[mutableVString copy] autorelease];
	[mutableVString release];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kSBUpdaterNewVersionURL, versionString]];
	[window hideCoverWindow];
	[self destructUpdateView];
	[document startDownloadingForURL:url];
}

- (void)cancelUpdate
{
	SBDocumentWindow *window = [SBGetSelectedDocument() window];
	[window hideCoverWindow];
}

- (void)openStringsWithPath:(NSString *)path
{
	[self openStringsWithPath:path anotherPath:nil];
}

- (void)openStringsWithPath:(NSString *)path anotherPath:(NSString *)anotherPath
{
	NSMutableArray *textSet = nil;
	NSArray *fieldSet = nil;
	NSSize viewSize = NSZeroSize;
	SBGetLocalizableTextSet(path, &textSet, &fieldSet, &viewSize);
	if ([textSet count] > 0)
	{
		[self destructLocalizeWindowController];
		localizationWindowController = [[SBLocalizationWindowController alloc] initWithViewSize:viewSize];
		localizationWindowController.fieldSet = fieldSet;
		localizationWindowController.textSet = textSet;
		if (anotherPath)
			[localizationWindowController mergeFilePath:anotherPath];
		[localizationWindowController showWindow:nil];
		
		if (floor(NSAppKitVersionNumber) < 1038)	// Resize window frame for auto-resizing (Call for 10.5. Strange bugs of Mac)
		{
			NSWindow *window = [localizationWindowController window];
			NSRect r = [window frame];
			[window setFrame:NSMakeRect(r.origin.x, r.origin.y, r.size.width, r.size.height - 1) display:YES];
			[window setFrame:r display:YES];
		}
	}
}

#pragma mark Menu

// Application

- (void)provideFeedback:(id)sender
{
	NSString *urlString = nil;
	NSString *title = NSLocalizedString(@"Sunrise Feedback", nil);
	if ([kSBFeedbackMailAddress length] > 0)
	{
		urlString = [NSString stringWithFormat:@"mailto:%@?subject=%@", kSBFeedbackMailAddress, title];
		urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
	}
}

- (void)checkForUpdates:(id)sender
{
	SBUpdater *updater = [SBUpdater sharedUpdater];
	updater.raiseResult = YES;
	updater.checkSkipVersion = NO;
	// Check new version
	[updater check];
}

- (void)preferences:(id)sender
{
	NSSize viewSize = NSZeroSize;
	viewSize.width = 800;
	viewSize.height = 600;
	[self destructPreferencesWindowController];
	preferencesWindowController = [[SBPreferencesWindowController alloc] initWithViewSize:viewSize];
	[preferencesWindowController prepare];
	[preferencesWindowController showWindow:nil];
}

- (void)emptyAllCaches:(id)sender
{
	NSString *title = nil;
	NSString *message = nil;
	NSString *defaultTitle = nil;
	NSString *alternateTitle = nil;
	NSURLCache *cache = nil;
	cache = [NSURLCache sharedURLCache];
	title = NSLocalizedString(@"Are you sure you want to empty the cache?", nil);
	message = NSLocalizedString(@"Sunrise saves the contents of webpages you open, and stores them in a cache, so the pages load faster when you visit them again.", nil);
	if ([cache diskCapacity] > 0 && [cache memoryCapacity] > 0)
	{
		NSString *diskCapacityDescription = nil;
		NSString *memoryCapacityDescription = nil;
		diskCapacityDescription = [NSString bytesString:[cache currentDiskUsage] expectedLength:[cache diskCapacity]];
		memoryCapacityDescription = [NSString bytesString:[cache currentMemoryUsage] expectedLength:[cache memoryCapacity]];
		message = [message stringByAppendingFormat:@"\n\n%@: %@\n%@: %@\n", NSLocalizedString(@"On disk", nil), diskCapacityDescription, NSLocalizedString(@"In memory", nil), memoryCapacityDescription];
	}
	defaultTitle = NSLocalizedString(@"Empty", nil);
	alternateTitle = NSLocalizedString(@"Cancel", nil);
	NSBeginAlertSheet(title, defaultTitle, alternateTitle, nil, nil, self, @selector(emptyAllCachesDidEnd:returnCode:contextInfo:), nil, nil, message);
}

- (void)emptyAllCachesDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSOKButton)
	{
		NSURLCache *cache = nil;
		cache = [NSURLCache sharedURLCache];
		[cache removeAllCachedResponses];
	}
	[sheet orderOut:nil];
}

// File

- (void)newDocument:(id)sender
{
	NSError *error = nil;
	[SBGetDocumentController() openUntitledDocumentAndDisplay:YES error:&error];
	if (error)
	{
		DebugLog(@"%s %@", __func__, error);
	}
}

- (void)openDocument:(id)sender
{
	SBOpenPanel *panel = [SBOpenPanel openPanel];
	NSInteger result = NSCancelButton;
	[panel setCanChooseDirectories:NO];
	[panel setAllowsMultipleSelection:YES];
	result = [panel runModalForDirectory:nil file:nil types:nil];
	if (result == NSOKButton)
	{
		SBDocument *document = SBGetSelectedDocument();
		if (document)
		{
			NSUInteger index = 0;
			NSArray *filenames = [panel filenames];
			for (NSString *filename in filenames)
			{
				[document constructNewTabWithURL:[NSURL fileURLWithPath:filename] selection:(index == ([filenames count] - 1))];
				index++;
			}
		}
	}
}

// Help

- (void)localize:(id)sender
{
	if ([[localizationWindowController window] isVisible])
	{
		[localizationWindowController showWindow:nil];
	}
	else {
		NSString *path = nil;
		path = [[NSBundle mainBundle] pathForResource:@"Localizable" ofType:@"strings"];
		[self openStringsWithPath:path];
	}
}

- (void)plugins:(id)sender
{
	NSString *path = SBFilePathInApplicationBundle(@"Plug-ins", @"html");
	if (path)
	{
		SBDocument *document = SBGetSelectedDocument();
		if (document)
		{
			[document constructNewTabWithURL:[NSURL fileURLWithPath:path] selection:YES];
		}
	}
}

- (void)sunrisepage:(id)sender
{
	NSDictionary *info = [[NSBundle mainBundle] localizedInfoDictionary];
	NSString *string = info ? [info objectForKey:@"SBHomePageURL"] : nil;
	if (string)
	{
		SBDocument *document = SBGetSelectedDocument();
		if (document)
		{
			if (document.selectedWebDataSource)
			{
				[document constructNewTabWithURL:[NSURL URLWithString:string] selection:YES];
			}
			else {
				[document openURLStringInSelectedTabViewItem:string];
			}
		}
	}
}

#ifdef __debug__
#pragma mark Debug

- (void)constructDebugMenu
{
	NSMenu *mainMenu = nil;
	NSMenu *debugMenu = nil;
	NSMenuItem *debugMenuItem = nil;
	NSMenuItem *writeViewStructure = nil;
	NSMenuItem *writeMainMenu = nil;
	NSMenuItem *validateStrings = nil;
	NSMenuItem *debugUI = nil;
	mainMenu = [NSApp mainMenu];
	debugMenuItem = [[[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""] autorelease];
	debugMenu = [[[NSMenu alloc] initWithTitle:@"Debug"] autorelease];
	writeViewStructure = [[[NSMenuItem alloc] initWithTitle:@"Export View Structure..." action:@selector(writeViewStructure:) keyEquivalent:@""] autorelease];
	writeMainMenu = [[[NSMenuItem alloc] initWithTitle:@"Export Menu as plist..." action:@selector(writeMainMenu:) keyEquivalent:@""] autorelease];
	validateStrings = [[[NSMenuItem alloc] initWithTitle:@"Validate strings file..." action:@selector(validateStrings:) keyEquivalent:@""] autorelease];
	debugUI = [[[NSMenuItem alloc] initWithTitle:@"Debug UI..." action:@selector(debugAddDummyDownloads:) keyEquivalent:@""] autorelease];
	[debugMenu addItem:writeViewStructure];
	[debugMenu addItem:writeMainMenu];
	[debugMenu addItem:validateStrings];
	[debugMenu addItem:debugUI];
	[debugMenuItem setSubmenu:debugMenu];
	[mainMenu addItem:debugMenuItem];
}

- (void)writeViewStructure:(id)sender
{
	SBDocument *document = SBGetSelectedDocument();
	id view = document.window.contentView;
	if (view)
	{
		NSSavePanel *panel = [NSSavePanel savePanel];
		if ([panel runModalForDirectory:nil file:@"ViewStructure.plist"])
		{
			NSString *path = [panel filename];
			SBDebugWriteViewStructure(view, path);
		}
	}
}

- (void)writeMainMenu:(id)sender
{
	NSSavePanel *panel = [NSSavePanel savePanel];
	if ([panel runModalForDirectory:nil file:@"Menu.plist"])
	{
		NSString *path = [panel filename];
		SBDebugWriteMainMenu(path);
	}
}

- (void)validateStrings:(id)sender
{
	SBOpenPanel *panel = [SBOpenPanel openPanel];
	NSString *path = [[NSBundle mainBundle] resourcePath];
	if ([panel runModalForDirectory:path file:nil types:[NSArray arrayWithObject:@"strings"]])
	{
		NSMutableArray *tset = nil;
		NSMutableArray *fset = nil;
		NSSize vsize = NSZeroSize;
		NSUInteger index = 0;
		SBGetLocalizableTextSet([panel filename], &tset, &fset, &vsize);
		for (NSArray *texts in tset)
		{
			NSString *text0 = [texts objectAtIndex:0];
			NSUInteger i = 0;
			for (NSArray *ts in tset)
			{
				NSString *t0 = [ts objectAtIndex:0];
				if ([text0 isEqualToString:t0] && index != i)
				{
					NSLog(@"Same keys %d : %@", i, t0);
				}
				i++;
			}
			index++;
		}
	}
}

#endif

@end
