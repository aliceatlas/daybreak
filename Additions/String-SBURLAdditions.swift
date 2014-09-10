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
        return (self as NSString).requestURLString
    }
    
    func isURLString(inout hasScheme: Bool) -> Bool {
        var objcHasScheme: ObjCBool = false
        let val = (self as NSString).isURLString(&objcHasScheme)
        hasScheme = Bool(objcHasScheme)
        return val
    }
    
    var URLEncodedString: String {
        return (self as NSString).URLEncodedString
    }

    var searchURLString: String {
        return (self as NSString).searchURLString
    }
}

func bytesStringForLength(length: Int64, unit hasUnit: Bool = true) -> String {
    let formatter = NSByteCountFormatter()
    formatter.countStyle = .Memory
    formatter.includesUnit = hasUnit
    return formatter.stringFromByteCount(length)
}

func unitStringForLength(length: Int64) -> String {
    let formatter = NSByteCountFormatter()
    formatter.countStyle = .Memory
    formatter.includesCount = false
    return formatter.stringFromByteCount(length)
}

func bytesString(receivedLegnth: Int64, expectedLength: Int64) -> String {
	let expected = bytesStringForLength(expectedLength)
    let sameUnit = unitStringForLength(receivedLegnth) == unitStringForLength(expectedLength)
    let received = bytesStringForLength(receivedLegnth, unit: !sameUnit)
    return "\(received)/\(expected)"
}