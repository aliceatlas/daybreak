//
//  SBTextInputView.h
//  Sunrise
//
//  Created by Atsushi Jike on 09/11/28.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SBDefinitions.h"
#import "SBBLKGUI.h"
#import "SBView.h"

@class SBBLKGUIButton;
@class SBBLKGUITextField;
@interface SBTextInputView : SBView
{
	NSTextField *messageLabel;
	SBBLKGUITextField *textLabel;
	SBBLKGUIButton *cancelButton;
	SBBLKGUIButton *doneButton;
}
@property (nonatomic, assign) NSString *message;
@property (nonatomic, assign) NSString *text;

- (id)initWithFrame:(NSRect)frame prompt:(NSString *)prompt;
// Rects
- (NSPoint)margin;
- (CGFloat)labelWidth;
- (NSSize)buttonSize;
- (CGFloat)buttonMargin;
- (NSFont *)textFont;
- (NSRect)messageLabelRect;
- (NSRect)textLabelRect;
- (NSRect)doneButtonRect;
- (NSRect)cancelButtonRect;
// Construction
- (void)constructMessageLabel:(NSString *)inMessage;
- (void)constructTextLabel;
- (void)constructDoneButton;
- (void)constructCancelButton;
// Setter
- (void)setMessage:(NSString *)message;
- (void)setText:(NSString *)inText;

@end
