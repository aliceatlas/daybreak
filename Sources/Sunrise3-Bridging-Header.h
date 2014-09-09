//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import "SBDefinitions.h"
#import "SBDocument.h"
#import "SBUtil.h"

#import "SBAdditions.h"

#import "SBSectionListView.h"
#import "SBBookmarkListView.h"
#import "SBSearchbar.h"

#import "NSColor-SBAdditions.h"

#import "SBTabbarItem.h"

#import "NSSavePanel-SBAdditions.h"

#import "SBTableCell.h"

#import "SBTabbar.h"

@interface NSToolbar (Private)
- (NSView *)_toolbarView;
@end

@interface NSURLRequest (Private)
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;
@end