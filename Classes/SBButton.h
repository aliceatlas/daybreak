/*

SBButton.h
 
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

@interface SBButton : SBView <NSCoding>
{
	NSString *title;
	NSImage *image;
	NSImage *disableImage;
	NSImage *backImage;
	NSImage *backDisableImage;
	SEL action;
	BOOL enabled;
	BOOL pressed;
	NSString *keyEquivalent;
	NSUInteger keyEquivalentModifierMask;
}
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSImage *image;
@property (nonatomic, retain) NSImage *disableImage;
@property (nonatomic, retain) NSImage *backImage;
@property (nonatomic, retain) NSImage *backDisableImage;
@property (nonatomic) SEL action;
@property (nonatomic) BOOL enabled;
@property (nonatomic) BOOL pressed;
@property (nonatomic, retain) NSString *keyEquivalent;
@property (nonatomic) NSUInteger keyEquivalentModifierMask;

// Setter
- (void)setToolbarVisible:(BOOL)isToolbarVisible;
- (void)setEnabled:(BOOL)inEnabled;
- (void)setPressed:(BOOL)isPressed;
- (void)setTitle:(NSString *)inTitle;
// Exec
- (void)executeAction;

@end