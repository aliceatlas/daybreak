/*

NSColor-SBAdditions.m
 
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

#import "NSColor-SBAdditions.h"


@implementation NSColor (SBAdditions)

+ (NSColor *)colorWithLabelColorName:(NSString *)labelColorName
{
	NSColor *color = nil;
	if ([labelColorName isEqualToString:SBBookmarkLabelColorNames[0]])
	{
		
	}
	else if ([labelColorName isEqualToString:SBBookmarkLabelColorNames[1]])
	{
		color = [NSColor colorWithCalibratedRed:SBBookmarkLabelColorRGBA[0 + 1 * 4] green:SBBookmarkLabelColorRGBA[1 + 1 * 4] blue:SBBookmarkLabelColorRGBA[2 + 1 * 4] alpha:SBBookmarkLabelColorRGBA[3 + 1 * 4]];
	}
	else if ([labelColorName isEqualToString:SBBookmarkLabelColorNames[2]])
	{
		color = [NSColor colorWithCalibratedRed:SBBookmarkLabelColorRGBA[0 + 2 * 4] green:SBBookmarkLabelColorRGBA[1 + 2 * 4] blue:SBBookmarkLabelColorRGBA[2 + 2 * 4] alpha:SBBookmarkLabelColorRGBA[3 + 2 * 4]];
	}
	else if ([labelColorName isEqualToString:SBBookmarkLabelColorNames[3]])
	{
		color = [NSColor colorWithCalibratedRed:SBBookmarkLabelColorRGBA[0 + 3 * 4] green:SBBookmarkLabelColorRGBA[1 + 3 * 4] blue:SBBookmarkLabelColorRGBA[2 + 3 * 4] alpha:SBBookmarkLabelColorRGBA[3 + 3 * 4]];
	}
	else if ([labelColorName isEqualToString:SBBookmarkLabelColorNames[4]])
	{
		color = [NSColor colorWithCalibratedRed:SBBookmarkLabelColorRGBA[0 + 4 * 4] green:SBBookmarkLabelColorRGBA[1 + 4 * 4] blue:SBBookmarkLabelColorRGBA[2 + 4 * 4] alpha:SBBookmarkLabelColorRGBA[3 + 4 * 4]];
	}
	else if ([labelColorName isEqualToString:SBBookmarkLabelColorNames[5]])
	{
		color = [NSColor colorWithCalibratedRed:SBBookmarkLabelColorRGBA[0 + 5 * 4] green:SBBookmarkLabelColorRGBA[1 + 5 * 4] blue:SBBookmarkLabelColorRGBA[2 + 5 * 4] alpha:SBBookmarkLabelColorRGBA[3 + 5 * 4]];
	}
	else if ([labelColorName isEqualToString:SBBookmarkLabelColorNames[6]])
	{
		color = [NSColor colorWithCalibratedRed:SBBookmarkLabelColorRGBA[0 + 6 * 4] green:SBBookmarkLabelColorRGBA[1 + 6 * 4] blue:SBBookmarkLabelColorRGBA[2 + 6 * 4] alpha:SBBookmarkLabelColorRGBA[3 + 6 * 4]];
	}
	else if ([labelColorName isEqualToString:SBBookmarkLabelColorNames[7]])
	{
		color = [NSColor colorWithCalibratedRed:SBBookmarkLabelColorRGBA[0 + 7 * 4] green:SBBookmarkLabelColorRGBA[1 + 7 * 4] blue:SBBookmarkLabelColorRGBA[2 + 7 * 4] alpha:SBBookmarkLabelColorRGBA[3 + 7 * 4]];
	}
	else if ([labelColorName isEqualToString:SBBookmarkLabelColorNames[8]])
	{
		color = [NSColor colorWithCalibratedRed:SBBookmarkLabelColorRGBA[0 + 8 * 4] green:SBBookmarkLabelColorRGBA[1 + 8 * 4] blue:SBBookmarkLabelColorRGBA[2 + 8 * 4] alpha:SBBookmarkLabelColorRGBA[3 + 8 * 4]];
	}
	else if ([labelColorName isEqualToString:SBBookmarkLabelColorNames[9]])
	{
		color = [NSColor colorWithCalibratedRed:SBBookmarkLabelColorRGBA[0 + 9 * 4] green:SBBookmarkLabelColorRGBA[1 + 9 * 4] blue:SBBookmarkLabelColorRGBA[2 + 9 * 4] alpha:SBBookmarkLabelColorRGBA[3 + 9 * 4]];
	}
	return color;
}

@end
