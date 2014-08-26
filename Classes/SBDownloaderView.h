/*

SBDownloaderView.h
 
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
@interface SBDownloaderView : SBView <NSTextFieldDelegate>
{
	NSTextField *messageLabel;
	NSTextField *urlLabel;
	SBBLKGUITextField *urlField;
	SBBLKGUIButton *cancelButton;
	SBBLKGUIButton *doneButton;
}
@property NSString *message;
@property NSString *urlString;
@property (readonly) NSPoint margin;
@property (readonly) CGFloat labelWidth;
@property (readonly) NSSize buttonSize;
@property (readonly) CGFloat buttonMargin;
@property (readonly) NSRect messageLabelRect;
@property (readonly) NSRect urlLabelRect;
@property (readonly) NSRect urlFieldRect;
@property (readonly) NSRect doneButtonRect;
@property (readonly) NSRect cancelButtonRect;

// Construction
- (void)constructMessageLabel;
- (void)constructURLLabel;
- (void)constructURLField;
- (void)constructDoneButton;
- (void)constructCancelButton;
- (void)makeResponderChain;
//  Actions
- (void)makeFirstResponderToURLField;

@end
