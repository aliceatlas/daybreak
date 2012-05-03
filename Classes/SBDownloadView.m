/*
 
 SBDownloadView.m
 
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

#import "SBDownloadView.h"
#import "SBDownload.h"
#import "SBDownloads.h"
#import "SBDownloadsView.h"
#import "SBCircleProgressIndicator.h"
#import "SBUtil.h"

@implementation SBDownloadView

@synthesize download;
@synthesize progressIndicator;
@synthesize selected;
@dynamic nameFont;
@dynamic paragraphStyle;

- (id)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		progressIndicator = nil;
		selected = NO;
		area = [[NSTrackingArea alloc] initWithRect:self.bounds options:(NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved |NSTrackingActiveAlways | NSTrackingInVisibleRect) owner:self userInfo:nil];
		[self addTrackingArea:area];
		[self constructProgressIndicator];
	}
	return self;
}

#pragma mark View

// Clicking through
- (NSView*)hitTest:(NSPoint)point
{
	NSView *view = [super hitTest:point];
	return (view == self) ? nil : view;
}

#pragma mark Getter

- (BOOL)isFirstResponder
{
	return [[self window] firstResponder] == [self superview];
}

- (NSPoint)padding
{
	return NSMakePoint(self.bounds.size.width * 0.1, self.bounds.size.width * 0.1);
}

- (CGFloat)heights
{
	return [self titleHeight] + [self bytesHeight];
}

- (CGFloat)titleHeight
{
	return 15.0;
}

- (CGFloat)bytesHeight
{
	return 12.0;
}

- (NSFont *)nameFont
{
	return [NSFont boldSystemFontOfSize:10.0];
}

- (NSParagraphStyle *)paragraphStyle
{
	NSMutableParagraphStyle *paragraph = nil;
	paragraph = [[[NSMutableParagraphStyle alloc] init] autorelease];
	[paragraph setAlignment:NSCenterTextAlignment];
	return [[paragraph copy] autorelease];
}

- (NSRect)progressRect
{
	NSRect r = NSZeroRect;
	NSRect b = self.bounds;
	NSPoint padding = [self padding];
	CGFloat bottomHeight = [self heights] + padding.y;
	r.size.width = r.size.height = 48.0;
	r.origin.x = (b.size.width - r.size.width) / 2;
	r.origin.y = bottomHeight + ((b.size.height - bottomHeight) - r.size.height) / 2;
	return r;
}

- (NSRect)nameRect:(NSString *)title
{
	NSRect r = NSZeroRect;
	NSRect drawRect = self.bounds;
	NSPoint padding = [self padding];
	CGFloat titleHeight = [self titleHeight];
	CGFloat bytesHeight = [self bytesHeight];
	CGFloat margin = 8.0;
	CGFloat availableWidth = self.bounds.size.width - titleHeight;
	if ([title length] > 0)
	{
		NSSize size = [title sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
												 self.nameFont, NSFontAttributeName, 
												 self.paragraphStyle, NSParagraphStyleAttributeName, nil]];
		if (size.width <= availableWidth)
		{
			drawRect.origin.x = (availableWidth - size.width) / 2;
			drawRect.size.width = size.width;
		}
		else {
			drawRect.size.width = availableWidth;
		}
	}
	else {
		drawRect.size.width = availableWidth;
	}
	r = NSZeroRect;
	r.size.width = drawRect.size.width;
	r.size.height = titleHeight;
	r.origin.x = margin + drawRect.origin.x;
	r.origin.y = padding.y + bytesHeight;
	return r;
}

#pragma mark Setter

- (void)setSelected:(BOOL)isSelected
{
	if (selected != isSelected)
	{
		selected = isSelected;
		progressIndicator.highlighted = selected;
		[self setNeedsDisplay:YES];
	}
}

#pragma mark Actions

- (void)destructProgressIndicator
{
	if (progressIndicator)
	{
		[progressIndicator removeFromSuperview];
		[progressIndicator release];
		progressIndicator = nil;
	}
}

- (void)constructProgressIndicator
{
	NSRect r = [self progressRect];
	[self destructProgressIndicator];
	progressIndicator = [[SBCircleProgressIndicator alloc] initWithFrame:r];
	progressIndicator.style = SBCircleProgressIndicatorWhiteStyle;
	[progressIndicator setAutoresizingMask:(NSViewMinXMargin)];
	progressIndicator.selected = selected;
	progressIndicator.alwaysDrawing = YES;
	progressIndicator.showPercentage = YES;
	[self addSubview:progressIndicator];
}

- (void)update
{
	if (download.status == SBStatusDone)
	{
		[self destructProgressIndicator];
	}
	else {
		progressIndicator.progress = download.progress;
		[progressIndicator setNeedsDisplay:YES];
	}
	[self setNeedsDisplay:YES];
}

- (void)remove
{
	SBDownloads *downloads = [SBDownloads sharedDownloads];
	[(SBDownloadsView *)self.superview layoutToolsHidden];
	[downloads removeItem:download];
}

- (void)finder
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:download.path])
	{
		[[NSWorkspace sharedWorkspace] selectFile:download.path inFileViewerRootedAtPath:nil];
		[(SBDownloadsView *)self.superview layoutToolsHidden];
	}
}

- (void)open
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:download.path])
	{
		[[NSWorkspace sharedWorkspace] openFile:download.path];
	}
}

#pragma mark Event

- (void)mouseEntered:(NSEvent *)theEvent
{
	[(SBDownloadsView *)self.superview layoutToolsForItem:self];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
	NSPoint location = [theEvent locationInWindow];
	NSPoint point = [self convertPoint:location fromView:nil];
	if (NSPointInRect(point, self.bounds))
	{
		[(SBDownloadsView *)self.superview layoutToolsForItem:self];
	}
}

- (void)mouseExited:(NSEvent *)theEvent
{
	[(SBDownloadsView *)self.superview layoutToolsHidden];
}

#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	CGFloat bytesHeight = [self bytesHeight];
	NSString *description = nil;
	
	[super drawRect:rect];
	
	// Icon
	if ([download.path length] > 0)
	{
		NSWorkspace *space = [NSWorkspace sharedWorkspace];
		NSImage *image = nil;
		if ((image = [space iconForFile:download.path]))
		{
			NSRect r = NSZeroRect;
			NSRect b = self.bounds;
			NSPoint padding = [self padding];
			CGFloat heights = [self heights];
			NSSize size = [image size];
			CGFloat fraction = 1.0;
			r.size.height = (b.size.height - heights - padding.y * 3);
			r.size.width = size.width * (r.size.height / size.height);
			r.origin.x = (b.size.width - r.size.width) / 2;
			r.origin.y = heights + padding.y * 2;
			fraction = download.status == SBStatusDone ? 1.0 : 0.5;
			[image drawInRect:r fromRect:NSMakeRect(0, 0, size.width, size.height) operation:NSCompositeSourceOver fraction:fraction];
		}
	}
	
	// name string
	if (download.name)
	{
		NSRect r = NSZeroRect;
		NSDictionary *attributes = nil;
		NSSize size = NSZeroSize;
		CGFloat margin = 8.0;
		
		r = [self nameRect:download.name];
		
		if (selected)
		{
			// Background
			CGRect sr = NSRectToCGRect(r);
			CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
			CGFloat components[4];
			CGPathRef path = nil;
			NSUInteger count = 2;
			CGFloat locations[count];
			CGFloat colors[count * 4];
			CGPoint points[count];
			if ([self isFirstResponder])
			{
				SBGetAlternateSelectedControlColorComponents(components);
			}
			else {
				components[0] = components[1] = components[2] = 0.8;
				components[3] = 1.0;
			}
			sr.origin.x -= margin;
			sr.size.width += margin * 2;
			locations[0] = 0.0;
			locations[1] = 1.0;
			colors[0] = components[0] - 0.2;
			colors[1] = components[1] - 0.2;
			colors[2] = components[2] - 0.2;
			colors[3] = components[3];
			colors[4] = components[0];
			colors[5] = components[1];
			colors[6] = components[2];
			colors[7] = components[3];
			points[0] = CGPointMake(0.0, sr.origin.y);
			points[1] = CGPointMake(0.0, CGRectGetMaxY(sr));
			CGContextSaveGState(ctx);
			path = SBRoundedPath(sr, sr.size.height / 2, 0.0, YES, YES);
			CGContextAddPath(ctx, path);
			CGContextClip(ctx);
			SBDrawGradientInContext(ctx, count, locations, colors, points);
			CGContextRestoreGState(ctx);
//			CGRect sr = NSRectToCGRect(r);
//			CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
//			CGFloat components[4];
//			CGPathRef path = nil;
//			if ([self isFirstResponder])
//			{
//				SBGetAlternateSelectedControlColorComponents(components);
//			}
//			else {
//				components[0] = components[1] = components[2] = 0.8;
//				components[3] = 1.0;
//			}
//			sr.origin.x -= margin;
//			sr.size.width += margin * 2;
//			path = SBRoundedPath(sr, sr.size.height / 2, 0.0, YES, YES);
//			CGContextSaveGState(ctx);
//			CGContextAddPath(ctx, path);
//			CGContextSetRGBFillColor(ctx, components[0], components[1], components[2], components[3]);
//			CGContextFillPath(ctx);
//			CGContextRestoreGState(ctx);
//			CGPathRelease(path);
		}
		attributes = [NSDictionary dictionaryWithObjectsAndKeys:
					  self.nameFont, NSFontAttributeName, 
					  [NSColor whiteColor], NSForegroundColorAttributeName, 
					  self.paragraphStyle, NSParagraphStyleAttributeName, nil];
		size = [download.name sizeWithAttributes:attributes];
		r.origin.y += (r.size.height - size.height) / 2;
		r.size.height = size.height;
		[download.name drawInRect:r withAttributes:attributes];
	}
	// bytes string
	switch (download.status)
	{
		case SBStatusUndone:
			description = NSLocalizedString(@"Undone", nil);
			break;
		case SBStatusProcessing:
			description = download.bytes;
			break;
		case SBStatusDone:
			description = NSLocalizedString(@"Done", nil);
			break;
	}
	if (description)
	{
		NSRect r = NSZeroRect;
		NSDictionary *attributes = nil;
		NSSize size = NSZeroSize;
		NSPoint padding = [self padding];
		r.size.width = rect.size.width;
		r.size.height = bytesHeight;
		r.origin.y = padding.y;
		attributes = [NSDictionary dictionaryWithObjectsAndKeys:
					  [NSFont systemFontOfSize:9.0], NSFontAttributeName, 
					  [NSColor lightGrayColor], NSForegroundColorAttributeName, 
					  self.paragraphStyle, NSParagraphStyleAttributeName, nil];
		size = [description sizeWithAttributes:attributes];
		r.origin.y += (r.size.height - size.height) / 2;
		r.size.height = size.height;
		[description drawInRect:r withAttributes:attributes];
	}
}

@end
