/*
 
 SBMessageView.m
 
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

#import "SBMessageView.h"


@implementation SBMessageView

@dynamic message;
@dynamic text;

- (id)initWithFrame:(NSRect)frame text:(NSString *)inText
{
	if (self = [super initWithFrame:frame])
	{
		[self constructMessageLabel];
		[self constructTextLabel:inText];
		[self setAutoresizingMask:(NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin)];
	}
	return self;
}

- (void)dealloc
{
	[messageLabel release];
	[textLabel release];
	[doneButton release];
	[cancelButton release];
	[super dealloc];
}

#pragma mark Rects

- (NSPoint)margin
{
	return NSMakePoint(36.0, 32.0);
}

- (CGFloat)labelWidth
{
	return 85.0;
}

- (NSSize)buttonSize
{
	return NSMakeSize(105.0, 24.0);
}

- (CGFloat)buttonMargin
{
	return 15.0;
}

- (NSFont *)textFont
{
	return [NSFont systemFontOfSize:16];
}

- (NSRect)messageLabelRect
{
	NSRect r = NSZeroRect;
	NSPoint margin = [self margin];
	r.size.width = self.bounds.size.width - margin.x * 2;
	r.size.height = 36.0;
	r.origin.x = margin.x;
	r.origin.y = self.bounds.size.height - r.size.height - margin.y;
	return r;
}

- (NSRect)textLabelRect
{
	NSRect r = NSZeroRect;
	NSRect messageLabelRect = [self messageLabelRect];
	NSPoint margin = [self margin];
	r.size.width = self.bounds.size.width - margin.x * 2;
	r.size.height = self.bounds.size.height - margin.y * 2;
	r.origin.x = margin.x;
	r.origin.y = messageLabelRect.origin.y - r.size.height;
	return r;
}

- (NSRect)doneButtonRect
{
	NSRect r = NSZeroRect;
	NSPoint margin = [self margin];
	CGFloat buttonMargin = [self buttonMargin];
	r.size = [self buttonSize];
	r.origin.y = margin.y;
	r.origin.x = (self.bounds.size.width - (r.size.width * 2 + buttonMargin)) / 2 + r.size.width + buttonMargin;
	return r;
}

- (NSRect)cancelButtonRect
{
	NSRect r = NSZeroRect;
	NSPoint margin = [self margin];
	CGFloat buttonMargin = [self buttonMargin];
	r.size = [self buttonSize];
	r.origin.y = margin.y;
	r.origin.x = (self.bounds.size.width - (r.size.width * 2 + buttonMargin)) / 2;
	return r;
}

#pragma mark Construction

- (void)constructMessageLabel
{
	NSRect r = [self messageLabelRect];
	messageLabel = [[NSTextField alloc] initWithFrame:r];
	[messageLabel setAutoresizingMask:(NSViewMinXMargin | NSViewMinYMargin)];
	[messageLabel setEditable:NO];
	[messageLabel setBordered:NO];
	[messageLabel setDrawsBackground:NO];
	[messageLabel setTextColor:[NSColor whiteColor]];
	[[messageLabel cell] setFont:[NSFont boldSystemFontOfSize:16]];
	[[messageLabel cell] setAlignment:NSCenterTextAlignment];
	[[messageLabel cell] setWraps:YES];
	[textLabel setStringValue:@"JavaScript"];
	[self addSubview:messageLabel];
}

- (void)constructTextLabel:(NSString *)inText
{
	NSRect r = [self textLabelRect];
	NSFont *font = [self textFont];
	NSSize size = [inText sizeWithAttributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]];
	textLabel = [[NSTextField alloc] initWithFrame:r];
	[textLabel setEditable:NO];
	[textLabel setBordered:NO];
	[textLabel setDrawsBackground:NO];
	[textLabel setTextColor:[NSColor whiteColor]];
	[[textLabel cell] setFont:font];
	[[textLabel cell] setAlignment:size.width > (r.size.width - 20.0) ? NSLeftTextAlignment : NSCenterTextAlignment];
	[[textLabel cell] setWraps:YES];
	[textLabel setStringValue:inText];
	[self addSubview:textLabel];
}

- (void)constructDoneButton
{
	NSRect r = [self doneButtonRect];
	doneButton = [[SBBLKGUIButton alloc] initWithFrame:r];
	[doneButton setTitle:NSLocalizedString(@"OK", nil)];
	[doneButton setTarget:self];
	[doneButton setAction:@selector(done)];
	[doneButton setEnabled:YES];
	[doneButton setKeyEquivalent:@"\r"];	// busy if button is added into a view
	[self addSubview:doneButton];
}

- (void)constructCancelButton
{
	NSRect r = [self cancelButtonRect];
	cancelButton = [[SBBLKGUIButton alloc] initWithFrame:r];
	[cancelButton setTitle:NSLocalizedString(@"Cancel", nil)];
	[cancelButton setTarget:self];
	[cancelButton setAction:@selector(cancel)];
	[cancelButton setKeyEquivalent:@"\e"];
	[self addSubview:cancelButton];
}

#pragma mark Getter

- (NSString *)message
{
	return [messageLabel stringValue];
}

- (NSString *)text
{
	return [textLabel stringValue];
}

#pragma mark Setter

- (void)setMessage:(NSString *)message
{
	[messageLabel setStringValue:message];
}

- (void)setText:(NSString *)inText
{
	[textLabel setStringValue:inText];
}

- (void)setDoneSelector:(SEL)inDoneSelector
{
	if (doneSelector != inDoneSelector)
	{
		doneSelector = inDoneSelector;
		if (doneSelector && !doneButton)
		{
			[self constructDoneButton];
		}
	}
}

- (void)setCancelSelector:(SEL)inCancelSelector
{
	if (cancelSelector != inCancelSelector)
	{
		cancelSelector = inCancelSelector;
		if (cancelSelector && !cancelButton)
		{
			[self constructCancelButton];
		}
	}
}

@end
