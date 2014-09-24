/*

SBDefinitions.m
 
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

// Versions
NSString *SBBookmarkVersion = @"1.0";

// Identifiers
NSString *kSBWebPreferencesIdentifier = @"Sunrise";

// Path components
NSString *kSBApplicationSupportDirectoryName = @"Sunrise3";
NSString *kSBApplicationSupportDirectoryName_Version1 = @"Sunrise";
NSString *kSBBookmarksFileName = @"Bookmarks.plist";
NSString *kSBHistoryFileName = @"History.plist";

// Default values
const NSStringEncoding SBAvailableStringEncodings[] = {
	-2147481087,	// Japanese (Shift JIS)
	21,				// Japanese (ISO 2022-JP)
	3,				// Japanese (EUC)
	-2147482072,	// Japanese (Shift JIS X0213)
	NSNotFound,	
	4,				// Unicode (UTF-8)
	NSNotFound,	
	5,				// Western (ISO Latin 1)
	30,				// Western (Mac OS Roman)
	NSNotFound,	
	-2147481085,	// Traditional Chinese (Big 5)
	-2147481082,	// Traditional Chinese (Big 5 HKSCS)
	-2147482589,	// Traditional Chinese (Windows, DOS)
	NSNotFound,	
	-2147481536,	// Korean (ISO 2022-KR)
	-2147483645,	// Korean (Mac OS)
	-2147482590,	// Korean (Windows, DOS)
	NSNotFound,	
	-2147483130,	// Arabic (ISO 8859-6)
	-2147482362,	// Arabic (Windows)
	NSNotFound,	
	-2147483128,	// Hebrew (ISO 8859-8)
	-2147482363,	// Hebrew (Windows)
	NSNotFound, 
	-2147483129,	// Greek (ISO 8859-7)
	13,				// Greek (Windows)
	NSNotFound, 
	-2147483131,	// Cyrillic (ISO 8859-5)
	-2147483641,	// Cyrillic (Mac OS)
	-2147481086,	// Cyrillic (KOI8-R)
	11,				// Cyrillic (Windows)
	-2147481080,	// Ukrainian (KOI8-U)
	NSNotFound,	
	-2147482595,	// Thai (Windows, DOS)
	NSNotFound,	
	-2147481296,	// Simplified Chinese (GB 2312)
	-2147481083,	// Simplified Chinese (HZ GB 2312)
	-2147482062,	// Chinese (GB 18030)
	NSNotFound, 
	9,				// Central European (ISO Latin 2)
	-2147483619,	// Central European (Mac OS)
	15,				// Central European (Windows Latin 2)
	NSNotFound, 
	-2147482360,	// Vietnamese (Windows)
	NSNotFound, 
	-2147483127,	// Turkish (ISO Latin 5)
	14,				// Turkish (Windows Latin 5)
	NSNotFound, 
	-2147483132,	// Central European (ISO Latin 4)
	-2147482361,	// Baltic (Windows)
	0
};

// Bookmark Key names
NSString *kSBBookmarkVersion = @"Version";
NSString *kSBBookmarkItems = @"Items";
NSString *kSBBookmarkTitle = @"title";
NSString *kSBBookmarkURL = @"url";
NSString *kSBBookmarkImage = @"image";
NSString *kSBBookmarkDate = @"date";
NSString *kSBBookmarkLabelName = @"label";
NSString *kSBBookmarkOffset = @"offset";

// Bookmark color names
NSInteger SBBookmarkCountOfLabelColors = 10;
NSString *SBBookmarkLabelColorNames[] = {
@"None",
@"Red",
@"Orange",
@"Yellow",
@"Green",
@"Blue",
@"Purple",
@"Magenta",
@"Gray",
@"Black"
};