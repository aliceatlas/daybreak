//
//  SBMessageView.h
//  Sunrise
//
//  Created by Atsushi Jike on 09/11/20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SBDefinitions.h"
#import "SBBLKGUI.h"
#import "SBView.h"

@class SBBLKGUIButton;
@class SBBLKGUITextField;
@interface SBMessageView : SBView
{
	NSTextField *messageLabel;
	NSTextField *textLabel;
	SBBLKGUIButton *cancelButton;
	SBBLKGUIButton *doneButton;
}
@property (nonatomic, assign) NSString *message;
@property (nonatomic, assign) NSString *text;

- (id)initWithFrame:(NSRect)frame text:(NSString *)inText;
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
- (void)constructMessageLabel;
- (void)constructTextLabel:(NSString *)inText;
- (void)constructDoneButton;
- (void)constructCancelButton;
// Setter
- (void)setMessage:(NSString *)message;
- (void)setText:(NSString *)inText;

@end
