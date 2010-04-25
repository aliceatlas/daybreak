/*
 
 NSArray-SBAdditions.m
 
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

#import "NSArray-SBAdditions.h"


@implementation NSArray (SBAdditions)

- (BOOL)containsIndexes:(NSIndexSet *)indexes
{
	BOOL r = YES;
	NSUInteger i = 0;
	for (i = [indexes lastIndex]; i != NSNotFound; i = [indexes indexLessThanIndex:i])
	{
		if (i >= [self count])
		{
			r = NO;
		}
	}
	return r;
}

- (NSIndexSet *)indexesOfObjects:(NSArray *)objects
{
	NSMutableIndexSet *indexes = nil;
	indexes = [NSMutableIndexSet indexSet];
	for (id object in objects)
	{
		NSUInteger index = [self indexOfObject:object];
		if (index != NSNotFound)
		{
			[indexes addIndex:index];
		}
	}
	return [[indexes copy] autorelease];
}

+ (NSArray *)arrayWithArrays:(NSArray *)arrays
{
	return [[[self mutableArrayWithArrays:arrays] copy] autorelease];
}

+ (NSMutableArray *)mutableArrayWithArrays:(NSArray *)arrays
{
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
	for (NSArray *a in arrays)
	{
		[array addObjectsFromArray:a];
	}
	return array;
}

@end
