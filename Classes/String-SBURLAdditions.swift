//
//  String-SBURLAdditions.swift
//  Sunrise
//
//  Created by Alice Atlas on 6/29/14.
//
//

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
        if let gSearchFormat = info?.objectForKey("SBGSearchFormat") as? NSString {
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