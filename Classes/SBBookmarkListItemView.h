/*
 
 SBBookmarkListItemView.h
 
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

#import "SBDefinitions.h"
#import "SBView.h"


@interface SBBookmarkListItemView : SBView
{
	NSProgressIndicator *progressIndicator;
	SBBookmarkMode mode;
	NSDictionary *item;
	BOOL selected;
	BOOL dragged;
	NSTrackingArea *area;
}
@property (nonatomic) SBBookmarkMode mode;
@property (nonatomic, retain) NSDictionary *item;
@property (nonatomic) BOOL selected;
@property (nonatomic) BOOL dragged;
@property (nonatomic, readonly) NSFont *titleFont;
@property (nonatomic, readonly) NSFont *urlFont;
@property (nonatomic, readonly) NSParagraphStyle *paragraphStyle;

+ (id)viewWithFrame:(NSRect)frame item:(NSDictionary *)item;
- (BOOL)hitToPoint:(NSPoint)point;
- (BOOL)hitToRect:(NSRect)rect;
- (BOOL)isFirstResponder;
- (NSPoint)padding;
- (CGFloat)heights;
- (CGFloat)titleHeight;
- (CGFloat)bytesHeight;
- (BOOL)visible;
- (NSFont *)titleFont;
// Rects
- (NSRect)imageRect;
- (NSRect)titleRect;
- (NSRect)titleRect:(NSString *)title;
- (NSRect)bytesRect;
// Setter
- (void)setSelected:(BOOL)isSelected;
- (void)setDragged:(BOOL)isDragged;
- (void)showProgress;
- (void)hideProgress;
- (void)remove;
- (void)edit;
- (void)update;
- (BOOL)hitToPoint:(NSPoint)point;

@end

@interface SBBookmarkListDirectoryItemView : SBBookmarkListItemView


@end
