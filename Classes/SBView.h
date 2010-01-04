/*

SBView.h
 
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

@interface SBView : NSView <NSCoding>
{
	CGFloat animationDuration;
	NSColor *frameColor;
	BOOL keyView;
	BOOL toolbarVisible;
	id target;
	SEL doneSelector;
	SEL cancelSelector;
}
@property (nonatomic, retain) NSColor *frameColor;
@property (nonatomic) CGFloat animationDuration;
@property (nonatomic) BOOL keyView;
@property (nonatomic) BOOL toolbarVisible;
@property (nonatomic) NSRect frame;
@property (nonatomic, assign) CALayer *layer;
@property (nonatomic) BOOL wantsLayer;
@property (nonatomic) BOOL hidden;
@property (nonatomic) CGFloat alphaValue;
@property (nonatomic, readonly) NSView *subview;
@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL doneSelector;
@property (nonatomic, assign) SEL cancelSelector;

// Getter
- (NSString *)description;
// Setter
- (void)setFrame:(NSRect)frame;
- (void)setLayer:(CALayer *)layer;
- (void)setWantsLayer:(BOOL)wantsLayer;
- (void)setHidden:(BOOL)hidden;
- (void)setAlphaValue:(CGFloat)alphaValue;
- (void)setFrame:(NSRect)frame animate:(BOOL)animate;
- (void)setKeyView:(BOOL)isKeyView;
- (void)setToolbarVisible:(BOOL)isToolbarVisible;
// Actions
- (void)fadeIn:(id)delegate;
- (void)fadeOut:(id)delegate;
- (void)done;
- (void)cancel;

@end
