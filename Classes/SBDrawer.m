/*

SBDrawer.m
 
Authoring by Atsushi Jike

Copyright 2009 Atsushi Jike. All rights reserved.

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

#import "SBDrawer.h"
#import "SBDownloadsView.h"


@implementation SBDrawer

@synthesize view;

- (NSRect)availableRect
{
	NSRect r = self.bounds;
	if (self.subview)
	{
		NSRect sr = self.subview.frame;
		r.size.height -= NSMaxY(sr);
		r.origin.y = NSMaxY(sr);
	}
	return r;
}

- (void)dealloc
{
	[view release];
	[super dealloc];
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldBoundsSize
{
	if (view)
	{
		if ([view respondsToSelector:@selector(layout:)])
		{
			[(id)view layout:NO];
		}
	}
	[super resizeSubviewsWithOldSize:oldBoundsSize];
}

#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	CGFloat lh = 1.0;
	[[NSColor colorWithCalibratedWhite:keyView ? 0.35 : 0.75 alpha:1.0] set];
	NSRectFill(rect);
	[[NSColor colorWithCalibratedWhite:0.45 alpha:1.0] set];
	NSRectFill(NSMakeRect(rect.origin.x, NSMaxY(rect) - lh, rect.size.width, lh));
}

@end
