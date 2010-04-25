//
//  SBGoogleSuggestParser.m
//  Sunrise
//
//  Created by Atsushi Jike on 10/04/20.
//  Copyright 2010 SONORAN BLUE. All rights reserved.
//

#import "SBGoogleSuggestParser.h"

NSString *kSBGSToplevelTagName = @"toplevel";
NSString *kSBGSCompleteSuggestionTagName = @"CompleteSuggestion";
NSString *kSBGSSuggestionTagName = @"suggestion";
NSString *kSBGSNum_queriesTagName = @"num_queries";
NSString *kSBGSSuggestionAttributeDataArgumentName = @"data";

@implementation SBGoogleSuggestParser

@synthesize items;

+ (id)parser
{
	return [[[self alloc] init] autorelease];
}

- (void)dealloc
{
	[items release];
	[super dealloc];
}

- (NSError *)parseData:(NSData *)data
{
	NSError *err = nil;
	NSXMLParser *parser = nil;
	
	_inToplevel = NO;
	_inCompleteSuggestion = NO;
	parser = [[NSXMLParser alloc] initWithData:data];
	[parser setDelegate:self];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	self.items = [NSMutableArray arrayWithCapacity:0];
	[parser parse];
	
	err = [parser parserError];
	
	[parser release];
	return err;
}

#pragma mark Delegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:kSBGSToplevelTagName])
	{
		_inToplevel = YES;
	}
	else if ([elementName isEqualToString:kSBGSCompleteSuggestionTagName])
	{
		NSMutableDictionary *item = [NSMutableDictionary dictionaryWithCapacity:0];
		_inCompleteSuggestion = YES;
		[item setObject:[NSNumber numberWithInteger:kSBURLFieldItemGoogleSuggestType] forKey:kSBType];
		[self.items addObject:item];
	}
	else {
		if (_inToplevel && _inCompleteSuggestion)
		{
			if ([elementName isEqualToString:kSBGSSuggestionTagName])
			{
				NSString *dataText = [attributeDict objectForKey:kSBGSSuggestionAttributeDataArgumentName];
				if ([dataText length] > 0)
				{
					NSMutableDictionary *item = [self.items lastObject];
					[item setObject:dataText forKey:kSBTitle];
					[item setObject:[dataText searchURLString] forKey:kSBURL];
				}
			}
		}
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (string)
	{
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
{
	if ([elementName isEqualToString:kSBGSToplevelTagName])
	{
		_inToplevel = NO;
	}
	else if ([elementName isEqualToString:kSBGSCompleteSuggestionTagName])
	{
		_inCompleteSuggestion = NO;
	}
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	// Abort parsing
	[parser abortParsing];
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validError
{
	// Abort parsing
	[parser abortParsing];
}

@end
