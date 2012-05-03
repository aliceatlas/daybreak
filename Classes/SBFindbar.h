/*

SBFindbar.h
 
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
#import "SBButton.h"
#import "SBBLKGUI.h"
#import "SBView.h"

@class SBFindSearchField;
@interface SBFindbar : SBView <NSTextFieldDelegate>
{
	NSView *contentView;
	SBButton *closeButton;
	SBFindSearchField *searchField;
	SBButton *backwardButton;
	SBButton *forwardButton;
	SBBLKGUIButton *caseSensitiveCheck;
	SBBLKGUIButton *wrapCheck;
	NSString *searchedString;
}
@property (nonatomic, retain) NSString *searchedString;

+ (CGFloat)minimumWidth;
+ (CGFloat)availableWidth;
// Rects
- (NSRect)contentRect;
- (NSRect)closeRect;
- (NSRect)searchRect;
- (NSRect)backwardRect;
- (NSRect)forwardRect;
- (NSRect)caseSensitiveRect;
- (NSRect)wrapRect;
// Destruction
- (void)destructContentView;
- (void)destructCloseButton;
- (void)destructSearchField;
- (void)destructBackwardButton;
- (void)destructForwardButton;
- (void)destructCaseSensitiveCheck;
- (void)destructWrapCheck;
// Construction
- (void)constructContentView;
- (void)constructCloseButton;
- (void)constructSearchField;
- (void)constructBackwardButton;
- (void)constructForwardButton;
- (void)constructCaseSensitiveCheck;
- (void)constructWrapCheck;
// Actions
- (void)selectText:(id)sender;
- (void)searchContinuous:(id)sender;
- (void)search:(id)sender;
- (void)searchBackward:(id)sender;
- (void)searchForward:(id)sender;
- (void)checkCaseSensitive:(id)sender;
- (void)checkWrap:(id)sender;
- (void)executeClose;
- (BOOL)executeSearch:(BOOL)forward continuous:(BOOL)continuous;

@end

@interface SBFindSearchField : NSSearchField
{
	SEL nextAction;
	SEL previousAction;
}

- (void)performFindNext:(id)sender;
- (void)performFindPrevious:(id)sender;
- (void)setNextAction:(SEL)inNextAction;
- (void)setPreviousAction:(SEL)inPreviousAction;

@end
