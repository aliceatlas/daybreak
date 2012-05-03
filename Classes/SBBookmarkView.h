/*

SBBookmarkView.h
 
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
@class SBBLKGUIPopUpButton;
@interface SBBookmarkView : SBView <NSTextFieldDelegate>
{
	NSImage *image;
	NSTextField *messageLabel;
	NSTextField *titleLabel;
	NSTextField *urlLabel;
	NSTextField *colorLabel;
	SBBLKGUITextField *titleField;
	SBBLKGUITextField *urlField;
	SBBLKGUIPopUpButton *colorPopup;
	SBBLKGUIButton *cancelButton;
	SBBLKGUIButton *doneButton;
	NSInteger fillMode;
}
@property (nonatomic, retain) NSImage *image;
@property (nonatomic, assign) NSString *message;
@property (nonatomic, assign) NSString *title;
@property (nonatomic, assign) NSString *urlString;
@property (nonatomic) NSInteger fillMode;

// Getter
- (NSDictionary *)itemRepresentation;
// Rects
- (NSPoint)margin;
- (CGFloat)labelWidth;
- (NSSize)buttonSize;
- (CGFloat)buttonMargin;
- (NSRect)imageRect;
- (NSRect)messageLabelRect;
- (NSRect)titleLabelRect;
- (NSRect)urlLabelRect;
- (NSRect)colorLabelRect;
- (NSRect)titleFieldRect;
- (NSRect)urlFieldRect;
- (NSRect)colorPopupRect;
- (NSRect)doneButtonRect;
- (NSRect)cancelButtonRect;
// Destruction
- (void)destructMessageLabel;
// Construction
- (void)constructMessageLabel;
- (void)constructTitleLabel;
- (void)constructURLLabel;
- (void)constructColorLabel;
- (void)constructTitleField;
- (void)constructURLField;
- (void)constructColorPopup;
- (void)constructDoneButton;
- (void)constructCancelButton;
- (void)makeResponderChain;
// Setter
- (void)setImage:(NSImage *)inImage;
- (void)setMessage:(NSString *)message;
- (void)setTitle:(NSString *)title;
- (void)setUrlString:(NSString *)urlString;
//  Actions
- (void)makeFirstResponderToTitleField;

@end

@interface SBEditBookmarkView : SBBookmarkView
{
	NSUInteger index;
}
@property (nonatomic) NSUInteger index;
@property (nonatomic, assign) NSString *labelName;

@end
