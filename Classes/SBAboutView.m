/*

SBAboutView.m
 
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

#import "SBAboutView.h"
#import "SBUtil.h"

static SBAboutView *_sharedView;

@implementation SBAboutView

+ (id)sharedView
{
	if (!_sharedView)
	{
		_sharedView = [[self alloc] initWithFrame:NSMakeRect(0, 0, 640, 360)];
	}
	return _sharedView;
}

- (id)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		animationDuration = 2.0;
		[self constructNameLabel];
		[self constructIdentifierLabel];
		[self constructCreditLabel];
		[self constructCopyrightLabel];
		[self constructBackButton];
		[self setAutoresizingMask:(NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin)];
	}
	return self;
}

- (void)dealloc
{
	[iconImageView release];
	[nameLabel release];
	[identifierLabel release];
	[creditScrollView release];
	[copyrightLabel release];
	[backButton release];
	[super dealloc];
}

#pragma mark Rects

- (NSRect)iconImageRect
{
	NSRect r = NSZeroRect;
	r.size.width = r.size.height = self.bounds.size.height / 1.5;
	r.origin.x = 32.0;
	r.origin.y = (self.bounds.size.height - r.size.height);
	return r;
}

- (NSRect)nameLabelRect
{
	NSRect r = NSZeroRect;
	NSRect iconRect = [self iconImageRect];
	r.size.width = 240.0;
	r.size.height = 24.0;
	r.origin.x = NSMaxX(iconRect) + iconRect.origin.x;
	r.origin.y = NSMaxY(iconRect) - r.size.height;
	return r;
}

- (NSRect)identifierLabelRect
{
	NSRect r = NSZeroRect;
	NSRect nameRect = [self nameLabelRect];
	r.origin.x = nameRect.origin.x;
	r.size.width = self.bounds.size.width - r.origin.x;
	r.size.height = 16.0;
	r.origin.y = nameRect.origin.y - r.size.height;
	return r;
}

- (NSRect)creditLabelRect
{
	NSRect r = NSZeroRect;
	NSRect identifierLabelRect = [self identifierLabelRect];
	NSRect copyrightLabelRect = [self copyrightLabelRect];
	r.origin.x = identifierLabelRect.origin.x;
	r.size.width = self.bounds.size.width - r.origin.x;
	r.origin.y = NSMaxY(copyrightLabelRect) + 10.0;
	r.size.height = identifierLabelRect.origin.y - (r.origin.y + 10.0);
	return r;
}

- (NSRect)copyrightLabelRect
{
	NSRect r = NSZeroRect;
	NSRect iconRect = [self iconImageRect];
	r.origin.x = NSMaxX(iconRect) + iconRect.origin.x;
	r.size.width = self.bounds.size.width - r.origin.x;
	r.size.height = 16.0;
	r.origin.y = 64.0;
	return r;
}

- (NSRect)backButtonRect
{
	NSRect r = NSZeroRect;
	r.size.width = 105.0;
	r.size.height = 24.0;
	r.origin.x = self.bounds.size.width - r.size.width;
	return r;
}

#pragma mark Construction

- (void)constructIconImageView
{
	NSRect r = [self iconImageRect];
	NSImage *image = [NSImage imageNamed:@"Application.icns"];
	if (image)
	{
		iconImageView = [[NSImageView alloc] initWithFrame:r];
		[iconImageView setImageFrameStyle:NSImageFrameNone];
		[iconImageView setAutoresizingMask:(NSViewMinXMargin | NSViewMinYMargin | NSViewMaxYMargin)];
		[image setSize:r.size];
		[iconImageView setImage:image];
		[iconImageView setImageScaling:NSImageScaleProportionallyDown];
		[self addSubview:iconImageView];
	}
}

- (void)constructNameLabel
{
	NSRect r = [self nameLabelRect];
	NSBundle *bundle = [NSBundle mainBundle];
	NSDictionary *info = [bundle infoDictionary];
	NSDictionary *localizedInfo = [bundle localizedInfoDictionary];
	NSString *name = localizedInfo ? [localizedInfo objectForKey:@"CFBundleName"] : nil;
	NSString *version = info ? [info objectForKey:@"CFBundleVersion"] : nil;
	NSString *string = name ? (version ? [NSString stringWithFormat:@"%@ %@", name, version] : name) : nil;
	if (string)
	{
		nameLabel = [[NSTextField alloc] initWithFrame:r];
		[nameLabel setAutoresizingMask:(NSViewMinXMargin | NSViewMinYMargin)];
		[nameLabel setEditable:NO];
		[nameLabel setBordered:NO];
		[nameLabel setDrawsBackground:NO];
		[nameLabel setTextColor:[NSColor whiteColor]];
		[[nameLabel cell] setFont:[NSFont boldSystemFontOfSize:20]];
		[[nameLabel cell] setAlignment:NSLeftTextAlignment];
		[nameLabel setStringValue:string];
		[self addSubview:nameLabel];
	}
}

- (void)constructIdentifierLabel
{
	NSRect r = [self identifierLabelRect];
	NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
	NSString *string = info ? [info objectForKey:@"CFBundleIdentifier"] : nil;
	if (string)
	{
		identifierLabel = [[NSTextField alloc] initWithFrame:r];
		[identifierLabel setAutoresizingMask:(NSViewMinXMargin | NSViewMinYMargin)];
		[identifierLabel setEditable:NO];
		[identifierLabel setBordered:NO];
		[identifierLabel setDrawsBackground:NO];
		[identifierLabel setTextColor:[NSColor colorWithCalibratedWhite:0.8 alpha:1.0]];
		[[identifierLabel cell] setFont:[NSFont systemFontOfSize:12.0]];
		[[identifierLabel cell] setAlignment:NSLeftTextAlignment];
		[identifierLabel setStringValue:string];
		[self addSubview:identifierLabel];
	}
}

- (void)constructCreditLabel
{
	NSRect r = [self creditLabelRect];
	NSString *rtfdPath = [[NSBundle mainBundle] pathForResource:@"Credits" ofType:@"rtfd"];
	NSTextView *creditLabel = nil;
	creditScrollView = [[SBBLKGUIScrollView alloc] initWithFrame:r];
	[creditScrollView setAutohidesScrollers:YES];
	[creditScrollView setHasHorizontalScroller:NO];
	[creditScrollView setHasVerticalScroller:YES];
	[creditScrollView setBackgroundColor:[NSColor colorWithCalibratedRed:SBWindowBackColors[0] green:SBWindowBackColors[1] blue:SBWindowBackColors[2] alpha:SBWindowBackColors[3]]];
	[creditScrollView setDrawsBackground:NO];
	creditLabel = [[[NSTextView alloc] initWithFrame:r] autorelease];
	[creditLabel setAutoresizingMask:(NSViewMinXMargin | NSViewMinYMargin)];
	[creditLabel setEditable:NO];
	[creditLabel setSelectable:YES];
	[creditLabel setDrawsBackground:NO];
	[creditLabel readRTFDFromFile:rtfdPath];
	[creditScrollView setDocumentView:creditLabel];
	[self addSubview:creditScrollView];
}

- (void)constructCopyrightLabel
{
	NSRect r = [self copyrightLabelRect];
	NSDictionary *info = [[NSBundle mainBundle] localizedInfoDictionary];
	NSString *string = info ? [info objectForKey:@"NSHumanReadableCopyright"] : nil;
	if (string)
	{
		copyrightLabel = [[NSTextField alloc] initWithFrame:r];
		[copyrightLabel setAutoresizingMask:(NSViewMinXMargin | NSViewMinYMargin)];
		[copyrightLabel setEditable:NO];
		[copyrightLabel setBordered:NO];
		[copyrightLabel setDrawsBackground:NO];
		[copyrightLabel setTextColor:[NSColor grayColor]];
		[[copyrightLabel cell] setFont:[NSFont systemFontOfSize:12.0]];
		[[copyrightLabel cell] setAlignment:NSLeftTextAlignment];
		[copyrightLabel setStringValue:string];
		[self addSubview:copyrightLabel];
	}
}

- (void)constructBackButton
{
	NSRect r = [self backButtonRect];
	backButton = [[SBBLKGUIButton alloc] initWithFrame:r];
	[backButton setTitle:NSLocalizedString(@"Back", nil)];
	[backButton setTarget:self];
	[backButton setAction:@selector(cancel)];
	[backButton setKeyEquivalent:@"\e"];
	[self addSubview:backButton];
}

#pragma mark Responder

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent
{
	unichar character;
	
	character = [[theEvent characters] characterAtIndex:0];
	if (character == NSDeleteCharacter || character == NSCarriageReturnCharacter || character == NSEnterCharacter)
	{
		[self cancel];
	}
	return [super performKeyEquivalent:theEvent];
}


#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	NSImage *image = [NSImage imageNamed:@"Application.icns"];
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
	[[NSColor colorWithCalibratedRed:SBWindowBackColors[0] green:SBWindowBackColors[1] blue:SBWindowBackColors[2] alpha:SBWindowBackColors[3]] set];
	NSRectFillUsingOperation(rect, NSCompositeSourceOver);
	
	if (image)
	{
		CGRect imageRect = NSRectToCGRect([self iconImageRect]);
		CGImageRef maskImage = nil;
		
		[image setSize:NSSizeFromCGSize(imageRect.size)];
		[image drawInRect:NSRectFromCGRect(imageRect) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
		
		imageRect.origin.y = imageRect.size.height * 1.5 - self.bounds.size.height;
		imageRect.size.height *= 0.5;
		maskImage = SBBookmarkReflectionMaskImage(imageRect.size);
		CGContextTranslateCTM(ctx, 0.0, imageRect.size.height);
		CGContextScaleCTM(ctx, 1.0, -1.0);
		CGContextClipToMask(ctx, imageRect, maskImage);
		[image drawInRect:NSRectFromCGRect(imageRect) fromRect:NSMakeRect(0, 0, imageRect.size.width, imageRect.size.height) operation:NSCompositeSourceOver fraction:1.0];
	}
}

@end
