/*

SBFixedSplitView.m
 
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

#import "SBFixedSplitView.h"

@implementation SBFixedSplitView

+ (SBFixedSplitView *)splitViewWithEmbedViews:(NSArray *)views frameRect:(NSRect)frameRect
{
	SBFixedSplitView *splitView = nil;
	NSView *view1 = [views count] > 0 ? [views objectAtIndex:0] : nil;
	NSView *view2 = [views count] > 1 ? [views objectAtIndex:1] : nil;
	NSView *superview = [view1 superview] ? [view1 superview] : ([view2 superview] ? [view2 superview] : nil);
	if (superview)
	{
		splitView = [[[SBFixedSplitView alloc] initWithFrame:frameRect] autorelease];
		[superview addSubview:splitView];
		[view1 removeFromSuperview];
		[view2 removeFromSuperview];
		[splitView addSubview:view1];
		[splitView addSubview:view2];
	}
	return splitView;
}

- (CGFloat)dividerThickness
{
	return 0;
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize
{
	if (![self isVertical])
	{
		NSArray *subviews = [self subviews];
		NSView *subview1 = [subviews count] > 0 ? [subviews objectAtIndex:0] : nil;
		NSView *subview2 = [subviews count] > 1 ? [subviews objectAtIndex:1] : nil;
		if (subview1 && subview2)
		{
			NSRect r1 = [subview1 frame];
			NSRect r2 = [subview2 frame];
			r1.size.width = self.bounds.size.width;
			r2.size.width = self.bounds.size.width;
			r2.size.height = self.bounds.size.height - r1.size.height;
			r2.origin.y = r1.size.height;
			[subview1 setFrame:r1];
			[subview2 setFrame:r2];
		}
	}else {
		[super resizeSubviewsWithOldSize:oldSize];
	}
}

@end
