/*

SBURLField.h
 
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

@class SBButton;
@class SBURLImageView;
@class SBURLTextField;
@class SBURLFieldSheet;
@class SBURLFieldContentView;
@protocol SBURLFieldDelegate;
@protocol SBURLFieldDatasource;

@interface SBURLField : SBView <NSTextFieldDelegate>
{
	SBButton *backwardButton;
	SBButton *forwardButton;
	SBURLImageView *imageView;
	SBURLTextField *field;
	SBButton *goButton;
	SBURLFieldSheet *sheet;
	SBURLFieldContentView *contentView;
	id<SBURLFieldDatasource> __unsafe_unretained dataSource;
	id __unsafe_unretained delegate;
	NSMutableArray *gsItems;
	NSMutableArray *bmItems;
	NSMutableArray *hItems;
	NSMutableArray *items;
	BOOL _isOpenSheet;
}
@property (strong) SBButton *backwardButton;
@property (strong) SBButton *forwardButton;
@property (strong) SBURLImageView *imageView;
@property (strong) SBURLTextField *field;
@property (strong) SBButton *goButton;
@property (strong) SBURLFieldSheet *sheet;
@property (strong) SBURLFieldContentView *contentView;
@property (unsafe_unretained) id<SBURLFieldDatasource> dataSource;
@property (unsafe_unretained) id delegate;
@property NSImage *image;
@property NSString *stringValue;
@property (strong) NSMutableArray *gsItems;
@property (strong) NSMutableArray *bmItems;
@property (strong) NSMutableArray *hItems;
@property (strong) NSMutableArray *items;
@property BOOL enabledBackward;
@property BOOL enabledForward;
@property BOOL enabledGo;
@property BOOL hiddenGo;
@property (readonly) NSSize minimumSize;
@property (readonly) NSFont *font;
@property (readonly) CGFloat sheetHeight;
@property (readonly) NSRect appearedSheetRect;
@property (readonly) BOOL isOpenSheet;
@property (getter=isEditing, readonly) BOOL editing;
@property (readonly) BOOL isFirstResponder;
@property (readonly) CGFloat buttonWidth;
@property (readonly) CGFloat goButtonWidth;
@property (readonly) CGFloat imageWidth;
@property (readonly) NSRect backwardRect;
@property (readonly) NSRect forwardRect;
@property (readonly) NSRect imageRect;
@property (readonly) NSRect fieldRect;
@property NSString *placeholderString;
@property NSArray *URLItems;


// Construction
- (void)constructViews;
- (void)constructButtons;
- (void)constructField;
- (void)constructGoButton;
- (void)constructSheet;

- (BOOL)canSelectIndex:(NSInteger)index;

// Action
- (void)endEditing;
- (void)adjustSheet;
- (void)appearSheetIfNeeded:(BOOL)closable;
- (void)appearSheet;
- (void)disappearSheet;
- (void)selectRowAbove;
- (void)selectRowBelow;
- (void)reloadData;
- (void)selectText:(id)sender;
- (void)setTextColor:(NSColor *)color;
- (void)setNextKeyView:(id)responder;
- (void)updateGoTitle:(NSEvent *)theEvent;
- (void)go;

// Execute Delegate Method
- (void)executeDidSelectBackward;
- (void)executeDidSelectForward;
- (void)executeShouldOpenURL;
- (void)executeShouldOpenURLInNewTab;
- (void)executeShouldDownloadURL;
- (void)executeTextDidChange;
- (void)executeWillResignFirstResponder;

@end

@interface SBURLImageView : NSImageView <NSDraggingSource>

@property (readonly) SBURLField *field;
@property (readonly) NSURL *URL;
@property (readonly) NSData *selectedWebViewImageDataForBookmark;
@property (readonly) NSImage *dragImage;

- (void)mouseDraggedActionWithEvent:(NSEvent *)theEvent;
- (void)mouseUpActionWithEvent:(NSEvent *)theEvent;

@end

@interface SBURLTextField : NSTextField
{
	SEL commandAction;
	SEL optionAction;
}
@property (readonly) SBURLField *field;
@property SEL commandAction;
@property SEL optionAction;

- (instancetype)initWithFrame:(NSRect)frame;

@end


@interface SBURLFieldSheet : NSPanel

@end

@interface SBURLFieldContentView : NSView
{
	NSScrollView *_scroller;
	NSTextField *_text;
	NSTableView *_table;
	id dataSource;
	id delegate;
}
@property (readonly) SBURLField *field;
@property (readonly) NSUInteger selectedRowIndex;

// Construction
- (void)constructTable;

// Set
- (void)setDataSource:(id)inDataSource;
- (void)setDelegate:(id)inDelegate;

// Action
- (void)adjustTable;
- (BOOL)selectRow:(NSUInteger)rowIndex;
- (void)deselectRow;
- (void)reloadData;
- (void)pushSelectedItem;
- (BOOL)pushItemAtIndex:(NSInteger)index;

@end

@interface SBURLFieldDataCell : NSCell
{
	BOOL separator;
	BOOL sectionHeader;
	BOOL drawsImage;
}
@property BOOL separator;
@property BOOL sectionHeader;
@property BOOL drawsImage;
@property (readonly) CGFloat side;
@property (readonly) CGFloat leftMargin;
@property (readonly) CGFloat imageWidth;

- (void)drawImageWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
- (void)drawTitleWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;

@end

@interface SBURLFieldUtil : NSObject

+ (NSString *)schemeForURLString:(NSString *)urlString;

@end