/*

SBSnapshotView.h
 
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
@interface SBSnapshotView : SBView <NSTextFieldDelegate>
{
	SBBLKGUIScrollView *scrollView;
	NSImageView *imageView;
	NSView *toolsView;
	SBBLKGUIButton *onlyVisibleButton;
	SBBLKGUIButton *updateButton;
	NSTextField *sizeLabel;
	SBBLKGUITextField *widthField;
	SBBLKGUITextField *heightField;
	NSTextField *scaleLabel;
	SBBLKGUITextField *scaleField;
	NSButton *lockButton;
	NSTextField *filetypeLabel;
	SBBLKGUIPopUpButton *filetypePopup;
	NSTabView *optionTabView;
	NSTextField *tiffOptionLabel;
	SBBLKGUIPopUpButton *tiffOptionPopup;
	NSTextField *jpgOptionLabel;
	SBBLKGUISlider *jpgOptionSlider;
	NSTextField *jpgOptionField;
	NSTextField *filesizeLabel;
	NSTextField *filesizeField;
	SBBLKGUIButton *cancelButton;
	SBBLKGUIButton *doneButton;
	SBView *progressBackgroundView;
	NSTextField *progressField;
	NSProgressIndicator *progressIndicator;
	NSRect visibleRect;
	NSImage *image;
	NSBitmapImageFileType filetype;
	NSTIFFCompression tiffCompression;
	CGFloat jpgFactor;
	NSTimer *updateTimer;
	NSSize successSize;
	CGFloat successScale;
	NSString *title;
	NSData *data;
}
@property (nonatomic, retain) NSString *title;
@property (nonatomic, readonly) NSString *filename;
@property (nonatomic, retain) NSData *data;

// Rects
- (NSPoint)margin;
- (CGFloat)labelWidth;
- (NSSize)buttonSize;
- (CGFloat)buttonMargin;
- (NSRect)doneButtonRect;
- (NSRect)cancelButtonRect;
// Construction
- (void)constructViews;
- (void)constructDoneButton;
- (void)constructCancelButton;
//Actions (Private)
- (BOOL)shouldShowSizeWarning:(id)field;
- (void)setTarget:(id)inTarget;
- (void)setVisibleRect:(NSRect)inVisibleRect;
- (BOOL)setImage:(NSImage *)inImage;
- (void)destructUpdateTimer;
- (void)showProgress;
- (void)hideProgress;
- (void)updateWithTimer:(NSTimer *)timer;
- (void)updateForField:(id)field;
- (void)updatingForField:(id)field;
- (void)updatePreviewImage;
- (void)updateFieldsForField:(id)field;
// Actions
- (void)checkOnlyVisible:(id)sender;
- (void)update:(id)sender;
- (void)lock:(id)sender;
- (void)selectFiletype:(id)sender;
- (void)selectTiffOption:(id)sender;
- (void)slideJpgOption:(id)sender;
- (void)save:(id)sender;
- (void)destruct;
- (NSData *)imageData:(NSBitmapImageFileType)inFiletype size:(NSSize)size;
@end
