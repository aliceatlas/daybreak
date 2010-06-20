/*

SBBookmarksView.h
 
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
#import "SBBookmarkListView.h"
#import "SBFixedSplitView.h"
#import "SBSearchbar.h"
#import "SBView.h"

@interface SBBookmarksView : SBView <SBBookmarkListViewDelegate>
{
	SBFixedSplitView *splitView;
	SBBLKGUIScrollView *scrollView;
	SBBookmarkListView *listView;
	SBSearchbar *searchbar;
	id delegate;
}
@property (nonatomic, retain) SBBookmarkListView *listView;
@property (nonatomic) CGFloat cellWidth;
@property (nonatomic) SBBookmarkMode mode;
@property (nonatomic, assign) id delegate;

- (CGFloat)splitWidth:(CGFloat)proposedWidth;
// Destruction
- (void)destructListView;
// Construction
- (void)constructListView:(SBBookmarkMode)inMode;
// Setter
- (void)setCellWidth:(CGFloat)cellWidth;
- (BOOL)setShowSearchbar:(BOOL)showSearchbar;
- (void)searchWithText:(NSString *)text;
- (void)closeSearchbar;
// Execute
- (void)executeDidChangeMode;
- (void)executeShouldEditItemAtIndex:(NSUInteger)index;
- (void)executeDidCellWidth;
// Actions
- (void)addForBookmarkItem:(NSDictionary *)item;
- (void)scrollToItem:(NSDictionary *)bookmarkItem;
- (void)reload;

@end
