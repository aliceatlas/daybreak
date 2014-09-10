//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import "SBDefinitions.h"
#import "SBDocument.h"
#import "SBUtil.h"

#import "SBSectionListView.h"
#import "SBBookmarkListView.h"

#import "NSSavePanel-SBAdditions.h"

#import "SBTabbar.h"

@interface NSToolbar (Private)
- (NSView *)_toolbarView;
@end

@interface NSURLRequest (Private)
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;
@end