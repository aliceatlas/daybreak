/*
NSString-SBAdditions.swift

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

extension NSString {
    func containsCharacter(character: unichar) -> Bool {
        for i in 0..<length {
            let c = characterAtIndex(i)
            if c == character {
                return true
            }
        }
        return false
    }
    
    func compareAsVersionString(string: NSString) -> NSComparisonResult {
        var result: NSComparisonResult = .OrderedSame
        let array0 = componentsSeparatedByString(" ") as [NSString]
        let array1 = string.componentsSeparatedByString(" ") as [NSString]
        var string0: NSString!
        var string1: NSString!
        if array1.count > 1 && array0.count > 1 {
            string0 = array0[0]
            string1 = array1[0]
            result = string0.compare(string1)
            if result == .OrderedSame {
                string0 = array0[1]
                string1 = array1[1]
                result = string0.compare(string1)
            }
        } else if array1.count > 0 && array0.count > 1 {
            string0 = array0[0]
            string1 = array1[0]
            result = string0.compare(string1)
            if result == .OrderedSame {
                result = .OrderedAscending
            }
        } else if array1.count > 1 && array0.count > 0 {
            string0 = array0[0]
            string1 = array1[0]
            result = string0.compare(string1)
            if result == .OrderedSame {
                result = .OrderedDescending
            }
        } else if array1.count > 0 && array0.count > 0 {
            string0 = array0[0]
            string1 = array1[0]
            result = string0.compare(string1)
        }
        return result;
    }
    
    class func bytesStringForLength(length: CLongLong) -> NSString {
        return bytesStringForLength(length, unit: true)
    }
    
    class func bytesStringForLength(length: Int64, unit hasUnit: Bool) -> NSString {
        let formatter = NSByteCountFormatter()
        formatter.countStyle = .Memory
        formatter.includesUnit = hasUnit
        return formatter.stringFromByteCount(length)
    }
    
    class func unitStringForLength(length: Int64) -> NSString {
        let formatter = NSByteCountFormatter()
        formatter.countStyle = .Memory
        formatter.includesCount = false
        return formatter.stringFromByteCount(length)
    }
    
    class func bytesString(receivedLegnth: CLongLong, expectedLength: CLongLong) -> NSString {
        let expected = bytesStringForLength(Int64(expectedLength))
        let sameUnit = unitStringForLength(receivedLegnth) == unitStringForLength(expectedLength)
        let received = bytesStringForLength(receivedLegnth, unit: !sameUnit)
        return "\(received)/\(expected)"
    }
    
    func stringByDeletingQuotations() -> NSString {
        return stringByDeletingCharacter("\"")
    }
    
    func stringByDeletingSpaces() -> NSString {
        return stringByDeletingCharacter(" ")
    }
    
    func stringByDeletingCharacter(character: NSString) -> NSString {
        var string = self
        if rangeOfString(character).location != NSNotFound {
            let firstRange = string.rangeOfString(character)
            let lastRange = string.rangeOfString(character, options: .BackwardsSearch)
            var range = NSMakeRange(NSNotFound, 0)
            if firstRange.location != NSNotFound && lastRange.location != NSNotFound {
                if NSEqualRanges(firstRange, lastRange) {
                    string = string.stringByReplacingCharactersInRange(firstRange, withString: "")
                } else {
                    range.location = firstRange.location + firstRange.length
                    range.length = lastRange.location - range.location
                    string = string.substringWithRange(range)
                }
            }
        }
        return string
    }
}

// URL additions
extension NSString {
    func isURLString(inout hasScheme: Bool) -> Bool {
        var r = false
        if (rangeOfString(" ").location == NSNotFound && rangeOfString(".").location != NSNotFound) || hasPrefix("http://localhost") {
            let string = URLEncodedString
            let attributedString = NSAttributedString(string: string)
            var range = NSMakeRange(0, 0)
            let URL = attributedString.URLAtIndex(NSMaxRange(range), effectiveRange: &range)
            r = range.location == 0
            if r {
                #if true
                    hasScheme = (URL.scheme?.utf16Count ?? 0) > 0 ? string.hasPrefix(URL.scheme!) : false
                #else
                    hasScheme = URL.absoluteString == string
                #endif
            }
        }
        return r
    }
    
    var stringByDeletingScheme: NSString? {
        var string = self
        for index in 0..<SBCountOfSchemes {
            let scheme = SBSchemes[index]
            if string.hasPrefix(scheme) {
                return string.substringFromIndex(scheme.utf16Count)
            }
        }
        return nil
    }
    
    var URLEncodedString: NSString {
        let requestURL = NSURL._web_URLWithUserTypedString(self)
        return requestURL.absoluteString!
    }
    
    var URLDecodedString: NSString {
        return NSURL(string: self)._web_userVisibleString()
    }
    
    var requestURLString: NSString {
        var stringValue: NSString = self
        var hasScheme = false
        if stringValue.isURLString(&hasScheme) {
            if !hasScheme {
                if stringValue.hasPrefix("/") {
                    stringValue = "file://" + stringValue
                } else {
                    stringValue = "http://" + stringValue
                }
            }
            stringValue = stringValue.URLEncodedString
        } else {
            stringValue = searchURLString
        }
        return stringValue
    }
    
    var searchURLString: NSString {
        var stringValue = self
        
        let info = NSBundle.mainBundle().localizedInfoDictionary
        let gSearchFormat = info["SBGSearchFormat"] as? NSString
        if gSearchFormat != nil {
            let str = NSString(format: gSearchFormat!, stringValue)
            let requestURL = NSURL._web_URLWithUserTypedString(str)
            stringValue = requestURL.absoluteString!
        }
        return stringValue
    }
}