/*
SBGoogleSuggestParser.swift

Copyright (c) 2014, Alice Atlas
Copyright (c) 2010, Atsushi Jike
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import Foundation

private let kSBGSToplevelTagName = "toplevel"
private let kSBGSCompleteSuggestionTagName = "CompleteSuggestion"
private let kSBGSSuggestionTagName = "suggestion"
private let kSBGSNum_queriesTagName = "num_queries"
private let kSBGSSuggestionAttributeDataArgumentName = "data"

func SBParseGoogleSuggestData(data: NSData, error: NSErrorPointer) -> [SBURLFieldItem]? {
    if let document = NSXMLDocument(data: data, options: 0, error: error) {
        var items: [SBURLFieldItem] = []
        let element = document.rootElement()!
        for suggestion in element.elementsForName(kSBGSCompleteSuggestionTagName) as [NSXMLElement] {
            let item = suggestion.elementsForName(kSBGSSuggestionTagName)[0] as NSXMLElement
            let string = item.attributeForName(kSBGSSuggestionAttributeDataArgumentName)!.stringValue!
            items.append(SBURLFieldItem.GoogleSuggest(title: string, URL: string.searchURLString))
        }
        return items
    }
    error.memory = error.memory ?? NSError(domain: "Daybreak", code: 420, userInfo: nil)
    return nil
}