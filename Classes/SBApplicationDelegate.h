/*

SBApplicationDelegate.h
 
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

#import "SBDefinitions.h"

@class SBDocument;
@class SBLocalizationWindowController;
@class SBPreferencesWindowController;
@class SBUpdateView;
@interface SBApplicationDelegate : NSObject
{
	SBLocalizationWindowController *localizationWindowController;
	SBPreferencesWindowController *preferencesWindowController;
	SBUpdateView *updateView;
}

//  Actions
- (void)destructUpdateView;
- (void)destructLocalizeWindowController;
- (void)destructPreferencesWindowController;
- (void)update:(NSString *)versionString;
- (void)doneUpdate;
- (void)cancelUpdate;
- (void)openStringsWithPath:(NSString *)path;
- (void)openStringsWithPath:(NSString *)path anotherPath:(NSString *)anotherPath;
// Menu Actions
- (void)provideFeedback:(id)sender;
- (void)checkForUpdates:(id)sender;
- (void)preferences:(id)sender;
- (void)emptyAllCaches:(id)sender;
- (void)newDocument:(id)sender;
- (void)localize:(id)sender;
- (void)plugins:(id)sender;
- (void)sunrisepage:(id)sender;
#ifdef __debug__
// Debug
- (void)constructDebugMenu;
- (void)writeViewStructure:(id)sender;
- (void)writeMainMenu:(id)sender;
- (void)validateStrings:(id)sender;
#endif

@end
