/*

SBSourceTextView.m
 
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

#import "SBSourceTextView.h"
#import "SBFindbar.h"

@implementation SBSourceTextView

@synthesize delegate, showFindbar;

- (id)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		showFindbar = NO;
	}
	return self;
}

- (void)dealloc
{
	delegate = nil;
	[super dealloc];
}

- (void)performFind:(id)sender
{
	if (self.bounds.size.width >= [SBFindbar availableWidth])
	{
		[self executeOpenFindbar];
	}
	else {
		NSBeep();
	}
}

- (void)performFindNext:(id)sender
{
	NSString *string = [[NSPasteboard pasteboardWithName:NSFindPboard] stringForType:NSStringPboardType];
	if ([string length] > 0)
	{
		BOOL caseFlag = [[NSUserDefaults standardUserDefaults] boolForKey:kSBFindCaseFlag];
		BOOL wrapFlag = [[NSUserDefaults standardUserDefaults] boolForKey:kSBFindWrapFlag];
		[self searchFor:string direction:YES caseSensitive:caseFlag wrap:wrapFlag continuous:NO];
	}
	else {
		[self performFind:sender];
	}
}

- (void)performFindPrevious:(id)sender
{
	NSString *string = [[NSPasteboard pasteboardWithName:NSFindPboard] stringForType:NSStringPboardType];
	if ([string length] > 0)
	{
		BOOL caseFlag = [[NSUserDefaults standardUserDefaults] boolForKey:kSBFindCaseFlag];
		BOOL wrapFlag = [[NSUserDefaults standardUserDefaults] boolForKey:kSBFindWrapFlag];
		[self searchFor:string direction:NO caseSensitive:caseFlag wrap:wrapFlag continuous:NO];
	}
	else {
		[self performFind:sender];
	}
}

- (BOOL)searchFor:(NSString *)searchString direction:(BOOL)forward caseSensitive:(BOOL)caseFlag wrap:(BOOL)wrapFlag continuous:(BOOL)continuous
{
	BOOL r = NO;
	NSString *string = [self string];
	NSRange range = {NSNotFound, 0};
	NSRange selectedRange = [self selectedRange];
	NSRange allRange = {0, [string length]};
	NSRange searchRange = {NSNotFound, 0};
	NSStringCompareOptions options = 0;
	NSUInteger invalidLength = 0;
	selectedRange = selectedRange.location == NSNotFound ? NSMakeRange(0, 0) : selectedRange;
	invalidLength = continuous ? selectedRange.location : (selectedRange.location + selectedRange.length);
	options = (forward ? 0 : NSBackwardsSearch) | (caseFlag ? NSCaseInsensitiveSearch : 0);
	if (forward)
	{
		searchRange = NSMakeRange(invalidLength, allRange.length - invalidLength);
	}
	else {
		searchRange = NSMakeRange(0, selectedRange.location);
	}
	range = [string rangeOfString:searchString options:options range:searchRange];
	if (range.location != NSNotFound)
	{
		[self selectRange:range];
		r = YES;
	}
	else {
		if (wrapFlag)
		{
			if (forward)
			{
				searchRange = NSMakeRange(0, selectedRange.location);
			}
			else {
				searchRange = NSMakeRange(invalidLength, allRange.length - invalidLength);
			}
			range = [string rangeOfString:searchString options:options range:searchRange];
			if (range.location != NSNotFound)
			{
				[self selectRange:range];
				r = YES;
			}
		}
	}
	if (!r)
	{
		NSBeep();
	}
	return r;
}

- (void)selectRange:(NSRange)range
{
	[self setSelectedRange:range];
	[self scrollRangeToVisible:range];
	[self showFindIndicatorForRange:range];
}

- (void)executeOpenFindbar
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(textViewShouldOpenFindbar:)])
		{
			[delegate textViewShouldOpenFindbar:self];
			showFindbar = YES;
		}
	}
}

- (void)executeCloseFindbar
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(textViewShouldCloseFindbar:)])
		{
			[delegate textViewShouldCloseFindbar:self];
			showFindbar = NO;
		}
	}
}

@end
