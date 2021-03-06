/*
String-SBURLAdditions.swift

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

let SBGigaByteUnitString = "GB"
let SBMegaByteUnitString = "MB"
let SBKiroByteUnitString = "KB"
let SBByteUnitString = "byte"
let SBBytesUnitString = "bytes"

extension String {
    var stringByDeletingScheme: String? {
        return SBSchemes.first{hasPrefix($0)} !! {suffix(self, count(self)-count($0))}
    }
    
    var requestURLString: String {
        var hasScheme = false
        if isURLString(&hasScheme) {
            var stringValue = self
            if !hasScheme {
                if stringValue.hasPrefix("/") {
                    stringValue = "file://\(stringValue)"
                } else {
                    stringValue = "http://\(stringValue)"
                }
            }
            return stringValue.URLEncodedString
        }
        return searchURLString
    }
    
    func isURLString(inout hasScheme: Bool) -> Bool {
        if (rangeOfString(" ") == nil && rangeOfString(".") != nil) || hasPrefix("http://localhost") {
            let string = URLEncodedString
            let attributedString = NSAttributedString(string: string)
            var range = NSMakeRange(0, 0)
            let URL = attributedString.URLAtIndex(NSMaxRange(range), effectiveRange: &range)
            if range.location == 0 {
                hasScheme = URL?.scheme.ifNotEmpty &! string.hasPrefix
                return true
            }
        }
        return false
    }
    
    var URLEncodedString: String {
        let requestURL = NSURL._web_URLWithUserTypedString(self)
        return requestURL.absoluteString
    }
    
    var URLDecodedString: String? {
        return NSURL(string: self)?._web_userVisibleString()
    }
    
    var searchURLString: String {
        let info = NSBundle.mainBundle().localizedInfoDictionary!
        if let gSearchFormat = info["SBGSearchFormat"] as? String {
            let str = gSearchFormat.format(self)
            let requestURL = NSURL._web_URLWithUserTypedString(str)
            return requestURL.absoluteString
        }
        return self
    }
    
    func compareAsVersionString(string: String) -> NSComparisonResult {
        var result: NSComparisonResult = .OrderedSame
        let array0 = componentsSeparatedByString(" ")
        let array1 = string.componentsSeparatedByString(" ")
        var string0: String!
        var string1: String!
        switch (min(array0.count, 2), min(array1.count, 2)) {
            case (2, 2):
                string0 = array0[0]
                string1 = array1[0]
                result = string0.compare(string1)
                if result == .OrderedSame {
                    string0 = array0[1]
                    string1 = array1[1]
                    result = string0.compare(string1)
                }
            case (2, 1):
                string0 = array0[0]
                string1 = array1[0]
                result = string0.compare(string1)
                if result == .OrderedSame {
                    result = .OrderedAscending
                }
            case (1, 2):
                string0 = array0[0]
                string1 = array1[0]
                result = string0.compare(string1)
                if result == .OrderedSame {
                    result = .OrderedDescending
                }
            case (1, 1):
                string0 = array0[0]
                string1 = array1[0]
                result = string0.compare(string1)
            default:
                break
        }
        return result
    }
    
    static func bytesStringForLength(length: Int64, unit hasUnit: Bool = true) -> String {
        let formatter = NSByteCountFormatter()
        formatter.countStyle = .Memory
        formatter.includesUnit = hasUnit
        return formatter.stringFromByteCount(length)
    }
    
    static func unitStringForLength(length: Int64) -> String {
        let formatter = NSByteCountFormatter()
        formatter.countStyle = .Memory
        formatter.includesCount = false
        return formatter.stringFromByteCount(length)
    }
    
    static func bytesString(receivedLegnth: Int64, expectedLength: Int64) -> String {
        let expected = bytesStringForLength(expectedLength)
        let sameUnit = unitStringForLength(receivedLegnth) == unitStringForLength(expectedLength)
        let received = bytesStringForLength(receivedLegnth, unit: !sameUnit)
        return "\(received)/\(expected)"
    }
}