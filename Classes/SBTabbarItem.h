/*

SBTabbarItem.h
 
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

@class SBTabbar;
@class SBCircleProgressIndicator;
@interface SBTabbarItem : SBView
{
	SBTabbar *tabbar;
	SBCircleProgressIndicator *progressIndicator;
	NSNumber *identifier;
	NSImage *image;
	NSString *title;
	BOOL selected;
	BOOL closable;
	SEL closeSelector;
	SEL selectSelector;
	BOOL _downInClose;
	BOOL _dragInClose;
	NSTrackingArea *area;
}
@property (nonatomic, assign) SBTabbar *tabbar;
@property (nonatomic, retain) SBCircleProgressIndicator *progressIndicator;
@property (nonatomic, retain) NSNumber *identifier;
@property (nonatomic, retain) NSImage *image;
@property (nonatomic, retain) NSString *title;
@property (nonatomic) BOOL selected;
@property (nonatomic) BOOL closable;
@property (nonatomic, assign) SEL closeSelector;
@property (nonatomic, assign) SEL selectSelector;
@property (nonatomic) CGFloat progress;

// Rects
- (CGRect)closableRect;
- (CGRect)progressRect;
// Setter
- (void)setTitle:(NSString *)inTitle;
- (void)setSelected:(BOOL)inSelected;
- (void)setClosable:(BOOL)inClosable;
// Destruction
- (void)destructProgressIndicator;
// Construction
- (void)constructProgressIndicator;
// Exec
- (void)executeShouldClose;
- (void)executeShouldSelect;

@end
