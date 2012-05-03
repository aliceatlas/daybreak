/*

SBSectionListView.h
 
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

@class SBSectionGroupe;
@class SBSectionItem;
@class SBSectionItemView;
@interface SBSectionListView : SBView
{
	NSScrollView *scrollView;
	NSView *contentView;
	NSMutableArray *sectionGroupeViews;
	NSMutableArray *sections;
}
@property (nonatomic, retain) NSMutableArray *sectionGroupeViews;
@property (nonatomic, retain) NSMutableArray *sections;

- (id)initWithFrame:(NSRect)frame;
- (NSRect)contentViewRect;
- (NSRect)groupeViewRectAtIndex:(NSInteger)index;
- (void)destructScrollView;
- (void)constructScrollView;
- (void)constructSectionGroupeViews;

@end

@interface SBSectionGroupeView : SBView
{
	NSMutableArray *itemViews;
	SBSectionGroupe *groupe;
}
@property (nonatomic, retain) NSMutableArray *itemViews;
@property (nonatomic, retain) SBSectionGroupe *groupe;

- (NSRect)itemViewRectAtIndex:(NSInteger)index;
- (void)addItemView:(SBSectionItemView *)itemView;

@end

@interface SBSectionItemView : SBView <NSTextFieldDelegate>
{
	SBSectionItem *item;
	NSImageView *currentImageView;
	NSTextField *currentField;
}
@property (nonatomic, retain) SBSectionItem *item;
@property (nonatomic, assign) NSImageView *currentImageView;
@property (nonatomic, assign) NSTextField *currentField;

- (id)initWithItem:(SBSectionItem *)inItem;
- (NSRect)titleRect;
- (NSRect)valueRect;
- (void)constructControl;

@end
