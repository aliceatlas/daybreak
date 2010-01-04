/*

SBDownloaderView.m
 
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

#import "SBDownloaderView.h"


@implementation SBDownloaderView

@dynamic message;
@dynamic urlString;

- (id)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		[self constructMessageLabel];
		[self constructURLLabel];
		[self constructURLField];
		[self constructDoneButton];
		[self constructCancelButton];
		[self makeResponderChain];
		[self setAutoresizingMask:(NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin)];
	}
	return self;
}

- (void)dealloc
{
	[messageLabel release];
	[urlLabel release];
	[urlField release];
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

- (NSRect)urlLabelRect
{
	NSRect r = NSZeroRect;
	NSPoint margin = [self margin];
	NSRect messageLabelRect = [self messageLabelRect];
	r.origin.x = margin.x;
	r.size.width = [self labelWidth];
	r.size.height = 24.0;
	r.origin.y = messageLabelRect.origin.y - margin.y - r.size.height;
	return r;
}

- (NSRect)urlFieldRect
{
	NSRect r = NSZeroRect;
	NSPoint margin = [self margin];
	NSRect urlLabelRect = [self urlLabelRect];
	r.origin.x = NSMaxX(urlLabelRect) + 10.0;
	r.origin.y = urlLabelRect.origin.y;
	r.size.width = self.bounds.size.width - r.origin.x - margin.x;
	r.size.height = 24.0;
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

#pragma mark Delegate

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	[doneButton setEnabled:([self.urlString length] > 0)];
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
	[self addSubview:messageLabel];
}

- (void)constructURLLabel
{
	NSRect r = [self urlLabelRect];
	urlLabel = [[NSTextField alloc] initWithFrame:r];
	[urlLabel setAutoresizingMask:(NSViewMinXMargin | NSViewMinYMargin)];
	[urlLabel setEditable:NO];
	[urlLabel setBordered:NO];
	[urlLabel setDrawsBackground:NO];
	[urlLabel setTextColor:[NSColor lightGrayColor]];
	[[urlLabel cell] setFont:[NSFont systemFontOfSize:12]];
	[[urlLabel cell] setAlignment:NSRightTextAlignment];
	[urlLabel setStringValue:[NSString stringWithFormat:@"%@ :", NSLocalizedString(@"URL", nil)]];
	[self addSubview:urlLabel];
}

- (void)constructURLField
{
	NSRect r = [self urlFieldRect];
	urlField = [[SBBLKGUITextField alloc] initWithFrame:r];
	[urlField setDelegate:self];
	[urlField setAutoresizingMask:(NSViewMinXMargin | NSViewMinYMargin)];
	[[urlField cell] setAlignment:NSLeftTextAlignment];
	[self addSubview:urlField];
}

- (void)constructDoneButton
{
	NSRect r = [self doneButtonRect];
	doneButton = [[SBBLKGUIButton alloc] initWithFrame:r];
	[doneButton setTitle:NSLocalizedString(@"Done", nil)];
	[doneButton setTarget:self];
	[doneButton setAction:@selector(done)];
	[doneButton setEnabled:NO];
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

- (void)makeResponderChain
{
	if (cancelButton)
		[urlField setNextKeyView:cancelButton];
	if (doneButton)
		[cancelButton setNextKeyView:doneButton];
	if (urlField)
		[doneButton setNextKeyView:urlField];
}

#pragma mark Getter

- (NSString *)message
{
	return [messageLabel stringValue];
}

- (NSString *)urlString
{
	return [urlField stringValue];
}

#pragma mark Setter

- (void)setMessage:(NSString *)message
{
	[messageLabel setStringValue:message];
}

- (void)setUrlString:(NSString *)urlString
{
	[urlField setStringValue:urlString];
}

#pragma mark  Actions

- (void)makeFirstResponderToURLField
{
	[[self window] makeFirstResponder:urlField];
}

@end
