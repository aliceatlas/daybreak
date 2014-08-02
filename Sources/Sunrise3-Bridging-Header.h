//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import "SBDefinitions.h"
#import "SBDocument.h"
#import "SBDocumentWindow.h"
#import "SBLocalizationWindowController.h"
#import "SBSavePanel.h"
#import "SBUpdateView.h"
#import "SBUtil.h"

#import "SBAdditions.h"

#import "SBSectionGroupe.h"
#import "SBSectionListView.h"
#import "SBBookmarkListView.h"
#import "SBSearchbar.h"

#import "NSColor-SBAdditions.h"
#import "SBFixedSplitView.h"

#import "SBDownloadsView.h"

@interface NSToolbar (Private)
- (NSView *)_toolbarView;
@end