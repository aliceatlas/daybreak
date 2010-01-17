/*

SBPreferences.m
 
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

#import "SBPreferences.h"
#import "SBUtil.h"

@implementation SBPreferences

static SBPreferences *_sharedPreferences;

+ (id)sharedPreferences
{
	if (!_sharedPreferences)
	{
		_sharedPreferences = [[SBPreferences alloc] init];
	}
	return _sharedPreferences;
}

- (void)registerDefaults
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:0];
	NSString *homaepage = SBDefaultHomePage();
	NSString *downloadsPath = SBDefaultSaveDownloadedFilesToPath();
	// Common
	[info setObject:[NSNumber numberWithFloat:kSBDefaultSidebarWidth] forKey:kSBSidebarWidth];
	[info setObject:[NSNumber numberWithInteger:SBSidebarRightPosition] forKey:kSBSidebarPosition];
	[info setObject:[NSNumber numberWithBool:YES] forKey:kSBSidebarVisibilityFlag];
	[info setObject:[NSNumber numberWithBool:YES] forKey:kSBTabbarVisibilityFlag];
	[info setObject:[NSNumber numberWithInteger:kSBDefaultBookmarkCellWidth] forKey:kSBBookmarkCellWidth];
	[info setObject:[NSNumber numberWithInteger:SBBookmarkIconMode] forKey:kSBBookmarkMode];
	[info setObject:SBUserAgentNames[0] forKey:kSBUserAgentName];
	// General
	[info setObject:[NSNumber numberWithBool:YES] forKey:kSBOpenNewWindowsWithHomePage];
	[info setObject:[NSNumber numberWithBool:YES] forKey:kSBOpenNewTabsWithHomePage];
	if (homaepage)
		[info setObject:homaepage forKey:kSBHomePage];
	if (downloadsPath)
		[info setObject:downloadsPath forKey:kSBSaveDownloadedFilesTo];
	[info setObject:@"in the current tab" forKey:kSBOpenURLFromApplications];
	[info setObject:[NSNumber numberWithBool:YES] forKey:kSBQuitWhenTheLastWindowIsClosed];
	[info setObject:[NSNumber numberWithBool:YES] forKey:kSBConfirmBeforeClosingMultipleTabs];
	[info setObject:[NSNumber numberWithBool:YES] forKey:kSBCheckTheNewVersionAfterLaunching];
	[info setObject:[NSNumber numberWithBool:YES] forKey:kSBClearsAllCachesAfterLaunching];
	// Appearance
//	kSBAllowsAnimatedImageToLoop
//	kSBAllowsAnimatedImages
//	kSBLoadsImagesAutomatically
//	kSBDefaultEncoding
//	kSBIncludeBackgroundsWhenPrinting
	// Bookmarks
	[info setObject:[NSNumber numberWithBool:YES] forKey:kSBShowBookmarksWhenWindowOpens];
	[info setObject:[NSNumber numberWithBool:YES] forKey:kSBShowAlertWhenRemovingBookmark];
	[info setObject:[NSNumber numberWithBool:YES] forKey:kSBUpdatesImageWhenAccessingBookmarkURL];
	// Security
//	kSBEnablePlugIns
//	kSBEnableJava
//	kSBEnableJavaScript
//	kSBBlockPopUpWindows
	[info setObject:[NSNumber numberWithBool:NO] forKey:kSBURLFieldShowsIDNAsASCII];
	[info setObject:@"Only visited sites" forKey:kSBAcceptCookies];
	// History
	[info setObject:[NSNumber numberWithDouble:SBDefaultHistorySaveSeconds] forKey:kSBHistorySaveDays];
	// Advanced
	// WebKitDeveloper
	[info setObject:[NSNumber numberWithBool:YES] forKey:kWebKitDeveloperExtras];
	[info setObject:[NSNumber numberWithBool:YES] forKey:kSBWhenNewTabOpensMakeActiveFlag];
	[defaults registerDefaults:[[info copy] autorelease]];
}

- (NSString *)homepage:(BOOL)isInWindow
{
	NSString *homepage = nil;
	if ([[self class] objectForKey:kSBHomePage])
	{
		if (isInWindow)
		{
			if ([[self class] boolForKey:kSBOpenNewWindowsWithHomePage])
			{
				homepage = [[self class] objectForKey:kSBHomePage];
			}
		}
		else {
			if ([[self class] boolForKey:kSBOpenNewTabsWithHomePage])
			{
				homepage = [[self class] objectForKey:kSBHomePage];
			}
		}
	}
	return homepage;
}

+ (BOOL)boolForKey:(NSString *)keyName
{
	return [[self objectForKey:keyName] boolValue];
}

+ (id)objectForKey:(NSString *)keyName
{
	id object = nil;
	WebPreferences *preferences = SBGetWebPreferences();
	if ([keyName isEqualToString:kSBAllowsAnimatedImageToLoop])
	{
		object = [NSNumber numberWithBool:[preferences allowsAnimatedImageLooping]];
	}
	else if ([keyName isEqualToString:kSBAllowsAnimatedImages])
	{
		object = [NSNumber numberWithBool:[preferences allowsAnimatedImages]];
	}
	else if ([keyName isEqualToString:kSBLoadsImagesAutomatically])
	{
		object = [NSNumber numberWithBool:[preferences loadsImagesAutomatically]];
	}
	else if ([keyName isEqualToString:kSBDefaultEncoding])
	{
		object = [preferences defaultTextEncodingName];
	}
	else if ([keyName isEqualToString:kSBIncludeBackgroundsWhenPrinting])
	{
		object = [NSNumber numberWithBool:[preferences shouldPrintBackgrounds]];
	}
	else if ([keyName isEqualToString:kSBEnablePlugIns])
	{
		object = [NSNumber numberWithBool:[preferences arePlugInsEnabled]];
	}
	else if ([keyName isEqualToString:kSBEnableJava])
	{
		object = [NSNumber numberWithBool:[preferences isJavaEnabled]];
	}
	else if ([keyName isEqualToString:kSBEnableJavaScript])
	{
		object = [NSNumber numberWithBool:[preferences isJavaScriptEnabled]];
	}
	else if ([keyName isEqualToString:kSBBlockPopUpWindows])
	{
		object = [NSNumber numberWithBool:![preferences javaScriptCanOpenWindowsAutomatically]];
	}
	else {
		object = [[NSUserDefaults standardUserDefaults] objectForKey:keyName];
	}
	return object;
}

+ (void)setBool:(BOOL)value forKey:(NSString *)keyName
{
	[self setObject:[NSNumber numberWithBool:value] forKey:keyName];
}

+ (void)setObject:(id)object forKey:(NSString *)keyName
{
	WebPreferences *preferences = SBGetWebPreferences();
	if ([keyName isEqualToString:kSBAllowsAnimatedImageToLoop])
	{
		[preferences setAllowsAnimatedImageLooping:[object boolValue]];
	}
	else if ([keyName isEqualToString:kSBAllowsAnimatedImages])
	{
		[preferences setAllowsAnimatedImages:[object boolValue]];
	}
	else if ([keyName isEqualToString:kSBLoadsImagesAutomatically])
	{
		[preferences setLoadsImagesAutomatically:[object boolValue]];
	}
	else if ([keyName isEqualToString:kSBDefaultEncoding])
	{
		[preferences setDefaultTextEncodingName:object];
	}
	else if ([keyName isEqualToString:kSBIncludeBackgroundsWhenPrinting])
	{
		[preferences setShouldPrintBackgrounds:[object boolValue]];
	}
	else if ([keyName isEqualToString:kSBEnablePlugIns])
	{
		[preferences setPlugInsEnabled:[object boolValue]];
	}
	else if ([keyName isEqualToString:kSBEnableJava])
	{
		[preferences setJavaEnabled:[object boolValue]];
	}
	else if ([keyName isEqualToString:kSBEnableJavaScript])
	{
		[preferences setJavaScriptEnabled:[object boolValue]];
	}
	else if ([keyName isEqualToString:kSBBlockPopUpWindows])
	{
		[preferences setJavaScriptCanOpenWindowsAutomatically:![object boolValue]];
	}
	else {
		[[NSUserDefaults standardUserDefaults] setObject:object forKey:keyName];
	}
}

@end
