//
//  SBWebResourcesView.h
//  Sunrise
//
//  Created by Atsushi Jike on 10/03/07.
//  Copyright 2010 Atsushi Jike. All rights reserved.
//

#import "SBDefinitions.h"
#import "SBBLKGUI.h"
#import "SBView.h"

@class SBWebResourcesView;
@protocol SBWebResourcesViewDataSource <NSObject>
- (NSInteger)numberOfRowsInWebResourcesView:(SBWebResourcesView *)aWebResourcesView;
- (id)webResourcesView:(SBWebResourcesView *)aWebResourcesView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;
- (void)webResourcesView:(SBWebResourcesView *)aWebResourcesView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;
@end
@protocol SBWebResourcesViewDelegate <NSObject>
@optional
- (void)webResourcesView:(SBWebResourcesView *)aWebResourcesView shouldDownloadAtRow:(NSInteger)rowIndex;
@end

@interface SBWebResourcesView : SBView
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

@interface SBWebResourceCell : NSCell
{
	BOOL showRoundedPath;
}
@property (nonatomic) BOOL showRoundedPath;

- (CGFloat)side;
- (void)drawTitleWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;

@end

@interface SBWebResourceButtonCell : NSButtonCell
{
	NSImage *highlightedImage;
}
@property (nonatomic, retain) NSImage *highlightedImage;

- (CGFloat)side;
- (void)drawImageWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;

@end