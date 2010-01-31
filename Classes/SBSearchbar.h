//
//  SBSearchbar.h
//  Sunrise
//
//  Created by Atsushi Jike on 09/12/19.
//  Copyright 2010 Atsushi Jike. All rights reserved.
//

#import "SBFindbar.h"


@interface SBSearchbar : SBFindbar

+ (CGFloat)minimumWidth;
+ (CGFloat)availableWidth;
// Construction
- (void)constructBackwardButton;
- (void)constructForwardButton;
- (void)constructCaseSensitiveCheck;
- (void)constructWrapCheck;
// Actions
- (void)executeDoneSelector:(id)sender;
- (void)executeClose;

@end