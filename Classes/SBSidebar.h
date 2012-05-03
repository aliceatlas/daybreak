/*

SBSidebar.h
 
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
#import "SBBottombar.h"
#import "SBDrawer.h"

@class SBSidebar;
@class SBSideBottombar;
@protocol SBSidebarDelegate <NSSplitViewDelegate>
- (void)sidebarShouldOpen:(SBSidebar *)inSidebar;
- (void)sidebarShouldClose:(SBSidebar *)inSidebar;
- (void)sidebarDidOpenDrawer:(SBSidebar *)inSidebar;
//- (CGFloat)sidebar:(SBSidebar *)inSidebar didDraggedResizer:(CGFloat)deltaX;
@end
@protocol SBSideBottombarDelegate <NSObject>
- (void)bottombarDidSelectedOpen:(SBSideBottombar *)inBottombar;
- (void)bottombarDidSelectedClose:(SBSideBottombar *)inBottombar;
- (void)bottombarDidSelectedDrawerOpen:(SBSideBottombar *)inBottombar;
- (void)bottombarDidSelectedDrawerClose:(SBSideBottombar *)inBottombar;
- (void)bottombar:(SBSideBottombar *)inBottombar didChangeSize:(CGFloat)size;
//- (CGFloat)bottombar:(SBSideBottombar *)inBottombar didDraggedResizer:(CGFloat)deltaX;
@end
@interface SBSidebar : NSSplitView <SBDownloadsViewDelegate, SBSideBottombarDelegate, NSAnimationDelegate>
{
	NSView *view;
	SBDrawer *drawer;
	SBSideBottombar *bottombar;
	SBSidebarPosition position;
	id<SBSidebarDelegate> siderbarDelegate;
	NSViewAnimation *_divideAnimation;
	CGFloat drawerHeight;
}
@property (nonatomic) SBSidebarPosition position;
@property (nonatomic, assign) id<SBSidebarDelegate> siderbarDelegate;
@property (nonatomic, retain) NSView *view;
@property (nonatomic, retain) SBDrawer *drawer;
@property (nonatomic, retain, readonly) SBSideBottombar *bottombar;
@property (nonatomic, readonly) BOOL visibleDrawer;
@property (nonatomic, readonly) BOOL animating;
@property (nonatomic) CGFloat drawerHeight;

- (id)initWithFrame:(NSRect)frame;
- (NSRect)viewRect;
- (NSRect)drawerRect;
- (NSRect)bottombarRect;
- (void)setView:(NSView *)aView;
- (void)setDrawer:(SBDrawer *)inDrawer;
- (void)setPosition:(SBSidebarPosition)inPosition;
- (void)destructDrawer;
- (void)destructBottombar;
- (void)destructDividerAnimation;
- (void)constructBottombar;
// Actions
- (void)setDividerPosition:(CGFloat)pos;
- (void)setDividerPosition:(CGFloat)pos animate:(BOOL)animate;
- (void)openDrawer:(id)sender;
- (void)closeDrawer:(id)sender;
- (void)closeDrawerWithAnimatedFlag:(BOOL)animated;
- (void)showBookmarkItemIndexes:(NSIndexSet *)indexes;

@end

@class SBButton;
@interface SBSideBottombar : SBBottombar
{
	SBSidebarPosition position;
	NSMutableArray *buttons;
	SBButton *drawerButton;
	SBButton *newFolderButton;
	SBBLKGUISlider *sizeSlider;
	id<SBSideBottombarDelegate> delegate;
	BOOL drawerVisibility;
}
@property (nonatomic, retain) SBBLKGUISlider *sizeSlider;
@property (nonatomic) SBSidebarPosition position;
@property (nonatomic, assign) id<SBSideBottombarDelegate> delegate;
@property (nonatomic) BOOL drawerVisibility;

- (id)initWithFrame:(NSRect)frame;
// Rects
- (CGFloat)buttonWidth;
- (CGFloat)sliderWidth;
- (CGFloat)sliderSideMargin;
- (NSRect)resizableRect;
- (NSRect)drawerButtonRect;
- (NSRect)newFolderButtonRect;
- (NSRect)sizeSliderRect;
- (void)setFrame:(NSRect)frame;
- (void)setPosition:(SBSidebarPosition)inPosition;
- (void)setDrawerVisibility:(BOOL)inDrawerVisibility;
- (void)destructDrawerButton;
- (void)destructNewFolderButton;
- (void)destructSizeSlider;
- (void)constructDrawerButton;
- (void)constructNewFolderButton;
- (void)constructSizeSlider;
// Actions
- (void)adjustButtons;
// Execute
- (void)open;
- (void)close;
- (void)toggleDrawer;
- (void)newFolder;
- (void)slide;

@end
