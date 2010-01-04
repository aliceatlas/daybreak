/*

SBCoverWindow.m
 
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

#import "SBCoverWindow.h"


@implementation SBCoverWindow

- (id)initWithParentWindow:(NSWindow *)parentWindow size:(NSSize)size
{
	NSRect frame = [parentWindow frame];
	NSUInteger styleMask = (NSBorderlessWindowMask);
	frame.size = size;
	if (self = [super initWithContentRect:frame styleMask:styleMask backing:NSBackingStoreBuffered defer:YES])
	{
		[self setMinSize:size];
		[self setReleasedWhenClosed:YES];
		[self setShowsToolbarButton:NO];
		[self setOneShot:NO];
		[self setAcceptsMouseMovedEvents:NO];
		[self setOpaque:NO];
		[self setBackgroundColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.8]];
		[self setHasShadow:NO];
	}
	return self;
}

- (NSTimeInterval)animationResizeTime:(NSRect)newWindowFrame
{
	return 0;
}

- (BOOL)canBecomeKeyWindow
{
	return YES;
}

@end
