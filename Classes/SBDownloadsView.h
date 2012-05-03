/*
 
 SBDownloadsView.h
 
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

#import "SBView.h"
#import "SBDownload.h"

@class SBButton;
@class SBDownloadView;
@interface SBDownloadsView : SBView <NSAnimationDelegate>
{
	id<SBDownloadsViewDelegate> delegate;
	NSMutableArray *downloadViews;
	SBButton *removeButton;
	SBButton *finderButton;
	SBDownloadView *toolsItemView;
	NSTimer *toolsTimer;
}
@property (nonatomic, assign) id<SBDownloadsViewDelegate> delegate;

- (NSSize)cellSize;
- (NSUInteger)blockX;
- (NSRect)cellFrameAtIndex:(NSUInteger)index;
- (NSRect)removeButtonRect:(SBDownloadView *)itemView;
- (NSRect)finderButtonRect:(SBDownloadView *)itemView;
- (void)addForItem:(SBDownload *)item;
- (BOOL)removeForItem:(SBDownload *)item;
- (void)updateForItem:(SBDownload *)item;
- (void)finishForItem:(SBDownload *)item;
- (void)failForItem:(SBDownload *)item;
- (void)layoutToolsForItem:(SBDownloadView *)itemView;
- (void)layoutTools;
- (void)layoutToolsHidden;
// Actions (Private)
- (void)needsDisplaySelectedItemViews;
- (void)executeDidRemoveAllItems;
- (void)destructControls;
- (void)destructToolsTimer;
- (void)constructDownloadViews;
- (void)constructControls;
- (void)layoutItems:(BOOL)animated;
// Menu Actions
- (void)delete:(id)sender;
- (void)selectAll:(id)sender;

@end
