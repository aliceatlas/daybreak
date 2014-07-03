//
//  SBGoogleSuggestParser.swift
//  Sunrise
//
//  Created by Alice Atlas on 7/2/14.
//
//

import Foundation

let kSBGSToplevelTagName = "toplevel"
let kSBGSCompleteSuggestionTagName = "CompleteSuggestion"
let kSBGSSuggestionTagName = "suggestion"
let kSBGSNum_queriesTagName = "num_queries"
let kSBGSSuggestionAttributeDataArgumentName = "data"

class SBGoogleSuggestParser: NSObject, NSXMLParserDelegate {
    var items: NSMutableDictionary[] = []
    var _inToplevel = false
    var _inCompleteSuggestion = false
    
    class func parser() -> SBGoogleSuggestParser {
        return SBGoogleSuggestParser()
    }
    
    func parseData(data: NSData) -> NSError? {
        _inToplevel = false
        _inCompleteSuggestion = false
        let parser = NSXMLParser(data: data)
        parser.delegate = self
        parser.shouldProcessNamespaces = false
        parser.shouldReportNamespacePrefixes = false
        parser.shouldResolveExternalEntities = false
        items = []
        return parser.parse() ? nil : parser.parserError
    }
    
    // Delegate
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName: String?, attributes: NSDictionary) {
        if elementName == kSBGSToplevelTagName {
            _inToplevel = true
        } else if elementName == kSBGSCompleteSuggestionTagName {
            let item = NSMutableDictionary()
            _inCompleteSuggestion = true
            item[kSBType] = kSBURLFieldItemGoogleSuggestType
            items.append(item)
        } else {
            if _inToplevel && _inCompleteSuggestion {
                if elementName == kSBGSSuggestionTagName {
                    let dataText = attributes[kSBGSSuggestionAttributeDataArgumentName] as String
                    if dataText.utf16count > 0 {
                        let item = items[items.count - 1]
                        item[kSBTitle] = dataText
                        item[kSBURL] = dataText.searchURLString
                    }
                }
            }
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName: String?) {
        if elementName == kSBGSToplevelTagName {
            _inToplevel = false
        } else if elementName == kSBGSCompleteSuggestionTagName {
            _inCompleteSuggestion = false
        }
    }
    
    func parser(parser: NSXMLParser, parseErrorOccurred error: NSError) {
        parser.abortParsing()
    }
    
    func parser(parser: NSXMLParser, validationErrorOccurred error: NSError) {
        parser.abortParsing()
    }
}