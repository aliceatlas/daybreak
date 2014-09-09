/*

SBFindbar.m
 
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

#import "SBFindbar.h"
#import "SBUtil.h"

#import "Sunrise3-Bridging-Header.h"
#import "Sunrise3-Swift.h"

@implementation SBFindbar

@synthesize searchedString;
@synthesize contentView;

- (instancetype)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		[self constructContentView];
		[self constructCloseButton];
		[self constructSearchField];
		[self constructBackwardButton];
		[self constructForwardButton];
		[self constructCaseSensitiveCheck];
		[self constructWrapCheck];
		searchedString = nil;
	}
	return self;
}

- (void)dealloc
{
	[self destructContentView];
	[self destructCloseButton];
	[self destructSearchField];
	[self destructBackwardButton];
	[self destructForwardButton];
	[self destructCaseSensitiveCheck];
	[self destructWrapCheck];
}

+ (CGFloat)minimumWidth
{
	return 750;
}

+ (CGFloat)availableWidth
{
	return 300;
}

#pragma mark Rects

- (NSRect)contentRect
{
	NSRect r = self.bounds;
	r.size.width = r.size.width >= self.class.minimumWidth ? r.size.width : self.class.minimumWidth;
	return r;
}

- (NSRect)closeRect
{
	NSRect r = NSZeroRect;
	r.size.width = r.size.height = self.bounds.size.height;
	return r;
}

- (NSRect)searchRect
{
	NSRect r = NSZeroRect;
	NSRect closeRect = self.closeRect;
	NSRect caseSensitiveRect = self.caseSensitiveRect;
	CGFloat marginNextToCase = 150.0;
	r.size.width = caseSensitiveRect.origin.x - NSMaxX(closeRect) - marginNextToCase - 24.0 * 2;
	r.size.height = 19.0;
	r.origin.x = NSMaxX(closeRect);
	r.origin.y = (self.bounds.size.height - r.size.height) / 2;
	return r;
}

- (NSRect)backwardRect
{
	NSRect r = NSZeroRect;
	NSRect searchRect = self.searchRect;
	r.size.width = 24.0;
	r.size.height = 18.0;
	r.origin.y = (self.bounds.size.height - r.size.height) / 2;
	r.origin.x = NSMaxX(searchRect);
	return r;
}

- (NSRect)forwardRect
{
	NSRect r = NSZeroRect;
	NSRect backwardRect = self.backwardRect;
	r.size.width = 24.0;
	r.size.height = 18.0;
	r.origin.y = (self.bounds.size.height - r.size.height) / 2;
	r.origin.x = NSMaxX(backwardRect);
	return r;
}

- (NSRect)caseSensitiveRect
{
	NSRect r = NSZeroRect;
	NSRect wrapRect = self.wrapRect;
	r.size.width = 150.0;
	r.size.height = self.bounds.size.height;
	r.origin.x = wrapRect.origin.x - r.size.width;
	return r;
}

- (NSRect)wrapRect
{
	NSRect r = NSZeroRect;
	NSRect contentRect = self.contentRect;
	r.size.width = 150.0;
	r.size.height = self.bounds.size.height;
	r.origin.x = contentRect.size.width - r.size.width;
	return r;
}

#pragma mark Destruction

- (void)destructContentView
{
	if (contentView)
	{
		[contentView removeFromSuperview];
		contentView = nil;
	}
}

- (void)destructCloseButton
{
	if (closeButton)
	{
		[closeButton removeFromSuperview];
		closeButton = nil;
	}
}

- (void)destructSearchField
{
	if (searchField)
	{
		[searchField removeFromSuperview];
		searchField = nil;
	}
}

- (void)destructBackwardButton
{
	if (backwardButton)
	{
		[backwardButton removeFromSuperview];
		backwardButton = nil;
	}
}

- (void)destructForwardButton
{
	if (forwardButton)
	{
		[forwardButton removeFromSuperview];
		forwardButton = nil;
	}
}

- (void)destructCaseSensitiveCheck
{
	if (caseSensitiveCheck)
	{
		[caseSensitiveCheck removeFromSuperview];
		caseSensitiveCheck = nil;
	}
}

- (void)destructWrapCheck
{
	if (wrapCheck)
	{
		[wrapCheck removeFromSuperview];
		wrapCheck = nil;
	}
}

#pragma mark Construction

- (void)constructContentView
{
	NSRect r = self.contentRect;
	[self destructContentView];
	contentView = [[NSView alloc] initWithFrame:r];
	[self addSubview:contentView];
}

- (void)constructCloseButton
{
	NSRect r = self.closeRect;
	[self destructCloseButton];
	closeButton = [[SBButton alloc] initWithFrame:r];
    closeButton.autoresizingMask = NSViewMaxXMargin;
	closeButton.image = [NSImage imageWithCGImage:SBIconImage(SBCloseIconImage(), SBButtonExclusiveShape, NSSizeToCGSize(r.size))];
	closeButton.target = self;
	closeButton.action = @selector(executeClose);
	[contentView addSubview:closeButton];
}

- (void)constructSearchField
{
	NSRect r = self.searchRect;
	NSString *string = [[NSPasteboard pasteboardWithName:NSFindPboard] stringForType:NSStringPboardType];
	[self destructSearchField];
	searchField = [[SBFindSearchField alloc] initWithFrame:r];
    searchField.autoresizingMask = NSViewWidthSizable;
    searchField.delegate = self;
    searchField.target = self;
    searchField.action = @selector(search:);
    searchField.nextAction = @selector(searchForward:);
    searchField.previousAction = @selector(searchBackward:);
    [searchField.cell setSendsWholeSearchString:YES];
    [searchField.cell setSendsSearchStringImmediately:NO];
	if (string)
        searchField.stringValue = string;
	[contentView addSubview:searchField];
}

- (void)constructBackwardButton
{
	NSRect r = self.backwardRect;
	[self destructBackwardButton];
	backwardButton = [[SBButton alloc] initWithFrame:r];
    backwardButton.autoresizingMask = NSViewMinXMargin;
	backwardButton.image = [NSImage imageWithCGImage:SBFindBackwardIconImage(NSSizeToCGSize(r.size), YES)];
	backwardButton.disableImage = [NSImage imageWithCGImage:SBFindBackwardIconImage(NSSizeToCGSize(r.size), NO)];
	backwardButton.target = self;
	backwardButton.action = @selector(searchBackward:);
	[contentView addSubview:backwardButton];
	
}

- (void)constructForwardButton
{
	NSRect r = self.forwardRect;
	[self destructForwardButton];
	forwardButton = [[SBButton alloc] initWithFrame:r];
    forwardButton.autoresizingMask = NSViewMinXMargin;
	forwardButton.image = [NSImage imageWithCGImage:SBFindForwardIconImage(NSSizeToCGSize(r.size), YES)];
	forwardButton.disableImage = [NSImage imageWithCGImage:SBFindForwardIconImage(NSSizeToCGSize(r.size), NO)];
	forwardButton.target = self;
	forwardButton.action = @selector(searchForward:);
	forwardButton.keyEquivalent = @"g";
	[contentView addSubview:forwardButton];
}

- (void)constructCaseSensitiveCheck
{
	NSRect r = self.caseSensitiveRect;
	BOOL caseFlag = [[NSUserDefaults standardUserDefaults] boolForKey:kSBFindCaseFlag];
	[self destructCaseSensitiveCheck];
	caseSensitiveCheck = [[SBBLKGUIButton alloc] initWithFrame:r];
    caseSensitiveCheck.autoresizingMask = NSViewMinXMargin;
    caseSensitiveCheck.buttonType = NSSwitchButton;
    caseSensitiveCheck.font = [NSFont systemFontOfSize:10.0];
    caseSensitiveCheck.title = NSLocalizedString(@"Ignore Case", nil);
    caseSensitiveCheck.state = caseFlag ? NSOnState : NSOffState;
    caseSensitiveCheck.target = self;
    caseSensitiveCheck.action = @selector(checkCaseSensitive:);
	[contentView addSubview:caseSensitiveCheck];
}

- (void)constructWrapCheck
{
	NSRect r = self.wrapRect;
	BOOL wrapFlag = [[NSUserDefaults standardUserDefaults] boolForKey:kSBFindWrapFlag];
	[self destructWrapCheck];
	wrapCheck = [[SBBLKGUIButton alloc] initWithFrame:r];
    wrapCheck.autoresizingMask = NSViewMinXMargin;
    wrapCheck.buttonType = NSSwitchButton;
    wrapCheck.font = [NSFont systemFontOfSize:10.0];
    wrapCheck.title = NSLocalizedString(@"Wrap Around", nil);
    wrapCheck.state = wrapFlag ? NSOnState : NSOffState;
    wrapCheck.target = self;
    wrapCheck.action = @selector(checkWrap:);
	[contentView addSubview:wrapCheck];
}

#pragma mark Delegate

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	NSString *string = searchField.stringValue;
	if (string.length > 0)
	{
		[self searchContinuous:nil];
	}
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command
{
	BOOL r = NO;
	if (control == searchField)
	{
		if (command == @selector(cancelOperation:))
		{
			if (searchField.stringValue.length == 0)
			{
				[self executeClose];
				r = YES;
			}
		}
	}
	return r;
}

#pragma mark Setter

- (void)setFrame:(NSRect)frame
{
	if (contentView)
	{
        contentView.frame = self.contentRect;
	}
    super.frame = frame;
}

#pragma mark Actions

- (void)selectText:(id)sender
{
	[searchField selectText:nil];
}

- (void)searchContinuous:(id)sender
{
	[self executeSearch:YES continuous:YES];
}

- (void)search:(id)sender
{
	if (searchField.stringValue.length > 0)
	{
		[self executeSearch:YES continuous:NO];
		[self executeClose];
	}
}

- (void)searchBackward:(id)sender
{
	[self executeSearch:NO continuous:NO];
}

- (void)searchForward:(id)sender
{
	[self executeSearch:YES continuous:NO];
}

- (void)checkCaseSensitive:(id)sender
{
	BOOL caseFlag = caseSensitiveCheck.state == NSOnState;
	[[NSUserDefaults standardUserDefaults] setBool:caseFlag forKey:kSBFindCaseFlag];
}

- (void)checkWrap:(id)sender
{
	BOOL wrapFlag = wrapCheck.state == NSOnState;
	[[NSUserDefaults standardUserDefaults] setBool:wrapFlag forKey:kSBFindWrapFlag];
}

- (void)executeClose
{
	if (target && doneSelector)
	{
		if ([target respondsToSelector:doneSelector])
		{
			[target performSelector:doneSelector withObject:self];
		}
	}
}

- (BOOL)executeSearch:(BOOL)forward continuous:(BOOL)continuous
{
	BOOL r = NO;
	NSString *string = searchField.stringValue;
	NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSFindPboard];
	[pasteboard declareTypes:@[NSStringPboardType] owner:self];
	[pasteboard setString:string forType:NSStringPboardType];
	if (target)
	{
		BOOL caseFlag = caseSensitiveCheck.state == NSOnState;
		BOOL wrap = wrapCheck.state == NSOnState;
		if ([target respondsToSelector:@selector(searchFor:direction:caseSensitive:wrap:continuous:)])
		{
			r = [target searchFor:string direction:forward caseSensitive:caseFlag wrap:wrap continuous:continuous];
		}
	}
	self.searchedString = string;
	return r;
}

#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	NSRect bounds = self.bounds;
	CGContextRef ctx = NSGraphicsContext.currentContext.graphicsPort;
	NSUInteger count = 2;
	CGFloat locations[count];
	CGFloat colors[count * 4];
	CGPoint points[count];
	CGFloat lh = 1.0;
	
	// Background
	locations[0] = 0.0;
	locations[1] = 1.0;
	colors[0] = colors[1] = colors[2] = 0.0;
	colors[3] = 1.0;
	colors[4] = colors[5] = colors[6] = 0.5;
	colors[7] = 1.0;
	points[0] = CGPointZero;
	points[1] = CGPointMake(0.0, bounds.size.height);
	SBDrawGradientInContext(ctx, count, locations, colors, points);
	
	// Lines
	[[NSColor colorWithCalibratedWhite:0.0 alpha:1.0] set];
	NSRectFill(NSMakeRect(bounds.origin.x, NSMaxY(bounds) - lh, bounds.size.width, lh));
	[[NSColor colorWithCalibratedWhite:0.0 alpha:1.0] set];
	NSRectFill(NSMakeRect(bounds.origin.x, bounds.origin.y, bounds.size.width, lh));
}

@end

@implementation SBFindSearchField

- (void)performFindNext:(id)sender
{
    id target = self.target;
	if (target && nextAction)
	{
		if ([target respondsToSelector:nextAction])
		{
			[target performSelector:nextAction withObject:self];
		}
	}
}

- (void)performFindPrevious:(id)sender
{
    id target = self.target;
	if (target && previousAction)
	{
		if ([target respondsToSelector:previousAction])
		{
			[target performSelector:previousAction withObject:self];
		}
	}
}

- (void)setNextAction:(SEL)inNextAction
{
	if (nextAction != inNextAction)
	{
		nextAction = inNextAction;
	}
}

- (void)setPreviousAction:(SEL)inPreviousAction
{
	if (previousAction != inPreviousAction)
	{
		previousAction = inPreviousAction;
	}
}

@end

