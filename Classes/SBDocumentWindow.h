/*

SBDocumentWindow.h
 
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

@class SBInnerView;
@class SBCoverWindow;
@class SBToolbar;
@class SBTabbar;
@class SBSplitView;
@interface SBDocumentWindow : NSWindow
{
	NSWindow *backWindow;
	BOOL keyView;
	SBInnerView *innerView;
	SBCoverWindow *coverWindow;
	SBTabbar *tabbar;
	SBSplitView *splitView;
	BOOL tabbarVisivility;
}
@property (nonatomic, readonly) NSRect innerRect;
@property (nonatomic) BOOL keyView;
@property (nonatomic, assign) NSString *title;
@property (nonatomic, assign) SBToolbar *toolbar;
@property (nonatomic, assign) NSView *contentView;
@property (nonatomic, retain) SBInnerView *innerView;
@property (nonatomic, retain) SBTabbar *tabbar;
@property (nonatomic, retain) SBSplitView *splitView;
@property (nonatomic, retain) SBCoverWindow *coverWindow;
@property (nonatomic, retain) NSWindow *backWindow;
@property (nonatomic) BOOL tabbarVisivility;

- (id)initWithFrame:(NSRect)frame delegate:(id)delegate tabbarVisivility:(BOOL)inTabbarVisivility;

- (BOOL)isCovering;
// Rects
- (CGFloat)tabbarHeight;
- (NSRect)tabbarRect;
- (NSRect)splitViewRect;
- (CGFloat)sheetPosition;
// Construction
- (void)constructInnerView;
// Setter
- (void)setTitle:(NSString *)title;
- (void)setToolbar:(SBToolbar *)toolbar;
- (void)setTabbar:(SBTabbar *)inTabbar;
- (void)setSplitView:(SBSplitView *)inSplitView;
// Actions
- (void)destructCoverWindow;
- (void)constructCoverWindowWithView:(id)view;
- (void)hideCoverWindow;
- (void)showCoverWindow:(SBView *)view;
- (void)hideToolbar;
- (void)showToolbar;
- (void)hideTabbar;
- (void)showTabbar;
- (void)flip;
- (void)flip:(SBView *)view;
- (void)doneFlip;

@end
