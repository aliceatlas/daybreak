//
//  SBGoogleSuggestParser.h
//  Sunrise
//
//  Created by Atsushi Jike on 10/04/20.
//  Copyright 2010 SONORAN BLUE. All rights reserved.
//

#import "SBDefinitions.h"


@interface SBGoogleSuggestParser : NSObject <NSXMLParserDelegate>
{
	NSMutableArray *items;
	BOOL _inToplevel;
	BOOL _inCompleteSuggestion;
}
@property (nonatomic, retain) NSMutableArray *items;

+ (id)parser;
- (NSError *)parseData:(NSData *)data;

@end
