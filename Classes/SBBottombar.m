/*

SBBottombar.m
 
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

#import "SBBottombar.h"
#import "SBUtil.h"

@implementation SBBottombar

#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	NSRect bounds = self.bounds;
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
	NSUInteger count = 2;
	CGFloat locations[count];
	CGPoint points[count];
	CGFloat lh = 1.0;
	
	// Background
	locations[0] = 0.0;
	locations[1] = 1.0;
	points[0] = CGPointZero;
	points[1] = CGPointMake(0.0, bounds.size.height);
	SBDrawGradientInContext(ctx, count, locations, SBBottombarColors, points);
	
	// Lines
	[[NSColor colorWithCalibratedWhite:1.0 alpha:0.45] set];
	NSRectFill(NSMakeRect(bounds.origin.x, NSMaxY(bounds) - lh, bounds.size.width, lh));
	[[NSColor colorWithCalibratedWhite:1.0 alpha:0.3] set];
	NSRectFill(NSMakeRect(bounds.origin.x, 0.0, bounds.size.width, lh));
}

@end
