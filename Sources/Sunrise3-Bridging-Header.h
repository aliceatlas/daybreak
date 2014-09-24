//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import "SBDefinitions.h"
#import "SBUtil.h"

#import "SBView.h"

#import "NSSavePanel-SBAdditions.h"

@interface NSToolbar (Private)
- (NSView *)_toolbarView;
@end

@interface NSURLRequest (Private)
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;
@end