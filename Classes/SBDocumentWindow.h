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
@property (copy) NSString *title;
@property (strong) SBToolbar *toolbar;
@property (strong) NSView *contentView;
@property (nonatomic, strong) SBInnerView *innerView;
@property (nonatomic, strong) SBTabbar *tabbar;
@property (nonatomic, strong) SBSplitView *splitView;
@property (nonatomic, strong) SBCoverWindow *coverWindow;
@property (nonatomic, strong) NSWindow *backWindow;
@property (nonatomic) BOOL tabbarVisivility;
@property (nonatomic, getter=isCovering, readonly) BOOL covering;
@property (nonatomic, readonly) CGFloat tabbarHeight;
@property (nonatomic, readonly) NSRect tabbarRect;
@property (nonatomic, readonly) NSRect splitViewRect;
@property (nonatomic, readonly) CGFloat sheetPosition;

- (instancetype)initWithFrame:(NSRect)frame delegate:(id)delegate tabbarVisivility:(BOOL)inTabbarVisivility NS_DESIGNATED_INITIALIZER;

// Construction
- (void)constructInnerView;
// Actions
- (void)destructCoverWindow;
- (void)constructCoverWindowWithView:(NSView *)view;
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
