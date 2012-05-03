/*

SBSavePanel.m
 
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

#import "SBSavePanel.h"
#import "SBUtil.h"


@implementation SBSavePanel

+ (id)savePanel
{
	id panel = [super savePanel];
	[panel setOpaque:NO];
	[panel setBackgroundColor:[NSColor clearColor]];
	[panel setShowsResizeIndicator:NO];
	[panel constructBackgroundView];
	[panel switchButtonType];
	return panel;
}

- (void)constructBackgroundView
{
	NSView *contentView = self.contentView;
	NSArray *subviews = [contentView subviews];
	if ([subviews count] > 0)
	{
		id belowView = [subviews objectAtIndex:0];
		SBSavePanelContentView *savePanelContentView = nil;
		savePanelContentView = [[[SBSavePanelContentView alloc] initWithFrame:contentView.frame] autorelease];
		[savePanelContentView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
		[contentView addSubview:savePanelContentView positioned:NSWindowBelow relativeTo:belowView];
	}
}

- (void)switchButtonType
{
	NSArray *subviews = [[self contentView] subviews];
	[self switchButtonTypeInSubViews:subviews];
}

- (void)switchButtonTypeInSubViews:(NSArray *)subviews
{
	for (id subview in subviews)
	{
		if ([subview isKindOfClass:[NSButton class]])
		{
			if ([(NSButton *)subview bezelStyle] == NSRoundedBezelStyle)
			{
				[(NSButton *)subview setBezelStyle:NSTexturedRoundedBezelStyle];
			}
		}
		else {
			if ([subview respondsToSelector:@selector(subviews)])
			{
				NSArray *views = [subview subviews];
				[self switchButtonTypeInSubViews:views];
			}
		}
	}
}

@end

@implementation SBOpenPanel

+ (id)openPanel
{
	id panel = [super openPanel];
	[panel setOpaque:NO];
	[panel setBackgroundColor:[NSColor clearColor]];
	[panel setShowsResizeIndicator:NO];
	[panel constructBackgroundView];
	[panel switchButtonType];
	return panel;
}

- (void)constructBackgroundView
{
	NSView *contentView = self.contentView;
	NSArray *subviews = [contentView subviews];
	if ([subviews count] > 0)
	{
		id belowView = [subviews objectAtIndex:0];
		SBSavePanelContentView *savePanelContentView = nil;
		savePanelContentView = [[[SBSavePanelContentView alloc] initWithFrame:contentView.frame] autorelease];
		[savePanelContentView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
		[contentView addSubview:savePanelContentView positioned:NSWindowBelow relativeTo:belowView];
	}
}

- (void)switchButtonType
{
	NSArray *subviews = [[self contentView] subviews];
	[self switchButtonTypeInSubViews:subviews];
}

- (void)switchButtonTypeInSubViews:(NSArray *)subviews
{
	for (id subview in subviews)
	{
		if ([subview isKindOfClass:[NSButton class]])
		{
			if ([(NSButton *)subview bezelStyle] == NSRoundedBezelStyle)
			{
				[(NSButton *)subview setBezelStyle:NSTexturedRoundedBezelStyle];
			}
		}
		else {
			if ([subview respondsToSelector:@selector(subviews)])
			{
				NSArray *views = [subview subviews];
				[self switchButtonTypeInSubViews:views];
			}
		}
	}
}

@end

@implementation SBSavePanelContentView

#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
	CGRect r = NSRectToCGRect(self.bounds);
	CGPathRef path = nil;
	CGPathRef strokePath = nil;
	NSUInteger count = 3;
	CGFloat locations[count];
	CGFloat colors[count * 4];
	CGFloat storkeColor[4];
	CGPoint points[count];
	BOOL extended = r.size.height < 350.0;
	
	CGContextRetain(ctx);
	[super drawRect:rect];
	
	locations[0] = 0.0;
	locations[1] = 0.95;
	locations[2] = 1.0;
	
	// Paths
	// Gray scales
	path = SBRoundedPath(CGRectInset(r, 0.0, 0.0), 8.0, 0.0, NO, YES);
	strokePath = SBRoundedPath(CGRectInset(r, 0.5, 0.5), 8.0, 0.0, NO, YES);
	// Frame
	colors[0] = colors[1] = colors[2] = extended ? 0.6 : 0.7;
	colors[3] = 1.0;
	colors[4] = colors[5] = colors[6] = extended ? 0.9 : 0.75;
	colors[7] = 1.0;
	colors[8] = colors[9] = colors[10] = extended ? 0.75 : 0.6;
	colors[11] = 1.0;
	storkeColor[0] = storkeColor[1] = storkeColor[2] = 0.2;
	storkeColor[3] = 1.0;
	points[0] = CGPointZero;
	points[1] = CGPointMake(0.0, r.size.height * 0.95);
	points[2] = CGPointMake(0.0, r.size.height);
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, path);
	CGContextClip(ctx);
	SBDrawGradientInContext(ctx, count, locations, colors, points);
	CGContextRestoreGState(ctx);
	
	// Stroke
	CGContextSaveGState(ctx);
	CGContextAddPath(ctx, strokePath);
	CGContextSetLineWidth(ctx, 0.5);
	CGContextSetRGBStrokeColor(ctx, storkeColor[0], storkeColor[1], storkeColor[2], storkeColor[3]);
	CGContextStrokePath(ctx);
	CGContextRestoreGState(ctx);
	CGContextRelease(ctx);
}

@end