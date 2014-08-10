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
@property (nonatomic, strong) SBButton *backwardButton;
@property (nonatomic, strong) SBButton *forwardButton;
@property (nonatomic, strong) SBURLImageView *imageView;
@property (nonatomic, strong) SBURLTextField *field;
@property (nonatomic, strong) SBButton *goButton;
@property (nonatomic, strong) SBURLFieldSheet *sheet;
@property (nonatomic, strong) SBURLFieldContentView *contentView;
@property (nonatomic, unsafe_unretained) id<SBURLFieldDatasource> dataSource;
@property (nonatomic, unsafe_unretained) id delegate;
@property (nonatomic, weak) NSImage *image;
@property (nonatomic, weak) NSString *stringValue;
@property (nonatomic, strong) NSMutableArray *gsItems;
@property (nonatomic, strong) NSMutableArray *bmItems;
@property (nonatomic, strong) NSMutableArray *hItems;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic) BOOL enabledBackward;
@property (nonatomic) BOOL enabledForward;
@property (nonatomic) BOOL enabledGo;
@property (nonatomic) BOOL hiddenGo;
@property (nonatomic, readonly) NSSize minimumSize;
@property (nonatomic, readonly) NSFont *font;
@property (nonatomic, readonly) CGFloat sheetHeight;
@property (nonatomic, readonly) NSRect appearedSheetRect;
@property (nonatomic, readonly) BOOL isOpenSheet;
@property (nonatomic, getter=isEditing, readonly) BOOL editing;
@property (nonatomic, readonly) BOOL isFirstResponder;
@property (nonatomic, readonly) CGFloat buttonWidth;
@property (nonatomic, readonly) CGFloat goButtonWidth;
@property (nonatomic, readonly) CGFloat imageWidth;
@property (nonatomic, readonly) NSRect backwardRect;
@property (nonatomic, readonly) NSRect forwardRect;
@property (nonatomic, readonly) NSRect imageRect;
@property (nonatomic, readonly) NSRect fieldRect;
@property (nonatomic) NSString *placeholderString;
@property (nonatomic) NSArray *URLItems;


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

@interface SBURLImageView : NSImageView

@property (nonatomic, readonly) SBURLField *field;
@property (nonatomic, readonly) NSURL *URL;
@property (nonatomic, readonly) NSData *selectedWebViewImageDataForBookmark;
@property (nonatomic, readonly) NSImage *dragImage;

- (void)mouseDraggedActionWithEvent:(NSEvent *)theEvent;
- (void)mouseUpActionWithEvent:(NSEvent *)theEvent;

@end

@interface SBURLTextField : NSTextField
{
	SEL commandAction;
	SEL optionAction;
}
@property (nonatomic, readonly) SBURLField *field;
@property (nonatomic) SEL commandAction;
@property (nonatomic) SEL optionAction;

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
@property (nonatomic, readonly) SBURLField *field;
@property (nonatomic, readonly) NSUInteger selectedRowIndex;

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
@property (nonatomic) BOOL separator;
@property (nonatomic) BOOL sectionHeader;
@property (nonatomic) BOOL drawsImage;
@property (nonatomic, readonly) CGFloat side;
@property (nonatomic, readonly) CGFloat leftMargin;
@property (nonatomic, readonly) CGFloat imageWidth;

- (void)drawImageWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
- (void)drawTitleWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;

@end

@interface SBURLFieldUtil : NSObject

+ (NSString *)schemeForURLString:(NSString *)urlString;

@end