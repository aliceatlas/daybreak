/*

NSString-SBURLAdditions.m
 
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

#import "NSString-SBURLAdditions.h"

NSString *SBGigaByteUnitString = @"GB";
NSString *SBMegaByteUnitString = @"MB";
NSString *SBKiroByteUnitString = @"KB";
NSString *SBByteUnitString = @"byte";
NSString *SBBytesUnitString = @"bytes";

@implementation NSString (SBAdditions)

- (BOOL)containsCharacter:(unichar)character
{
	BOOL r = NO;
	NSInteger i = 0;
	NSInteger length = [self length];
	for (i = 0; i < length; i++)
	{
		unichar c = [self characterAtIndex:i];
		if (c == character)
		{
			r = YES;
			break;
		}
	}
	return r;
}

- (NSComparisonResult)compareAsVersionString:(NSString *)string
{
	NSComparisonResult result = NSOrderedSame;
	NSArray *array0 = [self componentsSeparatedByString:@" "];
	NSArray *array1 = [string componentsSeparatedByString:@" "];
	NSString *string0 = nil;
	NSString *string1 = nil;
	if ([array1 count] > 1 && [array0 count] > 1)
	{
		string0 = [array0 objectAtIndex:0];
		string1 = [array1 objectAtIndex:0];
		result = [string0 compare:string1];
		if (result == NSOrderedSame)
		{
			string0 = [array0 objectAtIndex:1];
			string1 = [array1 objectAtIndex:1];
			result = [string0 compare:string1];
		}
	}
	else if ([array1 count] > 0 && [array0 count] > 1)
	{
		string0 = [array0 objectAtIndex:0];
		string1 = [array1 objectAtIndex:0];
		result = [string0 compare:string1];
		if (result == NSOrderedSame)
		{
			result = NSOrderedAscending;
		}
	}
	else if ([array1 count] > 1 && [array0 count] > 0)
	{
		string0 = [array0 objectAtIndex:0];
		string1 = [array1 objectAtIndex:0];
		result = [string0 compare:string1];
		if (result == NSOrderedSame)
		{
			result = NSOrderedDescending;
		}
	}
	else if ([array1 count] > 0 && [array0 count] > 0)
	{
		string0 = [array0 objectAtIndex:0];
		string1 = [array1 objectAtIndex:0];
		result = [string0 compare:string1];
	}
	return result;
}

+ (NSString *)bytesStringForLength:(long long)length
{
	return [self bytesStringForLength:length unit:YES];
}

+ (NSString *)bytesStringForLength:(long long)length unit:(BOOL)hasUnit
{
	NSString *string = nil;
	NSString *format = nil;
	NSString *unitString = nil;
	CGFloat value;
	unitString = [NSString unitStringForLength:length];
	if (length > (1024 * 1024 * 1024))	// giga
	{
		value = (length > 0 ? ((CGFloat)length / (1024 * 1024 * 1024)) : 0);
		if (value == (NSInteger)value)
		{
			format = @"%d";
			if (hasUnit) format = [format stringByAppendingFormat:@" %@", unitString];
			string = [NSString stringWithFormat:format, (NSInteger)value];
		}
		else {
			format = @"%.2f";
			if (hasUnit) format = [format stringByAppendingFormat:@" %@", unitString];
			string = [NSString stringWithFormat:format, value];
		}
	}
	else if (length > (1024 * 1024))	// mega
	{
		value = (length > 0 ? ((CGFloat)length / (1024 * 1024)) : 0);
		if (value == (NSInteger)value)
		{
			format = @"%d";
			if (hasUnit) format = [format stringByAppendingFormat:@" %@", unitString];
			string = [NSString stringWithFormat:format, (NSInteger)value];
		}
		else {
			format = @"%.1f";
			if (hasUnit) format = [format stringByAppendingFormat:@" %@", unitString];
			string = [NSString stringWithFormat:format, value];
		}
	}
	else if (length > 1024)				// kilo
	{
		value = (length > 0 ? ((CGFloat)length / 1024) : 0);
		format = @"%d";
		if (hasUnit) format = [format stringByAppendingFormat:@" %@", unitString];
		string = [NSString stringWithFormat:format, (NSInteger)value];
	}
	else{
		value = length;
		format = @"%d";
		if (hasUnit) format = [format stringByAppendingFormat:@" %@", unitString];
		string = [NSString stringWithFormat:format, (NSInteger)value];
	}
	return string;
}

+ (NSString *)unitStringForLength:(long long)length
{
	NSString *string = nil;
	if (length > (1024 * 1024 * 1024))	// giga
	{
		string = SBGigaByteUnitString;
	}
	else if (length > (1024 * 1024))	// mega
	{
		string = SBMegaByteUnitString;
	}
	else if (length > 1024)				// kilo
	{
		string = SBKiroByteUnitString;
	}
	else{
		string = (length <= 1 ? SBByteUnitString : SBBytesUnitString);
		string = NSLocalizedString(string, nil);
	}
	return string;
}

+ (NSString *)bytesString:(long long)receivedLegnth expectedLength:(long long)expectedLength
{
	NSString *string = nil;
	BOOL sameUnit = [[NSString unitStringForLength:receivedLegnth] isEqualToString:[NSString unitStringForLength:expectedLength]];
	NSString *received = nil;
	NSString *expected = [NSString bytesStringForLength:expectedLength];
	if (sameUnit)
	{
		received = [NSString bytesStringForLength:receivedLegnth unit:NO];
		string = [NSString stringWithFormat:@"%@/%@", received, expected];
	}
	else {
		received = [NSString bytesStringForLength:receivedLegnth];
		string = [NSString stringWithFormat:@"%@/%@", received, expected];
	}
	return string;
}

- (NSString *)stringByDeletingQuotations
{
	return [self stringByDeletingCharacter:@"\""];
}

- (NSString *)stringByDeletingSpaces
{
	return [self stringByDeletingCharacter:@" "];
}

- (NSString *)stringByDeletingCharacter:(NSString *)character
{
	NSString *string = self;
	if ([self rangeOfString:character].location != NSNotFound)
	{
		NSRange firstRange = {NSNotFound, 0};
		NSRange lastRange = {NSNotFound, 0};
		NSRange range = {NSNotFound, 0};
		firstRange = [string rangeOfString:character];
		lastRange = [string rangeOfString:character options:NSBackwardsSearch];
		if (firstRange.location != NSNotFound && lastRange.location != NSNotFound)
		{
			if (NSEqualRanges(firstRange, lastRange))
			{
				string = [string stringByReplacingCharactersInRange:firstRange withString:[NSString string]];
			}
			else {
				range.location = firstRange.location + firstRange.length;
				range.length = lastRange.location - range.location;
				string = [string substringWithRange:range];
			}
		}
	}
	return string;
}

@end


@implementation NSString (SBURLAdditions)

- (BOOL)isURLString:(BOOL *)hasScheme 
{
	BOOL r = NO;
	if (([self rangeOfString:@" "].location == NSNotFound && [self rangeOfString:@"."].location != NSNotFound) || 
		[self hasPrefix:@"http://localhost"])
	{
		NSString *string = [self URLEncodedString];
		NSAttributedString *attributedString = [[[NSAttributedString alloc] initWithString:string] autorelease];
		NSRange range = {0, 0};
		NSURL *URL = [attributedString URLAtIndex:NSMaxRange(range) effectiveRange:&range];
		r = range.location == 0;
		if (r)
		{
#if 1
			*hasScheme = [[URL scheme] length] > 0 ? [string hasPrefix:[URL scheme]] : NO;
#else
			*hasScheme = [[URL absoluteString] isEqualToString:string];
#endif
		}
	}
	return r;
}

- (NSString *)stringByDeletingScheme
{
	NSString *string = self;
	NSInteger count = SBCountOfSchemes;
	NSInteger index = 0;
	for (index = 0; index < count; index++)
	{
		NSString *scheme = SBSchemes[index];
		if ([string hasPrefix:scheme])
		{
			string = [string substringFromIndex:[scheme length]];
			break;
		}
	}
	return string;
}

- (NSString *)URLEncodedString
{
	NSString *string = nil;
	NSURL *requestURL = nil;
	requestURL = [NSURL _web_URLWithUserTypedString:self];
	string = [requestURL absoluteString];
	return string;
}

- (NSString *)URLDencodedString
{
	NSString *string = nil;
	string = [[NSURL URLWithString:self] _web_userVisibleString];
	return string;
}

- (NSString *)requestURLString
{
	NSString *stringValue = self;
	BOOL hasScheme = NO;
	if ([stringValue isURLString:&hasScheme])
	{
		if (!hasScheme)
		{
			if ([stringValue hasPrefix:@"/"])
			{
				stringValue = [@"file://" stringByAppendingString:stringValue];
			}
			else {
				stringValue = [@"http://" stringByAppendingString:stringValue];
			}
		}
		stringValue = [stringValue URLEncodedString];
	}
	else {
		stringValue = [self searchURLString];
	}
	return stringValue;
}

- (NSString *)searchURLString
{
	NSString *stringValue = self;
	NSString *str = nil;
	NSURL *requestURL = nil;
	NSDictionary *info = nil;
	NSString *gSearchFormat = nil;
	
	info = [[NSBundle mainBundle] localizedInfoDictionary];
	gSearchFormat = info ? [info objectForKey:@"SBGSearchFormat"] : nil;
	if (gSearchFormat)
	{
		str = [NSString stringWithFormat:gSearchFormat, stringValue];
		requestURL = [NSURL _web_URLWithUserTypedString:str];
		stringValue = [requestURL absoluteString];
	}
	return stringValue;
}

@end
