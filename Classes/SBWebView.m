/*

SBWebView.m
 
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

#import "SBWebView.h"
#import "SBFindbar.h"

@implementation SBWebView

@synthesize delegate, showFindbar, textEncodingName;

- (id)initWithFrame:(NSRect)frameRect frameName:(NSString *)frameName groupName:(NSString *)groupName
{
	if (self = [super initWithFrame:frameRect frameName:frameName groupName:groupName])
	{
		showFindbar = NO;
		textEncodingName = nil;
	}
	return self;
}

- (void)dealloc
{
	delegate = nil;
	[super dealloc];
}

- (NSString *)textEncodingName
{
	return textEncodingName ? textEncodingName : [[self preferences] defaultTextEncodingName];
}

#pragma mark Menu Actions

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
	if (continuous)
	{
		NSRange range = {NSNotFound , 0};
		range = [self rageOfStringInWebDocument:searchString caseSensitive:caseFlag];	// Flip case flag
		r = range.location != NSNotFound;
	}
	else {
		r = [self searchFor:searchString direction:forward caseSensitive:!caseFlag wrap:wrapFlag];
	}
	if ([self respondsToSelector:@selector(unmarkAllTextMatches)])
	{
		[self unmarkAllTextMatches];
	}
	if (r)
	{
		if ([self respondsToSelector:@selector(markAllMatchesForText:caseSensitive:highlight:limit:)])
		{
			[self markAllMatchesForText:searchString caseSensitive:!caseFlag highlight:YES limit:0];
		}
	}
	else {
		NSBeep();
	}
	return r;
}

- (void)executeOpenFindbar
{
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(webViewShouldOpenFindbar:)])
		{
			[delegate webViewShouldOpenFindbar:self];
			showFindbar = YES;
		}
	}
}

- (BOOL)executeCloseFindbar
{
	BOOL r = NO;
	if (delegate)
	{
		if ([delegate respondsToSelector:@selector(webViewShouldCloseFindbar:)])
		{
			r = [delegate webViewShouldCloseFindbar:self];
			showFindbar = NO;
		}
	}
	return r;
}

- (NSString *)documentString
{
	return [(id <WebDocumentText>)[[[self mainFrame] frameView] documentView] string];
}

- (BOOL)isEmpty
{
	NSString *URLString = nil;
	URLString = [[[[[self mainFrame] dataSource] request] URL] absoluteString];
	return (URLString == nil || [URLString isEqual:@""] || [URLString isEqual:[NSString string]]);
}

// Return range of string in web document
- (NSRange)rageOfStringInWebDocument:(NSString *)string caseSensitive:(BOOL)caseFlag
{
	NSRange range = {NSNotFound, 0};
	if ([[self documentString] length] > 0)
	{
		range = [[self documentString] rangeOfString:string options:(caseFlag ? NSCaseInsensitiveSearch : 0)];
	}
	
	return range;
}

- (void)keyDown:(NSEvent *)theEvent
{
	unichar charactor = [[theEvent characters] characterAtIndex:0];
	if (charactor == '\e')
	{
		if (![self executeCloseFindbar])
		{
			[super keyDown:theEvent];
		}
	}
	else {
		[super keyDown:theEvent];
	}
}

#pragma mark Gesture(10.6only)

- (void)beginGestureWithEvent:(NSEvent *)event
{
	_magnified = NO;
}

- (void)endGestureWithEvent:(NSEvent *)event
{
	_magnified = YES;
}

- (void)magnifyWithEvent:(NSEvent *)event
{
	if (!_magnified)
	{
		CGFloat magnification = [event magnification];
		if (magnification > 0)
		{
			[self zoomPageIn:nil];
			_magnified = YES;
		}
		else if (magnification < 0)
		{
			[self zoomPageOut:nil];
			_magnified = YES;
		}
	}
}

- (void)swipeWithEvent:(NSEvent *)event
{
	CGFloat deltaX = [event deltaX];
	if (deltaX > 0)			// Left
	{
		if ([self canGoBack])
		{
			if ([self isLoading])
				[self stopLoading:nil];
			[self goBack:nil];
		}
		else {
			NSBeep();
		}
	}
	else if (deltaX < 0)	// Right
	{
		if ([self canGoForward])
		{
			if ([self isLoading])
				[self stopLoading:nil];
			[self goForward:nil];
		}
		else {
			NSBeep();
		}
	}
}

#pragma mark Private API

- (id)inspector
{
	return [super respondsToSelector:@selector(inspector)] ? [super inspector] : nil;
}

- (void)showWebInspector:(id)sender
{
	id inspector = [self inspector];
	if (inspector)
	{
		if ([inspector respondsToSelector:@selector(show:)])
			[inspector show:nil];
	}
}

- (void)showConsole:(id)sender
{
	id inspector = [self inspector];
	if (inspector)
	{
		if ([inspector respondsToSelector:@selector(show:)])
			[inspector show:nil];
		if ([inspector respondsToSelector:@selector(showConsole:)])
			[inspector performSelector:@selector(showConsole:) withObject:nil afterDelay:0.25];
	}
}

@end
