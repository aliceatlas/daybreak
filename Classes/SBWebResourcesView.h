/*
 
 SBWebResourcesView.h
 
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
#import "SBTableCell.h"
#import "SBView.h"

@class SBWebResourcesView;
@protocol SBWebResourcesViewDataSource <NSObject>
- (NSInteger)numberOfRowsInWebResourcesView:(SBWebResourcesView *)aWebResourcesView;
- (id)webResourcesView:(SBWebResourcesView *)aWebResourcesView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;
- (void)webResourcesView:(SBWebResourcesView *)aWebResourcesView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;
@end
@protocol SBWebResourcesViewDelegate <NSObject>
@optional
- (void)webResourcesView:(SBWebResourcesView *)aWebResourcesView shouldSaveAtRow:(NSInteger)rowIndex;
- (void)webResourcesView:(SBWebResourcesView *)aWebResourcesView shouldDownloadAtRow:(NSInteger)rowIndex;
@end

@interface SBWebResourcesView : SBView <NSTableViewDataSource, NSTableViewDelegate>
{
	NSScrollView *scrollView;
	NSTableView *tableView;
	id<SBWebResourcesViewDataSource> dataSource;
	id<SBWebResourcesViewDelegate> delegate;
}
@property (nonatomic, assign) id<SBWebResourcesViewDataSource> dataSource;
@property (nonatomic, assign) id<SBWebResourcesViewDelegate> delegate;

// Constructions
- (void)constructTableView;
// Actions
- (void)reload;

@end

@interface SBWebResourceButtonCell : NSButtonCell
{
	NSImage *highlightedImage;
}
@property (nonatomic, retain) NSImage *highlightedImage;

- (CGFloat)side;
- (void)drawImageWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;

@end