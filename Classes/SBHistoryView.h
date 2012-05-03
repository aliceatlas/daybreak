/*

SBHistoryView.h
 
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
#import "SBBLKGUI.h"
#import "SBView.h"

@class SBBLKGUIButton;
@class SBBLKGUITextField;
@interface SBHistoryView : SBView <NSTextFieldDelegate, NSTableViewDelegate, NSTableViewDataSource>
{
	NSImageView *iconImageView;
	NSTextField *messageLabel;
	SBBLKGUISearchField *searchField;
	SBBLKGUIScrollView *scrollView;
	NSTableView *tableView;
	SBBLKGUIButton *removeButton;
	SBBLKGUIButton *removeAllButton;
	SBBLKGUIButton *backButton;
	NSMutableArray *items;
}
@property (nonatomic, assign) NSString *message;
@property (nonatomic, retain) NSMutableArray *items;

// Rects
- (NSPoint)margin;
- (CGFloat)labelWidth;
- (NSRect)iconRect;
- (CGFloat)buttonHeight;
- (CGFloat)buttonMargin;
- (CGFloat)searchFieldWidth;
- (NSRect)messageLabelRect;
- (NSRect)tableViewRect;
- (NSRect)removeButtonRect;
- (NSRect)removeAllButtonRect;
- (NSRect)backButtonRect;
// Construction
- (void)constructMessageLabel;
- (void)constructSearchField;
- (void)constructTableView;
- (void)constructRemoveButtons;
- (void)constructBackButton;
- (void)makeResponderChain;
// Setter
- (void)setMessage:(NSString *)message;

@end
