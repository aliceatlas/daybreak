/*

SBTabbar.h
 
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
@class SBTabbar;
@class SBTabbarItem;
@protocol SBTabbarDelegate;
@interface SBTabbar : SBView <NSAnimationDelegate>
{
	NSMutableArray *items;
	SBView *contentView;
	SBButton *addButton;
	id <SBTabbarDelegate> delegate;
	NSPoint _downPoint;
	NSRect _draggedItemRect;
	SBTabbarItem *_draggedItem;
	SBTabbarItem *_shouldReselectItem;
	BOOL _animating;
	NSTimer *autoScrollTimer;
	CGFloat _autoScrollDeltaX;
	NSTimer *closableTimer;
	SBTabbarItem *closableItem;
}
@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, assign) id <SBTabbarDelegate> delegate;
@property (nonatomic, readonly, assign) SBTabbarItem *selectedTabbarItem;

- (id)init;
// Rects
- (CGFloat)itemWidth;
- (CGFloat)itemMinimumWidth;
- (CGFloat)addButtonWidth;
- (NSRect)addButtonRect;
- (NSRect)addButtonRect:(NSInteger)count;
- (CGFloat)innerWidth;
- (NSRect)newItemRect;
- (NSRect)itemRectAtIndex:(NSInteger)index;
- (NSInteger)indexForPoint:(NSPoint)point rect:(NSRect *)rect;
- (SBTabbarItem *)itemAtPoint:(NSPoint)point;
// Setter
- (void)setToolbarVisible:(BOOL)isToolbarVisible;
// Destruction
- (void)destructContentView;
- (void)destructItems;
- (void)destructButtons;
- (void)destructAddButton;
- (void)destructAutoScrollTimer;
- (void)destructClosableTimer;
// Construction
- (void)constructContentView;
- (void)constructItems;
- (void)constructAddButton;
// Exec
- (void)executeShouldAddNewItemForURLs:(NSArray *)urls;
- (void)executeShouldOpenURLs:(NSArray *)urls startInItem:(SBTabbarItem *)item;
- (void)executeShouldReselect:(SBTabbarItem *)item;
- (void)executeShouldReloadItem:(SBTabbarItem *)item;
- (void)executeDidChangeSelection:(SBTabbarItem *)item;
- (void)executeDidReselectItem:(SBTabbarItem *)item;
- (void)executeDidRemoveItem:(NSString *)identifier;
// Actions
- (SBTabbarItem *)addItemWithIdentifier:(NSNumber *)identifier;
- (void)addItem:(SBTabbarItem *)item;
- (BOOL)removeItem:(SBTabbarItem *)item;
- (void)selectItem:(SBTabbarItem *)item;
- (void)selectItemForIndex:(NSUInteger)index;
- (void)selectLastItem;
- (void)selectPreviousItem;
- (void)selectNextItem;
- (void)closeItem:(SBTabbarItem *)item;
- (void)closeSelectedItem;
- (void)addNewItem:(id)sender;
- (void)closeItemFromMenu:(NSMenuItem *)menuItem;
- (void)closeOtherItemsFromMenu:(NSMenuItem *)menuItem;
- (void)reloadItemFromMenu:(NSMenuItem *)menuItem;
- (void)layout;
- (void)scroll:(CGFloat)deltaX;
- (BOOL)autoScrollWithPoint:(NSPoint)point;
- (void)autoScroll:(NSEvent *)theEvent;
- (void)mouseDraggedWithTimer:(NSTimer *)timer;
- (BOOL)canClosable;
- (void)constructClosableTimerForItem:(SBTabbarItem *)item;
- (void)applyClosableItem;
- (void)applyDisclosableAllItem;
// Update
- (void)updateItems;
- (NSMenu *)menuForItem:(SBTabbarItem *)item;

@end
