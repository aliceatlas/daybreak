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

import Cocoa

let SBGigaByteUnitString = "GB"
let SBMegaByteUnitString = "MB"
let SBKiroByteUnitString = "KB"
let SBByteUnitString = "byte"
let SBBytesUnitString = "bytes"

extension String {
    var requestURLString: String {
        var stringValue = self
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
            stringValue = self.searchURLString
        }
        return stringValue
    }
    
    func isURLString(inout hasScheme: Bool) -> Bool {
        var r = false
        if (find(self, " ") == nil && find(self, ".") == nil) || self.hasPrefix("http://localhost") {
            let string = self.URLEncodedString
            let attributedString = NSAttributedString(string: string)
            var range = NSMakeRange(0, 0)
            let URL = attributedString.URLAtIndex(NSMaxRange(range), effectiveRange: &range)
            r = range.location == 0
            if r {
                hasScheme = (URL.scheme.utf16count > 0) ? string.hasPrefix(URL.scheme) : false
                //hasScheme = URL.absoluteString == string;
            }
        }
        return r
    }
    
    var URLEncodedString: String {
        let requestURL = NSURL._web_URLWithUserTypedString(self)
        return requestURL.absoluteString
    }

    var searchURLString: String {
        var stringValue = self
        
        let info = NSBundle.mainBundle().localizedInfoDictionary
        if let gSearchFormat = info["SBGSearchFormat"] as? NSString {
            let str = NSString(format: gSearchFormat, stringValue)
            stringValue = str.URLEncodedString()
        }
        return stringValue
    }
}

func bytesStringForLength(length: Int, unit hasUnit: Bool = true) -> String {
    var string: String
    var value: Float
	let unitString = unitStringForLength(length)
    if length > (1024 * 1024 * 1024) { // giga
		value = length > 0 ? (Float(length) / (1024 * 1024 * 1024)) : 0
        if value == Float(Int(value)) {
            string = "\(Int(value))"
            if hasUnit { string += " \(unitString)" }
		} else {
            string = NSString(format: "%.2f", value)
            if hasUnit { string += NSString(format: " %@", unitString) }
		}
    } else if length > (1024 * 1024) { // mega
		value = length > 0 ? (Float(length) / (1024 * 1024)) : 0
		if value == Float(Int(value)) {
            string = "\(Int(value))"
            if hasUnit { string += " \(unitString)" }
		} else {
            string = NSString(format: "%.1f", value)
            if hasUnit { string += NSString(format: " %@", unitString) }
		}
    } else if length > 1024 { // kilo
		value = length > 0 ? (Float(length) / 1024) : 0
        string = "\(Int(value))"
        if hasUnit { string += NSString(format: " %@", unitString) }
	} else {
        string = "\(length)"
        if hasUnit { string += NSString(format: " %@", unitString) }
	}
	return string
}

func unitStringForLength(length: Int) -> String {
    if length > (1024 * 1024 * 1024) { // giga
		return SBGigaByteUnitString
    } else if length > (1024 * 1024) { // mega
		return  SBMegaByteUnitString
    } else if (length > 1024) { // kilo
		return SBKiroByteUnitString
	}
    return NSLocalizedString((length <= 1) ? SBByteUnitString : SBBytesUnitString, comment: "")
}

func bytesString(receivedLegnth: Int, expectedLength: Int) -> String {
	let expected = bytesStringForLength(expectedLength)
    let sameUnit = unitStringForLength(receivedLegnth) == unitStringForLength(expectedLength)
    let received = bytesStringForLength(receivedLegnth, unit: !sameUnit)
    return "\(received)/\(expected)"
}