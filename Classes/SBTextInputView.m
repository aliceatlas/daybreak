//
//  SBTextInputView.m
//  Sunrise
//
//  Created by Atsushi Jike on 09/11/28.
//  Copyright 2010 Atsushi Jike. All rights reserved.
//

#import "SBTextInputView.h"


@implementation SBTextInputView

@dynamic message;
@dynamic text;

- (id)initWithFrame:(NSRect)frame prompt:(NSString *)prompt
{
	if (self = [super initWithFrame:frame])
	{
		[self constructMessageLabel:prompt];
		[self constructTextLabel];
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
	NSSize ButtonSize = [self buttonSize];
	r.size.width = self.bounds.size.width - margin.x * 2;
	r.size.height = (self.bounds.size.height - messageLabelRect.size.height - ButtonSize.height) - margin.y * 4;
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

- (void)constructMessageLabel:(NSString *)inMessage
{
	NSRect r = [self messageLabelRect];
	NSFont *font = [NSFont boldSystemFontOfSize:16];
	NSSize size = [inMessage sizeWithAttributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]];
	messageLabel = [[NSTextField alloc] initWithFrame:r];
	[messageLabel setAutoresizingMask:(NSViewMinXMargin | NSViewMinYMargin)];
	[messageLabel setEditable:NO];
	[messageLabel setBordered:NO];
	[messageLabel setDrawsBackground:NO];
	[messageLabel setTextColor:[NSColor whiteColor]];
	[[messageLabel cell] setFont:font];
	[[textLabel cell] setAlignment:size.width > (r.size.width - 20.0) ? NSLeftTextAlignment : NSCenterTextAlignment];
	[[messageLabel cell] setWraps:YES];
	[messageLabel setStringValue:inMessage];
	[self addSubview:messageLabel];
}

- (void)constructTextLabel
{
	NSRect r = [self textLabelRect];
	textLabel = [[SBBLKGUITextField alloc] initWithFrame:r];
	[textLabel setAlignment:NSLeftTextAlignment];
	[textLabel setFont:[NSFont systemFontOfSize:14.0]];
	[textLabel setTextColor:[NSColor whiteColor]];
	[textLabel setDelegate:self];
	[[textLabel cell] setWraps:YES];
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

#pragma mark Delegate

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	BOOL canDone = NO;
	canDone = [[textLabel stringValue] length] > 0;
	[doneButton setEnabled:canDone];
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
