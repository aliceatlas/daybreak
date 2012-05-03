/*

SBLocalizationWindowController.h
 
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
#import "SBWindowController.h"

@interface SBLocalizationWindowController : SBWindowController <NSAnimationDelegate>
{
	NSTextField *langField;
	NSPopUpButton *langPopup;
	NSButton *switchButton;
	
	NSView *editView;
	NSScrollView *editScrollView;
	NSView *editContentView;
	NSMutableArray *textSet;
	NSArray *fieldSet;
	NSButton *openButton;
	NSButton *cancelButton;
	NSButton *createButton;
	
	NSView *contributeView;
	NSImageView *iconImageView;
	NSTextField *textField;
	NSTextField *checkoutTitleField;
	NSButton *checkoutButton;
	NSTextField *commitTitleField;
	NSButton *commitButton;
	BOOL animating;
}
@property (nonatomic, retain) NSMutableArray *textSet;
@property (nonatomic, retain) NSArray *fieldSet;

- (CGFloat)margin;
- (CGFloat)topMargin;
- (CGFloat)bottomMargin;
- (void)constructCommonViews;
- (void)constructEditView;
- (void)constructButtonsInEditView;
- (void)constructContributeView;
- (void)constructButtonsInContributeView;
- (void)open;
- (void)mergeFilePath:(NSString *)path;
- (void)showContribute;
- (void)showEdit;
- (void)changeView:(NSInteger)index;
- (void)cancel;
- (void)done;
- (void)export;
// Contribute
- (void)openCheckoutDirectory;

@end

@interface SBViewAnimation : NSViewAnimation
{
	id context;
}
@property (nonatomic, retain) id context;

@end
