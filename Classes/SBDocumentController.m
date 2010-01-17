/*

SBDocumentController.m
 
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

#import "SBDocumentController.h"
#import "SBDocument.h"
#import "SBPreferences.h"

@implementation SBDocumentController

- (NSString *)defaultType
{
	NSString *defaultType = nil;
	defaultType = kSBDocumentTypeName;
	return defaultType;
}

- (NSString *)typeForContentsOfURL:(NSURL *)inAbsoluteURL error:(NSError **)outError
{
	NSString *type = nil;
	if ([inAbsoluteURL isFileURL])
	{
		type = [super typeForContentsOfURL:inAbsoluteURL error:outError];
	}
	else {
		type = kSBDocumentTypeName;
	}
	return type;
}

- (id)openUntitledDocumentAndDisplay:(BOOL)displayDocument error:(NSError **)outError
{
	NSString *homepage = [[SBPreferences sharedPreferences] homepage:YES];
	BOOL sidebarVisibility = [[NSUserDefaults standardUserDefaults] boolForKey:kSBSidebarVisibilityFlag];
	NSURL *url = [homepage length] > 0 ? [NSURL URLWithString:[homepage requestURLString]] : nil;
	return [self openUntitledDocumentAndDisplay:displayDocument sidebarVisibility:sidebarVisibility initialURL:url error:outError];
}

- (id)openUntitledDocumentAndDisplay:(BOOL)displayDocument sidebarVisibility:(BOOL)sidebarVisibility initialURL:(NSURL *)url error:(NSError **)outError
{
	id doc = nil;
	NSString *type = nil;
	type = [self typeForContentsOfURL:url error:outError];
	if ([type isEqualToString:kSBStringsDocumentTypeName])
	{
	}
	else {
		SBDocument *document = nil;
		document = [self makeUntitledDocumentOfType:kSBDocumentTypeName error:outError];
		if (document)
		{
			if (url)
				document.initialURL = url;
			document.sidebarVisibility = sidebarVisibility;
			[self addDocument:document];
			[document makeWindowControllers];
			if (displayDocument)
			{
				[document showWindows];
			}
			doc = document;
		}
	}
	return doc;
}

@end
